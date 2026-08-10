import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/errors/app_failure.dart';
import 'package:la_valiente/features/customers/data/customer_mirror.dart';
import 'package:la_valiente/features/customers/data/customers_local_datasource.dart';
import 'package:la_valiente/features/customers/data/customers_repository.dart';
import 'package:la_valiente/features/customers/models/customer.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';

/// Ni el servidor ni el almacén seguro participan en estas pruebas: capturar un
/// cliente tiene que funcionar sin red, que es justo lo que se comprueba. Si
/// alguna ruta los tocara, el `UnimplementedError` lo delataría.
class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late AppDatabase database;
  late CustomersRepository repository;
  late SyncLocalDataSource syncLocal;

  var ids = 0;

  setUp(() {
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
        device: const DeviceDescriptor(name: 'Tablet', platform: 'android', appVersion: '1.0.0'),
        uuid: () => 'op-${++ids}',
      ),
      uuid: () => 'cliente-${++ids}',
    );
  });

  tearDown(() => database.close());

  group('alta', () {
    test('el cliente queda disponible de inmediato y con su operación encolada', () async {
      final result = await repository.create(fullName: 'Ana Pérez', phone: '5555 1234');

      final customer = result.getRight().toNullable()!;
      expect(customer.fullName, 'Ana Pérez');
      expect(customer.isPending, isTrue);
      expect(customer.version, 0);

      final pending = await syncLocal.pendingOperations(limit: 10);
      expect(pending, hasLength(1));
      expect(pending.single.entity, 'customer');
      expect(pending.single.opType, 'create');
      expect(pending.single.entityId, customer.id);
      // Una creación no lleva `base_version`: no hay versión previa que exigir.
      expect(pending.single.baseVersion, isNull);
    });

    test('los campos opcionales vacíos viajan como null, no como cadena vacía', () async {
      // El backend valida el teléfono y el NIT contra un patrón: `""` sería un
      // rechazo que mandaría a revisión por no haber escrito algo opcional.
      await repository.create(fullName: 'Ana Pérez', phone: '  ', nit: '');

      final payload = (await syncLocal.pendingOperations(limit: 1)).single.payload;
      expect(payload['phone'], isNull);
      expect(payload['nit'], isNull);
      expect(payload['full_name'], 'Ana Pérez');
    });

    test('un nombre vacío se rechaza sin tocar la base', () async {
      final result = await repository.create(fullName: ' ');

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      expect(await syncLocal.pendingCount(), 0);
      expect(await repository.watch().first, isEmpty);
    });
  });

  group('edición', () {
    test('la operación lleva la versión conocida del servidor', () async {
      // Simula un cliente que ya bajó del feed en su versión 3.
      await CustomerMirror(database).apply(
        SyncChange(
          entity: 'customer',
          id: 'c1',
          version: 3,
          syncSeq: 3,
          deleted: false,
          data: const {
            'full_name': 'Ana Pérez',
            'phone': null,
            'nit': null,
            'email': null,
            'address': null,
            'notes': null,
            'is_active': true,
          },
        ),
      );
      final current = (await repository.byId('c1'))!;

      await repository.update(current, fullName: 'Ana Morales');

      final operation = (await syncLocal.pendingOperations(limit: 1)).single;
      expect(operation.opType, 'update');
      // Sin esto el servidor no puede distinguir una edición sobre datos
      // frescos de una que pisa lo que otro dispositivo ya escribió (D6).
      expect(operation.baseVersion, 3);
      expect((await repository.byId('c1'))!.syncStatus, RowSyncStatus.pending);
    });
  });

  group('archivado', () {
    test('viaja como operación propia, no como una edición', () async {
      // Es lo que hace que el servidor le exija `customers.archive`: como
      // update pasaría el permiso que cualquier colaborador tiene.
      final customer = (await repository.create(fullName: 'Ana Pérez'))
          .getRight()
          .toNullable()!;

      await repository.archive(customer);

      final operations = await syncLocal.pendingOperations(limit: 10);
      expect(operations.last.opType, 'archive');
      expect(operations.last.entityId, customer.id);
      // Archivar es un cambio de estado, no una escritura sobre campos:
      // hacerlo encima del cambio de nombre de otro no es un conflicto.
      expect(operations.last.baseVersion, isNull);
    });

    test('deja de listarse de inmediato, sin esperar al servidor', () async {
      final customer = (await repository.create(fullName: 'Ana Pérez'))
          .getRight()
          .toNullable()!;

      await repository.archive(customer);

      expect(await repository.watch().first, isEmpty);
      expect(await repository.watchById(customer.id).first, isNull);
    });
  });

  group('búsqueda', () {
    Future<void> seed(List<String> names) async {
      for (final name in names) {
        await repository.create(fullName: name);
      }
    }

    test('encuentra sin importar tildes ni mayúsculas', () async {
      await seed(['Ana Pérez', 'Luis Gómez']);

      expect(await _names(repository.watch(query: 'perez')), ['Ana Pérez']);
      expect(await _names(repository.watch(query: 'PÉREZ')), ['Ana Pérez']);
      expect(await _names(repository.watch(query: 'gomez')), ['Luis Gómez']);
    });

    test('encuentra por teléfono aunque se escriba sin separadores', () async {
      await repository.create(fullName: 'Ana Pérez', phone: '5555-1234');

      expect(await _names(repository.watch(query: '55551234')), ['Ana Pérez']);
    });

    test('los borrados en otro dispositivo no aparecen', () async {
      await seed(['Ana Pérez']);
      final customer = (await repository.watch().first).single;

      await CustomerMirror(database).apply(
        SyncChange(
          entity: 'customer',
          id: customer.id,
          version: 2,
          syncSeq: 2,
          deleted: true,
          data: const {
            'full_name': 'Ana Pérez',
            'phone': null,
            'nit': null,
            'email': null,
            'address': null,
            'notes': null,
            'is_active': true,
          },
        ),
      );

      // El espejo respeta la fila `pending`, así que primero se confirma su
      // captura; después el tombstone sí entra y deja de listarse.
      await CustomerMirror(database).settle(customer.id, rejected: false);
      await CustomerMirror(database).apply(
        SyncChange(
          entity: 'customer',
          id: customer.id,
          version: 2,
          syncSeq: 2,
          deleted: true,
          data: const {
            'full_name': 'Ana Pérez',
            'phone': null,
            'nit': null,
            'email': null,
            'address': null,
            'notes': null,
            'is_active': true,
          },
        ),
      );

      expect(await repository.watch().first, isEmpty);
    });
  });
}

Future<List<String>> _names(Stream<List<Customer>> stream) async {
  return (await stream.first).map((customer) => customer.fullName).toList();
}
