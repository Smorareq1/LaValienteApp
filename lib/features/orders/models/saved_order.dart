import '../../../core/money/fixed2.dart';
import '../../../core/receipts/receipt.dart';
import 'order.dart';

/// El pedido recién guardado, para la pantalla de confirmación (§3.8).
class SavedOrder {
  const SavedOrder({
    required this.id,
    required this.dailyNumber,
    required this.total,
    required this.paid,
    this.warnings = const [],
    this.receivedAt,
    this.customerName,
    this.customerPhone,
    this.customerNit,
    this.garments = const [],
  });

  final String id;

  /// Correlativo del día, o el provisional en negativo mientras el pedido no
  /// haya subido.
  final int dailyNumber;

  /// Centavos.
  final int total;
  final int paid;

  final List<String> warnings;

  /// Cuándo se recibió la ropa. Es la hora que va en el comprobante, y la pone
  /// el repositorio: es el mismo instante que quedó guardado en la fila.
  final DateTime? receivedAt;

  /// Con quién y con qué se armó la boleta, para el comprobante que se comparte
  /// (§17.1). No sale del repositorio porque allí solo hay ids: los nombres de
  /// las prendas viven en el catálogo, y quien capturó ya los tiene en pantalla.
  final String? customerName;
  final String? customerPhone;
  final String? customerNit;
  final List<ReceiptGarment> garments;

  /// El mismo pedido con lo que hace falta para el comprobante.
  SavedOrder withTicket({
    String? customerName,
    String? customerPhone,
    String? customerNit,
    List<ReceiptGarment> garments = const [],
  }) {
    return SavedOrder(
      id: id,
      dailyNumber: dailyNumber,
      total: total,
      paid: paid,
      warnings: warnings,
      receivedAt: receivedAt,
      customerName: customerName,
      customerPhone: customerPhone,
      customerNit: customerNit,
      garments: garments,
    );
  }

  int get balance => total - paid;

  /// Todavía no tiene número del servidor, así que todavía no subió.
  bool get pendingSync => dailyNumber < 0;

  String get reference => orderReference(dailyNumber);

  double get totalAsDouble => Fixed2.toDouble(total);

  double get balanceAsDouble => Fixed2.toDouble(balance);
}
