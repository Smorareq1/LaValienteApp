import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/device_descriptor.dart';
import '../models/review_item.dart';
import '../models/sync_change.dart';
import '../models/sync_details.dart';
import '../models/sync_operation.dart';
import '../models/sync_progress.dart';
import 'entity_mirror.dart';
import 'sync_local_datasource.dart';
import 'sync_mirrors.dart';
import 'sync_remote_datasource.dart';

part 'sync_repository.g.dart';

/// Umbral de desfase de reloj que se reporta al usuario (§9, `SYNC_CLOCK_SKEW_WARN_S`).
const Duration kClockSkewWarnThreshold = Duration(minutes: 5);

/// Orquesta el ciclo de sincronización: **push → pull → reconciliar**.
///
/// Emite el avance como Stream (regla §11 de ARCHITECTURE.md) en vez de
/// devolver un resultado al final: un bootstrap de varios miles de filas tiene
/// que poder mostrar en qué va sin bloquear la pantalla.
///
/// No decide *cuándo* correr — de eso se encarga el motor en la capa de estado.
class SyncRepository {
  SyncRepository({
    required SyncLocalDataSource local,
    required SyncRemoteDataSource remote,
    required SecureStorageService storage,
    required Map<String, SyncEntityMirror> mirrors,
    required DeviceDescriptor device,
    DateTime Function() clock = DateTime.now,
    String Function() uuid = _defaultUuid,
  }) : _local = local,
       _remote = remote,
       _storage = storage,
       _mirrors = mirrors,
       _device = device,
       _clock = clock,
       _uuid = uuid;

  final SyncLocalDataSource _local;
  final SyncRemoteDataSource _remote;
  final SecureStorageService _storage;
  final Map<String, SyncEntityMirror> _mirrors;
  final DeviceDescriptor _device;
  final DateTime Function() _clock;
  final String Function() _uuid;

  static String _defaultUuid() => const Uuid().v4();

  /// Encola una operación local. La captura no espera al servidor: por eso el
  /// `op_id` y el `entity_id` los genera el dispositivo (D3, D4).
  Future<String> enqueue({
    required String entity,
    required String opType,
    required String entityId,
    required Map<String, dynamic> payload,
    int? baseVersion,
  }) async {
    final opId = _uuid();
    await _local.enqueue(
      opId: opId,
      entity: entity,
      opType: opType,
      entityId: entityId,
      payload: payload,
      baseVersion: baseVersion,
      createdAt: _clock(),
    );
    return opId;
  }

  /// Id que este dispositivo generó para sí mismo, o `null` si nunca arrancó.
  Future<String?> deviceId() async => (await _local.loadState()).deviceId;

  Future<int> pendingCount() => _local.pendingCount();

  Stream<int> watchPendingCount() => _local.watchPendingCount();

  /// Lo que espera subir, desglosado por entidad (§11.1).
  Stream<Map<String, int>> watchPendingByEntity() => _local.watchPendingByEntity();

  Stream<int> watchReviewCount() => _local.watchReviewCount();

  /// La cola de revisión, lo más reciente primero (§8).
  Stream<List<ReviewItem>> watchReviewItems() {
    return _local.watchReviewEntries().map(
      (rows) => rows.map(_toReviewItem).toList(),
    );
  }

  /// Descarta la captura: la persona decidió que no debe subir.
  ///
  /// Si la operación era un **alta**, se retira además la fila que dejó en el
  /// dispositivo. Es lo único que el feed no puede corregir por su cuenta,
  /// porque del otro lado esa entidad nunca existió.
  Future<void> discardReview(ReviewItem item) {
    return _local.discardReview(
      opId: item.opId,
      entityId: item.entityId,
      mirror: item.kind.createsLocalRow ? _mirrors[item.entity] : null,
      at: _clock(),
    );
  }

  /// Cierra la entrada sin tocar nada más. Lo usa quien ya resolvió el problema
  /// por otro camino: corregir la boleta deja su propia operación en el outbox,
  /// y dejar la entrada abierta pediría dos veces la misma decisión.
  Future<void> resolveReview(ReviewItem item) =>
      _local.resolveReview(item.opId, _clock());

