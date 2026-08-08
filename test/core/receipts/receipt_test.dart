import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/receipts/receipt.dart';

void main() {
  group('comprobante de pedido', () {
    test('un pedido pagado por completo no habla de saldo', () {
      final text = orderReceipt(
        reference: 'No. 42',
        total: 8500,
        paid: 8500,
        date: '8 ago 2026',
      );

      expect(text, contains('Total: Q85.00'));
      expect(text, contains('Pagado por completo'));
      expect(text, isNot(contains('Saldo')));
    });

    test('con anticipo se dicen las tres cifras', () {
      // Es el caso que genera reclamos: el cliente tiene que poder leer qué
      // dejó y qué debe sin hacer la resta.
      final text = orderReceipt(
        reference: 'No. 42',
        total: 8500,
        paid: 3000,
        date: '8 ago 2026',
      );

      expect(text, contains('Total: Q85.00'));
      expect(text, contains('Anticipo: Q30.00'));
      expect(text, contains('Saldo pendiente: Q55.00'));
    });

    test('un folio provisional avisa de que puede cambiar', () {
      // Callarlo haría que alguien apuntara el provisional en la boleta de
      // papel como si fuera el definitivo.
      final text = orderReceipt(
        reference: 'P-1',
        total: 5000,
        paid: 0,
        date: '8 ago 2026',
        pendingSync: true,
      );

      expect(text, contains('provisional'));
    });

    test('sin anticipo no se imprime una línea de cero', () {
      final text = orderReceipt(
        reference: 'No. 7',
        total: 5000,
        paid: 0,
        date: '8 ago 2026',
      );

      expect(text, isNot(contains('Anticipo')));
      expect(text, contains('Saldo pendiente: Q50.00'));
    });
  });

  group('comprobante de venta', () {
    test('cada línea lleva cantidad, producto y monto', () {
      final text = supplySaleReceipt(
        total: 5000,
        date: '8 ago 2026',
        method: 'Efectivo',
        items: [
          (name: 'Jabón en polvo', quantity: 200, amount: 5000),
        ],
      );

      expect(text, contains('2 × Jabón en polvo — Q50.00'));
      expect(text, contains('Total: Q50.00'));
      expect(text, contains('Pago: Efectivo'));
    });

    test('una venta de mostrador no inventa un cliente', () {
      final text = supplySaleReceipt(
        total: 2500,
        date: '8 ago 2026',
        items: [(name: 'Suavizante', quantity: 100, amount: 2500)],
      );

      expect(text, isNot(contains('Cliente')));
    });
  });
}
