import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/search_text.dart';
import '../../../core/time/business_date.dart';
import '../data/orders_repository.dart';
import '../models/order.dart';

part 'orders_controller.g.dart';

/// El día que se está mirando. Por omisión, el de negocio (plan 0001 D8) y no
/// el del reloj: un pedido tomado a las 19:00 en Cobán pertenece a hoy, aunque
/// en UTC ya sea mañana.
@riverpod
class OrderDateFilter extends _$OrderDateFilter {
  @override
  DateTime build() => businessDate();

  void update(DateTime date) => state = DateTime(date.year, date.month, date.day);
}

/// Estado por el que se filtra, o `null` para "Todos".
@riverpod
class OrderStatusFilter extends _$OrderStatusFilter {
  @override
  OrderStatus? build() => null;

  void update(OrderStatus? status) => state = status;
}

@riverpod
class OrderSearchQuery extends _$OrderSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Los pedidos de una fecha cualquiera, tal como están en la BD local.
///
/// Va por fecha y no por el filtro de la lista porque Inicio también los cuenta
/// y siempre habla de hoy: si leyera el filtro, abrir el calendario en Pedidos
/// le cambiaría los contadores a la pantalla principal.
@riverpod
Stream<List<OrderListItem>> ordersOn(Ref ref, String date) {
  return ref.watch(ordersRepositoryProvider).watchByDate(date);
}

/// Los pedidos del día elegido en la lista, que es [ordersOn] con la fecha que
/// el chip de la pantalla tenga puesta.
@riverpod
AsyncValue<List<OrderListItem>> ordersForDay(Ref ref) {
  final date = ref.watch(orderDateFilterProvider);
  return ref.watch(ordersOnProvider(isoDate(date)));
}

/// Los del día, ya pasados por los filtros de estado y búsqueda.
///
/// El filtrado va en Dart y no en SQL a propósito: son los pedidos de **un**
/// día, ya están en memoria, y hacerlo aquí deja que la búsqueda cubra a la vez
/// el nombre del cliente, el correlativo y la serie de la boleta sin tres
/// consultas ni un índice más.
@riverpod
List<OrderListItem> filteredOrders(Ref ref) {
  final orders = ref.watch(ordersForDayProvider).valueOrNull ?? const <OrderListItem>[];
  final status = ref.watch(orderStatusFilterProvider);
  final needle = normalizeForSearch(ref.watch(orderSearchQueryProvider));

  return [
    for (final order in orders)
      if ((status == null || order.status == status) && _matches(order, needle)) order,
  ];
}

bool _matches(OrderListItem order, String needle) {
  if (needle.isEmpty) return true;
  final haystack = [
    normalizeForSearch(order.customerName),
    // Con y sin prefijo: en el mostrador se busca "7" tanto como "#7".
    order.reference.toLowerCase(),
    '${order.dailyNumber}',
    order.bookletSerial ?? '',
  ];
  return haystack.any((value) => value.contains(needle));
}

/// Cuánto suman los pedidos listados. Es la semilla visual del cierre del día:
/// los anulados no cuentan, porque ese dinero nunca entró.
@riverpod
int listedTotal(Ref ref) {
  final orders = ref.watch(filteredOrdersProvider);
  return orders
      .where((order) => order.status != OrderStatus.cancelled)
      .fold(0, (sum, order) => sum + order.total);
}

/// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
/// que nadie tenga que refrescar.
@riverpod
Stream<OrderDetail?> orderDetail(Ref ref, String orderId) {
  return ref.watch(ordersRepositoryProvider).watchDetail(orderId);
}
