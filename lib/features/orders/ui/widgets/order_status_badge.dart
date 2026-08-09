import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../models/order.dart';

/// El color de cada estado de pedido, en un solo sitio.
///
/// Vivía duplicado en la lista y en el detalle, y las dos copias ya no decían lo
/// mismo: una pintaba `anulado` en gris y la otra en rojo. El estado de una
/// boleta es de las pocas cosas que se leen de lejos y sin texto, así que el
/// color tiene que significar siempre lo mismo en las dos pantallas.
AppStatusTone orderStatusTone(OrderStatus? status) => switch (status) {
  null => AppStatusTone.neutral,
  OrderStatus.received => AppStatusTone.info,
  OrderStatus.inProgress => AppStatusTone.warning,
  OrderStatus.ready => AppStatusTone.success,
  OrderStatus.delivered => AppStatusTone.brand,
  OrderStatus.cancelled => AppStatusTone.error,
};

AppBadgeStatus _badgeStatus(OrderStatus status) => switch (status) {
  OrderStatus.received => AppBadgeStatus.received,
  OrderStatus.inProgress => AppBadgeStatus.inProgress,
  OrderStatus.ready => AppBadgeStatus.ready,
  OrderStatus.delivered => AppBadgeStatus.delivered,
  OrderStatus.cancelled => AppBadgeStatus.cancelled,
};

/// Píldora con punto para el estado de un pedido (la de la cabecera del
/// detalle).
///
/// Un estado que esta versión no conoce no se inventa: se dice que no se conoce.
/// El ciclo de vida lo define el servidor y estrenar uno exige su versión de
/// app, así que pintarlo como "recibido" sería mentir sobre dónde está la ropa.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status, this.compact = false});

  final OrderStatus? status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final value = status;
    if (value == null) {
      return const AppStatusBadge(
        label: 'Estado desconocido',
        size: AppStatusBadgeSize.sm,
      );
    }
    return AppBadge(status: _badgeStatus(value), compact: compact);
  }
}

/// Píldora compacta sin punto, para las filas de la lista, donde comparte
/// columna con el total y el saldo.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({super.key, required this.status});

  final OrderStatus? status;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: status?.label ?? 'Estado desconocido',
      size: AppStatusBadgeSize.sm,
      tone: orderStatusTone(status),
    );
  }
}
