import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/diagnostics/app_log.dart';
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
  StreamSubscription<int>? _outbox;
  Future<void>? _inFlight;

  /// Cuántas operaciones esperaban la última vez que se miró el outbox.
  int? _pending;

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

    _periodic = Timer.periodic(
      kSyncPeriodicInterval,
      (_) => unawaited(sync(reason: 'periódico')),
    );
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(sync(reason: 'app al frente')),
    );
    _outbox = ref.read(syncRepositoryProvider).watchPendingCount().listen(_onOutboxChanged);

    // La suscripción muere con el provider, así que no hace falta guardarla.
    ref.listen(connectivityChangesProvider, (_, next) {
      if (next.valueOrNull ?? false) unawaited(sync(reason: 'volvió la red'));
    });

    scheduleMicrotask(() => unawaited(sync(reason: 'arranque')));
    return const SyncEngineState();
  }

  /// Pide un ciclo. Si ya hay uno corriendo, devuelve ese mismo.
  ///
  /// [reason] solo va al log. Está porque los cuatro disparadores del §5 se ven
  /// idénticos desde afuera, y saber cuál mandó el ciclo es la diferencia entre
  /// "sincroniza cuando toca" y "algo lo está llamando cada dos segundos".
  Future<void> sync({String reason = 'a mano'}) {
    if (_inFlight != null) {
      appLog('sync', 'ciclo pedido ($reason) — ya hay uno en vuelo, se engancha');
      return _inFlight!;
    }
    appLog('sync', 'ciclo arranca ($reason)');
    return _inFlight = _runCycle().whenComplete(() => _inFlight = null);
  }

  /// Pide un ciclo tras una captura local, agrupando ráfagas de ediciones.
  void syncSoon() {
    _debounce?.cancel();
    _debounce = Timer(
      kSyncMutationDebounce,
      () => unawaited(sync(reason: 'captura local')),
    );
  }

  /// El outbox cambió de tamaño: si creció, alguien acaba de capturar algo.
  ///
  /// Este es el disparador de **mutación local** del §5, y se implementa
  /// mirando la cola en vez de esperar que cada repositorio avise por dos
  /// razones. La primera es de capas: las dependencias de un módulo apuntan
  /// hacia adentro (UI → State → Data), así que un repositorio no puede llamar
  /// al motor sin invertir esa flecha. La segunda es que mirar la cola no se
  /// puede olvidar, y avisar sí: mientras el aviso fue responsabilidad de quien
  /// capturaba, ningún repositorio lo dio nunca y toda captura esperó los dos
  /// minutos del periódico para salir del mostrador.
  ///
  /// La cuenta la publica drift al **confirmar** la transacción, así que cuando
  /// esto corre la fila espejo y su operación ya están las dos en disco.
  void _onOutboxChanged(int pending) {
    final before = _pending;
    _pending = pending;

    // Solo cuando crece. Que baje es el propio push sacando lo que ya subió, y
    // la primera lectura es el arranque, que tiene su ciclo al final de `build`.
    if (before == null || pending <= before) return;

    // Si el motor viene de fallar manda el backoff. Seguir capturando durante
    // un corte no es razón para volver a golpear al servidor cada dos segundos:
    // el reintento ya está agendado y estas operaciones saldrán en él.
    if (state.nextAttemptAt != null) return;

    syncSoon();
  }

  Future<void> _runCycle() async {
    _retry?.cancel();
    state = state.copyWith(clearNextAttempt: true);

    await for (final progress in ref.read(syncRepositoryProvider).runCycle()) {
      state = state.copyWith(progress: progress);

      switch (progress.phase) {
        case SyncPhase.done:
          appLog(
            'sync',
            'ciclo ok · subidas ${progress.pushed} · bajadas ${progress.pulled} '
            '· quedan ${progress.remaining}',
          );
          _backoff.reset();
          state = state.copyWith(
            lastSyncedAt: DateTime.now(),
            consecutiveFailures: 0,
            clearNextAttempt: true,
          );
        case SyncPhase.failed:
          appLog(
            'sync',
            'ciclo FALLÓ · ${progress.failure?.runtimeType} '
            '· ${progress.failure?.message}',
          );
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
    appLog('sync', 'reintento en ${delay.inSeconds}s (fallo ${_backoff.failures})');
    _retry?.cancel();
    _retry = Timer(delay, () => unawaited(sync(reason: 'reintento')));
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
    unawaited(_outbox?.cancel());
    _periodic = null;
    _retry = null;
    _debounce = null;
    _lifecycle = null;
    _outbox = null;
    // Se olvida la cuenta: al volver a arrancar, la primera lectura del outbox
    // vuelve a ser el arranque y no una captura.
    _pending = null;
  }
}
