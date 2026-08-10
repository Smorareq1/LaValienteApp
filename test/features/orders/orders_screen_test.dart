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
import 'package:la_valiente/features/catalog/models/catalog.dart';
import 'package:la_valiente/features/orders/data/orders_local_datasource.dart';
import 'package:la_valiente/features/orders/data/orders_repository.dart';
import 'package:la_valiente/features/orders/domain/order_capture.dart';
import 'package:la_valiente/features/orders/domain/order_pricing.dart';
import 'package:la_valiente/features/orders/models/order.dart';
import 'package:la_valiente/features/orders/ui/widgets/order_progress.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
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

final _book = OrderPriceBook(
  services: [
    ServiceType(
      id: 'st-tub',
      code: 'wash_tub',
      name: 'Lavado por tina',
      pricingMode: PricingMode.tiered,
      options: const [
        ServiceOption(
          id: 'so-tub-g',
          serviceTypeId: 'st-tub',
          code: 'G',
          name: 'Tina grande',
        ),
      ],
    ),
  ],
  prices: const [
    ServicePrice(
      id: 'sp-tub-g',
      serviceTypeId: 'st-tub',
      serviceOptionId: 'so-tub-g',
      amount: '30.00',
      validFrom: '2020-01-01',
    ),
  ],
  onDate: '2020-01-01',
);

