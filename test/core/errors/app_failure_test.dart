import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/errors/app_failure.dart';

DioException _dioError({
  DioExceptionType type = DioExceptionType.badResponse,
  int? statusCode,
  dynamic data,
}) {
  final options = RequestOptions(path: '/auth/login');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response(requestOptions: options, statusCode: statusCode, data: data),
  );
}

void main() {
  group('AppFailure.fromException', () {
    test('no alcanzar el servidor → NetworkFailure', () {
      expect(
        AppFailure.fromException(
          _dioError(type: DioExceptionType.connectionError),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('los timeouts se separan de la falta de red', () {
      // Mandar a revisar el wifi a quien tiene el wifi bien lo pone a buscar un
      // problema que no existe: aquí lo que hay que hacer es reintentar.
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          AppFailure.fromException(_dioError(type: type)),
          isA<TimeoutFailure>(),
          reason: '$type debería ser un timeout',
        );
      }
    });

    test('401 → AuthFailure con el detail del backend', () {
      final failure = AppFailure.fromException(
        _dioError(statusCode: 401, data: {'detail': 'Invalid credentials'}),
      );
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Invalid credentials');
    });

    test('422 → ValidationFailure', () {
      expect(
        AppFailure.fromException(_dioError(statusCode: 422)),
        isA<ValidationFailure>(),
      );
    });

    test('500 → ServerFailure', () {
      expect(
        AppFailure.fromException(_dioError(statusCode: 500)),
        isA<ServerFailure>(),
      );
    });

    test('excepción genérica → UnexpectedFailure', () {
      expect(
        AppFailure.fromException(StateError('boom')),
        isA<UnexpectedFailure>(),
      );
    });
  });
}