  /// Vuelve a mandar la operación tal como se capturó.
  ///
  /// [baseVersion] lo aporta quien llama, con la versión que el dispositivo
  /// conoce **ahora**: la que iba en la operación original es justamente la que
  /// el servidor ya declaró vieja, y repetirla solo repetiría el choque.
  ///
  /// No se vuelve a marcar la fila local como `pending`. Lo que se reenvía es
  /// un comando, y el estado baja por el feed cuando el servidor lo aplique
  /// (D5): hasta entonces la pantalla muestra lo que el servidor tiene, que es
  /// la verdad de ese momento.
  Future<String> retryReview(ReviewItem item, {int? baseVersion}) async {
    final opId = _uuid();
    await _local.retryReview(
      resolvedOpId: item.opId,
      opId: opId,
      entity: item.entity,
      opType: item.opType,
      entityId: item.entityId,
      payload: item.localPayload,
      baseVersion: baseVersion,
      at: _clock(),
    );
    return opId;
  }

  ReviewItem _toReviewItem(ReviewEntry row) {
    return ReviewItem(
      opId: row.opId,
      entity: row.entity,
      opType: row.opType,
      entityId: row.entityId,
      outcome: ReviewOutcome.fromWire(row.status),
      reason: row.reason,
      localPayload: (jsonDecode(row.localPayload) as Map).cast<String, dynamic>(),
      serverData: row.serverData == null
          ? null
          : (jsonDecode(row.serverData!) as Map).cast<String, dynamic>(),
      serverVersion: row.serverVersion,
      createdAt: row.createdAt,
    );
  }

  Stream<SyncDetails> watchDetails() {
    return _local.watchState().map(
      (row) => SyncDetails(
        deviceId: row.deviceId,
        pullCursor: row.pullCursor,
        bootstrapCompleted: row.bootstrapCompleted,
        lastCycleAt: row.lastCycleAt,
        lastPushAt: row.lastPushAt,
        lastPullAt: row.lastPullAt,
        lastError: row.lastError,
        clockSkew: row.clockSkewSeconds == null
            ? null
            : Duration(seconds: row.clockSkewSeconds!),
      ),
    );
  }

  /// Corre un ciclo completo. Nunca lanza: los fallos salen como
  /// [SyncPhase.failed] con su [AppFailure].
  Stream<SyncProgress> runCycle() async* {
    var pushed = 0;
    var pulled = 0;

    try {
      final deviceId = await _ensureDeviceId();

      if (!(await _local.loadState()).deviceRegistered) {
        yield const SyncProgress(phase: SyncPhase.registering);
        await _remote.registerDevice(
          deviceId: deviceId,
          name: _device.name,
          platform: _device.platform,
          appVersion: _device.appVersion,
        );
        await _local.updateState(
          const SyncStateEntriesCompanion(deviceRegistered: Value(true)),
        );
      }

      // Lo que llegó cuando su entidad no tenía espejo entra ahora. Va antes
      // que todo porque un espejo recién registrado tiene que ver su historia
      // completa antes de que nadie lea su tabla.
      await _local.drainDeferred(_mirrors);

      // --- Push -------------------------------------------------------------
      while (true) {
        final batch = await _local.pendingOperations(limit: kSyncPushMaxOperations);
        if (batch.isEmpty) break;

        yield SyncProgress(
          phase: SyncPhase.pushing,
          pushed: pushed,
          pulled: pulled,
          remaining: await _local.pendingCount(),
        );

        final result = await _remote.push(deviceId: deviceId, operations: batch);
        if (result.deviceDirective == SyncDirective.wipe) {
          yield await _wipe();
          return;
        }

        final settled = await _reconcile(batch, result);
        pushed += settled;
        await _local.updateState(
          SyncStateEntriesCompanion(lastPushAt: Value(_clock())),
        );

        if (settled == 0) {
          // El servidor no resolvió ninguna operación del lote. Reintentar
          // ahora mismo sería un bucle: se corta y el backoff decide cuándo.
          throw const ServerFailure(
            'El servidor no devolvió resultado para ninguna operación del lote',
          );
        }
      }

      // --- Pull -------------------------------------------------------------
      final state = await _local.loadState();
      final isBootstrap = !state.bootstrapCompleted;
      var cursor = state.pullCursor;
      var hasMore = true;
      Duration? skew;

      while (hasMore) {
        yield SyncProgress(
          phase: isBootstrap ? SyncPhase.bootstrapping : SyncPhase.pulling,
          pushed: pushed,
          pulled: pulled,
        );

        final page = await _remote.pull(deviceId: deviceId, cursor: cursor);
        if (page.deviceDirective == SyncDirective.wipe) {
          yield await _wipe();
          return;
        }

        final receivedAt = _clock();
        await _local.applyPage(
          changes: page.changes,
          nextCursor: page.nextCursor,
          mirrors: _mirrors,
          pulledAt: receivedAt,
        );

        pulled += page.changes.length;
        skew = receivedAt.difference(page.serverTime);
        hasMore = page.hasMore;

        if (page.nextCursor <= cursor) {
          // Sin avance del cursor no hay progreso posible; seguir pidiendo la
          // misma página sería un bucle infinito contra el servidor.
          break;
        }
        cursor = page.nextCursor;
      }

      await _local.updateState(
        SyncStateEntriesCompanion(
          bootstrapCompleted: const Value(true),
          lastCycleAt: Value(_clock()),
          lastError: const Value(null),
          clockSkewSeconds: Value(skew?.inSeconds),
        ),
      );

      yield SyncProgress(
        phase: SyncPhase.done,
        pushed: pushed,
        pulled: pulled,
        remaining: await _local.pendingCount(),
      );
    } catch (error) {
      final failure = AppFailure.fromException(error);
      await _local.updateState(
        SyncStateEntriesCompanion(lastError: Value(failure.message)),
      );
      yield SyncProgress(
        phase: SyncPhase.failed,
        pushed: pushed,
        pulled: pulled,
        remaining: await _local.pendingCount(),
        failure: failure,
      );
    }
  }

