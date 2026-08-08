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
