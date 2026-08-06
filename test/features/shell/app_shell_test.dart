import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/app.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/sync/models/sync_status.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';
import 'package:la_valiente/features/sync/state/sync_status_controller.dart';

/// Sustituye el controlador de auth por una sesión fija, sin tocar red ni
/// almacenamiento seguro.
class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

/// Montar el shell enciende el motor de sync. En un widget test no hay BD
/// cifrada ni canales de plataforma, así que se sustituye por un motor apagado
/// y un estado fijo.
class _IdleSyncEngine extends SyncEngine {
  @override
  SyncEngineState build() => const SyncEngineState();
}

class _IdleSyncStatus extends SyncStatusController {
  @override
  SyncStatus build() => const SyncStatus.synced();
}

AuthUser _user({
  required List<String> permissions,
  List<String> roles = const ['admin'],
  List<String> denied = const [],
}) {
  return AuthUser(
    id: 'u1',
    username: 'mgonzalez',
    fullName: 'Marta González',
    roles: roles,
    permissions: permissions,
    deniedPermissions: denied,
  );
}

/// Monta la app real con la sesión indicada y deja que el router redirija.
Future<void> _pumpApp(WidgetTester tester, AuthUser user) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => _FakeAuthController(user)),
        syncEngineProvider.overrideWith(_IdleSyncEngine.new),
        syncStatusControllerProvider.overrideWith(_IdleSyncStatus.new),
      ],
      child: const LaValienteApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // El shell mide contra un teléfono: el diseño es mobile-first (Plan 0006 §3.1).
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('un admin ve los 5 destinos de la barra inferior', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(
      tester,
      _user(permissions: [
        AppPermissions.ordersRead,
        AppPermissions.expensesRead,
        AppPermissions.customersRead,
        AppPermissions.dailyCloseRead,
      ]),
    );

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Caja'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Más'), findsOneWidget);
  });

  testWidgets('sin permisos de módulo solo quedan Inicio y Más', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, _user(permissions: const [], roles: const ['colaborador']));

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Más'), findsOneWidget);
    expect(find.text('Pedidos'), findsNothing);
    expect(find.text('Caja'), findsNothing);
    expect(find.text('Clientes'), findsNothing);
  });

  testWidgets('Inicio muestra el saludo y las secciones permitidas', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(
      tester,
      _user(permissions: [
        AppPermissions.ordersRead,
        AppPermissions.ordersCreate,
        AppPermissions.expensesRead,
        AppPermissions.dailyCloseRead,
      ]),
    );

    expect(find.text('Marta González'), findsOneWidget);
    expect(find.text('Caja al momento'), findsOneWidget);
    expect(find.text('En el taller'), findsOneWidget);
    expect(find.text('Listos para entregar'), findsOneWidget);
    expect(find.text('Acciones rápidas'), findsOneWidget);
    expect(find.text('Nuevo pedido'), findsOneWidget);

    // Sin backend el día arranca en cero y la lista corta va vacía.
    // Las cifras son Text.rich (entero + decimales), de ahí findRichText.
    expect(find.text('Q0.00', findRichText: true), findsWidgets);
    expect(find.text('Nada listo por ahora'), findsOneWidget);
  });

  testWidgets('sin daily_close.read no se muestra el resumen de dinero', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, _user(permissions: [AppPermissions.ordersRead]));

    expect(find.text('Caja al momento'), findsNothing);
    expect(find.text('En el taller'), findsOneWidget);
  });

  testWidgets('el tab Más lista los módulos que el rol puede usar', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(
      tester,
      _user(permissions: [
        AppPermissions.inventoryRead,
        AppPermissions.catalogManage,
      ]),
    );

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    expect(find.text('Insumos'), findsOneWidget);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Sincronización'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);

    // Promociones exige `promotions.manage`, que este usuario no tiene.
    expect(find.text('Promociones'), findsNothing);
  });

  testWidgets('con el comodín el admin ve todos los destinos y módulos', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Un solo permiso, ninguno de los que las pantallas piden por nombre: es
    // exactamente la situación de un módulo que todavía no existía cuando se
    // creó el rol.
    await _pumpApp(tester, _user(permissions: const [AppPermissions.all]));

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Caja'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    expect(find.text('Insumos'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Promociones'), findsOneWidget);
  });

  testWidgets('cada entrada de Más abre una pantalla y deja volver', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(tester, _user(permissions: const [AppPermissions.all]));

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    // Sincronización y Promociones quedan fuera: son las del hub que ya tienen
    // pantalla real (UI 1 y UI 5).
    const entries = [
      'Insumos',
      'Personal',
      'Catálogo',
      'Cierres de días pasados',
      'Ajustes',
    ];

    for (final entry in entries) {
      await tester.tap(find.text(entry));
      await tester.pumpAndSettle();

      // Sin ruta, GoRouter caería en su pantalla de error en vez de en esto.
      expect(find.text('En construcción'), findsOneWidget, reason: entry);

      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('Cerrar sesión'), findsOneWidget, reason: entry);
    }
  });

  testWidgets('un deny explícito le gana al comodín', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pumpApp(
      tester,
      _user(
        permissions: const [AppPermissions.all],
        denied: const [AppPermissions.promotionsManage],
      ),
    );

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Promociones'), findsNothing);
  });
}
