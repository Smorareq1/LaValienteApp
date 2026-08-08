import 'package:design_system/design_system.dart';
import 'package:drift/drift.dart' show Value;
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

class _IdleSyncEngine extends SyncEngine {
  @override
  SyncEngineState build() => const SyncEngineState();
}

class _IdleSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => const SyncStatus.synced();
}

/// La pestaña, no la cifra del resumen: las dos dicen "Ingresos" y "Gastos"
/// porque hablan de lo mismo.
Finder tab(String label) =>
    find.descendant(of: find.byType(AppTabBar), matching: find.text(label));

void main() {
  late AppDatabase database;
  var closed = false;

  final today = isoDate(businessDate());

  /// Misma receta que en las otras pantallas: desmontar y dejar correr el
  /// temporizador que drift agenda al cancelar un stream, antes de cerrar la BD.
  void cashTest(String description, Future<void> Function(WidgetTester) body) {
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

  Future<void> seedPayment({
    required String amount,
    String method = 'cash',
    bool isAdvance = true,
  }) async {
    await database
        .into(database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(id: 'cliente-1', fullName: 'Ana Pérez'),
        );
    await database
        .into(database.orderEntries)
        .insert(
          OrderEntriesCompanion.insert(
            id: 'pedido-1',
            orderDate: today,
            dailyNumber: 7,
            customerId: 'cliente-1',
            status: 'received',
            subtotal: '80.00',
            discountTotal: '0.00',
            total: '80.00',
            receivedById: 'u1',
          ),
        );
    await database
        .into(database.orderPaymentEntries)
        .insert(
          OrderPaymentEntriesCompanion.insert(
            id: 'pago-$amount',
            orderId: 'pedido-1',
            amount: amount,
            method: method,
            isAdvance: Value(isAdvance),
            receivedById: 'u1',
            // A media mañana en Cobán: dentro de la ventana del día de negocio.
            paidAt: businessDate().toUtc().add(const Duration(hours: 16)),
          ),
        );
  }

  Future<void> seedExpense({
    required String amount,
    String concept = 'Gas — 2 sacos',
    String status = 'paid',
    String method = 'cash',
  }) async {
    await database
        .into(database.expenseCategoryEntries)
        .insert(
          ExpenseCategoryEntriesCompanion.insert(
            id: 'cat-1',
            name: 'Compra de insumos',
          ),
        );
    await database
        .into(database.expenseEntries)
        .insert(
          ExpenseEntriesCompanion.insert(
            id: 'gasto-$concept',
            expenseDate: today,
            categoryId: 'cat-1',
            concept: concept,
            amount: amount,
            method: method,
            status: status,
            createdById: 'u1',
          ),
        );
  }

  Future<void> seedClosure() {
    return database
        .into(database.dailyClosureEntries)
        .insert(
          DailyClosureEntriesCompanion.insert(
            id: 'acta-1',
            closeDate: today,
            ordersIncome: '80.00',
            suppliesIncome: '0.00',
            expensesTotal: '0.00',
            netTotal: '80.00',
            cashIncome: '80.00',
            transferIncome: '0.00',
            cashExpenses: '0.00',
            transferExpenses: '0.00',
            closedById: 'u1',
            closedAt: DateTime.utc(2026, 7, 19, 1, 12),
          ),
        );
  }

  Future<void> openCash(
    WidgetTester tester, {
    List<String> permissions = const [AppPermissions.all],
  }) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureStorageProvider.overrideWithValue(_UnusedStorage()),
          syncRemoteDataSourceProvider.overrideWithValue(_UnusedServer()),
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
  }

  group('el día', () {
    cashTest('suma los cobros del día y los muestra en la pestaña de ingresos', (
      tester,
    ) async {
      await seedPayment(amount: '80.00');
      await openCash(tester);

      expect(find.text('Caja del día'), findsOneWidget);
      expect(find.text('Efectivo en caja ahora'), findsOneWidget);
      expect(find.text('Pedido #7 · Ana Pérez'), findsOneWidget);
      // Dos veces: la cifra del resumen y la pestaña. Dicen lo mismo a
      // propósito, así que la prueba no puede pedir una sola.
      expect(find.text('Ingresos'), findsNWidgets(2));
    });

    cashTest('el gasto resta del neto y aparece en su pestaña', (tester) async {
      await seedPayment(amount: '80.00');
      await seedExpense(amount: '20.00');
      await openCash(tester);

      await tester.tap(tab('Gastos'));
      await tester.pumpAndSettle();

      expect(find.text('Gas — 2 sacos'), findsOneWidget);
      expect(find.text('Compra de insumos · efectivo'), findsOneWidget);
      expect(find.text('Total de gastos'), findsOneWidget);
    });

    cashTest('un gasto pendiente se marca y se explica', (tester) async {
      // Cuenta contra el día pero no salió del cajón: es la diferencia que el
      // cierre advierte, dicha antes de llegar a él.
      await seedExpense(amount: '30.00', status: 'pending');
      await openCash(tester);

      expect(
        find.textContaining('Q30.00 en gastos pendientes'),
        findsOneWidget,
      );

      await tester.tap(tab('Gastos'));
      await tester.pumpAndSettle();
      expect(find.text('Pendiente'), findsOneWidget);
    });

    cashTest('un día sin movimientos lo dice en vez de mostrar ceros sueltos', (
      tester,
    ) async {
      await openCash(tester);

      expect(find.text('Todavía no entra nada'), findsOneWidget);
    });
  });

  group('candado de fecha', () {
    cashTest('una fecha cerrada muestra el candado y apaga las acciones', (
      tester,
    ) async {
      await seedPayment(amount: '80.00');
      await seedClosure();
      await openCash(tester);

      expect(find.textContaining('Día cerrado a las'), findsOneWidget);

      // Los botones siguen visibles —esconderlos dejaría la pantalla sin
      // explicación— pero no hacen nada: el candado lo aplica el servidor y
      // esto evita mandar una captura que va a caer a la cola de revisión.
      final gasto = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Gasto'));
      final venta = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Venta'));
      expect(gasto.onPressed, isNull);
      expect(venta.onPressed, isNull);
    });
  });

  group('permisos', () {
    cashTest('sin permiso de venta el botón de venta no se dibuja', (tester) async {
      await openCash(
        tester,
        permissions: const [
          AppPermissions.expensesRead,
          AppPermissions.expensesCreate,
        ],
      );

      expect(find.text('Gasto'), findsOneWidget);
      expect(find.text('Venta'), findsNothing);
    });
  });
}
