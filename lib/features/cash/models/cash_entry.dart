import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/payment_method.dart';

/// De dónde salió un ingreso del día.
///
/// La hoja de papel los anota en la misma columna y los distingue con un color;
/// aquí los distingue este enum, que además decide adónde lleva el tap.
enum CashEntryKind {
  /// Un cobro contra una boleta: anticipo, abono o saldo al entregar.
  orderPayment,

  /// Una venta de insumo en el mostrador.
  supplySale,
}

/// Una línea de la lista de ingresos del día (plan 0006 §7.1).
class CashEntry {
  const CashEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.amount,
    required this.syncStatus,
    this.method,
    this.subtitle,
    this.at,
    this.route,
  });

  final String id;
  final CashEntryKind kind;

  /// Cómo se llama el movimiento en el mostrador: "Pedido No. 7 · Ana R.".
  final String title;

  /// En centavos.
  final int amount;

  final PaymentMethod? method;

  /// Segunda línea: hora, cuántos productos, si es anticipo.
  final String? subtitle;

  /// La hora a la que entró el dinero, si se sabe.
  final DateTime? at;

  /// Dónde verlo completo, si hay dónde.
  final String? route;

  final RowSyncStatus syncStatus;

  bool get pendingSync => syncStatus == RowSyncStatus.pending;

  bool get needsReview => syncStatus == RowSyncStatus.rejected;
}

/// El acta que cerró una fecha, cuando la fecha está cerrada.
///
/// «Cerrada» aquí es «hay un acta viva con esa fecha»: reabrir es la lápida
/// (plan 0005 D9), así que una fila con `deletedAt` no cierra nada.
class DayClosure {
  const DayClosure({
    required this.id,
    required this.closeDate,
    required this.closedAt,
    required this.closedById,
    required this.netTotal,
    this.notes,
  });

  final String id;
  final String closeDate;
  final DateTime closedAt;
  final String closedById;

  /// El neto que el acta dejó escrito. No se recalcula: es lo que los números
  /// decían la noche que alguien contó el cajón.
  final int netTotal;

  final String? notes;
}
