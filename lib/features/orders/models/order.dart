import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/fixed2.dart';
import '../domain/order_capture.dart';

/// Estados de un pedido (plan 0001 §7.1).
///
/// Las transiciones son las mismas que `ALLOWED_TRANSITIONS` del backend, y
/// están aquí para que la pantalla ofrezca solo lo que el servidor va a
/// aceptar. No es una duplicación por comodidad: mostrar un botón que termina
/// en la cola de revisión es peor que no mostrarlo.
enum OrderStatus {
  received('received', 'Recibido'),
  inProgress('in_progress', 'En proceso'),
  ready('ready', 'Listo'),
  delivered('delivered', 'Entregado'),
  cancelled('cancelled', 'Anulado');

  const OrderStatus(this.wire, this.label);

  final String wire;
  final String label;

  static OrderStatus? fromWire(String value) {
    for (final status in values) {
      if (status.wire == value) return status;
    }
    // Un estado que esta versión no conoce no se adivina: el ciclo de vida lo
    // define el servidor y estrenar uno exige su versión de app.
    return null;
  }

  /// El paso natural hacia adelante, si alguien quiere darlo.
  ///
  /// La cadena es **opcional** (plan 0001 D13): existe para saber qué hay en
  /// lavado, pero nadie está obligado a recorrerla y entregar no la exige. De
  /// ahí que esto no sea la acción principal de ninguna pantalla — el pedido se
  /// cierra al entregarlo, y eso se registra desde Caja.
  OrderStatus? get forwardStep => switch (this) {
    OrderStatus.received => OrderStatus.inProgress,
    OrderStatus.inProgress => OrderStatus.ready,
    OrderStatus.ready || OrderStatus.delivered || OrderStatus.cancelled => null,
  };

  /// El paso de vuelta, que existe para deshacer un toque equivocado.
  ///
  /// Va aparte de [forwardStep] y no mezclado con él porque no son la misma
  /// clase de acción: uno mueve el trabajo y el otro corrige un error, y
  /// ponerlos como dos botones iguales invita justo al toque que se quería
  /// deshacer.
  OrderStatus? get backStep => switch (this) {
    OrderStatus.inProgress => OrderStatus.received,
    OrderStatus.ready => OrderStatus.inProgress,
    OrderStatus.received || OrderStatus.delivered || OrderStatus.cancelled => null,
  };

  /// A dónde puede pasar con el botón de avanzar. Entregar y anular no salen de
  /// aquí: cada uno tiene su pantalla porque necesita datos propios.
  List<OrderStatus> get nextSteps => [
    if (forwardStep != null) forwardStep!,
    if (backStep != null) backStep!,
  ];

  /// Se entrega desde cualquier estado vivo (`DELIVERABLE_FROM` del backend,
  /// plan 0001 D13). Exigir `listo` antes obligaría a dar dos toques que en el
  /// mostrador nadie da: la entrega se registra al cierre, contra boletas que
  /// nunca salieron de `recibido`.
  bool get canBeDelivered => !isClosed;

  bool get canBeCancelled =>
      this == OrderStatus.received || this == OrderStatus.inProgress;

  /// Una boleta abierta: la lavandería todavía tiene la ropa. Es lo que llena
  /// la lista de entregas de Caja (plan 0006 §7.1.1).
  bool get isOpen => !isClosed;

  /// Un pedido cerrado ya no acepta nada; uno entregado sí sigue aceptando
  /// pagos, que es como se salda un fiado.
  bool get acceptsPayments => this != OrderStatus.cancelled;

  bool get isClosed => this == OrderStatus.delivered || this == OrderStatus.cancelled;

  /// Si la boleta todavía se puede corregir (plan 0001 §7.3). Un pedido `listo`
  /// se puede, pero exige `orders.update_ready`; uno cerrado no lo edita nadie
  /// — eso se corrige anulando y volviendo a capturar.
  bool get canBeEdited => !isClosed;

  /// Si además hace falta el permiso de admin para editarlo.
  bool get needsAdminToEdit => this == OrderStatus.ready;
}

/// Lo que se le dice a la persona: `#7` cuando el servidor ya numeró la boleta,
/// `P-1` mientras solo existe en el dispositivo (plan 0002 §6).
///
/// El correlativo provisional se guarda en negativo en la misma columna, porque
/// el servidor solo asigna positivos.
String orderReference(int dailyNumber) =>
    dailyNumber < 0 ? 'P-${-dailyNumber}' : '#$dailyNumber';

/// Una fila de la lista del día (plan 0006 §5.1).
class OrderListItem {
  const OrderListItem({
    required this.id,
    required this.dailyNumber,
    required this.orderDate,
    required this.customerName,
    required this.status,
    required this.total,
    required this.paid,
    required this.totalPieces,
    required this.syncStatus,
    this.bookletSerial,
    this.createdAt,
  });

  final String id;
  final int dailyNumber;
  final String orderDate;

  /// Nombre del cliente, o un aviso si su fila todavía no bajó del servidor.
  final String customerName;

  final OrderStatus? status;

  /// Centavos.
  final int total;
  final int paid;

