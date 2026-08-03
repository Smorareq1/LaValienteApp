import '../../../core/errors/app_failure.dart';

/// Etapa del ciclo de sincronización (plan 0004 §5: push → pull → reconciliar).
enum SyncPhase {
  idle,

  /// Primer contacto: el dispositivo se da de alta en el servidor.
  registering,

  /// Subiendo el outbox.
  pushing,

  /// Bajando el feed de cambios.
  pulling,

  /// Descarga inicial completa de un dispositivo nuevo (§7.2).
  bootstrapping,

  done,
  failed,

  /// El servidor revocó este dispositivo y ordenó borrar los datos locales.
  wiped,
}

/// Paso del ciclo, tal como lo emite el repositorio para que la UI lo muestre
/// (regla §11 de ARCHITECTURE.md: procesos largos reportan progreso por Stream).
class SyncProgress {
  const SyncProgress({
    required this.phase,
    this.pushed = 0,
    this.pulled = 0,
    this.remaining = 0,
    this.failure,
  });

  const SyncProgress.idle() : this(phase: SyncPhase.idle);

  final SyncPhase phase;

  /// Operaciones del outbox ya confirmadas por el servidor en este ciclo.
  final int pushed;

  /// Cambios aplicados desde el feed en este ciclo.
  final int pulled;

  /// Operaciones que siguen esperando en el outbox.
  final int remaining;

  final AppFailure? failure;

  bool get isRunning =>
      phase != SyncPhase.idle &&
      phase != SyncPhase.done &&
      phase != SyncPhase.failed &&
      phase != SyncPhase.wiped;
}
