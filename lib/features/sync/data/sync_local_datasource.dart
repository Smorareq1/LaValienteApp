import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../models/sync_change.dart';
import '../models/sync_operation.dart';
import 'entity_mirror.dart';

part 'sync_local_datasource.g.dart';

/// Lectura y escritura de la cola local de sincronización.
///
/// I/O puro sobre Drift: no decide cuándo sincronizar ni qué hacer con un
/// rechazo, solo persiste.
class SyncLocalDataSource {
  const SyncLocalDataSource(this._database);

  final AppDatabase _database;

  static const int _stateRowId = 0;

  // --- Estado del motor -----------------------------------------------------

  /// Devuelve la fila de estado, creándola en el primer arranque.
  Future<SyncStateEntry> loadState() async {
    final existing = await (_database.select(
      _database.syncStateEntries,
    )..where((row) => row.id.equals(_stateRowId))).getSingleOrNull();
    if (existing != null) return existing;

    await _database
        .into(_database.syncStateEntries)
        .insert(const SyncStateEntriesCompanion(id: Value(_stateRowId)));
    return (_database.select(
      _database.syncStateEntries,
    )..where((row) => row.id.equals(_stateRowId))).getSingle();
  }

  Stream<SyncStateEntry> watchState() {
    return (_database.select(
      _database.syncStateEntries,
    )..where((row) => row.id.equals(_stateRowId))).watchSingleOrNull().asyncMap(
      (row) async => row ?? await loadState(),
    );
  }

  Future<void> updateState(SyncStateEntriesCompanion changes) async {
    await loadState();
    await (_database.update(
      _database.syncStateEntries,
    )..where((row) => row.id.equals(_stateRowId))).write(changes);
  }

  // --- Outbox ---------------------------------------------------------------

  /// Encola una operación capturada. Devuelve el `seq` local asignado.
  Future<int> enqueue({
    required String opId,
    required String entity,
    required String opType,
    required String entityId,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    int? baseVersion,
  }) {
    return _database
        .into(_database.outboxEntries)
        .insert(
          OutboxEntriesCompanion.insert(
            opId: opId,
            entity: entity,
            opType: opType,
            entityId: entityId,
            payload: jsonEncode(payload),
            createdAt: createdAt,
            baseVersion: Value(baseVersion),
          ),
        );
  }

  /// Las operaciones más viejas primero: el servidor las aplica en ese orden.
  Future<List<SyncOperation>> pendingOperations({required int limit}) async {
    final rows =
        await (_database.select(_database.outboxEntries)
              ..orderBy([(row) => OrderingTerm.asc(row.seq)])
              ..limit(limit))
            .get();
    return rows.map(_toOperation).toList();
  }

