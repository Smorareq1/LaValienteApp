import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../sync/data/sync_repository.dart';
import '../domain/overtime.dart';
import '../models/staff.dart';
import 'staff_local_datasource.dart';

part 'attendance_repository.g.dart';

/// La jornada del día, contra la BD local siempre (plan 0004 D1).
///
/// De todo el módulo de personal solo esto sube desde el dispositivo: quién es
/// empleado, qué turnos hay y cuánto vale una hora extra se administran en línea
/// (plan 0005 D11). Marcar la entrada, no — se hace de pie, junto a la persona
/// que acaba de llegar, que es exactamente donde no se puede contar con señal.
class AttendanceRepository {
  const AttendanceRepository({
    required AppDatabase database,
    required StaffLocalDataSource local,
    required SyncRepository sync,
    String Function() uuid = _defaultUuid,
  }) : _database = database,
       _local = local,
       _sync = sync,
       _uuid = uuid;

  final AppDatabase _database;
  final StaffLocalDataSource _local;
  final SyncRepository _sync;
  final String Function() _uuid;

  static String _defaultUuid() => const Uuid().v4();

  Stream<List<EmployeeDay>> watchDay(String date) => _local.watchDay(date);

  Stream<List<Employee>> watchEmployees() => _local.watchEmployees();

  Stream<List<WorkShift>> watchShifts() => _local.watchShifts();

  Future<AttendanceRecord?> byId(String id) => _local.recordById(id);

  Future<PayrollRate?> rateOn(String date) => _local.rateOn(date);

  /// Marca la entrada. El id lo genera el dispositivo (D3), para que reintentar
  /// el push no le abra dos días de trabajo a la misma persona.
  ///
  /// Acepta [clockOut] y [overtimeMinutes] porque una jornada se anota muchas
  /// veces **después**, copiándola de la hoja de papel, cuando las dos horas ya
  /// se conocen. El servidor lo admite por la misma razón.
  Future<Either<AppFailure, AttendanceRecord>> clockIn({
    required String employeeId,
    required String workDate,
    required ClockTime clockIn,
    String? shiftId,
    ClockTime? clockOut,
    int overtimeMinutes = 0,
    String? notes,
  }) async {
    if (clockOut != null && clockOut.compareTo(clockIn) <= 0) {
      return const Left(
        ValidationFailure('La salida tiene que ser después de la entrada'),
      );
    }

    // El servidor también lo rechaza, pero sin señal eso no se sabría hasta la
    // cola de revisión, con el día ya andando.
    final existing = await _local.recordFor(employeeId: employeeId, date: workDate);
    if (existing != null) {
      return const Left(
        ValidationFailure('Esta persona ya tiene la jornada marcada hoy'),
      );
    }

    final id = _uuid();
    final cleanNotes = _clean(notes);

    try {
      await _database.transaction(() async {
        await _local.insertLocal(
          id: id,
          employeeId: employeeId,
          workDate: workDate,
          clockIn: clockIn,
          shiftId: shiftId,
          clockOut: clockOut,
          overtimeMinutes: overtimeMinutes,
          notes: cleanNotes,
        );
        await _sync.enqueue(
          entity: 'attendance_record',
          opType: 'create',
          entityId: id,
          payload: <String, dynamic>{
            'employee_id': employeeId,
            'work_date': workDate,
            'shift_id': shiftId,
            'clock_in': clockIn.wire,
            'clock_out': clockOut?.wire,
            'overtime_minutes': overtimeMinutes,
            'notes': cleanNotes,
          },
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    final saved = await _local.recordById(id);
    return saved == null
        ? const Left(CacheFailure('No se pudo guardar la jornada'))
        : Right(saved);
  }

  /// Cierra la jornada, o corrige lo que ya decía.
  ///
  /// Cada campo llega envuelto en un [Value] y no como un nulo cualquiera porque
  /// el servidor aplica **solo las claves que vengan** (`exclude_unset`): mandar
  /// un `notes` nulo que nadie tocó borraría la nota que escribió otro
  /// dispositivo. Ausente y "ponelo en nulo" no son lo mismo, y aquí se
  /// distinguen.
  ///
  /// Viaja con `base_version` porque dos teléfonos cerrándole el día a la misma
  /// persona es justo el caso para el que existe: el segundo pisaría una hora
  /// que nunca vio (plan 0004 D6).
  Future<Either<AppFailure, AttendanceRecord>> updateRecord(
    AttendanceRecord current, {
    Value<String?> shiftId = const Value.absent(),
    Value<ClockTime> clockIn = const Value.absent(),
    Value<ClockTime?> clockOut = const Value.absent(),
    Value<int> overtimeMinutes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) async {
    final start = clockIn.present ? clockIn.value : current.clockIn;
    final end = clockOut.present ? clockOut.value : current.clockOut;
    if (end != null && end.compareTo(start) <= 0) {
      return const Left(
        ValidationFailure('La salida tiene que ser después de la entrada'),
      );
    }
    if (overtimeMinutes.present && overtimeMinutes.value < 0) {
      return const Left(ValidationFailure('Los minutos extra no pueden ser negativos'));
    }

    final cleanNotes = notes.present
        ? Value<String?>(_clean(notes.value))
        : const Value<String?>.absent();

    try {
      await _database.transaction(() async {
        await _local.updateLocal(
          id: current.id,
          shiftId: shiftId,
          clockIn: clockIn,
          clockOut: clockOut,
          overtimeMinutes: overtimeMinutes,
          notes: cleanNotes,
        );
        await _sync.enqueue(
          entity: 'attendance_record',
          opType: 'update',
          entityId: current.id,
          baseVersion: current.version,
          payload: <String, dynamic>{
            if (shiftId.present) 'shift_id': shiftId.value,
            if (clockIn.present) 'clock_in': clockIn.value.wire,
            if (clockOut.present) 'clock_out': clockOut.value?.wire,
            if (overtimeMinutes.present) 'overtime_minutes': overtimeMinutes.value,
            if (cleanNotes.present) 'notes': cleanNotes.value,
          },
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    final saved = await _local.recordById(current.id);
    return saved == null
        ? const Left(CacheFailure('No se pudo guardar la jornada'))
        : Right(saved);
  }

  /// Marcar salida: la hora y los minutos que quien la marca **confirma**.
  ///
  /// Los minutos se pasan explícitos aunque haya una sugerencia a la vista. Es
  /// toda la diferencia del D8: el sistema propone, una persona decide, y lo que
  /// se guarda es la decisión. Puede quedar en cero.
  Future<Either<AppFailure, AttendanceRecord>> clockOut(
    AttendanceRecord current, {
    required ClockTime at,
    required int overtimeMinutes,
  }) {
    return updateRecord(
      current,
      clockOut: Value(at),
      overtimeMinutes: Value(overtimeMinutes),
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

@Riverpod(keepAlive: true)
AttendanceRepository attendanceRepository(Ref ref) {
  return AttendanceRepository(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(staffLocalDataSourceProvider),
    sync: ref.watch(syncRepositoryProvider),
  );
}
