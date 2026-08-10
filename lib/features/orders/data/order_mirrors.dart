import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
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
      createdAt: Value(_instant(data['created_at'])),
    );
  }

  /// La boleta se resuelve entera: sus líneas también dejan de estar protegidas.
  ///
  /// Una boleta es **una** unidad de trabajo en el outbox —una sola operación
  /// `order/create` que lleva prendas, cargos y descuentos dentro— pero cinco
  /// filas en la BD local. Sin esta cascada las hijas se quedarían `pending`
  /// para siempre: el motor solo conoce la entidad que nombra la operación, y el
  /// pull nunca podría traerles los montos que el servidor recalculó.
  ///
  /// Si además se aceptó, las líneas que capturó el dispositivo se retiran: ver
  /// [_retireCapturedLines].
  @override
  Future<void> settle(String entityId, {required bool rejected}) async {
    await super.settle(entityId, rejected: rejected);
    final status = rejected ? RowSyncStatus.rejected : RowSyncStatus.synced;

    // Antes de marcar nada. El retiro se apoya en `sync_status` para saber qué
    // filas capturó el mostrador, y la cascada de abajo borra justamente esa
    // señal.
    if (!rejected) await _retireCapturedLines(entityId);

    for (final child in <TableInfo<Table, DataClass>>[
      database.orderGarmentEntries,
      database.orderChargeEntries,
      database.orderDiscountEntries,
    ]) {
      await database.customUpdate(
        'UPDATE ${child.actualTableName} SET sync_status = ? WHERE order_id = ?',
        variables: [Variable<String>(status.name), Variable<String>(entityId)],
        updates: {child},
      );
    }

    // De los pagos solo el anticipo: es el único que pudo llegar dentro de la
    // captura. Un pago cobrado después viaja como operación propia y la resuelve
    // su propio espejo, así que tocarlo aquí lo desprotegería antes de tiempo.
    await database.customUpdate(
      'UPDATE ${database.orderPaymentEntries.actualTableName} '
      'SET sync_status = ? WHERE order_id = ? AND is_advance = 1',
      variables: [Variable<String>(status.name), Variable<String>(entityId)],
      updates: {database.orderPaymentEntries},
    );
  }

  /// Retira las líneas que minteó el dispositivo: el servidor creó las suyas.
  ///
  /// `order/create` y `order/update` mandan cantidades y elecciones, nunca ids
  /// de línea (ver `OrdersRepository.buildCreatePayload`): prendas, cargos y
  /// descuentos los arma el servidor con ids propios. Cuando el feed los baja,
  /// el `insertOrReplace` de [TableMirror.apply] no encuentra a quién pisar e
  /// inserta filas **nuevas**, y la boleta queda con cada línea dos veces: la
  /// vista previa y la de verdad. Es el mismo retiro que hace
  /// `SupplySaleMirror.settle` con las líneas de una venta de insumo.
  ///
  /// Dos condiciones, y las dos hacen falta:
  ///
  /// - `pending` — es lo que se capturó aquí. Lo que ya trajo el feed está
  ///   `synced` y esta lápida no lo toca.
  /// - `version = 0` — la fila nunca vino del servidor. Sin esto, entregar un
  ///   pedido se llevaría por delante las líneas buenas: `markDelivered` marca
  ///   las prendas `pending` para escribirles el conteo, y `order/deliver` se
  ///   resuelve por esta misma entidad.
  ///
  /// Rechazada es distinto y por eso no se llama: la boleta no existe del otro
  /// lado, no va a bajar nada, y las líneas son lo único que dice qué se había
  /// capturado. Se quedan hasta que alguien decida en la cola de revisión.
  ///
  /// El anticipo queda fuera a propósito: ese sí viaja con el id que le puso el
  /// dispositivo, así que el feed lo encuentra y lo actualiza en su lugar.
  Future<void> _retireCapturedLines(String orderId) async {
    final now = DateTime.now();

    for (final child in <TableInfo<Table, DataClass>>[
      database.orderGarmentEntries,
      database.orderChargeEntries,
      database.orderDiscountEntries,
    ]) {
      await database.customUpdate(
        'UPDATE ${child.actualTableName} SET deleted_at = ?, sync_status = ? '
        'WHERE order_id = ? AND sync_status = ? AND version = 0 '
        'AND deleted_at IS NULL',
        variables: [
          Variable<DateTime>(now),
          Variable<String>(RowSyncStatus.synced.name),
          Variable<String>(orderId),
          Variable<String>(RowSyncStatus.pending.name),
        ],
        updates: {child},
      );
    }
  }

  /// Descartar la boleta se lleva sus líneas y su anticipo.
  ///
  /// Marcar solo la cabecera bastaría para que desapareciera de la pantalla
  /// —todos los lectores filtran tombstones—, pero el anticipo dejaría dinero
  /// contado en un pedido que ya no existe, y el día no cuadraría por una fila
  /// que nadie puede ver.
  @override
  Future<void> discard(String entityId) async {
    await super.discard(entityId);
    final now = DateTime.now();

    for (final child in <TableInfo<Table, DataClass>>[
      database.orderGarmentEntries,
      database.orderChargeEntries,
      database.orderDiscountEntries,
      database.orderPaymentEntries,
    ]) {
      await database.customUpdate(
        'UPDATE ${child.actualTableName} SET deleted_at = ?, sync_status = ? '
        'WHERE order_id = ? AND deleted_at IS NULL',
        variables: [
          Variable<DateTime>(now),
          Variable<String>(RowSyncStatus.synced.name),
          Variable<String>(entityId),
        ],
        updates: {child},
      );
    }
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
