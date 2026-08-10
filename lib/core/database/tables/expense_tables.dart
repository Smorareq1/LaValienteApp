import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tablas espejo de gastos (plan 0005 §6.4; plan 0004 §7.3).
///
/// La categoría baja del servidor y nunca sube: se administran en línea (D11).
/// El gasto sí es bidireccional — es la mitad derecha de la hoja de Registro
/// Diario y el mostrador lo anota con o sin señal.

@DataClassName('ExpenseCategoryEntry')
class ExpenseCategoryEntries extends Table with SyncedColumns {
  TextColumn get name => text().withLength(max: 80)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ExpenseEntry')
class ExpenseEntries extends Table with SyncedColumns {
  /// Fecha de negocio en `YYYY-MM-DD`: el día al que el gasto pertenece, que no
  /// es el instante en que alguien lo tecleó.
  TextColumn get expenseDate => text().withLength(max: 10)();

  /// Solo el id. El nombre se lee uniendo con [ExpenseCategoryEntries], que es
  /// la razón de espejarlas: copiarlo aquí congelaría el nombre viejo el día
  /// que se corrija una categoría.
  TextColumn get categoryId => text()();

  TextColumn get concept => text().withLength(max: 160)();
  TextColumn get amount => text().withLength(max: 20)();

  /// `cash` o `transfer`. El arqueo del día se parte por esta columna.
  TextColumn get method => text().withLength(max: 20)();

  /// `paid` o `pending`. Un gasto pendiente cuenta contra el día pero todavía
  /// no salió del cajón, y esa diferencia es la que el cierre advierte.
  TextColumn get status => text().withLength(max: 20)();

  /// Los tres vínculos del §6.2 y §6.3: a quién se le pagó, qué jornada y qué
  /// lote. Ninguno se edita después (el servidor tampoco los deja): mover un
  /// gasto de una jornada a otra no es una corrección, es otro pago.
  TextColumn get employeeId => text().nullable()();
  TextColumn get attendanceRecordId => text().nullable()();
  TextColumn get productLotId => text().nullable()();

  TextColumn get observations => text().nullable()();
  TextColumn get createdById => text()();

  /// Un gasto anulado baja como lápida y el motivo viaja con ella, para que el
  /// total del día se pueda explicar también en el dispositivo.
  TextColumn get voidReason => text().nullable()();
}
