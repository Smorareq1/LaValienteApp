import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/fixed2.dart';
import '../domain/order_capture.dart';
import '../domain/order_pricing.dart';
import '../models/order.dart';

part 'orders_local_datasource.g.dart';

/// Lectura y escritura de pedidos en la BD local. I/O puro sobre Drift.
class OrdersLocalDataSource {
  const OrdersLocalDataSource(this._database);

  final AppDatabase _database;

  /// El correlativo provisional que le toca al siguiente pedido de [orderDate].
  ///
  /// Va en **negativo** (−1, −2, −3…) y ocupa la misma columna que el número
  /// diario. El servidor solo asigna positivos, así que el signo alcanza para
  /// distinguir "todavía no tiene número" de "es el pedido 7 del día", sin una
  /// columna extra que después habría que mantener sincronizada con la de
  /// verdad. Cuando el pedido sube, el feed lo pisa con el correlativo real.
  Future<int> nextProvisionalNumber(String orderDate) async {
    final lowest = _database.orderEntries.dailyNumber.min();
    final query = _database.selectOnly(_database.orderEntries)
      ..addColumns([lowest])
      ..where(_database.orderEntries.orderDate.equals(orderDate));

    final current = (await query.getSingle()).read(lowest);
    return current == null || current >= 0 ? -1 : current - 1;
  }

  /// Escribe las cinco filas del pedido y las deja `pending`.
  ///
  /// Se llama dentro de la transacción del repositorio: o entran todas junto con
  /// la operación del outbox, o no entra ninguna.
  Future<void> insertCapture({
    required String orderId,
    required OrderCapture capture,
    required PricedOrder priced,
    required int dailyNumber,
    required String receivedById,
    required DateTime capturedAt,
    required List<String> garmentIds,
    required List<String> chargeIds,
    required List<String> discountIds,
    String? paymentId,
  }) async {
    const pending = RowSyncStatus.pending;

    await _database
        .into(_database.orderEntries)
        .insert(
          OrderEntriesCompanion.insert(
            id: orderId,
            syncStatus: Value(pending.name),
            orderDate: capture.orderDate,
            dailyNumber: dailyNumber,
            bookletSerial: Value(capture.bookletSerial),
            customerId: capture.customerId,
            nit: Value(capture.nit),
            weightLbs: Value(
              capture.weightLbs == null ? null : Fixed2.format(capture.weightLbs!),
            ),
            totalPieces: Value(capture.totalPieces),
            observations: Value(capture.observations),
            // Todo pedido nace recibido (§7.1); lo demás son endpoints propios.
            status: 'received',
            subtotal: Fixed2.format(priced.subtotal),
            discountTotal: Fixed2.format(priced.discountTotal),
            total: Fixed2.format(priced.total),
            receivedById: receivedById,
            // La hora del dispositivo hasta que el pedido suba; el feed la
            // reemplaza por la del servidor, que es la que vale para el cierre.
            createdAt: Value(capturedAt),
          ),
        );

    for (var i = 0; i < capture.garments.length; i++) {
      final garment = capture.garments[i];
      await _database
          .into(_database.orderGarmentEntries)
          .insert(
            OrderGarmentEntriesCompanion.insert(
              id: garmentIds[i],
              syncStatus: Value(pending.name),
              orderId: orderId,
              garmentTypeId: garment.garmentTypeId,
              quantity: garment.quantity,
              notes: Value(garment.notes),
            ),
          );
    }

    for (var i = 0; i < priced.charges.length; i++) {
      final charge = priced.charges[i];
      await _database
          .into(_database.orderChargeEntries)
          .insert(
            OrderChargeEntriesCompanion.insert(
              id: chargeIds[i],
              syncStatus: Value(pending.name),
              orderId: orderId,
              serviceTypeId: charge.serviceTypeId,
              serviceOptionId: Value(charge.serviceOptionId),
              description: charge.description,
              quantity: Fixed2.format(charge.quantity),
              unitPrice: Fixed2.format(charge.unitPrice),
              amount: Fixed2.format(charge.amount),
            ),
          );
    }

    for (var i = 0; i < priced.discounts.length; i++) {
      final discount = priced.discounts[i];
      await _database
          .into(_database.orderDiscountEntries)
          .insert(
            OrderDiscountEntriesCompanion.insert(
              id: discountIds[i],
              syncStatus: Value(pending.name),
              orderId: orderId,
              // El id de la promoción, para que la fila local diga lo mismo que
              // la del servidor: nulo es "descuento manual" en las dos.
              promotionId: Value(discount.promotionId),
              description: discount.description,
              amount: Fixed2.format(discount.amount),
            ),
          );
    }

    final advance = capture.advancePayment;
    if (advance != null && paymentId != null) {
      await _database
          .into(_database.orderPaymentEntries)
          .insert(
            OrderPaymentEntriesCompanion.insert(
              id: paymentId,
              syncStatus: Value(pending.name),
              orderId: orderId,
              amount: Fixed2.format(advance.amount),
              method: advance.method.wire,
              // Anticipo por definición: el dinero llegó antes de que el trabajo
              // se hiciera. El backend lo fuerza igual cuando viaja en la
              // captura, y aquí se escribe igual para que la fila local diga lo
              // mismo que la del servidor.
              isAdvance: const Value(true),
              reference: Value(advance.reference),
              receivedById: receivedById,
              paidAt: capturedAt,
            ),
          );
    }
  }

