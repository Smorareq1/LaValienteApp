import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/payment_method.dart';
import '../domain/supply_sale_pricing.dart';

/// Un producto tal como se ofrece en el mostrador (plan 0006 §7.3).
///
/// Trae sus lotes vendibles en orden de llegada porque el precio de una venta no
/// es un número del producto sino del lote que le toque salir: dos frascos del
/// mismo jabón comprados con dos meses de diferencia se venden a lo que costaba
/// cada uno.
class ProductShelf {
  const ProductShelf({
    required this.id,
    required this.name,
    required this.unit,
    required this.lots,
    this.imagePath,
  });

  final String id;
  final String name;

  /// Bote, bolsa, galón… lo que el proveedor decidió.
  final String unit;

  final String? imagePath;

  /// Solo los vendibles, del más viejo al más nuevo, y ya descontado lo que las
  /// ventas capturadas sin señal se llevaron.
  final List<LotStock> lots;

  /// Lo que queda para vender, en centésimas.
  int get available => lots.fold(0, (sum, lot) => sum + lot.quantityAvailable);

  /// Lo que costaría la siguiente unidad: el precio del lote más viejo.
  int? get nextSalePrice => lots.isEmpty ? null : lots.first.salePrice;

  bool get isSoldOut => available <= 0;
}

/// Un producto en la cuadrícula de Insumos (plan 0006 §8.1).
///
/// No es [ProductShelf]: aquel es lo **vendible**, y este es el inventario. La
/// diferencia son los lotes de consumo interno —los que no llevan precio de
/// venta— que en el mostrador no existen y aquí sí, porque son suavizante que la
/// lavandería tiene y usa.
class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.name,
    required this.unit,
    required this.isActive,
    required this.stock,
    required this.sellableStock,
    required this.version,
    this.imagePath,
    this.description,
    this.nextSalePrice,
  });

  final String id;
  final String name;
  final String unit;
  final bool isActive;

  /// En centésimas: todo lo que los lotes vivos todavía tienen.
  final int stock;

  /// La parte de ese stock que lleva precio. El resto es de la casa.
  final int sellableStock;

  final int version;
  final String? imagePath;
  final String? description;

  /// Lo que costaría la siguiente unidad vendida: el precio del lote vendible
  /// más viejo (D5). Nulo cuando no hay nada que vender.
  final int? nextSalePrice;

  bool get isSoldOut => stock <= 0;

  /// Tiene existencias pero ninguna se vende: es insumo propio.
  bool get isInternalOnly => stock > 0 && sellableStock <= 0;
}

/// Un lote como se lee en el detalle del producto (§8.2).
class ProductLot {
  const ProductLot({
    required this.id,
    required this.lotNumber,
    required this.quantityReceived,
    required this.quantityAvailable,
    required this.receivedAt,
    required this.version,
    this.salePrice,
  });

  final String id;
  final int lotNumber;
  final int quantityReceived;
  final int quantityAvailable;

  /// `YYYY-MM-DD`. Es la que ordena el FIFO.
  final String receivedAt;

  final int version;

  /// Nulo = consumo interno; el FIFO de venta lo salta.
  final int? salePrice;

  /// **No hay `unitCost`**: el feed no lo manda a propósito (el margen de compra
  /// no se lee en el mostrador), así que el detalle lo muestra como «—».
  bool get isInternal => salePrice == null;

  bool get isEmpty => quantityAvailable <= 0;
}

/// Por qué se movió el stock de un lote.
enum MovementType {
  purchaseIn,
  saleOut,
  internalUse,
  adjustment;

  static MovementType fromWire(String value) => switch (value) {
    'purchase_in' => MovementType.purchaseIn,
    'sale_out' => MovementType.saleOut,
    'internal_use' => MovementType.internalUse,
    _ => MovementType.adjustment,
  };

  String get wire => switch (this) {
    MovementType.purchaseIn => 'purchase_in',
    MovementType.saleOut => 'sale_out',
    MovementType.internalUse => 'internal_use',
    MovementType.adjustment => 'adjustment',
  };

  String get label => switch (this) {
    MovementType.purchaseIn => 'Compra',
    MovementType.saleOut => 'Venta',
    MovementType.internalUse => 'Uso interno',
    MovementType.adjustment => 'Ajuste',
  };

  /// Los dos que una persona puede teclear. Una compra sale de registrar un lote
  /// y una venta de vender: dejarlas escribir a mano metería stock en el kardex
  /// sin ningún documento detrás.
  static const List<MovementType> manual = [
    MovementType.internalUse,
    MovementType.adjustment,
  ];
}

/// Una línea del kardex (§8.2).
class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.lotId,
    required this.lotNumber,
    required this.type,
    required this.quantity,
    this.unitPrice,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String lotId;
  final int lotNumber;
  final MovementType type;

  /// En centésimas, sin signo salvo en un ajuste, que es el único que puede ser
  /// negativo.
  final int quantity;

  final int? unitPrice;
  final String? notes;
  final DateTime? createdAt;

  /// Lo que esta línea le hizo al lote, signo incluido. El kardex se lee como un
  /// saldo corrido y quien lo lee no tiene por qué saberse la tabla de signos.
  int get stockDelta => switch (type) {
    MovementType.purchaseIn => quantity,
    MovementType.saleOut || MovementType.internalUse => -quantity,
    MovementType.adjustment => quantity,
  };
}

/// El detalle de un producto con sus lotes y su kardex (§8.2).
class ProductDetail {
  const ProductDetail({
    required this.product,
    required this.lots,
    required this.movements,
  });

  final ProductSummary product;

  /// Todos los lotes vivos, del más viejo al más nuevo.
  final List<ProductLot> lots;

  /// El kardex, de lo más reciente a lo más viejo.
  final List<InventoryMovement> movements;
}

/// Una venta de mostrador, como se lee en la lista de ingresos del día.
class SupplySaleSummary {
  const SupplySaleSummary({
    required this.id,
    required this.saleDate,
    required this.total,
    required this.method,
    required this.syncStatus,
    required this.itemCount,
    this.customerName,
    this.createdAt,
    this.cancelledAt,
  });

  final String id;
  final String saleDate;

  /// En centavos. Mientras la venta está `pending` es la vista previa que
  /// calculó el dispositivo; el feed la reemplaza por la del servidor (D10).
  final int total;

  final PaymentMethod? method;
  final RowSyncStatus syncStatus;
  final int itemCount;

  /// `null` = venta de mostrador, sin cliente.
  final String? customerName;

  final DateTime? createdAt;
  final DateTime? cancelledAt;

  bool get isCancelled => cancelledAt != null;

  bool get pendingSync => syncStatus == RowSyncStatus.pending;

  bool get needsReview => syncStatus == RowSyncStatus.rejected;
}
