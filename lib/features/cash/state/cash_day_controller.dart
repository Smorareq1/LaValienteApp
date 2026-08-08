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

/// Los cobros de pedidos de una fecha.
@riverpod
Stream<List<CashEntry>> cashOrderPayments(Ref ref, String date) {
  return ref.watch(cashLocalDataSourceProvider).watchOrderPayments(date);
}

/// Las ventas de insumo de una fecha.
@riverpod
Stream<List<SupplySaleSummary>> cashSupplySales(Ref ref, String date) {
  return ref.watch(inventoryRepositoryProvider).watchSalesByDate(date);
}

/// Los gastos de una fecha.
@riverpod
Stream<List<Expense>> cashExpenses(Ref ref, String date) {
  return ref.watch(expensesRepositoryProvider).watchByDate(date);
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
Stream<DayClosure?> cashClosure(Ref ref, String date) {
  return ref.watch(cashLocalDataSourceProvider).watchClosure(date);
}

/// El día entero, armado de sus cuatro fuentes.
///
/// Se compone aquí y no en una consulta porque son cuatro tablas que no se
/// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
/// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
///
/// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
/// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
/// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
@riverpod
CashDay cashDay(Ref ref, String date) {
  final payments =
      ref.watch(cashOrderPaymentsProvider(date)).valueOrNull ?? const <CashEntry>[];
  final sales =
      ref.watch(cashSupplySalesProvider(date)).valueOrNull ?? const <SupplySaleSummary>[];
  final expenses = ref.watch(cashExpensesProvider(date)).valueOrNull ?? const <Expense>[];
  final closure = ref.watch(cashClosureProvider(date)).valueOrNull;

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

/// El día que la pantalla de Caja está mirando: [cashDay] con la fecha del chip.
///
/// De aquí sale el candado del §14 —un día cerrado se lee, no se escribe—. La
/// comprobación de verdad la hace el servidor, porque el candado vive en sus
/// services (plan 0005 D9); esto es para no ofrecer un botón que va a terminar
/// en la cola de revisión con el papel ya firmado.
@riverpod
CashDay selectedCashDay(Ref ref) {
  return ref.watch(cashDayProvider(isoDate(ref.watch(cashDateFilterProvider))));
}
