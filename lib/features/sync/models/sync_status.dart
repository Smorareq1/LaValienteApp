/// Estados del indicador global de sincronización (Plan 0006 §11.1).
enum SyncState {
  /// ✓ todo subido.
  synced,

  /// ⟳ subiendo en este momento.
  syncing,

  /// N operaciones esperando conexión.
  pending,

  /// ! operaciones rechazadas o en conflicto que necesitan una decisión.
  needsReview,
}

/// Estado de la cola de sincronización que se muestra en el AppBar del shell.
class SyncStatus {
  const SyncStatus({
    required this.state,
    this.pendingCount = 0,
    this.reviewCount = 0,
    this.lastSyncedAt,
  });

  /// Nada pendiente ni en revisión.
  const SyncStatus.synced() : this(state: SyncState.synced);

  final SyncState state;

  /// Operaciones pendientes de subir.
  final int pendingCount;

  /// Operaciones en la cola de revisión (`/sync/review`).
  final int reviewCount;

  final DateTime? lastSyncedAt;

  bool get hasReview => reviewCount > 0;
}