  /// Reescribe la boleta: las líneas viejas quedan como lápidas y entran las
  /// nuevas (plan 0001 §7.3).
  ///
  /// Se marcan borradas en vez de eliminarse, igual que hace el servidor: es la
  /// única forma de que el `settle` sepa a qué filas les tocaba veredicto, y de
  /// que el pull que viene detrás no las resucite.
  Future<void> rewriteCapture({
    required String orderId,
    required OrderCapture capture,
    required PricedOrder priced,
    required DateTime at,
    required List<String> garmentIds,
    required List<String> chargeIds,
    required List<String> discountIds,
  }) async {
    const pending = RowSyncStatus.pending;

    final lineTables = <TableInfo<Table, dynamic>>[
      _database.orderGarmentEntries,
      _database.orderChargeEntries,
      _database.orderDiscountEntries,
    ];
    for (final table in lineTables) {
      await _database.customUpdate(
        'UPDATE ${table.actualTableName} SET deleted_at = ?, sync_status = ? '
        'WHERE order_id = ? AND deleted_at IS NULL',
        variables: [
          Variable<DateTime>(at),
          Variable<String>(pending.name),
          Variable<String>(orderId),
        ],
        updates: {table},
      );
    }

    for (var i = 0; i < capture.garments.length; i++) {
      final garment = capture.garments[i];
      await _database
          .into(_database.orderGarmentEntries)
          .insert(
            OrderGarmentEntriesCompanion.insert(
              id: garmentIds[i],
              syncStatus: Value(pending.name),
              orderId: orderId,
              garmentTypeId: garment.garmentTypeId,
              quantity: garment.quantity,
              notes: Value(garment.notes),
            ),
          );
    }

    for (var i = 0; i < priced.charges.length; i++) {
      final charge = priced.charges[i];
      await _database
          .into(_database.orderChargeEntries)
          .insert(
            OrderChargeEntriesCompanion.insert(
              id: chargeIds[i],
              syncStatus: Value(pending.name),
              orderId: orderId,
              serviceTypeId: charge.serviceTypeId,
              serviceOptionId: Value(charge.serviceOptionId),
              description: charge.description,
              quantity: Fixed2.format(charge.quantity),
              unitPrice: Fixed2.format(charge.unitPrice),
              amount: Fixed2.format(charge.amount),
            ),
          );
    }

    for (var i = 0; i < priced.discounts.length; i++) {
      final discount = priced.discounts[i];
      await _database
          .into(_database.orderDiscountEntries)
          .insert(
            OrderDiscountEntriesCompanion.insert(
              id: discountIds[i],
              syncStatus: Value(pending.name),
              orderId: orderId,
              promotionId: Value(discount.promotionId),
              description: discount.description,
              amount: Fixed2.format(discount.amount),
            ),
          );
    }

    // La fecha y el correlativo no se tocan: son el nombre por el que todos
    // llaman al pedido (§7.3). Tampoco el estado ni los pagos.
    await (_database.update(_database.orderEntries)..where((row) => row.id.equals(orderId)))
        .write(
          OrderEntriesCompanion(
            syncStatus: Value(pending.name),
            bookletSerial: Value(capture.bookletSerial),
            customerId: Value(capture.customerId),
            nit: Value(capture.nit),
            weightLbs: Value(
              capture.weightLbs == null ? null : Fixed2.format(capture.weightLbs!),
            ),
            totalPieces: Value(capture.totalPieces),
            observations: Value(capture.observations),
            subtotal: Value(Fixed2.format(priced.subtotal)),
            discountTotal: Value(Fixed2.format(priced.discountTotal)),
            total: Value(Fixed2.format(priced.total)),
          ),
        );
  }

