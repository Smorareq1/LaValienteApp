import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/core/time/business_date.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/catalog/data/catalog_mirrors.dart';
import 'package:la_valiente/features/customers/data/customers_local_datasource.dart';
import 'package:la_valiente/features/customers/data/customers_repository.dart';
import 'package:la_valiente/features/customers/models/customer.dart';
import 'package:la_valiente/features/orders/data/orders_local_datasource.dart';
import 'package:la_valiente/features/orders/data/orders_repository.dart';
import 'package:la_valiente/features/orders/state/order_capture_controller.dart';
import 'package:la_valiente/features/orders/ui/order_capture_screen.dart';
import 'package:la_valiente/features/scan/models/scan.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';

/// Donde el escaneo se convierte en boleta (Plan 0003 §4).
///
/// Es el punto que de verdad importa del módulo: lo que una máquina leyó tiene
/// que caer en los mismos campos que llenaría una persona, contra el **catálogo
/// local**, y sin decidir nada por su cuenta.
class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => const AuthUser(
    id: 'u1',
    username: 'mostrador',
    roles: ['admin'],
    permissions: ['*.*'],
  );
}

SyncChange _change(String entity, String id, Map<String, dynamic> data) =>
    SyncChange(entity: entity, id: id, version: 1, syncSeq: 1, deleted: false, data: data);

Map<String, dynamic> _field(Object? value, {bool needsReview = false}) => {
  'value': value,
  'confidence': needsReview ? 0.6 : 0.95,
  'raw_text': null,
  'needs_review': needsReview,
};

Map<String, dynamic> _charge(
  String code, {
  String? option,
  String quantity = '1',
  String? amount,
  bool needsReview = false,
}) => {
  'service_code': code,
  'option_code': option,
  'quantity': quantity,
  'amount': amount,
  'description': code,
  'confidence': needsReview ? 0.6 : 0.95,
  'needs_review': needsReview,
};

ScanResult _scan({
  List<Map<String, dynamic>> charges = const [],
  List<Map<String, dynamic>> garments = const [],
  Map<String, dynamic>? overrides,
}) {
  return ScanResult.fromJson({
    'id': 'scan-1',
    'status': 'completed',
    'warnings': <String>[],
    'draft': {
      'booklet_serial': _field('A-4410'),
      'nit': _field('CF'),
      'weight_lbs': _field('12.50'),
      'observations': _field('Entró 6:50'),
      'customer_name': _field('María López'),
      'garments': garments,
      'charges': charges,
      'estimated_subtotal': '30.00',
      'estimated_total': '30.00',
      'total_read': '30.00',
      ...?overrides,
    },
  });
}

