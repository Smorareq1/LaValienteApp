import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/inventory/domain/supply_sale_pricing.dart';

/// Un lote de [quantity] unidades a [price] quetzales, ambos en centésimas.
LotStock lot(int number, {required int quantity, int? price}) => LotStock(
  lotId: 'lote-$number',
  lotNumber: number,
  quantityAvailable: quantity,
  salePrice: price,
);

void main() {
  group('reparto FIFO', () {
    test('sale del lote más viejo primero', () {
      final line = priceLine(
        productId: 'jabon',
        productName: 'Jabón',
        quantity: 200,
        lots: [
          lot(1, quantity: 500, price: 250),
          lot(2, quantity: 500, price: 300),
        ],
      );

      expect(line.allocations, hasLength(1));
      expect(line.allocations.single.lotNumber, 1);
      expect(line.amount, 500); // 2 × Q2.50
      expect(line.isShort, isFalse);
    });

    test('una línea que cruza dos lotes se cobra al precio de cada uno', () {
      // El lote viejo cubre 3 y el nuevo los otros 2: son dos precios, no un
      // promedio. Es la razón de que el reparto exista.
      final line = priceLine(
        productId: 'jabon',
        productName: 'Jabón',
        quantity: 500,
        lots: [
          lot(1, quantity: 300, price: 250),
          lot(2, quantity: 400, price: 300),
        ],
      );

      expect(line.allocations.map((a) => a.lotNumber), [1, 2]);
      expect(line.spansLots, isTrue);
      expect(line.amount, 750 + 600);
      // La tarjeta muestra el precio de la primera porción, que es el que
      // pagaría la siguiente unidad.
      expect(line.unitPrice, 250);
    });

    test('un lote sin precio de venta se salta, no se vende a cero', () {
      // Es el consumo interno de la lavandería (§5.2). Venderlo a cero sería
      // regalar el inventario propio sin que nadie lo decidiera.
      final line = priceLine(
        productId: 'jabon',
        productName: 'Jabón',
        quantity: 200,
        lots: [
          lot(1, quantity: 1000, price: null),
          lot(2, quantity: 500, price: 300),
        ],
      );

      expect(line.available, 500);
      expect(line.allocations.single.lotNumber, 2);
      expect(line.amount, 600);
    });

    test('pedir más de lo que hay avisa pero no se niega', () {
      // La diferencia deliberada con el backend: el inventario de este teléfono
      // puede llevar horas de retraso y quien tiene el bote en la mano sabe más
      // (plan 0005 D12).
      final line = priceLine(
        productId: 'jabon',
        productName: 'Jabón',
        quantity: 500,
        lots: [lot(1, quantity: 200, price: 250)],
      );

      expect(line.isShort, isTrue);
      expect(line.available, 200);
      // Lo que no alcanzó se valúa al último precio conocido, para que el total
      // de la pantalla no quede corto respecto de lo que el cliente va a pagar.
      expect(line.amount, 1250);
    });

    test('sin ningún lote vendible no hay precio que inventar', () {
      final line = priceLine(
        productId: 'jabon',
        productName: 'Jabón',
        quantity: 200,
        lots: const [],
      );

      expect(line.isShort, isTrue);
      expect(line.allocations, isEmpty);
      expect(line.amount, 0);
      expect(line.unitPrice, 0);
    });
  });

  group('total de la venta', () {
    test('suma las líneas ya redondeadas, no los productos exactos', () {
      // Q0.33 × 3 = Q0.99 por línea. Sumar los productos exactos daría lo mismo
      // aquí, pero la regla es la del backend: se redondea por línea y después
      // se suma, para que las líneas impresas cuadren con el total impreso.
      final lines = [
        priceLine(
          productId: 'a',
          productName: 'A',
          quantity: 300,
          lots: [lot(1, quantity: 1000, price: 33)],
        ),
        priceLine(
          productId: 'b',
          productName: 'B',
          quantity: 300,
          lots: [lot(1, quantity: 1000, price: 33)],
        ),
      ];

      final sale = priceSale(lines);
      expect(lines.first.amount, 99);
      expect(sale.total, 198);
      expect(sale.canSave, isTrue);
      expect(sale.hasShortages, isFalse);
    });

    test('una venta vacía no se puede guardar', () {
      const sale = PricedSale.empty();
      expect(sale.canSave, isFalse);
      expect(sale.isEmpty, isTrue);
    });

    test('la venta avisa si alguna línea pasa del stock contado', () {
      final sale = priceSale([
        priceLine(
          productId: 'a',
          productName: 'A',
          quantity: 300,
          lots: [lot(1, quantity: 1000, price: 100)],
        ),
        priceLine(
          productId: 'b',
          productName: 'B',
          quantity: 300,
          lots: [lot(1, quantity: 100, price: 100)],
        ),
      ]);

      expect(sale.hasShortages, isTrue);
      // Sigue siendo guardable: el aviso no bloquea.
      expect(sale.canSave, isTrue);
    });
  });
}