  Future<OrderEntry?> byId(String id) {
    return (_database.select(
      _database.orderEntries,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  /// El pedido que ya se quedó con esa serie de imprenta, si lo hay.
  ///
  /// Lo usa la cola de revisión para poner nombre al rechazo más común: el
  /// servidor dice que la boleta ya está registrada, y esto encuentra bajo qué
  /// número — sin preguntarle nada más al servidor, porque el pedido bueno ya
  /// bajó por el feed. [excluding] deja fuera la captura rechazada, que también
  /// lleva esa serie escrita.
  Future<OrderEntry?> byBookletSerial(String serial, {String? excluding}) {
    final query = _database.select(_database.orderEntries)
      ..where(
        (row) =>
            row.bookletSerial.equals(serial) &
            row.deletedAt.isNull() &
            (excluding == null ? const Constant(true) : row.id.equals(excluding).not()),
      )
      ..limit(1);
    return query.getSingleOrNull();
  }

  // -- lectura -----------------------------------------------------------

  /// Los pedidos de [orderDate], con su cliente y su saldo.
  ///
  /// Los pagos entran por un `leftOuterJoin` y se suman **en Dart**, no con un
  /// `SUM()` de SQLite: los montos se guardan como texto y sumarlos allá
  /// obligaría a un `CAST(... AS REAL)`, que es exactamente el `double` que
  /// todo lo demás evita. Un día tiene decenas de pedidos; la aritmética sobra.
  Stream<List<OrderListItem>> watchByDate(String orderDate) {
    final orders = _database.orderEntries;
    final customers = _database.customerEntries;
    final payments = _database.orderPaymentEntries;

    final query =
        _database.select(orders).join([
            leftOuterJoin(customers, customers.id.equalsExp(orders.customerId)),
            leftOuterJoin(
              payments,
              payments.orderId.equalsExp(orders.id) & payments.deletedAt.isNull(),
            ),
          ])
          ..where(orders.deletedAt.isNull() & orders.orderDate.equals(orderDate))
          // Descendente: lo último que entró es lo que se está buscando. El
          // correlativo provisional es negativo, así que los pedidos que aún no
          // suben quedan al final; se ordena también por hora para que no se
          // mezclen entre sí.
          ..orderBy([
            OrderingTerm.desc(orders.dailyNumber),
            OrderingTerm.desc(orders.createdAt),
          ]);

    return query.watch().map((rows) {
      final byId = <String, OrderEntry>{};
      final names = <String, String?>{};
      final paid = <String, int>{};
      final seenPayments = <String>{};

      for (final row in rows) {
        final order = row.readTable(orders);
        byId[order.id] = order;
        names[order.id] = row.readTableOrNull(customers)?.fullName;

        final payment = row.readTableOrNull(payments);
        // El join repite el pedido una vez por pago; sin este control un pedido
        // con dos pagos y dos filas de cliente contaría el dinero dos veces.
        if (payment != null && seenPayments.add(payment.id)) {
          paid[order.id] = (paid[order.id] ?? 0) + (Fixed2.parse(payment.amount) ?? 0);
        }
      }

      return [
        for (final order in byId.values)
          OrderListItem(
            id: order.id,
            dailyNumber: order.dailyNumber,
            orderDate: order.orderDate,
            customerName: names[order.id] ?? 'Cliente sin sincronizar',
            status: OrderStatus.fromWire(order.status),
            total: Fixed2.parse(order.total) ?? 0,
            paid: paid[order.id] ?? 0,
            totalPieces: order.totalPieces,
            syncStatus: RowSyncStatus.values.byName(order.syncStatus),
            bookletSerial: order.bookletSerial,
            createdAt: order.createdAt,
          ),
      ];
    });
  }

  /// El pedido [id] con todo su detalle, en vivo.
  ///
  /// Se dispara con un cambio en **cualquiera** de las cinco tablas. Vigilar
  /// solo la del pedido no alcanzaría: cobrar inserta una fila en `payments` y
  /// no toca la del pedido, así que el saldo de la pantalla se quedaría viejo.
  Stream<OrderDetail?> watchDetail(String id) {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.orderEntries,
            _database.orderGarmentEntries,
            _database.orderChargeEntries,
            _database.orderDiscountEntries,
            _database.orderPaymentEntries,
            _database.customerEntries,
            _database.garmentTypeEntries,
          },
        )
        .watch()
        .asyncMap((_) => detail(id));
  }

  Future<OrderDetail?> detail(String id) async {
    final order = await byId(id);
    if (order == null || order.deletedAt != null) return null;

    final customer = await (_database.select(
      _database.customerEntries,
    )..where((row) => row.id.equals(order.customerId))).getSingleOrNull();

    final garmentRows =
        await (_database.select(_database.orderGarmentEntries)
              ..where((row) => row.orderId.equals(id) & row.deletedAt.isNull()))
            .get();
    final types = {
      for (final type in await _database.select(_database.garmentTypeEntries).get())
        type.id: type.name,
    };

    final chargeRows =
        await (_database.select(_database.orderChargeEntries)
              ..where((row) => row.orderId.equals(id) & row.deletedAt.isNull()))
            .get();
    final discountRows =
        await (_database.select(_database.orderDiscountEntries)
              ..where((row) => row.orderId.equals(id) & row.deletedAt.isNull()))
            .get();
    final paymentRows =
        await (_database.select(_database.orderPaymentEntries)
              ..where((row) => row.orderId.equals(id) & row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm.asc(row.paidAt)]))
            .get();

    return OrderDetail(
      id: order.id,
      dailyNumber: order.dailyNumber,
      orderDate: order.orderDate,
      customerId: order.customerId,
      customerName: customer?.fullName ?? 'Cliente sin sincronizar',
      status: OrderStatus.fromWire(order.status),
      subtotal: Fixed2.parse(order.subtotal) ?? 0,
      discountTotal: Fixed2.parse(order.discountTotal) ?? 0,
      total: Fixed2.parse(order.total) ?? 0,
      totalPieces: order.totalPieces,
      receivedById: order.receivedById,
      syncStatus: RowSyncStatus.values.byName(order.syncStatus),
      version: order.version,
      bookletSerial: order.bookletSerial,
      nit: order.nit,
      weightLbs: Fixed2.parse(order.weightLbs),
      observations: order.observations,
      createdAt: order.createdAt,
      deliveredAt: order.deliveredAt,
      deliveredById: order.deliveredById,
      cancelledAt: order.cancelledAt,
      cancelledById: order.cancelledById,
      cancelReason: order.cancelReason,
      garments: [
        for (final row in garmentRows)
          OrderGarmentLine(
            id: row.id,
            garmentTypeId: row.garmentTypeId,
            name: types[row.garmentTypeId] ?? 'Prenda sin sincronizar',
            quantity: row.quantity,
            quantityDelivered: row.quantityDelivered,
            notes: row.notes,
          ),
      ],
      charges: [
        for (final row in chargeRows)
          OrderChargeLine(
            id: row.id,
            serviceTypeId: row.serviceTypeId,
            serviceOptionId: row.serviceOptionId,
            description: row.description,
            quantity: Fixed2.parse(row.quantity) ?? 0,
            unitPrice: Fixed2.parse(row.unitPrice) ?? 0,
            amount: Fixed2.parse(row.amount) ?? 0,
          ),
      ],
      discounts: [
        for (final row in discountRows)
          OrderDiscountLine(
            id: row.id,
            promotionId: row.promotionId,
            description: row.description,
            amount: Fixed2.parse(row.amount) ?? 0,
          ),
      ],
      payments: [
        for (final row in paymentRows)
          OrderPaymentLine(
            id: row.id,
            amount: Fixed2.parse(row.amount) ?? 0,
            method: PaymentMethod.fromWire(row.method),
            isAdvance: row.isAdvance,
            paidAt: row.paidAt,
            syncStatus: RowSyncStatus.values.byName(row.syncStatus),
            reference: row.reference,
          ),
      ],
    );
  }

