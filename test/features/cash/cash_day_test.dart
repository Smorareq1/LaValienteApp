import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/money/payment_method.dart';
import 'package:la_valiente/features/cash/domain/cash_day.dart';
import 'package:la_valiente/features/cash/models/cash_entry.dart';
import 'package:la_valiente/features/cash/models/expense.dart';

CashEntry income(
  int amount, {
  PaymentMethod method = PaymentMethod.cash,
  CashEntryKind kind = CashEntryKind.orderPayment,
  RowSyncStatus syncStatus = RowSyncStatus.synced,
}) {
  return CashEntry(
    id: 'e-$amount-${kind.name}',
    kind: kind,
    title: 'Movimiento',
    amount: amount,
    method: method,
    syncStatus: syncStatus,
  );
}

Expense expense(
  int amount, {
  PaymentMethod method = PaymentMethod.cash,
  ExpenseStatus status = ExpenseStatus.paid,
  RowSyncStatus syncStatus = RowSyncStatus.synced,
}) {
  return Expense(
    id: 'g-$amount-${status.name}',
    expenseDate: '2026-07-18',
    categoryId: 'cat',
    categoryName: 'Insumos',
    concept: 'Gas',
    amount: amount,
    method: method,
    status: status,
    syncStatus: syncStatus,
    version: 1,
  );
}

void main() {
  group('la hoja del 18/07/26', () {
    // Las cifras del §6.1 del plan 0005, que son las del papel real.
    final day = CashDay(
      date: '2026-07-18',
      incomes: [
        income(80000),
        income(15000, method: PaymentMethod.transfer),
        income(4500, kind: CashEntryKind.supplySale),
      ],
      expenses: [expense(16100), expense(7000, method: PaymentMethod.transfer)],
    );

    test('separa lo que entró por pedidos de lo que entró por insumos', () {
      expect(day.ordersIncome, 95000);
      expect(day.suppliesIncome, 4500);
      expect(day.incomeTotal, 99500);
    });

    test('el neto es lo que entró menos lo que el día debe', () {
      expect(day.expensesTotal, 23100);
      expect(day.netTotal, 99500 - 23100);
    });

    test('el arqueo separa el efectivo de la transferencia', () {
      expect(day.income.cash, 84500);
      expect(day.income.transfer, 15000);
      expect(day.paidExpenses.cash, 16100);
      expect(day.paidExpenses.transfer, 7000);
    });

    test('el efectivo en caja es lo que entró en billetes menos lo que salió', () {
      // Una transferencia no está en ningún cajón, ni la que entró ni la que
      // salió: por eso el arqueo no las toca.
      expect(day.cashOnHand, 84500 - 16100);
    });
  });

  group('gastos pendientes', () {
    final day = CashDay(
      date: '2026-07-18',
      incomes: [income(50000)],
      expenses: [expense(10000), expense(3000, status: ExpenseStatus.pending)],
    );

    test('cuentan contra el día', () {
      expect(day.expensesTotal, 13000);
      expect(day.netTotal, 37000);
      expect(day.pendingExpensesTotal, 3000);
    });

    test('pero no contra el cajón: el dinero sigue adentro', () {
      // Es la diferencia que el cierre advierte. Meterlos en el arqueo haría que
      // la pantalla pidiera menos dinero del que de verdad hay.
      expect(day.paidExpenses.cash, 10000);
      expect(day.cashOnHand, 40000);
    });
  });

  group('estado del día', () {
    test('un día sin movimientos lo dice', () {
      const day = CashDay.empty('2026-07-18');
      expect(day.hasMovement, isFalse);
      expect(day.incomeTotal, 0);
      expect(day.netTotal, 0);
      expect(day.isClosed, isFalse);
    });

    test('cuenta lo capturado que todavía no subió', () {
      final day = CashDay(
        date: '2026-07-18',
        incomes: [income(1000, syncStatus: RowSyncStatus.pending)],
        expenses: [expense(500, syncStatus: RowSyncStatus.pending), expense(200)],
      );
      expect(day.pendingSyncCount, 2);
    });

    test('con acta viva la fecha está cerrada', () {
      final day = CashDay(
        date: '2026-07-18',
        incomes: const [],
        expenses: const [],
        closure: DayClosure(
          id: 'acta',
          closeDate: '2026-07-18',
          closedAt: DateTime.utc(2026, 7, 19, 1, 12),
          closedById: 'marta',
          netTotal: 76400,
        ),
      );
      expect(day.isClosed, isTrue);
    });
  });

  group('reparto por método', () {
    test('un método que esta versión no conoce cuenta como efectivo', () {
      // El backend hace lo mismo. El arqueo prefiere errar contando de más en el
      // cajón, porque esa diferencia se ve al contarlo.
      final split = Split.of([(1000, null), (500, PaymentMethod.transfer)]);
      expect(split.cash, 1000);
      expect(split.transfer, 500);
      expect(split.total, 1500);
    });
  });
}
