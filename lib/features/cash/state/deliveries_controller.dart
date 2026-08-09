import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/search_text.dart';
import '../../../core/money/payment_method.dart';
import '../../orders/data/orders_repository.dart';
import '../../orders/models/order.dart';
import '../models/delivery_line.dart';

part 'deliveries_controller.g.dart';

/// Las boletas que la lavandería todavía no devolvió (plan 0006 §7.1.1).
///
/// Va sin fecha aposta: la de Caja dice de qué día es el dinero, no cuáles
/// boletas están abiertas. Una que entró el lunes se entrega el miércoles, y
/// filtrarla por el día escondería justo la que lleva más tiempo esperando.
@riverpod
Stream<List<OrderListItem>> openOrders(Ref ref) {
  return ref.watch(ordersRepositoryProvider).watchOpen();
}

/// Lo que se escribió en el buscador de entregas.
@riverpod
class DeliverySearchQuery extends _$DeliverySearchQuery {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Las boletas abiertas que casan con lo escrito.
///
/// El número de boleta es lo primero que se busca porque es lo que la persona
/// tiene en la mano; el nombre del cliente entra por si la boleta se perdió.
@riverpod
List<OrderListItem> deliverableOrders(Ref ref) {
  final orders = ref.watch(openOrdersProvider).valueOrNull ?? const <OrderListItem>[];
  final needle = normalizeForSearch(ref.watch(deliverySearchQueryProvider));
  if (needle.isEmpty) return orders;

  return [
    for (final order in orders)
      if (_matches(order, needle)) order,
  ];
}

bool _matches(OrderListItem order, String needle) {
  final haystack = [
    normalizeForSearch(order.bookletSerial ?? ''),
    normalizeForSearch(order.customerName),
    // Con y sin prefijo: en el mostrador se busca "7" tanto como "#7".
    order.reference.toLowerCase(),
    '${order.dailyNumber}',
  ];
  return haystack.any((value) => value.isNotEmpty && value.contains(needle));
}

/// Las boletas marcadas para entregar, por id de pedido.
///
/// El repaso del final del día es de varias boletas a la vez —"de las que
/// tenía, entregué estas"— así que la selección vive fuera de la pantalla y
/// sobrevive a que alguien busque otra cosa en el medio.
@riverpod
class DeliverySelection extends _$DeliverySelection {
  @override
  Map<String, DeliveryLine> build() => const {};

  void toggle(OrderListItem order) {
    final next = Map<String, DeliveryLine>.from(state);
    if (next.remove(order.id) == null) {
      next[order.id] = DeliveryLine.of(order);
    }
    state = next;
  }

  /// Marca una boleta, y no hace nada si ya estaba marcada. Devuelve si esta
  /// llamada fue la que la marcó.
  ///
  /// Aparte de [toggle] a propósito. Tocar una fila dos veces quiere decir «me
  /// equivoqué»; escanear la misma boleta dos veces quiere decir «esta», dicho
  /// dos veces —pasa barriendo una pila de papeles, cuando no se recuerda si
  /// esa ya fue—. Un escaneo que desmarcara perdería justo la boleta que se
  /// acaba de confirmar, y en silencio.
  bool mark(OrderListItem order) {
    if (state.containsKey(order.id)) return false;
    state = {...state, order.id: DeliveryLine.of(order)};
    return true;
  }

  /// Cambia lo que paga una boleta ya marcada. Si no está marcada no hace nada:
  /// cobrar algo que nadie dijo que se entregó sería inventar el movimiento.
  void setPayment(
    String orderId, {
    required int amount,
    required PaymentMethod method,
    String? reference,
  }) {
    final line = state[orderId];
    if (line == null) return;
    state = {
      ...state,
      orderId: line.copyWith(amount: amount, method: method, paymentReference: reference),
    };
  }

  void clear() => state = const {};
}

/// Lo marcado, en el orden en que aparece la lista y ya sumado.
@riverpod
DeliveryBatch deliveryBatch(Ref ref) {
  final selection = ref.watch(deliverySelectionProvider);
  if (selection.isEmpty) return const DeliveryBatch([]);

  // Se recorre la lista abierta y no el mapa para que la hoja del lote salga en
  // el mismo orden que la pantalla: quien marcó cuatro boletas de arriba abajo
  // espera encontrarlas así, no en el orden en que las fue tocando.
  final orders = ref.watch(openOrdersProvider).valueOrNull ?? const <OrderListItem>[];
  final ordered = [
    for (final order in orders)
      if (selection[order.id] case final line?) line,
  ];

  // Una boleta que dejó de estar abierta —la entregó otro teléfono mientras
  // esta seguía marcada— desaparece de `orders` pero no del mapa. Se conserva
  // para que el conteo no mienta; el intento de entregarla fallará con su
  // mensaje, que es mejor que borrarla de la vista sin decir nada.
  final missing = selection.keys.where(
    (id) => ordered.every((line) => line.orderId != id),
  );
  return DeliveryBatch([...ordered, for (final id in missing) selection[id]!]);
}
