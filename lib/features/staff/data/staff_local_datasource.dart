import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/fixed2.dart';
import '../domain/overtime.dart';
import '../models/staff.dart';

part 'staff_local_datasource.g.dart';

/// Lectura y escritura de personal en la BD local. I/O puro sobre Drift.
class StaffLocalDataSource {
  const StaffLocalDataSource(this._database);

  final AppDatabase _database;

  /// El personal activo, en orden alfabético.
  ///
  /// Alfabético y no por antigüedad porque la lista se usa para *buscar a una
  /// persona con el dedo*, de pie, mientras esa persona espera.
  Stream<List<Employee>> watchEmployees({bool includeArchived = false}) {
    final query = _database.select(_database.employeeEntries)
      ..where(
        (row) => includeArchived
            ? row.deletedAt.isNull()
            : row.deletedAt.isNull() & row.isActive.equals(true),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.fullName)]);

    return query.watch().map((rows) => rows.map(_toEmployee).toList());
  }

  Stream<List<WorkShift>> watchShifts({bool includeArchived = false}) {
    final query = _database.select(_database.workShiftEntries)
      ..where(
        (row) => includeArchived
            ? row.deletedAt.isNull()
            : row.deletedAt.isNull() & row.isActive.equals(true),
      )
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.startsAt),
      ]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          if (_toShift(row) case final shift?) shift,
      ],
    );
  }

  /// Todas las tarifas de un código, de la más nueva a la más vieja.
  ///
  /// La pantalla de §9.3 muestra la vigente destacada y el historial debajo, así
  /// que las quiere todas y no solo la de hoy.
  Stream<List<PayrollRate>> watchRates({String code = PayrollRate.overtimeCode}) {
    final query = _database.select(_database.payrollRateEntries)
      ..where((row) => row.deletedAt.isNull() & row.code.equals(code))
      ..orderBy([(row) => OrderingTerm.desc(row.validFrom)]);

    return query.watch().map((rows) => rows.map(_toRate).toList());
  }

  /// El día de cada empleado activo: su jornada si la tiene, el turno bajo el
  /// que la marcó y la tarifa que valúa sus minutos extra.
  ///
  /// Sale una fila por empleado **aunque no haya marcado**, porque la pantalla
  /// de §9.1 es una lista de personas y no una lista de jornadas: quien no ha
  /// entrado todavía es justamente a quien hay que marcarle la entrada.
  Stream<List<EmployeeDay>> watchDay(String date) {
    final employees = _database.employeeEntries;
    final records = _database.attendanceRecordEntries;
    final shifts = _database.workShiftEntries;

    final query =
        _database.select(employees).join([
            leftOuterJoin(
              records,
              records.employeeId.equalsExp(employees.id) &
                  records.workDate.equals(date) &
                  records.deletedAt.isNull(),
            ),
            leftOuterJoin(shifts, shifts.id.equalsExp(records.shiftId)),
          ])
          ..where(employees.deletedAt.isNull() & employees.isActive.equals(true))
          ..orderBy([OrderingTerm.asc(employees.fullName)]);

    // La tarifa se resuelve aparte y no en el join: es una sola por día, y
    // arrastrarla por cada fila la haría depender del orden de las ventanas de
    // vigencia dentro de una unión externa.
    return query.watch().asyncMap((rows) async {
      final rate = await rateOn(date);
      return [
        for (final row in rows)
          EmployeeDay(
            employee: _toEmployee(row.readTable(employees)),
            record: _toRecord(row.readTableOrNull(records)),
            shift: _toShift(row.readTableOrNull(shifts)),
            hourlyRate: rate?.amount,
          ),
      ];
    });
  }

  /// La tarifa que cubre [date], o `null` si ninguna la cubre.
  ///
  /// `null` no es cero: es que nadie dio de alta la tarifa de ese día, y la
  /// pantalla tiene que decirlo en vez de valuar una hora extra en Q0.00.
  Future<PayrollRate?> rateOn(
    String date, {
    String code = PayrollRate.overtimeCode,
  }) async {
    final query = _database.select(_database.payrollRateEntries)
      ..where((row) => row.deletedAt.isNull() & row.code.equals(code));

    final rows = await query.get();
    for (final row in rows) {
      final rate = _toRate(row);
      if (rate.coversDate(date)) return rate;
    }
    return null;
  }

  Future<AttendanceRecord?> recordById(String id) async {
    final query = _database.select(_database.attendanceRecordEntries)
      ..where((row) => row.id.equals(id))
      ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null || row.deletedAt != null) return null;
    return _toRecord(row);
  }

  /// La jornada abierta o cerrada de una persona ese día, si la tiene.
  ///
  /// Es la comprobación que evita marcarle dos entradas a alguien: el servidor
  /// también la rechazaría, pero se descubriría en la cola de revisión con el
  /// día ya avanzado.
  Future<AttendanceRecord?> recordFor({
    required String employeeId,
    required String date,
  }) async {
    final query = _database.select(_database.attendanceRecordEntries)
      ..where(
        (row) =>
            row.deletedAt.isNull() &
            row.employeeId.equals(employeeId) &
            row.workDate.equals(date),
      )
      ..limit(1);
    final row = await query.getSingleOrNull();
    return _toRecord(row);
  }

  /// Escribe la entrada capturada aquí y la deja `pending`.
  Future<void> insertLocal({
    required String id,
    required String employeeId,
    required String workDate,
    required ClockTime clockIn,
    String? shiftId,
    ClockTime? clockOut,
    int overtimeMinutes = 0,
    String? notes,
  }) {
    return _database
        .into(_database.attendanceRecordEntries)
        .insert(
          AttendanceRecordEntriesCompanion.insert(
            id: id,
            syncStatus: Value(RowSyncStatus.pending.name),
            employeeId: employeeId,
            workDate: workDate,
            shiftId: Value(shiftId),
            clockIn: clockIn.wire,
            clockOut: Value(clockOut?.wire),
            overtimeMinutes: Value(overtimeMinutes),
            notes: Value(notes),
          ),
        );
  }

  /// Reescribe lo que cambió de una jornada y la vuelve a dejar `pending`.
  ///
  /// Cada campo es opcional por separado porque el servidor aplica solo lo que
  /// venga en el cuerpo: mandar un `notes` nulo que nadie tocó borraría la nota
  /// que otro dispositivo escribió.
  Future<void> updateLocal({
    required String id,
    Value<String?> shiftId = const Value.absent(),
    Value<ClockTime> clockIn = const Value.absent(),
    Value<ClockTime?> clockOut = const Value.absent(),
    Value<int> overtimeMinutes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) {
    return (_database.update(
      _database.attendanceRecordEntries,
    )..where((row) => row.id.equals(id))).write(
      AttendanceRecordEntriesCompanion(
        syncStatus: Value(RowSyncStatus.pending.name),
        shiftId: shiftId,
        clockIn: clockIn.present ? Value(clockIn.value.wire) : const Value.absent(),
        clockOut: clockOut.present
            ? Value(clockOut.value?.wire)
            : const Value.absent(),
        overtimeMinutes: overtimeMinutes,
        notes: notes,
      ),
    );
  }

  static Employee _toEmployee(EmployeeEntry row) => Employee(
    id: row.id,
    fullName: row.fullName,
    isActive: row.isActive,
    version: row.version,
    phone: row.phone,
    userId: row.userId,
    notes: row.notes,
  );

  static PayrollRate _toRate(PayrollRateEntry row) => PayrollRate(
    id: row.id,
    code: row.code,
    amount: Fixed2.parse(row.amount) ?? 0,
    validFrom: row.validFrom,
    validTo: row.validTo,
    version: row.version,
  );

  /// `null` cuando la fila no trae horas interpretables, para saltarse ese turno
  /// en vez de tumbar la pantalla entera.
  static WorkShift? _toShift(WorkShiftEntry? row) {
    if (row == null) return null;
    final startsAt = ClockTime.parse(row.startsAt);
    final endsAt = ClockTime.parse(row.endsAt);
    if (startsAt == null || endsAt == null) return null;
    return WorkShift(
      id: row.id,
      code: row.code,
      name: row.name,
      startsAt: startsAt,
      endsAt: endsAt,
      isActive: row.isActive,
      sortOrder: row.sortOrder,
      version: row.version,
    );
  }

  static AttendanceRecord? _toRecord(AttendanceRecordEntry? row) {
    if (row == null) return null;
    final clockIn = ClockTime.parse(row.clockIn);
    if (clockIn == null) return null;
    return AttendanceRecord(
      id: row.id,
      employeeId: row.employeeId,
      workDate: row.workDate,
      clockIn: clockIn,
      clockOut: ClockTime.parse(row.clockOut),
      overtimeMinutes: row.overtimeMinutes,
      shiftId: row.shiftId,
      notes: row.notes,
      syncStatus: RowSyncStatus.values.byName(row.syncStatus),
      version: row.version,
    );
  }
}

@Riverpod(keepAlive: true)
StaffLocalDataSource staffLocalDataSource(Ref ref) {
  return StaffLocalDataSource(ref.watch(appDatabaseProvider));
}
