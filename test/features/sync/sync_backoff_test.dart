import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/sync/service/sync_backoff.dart';

/// Random fijo en el centro del rango: deja el jitter en 1.0 y hace
/// comprobables las esperas.
class _NoJitter implements Random {
  @override
  double nextDouble() => 0.5;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

void main() {
  test('la espera se duplica en cada fallo y se detiene en el techo', () {
    final backoff = SyncBackoff(
      base: const Duration(seconds: 5),
      ceiling: const Duration(minutes: 1),
      random: _NoJitter(),
    );

    expect(backoff.nextDelay(), const Duration(seconds: 5));
    expect(backoff.nextDelay(), const Duration(seconds: 10));
    expect(backoff.nextDelay(), const Duration(seconds: 20));
    expect(backoff.nextDelay(), const Duration(seconds: 40));
    expect(backoff.nextDelay(), const Duration(minutes: 1));
    expect(backoff.nextDelay(), const Duration(minutes: 1), reason: 'no crece más allá del techo');
    expect(backoff.failures, 6);
  });

  test('un ciclo exitoso devuelve la espera al principio', () {
    final backoff = SyncBackoff(random: _NoJitter());
    backoff.nextDelay();
    backoff.nextDelay();

    backoff.reset();

    expect(backoff.failures, 0);
    expect(backoff.nextDelay(), const Duration(seconds: 5));
  });

  test('el jitter mantiene la espera dentro de ±25 %', () {
    final backoff = SyncBackoff(base: const Duration(seconds: 100), random: Random(7));

    for (var i = 0; i < 20; i++) {
      final delay = backoff.nextDelay();
      final nominal = min(100 * (1 << i), backoff.ceiling.inSeconds) * 1000;
      expect(delay.inMilliseconds, greaterThanOrEqualTo((nominal * 0.75).floor()));
      expect(delay.inMilliseconds, lessThanOrEqualTo((nominal * 1.25).ceil()));
    }
  });
}
