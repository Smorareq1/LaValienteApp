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
import 'package:la_valiente/features/home/ui/widgets/cash_summary_card.dart';
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

  @override
  Future<void> sync() async {}
}

class _IdleSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => const SyncStatus.synced();
}

/// Inicio (Plan 0006 §4.1) contra la BD local: la pantalla se abre con las
/// cifras del día ya puestas, sin pedirle nada al servidor.
void main() {
  late AppDatabase database;
  var closed = false;

  final today = isoDate(businessDate());

  /// Misma receta que las otras pantallas: desmontar y dejar correr el
  /// temporizador que drift agenda al cancelar un stream, antes de cerrar la BD.
  void homeTest(String description, Future<void> Function(WidgetTester) body) {
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

  Future<void> seedCustomer() {
    return database
        .into(database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(id: 'cliente-1', fullName: 'Ana Pérez'),
        );
  }

  Future<void> seedOrder({
    required String id,
    required int dailyNumber,
    required String status,
    String total = '80.00',
    int pieces = 4,
    int hourOfDay = 16,
  }) {
    return database
        .into(database.orderEntries)
        .insert(
          OrderEntriesCompanion.insert(
            id: id,
            orderDate: today,
            dailyNumber: dailyNumber,
            customerId: 'cliente-1',
            status: status,
            subtotal: total,
            discountTotal: '0.00',
            total: total,
            totalPieces: Value(pieces),
            receivedById: 'u1',
            createdAt: Value(
              businessDate().toUtc().add(Duration(hours: hourOfDay)),
            ),
          ),
        );
  }

  Future<void> seedPayment({
    required String orderId,
    required String amount,
    String method = 'cash',
  }) {
    return database
        .into(database.orderPaymentEntries)
        .insert(
          OrderPaymentEntriesCompanion.insert(
            id: 'pago-$orderId-$amount',
            orderId: orderId,
            amount: amount,
            method: method,
            receivedById: 'u1',
            // A media mañana en Cobán: dentro de la ventana del día de negocio.
            paidAt: businessDate().toUtc().add(const Duration(hours: 16)),
          ),
        );
  }

  Future<void> seedExpense({required String amount, String status = 'paid'}) async {
    await database
        .into(database.expenseCategoryEntries)
        .insert(
          ExpenseCategoryEntriesCompanion.insert(id: 'cat-1', name: 'Gas'),
        );
    await database
        .into(database.expenseEntries)
        .insert(
          ExpenseEntriesCompanion.insert(
            id: 'gasto-$amount',
            expenseDate: today,
            categoryId: 'cat-1',
            concept: 'Gas — 2 sacos',
            amount: amount,
            method: 'cash',
            status: status,
            createdById: 'u1',
          ),
        );
  }

  Future<void> openHome(
    WidgetTester tester, {
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
  }

  group('el dinero del día', () {
    homeTest('suma los cobros locales en vez de mostrar cero', (tester) async {
      await seedCustomer();
      await seedOrder(id: 'pedido-1', dailyNumber: 7, status: 'ready');
      await seedPayment(orderId: 'pedido-1', amount: '50.00');
      await seedPayment(orderId: 'pedido-1', amount: '30.00', method: 'transfer');
      await seedExpense(amount: '20.00');
      await openHome(tester);

      // Q80 cobrados, repartidos entre el cajón y el banco, y Q20 de gasto.
      // Se busca dentro de la tarjeta: el total de la boleta también dice Q80.
      Finder inCard(String text) => find.descendant(
        of: find.byType(CashSummaryCard),
        matching: find.text(text),
      );

      expect(find.text('Cobrado hasta ahora'), findsOneWidget);
      expect(inCard('Q80.00'), findsOneWidget);
      expect(inCard('Efectivo Q50'), findsOneWidget);
      expect(inCard('Transferencia Q30'), findsOneWidget);
      expect(inCard('Q20.00'), findsOneWidget);
    });

    homeTest('el saldo del pedido queda como "por cobrar"', (tester) async {
      await seedCustomer();
      await seedOrder(id: 'pedido-1', dailyNumber: 7, status: 'ready');
      await seedPayment(orderId: 'pedido-1', amount: '30.00');
      await openHome(tester);

      // Q80 de boleta con Q30 abonados: Q50 que el día todavía espera.
      expect(find.text('Por cobrar'), findsOneWidget);
      expect(find.text('Q50.00'), findsWidgets);
    });

    homeTest('un día sin movimiento se muestra en cero, no vacío', (tester) async {
      await openHome(tester);

      expect(find.text('Cobrado hasta ahora'), findsOneWidget);
      expect(find.text('Nada listo por ahora'), findsOneWidget);
    });
  });

  group('el taller', () {
    homeTest('cuenta los pedidos de hoy por estado', (tester) async {
      await seedCustomer();
      await seedOrder(id: 'p1', dailyNumber: 1, status: 'received');
      await seedOrder(id: 'p2', dailyNumber: 2, status: 'in_progress');
      await seedOrder(id: 'p3', dailyNumber: 3, status: 'in_progress');
      await seedOrder(id: 'p4', dailyNumber: 4, status: 'ready');
      await seedOrder(id: 'p5', dailyNumber: 5, status: 'delivered');
      await openHome(tester);

      // Dos en proceso, uno en cada uno de los otros estados. Se leen por su
      // etiqueta: el "2" suelto también podría venir de cualquier otra cifra.
      String countUnder(String label) {
        // Cada contador es una Column con la cifra arriba y la etiqueta abajo.
        final column = find
            .ancestor(of: find.text(label), matching: find.byType(Column))
            .first;
        final texts = find.descendant(of: column, matching: find.byType(Text));
        return tester.widget<Text>(texts.first).data!;
      }

      expect(countUnder('Recibidos'), '1');
      expect(countUnder('En proceso'), '2');
      expect(countUnder('Listos'), '1');
    });

    homeTest('los listos se listan del más viejo al más nuevo', (tester) async {
      await seedCustomer();
      await seedOrder(id: 'p1', dailyNumber: 1, status: 'ready', hourOfDay: 20);
      await seedOrder(id: 'p2', dailyNumber: 2, status: 'ready', hourOfDay: 14);
      await openHome(tester);

      // El que lleva más tiempo en el estante va primero: es el que hay que
      // entregar antes de que el cliente pregunte.
      final references = tester
          .widgetList<Text>(find.textContaining('No. #'))
          .map((text) => text.data!)
          .toList();
      expect(references.first, startsWith('No. #2'));
      expect(references.length, 2);
    });

    homeTest('un pedido sin sincronizar se marca en su tarjeta', (tester) async {
      await seedCustomer();
      await database
          .into(database.orderEntries)
          .insert(
            OrderEntriesCompanion.insert(
              id: 'p1',
              syncStatus: const Value('pending'),
              orderDate: today,
              // Correlativo provisional: negativo hasta que el servidor numere.
              dailyNumber: -1,
              customerId: 'cliente-1',
              status: 'ready',
              subtotal: '80.00',
              discountTotal: '0.00',
              total: '80.00',
              receivedById: 'u1',
            ),
          );
      await openHome(tester);

      expect(find.textContaining('Folio P-1 · sin sincronizar'), findsOneWidget);
    });
  });

  group('permisos', () {
    homeTest('sin daily_close.read no se ve la tarjeta de dinero', (tester) async {
      await seedCustomer();
      await seedOrder(id: 'pedido-1', dailyNumber: 7, status: 'ready');
      await seedPayment(orderId: 'pedido-1', amount: '80.00');
      await openHome(
        tester,
        permissions: const [AppPermissions.ordersRead],
      );

      expect(find.text('Cobrado hasta ahora'), findsNothing);
      // Lo del taller sí: no es dinero.
      expect(find.text('En el taller'), findsOneWidget);
    });
  });
}
