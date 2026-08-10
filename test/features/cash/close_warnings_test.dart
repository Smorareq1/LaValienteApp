import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/cash/domain/close_warnings.dart';

/// Las advertencias del cierre (plan 0006 §7.4). El servidor manda códigos
/// porque es el único que puede contarlas; la frase es de la app porque es la
/// que habla español.
void main() {
  List<String> messagesOf(List<String> codes, {int unsynced = 0}) => [
    for (final warning in closeWarnings(codes: codes, unsyncedCaptures: unsynced))
      warning.message,
  ];

  group('traducción de códigos', () {
    test('un día sin nada que decir no dice nada', () {
      expect(closeWarnings(codes: const []), isEmpty);
    });

    test('las boletas sin entregar se cuentan y se concuerdan en singular', () {
      expect(
        messagesOf(const ['open_tickets:1']),
        ['Una boleta del día sigue sin entregarse.'],
      );
      expect(
        messagesOf(const ['open_tickets:3']),
        ['3 boletas del día siguen sin entregarse.'],
      );
    });

    test('el dinero llega como texto del servidor y sale como quetzales', () {
      expect(
        messagesOf(const ['uncollected:120.50']),
        contains(startsWith('Quedan Q120.50 sin cobrar')),
      );
    });

    test('el gasto pendiente explica por qué no cuadra con el arqueo', () {
      final message = messagesOf(const ['pending_expenses:80.00']).single;

      expect(message, contains('Q80.00'));
      expect(message, contains('no salieron del cajón'));
    });

    test('reabrir obliga a volver a cerrar, y eso pesa', () {
      final warning = closeWarnings(codes: const ['reopened']).single;

      expect(warning.message, contains('cerrarlo otra vez'));
      expect(warning.tone, CloseWarningTone.serious);
    });
  });

  group('capturas sin subir', () {
    test('encabezan la lista: son las que cambian las cifras del acta', () {
      final warnings = closeWarnings(
        codes: const ['open_tickets:2'],
        unsyncedCaptures: 3,
      );

      expect(warnings.first.message, startsWith('3 capturas de este dispositivo'));
      expect(warnings.first.tone, CloseWarningTone.serious);
      expect(warnings.length, 2);
    });

    test('sin nada en el outbox no se inventa el aviso', () {
      expect(messagesOf(const [], unsynced: 0), isEmpty);
    });
  });

  test('un código que esta versión no conoce se muestra igual', () {
    // Descartarlo en silencio haría desaparecer algo que valía la pena leer
    // antes de firmar, solo porque el teléfono tiene una app vieja.
    expect(
      messagesOf(const ['something_new:7']),
      ['El servidor marcó algo más para revisar (something_new:7).'],
    );
  });
}