  // -- escritura del ciclo de vida ---------------------------------------

  /// Deja el pedido en [status] y lo marca `pending`.
  Future<void> markStatus(String id, OrderStatus status) {
    return (_database.update(_database.orderEntries)..where((row) => row.id.equals(id)))
        .write(
          OrderEntriesCompanion(
            status: Value(status.wire),
            syncStatus: Value(RowSyncStatus.pending.name),
          ),
        );
  }

  /// Escribe la entrega: el conteo de lo que sí volvió, quién entregó y cuándo.
  Future<void> markDelivered({
    required String id,
    required Map<String, int> delivered,
    required String deliveredById,
    required DateTime at,
  }) async {
    for (final entry in delivered.entries) {
      await (_database.update(_database.orderGarmentEntries)
            ..where((row) => row.id.equals(entry.key)))
          .write(
            OrderGarmentEntriesCompanion(
              quantityDelivered: Value(entry.value),
              syncStatus: Value(RowSyncStatus.pending.name),
            ),
          );
    }

    await (_database.update(_database.orderEntries)..where((row) => row.id.equals(id)))
        .write(
          OrderEntriesCompanion(
            status: Value(OrderStatus.delivered.wire),
            deliveredAt: Value(at),
            deliveredById: Value(deliveredById),
            syncStatus: Value(RowSyncStatus.pending.name),
          ),
        );
  }

