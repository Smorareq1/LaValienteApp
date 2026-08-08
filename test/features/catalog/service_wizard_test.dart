import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:la_valiente/features/catalog/data/catalog_remote_datasource.dart';
import 'package:la_valiente/features/catalog/models/catalog.dart';
import 'package:la_valiente/features/catalog/models/catalog_admin.dart';
import 'package:la_valiente/features/catalog/ui/service_wizard_screen.dart';

/// El catálogo del servidor, de mentira. Crear un servicio son **dos llamadas**
/// —el servicio y luego cada precio— y lo que este fake tiene que dejar ver es
/// justamente eso: qué se mandó, en qué orden, y qué pasa si el precio falla.
class _FakeRemote implements CatalogRemoteDataSource {
  NewService? created;
  final List<(String, int, String, String?)> registered = [];

  bool createFails = false;
  bool priceFails = false;

  @override
  Future<AdminService> createService(NewService input) async {
    if (createFails) throw Exception('sin red');
    created = input;
    return AdminService(
      id: 'svc-new',
      code: input.code,
      name: input.name,
      pricingMode: input.pricingMode,
      isActive: true,
      sortOrder: input.sortOrder,
      version: 1,
      unitLabel: input.unitLabel,
      // El servidor asigna los ids de las opciones; el asistente los usa para
      // colgar cada precio de su tramo.
      options: [
        for (final (index, option) in input.options.indexed)
          AdminServiceOption(
            id: 'opt-$index',
            code: option.code,
            name: option.name,
            isActive: true,
            sortOrder: option.sortOrder,
            version: 1,
            minQuantity: option.minQuantity,
            maxQuantity: option.maxQuantity,
          ),
      ],
    );
  }

  @override
  Future<AdminPrice> registerPrice(
    String serviceId, {
    required int amount,
    required String validFrom,
    String? optionId,
  }) async {
    if (priceFails) throw Exception('sin red');
    registered.add((serviceId, amount, validFrom, optionId));
    return AdminPrice(
      id: 'price-${registered.length}',
      amount: amount,
      validFrom: validFrom,
      serviceOptionId: optionId,
    );
  }

  @override
  Future<List<AdminService>> services() async => const [];

  @override
  Future<AdminService> service(String id) async => throw UnimplementedError();

  @override
  Future<List<AdminPrice>> prices(String serviceId) async => const [];

  @override
  Future<List<AdminGarment>> garments() async => const [];

