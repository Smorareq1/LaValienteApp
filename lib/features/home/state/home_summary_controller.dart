import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/time/business_date.dart';
import '../../../core/time/relative_time.dart';
import '../../cash/state/cash_day_controller.dart';
import '../../orders/models/order.dart';
import '../../orders/state/orders_controller.dart';
import '../../sync/state/sync_engine.dart';
import '../models/home_summary.dart';

part 'home_summary_controller.g.dart';

/// Cuántos pedidos listos caben en la lista corta de Inicio (§4.1).
const int kHomeReadyOrdersShown = 5;

/// El día del que habla Inicio: el de negocio, siempre hoy.
///
/// Tiene provider propio para no leer `businessDate()` en tres sitios del
/// resumen y que dos de ellos pudieran caer a lados distintos de la medianoche.
@riverpod
String homeDate(Ref ref) => isoDate(businessDate());

/// El resumen del día que consume la pantalla Inicio (Plan 0006 §4.1).
///
/// Se arma **contra la BD local** y no contra `GET /daily-close/preview`: el
/// plan da esa ruta como fuente y el cálculo local como respaldo sin señal, pero
/// aquí el respaldo es lo único que hace falta. Inicio se abre al llegar en la
/// mañana, muchas veces antes de que el primer pull termine, y las cifras que
/// pediría al servidor son exactamente las que la Caja ya suma de las mismas
/// tablas espejo. Pedirlas de nuevo por red solo agregaría una pantalla que se
/// queda en cero cuando no hay señal, que es justo lo que esto viene a arreglar.
///
/// La cifra oficial sigue siendo la del servidor y se ve donde importa: en el
/// acta del cierre (§7.4), que sí es online-only.
@riverpod
HomeSummary homeSummary(Ref ref) {
  final date = ref.watch(homeDateProvider);
  final day = ref.watch(cashDayProvider(date));
  final orders = ref.watch(ordersOnProvider(date)).valueOrNull ?? const <OrderListItem>[];
  final lastSyncedAt = ref.watch(syncEngineProvider).lastSyncedAt;

  final income = day.income;

  return HomeSummary(
    collectedToday: day.incomeTotal,
    collectedCash: income.cash,
    collectedTransfer: income.transfer,
    expensesToday: day.expensesTotal,
    receivable: orders
        .where((order) => order.hasBalance)
        .fold(0, (sum, order) => sum + order.balance),
    receivedCount: _countOf(orders, OrderStatus.received),
    inProcessCount: _countOf(orders, OrderStatus.inProgress),
    readyCount: _countOf(orders, OrderStatus.ready),
    deliveredCount: _countOf(orders, OrderStatus.delivered),
    readyOrders: _readyOrders(orders),
    lastSyncedAtLabel: lastSyncedAt == null ? null : relativeAge(lastSyncedAt),
  );
}

int _countOf(List<OrderListItem> orders, OrderStatus status) =>
    orders.where((order) => order.status == status).length;

/// Los listos para entregar, los más viejos primero.
///
/// El orden es al revés que en la lista de Pedidos a propósito: allá se busca lo
/// que acaba de entrar, y aquí lo que lleva más tiempo esperando en el estante,
/// que es lo que hay que entregar antes de que el cliente pregunte. Sin hora de
/// recepción —un pedido capturado sin señal todavía no la tiene del servidor— va
/// al final en vez de fingir que llegó a medianoche.
List<ReadyOrder> _readyOrders(List<OrderListItem> orders) {
  final ready = [
    for (final order in orders)
      if (order.status == OrderStatus.ready) order,
  ]..sort((a, b) {
      final left = a.createdAt;
      final right = b.createdAt;
      if (left == null && right == null) return 0;
      if (left == null) return 1;
      if (right == null) return -1;
      return left.compareTo(right);
    });

  return [
    for (final order in ready.take(kHomeReadyOrdersShown))
      ReadyOrder(
        id: order.id,
        reference: order.reference,
        customerName: order.customerName,
        pieces: order.totalPieces,
        total: order.total,
        balance: order.balance,
        receivedAtLabel: _timeLabel(order.createdAt),
        pendingSync: order.isPending,
      ),
  ];
}

String? _timeLabel(DateTime? moment) {
  if (moment == null) return null;
  final local = moment.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
