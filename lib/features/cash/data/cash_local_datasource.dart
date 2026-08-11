import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../../../core/time/business_date.dart';
import '../../orders/models/order.dart';
import '../models/cash_entry.dart';

part 'cash_local_datasource.g.dart';

/// Lo que la Caja necesita leer y que no es suyo: los cobros de pedidos y el
/// acta del cierre.
///
/// Los cobros viven en las tablas de pedidos, pero la pregunta «cuánto entró
/// hoy» es de la Caja y no del módulo de pedidos: un pedido se lee por su fecha
/// de boleta y el dinero se lee por el día en que se recibió, que casi nunca es
/// el mismo (plan 0005 D1).
class CashLocalDataSource {
  const CashLocalDataSource(this._database);

  final AppDatabase _database;

  /// Los cobros recibidos en el día de negocio [date].
  ///
  /// Se corta por `paidAt` y no por la fecha del pedido: un anticipo pertenece
  /// al día en que se entregó y el saldo al día en que se cobró. Como `paidAt`
  /// es una marca UTC, el corte usa la ventana del día de la lavandería — las
  /// 19:00 en Cobán ya son mañana en UTC.
  ///
  /// Los cobros de pedidos anulados **entran**: ese dinero está en el cajón y
  /// el conteo tiene que poder explicarlo.
  Stream<List<CashEntry>> watchOrderPayments(String date) {
    final day = parseIsoDate(date);
    if (day == null) return Stream.value(const []);
    final bounds = businessDayBounds(day);

    final payments = _database.orderPaymentEntries;
    final orders = _database.orderEntries;
    final customers = _database.customerEntries;

    final query =
        _database.select(payments).join([
            leftOuterJoin(orders, orders.id.equalsExp(payments.orderId)),
            leftOuterJoin(customers, customers.id.equalsExp(orders.customerId)),
          ])
          ..where(
            payments.deletedAt.isNull() &
                payments.paidAt.isBiggerOrEqualValue(bounds.start) &
                payments.paidAt.isSmallerThanValue(bounds.end),
          )
          ..orderBy([OrderingTerm.desc(payments.paidAt)]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          _toEntry(
            row.readTable(payments),
            row.readTableOrNull(orders),
            row.readTableOrNull(customers)?.fullName,
          ),
      ],
    );
  }

  static CashEntry _toEntry(
    OrderPaymentEntry payment,
    OrderEntry? order,
    String? customerName,
  ) {
    final reference = order == null ? null : orderReference(order.dailyNumber);
    final who = customerName ?? 'Cliente sin sincronizar';
    // La serie de imprenta va en la fila junto al correlativo: el papel que
    // alguien tiene en la mano al repasar la caja lleva ese número y no el
    // nuestro, y buscar una entrega sin él es leer la lista entera.
    final serial = order?.bookletSerial;

    return CashEntry(
      id: payment.id,
      kind: CashEntryKind.orderPayment,
      title: reference == null ? who : 'Pedido $reference · $who',
      subtitle: [
        payment.isAdvance ? 'Anticipo' : 'Abono al pedido',
        if (serial != null && serial.isNotEmpty) 'boleta $serial',
      ].join(' · '),
      amount: Fixed2.parse(payment.amount) ?? 0,
      method: PaymentMethod.fromWire(payment.method),
      at: payment.paidAt,
      route: order == null ? null : '/orders/${order.id}',
      syncStatus: RowSyncStatus.values.byName(payment.syncStatus),
    );
  }

  /// El acta que cerró [date], si la fecha está cerrada.
  ///
  /// Filtra las lápidas porque reabrir **es** la lápida (D9): un acta con
  /// `deletedAt` es un día que estuvo cerrado y ya no lo está.
  Stream<DayClosure?> watchClosure(String date) {
    final query = _database.select(_database.dailyClosureEntries)
      ..where((row) => row.deletedAt.isNull() & row.closeDate.equals(date))
      ..limit(1);

    return query.watchSingleOrNull().map(
      (row) => row == null
          ? null
          : DayClosure(
              id: row.id,
              closeDate: row.closeDate,
              closedAt: row.closedAt,
              closedById: row.closedById,
              netTotal: Fixed2.parse(row.netTotal) ?? 0,
              notes: row.notes,
            ),
    );
  }
}

@Riverpod(keepAlive: true)
CashLocalDataSource cashLocalDataSource(Ref ref) {
  return CashLocalDataSource(ref.watch(appDatabaseProvider));
}
