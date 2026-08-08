/// Un pedido listo para entregar, tal como se muestra en la lista corta de
/// Inicio (Plan 0006 §4.1).
class ReadyOrder {
  const ReadyOrder({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.pieces,
    required this.total,
    required this.balance,
    this.receivedAtLabel,
    this.pendingSync = false,
  });

  final String id;

  /// Número diario, o folio provisional `P-n` si aún no sincroniza.
  final String reference;

  final String customerName;
  final int pieces;

  /// En centavos, como en todo lo demás que es dinero.
  final int total;

  /// Saldo pendiente; `0` si está pagado.
  final int balance;

  /// Hora de recepción ya formateada para mostrar.
  final String? receivedAtLabel;

  /// El pedido todavía no subió al servidor (Plan 0004).
  final bool pendingSync;

  bool get isPaid => balance <= 0;
}

/// Todo lo que la pantalla Inicio necesita para responder "¿cómo va el día?".
///
/// Se arma entero contra la BD local (plan 0004 D1): las cifras son las mismas
/// que la Caja suma para el día de hoy y los contadores salen de los pedidos con
/// fecha de hoy. Que no dependa de la red es el punto — Inicio es la primera
/// pantalla que se abre en la mañana, y muchas veces antes de que el primer
/// pull termine.
class HomeSummary {
  const HomeSummary({
    required this.collectedToday,
    required this.collectedCash,
    required this.collectedTransfer,
    required this.expensesToday,
    required this.receivable,
    required this.receivedCount,
    required this.inProcessCount,
    required this.readyCount,
    required this.deliveredCount,
    required this.readyOrders,
    this.lastSyncedAtLabel,
  });

  /// Estado inicial: el día todavía no tiene movimientos registrados.
  const HomeSummary.empty()
      : this(
          collectedToday: 0,
          collectedCash: 0,
          collectedTransfer: 0,
          expensesToday: 0,
          receivable: 0,
          receivedCount: 0,
          inProcessCount: 0,
          readyCount: 0,
          deliveredCount: 0,
          readyOrders: const [],
        );

  /// Cobrado en el día (pedidos + ventas de insumo), en centavos.
  final int collectedToday;
  final int collectedCash;
  final int collectedTransfer;

  final int expensesToday;

  /// Saldo por cobrar de los pedidos del día.
  final int receivable;

  final int receivedCount;
  final int inProcessCount;
  final int readyCount;
  final int deliveredCount;

  /// Lista corta (≤ 5) de pedidos listos para entregar.
  final List<ReadyOrder> readyOrders;

  final String? lastSyncedAtLabel;

  /// Proporción del cobro que entró en efectivo, para la barra de arqueo.
  /// Cuando no hay cobros el reparto es 50/50 y la barra se ve neutra.
  double get cashShare =>
      collectedToday <= 0 ? 0.5 : (collectedCash / collectedToday).clamp(0.0, 1.0);

  bool get hasMovement => collectedToday > 0 || expensesToday > 0;
}
