import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/network/api_client.dart';
import '../../access/models/access.dart';
import '../domain/overtime.dart';
import '../models/staff.dart';

part 'staff_remote_datasource.g.dart';

/// I/O contra `/staff` para las pantallas de administración (§9.2 y §9.3).
///
/// **En línea**, a diferencia de la asistencia. Marcar una entrada es captura de
/// mostrador y aguanta sin señal; dar de alta a alguien o mover una tarifa no:
/// se decide una vez, con calma, y baja al dispositivo por el feed (plan 0005
/// D11). Por eso aquí no hay outbox — si no hay red, no se guarda y se dice.
class StaffRemoteDataSource {
  const StaffRemoteDataSource(this._dio);

  final Dio _dio;

  /// Todos, incluidos los dados de baja: esta es la pantalla que los administra
  /// y esconder a alguien inactivo lo volvería imposible de reactivar.
  Future<List<Employee>> employees() async {
    final response = await _dio.get<List<dynamic>>(
      '/staff/employees',
      queryParameters: {'include_inactive': true},
    );
    return [
      for (final item in response.data ?? const [])
        Employee.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Employee> createEmployee(EmployeeInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/staff/employees',
      data: input.toJson(withActive: false),
    );
    return Employee.fromJson(response.data!);
  }

  Future<Employee> updateEmployee(String id, EmployeeInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/staff/employees/$id',
      data: input.toJson(withActive: true),
    );
    return Employee.fromJson(response.data!);
  }

  Future<List<WorkShift>> shifts() async {
    final response = await _dio.get<List<dynamic>>(
      '/staff/shifts',
      queryParameters: {'include_inactive': true},
    );
    return [
      for (final item in response.data ?? const [])
        WorkShift.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<WorkShift> createShift(ShiftInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/staff/shifts',
      data: input.toJson(withCode: true),
    );
    return WorkShift.fromJson(response.data!);
  }

  /// El código no viaja: es por lo que una jornada ya marcada nombra su turno.
  Future<WorkShift> updateShift(String id, ShiftInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/staff/shifts/$id',
      data: input.toJson(withCode: false),
    );
    return WorkShift.fromJson(response.data!);
  }

  /// Todas las ventanas de un código, de la más nueva a la más vieja: el
  /// historial que el §9.3 muestra bajo la vigente.
  Future<List<PayrollRate>> rates({String code = PayrollRate.overtimeCode}) async {
    final response = await _dio.get<List<dynamic>>(
      '/staff/rates',
      queryParameters: {'code': code},
    );
    return [
      for (final item in response.data ?? const [])
        PayrollRate.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Abre una ventana nueva. El servidor cierra la anterior el día anterior
  /// (plan 0005 D7); la hora extra ya pagada conserva su monto porque el gasto
  /// lo congeló.
  Future<PayrollRate> registerRate({
    required int amount,
    required String validFrom,
    String code = PayrollRate.overtimeCode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/staff/rates',
      data: {
        'code': code,
        'amount': Fixed2.format(amount),
        'valid_from': validFrom,
      },
    );
    return PayrollRate.fromJson(response.data!);
  }

  /// Las cuentas del sistema, para el desplegable de «usuario vinculado».
  ///
  /// Pide `authorization.users.manage`, que `staff.manage` no implica. Devuelve
  /// vacío si el servidor lo niega en vez de tumbar el formulario: vincular una
  /// cuenta es opcional (D6) y la mayoría del personal no tiene ninguna.
  Future<List<SystemUser>> users() async {
    try {
      final response = await _dio.get<List<dynamic>>('/authorization/users');
      return [
        for (final item in response.data ?? const [])
          SystemUser.fromJson(item as Map<String, dynamic>),
      ];
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) return const [];
      rethrow;
    }
  }
}

/// Lo que el formulario de empleado manda.
class EmployeeInput {
  const EmployeeInput({
    required this.fullName,
    this.phone,
    this.userId,
    this.notes,
    this.isActive = true,
  });

  final String fullName;
  final String? phone;

  /// La cuenta con la que esta persona entra a la app, si tiene (D6).
  final String? userId;

  final String? notes;
  final bool isActive;

  Map<String, dynamic> toJson({required bool withActive}) => <String, dynamic>{
    'full_name': fullName,
    'phone': phone,
    'user_id': userId,
    'notes': notes,
    if (withActive) 'is_active': isActive,
  };
}

/// Lo que el formulario de turno manda.
class ShiftInput {
  const ShiftInput({
    required this.code,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String code;
  final String name;
  final ClockTime startsAt;
  final ClockTime endsAt;
  final int sortOrder;
  final bool isActive;

  Map<String, dynamic> toJson({required bool withCode}) => <String, dynamic>{
    if (withCode) 'code': code,
    'name': name,
    'starts_at': startsAt.wire,
    'ends_at': endsAt.wire,
    'sort_order': sortOrder,
    if (!withCode) 'is_active': isActive,
  };
}

@Riverpod(keepAlive: true)
StaffRemoteDataSource staffRemoteDataSource(Ref ref) {
  return StaffRemoteDataSource(ref.watch(apiClientProvider));
}
