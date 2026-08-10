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

  /// Una boleta abierta con una prenda y sin anticipo: lo que la lista de
  /// entregas de Caja tiene que encontrar. Se queda en `received` a propósito.
  Future<void> seedOpenOrder({
    required String id,
    required String serial,
    required String name,
  }) async {
    await database
        .into(database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(id: 'cliente-$id', fullName: name),
        );
    await database
        .into(database.orderEntries)
        .insert(
          OrderEntriesCompanion.insert(
            id: id,
            orderDate: today,
            dailyNumber: serial.hashCode.abs() % 90 + 1,
            bookletSerial: Value(serial),
            customerId: 'cliente-$id',
            totalPieces: const Value(3),
            status: 'received',
            subtotal: '80.00',
            discountTotal: '0.00',
            total: '80.00',
            receivedById: 'u1',
          ),
        );
    await database
        .into(database.orderGarmentEntries)
        .insert(
          OrderGarmentEntriesCompanion.insert(
            id: 'prenda-$id',
            orderId: id,
            garmentTypeId: 'gt-camisa',
            quantity: 3,
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

  group('entregas y cobros', () {
    cashTest('las boletas abiertas se listan con su saldo', (tester) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await openCash(tester);

      expect(find.text('ENTREGAS Y COBROS'), findsOneWidget);
      expect(find.text('1 sin entregar'), findsOneWidget);
      expect(find.text('B-000144'), findsOneWidget);
      expect(find.text('Sonia Pérez'), findsOneWidget);
      // Nadie la pasó por «en proceso» ni «lista» y aun así está acá: es el
      // caso normal (plan 0001 D13).
      expect(find.text('saldo'), findsOneWidget);
    });

    cashTest('tocar la boleta la entrega y la cobra de una vez', (tester) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await openCash(tester);

      await tester.tap(find.text('Sonia Pérez'));
      await tester.pumpAndSettle();

      // La hoja de una boleta: las dos preguntas del papel, en su orden.
      expect(find.text('Entregar B-000144'), findsOneWidget);
      expect(find.text('¿CUÁNTO PAGÓ?'), findsOneWidget);
      expect(find.text('¿CÓMO PAGÓ?'), findsOneWidget);
      expect(find.text('Entran Q80.00 a la caja de hoy'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Cobrar y entregar'));
      await tester.pumpAndSettle();

      // La boleta se cerró y su cobro es un ingreso del día.
      final order = await (database.select(
        database.orderEntries,
      )..where((row) => row.id.equals('p-1'))).getSingle();
      expect(order.status, 'delivered');
      expect(order.deliveredById, 'u1');

      final payments = await database.select(database.orderPaymentEntries).get();
      expect(payments.single.amount, '80.00');
      expect(payments.single.method, 'cash');
      expect(payments.single.isAdvance, isFalse);

      // Y ya no está entre las pendientes: entregada es entregada.
      expect(find.text('No queda ropa pendiente de entregar.'), findsOneWidget);
    });

    cashTest('el cliente que paga una parte queda entregado con saldo', (tester) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await openCash(tester);

      await tester.tap(find.text('Sonia Pérez'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Queda debiendo'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.ancestor(
            of: find.text('PAGA AHORA'),
            matching: find.byType(AppFormField),
          ),
          matching: find.byType(TextField),
        ),
        '50',
      );
      await tester.pumpAndSettle();
      expect(find.text('Queda debiendo Q30.00'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Entregar con saldo'));
      await tester.pumpAndSettle();

      final order = await (database.select(
        database.orderEntries,
      )..where((row) => row.id.equals('p-1'))).getSingle();
      expect(order.status, 'delivered');

      // Entra lo que pagó, no el saldo entero: los Q30 quedan a deber.
      final payments = await database.select(database.orderPaymentEntries).get();
      expect(payments.single.amount, '50.00');
    });

    cashTest('la casilla marca para el repaso en lote del cierre', (tester) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await openCash(tester);

      await tester.tap(find.byKey(const ValueKey('mark-p-1')));
      await tester.pumpAndSettle();
      expect(find.text('1 boleta marcada · Q80.00'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Registrar'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar 1 entrega'), findsOneWidget);
      expect(find.text('Entra a caja'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Entregar'));
      await tester.pumpAndSettle();

      final order = await (database.select(
        database.orderEntries,
      )..where((row) => row.id.equals('p-1'))).getSingle();
      expect(order.status, 'delivered');

      final payments = await database.select(database.orderPaymentEntries).get();
      expect(payments.single.amount, '80.00');
      expect(payments.single.isAdvance, isFalse);

      // Y deja de estar marcada: lo que ya salió no puede seguir contando.
      expect(find.textContaining('boleta marcada'), findsNothing);
    });

    cashTest('el buscador filtra por número de boleta', (tester) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await seedOpenOrder(id: 'p-2', serial: 'B-000139', name: 'Lucía Marroquín');
      await openCash(tester);

      await tester.enterText(find.byType(AppSearchField), '000139');
      // El campo tiene retardo: sin dejarlo pasar la lista no se ha rehecho.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Lucía Marroquín'), findsOneWidget);
      expect(find.text('Sonia Pérez'), findsNothing);
    });

    cashTest('un día cerrado ya no ofrece registrar entregas', (tester) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await seedClosure();
      await openCash(tester);

      expect(find.text('ENTREGAS Y COBROS'), findsNothing);
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

    cashTest('sin permiso de entrega el bloque de entregas no se dibuja', (
      tester,
    ) async {
      await seedOpenOrder(id: 'p-1', serial: 'B-000144', name: 'Sonia Pérez');
      await openCash(
        tester,
        permissions: const [AppPermissions.expensesRead],
      );

      expect(find.text('ENTREGAS Y COBROS'), findsNothing);
    });
  });
}
