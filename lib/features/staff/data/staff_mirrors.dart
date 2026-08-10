import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejos de personal: empleados, turnos, tarifas y jornadas.
///
/// Solo la jornada es bidireccional. Los otros tres bajan y nunca suben: el
/// personal se administra en línea (plan 0005 D11), y quién es empleado o
/// cuánto vale una hora extra no son decisiones que se tomen de pie en el
/// mostrador.
List<TableMirror<DataClass>> staffMirrors(AppDatabase database) => [
  EmployeeMirror(database),
  WorkShiftMirror(database),
  PayrollRateMirror(database),
  AttendanceRecordMirror(database),
];

class EmployeeMirror extends TableMirror<EmployeeEntry> {
  const EmployeeMirror(super.database);

  @override
  String get entity => 'employee';

  @override
  TableInfo<Table, EmployeeEntry> get table => database.employeeEntries;

  @override
  EmployeeEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return EmployeeEntriesCompanion(
      fullName: Value(data['full_name'] as String),
      phone: Value(data['phone'] as String?),
      userId: Value(data['user_id'] as String?),
      notes: Value(data['notes'] as String?),
      isActive: Value(data['is_active'] as bool),
    );
  }
}

class WorkShiftMirror extends TableMirror<WorkShiftEntry> {
  const WorkShiftMirror(super.database);

  @override
  String get entity => 'work_shift';

  @override
  TableInfo<Table, WorkShiftEntry> get table => database.workShiftEntries;

  @override
  WorkShiftEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return WorkShiftEntriesCompanion(
      code: Value(data['code'] as String),
      name: Value(data['name'] as String),
      startsAt: Value(data['starts_at'] as String),
      endsAt: Value(data['ends_at'] as String),
      isActive: Value(data['is_active'] as bool),
      sortOrder: Value(data['sort_order'] as int),
    );
  }
}

class PayrollRateMirror extends TableMirror<PayrollRateEntry> {
  const PayrollRateMirror(super.database);

  @override
  String get entity => 'payroll_rate';

  @override
  TableInfo<Table, PayrollRateEntry> get table => database.payrollRateEntries;

  @override
  PayrollRateEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return PayrollRateEntriesCompanion(
      code: Value(data['code'] as String),
      amount: Value(data['amount'] as String),
      validFrom: Value(data['valid_from'] as String),
      validTo: Value(data['valid_to'] as String?),
    );
  }
}

class AttendanceRecordMirror extends TableMirror<AttendanceRecordEntry> {
  const AttendanceRecordMirror(super.database);

  @override
  String get entity => 'attendance_record';

  @override
  TableInfo<Table, AttendanceRecordEntry> get table => database.attendanceRecordEntries;

  @override
  AttendanceRecordEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return AttendanceRecordEntriesCompanion(
      employeeId: Value(data['employee_id'] as String),
      workDate: Value(data['work_date'] as String),
      shiftId: Value(data['shift_id'] as String?),
      clockIn: Value(data['clock_in'] as String),
      clockOut: Value(data['clock_out'] as String?),
      // Los minutos confirmados. El feed no manda la sugerencia y no debe: se
      // recalcula al leer, contra el turno de esta misma fila.
      overtimeMinutes: Value(data['overtime_minutes'] as int),
      notes: Value(data['notes'] as String?),
    );
  }
}
