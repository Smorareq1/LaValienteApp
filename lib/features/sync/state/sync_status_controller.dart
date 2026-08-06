import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/sync_repository.dart';
import '../models/sync_details.dart';
import '../models/sync_status.dart';
import 'sync_engine.dart';

part 'sync_status_controller.g.dart';

/// Diagnóstico del motor para la pantalla de Sincronización.
@Riverpod(keepAlive: true)
Stream<SyncDetails> syncDetails(Ref ref) {
  return ref.watch(syncRepositoryProvider).watchDetails();
}

/// Operaciones esperando en el outbox, en vivo desde la BD local.
@Riverpod(keepAlive: true)
Stream<int> pendingOperationsCount(Ref ref) {
  return ref.watch(syncRepositoryProvider).watchPendingCount();
}

/// Lo que espera subir, desglosado por entidad (§11.1).
@Riverpod(keepAlive: true)
Stream<Map<String, int>> pendingByEntity(Ref ref) {
  return ref.watch(syncRepositoryProvider).watchPendingByEntity();
}

/// Capturas que el servidor rechazó y esperan una decisión humana (§8).
@Riverpod(keepAlive: true)
Stream<int> reviewQueueCount(Ref ref) {
  return ref.watch(syncRepositoryProvider).watchReviewCount();
}

/// Estado de la cola de sincronización que consume el AppBar del shell.
///
/// Compone tres fuentes: la fase del motor, el outbox y la cola de revisión.
/// El orden de prioridad no es estético — lo que necesita una decisión humana
/// tapa a lo que solo necesita esperar.
@Riverpod(keepAlive: true)
class SyncStatusController extends _$SyncStatusController {
  @override
  SyncStatus build() {
    final engine = ref.watch(syncEngineProvider);
    final pending = ref.watch(pendingOperationsCountProvider).valueOrNull ?? 0;
    final review = ref.watch(reviewQueueCountProvider).valueOrNull ?? 0;

    final SyncState state;
    if (review > 0) {
      state = SyncState.needsReview;
    } else if (engine.progress.isRunning) {
      state = SyncState.syncing;
    } else if (pending > 0) {
      state = SyncState.pending;
    } else {
      state = SyncState.synced;
    }

    return SyncStatus(
      state: state,
      pendingCount: pending,
      reviewCount: review,
      lastSyncedAt: engine.lastSyncedAt,
    );
  }

  /// Fuerza un ciclo. Lo usa el botón "Sincronizar ahora".
  Future<void> syncNow() => ref.read(syncEngineProvider.notifier).sync();
}