void main() {
  late AppDatabase database;
  late CustomersRepository customers;
  late OrdersRepository orders;
  var closed = false;
  var ids = 0;

  /// Misma receta que las otras pruebas con BD: desmontar el árbol y dejar
  /// correr el temporizador que drift agenda al cancelar un stream.
  void prefillTest(String description, Future<void> Function(WidgetTester) body) {
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
    final sync = SyncRepository(
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

  Future<void> seedCatalog() async {
    await ServiceTypeMirror(database).apply(
      _change('service_type', 'st-weight', {
        'code': 'wash_by_weight',
        'name': 'Lavado por peso',
        'pricing_mode': 'per_unit',
        'unit_label': 'lb',
        'is_active': true,
        'sort_order': 0,
      }),
    );
    await ServicePriceMirror(database).apply(
      _change('service_price', 'sp-weight', {
        'service_type_id': 'st-weight',
        'service_option_id': null,
        'price': '2.50',
        'valid_from': '2020-01-01',
        'valid_to': null,
      }),
    );
    await ServiceTypeMirror(database).apply(
      _change('service_type', 'st-tub', {
        'code': 'wash_tub',
        'name': 'Lavado por tina',
        'pricing_mode': 'tiered',
        'unit_label': 'tina',
        'is_active': true,
        'sort_order': 1,
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
  }

  Future<ProviderContainer> open(
    WidgetTester tester,
    ScanResult? scan, {
    Customer? scanCustomer,
  }) async {
    tester.view.physicalSize = const Size(400, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        authControllerProvider.overrideWith(_FakeAuthController.new),
        customersRepositoryProvider.overrideWithValue(customers),
        ordersRepositoryProvider.overrideWithValue(orders),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: OrderCaptureScreen(scan: scan, scanCustomer: scanCustomer),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  prefillTest('el encabezado llega lleno y avisa de que lo leyó una máquina', (
    tester,
  ) async {
    await seedCatalog();
    final container = await open(tester, _scan());

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.bookletSerial, 'A-4410');
    expect(state.nit, 'CF');
    expect(state.observations, 'Entró 6:50');
    expect(state.isFromScan, isTrue);
    // El aviso no es decorativo: la diferencia entre revisar y confiar es lo que
    // separa esto de un módulo que guarda pedidos equivocados.
    expect(find.textContaining('Boleta escaneada'), findsOneWidget);
  });

  prefillTest('el lavado por peso llena el peso del encabezado', (tester) async {
    // Son el mismo número escrito una sola vez (§3.1): la línea lo trae y el
    // campo de peso lo recibe, o el motor rechazaría la boleta por descuadre.
    await seedCatalog();
    final container = await open(
      tester,
      _scan(charges: [_charge('wash_by_weight', quantity: '12.5')]),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.washByWeight, isTrue);
    expect(state.weightText, '12.50');
  });

  prefillTest('una opción escalonada cae en su propio stepper', (tester) async {
    await seedCatalog();
    final container = await open(
      tester,
      _scan(charges: [_charge('wash_tub', option: 'G', quantity: '2')]),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.serviceQuantities[serviceKey('wash_tub', 'G')], 2);
  });

  prefillTest('un servicio que este dispositivo no conoce se ignora', (
    tester,
  ) async {
    // El catálogo local manda: prellenar un código que la boleta no puede
    // cobrar solo produciría un error al guardar.
    await seedCatalog();
    final container = await open(
      tester,
      _scan(charges: [_charge('servicio_inventado', quantity: '1')]),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.serviceQuantities, isEmpty);
  });

  prefillTest('una prenda que no está en el catálogo local tampoco entra', (
    tester,
  ) async {
    await seedCatalog();
    final container = await open(
      tester,
      _scan(
        garments: [
          {
            'garment_type_id': 'gt-camisa',
            'name': 'Camisa',
            'quantity': 3,
            'confidence': 0.9,
            'needs_review': false,
          },
          {
            'garment_type_id': 'gt-fantasma',
            'name': 'Sombrero',
            'quantity': 1,
            'confidence': 0.9,
            'needs_review': false,
          },
        ],
      ),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.garmentQuantities, {'gt-camisa': 3});
    expect(state.totalPieces, 3);
  });

  prefillTest('el cliente NO se elige solo', (tester) async {
    // §7.5: la sugerencia se confirma a mano. Aceptarla sola archivaría la ropa
    // de alguien bajo el nombre de otro, y le entregaría su historial.
    await seedCatalog();
    final container = await open(
      tester,
      _scan(
        overrides: {
          'customer_match': {
            'customer_id': 'c1',
            'full_name': 'María López',
            'phone': '55123456',
            'score': 1.0,
            'matched_on': 'phone',
          },
        },
      ),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.customer, isNull);
    expect(state.blockers.first, contains('el cliente'));
  });

  prefillTest('el id del escaneo viaja con la boleta', (tester) async {
    // Sin él el servidor no puede guardar el diff de D7, que es la única medida
    // de calidad tomada sobre boletas reales.
    await seedCatalog();
    final container = await open(
      tester,
      _scan(charges: [_charge('wash_tub', option: 'G', quantity: '1')]),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.scanId, 'scan-1');
  });

  prefillTest('una boleta en blanco ofrece escanear y no dice nada de scans', (
    tester,
  ) async {
    await seedCatalog();
    await open(tester, null);

    expect(find.text('Escanear'), findsOneWidget);
    expect(find.textContaining('Boleta escaneada'), findsNothing);
  });

  prefillTest('la fecha de la boleta manda sobre la de hoy', (tester) async {
    // Una boleta atrasada se cobra con los precios que regían ese día (D1), así
    // que la fecha leída tiene que llegar **antes** de que se calcule nada.
    await seedCatalog();
    final container = await open(
      tester,
      _scan(overrides: {'order_date': _field('2026-07-30')}),
    );

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(isoDate(state.orderDate), '2026-07-30');
  });

  prefillTest('el cliente confirmado en el escaneo abre la boleta a su nombre', (
    tester,
  ) async {
    await seedCatalog();
    const confirmed = Customer(
      id: 'cust-1',
      fullName: 'María López',
      version: 1,
      syncStatus: RowSyncStatus.synced,
      nit: '1234567-8',
    );

    final container = await open(tester, _scan(), scanCustomer: confirmed);

    final state = container.read(orderCaptureControllerProvider(null)).value!;
    expect(state.customer?.id, 'cust-1');
    // El NIT del cliente registrado gana al leído de la foto: es con el que se
    // le factura.
    expect(state.nit, '1234567-8');
  });
}
