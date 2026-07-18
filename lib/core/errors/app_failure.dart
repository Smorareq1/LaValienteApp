import 'package:dio/dio.dart';

/// Taxonomía de fallos de la app. Toda excepción cruda debe transformarse
/// en un `AppFailure` tipado antes de salir de la capa Repository.
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;

  /// Traduce una excepción cruda (típicamente de Dio) a un fallo tipado.
  static AppFailure fromException(Object error) {
    if (error is AppFailure) return error;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkFailure();
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode ?? 0;
          final detail = _detailFrom(error.response?.data);
          if (status == 401 || status == 403) {
            return AuthFailure(detail ?? 'Sesión inválida o acceso denegado');
          }
          if (status == 422) {
            return ValidationFailure(detail ?? 'Datos inválidos');
          }
          return ServerFailure(detail ?? 'Error del servidor ($status)');
        default:
          return UnexpectedFailure(error.message ?? 'Error inesperado');
      }
    }
    return UnexpectedFailure(error.toString());
  }

  static String? _detailFrom(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
    }
    return null;
  }
}

/// Timeout o pérdida de conexión de red.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Sin conexión con el servidor']);
}

/// Error explícito devuelto por el backend.
final class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Problemas de sesión, credenciales inválidas o acceso denegado.
final class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Credenciales inválidas']);
}

/// Fallo al leer o escribir en la base de datos local.
final class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}

/// Datos capturados localmente que no son válidos.
final class ValidationFailure extends AppFailure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

/// Excepciones genéricas o no controladas.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([super.message = 'Error inesperado']);
}
