import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_user.dart';
import 'auth_remote_datasource.dart';

part 'auth_repository.g.dart';

/// Orquestador de datos de autenticación: coordina el datasource remoto y el
/// almacenamiento seguro, y transforma excepciones crudas en [AppFailure].
class AuthRepository {
  const AuthRepository(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  /// Inicia sesión (por usuario o correo), persiste los tokens y devuelve el
  /// usuario actual.
  Future<Either<AppFailure, AuthUser>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final tokens = await _remote.login(identifier: identifier, password: password);
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final user = await _remote.me();
      return right(user);
    } catch (error) {
      return left(AppFailure.fromException(error));
    }
  }

  /// Restaura la sesión persistida. Devuelve `null` si no hay sesión.
  Future<Either<AppFailure, AuthUser?>> restoreSession() async {
    try {
      if (!await _storage.hasSession()) return right(null);
      final user = await _remote.me();
      return right(user);
    } catch (error) {
      final failure = AppFailure.fromException(error);
      if (failure is AuthFailure) {
        // Sesión expirada e irrecuperable: limpiar y continuar sin sesión.
        await _storage.clearSession();
        return right(null);
      }
      return left(failure);
    }
  }

  /// Pide el envío de un código de recuperación de contraseña.
  Future<Either<AppFailure, Unit>> requestPasswordReset({required String identifier}) async {
    try {
      await _remote.forgotPassword(identifier: identifier);
      return right(unit);
    } catch (error) {
      return left(AppFailure.fromException(error));
    }
  }

  /// Canjea el código recibido por una nueva contraseña.
  Future<Either<AppFailure, Unit>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remote.resetPassword(
        identifier: identifier,
        code: code,
        newPassword: newPassword,
      );
      return right(unit);
    } catch (error) {
      return left(AppFailure.fromException(error));
    }
  }

  /// Cierra la sesión en el backend (best effort) y limpia la sesión local.
  Future<Either<AppFailure, Unit>> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // La sesión local se limpia aunque el backend no responda.
    }
    await _storage.clearSession();
    return right(unit);
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
}
