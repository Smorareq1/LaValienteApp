/// Estados del indicador global de sincronización (Plan 0006 §11.1).
enum SyncState {
  /// ✓ todo subido.
  synced,

  /// ⟳ subiendo en este momento.
  syncing,

  /// N operaciones esperando conexión.
  pending,

  /// El último ciclo se cayó y hay un reintento agendado.
  ///
  /// Estado propio y no un caso de [pending] porque son cosas distintas: en
  /// `pending` el motor funciona y la cola avanza sola, y aquí no avanza. Sin
  /// esta distinción un ciclo que falla con el outbox vacío caía en [synced] y
  /// el AppBar ponía el ✓ de "todo sincronizado" justo cuando nada se estaba
  /// sincronizando.
  failed,

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
    this.failureMessage,
  });

  /// Nada pendiente ni en revisión.
  const SyncStatus.synced() : this(state: SyncState.synced);

  final SyncState state;

  /// Operaciones pendientes de subir.
  final int pendingCount;

  /// Operaciones en la cola de revisión (`/sync/review`).
  final int reviewCount;

  final DateTime? lastSyncedAt;

  /// Por qué se cayó el último ciclo, ya en español. Solo con [SyncState.failed].
  ///
  /// Se arrastra hasta aquí para que la pantalla pueda decir *qué* falló en vez
  /// de suponerlo: que no se alcanzara al servidor y que el servidor no
  /// contestara a tiempo piden cosas distintas de quien lo lee.
  final String? failureMessage;

  bool get hasReview => reviewCount > 0;
}
