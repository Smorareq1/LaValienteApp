import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/staff_remote_datasource.dart';
import '../models/staff.dart';

part 'staff_admin_controller.g.dart';

/// La lista de empleados de la pantalla de administración (§9.2).
///
/// Va contra la API y no contra la BD local a propósito: aquí se **escribe**, y
/// quien acaba de guardar tiene que ver la fila como quedó en el servidor. Lo
/// que baja al espejo por el feed es para marcar asistencia, no para editarlo.
@riverpod
class EmployeesAdminController extends _$EmployeesAdminController {
  @override
  Future<List<Employee>> build() =>
      ref.watch(staffRemoteDataSourceProvider).employees();

  Future<Either<AppFailure, Employee>> create(EmployeeInput input) =>
      _write(() => ref.read(staffRemoteDataSourceProvider).createEmployee(input));

  /// `edit` y no `update` porque `AsyncNotifier` ya usa ese nombre.
  Future<Either<AppFailure, Employee>> edit(String id, EmployeeInput input) =>
      _write(() => ref.read(staffRemoteDataSourceProvider).updateEmployee(id, input));

  Future<Either<AppFailure, Employee>> _write(
    Future<Employee> Function() body,
  ) async {
    try {
      final saved = await body();
      final current = state.valueOrNull;
      if (current != null) state = AsyncData(_replacing(current, saved));
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }

  /// Se sustituye la fila en memoria en vez de volver a pedir todo: la respuesta
  /// **es** el estado nuevo, y recargar solo agregaría un parpadeo y otro viaje.
  static List<Employee> _replacing(List<Employee> current, Employee saved) {
    final updated = [
      for (final employee in current)
        if (employee.id == saved.id) saved else employee,
    ];
    if (!current.any((employee) => employee.id == saved.id)) updated.add(saved);
    // Los activos arriba, y dentro de cada grupo por nombre: quien está de baja
    // sigue existiendo pero no estorba la lista del día a día.
    updated.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.fullName.compareTo(b.fullName);
    });
    return updated;
  }
}

/// Los turnos de la pantalla de ajustes (§9.3).
@riverpod
class ShiftsAdminController extends _$ShiftsAdminController {
  @override
  Future<List<WorkShift>> build() =>
      ref.watch(staffRemoteDataSourceProvider).shifts();

  Future<Either<AppFailure, WorkShift>> create(ShiftInput input) =>
      _write(() => ref.read(staffRemoteDataSourceProvider).createShift(input));

  Future<Either<AppFailure, WorkShift>> edit(String id, ShiftInput input) =>
      _write(() => ref.read(staffRemoteDataSourceProvider).updateShift(id, input));

  Future<Either<AppFailure, WorkShift>> _write(
    Future<WorkShift> Function() body,
  ) async {
    try {
      final saved = await body();
      final current = state.valueOrNull;
      if (current != null) state = AsyncData(_replacing(current, saved));
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }

  static List<WorkShift> _replacing(List<WorkShift> current, WorkShift saved) {
    final updated = [
      for (final shift in current)
        if (shift.id == saved.id) saved else shift,
    ];
    if (!current.any((shift) => shift.id == saved.id)) updated.add(saved);
    // Por hora de inicio: es el orden en que transcurre el día, que es como se
    // lee un horario aunque `sort_order` diga otra cosa.
    updated.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return updated;
  }
}

/// El historial de la tarifa de hora extra (§9.3).
///
/// La lista llega de la más nueva a la más vieja y la vigente es la que no tiene
/// fecha de cierre. No se ordena aquí: el servidor ya la manda así y reordenar
/// por `valid_from` daría lo mismo salvo el día en que se registran dos.
@riverpod
class OvertimeRatesController extends _$OvertimeRatesController {
  @override
  Future<List<PayrollRate>> build() =>
      ref.watch(staffRemoteDataSourceProvider).rates();

  /// Abre una ventana nueva desde [validFrom]. Recarga en vez de insertar
  /// porque este POST **cambia otra fila**: la que estaba vigente queda cerrada
  /// el día anterior, y esa fecha la pone el servidor.
  Future<Either<AppFailure, PayrollRate>> register({
    required int amount,
    required String validFrom,
  }) async {
    try {
      final saved = await ref
          .read(staffRemoteDataSourceProvider)
          .registerRate(amount: amount, validFrom: validFrom);
      ref.invalidateSelf();
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }
}

/// Las cuentas del sistema para el desplegable de «usuario vinculado».
@riverpod
Future<List<SystemUser>> systemUsers(Ref ref) =>
    ref.watch(staffRemoteDataSourceProvider).users();