  /// Reparte los resultados del lote y devuelve cuántas operaciones salieron
  /// del outbox.
  Future<int> _reconcile(List<SyncOperation> batch, SyncPushResult result) async {
    final byOpId = {for (final item in result.results) item.opId: item};
    final applied = <String>[];
    final unanswered = <String>[];
    var settled = 0;

    for (final operation in batch) {
      final outcome = byOpId[operation.opId];
      if (outcome == null) {
        unanswered.add(operation.opId);
        continue;
      }

      if (outcome.outcome.isSettled) {
        applied.add(operation.opId);
      } else {
        // Rechazo o conflicto: nada se descarta en silencio (§8).
        // `moveToReview` ya la saca del outbox.
        await _local.moveToReview(operation, outcome);
      }

      // La fila espejo deja de estar protegida contra el pull. Sin esto se
      // quedaría `pending` para siempre y el feed nunca podría corregirla.
      await _mirrors[operation.entity]?.settle(
        operation.entityId,
        rejected: !outcome.outcome.isSettled,
      );
      settled++;
    }

    await _local.removeOperations(applied);
    await _local.recordAttempt(unanswered, 'El servidor no devolvió resultado para esta operación');
    return settled;
  }

  Future<String> _ensureDeviceId() async {
    final state = await _local.loadState();
    final existing = state.deviceId;
    if (existing != null) return existing;

    final deviceId = _uuid();
    await _local.updateState(SyncStateEntriesCompanion(deviceId: Value(deviceId)));
    return deviceId;
  }

  /// Cumple la orden de revocación: datos locales fuera y sesión cerrada (D11).
  Future<SyncProgress> _wipe() async {
    final newKey = await _storage.rotateDatabaseKey();
    await _local.wipe(newHexKey: newKey);
    await _storage.clearSession();
    return const SyncProgress(phase: SyncPhase.wiped);
  }
}

@Riverpod(keepAlive: true)
SyncRepository syncRepository(Ref ref) {
  return SyncRepository(
    local: ref.watch(syncLocalDataSourceProvider),
    remote: ref.watch(syncRemoteDataSourceProvider),
    storage: ref.watch(secureStorageProvider),
    mirrors: ref.watch(syncMirrorsProvider),
    device: DeviceDescriptor.current(),
  );
}
