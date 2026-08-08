import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/time/business_date.dart';
import '../data/attendance_repository.dart';
import '../domain/overtime.dart';
import '../models/staff.dart';

part 'attendance_controller.g.dart';

/// El día que la asistencia está mirando. Por omisión el de negocio, igual que
/// la Caja: a las 19:00 en Cobán la jornada de hoy sigue siendo la de hoy.
@riverpod
class AttendanceDateFilter extends _$AttendanceDateFilter {
  @override
  DateTime build() => businessDate();

  void update(DateTime date) => state = DateTime(date.year, date.month, date.day);
}

/// El personal activo con su día resuelto (§9.1).
@riverpod
Stream<List<EmployeeDay>> attendanceDay(Ref ref, String date) {
  return ref.watch(attendanceRepositoryProvider).watchDay(date);
}

/// Los turnos que se pueden elegir al marcar.
@riverpod
Stream<List<WorkShift>> workShifts(Ref ref) {
  return ref.watch(attendanceRepositoryProvider).watchShifts();
}

/// El turno que le toca a una hora, si alguno la cubre.
///
/// Es una sugerencia para el formulario y nada más: quien marca puede cambiarla,
/// y trabajar fuera de todo turno es normal —es justo cuando no hay hora extra
/// que sugerir.
WorkShift? shiftCovering(List<WorkShift> shifts, ClockTime moment) {
  for (final shift in shifts) {
    if (shift.covers(moment)) return shift;
  }
  return null;
}
