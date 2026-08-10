import '../../../core/money/fixed2.dart';

/// Lo que la vista previa necesita saber de un lote.
///
/// Copia plana de la fila espejo: la aritmética no puede cambiar el stock como
/// efecto de leerlo.
class LotStock {
  const LotStock({
    required this.lotId,
    required this.lotNumber,
    required this.quantityAvailable,
    this.salePrice,
  });

  final String lotId;
  final int lotNumber;

  /// En centésimas, como todo lo que admite dos decimales.
  final int quantityAvailable;

  /// `null` marca un lote que la lavandería guarda para su propio consumo. El
  /// FIFO lo **salta**, no lo vende a cero (plan 0005 §5.2).
  final int? salePrice;

  bool get isSellable => salePrice != null && quantityAvailable > 0;
}

/// La parte de una línea que cubre un lote, al precio de ese lote.
class SaleAllocation {
  const SaleAllocation({
    required this.lotNumber,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  final int lotNumber;
  final int quantity;
  final int unitPrice;
  final int amount;
}

/// Una línea valuada: cuánto se cobraría y si el stock del dispositivo alcanza.
class PricedSaleLine {
  const PricedSaleLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.allocations,
    required this.amount,
    required this.available,
  });

  final String productId;
  final String productName;
  final int quantity;
  final List<SaleAllocation> allocations;

  /// Σ de las porciones, cada una redondeada antes de sumar.
  final int amount;

  /// Lo que el dispositivo cree que queda vendible.
  final int available;

  /// El stock local no alcanza. **No bloquea**: el dispositivo puede llevar
  /// horas sin señal y otro pudo recibir un lote (plan 0005 D12). Se avisa, se
  /// vende, y el servidor rechaza si de verdad no había.
  bool get isShort => quantity > available;

  /// La línea cruza dos lotes comprados a precios distintos, así que el precio
  /// unitario no es uno solo.
  bool get spansLots => allocations.length > 1;

  /// El precio de la primera porción, que es el que la tarjeta muestra.
  int get unitPrice => allocations.isEmpty ? 0 : allocations.first.unitPrice;
}

/// La venta entera, tal como se lee en el footer antes de guardarla.
class PricedSale {
  const PricedSale({required this.lines, required this.total});

  const PricedSale.empty() : lines = const [], total = 0;

  final List<PricedSaleLine> lines;
  final int total;

  bool get isEmpty => lines.isEmpty;

  /// Alguna línea pide más de lo que el dispositivo tiene contado.
  bool get hasShortages => lines.any((line) => line.isShort);

  bool get canSave => lines.isNotEmpty && lines.every((line) => line.quantity > 0);
}

/// Valúa una línea contra los lotes del producto, del más viejo al más nuevo
/// (plan 0005 D5).
///
/// Es el gemelo de `inventory/allocation.py`, con una diferencia deliberada: el
/// backend **lanza** cuando el stock no alcanza y aquí no se lanza nada. Lo que
/// el mostrador ve es una vista previa contra un inventario que puede tener
/// horas de retraso; negarse a vender por eso sería dejar a alguien con el
/// producto en la mano y la app diciendo que no existe. Se reparte lo que hay,
/// se marca la línea como corta y el servidor decide de verdad al aplicarla.
///
/// [lots] tiene que venir ya en orden de llegada: ordenar es cosa de la consulta.
PricedSaleLine priceLine({
  required String productId,
  required String productName,
  required int quantity,
  required List<LotStock> lots,
}) {
  final sellable = [for (final lot in lots) if (lot.isSellable) lot];
  final available = sellable.fold(0, (sum, lot) => sum + lot.quantityAvailable);

  final allocations = <SaleAllocation>[];
  var remaining = quantity;
  for (final lot in sellable) {
    if (remaining <= 0) break;
    final taken = remaining < lot.quantityAvailable ? remaining : lot.quantityAvailable;
    allocations.add(
      SaleAllocation(
        lotNumber: lot.lotNumber,
        quantity: taken,
        unitPrice: lot.salePrice!,
        amount: Fixed2.multiply(lot.salePrice!, taken),
      ),
    );
    remaining -= taken;
  }

  // Lo que no alcanzó a cubrirse se valúa al precio del último lote que sí
  // existe, para que el total de la pantalla no se quede corto respecto de lo
  // que el cliente va a pagar. Sin ningún lote vendible no hay precio que
  // inventar y la línea vale cero: la advertencia es lo que se muestra.
  if (remaining > 0 && allocations.isNotEmpty) {
    final price = allocations.last.unitPrice;
    allocations.add(
      SaleAllocation(
        lotNumber: allocations.last.lotNumber,
        quantity: remaining,
        unitPrice: price,
        amount: Fixed2.multiply(price, remaining),
      ),
    );
  }

  return PricedSaleLine(
    productId: productId,
    productName: productName,
    quantity: quantity,
    allocations: allocations,
    amount: allocations.fold(0, (sum, allocation) => sum + allocation.amount),
    available: available,
  );
}

/// Σ de las líneas ya redondeadas, no de los productos exactos: las líneas
/// impresas tienen que cuadrar con el total impreso.
PricedSale priceSale(List<PricedSaleLine> lines) =>
    PricedSale(lines: lines, total: lines.fold(0, (sum, line) => sum + line.amount));
