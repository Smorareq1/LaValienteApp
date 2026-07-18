import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

/// Interceptor de autenticación:
/// - Adjunta el access token a cada petición protegida.
/// - Ante un 401, intenta refrescar la sesión una vez y reintenta la petición.
/// - Si el refresh falla, limpia la sesión local.
///
/// Extiende [QueuedInterceptor] para serializar los refresh concurrentes.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required Dio dio,
  })  : _storage = storage,
        _dio = dio;

  final SecureStorageService _storage;
  final Dio _dio;

  static const Set<String> _publicPaths = {'/auth/login', '/auth/refresh', '/auth/register'};

  bool _isPublic(RequestOptions options) => _publicPaths.contains(options.path);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options)) {
      final accessToken = await _storage.readAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['auth_retry'] == true;

    if (!is401 || _isPublic(err.requestOptions) || alreadyRetried) {
      return handler.next(err);
    }

    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return handler.next(err);

    try {
      // Cliente sin interceptores para evitar recursión durante el refresh.
      final refreshClient = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data!;
      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      final retryOptions = err.requestOptions
        ..extra['auth_retry'] = true
        ..headers['Authorization'] = 'Bearer ${data['access_token']}';
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException {
      await _storage.clearSession();
      return handler.next(err);
    }
  }
}
