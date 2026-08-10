import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/scan/models/scan.dart';

/// Cómo llega el borrador del servidor y qué hace la app con él.
///
/// El JSON de estas pruebas es literalmente el que produce
/// `intake_scan/schemas.py`: si los dos lados se separan, esto es lo que lo dice.
Map<String, dynamic> _field(
  Object? value, {
  double confidence = 0.95,
  bool needsReview = false,
  String? raw,
}) => {
  'value': value,
  'confidence': confidence,
  'raw_text': raw,
  'needs_review': needsReview,
};

Map<String, dynamic> _draft({
  List<Map<String, dynamic>> garments = const [],
  List<Map<String, dynamic>> charges = const [],
  Map<String, dynamic>? match,
}) => {
  'order_date': _field('2026-08-08'),
  'daily_number': _field(41),
  'booklet_serial': _field('A-4410'),
  'nit': _field('CF'),
  'weight_lbs': _field('12.50'),
  'observations': _field(null, confidence: 0),
  'customer_name': _field('María López'),
  'customer_phone': _field('55123456'),
  'customer_address': _field(null, confidence: 0),
  'customer_match': match,
  'garments': garments,
  'charges': charges,
  'estimated_subtotal': '98.75',
  'estimated_total': '98.75',
  'total_read': '108.75',
};

void main() {
  group('el borrador', () {
    test('el dinero y el peso llegan a centésimas como el resto de la app', () {
      final draft = ScanDraft.fromJson(_draft());

      expect(draft.weightLbs.value, 1250);
      expect(draft.estimatedTotal, 9875);
      expect(draft.totalRead, 10875);
    });

    test('la cantidad de una línea también', () {
      // El servidor manda «12.5» libras y los steppers cuentan centésimas.
      final draft = ScanDraft.fromJson(
        _draft(
          charges: [
            {
              'service_code': 'wash_by_weight',
              'option_code': null,
              'quantity': '12.5',
              'amount': null,
              'description': 'Lavado por peso',
              'confidence': 0.9,
              'needs_review': false,
            },
          ],
        ),
      );

      expect(draft.charges.single.quantity, 1250);
    });

    test('cuenta los campos dudosos, que es lo único que hay que hacer', () {
      final draft = ScanDraft.fromJson(
        _draft(
          garments: [
            {
              'garment_type_id': 'g1',
              'name': 'Camisa',
              'quantity': 3,
              'confidence': 0.6,
              'needs_review': true,
            },
          ],
        )..['booklet_serial'] = _field('A-4410', confidence: 0.6, needsReview: true),
      );

      expect(draft.reviewCount, 2);
    });

    test('un borrador sin nada aprovechable se reconoce', () {
      // La pantalla lo trata como un fallo: mejor volver a fotografiar que
      // abrir una boleta en blanco que parecía llena.
      final empty = ScanDraft.fromJson({
        'customer_name': _field(null, confidence: 0),
        'garments': <Map<String, dynamic>>[],
        'charges': <Map<String, dynamic>>[],
      });

      expect(empty.isEmpty, isTrue);
    });
  });

  group('la sugerencia de cliente', () {
    test('un acierto por teléfono se distingue de uno por nombre', () {
      // El teléfono es el único identificador real de la boleta: dos personas
      // comparten nombre, nadie comparte número.
      final byPhone = ScanDraft.fromJson(
        _draft(
          match: {
            'customer_id': 'c1',
            'full_name': 'María López',
            'phone': '55123456',
            'score': 1.0,
            'matched_on': 'phone',
          },
        ),
      );
      final byName = ScanDraft.fromJson(
        _draft(
          match: {
            'customer_id': 'c1',
            'full_name': 'María López',
            'phone': null,
            'score': 0.9,
            'matched_on': 'name',
          },
        ),
      );

      expect(byPhone.customerMatch!.isExact, isTrue);
      expect(byName.customerMatch!.isExact, isFalse);
    });

    test('sin coincidencia no se inventa ninguna', () {
      expect(ScanDraft.fromJson(_draft()).customerMatch, isNull);
    });
  });

  group('la respuesta', () {
    test('un escaneo completo trae borrador', () {
      final result = ScanResult.fromJson({
        'id': 's1',
        'status': 'completed',
        'draft': _draft(),
        'warnings': ['total_mismatch:108.75:98.75'],
        'latency_ms': 2400,
      });

      expect(result.isCompleted, isTrue);
      expect(result.warnings, hasLength(1));
    });

    test('uno fallido no', () {
      final result = ScanResult.fromJson({
        'id': 's1',
        'status': 'failed',
        'draft': null,
        'error': 'The scan provider could not be reached.',
      });

      expect(result.isCompleted, isFalse);
      expect(result.error, isNotNull);
    });
  });
}
