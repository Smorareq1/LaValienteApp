import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../orders/data/orders_repository.dart';
import '../../orders/domain/order_capture.dart';
import '../models/delivery_line.dart';

part 'deliveries_repository.g.dart';

/// Cómo terminó el repaso: cuántas boletas salieron, cuánto entró y qué no pudo.
class DeliveryOutcome {
  const DeliveryOutcome({
    required this.delivered,
    required this.collected,
    required this.failures,
  });

  /// Boletas que quedaron entregadas.
  final int delivered;

  /// Centavos que entraron a la caja.
  final int collected;

  /// Una línea por boleta que no se pudo, ya con su porqué en español.
  final List<String> failures;

  bool get isClean => failures.isEmpty;
}

@riverpod
DeliveriesRepository deliveriesRepository(Ref ref) {
  return DeliveriesRepository(ref.watch(ordersRepositoryProvider));
}

/// El registro de entregas del lado de ingresos de la Caja (plan 0006 §7.1.1).
class DeliveriesRepository {
  const DeliveriesRepository(this._orders);

  final OrdersRepository _orders;

  /// Entrega cada boleta marcada, una por una.
  ///
  /// **No es una transacción, a propósito.** Son entregas independientes: si la
  /// séptima falla, deshacer las seis anteriores sería mentir sobre ropa que ya
  /// salió por la puerta. Lo que falla se nombra y se queda marcado para
  /// volver a intentarlo.
  Future<DeliveryOutcome> deliverAll(
    List<DeliveryLine> lines, {
    required String actorId,
  }) async {
    var delivered = 0;
    var collected = 0;
    final failures = <String>[];

    for (final line in lines) {
      final order = await _orders.detail(line.orderId);
      if (order == null) {
        failures.add('${line.label}: ya no está en este teléfono');
        continue;
      }

      final result = await _orders.deliver(
        order,
        // Vuelve todo. Conciliar prenda por prenda tiene su pantalla (§5.5) y
        // no cabe en un repaso de diez boletas; quien nota que falta algo entra
        // por ahí.
        delivered: {
          for (final garment in order.garments) garment.id: garment.quantity,
        },
        actorId: actorId,
        // Cobrar cero no es un pago: entregar sin que pague nada es fiar
        // entero, y eso se registra como saldo, no como un movimiento de Q0.
        payment: line.amount > 0
            ? PaymentDraft(
                amount: line.amount,
                method: line.method,
                reference: line.paymentReference,
              )
            : null,
      );

      result.match(
        (failure) => failures.add('${line.label}: ${failure.message}'),
        (_) {
          delivered++;
          collected += line.amount;
        },
      );
    }

    return DeliveryOutcome(
      delivered: delivered,
      collected: collected,
      failures: failures,
    );
  }
}
