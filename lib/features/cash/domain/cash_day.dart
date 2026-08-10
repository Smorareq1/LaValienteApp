import '../../../core/money/payment_method.dart';
import '../models/cash_entry.dart';
import '../models/expense.dart';

/// Un monto partido en las dos formas en que la lavandería recibe dinero.
///
/// La fila rosada de la hoja es una transferencia; lo que no está marcado es
/// efectivo. Separarlas es todo el punto del arqueo: el cajón solo se puede
/// contra la mitad de efectivo.
class Split {
  const Split({this.cash = 0, this.transfer = 0});

  final int cash;
  final int transfer;

  int get total => cash + transfer;

  /// Suma pares monto/método. Un método que esta versión no conoce cuenta como
  /// efectivo, que es lo que el backend hace también: el arqueo prefiere errar
  /// contando de más en el cajón, porque esa diferencia se ve al contarlo.
  static Split of(Iterable<(int, PaymentMethod?)> amounts) {
    var cash = 0;
    var transfer = 0;
    for (final (amount, method) in amounts) {
      if (method == PaymentMethod.transfer) {
        transfer += amount;
      } else {
        cash += amount;
      }
    }
    return Split(cash: cash, transfer: transfer);
  }
}

/// El día de Caja: la hoja de Registro Diario en pantalla (plan 0006 §7.1).
///
/// Aritmética pura, gemela de `daily_close/totals.py`: son las cifras que
/// alguien compara contra el dinero de un cajón, así que tienen que poder
/// probarse sin base de datos y decir lo mismo que dirá el cierre.
///
/// Esta es la **vista previa local**. La cifra oficial es la del servidor, y
/// cuando difiera manda la suya (plan 0004 D10) — aquí no se finge lo contrario.
class CashDay {
  const CashDay({
    required this.date,
    required this.incomes,
    required this.expenses,
    this.closure,
  });

  const CashDay.empty(this.date) : incomes = const [], expenses = const [], closure = null;

  /// `YYYY-MM-DD`.
  final String date;

  final List<CashEntry> incomes;
  final List<Expense> expenses;

  /// El acta, si la fecha está cerrada.
  final DayClosure? closure;

  bool get isClosed => closure != null;

  Iterable<CashEntry> get _orderPayments =>
      incomes.where((entry) => entry.kind == CashEntryKind.orderPayment);

  Iterable<CashEntry> get _supplySales =>
      incomes.where((entry) => entry.kind == CashEntryKind.supplySale);

  int get ordersIncome => _orderPayments.fold(0, (sum, entry) => sum + entry.amount);

  int get suppliesIncome => _supplySales.fold(0, (sum, entry) => sum + entry.amount);

  int get incomeTotal => ordersIncome + suppliesIncome;

  /// Todo lo que el día debe, pagado o no: es lo que la hoja anota y lo que
  /// resta del neto.
  int get expensesTotal => expenses.fold(0, (sum, expense) => sum + expense.amount);

  /// Lo que el día debe y todavía no ha salido del cajón.
  int get pendingExpensesTotal => expenses
      .where((expense) => expense.isPending)
      .fold(0, (sum, expense) => sum + expense.amount);

  int get netTotal => incomeTotal - expensesTotal;

  Split get income =>
      Split.of([for (final entry in incomes) (entry.amount, entry.method)]);

  /// Solo lo pagado: un gasto `pending` cuenta contra el día pero el cajón nunca
  /// lo vio, y meterlo aquí haría que el arqueo pidiera menos dinero del que hay.
  Split get paidExpenses => Split.of([
    for (final expense in expenses)
      if (!expense.isPending) (expense.amount, expense.method),
  ]);

  /// Lo que debería haber en efectivo: lo que entró en billetes menos lo que
  /// salió en billetes.
  int get cashOnHand => income.cash - paidExpenses.cash;

  bool get hasMovement => incomes.isNotEmpty || expenses.isNotEmpty;

  /// Capturas del día que todavía no subieron. El cierre las advierte, porque un
  /// día cerrado con movimientos sin sincronizar se cierra incompleto.
  int get pendingSyncCount =>
      incomes.where((entry) => entry.pendingSync).length +
      expenses.where((expense) => expense.pendingSync).length;
}
