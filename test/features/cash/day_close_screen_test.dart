import 'package:design_system/design_system.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/app.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/core/time/business_date.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/cash/data/daily_close_remote_datasource.dart';
import 'package:la_valiente/features/cash/models/day_close.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/models/sync_status.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';
import 'package:la_valiente/features/sync/state/sync_status_controller.dart';

class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

/// Motor apagado. `sync()` también se anula: cerrar el día pide un ciclo para
/// que el candado baje por el feed, y aquí ese ciclo solo dejaría un temporizador
/// de reintento colgando contra un servidor que no existe.
class _IdleSyncEngine extends SyncEngine {
  @override
  SyncEngineState build() => const SyncEngineState();

  @override
  Future<void> sync({String reason = 'a mano'}) async {}
}

class _IdleSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => const SyncStatus.synced();
}

/// Lo que lanza Dio cuando de verdad no se alcanza al servidor.
///
/// Un `Exception` pelado no sirve para esta prueba: la pantalla ya no dice
/// "necesita conexión" ante cualquier fallo —decirlo mandaba a revisar el wifi
/// a quien tenía el wifi perfecto— sino que hace caso al tipo, y un error
/// genérico es justamente el caso que ahora se muestra distinto.
DioException _noNetwork() => DioException(
  requestOptions: RequestOptions(path: '/daily-close/preview'),
  type: DioExceptionType.connectionError,
);

/// El servidor del cierre, sin red: el acta es online-only y lo que se prueba
/// aquí es qué hace la pantalla con lo que le respondan.
class _FakeDailyClose implements DailyCloseRemoteDataSource {
  _FakeDailyClose({
    required this.today,
    this.closure,
    this.fails = false,
    DioException? failure,
  }) : failure = failure ?? _noNetwork();

  DayClosePreview today;
  DayClosureRecord? closure;
  bool fails;

  /// Con qué falla cuando [fails]. Por defecto, falta de red.
  final DioException failure;

  int closeCalls = 0;
  int reopenCalls = 0;
  String? lastNotes;
  String? lastReason;

  @override
  Future<DayClosePreview> preview(String date) async {
    if (fails) throw failure;
    return today;
  }

  @override
  Future<List<DayClosureRecord>> history({
    required String from,
    required String to,
  }) async {
    if (fails) throw failure;
    final record = closure;
    return record == null ? const [] : [record];
  }

  @override
  Future<DayClosureRecord> close({required String date, String? notes}) async {
    closeCalls++;
    lastNotes = notes;
    return _record(date: date, id: 'acta-nueva');
  }

  @override
  Future<DayClosureRecord> reopen({
    required String id,
    required String reason,
  }) async {
    reopenCalls++;
    lastReason = reason;
    return _record(date: today.closeDate, id: id, reopenReason: reason);
  }
}

DayClosePreview _preview({
  required String date,
  bool isClosed = false,
  List<String> warnings = const [],
}) {
  return DayClosePreview(
    closeDate: date,
    ordersIncome: 89500,
    suppliesIncome: 10000,
    expensesTotal: 23100,
    netTotal: 76400,
    cashIncome: 79500,
    transferIncome: 20000,
    cashExpenses: 23100,
    transferExpenses: 0,
    ordersDelivered: 12,
    isClosed: isClosed,
    warnings: warnings,
    closureId: isClosed ? 'acta-1' : null,
  );
}

DayClosureRecord _record({
  required String date,
  required String id,
  String? notes,
  String? reopenReason,
}) {
  return DayClosureRecord(
    id: id,
    closeDate: date,
    ordersIncome: 89500,
    suppliesIncome: 10000,
    expensesTotal: 23100,
    netTotal: 76400,
    cashIncome: 79500,
    transferIncome: 20000,
    cashExpenses: 23100,
    transferExpenses: 0,
    ordersDelivered: 12,
    closedById: 'u1',
    closedAt: DateTime.utc(2026, 7, 19, 1, 12),
    version: 1,
    notes: notes,
    reopenedById: reopenReason == null ? null : 'u1',
    reopenReason: reopenReason,
  );
}

