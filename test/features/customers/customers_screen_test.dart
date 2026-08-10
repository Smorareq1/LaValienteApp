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
import 'package:la_valiente/features/customers/data/customers_local_datasource.dart';
import 'package:la_valiente/features/customers/data/customers_repository.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_status.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';
import 'package:la_valiente/features/sync/state/sync_status_controller.dart';

/// Estas pantallas no tocan la red: leen y escriben la BD local, y el motor de
/// sync se lleva las operaciones después. Un `UnimplementedError` delataría
/// cualquier ruta que sí saliera a buscar al servidor.
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

void main() {
  late AppDatabase database;
  late CustomersRepository repository;
  late SyncLocalDataSource syncLocal;
  var closed = false;
  var ids = 0;

  /// Como `testWidgets`, pero desmonta el árbol y apaga la BD antes de acabar.
  ///
  /// El orden importa, y los dos pasos son obligatorios. Al cancelar un stream,
  /// drift agenda un temporizador para olvidar esa consulta:
  ///
  /// - Si el árbol se desmonta cuando la prueba ya terminó, ese temporizador
  ///   queda vivo y el framework falla con "A Timer is still pending".
  /// - Y si se cierra la BD con uno de esos temporizadores pendiente —lo que
  ///   pasa en cuanto una prueba navega y cancela un stream a medio camino—,
  ///   `close()` se queda esperándolo para siempre.
  ///
  /// Desmontar y dejarlo correr antes de cerrar resuelve ambos.
  void customerTest(String description, Future<void> Function(WidgetTester) body) {
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
    syncLocal = SyncLocalDataSource(database);
    ids = 0;
    repository = CustomersRepository(
      database: database,
      local: CustomersLocalDataSource(database),
      sync: SyncRepository(
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
      ),
      uuid: () => 'cliente-${++ids}',
    );
  });

  // Red de seguridad para una prueba que reviente antes de cerrarla.
  tearDown(() async {
    if (!closed) await database.close();
  });

  AuthUser user({List<String> permissions = const [AppPermissions.all]}) {
    return AuthUser(
      id: 'u1',
      username: 'mgonzalez',
      fullName: 'Marta González',
      roles: const ['admin'],
      permissions: permissions,
      deniedPermissions: const [],
    );
  }

  /// Monta la app real, entra al tab Clientes y espera a que la lista pinte.
  Future<void> openCustomers(
    WidgetTester tester, {
    List<String> permissions = const [AppPermissions.all],
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider
              .overrideWith(() => _FakeAuthController(user(permissions: permissions))),
          syncEngineProvider.overrideWith(_IdleSyncEngine.new),
          syncStatusControllerProvider.overrideWith(_IdleSyncStatus.new),
          customersRepositoryProvider.overrideWithValue(repository),
        ],
        child: const LaValienteApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();
  }

  /// Escribe en el buscador y deja pasar el retardo.
  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(AppSearchField),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  Finder fieldNamed(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label, findRichText: true),
          matching: find.byType(AppFormField),
        ),
        matching: find.byType(TextField),
      );

  group('lista', () {
    customerTest('muestra los clientes con su teléfono y su NIT', (tester) async {
      await repository.create(
        fullName: 'Ana Pérez',
        phone: '5555-1234',
        nit: '1234567-8',
      );
      await repository.create(fullName: 'Luis Gómez');

      await openCustomers(tester);

      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('5555-1234 · NIT 1234567-8'), findsOneWidget);
      expect(find.text('Luis Gómez'), findsOneWidget);
      // Sin teléfono se dice, en vez de dejar la línea en blanco.
      expect(find.text('Sin teléfono ni NIT'), findsOneWidget);
      expect(find.text('2 registrados'), findsOneWidget);
    });

    customerTest('el buscador filtra sin importar tildes', (tester) async {
      await repository.create(fullName: 'Ana Pérez');
      await repository.create(fullName: 'Luis Gómez');

      await openCustomers(tester);
      await search(tester, 'perez');

      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('Luis Gómez'), findsNothing);
    });

    customerTest('una búsqueda sin resultados lo dice con el término buscado',
        (tester) async {
      await repository.create(fullName: 'Ana Pérez');

      await openCustomers(tester);
      await search(tester, 'zzz');

      expect(find.text('Nadie coincide con "zzz"'), findsOneWidget);
    });

    customerTest('sin clientes invita a registrar el primero', (tester) async {
      await openCustomers(tester);

      expect(find.text('Todavía no hay clientes'), findsOneWidget);
    });

    customerTest('un cliente capturado sin señal se marca como pendiente',
        (tester) async {
      await repository.create(fullName: 'Ana Pérez');

      await openCustomers(tester);

      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    customerTest('sin customers.create no aparece el botón de alta', (tester) async {
      await openCustomers(tester, permissions: const [AppPermissions.customersRead]);

      expect(find.text('Todavía no hay clientes'), findsOneWidget);
      expect(find.text('Nuevo cliente'), findsNothing);
    });
  });

  group('alta', () {
    customerTest('el cliente guardado aparece en la lista', (tester) async {
      await openCustomers(tester);

      await tester.tap(find.text('Nuevo cliente'));
      await tester.pumpAndSettle();

      await tester.enterText(fieldNamed('NOMBRE COMPLETO'), 'Sandra Chávez');
      await tester.enterText(fieldNamed('TELÉFONO'), '4478-1120');
      await tester.tap(find.text('Guardar cliente'));
      await tester.pumpAndSettle();

      expect(find.text('Sandra Chávez'), findsOneWidget);
      expect(find.text('4478-1120'), findsOneWidget);

      // Y quedó encolada para el servidor, no solo pintada.
      expect(await syncLocal.pendingCount(), 1);
    });

    customerTest('el atajo CF llena el NIT de consumidor final', (tester) async {
      await openCustomers(tester);

      await tester.tap(find.text('Nuevo cliente'));
      await tester.pumpAndSettle();

      await tester.enterText(fieldNamed('NOMBRE COMPLETO'), 'Sandra Chávez');
      await tester.tap(find.widgetWithText(InkWell, 'CF'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar cliente'));
      await tester.pumpAndSettle();

      expect(find.text('NIT CF'), findsOneWidget);
    });

    customerTest('sin nombre el error se ancla al campo y no se guarda nada',
        (tester) async {
      await openCustomers(tester);

      await tester.tap(find.text('Nuevo cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar cliente'));
      await tester.pumpAndSettle();

      expect(find.text('Escribe el nombre del cliente'), findsOneWidget);
      // La sheet sigue abierta con lo escrito; nadie perdió su captura.
      expect(find.text('Nuevo cliente'), findsWidgets);
      expect(await syncLocal.pendingCount(), 0);
    });
  });

  group('detalle', () {
    customerTest('abre con los datos del cliente', (tester) async {
      await repository.create(
        fullName: 'Ana Pérez',
        phone: '5555-1234',
        address: '4a calle 5-32, zona 1',
      );

      await openCustomers(tester);
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.text('Cliente'), findsOneWidget);
      expect(find.text('5555-1234'), findsOneWidget);
      expect(find.text('4a calle 5-32, zona 1'), findsOneWidget);
      // Los pedidos llegan con UI 4: el hueco se dice, no se inventa.
      expect(find.text('Aún no se ven los pedidos'), findsOneWidget);
    });

    customerTest('la edición se refleja al volver de la sheet', (tester) async {
      await repository.create(fullName: 'Ana Pérez');

      await openCustomers(tester);
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Editar'));
      await tester.pumpAndSettle();
      await tester.enterText(fieldNamed('NOMBRE COMPLETO'), 'Ana Morales');
      await tester.tap(find.text('Guardar cambios'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Morales'), findsOneWidget);
      expect(find.text('Ana Pérez'), findsNothing);
    });

    customerTest('sin customers.archive no se ofrece archivar', (tester) async {
      await repository.create(fullName: 'Ana Pérez');

      await openCustomers(
        tester,
        permissions: const [
          AppPermissions.customersRead,
          AppPermissions.customersUpdate,
        ],
      );
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Editar'), findsOneWidget);
      expect(find.text('Archivar cliente'), findsNothing);
    });

    customerTest('archivar pide confirmación y saca al cliente de la lista',
        (tester) async {
      await repository.create(fullName: 'Ana Pérez');

      await openCustomers(tester);
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Archivar cliente'));
      await tester.pumpAndSettle();

      expect(find.text('Archivar a Ana Pérez'), findsOneWidget);
      await tester.tap(find.text('Archivar'));
      await tester.pumpAndSettle();

      // Vuelve a la lista, ya sin él.
      expect(find.text('Todavía no hay clientes'), findsOneWidget);
      expect(find.text('Ana Pérez'), findsNothing);
    });

    customerTest('cancelar la confirmación deja al cliente en paz', (tester) async {
      await repository.create(fullName: 'Ana Pérez');

      await openCustomers(tester);
      await tester.tap(find.text('Ana Pérez'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Archivar cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Seguimos en el detalle, y al volver el cliente sigue en la lista.
      expect(find.text('Archivar cliente'), findsOneWidget);
      await tester.tap(find.byTooltip('Volver'));
      await tester.pumpAndSettle();
      expect(find.text('Ana Pérez'), findsOneWidget);
      expect(find.text('Todavía no hay clientes'), findsNothing);
    });
  });
}
