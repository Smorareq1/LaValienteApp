import 'package:design_system/design_system.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/app.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/catalog/data/catalog_mirrors.dart';
import 'package:la_valiente/features/customers/data/customers_local_datasource.dart';
import 'package:la_valiente/features/customers/data/customers_repository.dart';
import 'package:la_valiente/features/orders/data/orders_local_datasource.dart';
import 'package:la_valiente/features/orders/data/orders_repository.dart';
import 'package:la_valiente/features/orders/ui/widgets/order_saved_sheet.dart';
import 'package:la_valiente/features/promotions/data/promotion_mirror.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';
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

SyncChange _change(String entity, String id, Map<String, dynamic> data) {
  return SyncChange(entity: entity, id: id, version: 1, syncSeq: 1, deleted: false, data: data);
}

void main() {
  late AppDatabase database;
  late CustomersRepository customers;
  late OrdersRepository orders;
  late SyncLocalDataSource syncLocal;
  var closed = false;
  var ids = 0;

  /// Misma receta que en Clientes: desmontar el árbol y dejar correr el
  /// temporizador que drift agenda al cancelar un stream, antes de cerrar la BD.
  void captureTest(String description, Future<void> Function(WidgetTester) body) {
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
    syncLocal = SyncLocalDataSource(database);
    final sync = SyncRepository(
      local: syncLocal,
      remote: _UnusedServer(),
      storage: _UnusedStorage(),
      mirrors: const {},
      device: const DeviceDescriptor(
        name: 'Tablet',
        platform: 'android',
        appVersion: '1.0.0',
      ),
      uuid: () => 'op-${++ids}',
    );
    customers = CustomersRepository(
      database: database,
      local: CustomersLocalDataSource(database),
      sync: sync,
      uuid: () => 'cliente-${++ids}',
    );
    orders = OrdersRepository(
      database: database,
      local: OrdersLocalDataSource(database),
      sync: sync,
      uuid: () => 'id-${++ids}',
    );
  });

  tearDown(() async {
    if (!closed) await database.close();
  });

  /// Siembra el catálogo tal como llegaría del feed: una tina escalonada y un
  /// par de tipos de prenda alcanzan para armar una boleta completa.
  Future<void> seedCatalog() async {
    await ServiceTypeMirror(database).apply(
      _change('service_type', 'st-tub', {
        'code': 'wash_tub',
        'name': 'Lavado por tina',
        'pricing_mode': 'tiered',
        'unit_label': 'tina',
        'is_active': true,
        'sort_order': 0,
      }),
    );
    await ServiceOptionMirror(database).apply(
      _change('service_option', 'so-tub-g', {
        'service_type_id': 'st-tub',
        'code': 'G',
        'name': 'Tina grande',
        'min_quantity': null,
        'max_quantity': null,
        'is_active': true,
        'sort_order': 0,
      }),
    );
    await ServicePriceMirror(database).apply(
      _change('service_price', 'sp-tub-g', {
        'service_type_id': 'st-tub',
        'service_option_id': 'so-tub-g',
        'price': '30.00',
        'valid_from': '2020-01-01',
        'valid_to': null,
      }),
    );
    await GarmentTypeMirror(database).apply(
      _change('garment_type', 'gt-camisa', {
        'name': 'Camisa',
        'notes': null,
        'is_active': true,
        'sort_order': 0,
      }),
    );
    await GarmentTypeMirror(database).apply(
      _change('garment_type', 'gt-toalla', {
        'name': 'Toalla grande',
        'notes': null,
        'is_active': true,
        'sort_order': 1,
      }),
    );
  }

  /// Una promoción tal como bajaría del feed: pull-only, como el catálogo.
  Future<void> seedPromotion({
    String code = 'tina_50',
    String name = '50% en tinas',
    String type = 'percentage',
    String value = '50',
    List<String>? services = const ['wash_tub'],
    String from = '2020-01-01',
    String? to,
    bool active = true,
  }) async {
    await PromotionMirror(database).apply(
      _change('promotion', 'promo-$code', {
        'code': code,
        'name': name,
        'description': null,
        'discount_type': type,
        'value': value,
        'applies_to_service_codes': services,
        'valid_from': from,
        'valid_to': to,
        'is_active': active,
      }),
    );
  }

  /// Monta la app real y entra a la toma de pedido desde Inicio.
  Future<void> openCapture(
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
          customersRepositoryProvider.overrideWithValue(customers),
          ordersRepositoryProvider.overrideWithValue(orders),
        ],
        child: const LaValienteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo pedido'));
    await tester.pumpAndSettle();
  }

  Future<void> pickCustomer(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  /// Toca el `+` de la fila que contiene [label]: el stepper es hermano del
  /// nombre, así que se busca dentro de la fila que los contiene a los dos.
  Future<void> addOne(WidgetTester tester, String label) async {
    final row = find.ancestor(of: find.text(label), matching: find.byType(Row)).first;
    await tester.tap(
      find.descendant(of: row, matching: find.byIcon(Icons.add_rounded)),
    );
    await tester.pumpAndSettle();
  }

  /// Abre la sección 6, que arranca plegada como el resto de las opcionales.
  Future<void> openDiscounts(WidgetTester tester) async {
    await tester.tap(find.text('Descuentos'));
    await tester.pumpAndSettle();
  }

  captureTest('abre con las siete secciones de la boleta', (tester) async {
    await seedCatalog();
    await openCapture(tester);

    for (final title in const [
      'Encabezado',
      'Cliente',
      'Prendas',
      'Observaciones',
      'Servicios',
      'Descuentos',
      'Pago inicial',
    ]) {
      expect(find.text(title), findsOneWidget, reason: 'falta la sección $title');
    }
  });

  captureTest('sin nada capturado dice qué falta y no deja guardar', (tester) async {
    await seedCatalog();
    await openCapture(tester);

    expect(find.text('Falta el cliente, las prendas y un cargo para guardar.'), findsOneWidget);
    expect(find.text('Sin cliente seleccionado'), findsOneWidget);
    expect(find.text('Ninguna prenda agregada'), findsOneWidget);
  });

  captureTest('el descuento manual solo aparece con su permiso, la promoción no', (
    tester,
  ) async {
    await seedCatalog();
    await seedPromotion();
    await openCapture(
      tester,
      permissions: const [
        AppPermissions.ordersRead,
        AppPermissions.ordersCreate,
        AppPermissions.customersRead,
      ],
    );

    // La sección sigue ahí y ofrece la promoción: elegir una vigente es trabajo
    // de mostrador. Lo que desaparece es el monto a mano.
    expect(find.text('Descuentos'), findsOneWidget);
    await openDiscounts(tester);
    expect(find.text('50% en tinas'), findsOneWidget);
    expect(find.text('DESCUENTO MANUAL'), findsNothing);
  });

  captureTest('con permiso de descuento manual aparecen las dos formas', (tester) async {
    await seedCatalog();
    await seedPromotion();
    await openCapture(tester);
    await openDiscounts(tester);

    expect(find.text('50% en tinas'), findsOneWidget);
    expect(find.text('DESCUENTO MANUAL'), findsOneWidget);
  });

  captureTest('el chip de promoción rebaja el total al marcarlo', (tester) async {
    await seedCatalog();
    await seedPromotion();
    await openCapture(tester);

    await addOne(tester, 'Tina grande');
    await openDiscounts(tester);
    // Antes de marcarla, el chip ya dice lo que rebajaría.
    expect(find.text('−Q15.00'), findsOneWidget);

    await tester.tap(find.text('50% en tinas'));
    await tester.pumpAndSettle();

    // El footer estrena la línea de descuento y la cabecera de la sección dice
    // de dónde salió.
    expect(find.textContaining('Desc.'), findsOneWidget);
    expect(find.textContaining('−Q15.00 · 1 promoción'), findsOneWidget);
  });

  captureTest('una promoción que no muerde nada bloquea y lo explica', (tester) async {
    await seedCatalog();
    await seedPromotion(code: 'domicilio_50', name: '50% en domicilio', services: const [
      'delivery',
    ]);
    await openCapture(tester);

    await addOne(tester, 'Tina grande');
    await openDiscounts(tester);
    await tester.tap(find.text('50% en domicilio'));
    await tester.pumpAndSettle();

    expect(
      find.text('«50% en domicilio» no rebaja nada en este pedido.'),
      findsWidgets,
    );
  });

  captureTest('sin promociones vigentes la sección lo dice', (tester) async {
    await seedCatalog();
    await openCapture(tester);
    await openDiscounts(tester);

    expect(find.text('No hay promociones vigentes para esta fecha.'), findsOneWidget);
  });

  captureTest('el total se recalcula con cada cambio y el pedido se guarda', (tester) async {
    await seedCatalog();
    await customers.create(fullName: 'Ana Pérez', phone: '5555-1234', nit: '1234567-8');

    await openCapture(tester);
    await pickCustomer(tester, 'Ana Pérez');

    await addOne(tester, 'Camisa');
    await addOne(tester, 'Camisa');
    await addOne(tester, 'Toalla grande');
    // El contador de la sección 3 y la pastilla del footer dicen lo mismo.
    expect(find.text('3 pzas'), findsNWidgets(2));

    await addOne(tester, 'Tina grande');
    // Una tina grande a Q30.00: la línea lo dice y el footer también.
    expect(find.text('1 × Q30.00 = Q30.00'), findsOneWidget);
    expect(find.text('1 cargo'), findsOneWidget);

    await addOne(tester, 'Tina grande');
    expect(find.text('2 × Q30.00 = Q60.00'), findsOneWidget);

    await tester.tap(find.text('Guardar pedido'));
    await tester.pumpAndSettle();

    // Confirmación con el folio provisional: el número de verdad lo asigna el
    // servidor y todavía no ha hablado con él.
    expect(find.text('Pedido guardado'), findsOneWidget);
    expect(find.text('FOLIO PROVISIONAL'), findsOneWidget);
    expect(find.text('P-1'), findsOneWidget);

    final saved = (await database.select(database.orderEntries).get()).single;
    expect(saved.customerId, 'cliente-1');
    expect(saved.total, '60.00');
    expect(saved.totalPieces, 3);
    expect(saved.nit, '1234567-8');

    final pending = await syncLocal.pendingOperations(limit: 10);
    // Dos operaciones: el alta del cliente y la boleta, en ese orden.
    expect(pending.map((operation) => '${operation.entity}/${operation.opType}'), [
      'customer/create',
      'order/create',
    ]);
  });

  /// En el mostrador se cobra antes de saber el trabajo: cuando la ropa entra
  /// nadie sabe todavía qué tratamientos va a necesitar, así que el cliente deja
  /// Q100 sobre una boleta que a lo mejor cierra en Q60. Bloquearlo obligaba a
  /// mentir en el monto para poder guardar.
  captureTest('un anticipo mayor que el total se guarda y queda a favor', (
    tester,
  ) async {
    await seedCatalog();
    await customers.create(fullName: 'Ana Pérez');

    await openCapture(tester);
    await pickCustomer(tester, 'Ana Pérez');
    await addOne(tester, 'Camisa');
    await addOne(tester, 'Tina grande');

    await tester.tap(find.text('Pago inicial'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(AppTextField, 'Q 0.00').last, '100');
    await tester.pumpAndSettle();

    // Ni bloquea ni se calla: dice cuánto quedó a favor y de qué se trata.
    expect(find.textContaining('Deja Q70.00 de más'), findsOneWidget);
    expect(find.textContaining('anticipo no puede ser mayor'), findsNothing);

    await tester.tap(find.text('Guardar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Pedido guardado'), findsOneWidget);
    final payment = (await database.select(database.orderPaymentEntries).get()).single;
    expect(payment.amount, '100.00');
    expect(payment.isAdvance, isTrue);
  });

  /// El campo de NIT, que vive en la sección del cliente y solo existe cuando
  /// hay uno elegido.
  Finder nitField() => find.descendant(
    of: find.byKey(const ValueKey('nit-field')),
    matching: find.byType(TextField),
  );

  String? readNit(WidgetTester tester) =>
      tester.widget<TextField>(nitField()).controller?.text;

  captureTest('el NIT sale del cliente y aparece con él', (tester) async {
    await seedCatalog();
    await customers.create(fullName: 'Ana Pérez', nit: '1234567-8');

    await openCapture(tester);
    // Sin cliente no hay NIT que enseñar: es un dato de él.
    expect(nitField(), findsNothing);

    await pickCustomer(tester, 'Ana Pérez');
    expect(readNit(tester), '1234567-8');
    // Con la sección cerrada, el resumen dice a quién y con qué NIT se factura.
    expect(find.text('Ana Pérez · NIT 1234567-8'), findsOneWidget);

    // Soltar al cliente se lleva el campo y el dato.
    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();
    expect(nitField(), findsNothing);
    expect(find.text('Sin cliente seleccionado'), findsOneWidget);
  });

  captureTest('un cliente sin NIT registrado entra como CF', (tester) async {
    // Es lo que se le factura a quien no da NIT, y es la mayoría: tenerlo que
    // teclear en cada boleta es el trabajo que esto quita.
    await seedCatalog();
    await customers.create(fullName: 'Ana Pérez');

    await openCapture(tester);
    await pickCustomer(tester, 'Ana Pérez');

    expect(readNit(tester), 'CF');
  });

  captureTest('limpiar la boleta pregunta antes de borrarla', (tester) async {
    // El botón vive al pie de la lista, donde cae el pulgar al terminar de
    // contar prendas, y lo que borra no está guardado en ninguna parte.
    await seedCatalog();
    await openCapture(tester);

    await addOne(tester, 'Camisa');
    expect(find.text('1 tipo de prenda'), findsOneWidget);

    await tester.tap(find.text('Limpiar boleta'));
    await tester.pumpAndSettle();
    expect(find.text('¿Limpiar la boleta?'), findsOneWidget);

    await tester.tap(find.text('Seguir capturando'));
    await tester.pumpAndSettle();
    expect(find.text('1 tipo de prenda'), findsOneWidget);

    await tester.tap(find.text('Limpiar boleta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpiar'));
    await tester.pumpAndSettle();

    expect(find.text('Ninguna prenda agregada'), findsOneWidget);
  });

  captureTest('la confirmación lleva lo que va en el comprobante', (tester) async {
    await seedCatalog();
    await customers.create(fullName: 'Ana Pérez', phone: '5555-1234');

    await openCapture(tester);
    await pickCustomer(tester, 'Ana Pérez');
    await addOne(tester, 'Camisa');
    await addOne(tester, 'Camisa');
    await addOne(tester, 'Toalla grande');
    await addOne(tester, 'Tina grande');

    await tester.tap(find.text('Guardar pedido'));
    await tester.pumpAndSettle();

    // Lo que se comparte con el cliente: quién es, qué dejó y a qué hora.
    final sheet = tester.widget<OrderSavedSheet>(find.byType(OrderSavedSheet));
    expect(sheet.order.customerName, 'Ana Pérez');
    expect(sheet.order.customerPhone, '5555-1234');
    expect(sheet.order.customerNit, 'CF');
    expect(sheet.order.receivedAt, isNotNull);
    expect(sheet.order.garments, const [
      (name: 'Camisa', quantity: 2),
      (name: 'Toalla grande', quantity: 1),
    ]);

    // «Listo» es el que cierra el trámite y lleva el magenta; tomar otra boleta
    // seguida es la excepción y va sin fondo.
    AppButton button(String label) => tester.widget<AppButton>(
      find.descendant(
        of: find.byType(OrderSavedSheet),
        matching: find.widgetWithText(AppButton, label),
      ),
    );
    expect(button('Listo').elevated, isTrue);
    expect(button('Listo').variant, AppButtonVariant.primary);
    expect(button('Nuevo pedido').variant, AppButtonVariant.ghost);
  });
}
