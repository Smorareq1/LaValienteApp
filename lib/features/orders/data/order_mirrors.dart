import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejos de pedidos. Los cinco son bidireccionales (plan 0004 §7.3): el
/// mostrador captura y cobra sin red, y la fila `pending` que deja el outbox es
/// lo que [TableMirror] protege del pull.
///
/// Cada uno traduce exactamente los campos que declara `FEED_ENTITIES` del
/// backend. Uno que allá se agregue aquí no aparece solo, y eso es lo que se
/// quiere: el feed nunca escribe columnas sorpresa.
List<TableMirror<DataClass>> orderMirrors(AppDatabase database) => [
  OrderMirror(database),
  OrderGarmentMirror(database),
  OrderChargeMirror(database),
  OrderDiscountMirror(database),
  OrderPaymentMirror(database),
];

/// Fechas con hora del feed (`delivered_at`, `paid_at`): ISO-8601 con zona.
DateTime? _instant(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toUtc();

class OrderMirror extends TableMirror<OrderEntry> {
  const OrderMirror(super.database);

  @override
  String get entity => 'order';

  @override
  TableInfo<Table, OrderEntry> get table => database.orderEntries;

  @override
  OrderEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return OrderEntriesCompanion(
      orderDate: Value(data['order_date'] as String),
      dailyNumber: Value(data['daily_number'] as int),
      bookletSerial: Value(data['booklet_serial'] as String?),
      customerId: Value(data['customer_id'] as String),
      nit: Value(data['nit'] as String?),
      weightLbs: Value(data['weight_lbs'] as String?),
      totalPieces: Value(data['total_pieces'] as int),
      observations: Value(data['observations'] as String?),
      status: Value(data['status'] as String),
      // Los tres montos llegan como string y se guardan como string:
      // convertirlos a double aquí sería meter el error de redondeo justo en la
      // frontera, y el total es lo único que el cliente revisa.
      subtotal: Value(data['subtotal'] as String),
      discountTotal: Value(data['discount_total'] as String),
      total: Value(data['total'] as String),
      receivedById: Value(data['received_by_id'] as String),
      deliveredAt: Value(_instant(data['delivered_at'])),
      deliveredById: Value(data['delivered_by_id'] as String?),
      cancelledAt: Value(_instant(data['cancelled_at'])),
      cancelledById: Value(data['cancelled_by_id'] as String?),
      cancelReason: Value(data['cancel_reason'] as String?),
    );
  }
}

class OrderGarmentMirror extends TableMirror<OrderGarmentEntry> {
  const OrderGarmentMirror(super.database);

  @override
  String get entity => 'order_garment';

  @override
  TableInfo<Table, OrderGarmentEntry> get table => database.orderGarmentEntries;

  @override
  OrderGarmentEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return OrderGarmentEntriesCompanion(
      orderId: Value(data['order_id'] as String),
      garmentTypeId: Value(data['garment_type_id'] as String),
      quantity: Value(data['quantity'] as int),
      quantityDelivered: Value(data['quantity_delivered'] as int?),
      notes: Value(data['notes'] as String?),
    );
  }
}

class OrderChargeMirror extends TableMirror<OrderChargeEntry> {
  const OrderChargeMirror(super.database);

  @override
  String get entity => 'order_charge';

  @override
  TableInfo<Table, OrderChargeEntry> get table => database.orderChargeEntries;

  @override
  OrderChargeEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return OrderChargeEntriesCompanion(
      orderId: Value(data['order_id'] as String),
      serviceTypeId: Value(data['service_type_id'] as String),
      serviceOptionId: Value(data['service_option_id'] as String?),
      description: Value(data['description'] as String),
      quantity: Value(data['quantity'] as String),
      unitPrice: Value(data['unit_price'] as String),
      amount: Value(data['amount'] as String),
    );
  }
}

class OrderDiscountMirror extends TableMirror<OrderDiscountEntry> {
  const OrderDiscountMirror(super.database);

  @override
  String get entity => 'order_discount';

  @override
  TableInfo<Table, OrderDiscountEntry> get table => database.orderDiscountEntries;

  @override
  OrderDiscountEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return OrderDiscountEntriesCompanion(
      orderId: Value(data['order_id'] as String),
      promotionId: Value(data['promotion_id'] as String?),
      description: Value(data['description'] as String),
      amount: Value(data['amount'] as String),
    );
  }
}

class OrderPaymentMirror extends TableMirror<OrderPaymentEntry> {
  const OrderPaymentMirror(super.database);

  @override
  String get entity => 'order_payment';

  @override
  TableInfo<Table, OrderPaymentEntry> get table => database.orderPaymentEntries;

  @override
  OrderPaymentEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return OrderPaymentEntriesCompanion(
      orderId: Value(data['order_id'] as String),
      amount: Value(data['amount'] as String),
      method: Value(data['method'] as String),
      isAdvance: Value(data['is_advance'] as bool),
      reference: Value(data['reference'] as String?),
      receivedById: Value(data['received_by_id'] as String),
      paidAt: Value(_instant(data['paid_at'])!),
    );
  }
}
