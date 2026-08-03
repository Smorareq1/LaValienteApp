import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/connectivity.dart';
import '../../auth/state/auth_controller.dart';
import '../data/sync_repository.dart';
import '../models/sync_progress.dart';
import '../service/sync_backoff.dart';

part 'sync_engine.g.dart';

/// Cada cuánto se sincroniza sin que pase nada más.
const Duration kSyncPeriodicInterval = Duration(minutes: 2);

/// Espera tras una captura local antes de subirla, para que una ráfaga de
/// ediciones se vaya en un solo ciclo.
const Duration kSyncMutationDebounce = Duration(seconds: 2);

/// Estado del motor de sincronización.
class SyncEngineState {
  const SyncEngineState({
    this.progress = const SyncProgress.idle(),
    this.lastSyncedAt,
    this.nextAttemptAt,
    this.consecutiveFailures = 0,
  });

  final SyncProgress progress;

  /// Último ciclo que terminó bien.
  final DateTime? lastSyncedAt;

  /// Cuándo volverá a intentarlo tras un fallo.
  final DateTime? nextAttemptAt;

  final int consecutiveFailures;

  SyncEngineState copyWith({
    SyncProgress? progress,
    DateTime? lastSyncedAt,
    DateTime? nextAttemptAt,
    bool clearNextAttempt = false,
    int? consecutiveFailures,
  }) {
    return SyncEngineState(
      progress: progress ?? this.progress,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      nextAttemptAt: clearNextAttempt ? null : (nextAttemptAt ?? this.nextAttemptAt),
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
    );
  }
}

/// Decide **cuándo** sincronizar. El *cómo* vive en [SyncRepository].
///
/// Dispara con los cuatro eventos del plan (§5): recuperar conectividad, app a
/// primer plano, mutación local (con debounce) y un periódico de red. Nunca
/// corre dos ciclos a la vez: el segundo se engancha al que ya está en vuelo,
/// porque dos push simultáneos del mismo outbox mandarían las mismas
/// operaciones dos veces.
@Riverpod(keepAlive: true)
class SyncEngine extends _$SyncEngine {
  final SyncBackoff _backoff = SyncBackoff();

  Timer? _periodic;
  Timer? _retry;
  Timer? _debounce;
  AppLifecycleListener? _lifecycle;
  Future<void>? _inFlight;

  @override
  SyncEngineState build() {
    ref.onDispose(_stopTriggers);

    // Sin sesión no hay contra qué sincronizar, y el interceptor de auth
    // rebotaría cada llamada.
    final session = ref.watch(authControllerProvider).valueOrNull;
    if (session == null) {
      _stopTriggers();
      return const SyncEngineState();
    }

    _periodic = Timer.periodic(kSyncPeriodicInterval, (_) => unawaited(sync()));
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(sync()));

    // La suscripción muere con el provider, así que no hace falta guardarla.
    ref.listen(connectivityChangesProvider, (_, next) {
      if (next.valueOrNull ?? false) unawaited(sync());
    });

    scheduleMicrotask(() => unawaited(sync()));
    return const SyncEngineState();
  }

  /// Pide un ciclo. Si ya hay uno corriendo, devuelve ese mismo.
  Future<void> sync() {
    return _inFlight ??= _runCycle().whenComplete(() => _inFlight = null);
  }

  /// Registra una captura local y programa su subida.
  ///
  /// Es la puerta por la que entra todo lo que la app escribe: la UI no habla
  /// con el repositorio de sync, encola aquí y sigue trabajando.
  Future<void> capture({
    required String entity,
    required String opType,
    required String entityId,
    required Map<String, dynamic> payload,
    int? baseVersion,
  }) async {
    await ref
        .read(syncRepositoryProvider)
        .enqueue(
          entity: entity,
          opType: opType,
          entityId: entityId,
          payload: payload,
          baseVersion: baseVersion,
        );
    syncSoon();
  }

  /// Pide un ciclo tras una captura local, agrupando ráfagas de ediciones.
  void syncSoon() {
    _debounce?.cancel();
    _debounce = Timer(kSyncMutationDebounce, () => unawaited(sync()));
  }

  Future<void> _runCycle() async {
    _retry?.cancel();
    state = state.copyWith(clearNextAttempt: true);

    await for (final progress in ref.read(syncRepositoryProvider).runCycle()) {
      state = state.copyWith(progress: progress);

      switch (progress.phase) {
        case SyncPhase.done:
          _backoff.reset();
          state = state.copyWith(
            lastSyncedAt: DateTime.now(),
            consecutiveFailures: 0,
            clearNextAttempt: true,
          );
        case SyncPhase.failed:
          _scheduleRetry();
        case SyncPhase.wiped:
          // El dispositivo dejó de estar autorizado: se apagan los
          // disparadores y la sesión cerrada se lleva al usuario al login.
          _stopTriggers();
          await ref.read(authControllerProvider.notifier).logout();
        default:
          break;
      }
    }
  }

  void _scheduleRetry() {
    final delay = _backoff.nextDelay();
    _retry?.cancel();
    _retry = Timer(delay, () => unawaited(sync()));
    state = state.copyWith(
      nextAttemptAt: DateTime.now().add(delay),
      consecutiveFailures: _backoff.failures,
    );
  }

  void _stopTriggers() {
    _periodic?.cancel();
    _retry?.cancel();
    _debounce?.cancel();
    _lifecycle?.dispose();
    _periodic = null;
    _retry = null;
    _debounce = null;
    _lifecycle = null;
  }
}
