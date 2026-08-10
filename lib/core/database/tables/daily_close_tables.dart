import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tabla espejo del cierre del día (plan 0005 §6.1).
///
/// Cerrar es online-only (D11), así que esta tabla nunca sube nada. Baja porque
/// el acta es lo que le dice a cada dispositivo que la fecha quedó bloqueada,
/// **antes** de que alguien intente escribir en ella: sin el espejo, un gasto
/// capturado sin señal contra un día ya cerrado se descubriría recién al
/// sincronizar, en la cola de revisión y con el papel ya firmado.
@DataClassName('DailyClosureEntry')
class DailyClosureEntries extends Table with SyncedColumns {
  TextColumn get closeDate => text().withLength(max: 10)();

  TextColumn get ordersIncome => text().withLength(max: 20)();
  TextColumn get suppliesIncome => text().withLength(max: 20)();
  TextColumn get expensesTotal => text().withLength(max: 20)();
  TextColumn get netTotal => text().withLength(max: 20)();

  TextColumn get cashIncome => text().withLength(max: 20)();
  TextColumn get transferIncome => text().withLength(max: 20)();

  /// Solo lo que de verdad salió del cajón: un gasto `pending` cuenta contra el
  /// día pero no contra el arqueo.
  TextColumn get cashExpenses => text().withLength(max: 20)();
  TextColumn get transferExpenses => text().withLength(max: 20)();

  IntColumn get ordersDelivered => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get closedById => text()();
  DateTimeColumn get closedAt => dateTime()();

  /// Quién reabrió el día y por qué. Reabrir es **la lápida misma** (D9): el
  /// servidor pone `deleted_at` y estas dos columnas le ponen nombre. De ahí que
  /// «la fecha está cerrada» se lea aquí como «hay una fila viva con esa fecha»
  /// y no como «existe un acta»: el acta reabierta se conserva, y tiene que
  /// conservarse, porque un día cerrado en Q764 y luego reabierto es un hecho.
  TextColumn get reopenedById => text().nullable()();
  TextColumn get reopenReason => text().nullable()();
}
