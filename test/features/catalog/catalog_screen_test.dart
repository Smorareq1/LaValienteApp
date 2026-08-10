import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/catalog/data/catalog_remote_datasource.dart';
import 'package:la_valiente/features/catalog/models/catalog.dart';
import 'package:la_valiente/features/catalog/models/catalog_admin.dart';
import 'package:la_valiente/features/catalog/ui/catalog_screen.dart';
import 'package:la_valiente/features/catalog/ui/service_detail_screen.dart';

/// El servidor de catálogo, de mentira. La administración va en línea, así que
/// lo que hay que fingir es la red.
class _FakeRemote implements CatalogRemoteDataSource {
  _FakeRemote({
    this.serviceRows = const [],
    this.garmentRows = const [],
    this.priceRows = const [],
  });

  List<AdminService> serviceRows;
  List<AdminGarment> garmentRows;
  List<AdminPrice> priceRows;

  bool fails = false;

  @override
  Future<List<AdminService>> services() async {
    if (fails) throw Exception('sin red');
    return serviceRows;
  }

  @override
  Future<AdminService> service(String id) async =>
      serviceRows.firstWhere((each) => each.id == id);

  @override
  Future<List<AdminPrice>> prices(String serviceId) async => priceRows;

  @override
  Future<List<AdminGarment>> garments() async {
    if (fails) throw Exception('sin red');
    return garmentRows;
  }

  @override
  Future<AdminService> createService(NewService input) async =>
      throw UnimplementedError();

  @override
  Future<AdminService> updateService(
    String id, {
    required String name,
    String? unitLabel,
    required bool isActive,
  }) async => throw UnimplementedError();

  @override
  Future<AdminPrice> registerPrice(
    String serviceId, {
    required int amount,
    required String validFrom,
    String? optionId,
  }) async => throw UnimplementedError();

  @override
  Future<AdminGarment> createGarment({
    required String name,
    String? notes,
    int sortOrder = 0,
  }) async => throw UnimplementedError();

  @override
  Future<AdminGarment> updateGarment(
    String id, {
    required String name,
    String? notes,
    int? sortOrder,
    required bool isActive,
  }) async => throw UnimplementedError();
}

AdminService _service({
  String id = 'svc-1',
  String name = 'Lavado por libra',
  PricingMode mode = PricingMode.perUnit,
  String? unitLabel = 'libra',
  int? price = 1250,
  bool active = true,
  List<AdminServiceOption> options = const [],
}) {
  return AdminService(
    id: id,
    code: id,
    name: name,
    pricingMode: mode,
    isActive: active,
    sortOrder: 0,
    version: 1,
    options: options,
    unitLabel: unitLabel,
    currentPrice: price,
  );
}

Future<void> _pump(WidgetTester tester, _FakeRemote remote, Widget screen) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [catalogRemoteDataSourceProvider.overrideWithValue(remote)],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('la lista', () {
    testWidgets('un servicio por unidad dice su unidad y su precio', (tester) async {
      final remote = _FakeRemote(serviceRows: [_service()]);
      await _pump(tester, remote, const CatalogScreen());

      expect(find.text('Lavado por libra'), findsOneWidget);
      expect(find.text('Precio por libra'), findsOneWidget);
      expect(find.text('Q12.50'), findsOneWidget);
    });

    testWidgets('un servicio variable no promete un precio que no existe', (
      tester,
    ) async {
      // El precio lo teclea quien captura: enseñar uno aquí sería mentir.
      final remote = _FakeRemote(
        serviceRows: [
          _service(
            id: 'svc-2',
            name: 'Mensajería',
            mode: PricingMode.variable,
            unitLabel: null,
            price: null,
          ),
        ],
      );
      await _pump(tester, remote, const CatalogScreen());

      expect(find.text('Precio que se teclea al capturar'), findsOneWidget);
    });

    testWidgets('sin red se dice y se ofrece reintentar', (tester) async {
      final remote = _FakeRemote()..fails = true;
      await _pump(tester, remote, const CatalogScreen());

      expect(find.text('No se pudo leer el catálogo'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('las prendas viven en su propia pestaña', (tester) async {
      final remote = _FakeRemote(
        garmentRows: [
          const AdminGarment(
            id: 'g1',
            name: 'Camisa',
            isActive: true,
            sortOrder: 1,
            version: 1,
          ),
        ],
      );
      await _pump(tester, remote, const CatalogScreen());

      expect(find.text('Camisa'), findsNothing);
      await tester.tap(find.text('Prendas'));
      await tester.pumpAndSettle();
      expect(find.text('Camisa'), findsOneWidget);
    });
  });

  group('el detalle', () {
    testWidgets('el historial distingue la ventana vigente de las cerradas', (
      tester,
    ) async {
      final remote = _FakeRemote(
        serviceRows: [_service()],
        priceRows: const [
          AdminPrice(id: 'p2', amount: 1250, validFrom: '2026-06-01'),
          AdminPrice(
            id: 'p1',
            amount: 1000,
            validFrom: '2026-01-01',
            validTo: '2026-05-31',
          ),
        ],
      );
      await _pump(tester, remote, const ServiceDetailScreen(serviceId: 'svc-1'));

      expect(find.text('Vigente'), findsOneWidget);
      expect(find.text('Del 2026-01-01 al 2026-05-31'), findsOneWidget);
    });

    testWidgets('dice que los pedidos ya tomados no cambian', (tester) async {
      // Es la pregunta que hace cualquiera antes de subir un precio, y se
      // contesta donde se hace.
      final remote = _FakeRemote(serviceRows: [_service()]);
      await _pump(tester, remote, const ServiceDetailScreen(serviceId: 'svc-1'));

      expect(
        find.textContaining('Los pedidos ya tomados no cambian'),
        findsOneWidget,
      );
    });

    testWidgets('un servicio variable no ofrece registrar precios', (tester) async {
      final remote = _FakeRemote(
        serviceRows: [
          _service(
            id: 'svc-1',
            name: 'Mensajería',
            mode: PricingMode.variable,
            unitLabel: null,
            price: null,
          ),
        ],
      );
      await _pump(tester, remote, const ServiceDetailScreen(serviceId: 'svc-1'));

      expect(find.text('Nuevo precio'), findsNothing);
      expect(
        find.textContaining('no tiene precio que administrar'),
        findsOneWidget,
      );
    });

    testWidgets('cada opción de un servicio por tramos lleva su precio', (
      tester,
    ) async {
      final remote = _FakeRemote(
        serviceRows: [
          _service(
            mode: PricingMode.tiered,
            unitLabel: null,
            price: null,
            options: const [
              AdminServiceOption(
                id: 'o1',
                code: 'S',
                name: 'Tina pequeña',
                isActive: true,
                sortOrder: 0,
                version: 1,
                minQuantity: 1,
                maxQuantity: 5,
                currentPrice: 3500,
              ),
            ],
          ),
        ],
      );
      await _pump(tester, remote, const ServiceDetailScreen(serviceId: 'svc-1'));

      expect(find.text('Tina pequeña'), findsOneWidget);
      expect(find.text('de 1 a 5'), findsOneWidget);
      expect(find.text('Q35.00'), findsOneWidget);
    });
  });
}
