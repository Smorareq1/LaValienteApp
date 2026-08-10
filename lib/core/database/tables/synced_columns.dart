import 'package:drift/drift.dart';

/// Estado de sincronización de una fila espejo (plan 0004 §6.3).
enum RowSyncStatus {
  /// Igual a lo que tiene el servidor.
  synced,

  /// Tiene cambios locales con una operación esperando en el outbox. El pull
  /// no la pisa hasta que esa operación se resuelva.
  pending,

  /// Su operación cayó a la cola de revisión; espera una decisión humana.
  rejected,
}

/// Columnas que lleva toda tabla espejo del feed.
///
/// Base del esquema espejo: cada entidad que se sincronice (clientes, catálogo,
/// pedidos…) mezcla esto para hablar el mismo lenguaje que el motor —
/// `version` para la concurrencia optimista, `deletedAt` para los tombstones y
/// `syncStatus` para saber qué filas no debe tocar el pull.
mixin SyncedColumns on Table {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  TextColumn get id => text()();

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  IntColumn get version => integer().withDefault(const Constant(0))();

  TextColumn get syncStatus =>
      text().withLength(max: 20).withDefault(Constant(RowSyncStatus.synced.name))();

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
