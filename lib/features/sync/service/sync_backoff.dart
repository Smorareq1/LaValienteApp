import 'dart:math';

/// Espera creciente entre ciclos fallidos (plan 0004 §5).
///
/// El jitter no es adorno: sin él, veinte tabletas que pierden el wifi a la
/// vez lo recuperan a la vez y le caen al servidor en el mismo instante, una y
/// otra vez.
class SyncBackoff {
  SyncBackoff({
    this.base = const Duration(seconds: 5),
    this.ceiling = const Duration(minutes: 5),
    Random? random,
  }) : _random = random ?? Random();

  final Duration base;
  final Duration ceiling;
  final Random _random;

  int _failures = 0;

  /// Fallos consecutivos desde el último ciclo exitoso.
  int get failures => _failures;

  /// Registra un fallo y devuelve cuánto esperar antes del siguiente intento.
  Duration nextDelay() {
    final exponent = min(_failures, 16);
    final grown = base * pow(2, exponent).toDouble();
    final capped = grown > ceiling ? ceiling : grown;
    _failures++;

    // ±25 % para desalinear dispositivos que fallaron al mismo tiempo.
    final jitter = 1 + (_random.nextDouble() - 0.5) / 2;
    return Duration(microseconds: (capped.inMicroseconds * jitter).round());
  }

  void reset() => _failures = 0;
}
