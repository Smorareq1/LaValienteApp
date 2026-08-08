import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../models/expense.dart';

part 'expenses_local_datasource.g.dart';

/// Lectura y escritura de gastos en la BD local. I/O puro sobre Drift.
class ExpensesLocalDataSource {
  const ExpensesLocalDataSource(this._database);

  final AppDatabase _database;

  /// Las categorías que se pueden elegir, en el orden que fijó el servidor.
  Stream<List<ExpenseCategory>> watchCategories() {
    final query = _database.select(_database.expenseCategoryEntries)
      ..where((row) => row.deletedAt.isNull() & row.isActive.equals(true))
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.name),
      ]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          ExpenseCategory(
            id: row.id,
            name: row.name,
            isActive: row.isActive,
            sortOrder: row.sortOrder,
          ),
      ],
    );
  }

  /// Los gastos de [date], agrupados por categoría.
  ///
  /// Se une con la categoría para mostrar su nombre: copiarlo en la fila del
  /// gasto habría congelado el nombre viejo el día que se corrija una categoría.
  ///
  /// Ordenar por hora sería lo natural y no se puede: el feed no manda el
  /// `created_at` de un gasto. Así que se ordena como la hoja de papel los
  /// agrupa —por tipo de gasto— en vez de dejarlos en el orden arbitrario en que
  /// el pull los fue insertando.
  Stream<List<Expense>> watchByDate(String date) {
    final expenses = _database.expenseEntries;
    final categories = _database.expenseCategoryEntries;

    final query =
        _database.select(expenses).join([
            leftOuterJoin(categories, categories.id.equalsExp(expenses.categoryId)),
          ])
          ..where(expenses.deletedAt.isNull() & expenses.expenseDate.equals(date))
          ..orderBy([
            OrderingTerm.asc(categories.sortOrder),
            OrderingTerm.asc(categories.name),
            OrderingTerm.asc(expenses.concept),
          ]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          _toExpense(row.readTable(expenses), row.readTableOrNull(categories)?.name),
      ],
    );
  }

  Future<Expense?> byId(String id) async {
    final expenses = _database.expenseEntries;
    final categories = _database.expenseCategoryEntries;

    final query =
        _database.select(expenses).join([
            leftOuterJoin(categories, categories.id.equalsExp(expenses.categoryId)),
          ])
          ..where(expenses.id.equals(id))
          ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final entry = row.readTable(expenses);
    if (entry.deletedAt != null) return null;
    return _toExpense(entry, row.readTableOrNull(categories)?.name);
  }

  static Expense _toExpense(ExpenseEntry row, String? categoryName) {
    return Expense(
      id: row.id,
      expenseDate: row.expenseDate,
      categoryId: row.categoryId,
      categoryName: categoryName ?? 'Categoría sin sincronizar',
      concept: row.concept,
      amount: Fixed2.parse(row.amount) ?? 0,
      method: PaymentMethod.fromWire(row.method),
      status: ExpenseStatus.fromWire(row.status),
      syncStatus: RowSyncStatus.values.byName(row.syncStatus),
      version: row.version,
      observations: row.observations,
      employeeId: row.employeeId,
      attendanceRecordId: row.attendanceRecordId,
      productLotId: row.productLotId,
    );
  }

  /// Escribe el gasto capturado aquí y lo deja `pending`.
  ///
  /// Corre dentro de la transacción del repositorio, junto con su operación.
  Future<void> insertLocal({
    required String id,
    required String expenseDate,
    required String categoryId,
    required String concept,
    required int amount,
    required PaymentMethod method,
    required ExpenseStatus status,
    required String createdById,
    String? observations,
  }) {
    return _database
        .into(_database.expenseEntries)
        .insert(
          ExpenseEntriesCompanion.insert(
            id: id,
            syncStatus: Value(RowSyncStatus.pending.name),
            expenseDate: expenseDate,
            categoryId: categoryId,
            concept: concept,
            amount: Fixed2.format(amount),
            method: method.wire,
            status: status.wire,
            observations: Value(observations),
            createdById: createdById,
          ),
        );
  }

  /// Reescribe lo corregible de un gasto y lo vuelve a dejar `pending`.
  ///
  /// Los vínculos (empleado, jornada, lote) no están: el servidor tampoco los
  /// deja mover.
  Future<void> updateLocal({
    required String id,
    required String expenseDate,
    required String categoryId,
    required String concept,
    required int amount,
    required PaymentMethod method,
    required ExpenseStatus status,
    String? observations,
  }) {
    return (_database.update(
      _database.expenseEntries,
    )..where((row) => row.id.equals(id))).write(
      ExpenseEntriesCompanion(
        syncStatus: Value(RowSyncStatus.pending.name),
        expenseDate: Value(expenseDate),
        categoryId: Value(categoryId),
        concept: Value(concept),
        amount: Value(Fixed2.format(amount)),
        method: Value(method.wire),
        status: Value(status.wire),
        observations: Value(observations),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
ExpensesLocalDataSource expensesLocalDataSource(Ref ref) {
  return ExpensesLocalDataSource(ref.watch(appDatabaseProvider));
}