  Future<void> markCancelled({
    required String id,
    required String reason,
    required String cancelledById,
    required DateTime at,
  }) {
    return (_database.update(_database.orderEntries)..where((row) => row.id.equals(id)))
        .write(
          OrderEntriesCompanion(
            status: Value(OrderStatus.cancelled.wire),
            cancelledAt: Value(at),
            cancelledById: Value(cancelledById),
            cancelReason: Value(reason),
            syncStatus: Value(RowSyncStatus.pending.name),
          ),
        );
  }

  Future<void> insertPayment({
    required String paymentId,
    required String orderId,
    required PaymentDraft payment,
    required String receivedById,
    required DateTime paidAt,
  }) {
    return _database
        .into(_database.orderPaymentEntries)
        .insert(
          OrderPaymentEntriesCompanion.insert(
            id: paymentId,
            syncStatus: Value(RowSyncStatus.pending.name),
            orderId: orderId,
            amount: Fixed2.format(payment.amount),
            method: payment.method.wire,
            // Solo el que viaja dentro de la captura es anticipo; este llega
            // con el trabajo ya hecho o en curso.
            isAdvance: const Value(false),
            reference: Value(payment.reference),
            receivedById: receivedById,
            paidAt: paidAt,
          ),
        );
  }
}

@Riverpod(keepAlive: true)
OrdersLocalDataSource ordersLocalDataSource(Ref ref) {
  return OrdersLocalDataSource(ref.watch(appDatabaseProvider));
}
