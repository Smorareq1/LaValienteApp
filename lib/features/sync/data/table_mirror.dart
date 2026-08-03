import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../models/sync_change.dart';
import 'entity_mirror.dart';

/// Espejo genérico de una tabla que mezcla [SyncedColumns].
///
/// Concentra aquí las dos reglas que toda entidad del feed comparte, para que
/// ningún módulo las tenga que recordar (§7.2):
///
/// 1. Un cambio borrado es un **tombstone**: se marca `deletedAt`, no se borra
///    la fila, porque el borrado tiene que sobrevivir a un re-pull.
/// 2. Una fila `pending` **no se pisa**. Es una captura local que todavía viaja
///    en el outbox; el pull la sobrescribiría con lo que el servidor tenía
///    *antes* de recibirla, y el trabajo de la persona desaparecería de la
///    pantalla sin explicación.
///
/// Lo único que cada módulo pone es cómo se traduce el JSON del feed a columnas.
abstract class TableMirror<D extends DataClass> implements SyncEntityMirror {
  const TableMirror(this.database);

  final AppDatabase database;

  /// Tabla espejo. Debe mezclar [SyncedColumns].
  TableInfo<Table, D> get table;

  /// Traduce `change.data` a las columnas propias de la entidad. Las comunes
  /// (`id`, `version`, `syncStatus`, `deletedAt`) las pone [apply].
  UpdateCompanion<D> toCompanion(SyncChange change);

  @override
  Future<void> apply(SyncChange change) async {
    if (await _isPending(change.id)) return;

    final columns = <String, Expression<Object>>{
      ...toCompanion(change).toColumns(false),
      'id': Variable<String>(change.id),
      'version': Variable<int>(change.version),
      'sync_status': Variable<String>(RowSyncStatus.synced.name),
      if (change.deleted) 'deleted_at': Variable<DateTime>(DateTime.now()),
      if (!change.deleted) 'deleted_at': const Variable<DateTime>(null),
    };

    await database
        .into(table)
        .insert(RawValuesInsertable<D>(columns), mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> settle(String entityId, {required bool rejected}) async {
    // El servidor ya dio su veredicto: la fila deja de estar protegida contra el
    // pull. Si se aplicó, el cambio que viene atrás traerá los valores buenos
    // (montos recalculados, correlativos); si se rechazó, queda marcada para que
    // la cola de revisión tenga a qué apuntar.
    final status = rejected ? RowSyncStatus.rejected : RowSyncStatus.synced;
    await database.customUpdate(
      'UPDATE ${table.actualTableName} SET sync_status = ? WHERE id = ?',
      variables: [Variable<String>(status.name), Variable<String>(entityId)],
      updates: {table},
    );
  }

  Future<bool> _isPending(String id) async {
    final rows = await database
        .customSelect(
          'SELECT 1 FROM ${table.actualTableName} WHERE id = ? AND sync_status = ?',
          variables: [
            Variable<String>(id),
            Variable<String>(RowSyncStatus.pending.name),
          ],
          readsFrom: {table},
        )
        .get();
    return rows.isNotEmpty;
  }
}