void main() {
  late AppDatabase database;
  late OrdersRepository orders;
  var closed = false;
  var ids = 0;

  /// Misma receta que en las otras pantallas: desmontar y dejar correr el
  /// temporizador que drift agenda al cancelar un stream, antes de cerrar la BD.
  void orderTest(String description, Future<void> Function(WidgetTester) body) {
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
    ids = 0;
    database = AppDatabase(NativeDatabase.memory());
    orders = OrdersRepository(
      database: database,
      local: OrdersLocalDataSource(database),
      sync: SyncRepository(
        local: SyncLocalDataSource(database),
        remote: _UnusedServer(),
        storage: _UnusedStorage(),
        mirrors: const {},
        device: const DeviceDescriptor(
          name: 'Tablet',
          platform: 'android',
          appVersion: '1.0.0',
        ),
        uuid: () => 'op-${++ids}',
      ),
      uuid: () => 'id-${++ids}',
    );
  });

  tearDown(() async {
    if (!closed) await database.close();
  });

  /// Deja un pedido del día de hoy en la BD local, como si se acabara de
  /// capturar en el mostrador.
  Future<String> seedOrder({PaymentDraft? advance, bool crowded = false}) async {
    await database
        .into(database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(
            id: 'cliente-1',
            fullName: 'Ana Pérez',
            phone: const Value('5555-1234'),
            nit: const Value('1234567-8'),
          ),
        );
    for (final (id, name) in const [
      ('gt-camisa', 'Camisa'),
      ('gt-pantalon', 'Pantalón de vestir'),
      ('gt-toalla', 'Toalla grande de baño'),
    ]) {
      if (!crowded && id != 'gt-camisa') continue;
      await database
          .into(database.garmentTypeEntries)
          .insert(GarmentTypeEntriesCompanion.insert(id: id, name: name));
    }

    final capture = OrderCapture(
      orderDate: isoDate(businessDate()),
      customerId: 'cliente-1',
      bookletSerial: crowded ? '10432' : null,
      weightLbs: crowded ? 2250 : null,
      observations: crowded
          ? 'Camisa blanca manchada de tinta. El cliente pasa el jueves temprano.'
          : null,
      garments: [
        const GarmentDraft(garmentTypeId: 'gt-camisa', quantity: 3),
        if (crowded) ...const [
          GarmentDraft(garmentTypeId: 'gt-pantalon', quantity: 4),
          GarmentDraft(garmentTypeId: 'gt-toalla', quantity: 5),
        ],
      ],
      charges: const [ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
      advancePayment: advance,
    );
    final result = await orders.create(
      capture: capture,
      priced: priceOrder(
        charges: capture.charges,
        discounts: const [],
        book: _book,
        totalPieces: capture.totalPieces,
      ),
      receivedById: 'u1',
    );
    expect(result.isRight(), isTrue);
    return (await database.select(database.orderEntries).get()).single.id;
  }

  /// Recorre la cadena hasta `listo`, que es donde el detalle empieza a ofrecer
  /// dinero: cobrar y entregar no salen mientras la ropa esté en la lavadora
  /// (§5.4). Caja sí entrega desde cualquier estado, y eso se prueba allá.
  Future<void> markReady(String id) async {
    for (final status in const [OrderStatus.inProgress, OrderStatus.ready]) {
      final order = (await orders.detail(id))!;
      expect((await orders.changeStatus(order, status)).isRight(), isTrue);
    }
  }

  /// Un acta que cierra [date], como la que baja del feed cuando alguien cerró
  /// el día desde otro dispositivo.
  Future<void> seedClosure(String date) async {
    await database
        .into(database.dailyClosureEntries)
        .insert(
          DailyClosureEntriesCompanion.insert(
            id: 'acta-$date',
            closeDate: date,
            ordersIncome: '0.00',
            suppliesIncome: '0.00',
            expensesTotal: '0.00',
            netTotal: '0.00',
            cashIncome: '0.00',
            transferIncome: '0.00',
            cashExpenses: '0.00',
            transferExpenses: '0.00',
            closedById: 'u1',
            closedAt: DateTime.now(),
          ),
        );
  }

  /// El catálogo en la BD local, que es de donde lo lee la pantalla de captura
  /// cuando se reabre una boleta para corregirla.
  Future<void> seedCatalog() async {
    await database
        .into(database.serviceTypeEntries)
        .insert(
          ServiceTypeEntriesCompanion.insert(
            id: 'st-tub',
            code: 'wash_tub',
            name: 'Lavado por tina',
            pricingMode: 'tiered',
          ),
        );
    await database
        .into(database.serviceOptionEntries)
        .insert(
          ServiceOptionEntriesCompanion.insert(
            id: 'so-tub-g',
            serviceTypeId: 'st-tub',
            code: 'G',
            name: 'Tina grande',
          ),
        );
    await database
        .into(database.servicePriceEntries)
        .insert(
          ServicePriceEntriesCompanion.insert(
            id: 'sp-tub-g',
            serviceTypeId: 'st-tub',
            serviceOptionId: const Value('so-tub-g'),
            price: '30.00',
            validFrom: '2020-01-01',
          ),
        );
    // Un segundo servicio, suelto y por unidad: es el que se le suma a una
    // boleta que ya está en el taller ("y además un secado").
    await database
        .into(database.serviceTypeEntries)
        .insert(
          ServiceTypeEntriesCompanion.insert(
            id: 'st-dry',
            code: 'dry',
            name: 'Secado',
            pricingMode: 'per_unit',
            sortOrder: const Value(1),
          ),
        );
    await database
        .into(database.servicePriceEntries)
        .insert(
          ServicePriceEntriesCompanion.insert(
            id: 'sp-dry',
            serviceTypeId: 'st-dry',
            price: '20.00',
            validFrom: '2020-01-01',
          ),
        );
  }

  /// Toca el `+` de la fila que contiene [label], igual que en la toma de pedido:
  /// el stepper es hermano del nombre.
  Future<void> addOne(WidgetTester tester, String label) async {
    final row = find.ancestor(of: find.text(label), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.add_rounded)));
    await tester.pumpAndSettle();
  }

  Future<void> openOrders(
    WidgetTester tester, {
    List<String> permissions = const [AppPermissions.all],
    Size size = const Size(400, 2200),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
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
          ordersRepositoryProvider.overrideWithValue(orders),
        ],
        child: const LaValienteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();
  }

  group('lista', () {
    orderTest('muestra el pedido con folio provisional, estado y saldo', (tester) async {
      await seedOrder(advance: const PaymentDraft(amount: 1000));
      await openOrders(tester);

      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('P-1'), findsOneWidget);
      expect(find.text('Recibido'), findsWidgets);
      expect(find.text('Debe Q20.00'), findsOneWidget);
      expect(find.text('1 pedido'), findsOneWidget);
      expect(find.text('Total listado'), findsOneWidget);
    });

    orderTest('el filtro de estado dice cuándo no hay nada', (tester) async {
      await seedOrder();
      await openOrders(tester);

      // Los chips viven en una lista horizontal; se toca uno de los primeros
      // para no depender de cuántos caben en el ancho de la prueba.
      await tester.tap(find.text('En proceso').first);
      await tester.pumpAndSettle();

      expect(find.text('Ana Pérez'), findsNothing);
      expect(find.text('Ningún pedido en proceso este día'), findsOneWidget);
    });

    orderTest('un día sin pedidos ofrece capturar el primero', (tester) async {
      await openOrders(tester);

      expect(find.text('Sin pedidos este día'), findsOneWidget);
    });
  });

  group('detalle', () {
    orderTest('avanza el estado y lo confirma', (tester) async {
      await seedOrder();
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.text('P-1'), findsOneWidget);
      expect(find.text('Camisa'), findsOneWidget);
      // En la tarjeta de pagos y otra vez en la barra de abajo, que es donde se
      // lee justo antes de tocar el botón.
      expect(find.text('Saldo pendiente'), findsNWidgets(2));

      await tester.tap(find.text('Pasar a proceso'));
      await tester.pumpAndSettle();

      expect(find.text('En proceso'), findsWidgets);
      // Listo todavía no: la cadena no se salta, y por eso ahora aparece el
      // paso siguiente y el de volver atrás.
      expect(find.text('Marcar listo'), findsOneWidget);
      expect(find.text('Regresar a recibido'), findsOneWidget);
    });

    orderTest('el avance se ve en los cuatro pasos', (tester) async {
      final id = await seedOrder();
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderProgress), findsOneWidget);

      // Anulado se sale de la cadena, así que no hay avance que dibujar.
      await orders.cancel(
        (await orders.detail(id))!,
        reason: 'boleta duplicada',
        actorId: 'u1',
      );
      await tester.pumpAndSettle();

      expect(find.byType(OrderProgress), findsNothing);
      expect(find.text('Pedido anulado'), findsOneWidget);
      expect(find.text('Motivo: boleta duplicada'), findsOneWidget);
    });

    orderTest('la cadena se recorre de un paso a la vez', (tester) async {
      // Lo que la pantalla ofrece es **el siguiente paso**, no los cuatro: en
      // `recibido` no se cobra ni se entrega, porque la ropa está en la lavadora.
      final id = await seedOrder();
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.text('Pasar a proceso'), findsOneWidget);
      expect(find.text('Cobrar'), findsNothing);
      expect(find.text('Entregar pedido'), findsNothing);

      await tester.tap(find.text('Pasar a proceso'));
      await tester.pumpAndSettle();
      // El aviso de que se avanzó vive abajo, sobre la barra de acciones: hay
      // que dejarlo irse antes de tocar el paso siguiente.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Marcar listo'), findsOneWidget);
      expect(find.text('Cobrar'), findsNothing);
      expect(find.text('Entregar pedido'), findsNothing);

      await tester.tap(find.text('Marcar listo'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Con la ropa lista sí: primero cobrar, después entregar.
      expect(find.text('Cobrar'), findsOneWidget);
      expect(find.text('Entregar pedido'), findsOneWidget);
      expect(find.text('Marcar listo'), findsNothing);
      expect((await orders.detail(id))!.status, OrderStatus.ready);
    });

    orderTest('registrar un pago baja el saldo en la misma pantalla', (tester) async {
      final id = await seedOrder();
      await markReady(id);
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cobrar'));
      await tester.pumpAndSettle();

      // El monto arranca en el saldo entero.
      expect(find.text('Saldo actual Q30.00'), findsOneWidget);
      expect(find.text('Queda saldado'), findsOneWidget);

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Pagado por completo'), findsNWidgets(2));
      // Sin saldo ya no se ofrece cobrar de nuevo.
      expect(find.text('Cobrar'), findsNothing);
    });

    orderTest('cobrar de más se rechaza antes de mandarlo', (tester) async {
      final id = await seedOrder();
      await markReady(id);
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cobrar'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.ancestor(
            of: find.text('MONTO'),
            matching: find.byType(AppFormField),
          ),
          matching: find.byType(TextField),
        ),
        '100',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('No se puede cobrar más que el saldo'), findsOneWidget);
    });

    orderTest('anular exige el motivo y lo deja escrito', (tester) async {
      await seedOrder();
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anular'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anular pedido'));
      await tester.pumpAndSettle();
      expect(find.text('Escribí por qué se anula'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.ancestor(
            of: find.text('MOTIVO'),
            matching: find.byType(AppFormField),
          ),
          matching: find.byType(TextField),
        ),
        'El cliente se arrepintió',
      );
      await tester.tap(find.text('Anular pedido'));
      await tester.pumpAndSettle();

      expect(find.text('Motivo: El cliente se arrepintió'), findsOneWidget);
      expect(find.text('Anular'), findsNothing);
    });

    orderTest('sin permiso de anular, la acción no está', (tester) async {
      await seedOrder();
      await openOrders(
        tester,
        permissions: const [
          AppPermissions.ordersRead,
          AppPermissions.ordersUpdate,
          AppPermissions.customersRead,
        ],
      );

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.text('Pasar a proceso'), findsOneWidget);
      expect(find.text('Anular'), findsNothing);
      expect(find.text('Cobrar'), findsNothing);
    });

    /// El detalle es la pantalla más cargada de la app y las otras pruebas la
    /// miran en una ventana de 2200 px de alto, donde nada se aprieta. Esta la
    /// abre en un teléfono de verdad y con la boleta llena —boleta, peso, tres
    /// tipos de prenda, observaciones, anticipo— porque los desbordes salen
    /// cuando el contenido compite por el ancho, no cuando sobra sitio.
    orderTest('entra en un teléfono con la boleta llena', (tester) async {
      await seedOrder(crowded: true, advance: const PaymentDraft(amount: 1000));
      await openOrders(tester, size: const Size(390, 844));

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('10432'), findsOneWidget);
      expect(find.text('22.50 lbs'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('5555-1234 · NIT 1234567-8'), findsOneWidget);
      expect(find.text('Pantalón de vestir'), findsOneWidget);
    });

    orderTest('con el día cerrado se bloquea el dinero, no el trabajo', (tester) async {
      await seedCatalog();
      await seedOrder();
      await seedClosure(isoDate(businessDate()));
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.text('Día cerrado · este pedido ya no se puede editar'), findsOneWidget);
      // Corregir, anular y cobrar tocan la hoja del día, así que se van.
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Anular'), findsNothing);
      expect(find.text('Cobrar'), findsNothing);
      // Mover la ropa por el taller no mueve dinero de ningún día, y el
      // servidor tampoco lo bloquea: el botón sigue.
      expect(find.text('Pasar a proceso'), findsOneWidget);
    });
  });

  group('entrega', () {
    orderTest('concilia las prendas y deja constancia de lo que faltó', (tester) async {
      final id = await seedOrder(advance: const PaymentDraft(amount: 3000));
      await openOrders(tester);

      // Se recorre la cadena: en esta pantalla entregar espera a que la ropa
      // esté lista. La entrega sin recorrerla es la de Caja (plan 0001 D13).
      await markReady(id);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entregar pedido'));
      await tester.pumpAndSettle();

      expect(find.text('Se recibieron 3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove_rounded).last);
      await tester.pumpAndSettle();
      expect(find.text('Se recibieron 3; faltan 1'), findsOneWidget);

      await tester.tap(find.text('Confirmar entrega'));
      await tester.pumpAndSettle();

      final delivered = (await orders.detail(id))!;
      expect(delivered.status, OrderStatus.delivered);
      expect(delivered.garments.single.quantityDelivered, 2);
    });
  });

  group('corregir', () {
    orderTest('Editar reabre la boleta precargada', (tester) async {
      await seedCatalog();
      await seedOrder();
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      // Misma pantalla de la toma, pero diciendo qué está haciendo.
      expect(find.text('Corregir boleta'), findsOneWidget);
      expect(find.textContaining('el No. y la fecha no cambian'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
      // Y con lo que la boleta ya decía: el contador de la sección 3 y la
      // pastilla del footer.
      expect(find.text('Ana Pérez'), findsWidgets);
      expect(find.text('3 pzas'), findsNWidgets(2));
    });

    orderTest('corregir reemplaza las líneas y vuelve al detalle', (tester) async {
      await seedCatalog();
      final id = await seedOrder();
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      // Una camisa más.
      final row = find.ancestor(of: find.text('Camisa'), matching: find.byType(Row)).first;
      await tester.tap(find.descendant(of: row, matching: find.byIcon(Icons.add_rounded)));
      await tester.pumpAndSettle();
      expect(find.text('4 pzas'), findsNWidgets(2));

      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      // De vuelta en el detalle, con lo corregido.
      expect(find.text('Pedido corregido'), findsOneWidget);
      final order = await orders.detail(id);
      expect(order!.totalPieces, 4);
      expect(order.garments.single.quantity, 4);
    });

    orderTest('un pedido entregado ya no ofrece corregirse', (tester) async {
      await seedCatalog();
      final id = await seedOrder(advance: const PaymentDraft(amount: 3000));
      final order = (await orders.detail(id))!;
      await orders.changeStatus(order, OrderStatus.inProgress);
      await orders.changeStatus((await orders.detail(id))!, OrderStatus.ready);
      await orders.deliver(
        (await orders.detail(id))!,
        delivered: const {},
        actorId: 'u1',
      );

      await openOrders(tester);
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsNothing);
    });

    orderTest('un pedido en proceso suma un secado desde el catálogo', (tester) async {
      // El caso del cliente: la ropa ya entró y alguien decide que además va un
      // secado. Se abre la lista del catálogo, no la boleta entera.
      await seedCatalog();
      final id = await seedOrder();
      await orders.changeStatus((await orders.detail(id))!, OrderStatus.inProgress);
      await openOrders(tester);

      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agregar servicios'));
      await tester.pumpAndSettle();

      // Lo que ya lleva sale marcado: la tina que se cobró al capturarla.
      expect(find.text('1 × Q30.00 = Q30.00'), findsOneWidget);

      await addOne(tester, 'Secado');
      expect(find.text('1 × Q20.00 = Q20.00'), findsOneWidget);

      await tester.tap(find.text('Guardar servicios'));
      await tester.pumpAndSettle();

      final order = (await orders.detail(id))!;
      expect(order.charges.length, 2);
      expect(order.total, 5000);
      // Y no perdió nada de la boleta por el camino.
      expect(order.garments.single.quantity, 3);
      expect(order.status, OrderStatus.inProgress);
    });

    orderTest('sin el permiso de admin, un pedido listo no se edita', (tester) async {
      await seedCatalog();
      final id = await seedOrder();
      await orders.changeStatus((await orders.detail(id))!, OrderStatus.inProgress);
      await orders.changeStatus((await orders.detail(id))!, OrderStatus.ready);

      await openOrders(
        tester,
        permissions: const [
          AppPermissions.ordersRead,
          AppPermissions.ordersUpdate,
          AppPermissions.customersRead,
        ],
      );
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      // Ya está contado, lavado y doblado: corregirlo es decisión de un admin.
      expect(find.text('Editar'), findsNothing);
    });
  });
}