  @override
  Future<AdminService> updateService(
    String id, {
    required String name,
    String? unitLabel,
    required bool isActive,
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

/// Con router de verdad porque al terminar el asistente **navega**: reemplaza su
/// propia ruta por la del detalle del servicio recién creado. Un `MaterialApp` a
/// secas dejaría esa mitad sin probar y reventaría al llegar ahí.
Future<void> _pump(WidgetTester tester, _FakeRemote remote) async {
  tester.view.physicalSize = const Size(400, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: ServiceWizardScreen.path,
    routes: [
      GoRoute(
        path: ServiceWizardScreen.path,
        builder: (context, state) => const ServiceWizardScreen(),
      ),
      GoRoute(
        path: '/catalog/services/:id',
        builder: (context, state) =>
            Scaffold(body: Text('detalle ${state.pathParameters['id']}')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [catalogRemoteDataSourceProvider.overrideWithValue(remote)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

/// El campo cuya etiqueta se da.
///
/// Busca por la **propiedad** `label` del `AppFormField` y no por el texto
/// pintado: un campo opcional dibuja su etiqueta como `Text.rich` —con el
/// «· opcional» dentro— y `find.text` no la ve.
Finder _field(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is AppFormField && widget.label == label,
  ),
  matching: find.byType(TextField),
);

Future<void> _fill(
  WidgetTester tester,
  String label,
  String value, {
  int at = 0,
}) async {
  await tester.enterText(_field(label).at(at), value);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('el paso 1', () {
    testWidgets('avisa de que el código y la modalidad no se cambian', (
      tester,
    ) async {
      // Es lo que decide cómo se cobra y a qué apuntan los pedidos ya tomados.
      await _pump(tester, _FakeRemote());

      expect(find.textContaining('no se cambian'), findsOneWidget);
      expect(find.text('Paso 1 de 2'), findsOneWidget);
    });

    testWidgets('un código con mayúsculas se rechaza antes de salir', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pump(tester, remote);

      await _fill(tester, 'CÓDIGO', 'Tinas Grandes');
      await _fill(tester, 'NOMBRE', 'Tinas grandes');
      await _tap(tester, 'Siguiente');

      expect(find.textContaining('Minúsculas, números y guion bajo'), findsOneWidget);
      expect(remote.created, isNull);
    });

    testWidgets('elegir tramos agrega un paso al asistente', (tester) async {
      await _pump(tester, _FakeRemote());

      expect(find.text('Paso 1 de 2'), findsOneWidget);
      await _tap(tester, 'Por tramos');
      expect(find.text('Paso 1 de 3'), findsOneWidget);
    });

    testWidgets('un servicio variable no llega a pedir precio', (tester) async {
      // El monto lo teclea quien captura: no hay ventana que abrir.
      final remote = _FakeRemote();
      await _pump(tester, remote);

      await _tap(tester, 'Variable');
      expect(find.text('Paso 1 de 1'), findsOneWidget);

      await _fill(tester, 'CÓDIGO', 'mensajeria');
      await _fill(tester, 'NOMBRE', 'Mensajería');
      await _tap(tester, 'Crear servicio');

      expect(remote.created?.pricingMode, PricingMode.variable);
      expect(remote.registered, isEmpty);
    });
  });

  group('un servicio por unidad', () {
    testWidgets('se crea con su precio en la misma pasada', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, remote);

      await _fill(tester, 'CÓDIGO', 'lavado_libra');
      await _fill(tester, 'NOMBRE', 'Lavado por libra');
      await _fill(tester, 'UNIDAD', 'libra');
      await _tap(tester, 'Siguiente');

      await _fill(tester, 'LAVADO POR LIBRA', '12.50');
      await _tap(tester, 'Crear servicio');

      expect(remote.created?.code, 'lavado_libra');
      expect(remote.created?.unitLabel, 'libra');
      expect(remote.created?.options, isEmpty);
      // En centavos, y sin opción: el precio cuelga del propio servicio.
      expect(remote.registered.single.$2, 1250);
      expect(remote.registered.single.$4, isNull);
    });

    testWidgets('sin precio no deja terminar', (tester) async {
      // Es el punto del asistente: un servicio mudo no se puede cobrar.
      final remote = _FakeRemote();
      await _pump(tester, remote);

      await _fill(tester, 'CÓDIGO', 'lavado_libra');
      await _fill(tester, 'NOMBRE', 'Lavado por libra');
      await _tap(tester, 'Siguiente');
      await _tap(tester, 'Crear servicio');

      expect(find.textContaining('Falta el precio'), findsOneWidget);
      expect(remote.created, isNull);
    });
  });

  group('un servicio por tramos', () {
    Future<void> twoTiers(WidgetTester tester) async {
      await _fill(tester, 'CÓDIGO', 'tinas');
      await _fill(tester, 'NOMBRE', 'Tinas');
      await _tap(tester, 'Por tramos');
      await _tap(tester, 'Siguiente');

      await _fill(tester, 'CÓDIGO', 'P');
      await _fill(tester, 'NOMBRE', 'Tina pequeña');
      await _fill(tester, 'DESDE', '1');
      await _fill(tester, 'HASTA', '5');

      await _tap(tester, 'Agregar tramo');
      await _fill(tester, 'CÓDIGO', 'G', at: 1);
      await _fill(tester, 'NOMBRE', 'Tina grande', at: 1);
    }

    testWidgets('cada tramo se lleva su propio precio', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, remote);

      await twoTiers(tester);
      await _tap(tester, 'Siguiente');

      await _fill(tester, 'TINA PEQUEÑA', '25.00');
      await _fill(tester, 'TINA GRANDE', '35.00');
      await _tap(tester, 'Crear servicio');

      expect(remote.created?.options.map((o) => o.code), ['P', 'G']);
      expect(remote.created?.options.first.minQuantity, 1);
      expect(remote.created?.options.first.maxQuantity, 5);
      // Un precio por tramo, colgado del id que asignó el servidor.
      expect(remote.registered.map((p) => (p.$2, p.$4)), [
        (2500, 'opt-0'),
        (3500, 'opt-1'),
      ]);
    });

    testWidgets('dos tramos con el mismo código se rechazan', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, remote);

      await _fill(tester, 'CÓDIGO', 'tinas');
      await _fill(tester, 'NOMBRE', 'Tinas');
      await _tap(tester, 'Por tramos');
      await _tap(tester, 'Siguiente');

      await _fill(tester, 'CÓDIGO', 'P');
      await _fill(tester, 'NOMBRE', 'Tina pequeña');
      await _tap(tester, 'Agregar tramo');
      await _fill(tester, 'CÓDIGO', 'P', at: 1);
      await _fill(tester, 'NOMBRE', 'Otra', at: 1);
      await _tap(tester, 'Siguiente');

      expect(find.text('Ese código ya está en otro tramo'), findsOneWidget);
      expect(remote.created, isNull);
    });

    testWidgets('el último tramo no se puede quitar', (tester) async {
      // El servidor rechaza un servicio por tramos sin ninguno.
      await _pump(tester, _FakeRemote());

      await _fill(tester, 'CÓDIGO', 'tinas');
      await _fill(tester, 'NOMBRE', 'Tinas');
      await _tap(tester, 'Por tramos');
      await _tap(tester, 'Siguiente');

      expect(find.byTooltip('Quitar tramo 1'), findsNothing);
      await _tap(tester, 'Agregar tramo');
      expect(find.byTooltip('Quitar tramo 1'), findsOneWidget);
    });
  });

  group('cuando algo falla', () {
    testWidgets('si el servicio no se crea, no se pierde lo escrito', (
      tester,
    ) async {
      final remote = _FakeRemote()..createFails = true;
      await _pump(tester, remote);

      await _fill(tester, 'CÓDIGO', 'lavado_libra');
      await _fill(tester, 'NOMBRE', 'Lavado por libra');
      await _tap(tester, 'Siguiente');
      await _fill(tester, 'LAVADO POR LIBRA', '12.50');
      await _tap(tester, 'Crear servicio');

      expect(find.textContaining('sin red'), findsOneWidget);
      // Sigue en el paso de precios, con el asistente entero por detrás.
      expect(find.text('Paso 2 de 2'), findsOneWidget);
    });

    testWidgets('si el precio falla se dice cuál quedó sin él', (tester) async {
      // El servicio ya existe: reintentar el alta chocaría contra el código,
      // que es único, así que lo honesto es nombrar lo que falta.
      final remote = _FakeRemote()..priceFails = true;
      await _pump(tester, remote);

      await _fill(tester, 'CÓDIGO', 'lavado_libra');
      await _fill(tester, 'NOMBRE', 'Lavado por libra');
      await _tap(tester, 'Siguiente');
      await _fill(tester, 'LAVADO POR LIBRA', '12.50');
      await _tap(tester, 'Crear servicio');

      expect(remote.created, isNotNull);
      expect(
        find.textContaining('quedó sin precio: Lavado por libra'),
        findsOneWidget,
      );
    });
  });
}
