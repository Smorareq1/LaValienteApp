import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/sync/models/sync_operation.dart';

SyncOperation _operation({DateTime? createdAt, int? baseVersion}) {
  return SyncOperation(
    seq: 1,
    opId: 'op-1',
    entity: 'customer',
    opType: 'create',
    entityId: 'c1',
    baseVersion: baseVersion,
    payload: const {'full_name': 'Ana'},
    createdAt: createdAt ?? DateTime.now(),
  );
}

void main() {
  group('formato de cable', () {
    test('client_ts viaja en UTC', () {
      // Una fecha local serializada tal cual no lleva offset, y el servidor no
      // puede situarla en el tiempo: al medir el desfase de reloj reventaba el
      // push entero con un 500.
      final wire = _operation(createdAt: DateTime.utc(2026, 8, 1, 18, 30).toLocal()).toWire();

      expect(wire['client_ts'], endsWith('Z'));
      expect(DateTime.parse(wire['client_ts'] as String).isUtc, isTrue);
      expect(DateTime.parse(wire['client_ts'] as String), DateTime.utc(2026, 8, 1, 18, 30));
    });

    test('base_version se omite en las creaciones', () {
      expect(_operation().toWire().containsKey('base_version'), isFalse);
      expect(_operation(baseVersion: 3).toWire()['base_version'], 3);
    });

    test('los nombres de campo son los que espera el backend', () {
      expect(
        _operation().toWire().keys,
        containsAll(['op_id', 'seq', 'entity', 'op_type', 'entity_id', 'payload', 'client_ts']),
      );
    });
  });

  group('veredicto del servidor', () {
    test('applied y already_applied cierran la operación', () {
      expect(SyncOperationOutcome.fromWire('applied').isSettled, isTrue);
      expect(SyncOperationOutcome.fromWire('already_applied').isSettled, isTrue);
    });

    test('rejected y conflict mandan a revisión', () {
      expect(SyncOperationOutcome.fromWire('rejected').needsReview, isTrue);
      expect(SyncOperationOutcome.fromWire('conflict').needsReview, isTrue);
    });

    test('un estado desconocido no se interpreta como éxito', () {
      expect(() => SyncOperationOutcome.fromWire('quien_sabe'), throwsFormatException);
    });
  });
}
