import '../../../core/money/payment_method.dart';
import 'order_pricing.dart';

// `PaymentMethod` se mudó a `core/money` cuando la Caja y la venta de insumo
// empezaron a necesitarlo (UI 6). Se reexporta desde aquí para que todo lo que
// habla de pagos de pedidos lo siga encontrando donde siempre estuvo.
export '../../../core/money/payment_method.dart' show PaymentMethod;

/// Una línea de prendas: tipo, cuántas y la nota de esa línea.
class GarmentDraft {
  const GarmentDraft({
    required this.garmentTypeId,
    required this.quantity,
    this.notes,
  });

  final String garmentTypeId;
  final int quantity;
  final String? notes;
}

/// Dinero entregado al capturar.
class PaymentDraft {
  const PaymentDraft({
    required this.amount,
    this.method = PaymentMethod.cash,
    this.reference,
  });

  /// Centavos.
  final int amount;
  final PaymentMethod method;

  /// Número de la transferencia. Solo tiene sentido si [method] no es efectivo.
  final String? reference;
}

/// Una boleta tal como quedó en la pantalla, antes de que nadie le ponga precio.
///
/// Solo lleva lo que la persona capturó. Los montos no viven aquí: los resuelve
/// [priceOrder] contra el catálogo de [orderDate], y el servidor los vuelve a
/// resolver al aplicar la operación (D5).
class OrderCapture {
  const OrderCapture({
    required this.orderDate,
    required this.customerId,
    required this.garments,
    required this.charges,
    this.bookletSerial,
    this.nit,
    this.weightLbs,
    this.observations,
    this.discounts = const [],
    this.advancePayment,
  });

  /// Fecha de negocio en `YYYY-MM-DD`.
  final String orderDate;
  final String customerId;
  final String? bookletSerial;
  final String? nit;

  /// Libras en centésimas, o `null` si no se pesó.
  final int? weightLbs;

  final String? observations;
  final List<GarmentDraft> garments;
  final List<ChargeDraft> charges;
  final List<DiscountDraft> discounts;
  final PaymentDraft? advancePayment;

  /// El "No. Piezas" de la boleta. Se suma, nunca se digita (§3.3).
  int get totalPieces => garments.fold(0, (sum, item) => sum + item.quantity);
}
