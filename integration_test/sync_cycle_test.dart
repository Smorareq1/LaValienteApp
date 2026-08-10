import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:la_valiente/core/config/env.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/auth/data/auth_repository.dart';
import 'package:la_valiente/features/catalog/data/catalog_repository.dart';
import 'package:la_valiente/features/customers/data/customers_repository.dart';
import 'package:la_valiente/features/customers/models/customer.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/sync_progress.dart';

/// Ciclo de sincronización contra el backend real.
///
/// Es la prueba que ningún fake puede dar: que el contrato que la app escribe
/// y el que el servidor lee son el mismo. Requiere el backend levantado y un
/// usuario de pruebas:
///
/// ```
/// docker compose -f docker-compose.dev.yml up -d
/// flutter test integration_test/sync_cycle_test.dart -d emulator-5554 \
///   --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
///   --dart-define=E2E_USER=e2e_tester --dart-define=E2E_PASSWORD=...
/// ```
///
/// En el emulador de Android, `10.0.2.2` es el `localhost` de la máquina.
const String _user = String.fromEnvironment('E2E_USER');
const String _password = String.fromEnvironment('E2E_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer();

    // Cada corrida parte de cero: si no, el cursor de la anterior haría que el
    // pull no traiga nada y la prueba pasaría sin probar nada.
    //
    // Se re-cifra con la llave **vigente**, no con una nueva: rotar antes de
    // que la BD se haya abierto la dejaría intentando descifrar con una llave
    // que no corresponde al archivo. En producción el wipe solo ocurre con la
    // conexión ya abierta, y por eso ahí sí puede rotar.
    final key = await container.read(secureStorageProvider).databaseKey();
    await container.read(syncLocalDataSourceProvider).wipe(newHexKey: key);
  });

  tearDown(() => container.dispose());

  testWidgets('un dispositivo nuevo se registra y baja el catálogo sembrado', (tester) async {
    expect(
      _user.isNotEmpty && _password.isNotEmpty,
      isTrue,
      reason: 'faltan --dart-define=E2E_USER y E2E_PASSWORD',
    );

    final login = await container
        .read(authRepositoryProvider)
        .login(identifier: _user, password: _password);
    expect(
      login.isRight(),
      isTrue,
      reason: 'no se pudo iniciar sesión contra ${Env.apiV1BaseUrl}: '
          '${login.fold((failure) => failure.message, (_) => '')}',
    );

    final repository = container.read(syncRepositoryProvider);
    final steps = await repository.runCycle().toList();
    final last = steps.last;

    expect(
      last.phase,
      SyncPhase.done,
      reason: 'el ciclo falló: ${last.failure?.message}',
    );

    // El primer ciclo de un dispositivo nuevo es el bootstrap del §7.2.
    expect(steps.map((step) => step.phase), contains(SyncPhase.registering));
    expect(steps.map((step) => step.phase), contains(SyncPhase.bootstrapping));

    expect(await repository.deviceId(), isNotNull);

    // Con los espejos del PR S3 registrados, el catálogo sembrado no se aparca:
    // aterriza en sus tablas y queda consultable sin red.
    final catalog = container.read(catalogRepositoryProvider);
    final services = await catalog.watchServices().first;
    expect(services, isNotEmpty, reason: '¿corriste scripts/seed_catalog.py?');
    expect(services.map((service) => service.code), contains('wash_by_weight'));

    // Las opciones tienen que haber quedado colgadas de su servicio, que es lo
    // que el pull no garantiza por sí solo: llegan como filas sueltas.
    expect(
      services.where((service) => service.options.isNotEmpty),
      isNotEmpty,
      reason: 'ningún servicio recibió sus opciones',
    );

    expect(await catalog.watchGarmentTypes().first, isNotEmpty);

    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final porLibra = services.firstWhere((service) => service.code == 'wash_by_weight');
    final precio = await catalog.priceFor(serviceTypeId: porLibra.id, onDate: hoy);
    expect(precio, isNotNull, reason: 'el servicio por libra no tiene precio vigente');
    // El dinero viaja y se guarda como string: un double redondearía Q2.50.
    expect(precio!.amount, isA<String>());

    expect(
      await container.read(syncLocalDataSourceProvider).deferredCount(),
      0,
      reason: 'nada del feed quedó sin espejo',
    );
  });

  testWidgets('un cliente capturado offline llega al servidor y vuelve', (tester) async {
    expect(_user.isNotEmpty && _password.isNotEmpty, isTrue);

    await container
        .read(authRepositoryProvider)
        .login(identifier: _user, password: _password);

    final repository = container.read(syncRepositoryProvider);
    // Primer ciclo: registro y bootstrap.
    await repository.runCycle().toList();

    // Se captura por el repositorio de clientes, no encolando a mano: así lo
    // que se prueba es el camino que va a usar la pantalla.
    final customers = container.read(customersRepositoryProvider);
    final marca = DateTime.now().millisecondsSinceEpoch;
    final creado = await customers.create(
      fullName: 'Cliente E2E $marca',
      phone: '5555 1234',
    );

    final customer = creado.getRight().toNullable();
    expect(customer, isNotNull, reason: creado.getLeft().toNullable()?.message);
    // Existe y se puede buscar antes de que el servidor sepa de él (D1, D3).
    expect(customer!.isPending, isTrue);
    expect(
      await _names(customers.watch(query: 'cliente e2e $marca')),
      ['Cliente E2E $marca'],
    );
    expect(await repository.pendingCount(), 1);

    final last = (await repository.runCycle().toList()).last;

    expect(last.phase, SyncPhase.done, reason: last.failure?.message);
    expect(last.pushed, 1);
    expect(
      await repository.pendingCount(),
      0,
      reason: 'el servidor la aceptó, así que sale del outbox',
    );

    // La vuelta completa: el mismo ciclo lo trae de regreso por el feed, ya con
    // la versión que le asignó el servidor.
    final confirmado = await customers.byId(customer.id);
    expect(confirmado!.isPending, isFalse, reason: 'la fila se quedó protegida contra el pull');
    expect(confirmado.version, greaterThan(0));
    expect(confirmado.phone, '5555 1234');
  });
}

Future<List<String>> _names(Stream<List<Customer>> stream) async {
  return (await stream.first).map((customer) => customer.fullName).toList();
}
