import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/env.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

part 'api_client.g.dart';

/// Cliente HTTP central de la app, apuntando al backend `/api/v1`.
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiV1BaseUrl,
      // Diez segundos alcanzan en la red del negocio y quedan cortos contra un
      // túnel recién levantado o una conexión de datos floja, donde el primer
      // apretón de manos TLS se lleva varios segundos él solo.
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  // El de log va primero para que cronometre lo que de verdad pasa por el cable.
  // Puesto después del de auth, un 401 que se resuelve refrescando se lo comería
  // el `handler.resolve` del otro y no quedaría rastro del reintento.
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(
    AuthInterceptor(storage: ref.watch(secureStorageProvider), dio: dio),
  );

  return dio;
}
