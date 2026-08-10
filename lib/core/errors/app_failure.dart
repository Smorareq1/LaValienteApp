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
        // Que el servidor tarde y que no se le pueda alcanzar son cosas
        // distintas, y confundirlas manda a revisar el wifi a quien tiene el
        // wifi perfecto. El primero se espera o se reintenta; el segundo se
        // arregla en el teléfono.
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutFailure();
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

/// No se pudo alcanzar el servidor: no hay red, o no está donde se le busca.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Sin conexión con el servidor']);
}

/// El servidor está ahí pero no contestó a tiempo.
///
/// Se separa de [NetworkFailure] porque la acción es otra: aquí se espera y se
/// reintenta, y decirle a alguien que revise su red lo manda a buscar un
/// problema que no tiene.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'El servidor tardó demasiado en responder']);
}

/// El teléfono está sin señal y no puede resolver el intento por su cuenta.
///
/// Lleva su propio mensaje porque cada caso explica algo distinto: que en este
/// aparato solo puede entrar quien ya entró, o que lleva demasiado sin verse
/// con el servidor.
final class OfflineLoginFailure extends AppFailure {
  const OfflineLoginFailure(super.message);
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
