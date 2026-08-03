import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tabla espejo de clientes (plan 0004 §7.3: bidireccional, `create` y `update`
/// offline).
///
/// Es la única entidad del PR S3 que se escribe local: por eso `syncStatus`
/// importa aquí de verdad — una fila `pending` es un cliente capturado en el
/// mostrador que el servidor todavía no conoce, y el pull no la puede pisar.
@DataClassName('CustomerEntry')
class CustomerEntries extends Table with SyncedColumns {
  TextColumn get fullName => text().withLength(max: 120)();
  TextColumn get phone => text().withLength(max: 20).nullable()();
  TextColumn get nit => text().withLength(max: 20).nullable()();
  TextColumn get email => text().withLength(max: 320).nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// `full_name` y `phone` en minúsculas y sin acentos, para que la búsqueda del
  /// mostrador encuentre "Perez" escribiendo "pérez" y al revés. Se calcula al
  /// escribir porque SQLite no trae `unaccent` ni una collation que sirva.
  TextColumn get searchIndex => text().withDefault(const Constant(''))();
}