  Future<int> pendingCount() async {
    final count = _database.outboxEntries.seq.count();
    final query = _database.selectOnly(_database.outboxEntries)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final count = _database.outboxEntries.seq.count();
    final query = _database.selectOnly(_database.outboxEntries)..addColumns([count]);
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Saca del outbox las operaciones que el servidor ya dio por buenas.
  Future<void> removeOperations(Iterable<String> opIds) async {
    if (opIds.isEmpty) return;
    await (_database.delete(
      _database.outboxEntries,
    )..where((row) => row.opId.isIn(opIds.toList()))).go();
  }

  /// Deja constancia de un intento fallido para que el problema sea visible
  /// aunque el motor siga reintentando en silencio.
  Future<void> recordAttempt(Iterable<String> opIds, String error) async {
    if (opIds.isEmpty) return;
    await _database.customUpdate(
      'UPDATE outbox_entries SET attempts = attempts + 1, last_error = ? '
      'WHERE op_id IN (${List.filled(opIds.length, '?').join(', ')})',
      variables: [Variable<String>(error), ...opIds.map(Variable<String>.new)],
      updates: {_database.outboxEntries},
    );
  }

  // --- Cola de revisión -----------------------------------------------------

  /// Mueve una operación rechazada o en conflicto a revisión humana (§8).
  Future<void> moveToReview(SyncOperation operation, SyncOperationResult result) async {
    await _database.transaction(() async {
      await _database
          .into(_database.reviewEntries)
          .insert(
            ReviewEntriesCompanion.insert(
              opId: operation.opId,
              entity: operation.entity,
              opType: operation.opType,
              entityId: operation.entityId,
              status: result.outcome.name,
              reason: Value(result.reason),
              localPayload: jsonEncode(operation.payload),
              serverData: Value(
                result.serverData == null ? null : jsonEncode(result.serverData),
              ),
              serverVersion: Value(result.serverVersion),
              createdAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      await (_database.delete(
        _database.outboxEntries,
      )..where((row) => row.opId.equals(operation.opId))).go();
    });
  }

  Stream<int> watchReviewCount() {
    final count = _database.reviewEntries.id.count();
    final query = _database.selectOnly(_database.reviewEntries)
      ..addColumns([count])
      ..where(_database.reviewEntries.resolvedAt.isNull());
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  // --- Feed de cambios ------------------------------------------------------

  /// Aplica una página del feed y avanza el cursor **en la misma transacción**.
  ///
  /// Si el proceso muere a media página, la transacción se deshace entera y el
  /// cursor sigue apuntando al inicio: al reintentar se re-aplica la página, lo
  /// que es inocuo porque cada cambio trae la fila completa (§7.2).
  Future<void> applyPage({
    required List<SyncChange> changes,
    required int nextCursor,
    required Map<String, SyncEntityMirror> mirrors,
    required DateTime pulledAt,
  }) {
    return _database.transaction(() async {
      for (final change in changes) {
        final mirror = mirrors[change.entity];
        if (mirror != null) {
          await mirror.apply(change);
        } else {
          await _deferChange(change, pulledAt);
        }
      }

      await updateState(
        SyncStateEntriesCompanion(
          pullCursor: Value(nextCursor),
          lastPullAt: Value(pulledAt),
        ),
      );
    });
  }

  Future<void> _deferChange(SyncChange change, DateTime receivedAt) {
    return _database
        .into(_database.deferredChanges)
        .insert(
          DeferredChangesCompanion.insert(
            entity: change.entity,
            entityId: change.id,
            version: change.version,
            syncSeq: change.syncSeq,
            deleted: change.deleted,
            data: jsonEncode(change.data),
            receivedAt: receivedAt,
          ),
          onConflict: DoUpdate(
            (_) => DeferredChangesCompanion(
              version: Value(change.version),
              syncSeq: Value(change.syncSeq),
              deleted: Value(change.deleted),
              data: Value(jsonEncode(change.data)),
              receivedAt: Value(receivedAt),
            ),
          ),
        );
  }

  /// Cambios guardados de entidades que todavía no tienen espejo.
  Future<List<SyncChange>> deferredChanges({String? entity}) async {
    final query = _database.select(_database.deferredChanges)
      ..orderBy([(row) => OrderingTerm.asc(row.syncSeq)]);
    if (entity != null) query.where((row) => row.entity.equals(entity));

    final rows = await query.get();
    return rows
        .map(
          (row) => SyncChange(
            entity: row.entity,
            id: row.entityId,
            version: row.version,
            syncSeq: row.syncSeq,
            deleted: row.deleted,
            data: (jsonDecode(row.data) as Map).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<int> deferredCount() async {
    final count = _database.deferredChanges.entityId.count();
    final query = _database.selectOnly(_database.deferredChanges)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Aplica los cambios aparcados cuya entidad ya tiene espejo y los descarta.
  ///
  /// Es lo que hace que registrar un espejo nuevo baste: lo que llegó mientras
  /// no existía entra en el siguiente ciclo, sin rebobinar el cursor ni pedirle
  /// nada extra al servidor. Devuelve cuántos se aplicaron.
  Future<int> drainDeferred(Map<String, SyncEntityMirror> mirrors) async {
    if (mirrors.isEmpty) return 0;

    final pending = (await deferredChanges())
        .where((change) => mirrors.containsKey(change.entity))
        .toList();
    if (pending.isEmpty) return 0;

    await _database.transaction(() async {
      for (final change in pending) {
        await mirrors[change.entity]!.apply(change);
        await (_database.delete(_database.deferredChanges)..where(
              (row) => row.entity.equals(change.entity) & row.entityId.equals(change.id),
            ))
            .go();
      }
    });
    return pending.length;
  }

  // --- Wipe -----------------------------------------------------------------

  /// Borra todo rastro local. Lo ejecuta la orden de revocación (D11).
  ///
  /// Borrar filas no basta: SQLite deja las páginas liberadas dentro del
  /// archivo. `VACUUM` lo reescribe y `PRAGMA rekey` lo vuelve a cifrar con
  /// [newHexKey], de modo que lo que quedara del archivo anterior ya no se
  /// puede descifrar ni con la llave que el dispositivo tenía guardada.
  Future<void> wipe({required String newHexKey}) async {
    await _database.transaction(() async {
      for (final table in _database.allTables) {
        await _database.delete(table).go();
      }
    });
    await _database.customStatement('VACUUM;');
    await _database.customStatement('PRAGMA rekey = "x\'$newHexKey\'";');
  }

  SyncOperation _toOperation(OutboxEntry row) {
    return SyncOperation(
      seq: row.seq,
      opId: row.opId,
      entity: row.entity,
      opType: row.opType,
      entityId: row.entityId,
      baseVersion: row.baseVersion,
      payload: (jsonDecode(row.payload) as Map).cast<String, dynamic>(),
      createdAt: row.createdAt,
      attempts: row.attempts,
      lastError: row.lastError,
    );
  }
}

@Riverpod(keepAlive: true)
SyncLocalDataSource syncLocalDataSource(Ref ref) {
  return SyncLocalDataSource(ref.watch(appDatabaseProvider));
}
