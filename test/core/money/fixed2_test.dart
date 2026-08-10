import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/money/fixed2.dart';

void main() {
  group('parse', () {
    test('lee el texto que manda el servidor', () {
      expect(Fixed2.parse('2.50'), 250);
      expect(Fixed2.parse('108.75'), 10875);
      expect(Fixed2.parse('30'), 3000);
      expect(Fixed2.parse('0.05'), 5);
    });

    test('acepta la coma, que es lo que trae el teclado en español', () {
      expect(Fixed2.parse('12,5'), 1250);
    });

    test('tolera un campo a medio escribir', () {
      expect(Fixed2.parse('12.'), 1200);
      expect(Fixed2.parse('.5'), 50);
    });

    test('devuelve null en lo que no es un número', () {
      expect(Fixed2.parse(null), isNull);
      expect(Fixed2.parse(''), isNull);
      expect(Fixed2.parse('  '), isNull);
      expect(Fixed2.parse('doce'), isNull);
      expect(Fixed2.parse('1.2.3'), isNull);
    });

    test('trunca más allá del centavo en vez de redondear', () {
      // Nadie teclea milésimas queriendo; redondear ahí inventaría un centavo.
      expect(Fixed2.parse('1.999'), 199);
    });
  });

  group('format', () {
    test('siempre con dos decimales', () {
      expect(Fixed2.format(250), '2.50');
      expect(Fixed2.format(3000), '30.00');
      expect(Fixed2.format(5), '0.05');
      expect(Fixed2.format(0), '0.00');
    });

    test('ida y vuelta sin perder nada', () {
      for (final text in ['0.01', '2.50', '108.75', '9999.99']) {
        expect(Fixed2.format(Fixed2.parse(text)!), text);
      }
    });
  });

  group('multiply', () {
    test('cantidad entera', () {
      // 3 tinas grandes a Q30.00.
      expect(Fixed2.multiply(3000, 300), 9000);
    });

    test('cantidad con fracción: 12.5 lb a Q2.50', () {
      expect(Fixed2.multiply(250, 1250), 3125);
    });

    test('redondea al centavo alejándose del cero', () {
      // Q0.05 × 2.5 = 0.125 → 0.13, como redondearía una persona en papel.
      expect(Fixed2.multiply(5, 250), 13);
      // Q0.01 × 1.25 = 0.0125 → 0.01.
      expect(Fixed2.multiply(1, 125), 1);
    });

    test('no acumula el error de un double', () {
      // Cien líneas de Q0.10 dan exactamente Q10.00, no Q9.99…
      var total = 0;
      for (var i = 0; i < 100; i++) {
        total += Fixed2.multiply(10, 100);
      }
      expect(Fixed2.format(total), '10.00');
    });
  });
}
