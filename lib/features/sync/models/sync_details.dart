/// Diagnóstico del motor de sincronización, para la pantalla de Sincronización.
///
/// Es lo que alguien necesita ver cuando algo "no se está subiendo": desde
/// cuándo, con qué error y si el reloj del equipo tiene la culpa (§9, §11).
class SyncDetails {
  const SyncDetails({
    this.deviceId,
    this.pullCursor = 0,
    this.bootstrapCompleted = false,
    this.lastCycleAt,
    this.lastPushAt,
    this.lastPullAt,
    this.lastError,
    this.clockSkew,
  });

  final String? deviceId;
  final int pullCursor;
  final bool bootstrapCompleted;
  final DateTime? lastCycleAt;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;
  final String? lastError;

  /// Diferencia entre el reloj del equipo y el del servidor.
  final Duration? clockSkew;
}
