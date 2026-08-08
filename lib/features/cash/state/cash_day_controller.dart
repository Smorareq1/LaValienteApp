import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/time/business_date.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../inventory/models/product.dart';
import '../data/cash_local_datasource.dart';
import '../data/expenses_repository.dart';
import '../domain/cash_day.dart';
import '../models/cash_entry.dart';
import '../models/expense.dart';

part 'cash_day_controller.g.dart';

/// El día que la Caja está mirando. Por omisión el de negocio (plan 0001 D8): a
/// las 19:00 en Cobán la caja del día sigue siendo la de hoy, aunque en UTC ya
/// sea mañana.
@riverpod
class CashDateFilter extends _$CashDateFilter {
  @override
  DateTime build() => businessDate();

  void update(DateTime date) => state = DateTime(date.year, date.month, date.day);
}

/// Los cobros de pedidos del día.
@riverpod
Stream<List<CashEntry>> cashOrderPayments(Ref ref) {
  final date = ref.watch(cashDateFilterProvider);
  return ref.watch(cashLocalDataSourceProvider).watchOrderPayments(isoDate(date));
}

/// Las ventas de insumo del día.
@riverpod
Stream<List<SupplySaleSummary>> cashSupplySales(Ref ref) {
  final date = ref.watch(cashDateFilterProvider);
  return ref.watch(inventoryRepositoryProvider).watchSalesByDate(isoDate(date));
}

/// Los gastos del día.
@riverpod
Stream<List<Expense>> cashExpenses(Ref ref) {
  final date = ref.watch(cashDateFilterProvider);
  return ref.watch(expensesRepositoryProvider).watchByDate(isoDate(date));
}

/// Las categorías que el formulario de gasto puede ofrecer.
///
/// Bajan del feed y se administran en línea (D11), así que un teléfono que nunca
/// sincronizó no tiene ninguna — y el formulario lo dice en vez de mostrar una
/// lista vacía sin explicación.
@riverpod
Stream<List<ExpenseCategory>> cashExpensesCategories(Ref ref) {
  return ref.watch(expensesRepositoryProvider).watchCategories();
}

/// El acta, si la fecha ya se cerró.
@riverpod
Stream<DayClosure?> cashClosure(Ref ref) {
  final date = ref.watch(cashDateFilterProvider);
  return ref.watch(cashLocalDataSourceProvider).watchClosure(isoDate(date));
}

/// El día entero, armado de sus cuatro fuentes.
///
/// Se compone aquí y no en una consulta porque son cuatro tablas que no se
/// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
/// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
@riverpod
CashDay cashDay(Ref ref) {
  final date = isoDate(ref.watch(cashDateFilterProvider));
  final payments = ref.watch(cashOrderPaymentsProvider).valueOrNull ?? const <CashEntry>[];
  final sales = ref.watch(cashSupplySalesProvider).valueOrNull ?? const <SupplySaleSummary>[];
  final expenses = ref.watch(cashExpensesProvider).valueOrNull ?? const <Expense>[];
  final closure = ref.watch(cashClosureProvider).valueOrNull;

  final incomes = <CashEntry>[
    ...payments,
    for (final sale in sales)
      // Una venta anulada no entra: ese dinero se devolvió y el servidor
      // tampoco la cuenta.
      if (!sale.isCancelled) _fromSale(sale),
  ]..sort(_byTimeDescending);

  return CashDay(date: date, incomes: incomes, expenses: expenses, closure: closure);
}

CashEntry _fromSale(SupplySaleSummary sale) {
  final products = sale.itemCount == 1 ? 'producto' : 'productos';
  return CashEntry(
    id: sale.id,
    kind: CashEntryKind.supplySale,
    title: sale.customerName ?? 'Venta de mostrador',
    subtitle: '${sale.itemCount} $products',
    amount: sale.total,
    method: sale.method,
    at: sale.createdAt,
    syncStatus: sale.syncStatus,
  );
}

/// Lo último que entró, arriba. Lo que no tiene hora —una venta que bajó del
/// feed sin `created_at`— se va al final en vez de fingir que ocurrió a
/// medianoche.
int _byTimeDescending(CashEntry a, CashEntry b) {
  final left = a.at;
  final right = b.at;
  if (left == null && right == null) return 0;
  if (left == null) return 1;
  if (right == null) return -1;
  return right.compareTo(left);
}

/// Si la fecha que se está mirando admite escrituras.
///
/// Es el candado del §14: un día cerrado se lee, no se escribe. La comprobación
/// de verdad la hace el servidor —el candado vive en sus services (plan 0005
/// D9)— y esto es para no ofrecer un botón que va a terminar en la cola de
/// revisión con el papel ya firmado.
@riverpod
bool cashDayIsLocked(Ref ref) => ref.watch(cashDayProvider).isClosed;
