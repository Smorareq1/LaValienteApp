import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';

part 'auth_remote_datasource.g.dart';

/// I/O puro contra los endpoints `/auth` del backend.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthTokens> login({required String identifier, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'identifier': identifier, 'password': password},
    );
    return AuthTokens.fromJson(response.data!);
  }

  Future<AuthUser> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return AuthUser.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  /// Solicita un código de recuperación. El backend siempre responde 202.
  Future<void> forgotPassword({required String identifier}) async {
    await _dio.post<void>(
      '/auth/forgot-password',
      data: {'identifier': identifier},
    );
  }

  /// Canjea el código de recuperación por una nueva contraseña.
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/auth/reset-password',
      data: {'identifier': identifier, 'code': code, 'new_password': newPassword},
    );
  }
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
}
