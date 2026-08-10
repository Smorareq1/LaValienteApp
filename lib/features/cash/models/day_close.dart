import '../../../core/money/fixed2.dart';

/// Las cifras del día (plan 0005 §6.1), estén moviéndose o ya congeladas.
///
/// Es la forma que comparten el preview y el acta, igual que en el backend:
/// lo que la pantalla muestra a las cuatro de la tarde y lo que muestra con el
/// cajón ya contado se diferencian en si todavía pueden cambiar, no en qué
/// significan.
///
/// Todo en centavos: el servidor las manda como texto (`"764.00"`) y aquí
/// entran por [Fixed2] como en cualquier otra frontera de dinero.
class DayFigures {
  const DayFigures({
    required this.closeDate,
    required this.ordersIncome,
    required this.suppliesIncome,
    required this.expensesTotal,
    required this.netTotal,
    required this.cashIncome,
    required this.transferIncome,
    required this.cashExpenses,
    required this.transferExpenses,
    required this.ordersDelivered,
  });

  /// `YYYY-MM-DD`.
  final String closeDate;

  final int ordersIncome;
  final int suppliesIncome;

  /// Todo lo que el día debe, pagado o no.
  final int expensesTotal;

  final int netTotal;

  final int cashIncome;
  final int transferIncome;

  /// Solo lo que de verdad salió del cajón: un gasto `pending` cuenta contra el
  /// día pero no contra el arqueo.
  final int cashExpenses;
  final int transferExpenses;

  final int ordersDelivered;

  int get incomeTotal => ordersIncome + suppliesIncome;

  /// Lo que el cajón debería tener al contarlo.
  int get cashOnHand => cashIncome - cashExpenses;

  /// Lo que el día debe y todavía no ha salido: la diferencia entre lo que la
  /// hoja anota y lo que el cajón vio.
  int get pendingExpenses => expensesTotal - (cashExpenses + transferExpenses);

  static int _money(Object? value) => Fixed2.parse(value as String?) ?? 0;
}

/// El día como está ahora mismo (`GET /daily-close/preview`).
class DayClosePreview extends DayFigures {
  const DayClosePreview({
    required super.closeDate,
    required super.ordersIncome,
    required super.suppliesIncome,
    required super.expensesTotal,
    required super.netTotal,
    required super.cashIncome,
    required super.transferIncome,
    required super.cashExpenses,
    required super.transferExpenses,
    required super.ordersDelivered,
    required this.isClosed,
    this.warnings = const [],
    this.closureId,
  });

  final bool isClosed;

  /// Lo que vale la pena leer antes de firmar, **en códigos** (`open_tickets:3`,
  /// `uncollected:120.00`, `pending_expenses:80.00`, `reopened`). El servidor es
  /// el único que puede contarlas —ve las boletas de todos los dispositivos— y
  /// la app es la que las dice en español: `closeWarnings` las traduce.
  final List<String> warnings;

  /// Bajo qué acta quedó archivado, si ya se cerró.
  final String? closureId;

  factory DayClosePreview.fromJson(Map<String, dynamic> json) {
    return DayClosePreview(
      closeDate: json['close_date'] as String,
      ordersIncome: DayFigures._money(json['orders_income']),
      suppliesIncome: DayFigures._money(json['supplies_income']),
      expensesTotal: DayFigures._money(json['expenses_total']),
      netTotal: DayFigures._money(json['net_total']),
      cashIncome: DayFigures._money(json['cash_income']),
      transferIncome: DayFigures._money(json['transfer_income']),
      cashExpenses: DayFigures._money(json['cash_expenses']),
      transferExpenses: DayFigures._money(json['transfer_expenses']),
      ordersDelivered: json['orders_delivered'] as int? ?? 0,
      isClosed: json['is_closed'] as bool? ?? false,
      warnings: [
        for (final warning in json['warnings'] as List<dynamic>? ?? const [])
          warning as String,
      ],
      closureId: json['closure_id'] as String?,
    );
  }
}

/// El acta tal como quedó archivada (plan 0005 D9).
///
/// Guarda cada cifra aunque cada cifra sea derivable: eso **es** un acta. Dice
/// lo que los números decían la noche que alguien contó el cajón, y sigue
/// diciéndolo cuando se renombre una categoría o cambie la forma de sumar.
class DayClosureRecord extends DayFigures {
  const DayClosureRecord({
    required this.id,
    required super.closeDate,
    required super.ordersIncome,
    required super.suppliesIncome,
    required super.expensesTotal,
    required super.netTotal,
    required super.cashIncome,
    required super.transferIncome,
    required super.cashExpenses,
    required super.transferExpenses,
    required super.ordersDelivered,
    required this.closedById,
    required this.closedAt,
    required this.version,
    this.notes,
    this.reopenedById,
    this.reopenReason,
  });

  final String id;
  final String closedById;
  final DateTime closedAt;
  final int version;
  final String? notes;

  /// Quién reabrió el día y por qué. Reabrir **es** la lápida (D9): el acta
  /// reabierta se conserva, porque un día cerrado en Q764 y luego reabierto es
  /// un hecho que alguien tiene que poder encontrar.
  final String? reopenedById;
  final String? reopenReason;

  bool get isReopened => reopenedById != null;

  factory DayClosureRecord.fromJson(Map<String, dynamic> json) {
    return DayClosureRecord(
      id: json['id'] as String,
      closeDate: json['close_date'] as String,
      ordersIncome: DayFigures._money(json['orders_income']),
      suppliesIncome: DayFigures._money(json['supplies_income']),
      expensesTotal: DayFigures._money(json['expenses_total']),
      netTotal: DayFigures._money(json['net_total']),
      cashIncome: DayFigures._money(json['cash_income']),
      transferIncome: DayFigures._money(json['transfer_income']),
      cashExpenses: DayFigures._money(json['cash_expenses']),
      transferExpenses: DayFigures._money(json['transfer_expenses']),
      ordersDelivered: json['orders_delivered'] as int? ?? 0,
      closedById: json['closed_by_id'] as String,
      closedAt: DateTime.parse(json['closed_at'] as String).toUtc(),
      version: json['version'] as int? ?? 1,
      notes: json['notes'] as String?,
      reopenedById: json['reopened_by_id'] as String?,
      reopenReason: json['reopen_reason'] as String?,
    );
  }
}
