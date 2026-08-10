import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejos de la Caja: categorías de gasto, gastos y el acta del cierre.
///
/// Solo el gasto es bidireccional. La categoría y el acta bajan y nunca suben:
/// las categorías se administran en línea y cerrar un día exige verlo entero
/// (plan 0005 D11).
List<TableMirror<DataClass>> cashMirrors(AppDatabase database) => [
  ExpenseCategoryMirror(database),
  ExpenseMirror(database),
  DailyClosureMirror(database),
];

DateTime? _instant(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toUtc();

class ExpenseCategoryMirror extends TableMirror<ExpenseCategoryEntry> {
  const ExpenseCategoryMirror(super.database);

  @override
  String get entity => 'expense_category';

  @override
  TableInfo<Table, ExpenseCategoryEntry> get table => database.expenseCategoryEntries;

  @override
  ExpenseCategoryEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ExpenseCategoryEntriesCompanion(
      name: Value(data['name'] as String),
      isActive: Value(data['is_active'] as bool),
      sortOrder: Value(data['sort_order'] as int),
    );
  }
}

class ExpenseMirror extends TableMirror<ExpenseEntry> {
  const ExpenseMirror(super.database);

  @override
  String get entity => 'expense';

  @override
  TableInfo<Table, ExpenseEntry> get table => database.expenseEntries;

  @override
  ExpenseEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ExpenseEntriesCompanion(
      expenseDate: Value(data['expense_date'] as String),
      categoryId: Value(data['category_id'] as String),
      concept: Value(data['concept'] as String),
      amount: Value(data['amount'] as String),
      method: Value(data['method'] as String),
      status: Value(data['status'] as String),
      employeeId: Value(data['employee_id'] as String?),
      attendanceRecordId: Value(data['attendance_record_id'] as String?),
      productLotId: Value(data['product_lot_id'] as String?),
      observations: Value(data['observations'] as String?),
      createdById: Value(data['created_by_id'] as String),
      voidReason: Value(data['void_reason'] as String?),
    );
  }
}

class DailyClosureMirror extends TableMirror<DailyClosureEntry> {
  const DailyClosureMirror(super.database);

  @override
  String get entity => 'daily_closure';

  @override
  TableInfo<Table, DailyClosureEntry> get table => database.dailyClosureEntries;

  @override
  DailyClosureEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return DailyClosureEntriesCompanion(
      closeDate: Value(data['close_date'] as String),
      ordersIncome: Value(data['orders_income'] as String),
      suppliesIncome: Value(data['supplies_income'] as String),
      expensesTotal: Value(data['expenses_total'] as String),
      netTotal: Value(data['net_total'] as String),
      cashIncome: Value(data['cash_income'] as String),
      transferIncome: Value(data['transfer_income'] as String),
      cashExpenses: Value(data['cash_expenses'] as String),
      transferExpenses: Value(data['transfer_expenses'] as String),
      ordersDelivered: Value(data['orders_delivered'] as int),
      notes: Value(data['notes'] as String?),
      closedById: Value(data['closed_by_id'] as String),
      closedAt: Value(_instant(data['closed_at'])!),
      reopenedById: Value(data['reopened_by_id'] as String?),
      reopenReason: Value(data['reopen_reason'] as String?),
    );
  }
}
