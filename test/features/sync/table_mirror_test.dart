// `drift` y `matcher` exportan ambos `isNull`/`isNotNull`; aquí se quieren los
// del matcher, así que de drift solo entra lo que hace falta.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/features/catalog/data/catalog_mirrors.dart';
import 'package:la_valiente/features/customers/data/customer_mirror.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';

SyncChange _customer(
  String id, {
  String name = 'Ana Pérez',
  String? phone = '5555 1234',
  int version = 1,
  bool deleted = false,
}) {
  return SyncChange(
    entity: 'customer',
    id: id,
    version: version,
    syncSeq: version,
    deleted: deleted,
    data: {
      'id': id,
      'version': version,
      'full_name': name,
      'phone': phone,
      'nit': null,
      'email': null,
      'address': null,
      'notes': null,
      'is_active': true,
    },
  );
}

void main() {
  late AppDatabase database;
  late CustomerMirror mirror;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    mirror = CustomerMirror(database);
  });

  tearDown(() => database.close());

  Future<CustomerEntry?> read(String id) {
    return (database.select(
      database.customerEntries,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  group('aplicar el feed', () {
    test('un cambio nuevo crea la fila con la versión del servidor', () async {
      await mirror.apply(_customer('c1'));

      final row = await read('c1');
      expect(row!.fullName, 'Ana Pérez');
      expect(row.version, 1);
      expect(row.syncStatus, RowSyncStatus.synced.name);
      expect(row.deletedAt, isNull);
    });

    test('el índice de búsqueda ignora tildes y separadores del teléfono', () async {
      await mirror.apply(_customer('c1'));

      final row = await read('c1');
      expect(row!.searchIndex, 'ana perez 55551234');
    });

    test('un cambio posterior reemplaza la fila entera', () async {
      await mirror.apply(_customer('c1'));
      await mirror.apply(_customer('c1', name: 'Ana Morales', phone: null, version: 2));

      final row = await read('c1');
      expect(row!.fullName, 'Ana Morales');
      expect(row.phone, isNull);
      expect(row.version, 2);
    });

    test('un borrado deja tombstone en vez de borrar la fila', () async {
      await mirror.apply(_customer('c1'));
      await mirror.apply(_customer('c1', version: 2, deleted: true));

      final row = await read('c1');
      // La fila sobrevive: si se borrara, un re-pull de la misma página la
      // resucitaría y el borrado se perdería.
      expect(row, isNotNull);
      expect(row!.deletedAt, isNotNull);
    });

    test('un cambio sin borrado levanta un tombstone anterior', () async {
      await mirror.apply(_customer('c1', deleted: true));
      await mirror.apply(_customer('c1', version: 2));

      expect((await read('c1'))!.deletedAt, isNull);
    });
  });

  group('filas con captura local', () {
    Future<void> insertPending(String id, String name) {
      return database
          .into(database.customerEntries)
          .insert(
            CustomerEntriesCompanion.insert(
              id: id,
              fullName: name,
              syncStatus: Value(RowSyncStatus.pending.name),
            ),
          );
    }

    test('el pull no pisa lo capturado y sin confirmar', () async {
      await insertPending('c1', 'Nombre del mostrador');

      await mirror.apply(_customer('c1', name: 'Nombre del servidor'));

      // Lo escrito en el mostrador sigue en pantalla: pisarlo con lo que el
      // servidor tenía *antes* de recibirlo haría desaparecer el trabajo de la
      // persona sin ninguna explicación.
      expect((await read('c1'))!.fullName, 'Nombre del mostrador');
    });

    test('tras confirmarse la operación, el pull vuelve a mandar', () async {
      await insertPending('c1', 'Nombre del mostrador');

      await mirror.settle('c1', rejected: false);
      await mirror.apply(_customer('c1', name: 'Nombre del servidor'));

      expect((await read('c1'))!.fullName, 'Nombre del servidor');
    });

    test('un rechazo marca la fila para la cola de revisión', () async {
      await insertPending('c1', 'Nombre del mostrador');

      await mirror.settle('c1', rejected: true);

      expect((await read('c1'))!.syncStatus, RowSyncStatus.rejected.name);
    });
  });

  group('espejos del catálogo', () {
    test('cada espejo declara la entidad que el feed nombra', () {
      final names = catalogMirrors(database).map((mirror) => mirror.entity);

      expect(names, ['service_type', 'service_option', 'service_price', 'garment_type']);
    });

    test('el precio se guarda tal cual, sin pasar por double', () async {
      await ServicePriceMirror(database).apply(
        SyncChange(
          entity: 'service_price',
          id: 'p1',
          version: 1,
          syncSeq: 1,
          deleted: false,
          data: {
            'service_type_id': 's1',
            'service_option_id': null,
            'price': '12.35',
            'valid_from': '2026-01-01',
            'valid_to': null,
          },
        ),
      );

      final row = await (database.select(
        database.servicePriceEntries,
      )..where((entry) => entry.id.equals('p1'))).getSingle();
      expect(row.price, '12.35');
    });
  });
}
