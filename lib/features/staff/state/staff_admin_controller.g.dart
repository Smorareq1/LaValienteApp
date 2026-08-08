// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$systemUsersHash() => r'921e60d9c49ac654e305f0644d5985405dd3e086';

/// Las cuentas del sistema para el desplegable de «usuario vinculado».
///
/// Copied from [systemUsers].
@ProviderFor(systemUsers)
final systemUsersProvider =
    AutoDisposeFutureProvider<List<SystemUser>>.internal(
      systemUsers,
      name: r'systemUsersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$systemUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SystemUsersRef = AutoDisposeFutureProviderRef<List<SystemUser>>;
String _$employeesAdminControllerHash() =>
    r'e4f827e02ee5dc328140ec0f1fc367405321a9bf';

/// La lista de empleados de la pantalla de administración (§9.2).
///
/// Va contra la API y no contra la BD local a propósito: aquí se **escribe**, y
/// quien acaba de guardar tiene que ver la fila como quedó en el servidor. Lo
/// que baja al espejo por el feed es para marcar asistencia, no para editarlo.
///
/// Copied from [EmployeesAdminController].
@ProviderFor(EmployeesAdminController)
final employeesAdminControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      EmployeesAdminController,
      List<Employee>
    >.internal(
      EmployeesAdminController.new,
      name: r'employeesAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$employeesAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EmployeesAdminController = AutoDisposeAsyncNotifier<List<Employee>>;
String _$shiftsAdminControllerHash() =>
    r'ba93f3599b8daec1e9e91b3c7d8a8bb162e0619e';

/// Los turnos de la pantalla de ajustes (§9.3).
///
/// Copied from [ShiftsAdminController].
@ProviderFor(ShiftsAdminController)
final shiftsAdminControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ShiftsAdminController,
      List<WorkShift>
    >.internal(
      ShiftsAdminController.new,
      name: r'shiftsAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shiftsAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShiftsAdminController = AutoDisposeAsyncNotifier<List<WorkShift>>;
String _$overtimeRatesControllerHash() =>
    r'0d101c8e905d6afcd483fb3eea8af0bfb50ebe22';

/// El historial de la tarifa de hora extra (§9.3).
///
/// La lista llega de la más nueva a la más vieja y la vigente es la que no tiene
/// fecha de cierre. No se ordena aquí: el servidor ya la manda así y reordenar
/// por `valid_from` daría lo mismo salvo el día en que se registran dos.
///
/// Copied from [OvertimeRatesController].
@ProviderFor(OvertimeRatesController)
final overtimeRatesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      OvertimeRatesController,
      List<PayrollRate>
    >.internal(
      OvertimeRatesController.new,
      name: r'overtimeRatesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$overtimeRatesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OvertimeRatesController = AutoDisposeAsyncNotifier<List<PayrollRate>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