  final int totalPieces;
  final RowSyncStatus syncStatus;
  final String? bookletSerial;
  final DateTime? createdAt;

  String get reference => orderReference(dailyNumber);

  int get balance => total - paid;

  bool get hasBalance => balance > 0 && status != OrderStatus.cancelled;

  bool get isPending => syncStatus == RowSyncStatus.pending;

  bool get needsReview => syncStatus == RowSyncStatus.rejected;

  double get totalAsDouble => Fixed2.toDouble(total);

  double get balanceAsDouble => Fixed2.toDouble(balance);
}

class OrderGarmentLine {
  const OrderGarmentLine({
    required this.id,
    required this.garmentTypeId,
    required this.name,
    required this.quantity,
    this.quantityDelivered,
    this.notes,
  });

  final String id;
  final String garmentTypeId;

  /// Nombre del tipo de prenda; si su fila no bajó, el id sirve de último
  /// recurso antes que dejar la línea en blanco.
  final String name;

  final int quantity;

  /// Se llena al entregar; el hueco contra [quantity] es la pérdida.
  final int? quantityDelivered;

  final String? notes;

  bool get isShort => quantityDelivered != null && quantityDelivered! < quantity;
}

class OrderChargeLine {
  const OrderChargeLine({
    required this.id,
    required this.serviceTypeId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.serviceOptionId,
  });

  final String id;

  /// A qué servicio del catálogo apunta. La línea guarda su descripción
  /// congelada (D2), pero para **reabrir** el pedido y corregirlo hace falta
  /// saber qué casilla del formulario la produjo.
  final String serviceTypeId;
  final String? serviceOptionId;

  final String description;

  /// Centésimas, como se capturó (2.50 lb son 250).
  final int quantity;

  final int unitPrice;
  final int amount;
}

class OrderDiscountLine {
  const OrderDiscountLine({
    required this.id,
    required this.description,
    required this.amount,
    this.promotionId,
  });

  final String id;

  /// `null` en un descuento manual. Con valor, la línea salió de una promoción
  /// y al reabrir el pedido se vuelve a marcar su chip.
  final String? promotionId;

  final String description;
  final int amount;

  bool get isManual => promotionId == null;
}

class OrderPaymentLine {
  const OrderPaymentLine({
    required this.id,
    required this.amount,
    required this.method,
    required this.isAdvance,
    required this.paidAt,
    required this.syncStatus,
    this.reference,
  });

  final String id;
  final int amount;

  /// `null` si el servidor mandó un método que esta versión no conoce.
  final PaymentMethod? method;

  final bool isAdvance;
  final DateTime paidAt;
  final RowSyncStatus syncStatus;
  final String? reference;

  bool get isPending => syncStatus == RowSyncStatus.pending;
}

/// El pedido entero, como lo muestra el detalle (plan 0006 §5.4).
class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.dailyNumber,
    required this.orderDate,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.subtotal,
    required this.discountTotal,
    required this.total,
    required this.totalPieces,
    required this.receivedById,
    required this.syncStatus,
    required this.version,
    required this.garments,
    required this.charges,
    required this.discounts,
    required this.payments,
    this.bookletSerial,
    this.nit,
    this.weightLbs,
    this.observations,
    this.createdAt,
    this.deliveredAt,
    this.deliveredById,
    this.cancelledAt,
    this.cancelledById,
    this.cancelReason,
  });

  final String id;
  final int dailyNumber;
  final String orderDate;
  final String customerId;
  final String customerName;
  final OrderStatus? status;
  final int subtotal;
  final int discountTotal;
  final int total;
  final int totalPieces;
  final String receivedById;
  final RowSyncStatus syncStatus;

  /// Versión conocida del servidor. Viaja como `base_version` al corregir, para
  /// que una boleta que cambió mientras el teléfono estaba sin señal sea un
  /// conflicto y no una sobrescritura (plan 0004 D6).
  final int version;

  final String? bookletSerial;
  final String? nit;

  /// Libras en centésimas.
  final int? weightLbs;

  final String? observations;
  final DateTime? createdAt;
  final DateTime? deliveredAt;
  final String? deliveredById;
  final DateTime? cancelledAt;
  final String? cancelledById;
  final String? cancelReason;

  final List<OrderGarmentLine> garments;
  final List<OrderChargeLine> charges;
  final List<OrderDiscountLine> discounts;
  final List<OrderPaymentLine> payments;

  String get reference => orderReference(dailyNumber);

  bool get isPending => syncStatus == RowSyncStatus.pending;

  bool get needsReview => syncStatus == RowSyncStatus.rejected;

  /// Lo cobrado. Se suma aquí, en enteros, y no se guarda en ninguna columna:
  /// un saldo almacenado es lo primero que se queda viejo el día que se anule
  /// un pago (plan 0001 §5.3).
  int get paid => payments.fold(0, (sum, payment) => sum + payment.amount);

  int get balance => total - paid;

  bool get hasBalance => balance > 0;

  double get totalAsDouble => Fixed2.toDouble(total);

  double get balanceAsDouble => Fixed2.toDouble(balance);
}
