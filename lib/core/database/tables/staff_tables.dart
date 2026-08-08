import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tablas espejo de personal (plan 0005 §6.2; plan 0004 §7.3).
///
/// Empleados, turnos y tarifas bajan y nunca suben: se administran en línea
/// (D11). La jornada sí es bidireccional — se marca de pie, junto a la persona
/// que acaba de entrar, que es exactamente donde no se puede contar con señal.
///
/// Las horas viajan como `HH:MM:SS` y aquí se guardan igual. Es texto y no un
/// `DateTime` a propósito: una hora de reloj no es un instante —no tiene día ni
/// zona— y meterla en un `DateTime` obligaría a inventarle una fecha que después
/// habría que recordar ignorar. Ordenadas como texto quedan en orden porque
/// vienen con cero a la izquierda, igual que las fechas `YYYY-MM-DD` del resto
/// del esquema.

@DataClassName('EmployeeEntry')
class EmployeeEntries extends Table with SyncedColumns {
  TextColumn get fullName => text().withLength(max: 120)();
  TextColumn get phone => text().withLength(max: 32).nullable()();

  /// La cuenta con la que esta persona entra al sistema, si tiene una (D6). La
  /// mayoría del personal no tiene: se le anota la jornada, no usa la app.
  TextColumn get userId => text().nullable()();

  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DataClassName('WorkShiftEntry')
class WorkShiftEntries extends Table with SyncedColumns {
  TextColumn get code => text().withLength(max: 20)();
  TextColumn get name => text().withLength(max: 80)();

  /// Ventana programada del turno, `HH:MM:SS`. Su duración es contra lo que se
  /// mide la hora extra sugerida, y por eso el turno viaja entero y no solo su
  /// nombre.
  TextColumn get startsAt => text().withLength(max: 8)();
  TextColumn get endsAt => text().withLength(max: 8)();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('PayrollRateEntry')
class PayrollRateEntries extends Table with SyncedColumns {
  /// `overtime_hour` es la única de la fase 1.
  TextColumn get code => text().withLength(max: 50)();

  TextColumn get amount => text().withLength(max: 20)();

  /// La ventana de vigencia, no solo el monto de hoy: la app valúa jornadas de
  /// días pasados y una tarifa que subió ayer no puede reescribir lo que se
  /// pagó la semana pasada. Mismo motivo por el que `service_price` viaja con
  /// sus fechas.
  TextColumn get validFrom => text().withLength(max: 10)();
  TextColumn get validTo => text().withLength(max: 10).nullable()();
}

@DataClassName('AttendanceRecordEntry')
class AttendanceRecordEntries extends Table with SyncedColumns {
  TextColumn get employeeId => text()();

  /// Fecha de negocio en `YYYY-MM-DD`.
  TextColumn get workDate => text().withLength(max: 10)();

  /// Nulo cuando alguien trabajó fuera de todo turno. Entonces no hay duración
  /// programada que exceder y el sistema no sugiere minutos extra: los dice una
  /// persona o no los dice nadie.
  TextColumn get shiftId => text().nullable()();

  TextColumn get clockIn => text().withLength(max: 8)();

  /// Nulo mientras la persona sigue trabajando.
  TextColumn get clockOut => text().withLength(max: 8).nullable()();

  /// Los minutos que alguien **confirmó** que se pagan. La sugerencia no está
  /// aquí y no puede estar (D8): se recalcula en cada lectura justamente para
  /// que no se pueda confundir con una decisión.
  IntColumn get overtimeMinutes => integer().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();
}