void main() {
  late AppDatabase database;
  var closed = false;

  final today = isoDate(businessDate());

  void closeTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await database.close();
      closed = true;
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    closed = false;
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    if (!closed) await database.close();
  });

  Future<void> openClose(
    WidgetTester tester, {
    required _FakeDailyClose server,
    List<String> permissions = const [AppPermissions.all],
  }) async {
    tester.view.physicalSize = const Size(400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureStorageProvider.overrideWithValue(_UnusedStorage()),
          syncRemoteDataSourceProvider.overrideWithValue(_UnusedServer()),
          dailyCloseRemoteDataSourceProvider.overrideWithValue(server),
          authControllerProvider.overrideWith(
            () => _FakeAuthController(
              AuthUser(
                id: 'u1',
                username: 'mostrador',
                fullName: 'Marta González',
                roles: const ['admin'],
                permissions: permissions,
              ),
            ),
          ),
          syncEngineProvider.overrideWith(_IdleSyncEngine.new),
          syncStatusControllerProvider.overrideWith(_IdleSyncStatus.new),
        ],
        child: const LaValienteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Caja'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar día'));
    await tester.pumpAndSettle();
  }

  group('el acta', () {
    closeTest('muestra los totales y el arqueo del servidor', (tester) async {
      await openClose(tester, server: _FakeDailyClose(today: _preview(date: today)));

      expect(find.text('Cierre del día'), findsOneWidget);
      expect(find.text('Ingresos por pedidos'), findsOneWidget);
      expect(find.text('12 pedidos entregados'), findsOneWidget);
      expect(find.text('NETO DEL DÍA'), findsOneWidget);
      // El arqueo: lo que debería quedar en el cajón es el efectivo que entró
      // menos el que salió, no el neto del día.
      expect(find.text('Debería haber en el cajón'), findsOneWidget);
    });

    closeTest('traduce las advertencias del servidor', (tester) async {
      await openClose(
        tester,
        server: _FakeDailyClose(
          today: _preview(
            date: today,
            warnings: const ['open_tickets:2', 'pending_expenses:80.00'],
          ),
        ),
      );

      expect(find.text('Antes de firmar'), findsOneWidget);
      expect(find.text('2 boletas del día siguen sin entregarse.'), findsOneWidget);
      expect(find.textContaining('Q80.00 en gastos'), findsOneWidget);
    });
  });

  group('cerrar', () {
    closeTest('pide confirmación y manda las notas', (tester) async {
      final server = _FakeDailyClose(today: _preview(date: today));
      await openClose(tester, server: server);

      await tester.enterText(
        find.widgetWithText(AppTextField, 'Lo que haya que dejar dicho de este día'),
        'Faltó cobrar el pedido 12',
      );
      await tester.tap(find.widgetWithText(AppButton, 'Cerrar día'));
      await tester.pumpAndSettle();

      // El diálogo dice qué pasa después y con qué cifra se archiva, no
      // "¿estás seguro?".
      final message = find.descendant(
        of: find.byType(AppConfirmDialog),
        matching: find.textContaining('La fecha queda bloqueada'),
      );
      expect(message, findsOneWidget);
      expect(tester.widget<Text>(message).data, contains('Q764.00'));

      await tester.tap(find.widgetWithText(AppButton, 'Cerrar día').last);
      await tester.pumpAndSettle();

      expect(server.closeCalls, 1);
      expect(server.lastNotes, 'Faltó cobrar el pedido 12');
    });

    closeTest('echarse atrás no cierra nada', (tester) async {
      final server = _FakeDailyClose(today: _preview(date: today));
      await openClose(tester, server: server);

      await tester.tap(find.widgetWithText(AppButton, 'Cerrar día'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Cancelar'));
      await tester.pumpAndSettle();

      expect(server.closeCalls, 0);
    });
  });

  group('día ya cerrado', () {
    closeTest('se abre en modo acta, con quién firmó y sus notas', (tester) async {
      await openClose(
        tester,
        server: _FakeDailyClose(
          today: _preview(date: today, isClosed: true),
          closure: _record(date: today, id: 'acta-1', notes: 'Cuadró al centavo'),
        ),
      );

      expect(find.text('Acta del día'), findsOneWidget);
      expect(find.textContaining('Cerrado a las'), findsOneWidget);
      expect(find.text('Cuadró al centavo'), findsOneWidget);
      // Ya no hay nada que firmar ni un campo donde escribir.
      expect(find.widgetWithText(AppButton, 'Cerrar día'), findsNothing);
      expect(find.text('Reabrir el día'), findsOneWidget);
    });

    closeTest('reabrir exige un motivo y lo manda', (tester) async {
      final server = _FakeDailyClose(
        today: _preview(date: today, isClosed: true),
        closure: _record(date: today, id: 'acta-1'),
      );
      await openClose(tester, server: server);

      await tester.tap(find.widgetWithText(AppButton, 'Reabrir el día'));
      await tester.pumpAndSettle();

      // Sin motivo no se reabre: el servidor lo exige y decirlo aquí evita el
      // viaje.
      await tester.tap(find.widgetWithText(AppButton, 'Reabrir día'));
      await tester.pumpAndSettle();
      expect(find.text('Escribí por qué se reabre'), findsOneWidget);
      expect(server.reopenCalls, 0);

      await tester.enterText(
        find.widgetWithText(AppTextField, 'Ej. faltó anotar el gas'),
        'Faltó anotar el gas',
      );
      await tester.tap(find.widgetWithText(AppButton, 'Reabrir día'));
      await tester.pumpAndSettle();

      expect(server.reopenCalls, 1);
      expect(server.lastReason, 'Faltó anotar el gas');
    });
  });

  group('permisos y red', () {
    closeTest('sin permiso de cerrar se lee el día pero no se firma', (tester) async {
      await openClose(
        tester,
        server: _FakeDailyClose(today: _preview(date: today)),
        permissions: const [
          AppPermissions.expensesRead,
          AppPermissions.dailyCloseRead,
        ],
      );

      expect(find.text('NETO DEL DÍA'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Cerrar día'), findsNothing);
      expect(
        find.textContaining('Cerrar el día es cosa de un administrador'),
        findsOneWidget,
      );
    });

    closeTest('sin red lo dice y ofrece reintentar', (tester) async {
      await openClose(
        tester,
        server: _FakeDailyClose(today: _preview(date: today), fails: true),
      );

      expect(find.text('El cierre necesita conexión'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Reintentar'), findsOneWidget);
    });

    // Un servidor que se queda callado no es un teléfono sin señal, y la
    // pantalla llegó a decir lo mismo en los dos casos. Con el túnel de
    // desarrollo colgándose una de cada cinco peticiones, ese mensaje mandaba a
    // revisar una red que estaba perfecta.
    closeTest('un servidor que no contesta no se confunde con falta de red', (
      tester,
    ) async {
      await openClose(
        tester,
        server: _FakeDailyClose(
          today: _preview(date: today),
          fails: true,
          failure: DioException(
            requestOptions: RequestOptions(path: '/daily-close/preview'),
            type: DioExceptionType.receiveTimeout,
          ),
        ),
      );

      expect(find.text('El servidor no contestó a tiempo'), findsOneWidget);
      expect(find.text('El cierre necesita conexión'), findsNothing);
      expect(find.widgetWithText(AppButton, 'Reintentar'), findsOneWidget);
    });
  });
}
