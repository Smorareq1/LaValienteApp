import 'dart:isolate';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/offline_credential.dart';
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
  ///
  /// Sin señal cae en [_offlineLogin], que solo sabe abrirle a quien ya entró
  /// en este teléfono alguna vez.
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
      await _rememberForOffline(identifier: identifier, password: password, user: user);
      return right(user);
    } catch (error) {
      final failure = AppFailure.fromException(error);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        return _offlineLogin(identifier: identifier, password: password);
      }
      return left(failure);
    }
  }

  /// Guarda lo justo para volver a entrar sin señal: la ficha del usuario y un
  /// verificador de la contraseña que el servidor **acaba de aceptar**.
  ///
  /// Se rehace en cada login en línea, así que un cambio de contraseña deja de
  /// valer en este aparato la primera vez que se entra con la nueva.
  Future<void> _rememberForOffline({
    required String identifier,
    required String password,
    required AuthUser user,
  }) async {
    await _storage.saveUser(user.toJson());
    final credential = await Isolate.run(
      () => OfflineCredential.create(
        identifier: identifier,
        password: password,
        now: DateTime.now(),
      ),
    );
    await _storage.saveOfflineCredential(credential);
  }

  /// Entrada sin señal, contra el verificador de este teléfono.
  ///
  /// Corre en otro isolate porque las cien mil vueltas de PBKDF2 congelarían la
  /// pantalla; que tarde es el punto, que se note no.
  Future<Either<AppFailure, AuthUser>> _offlineLogin({
    required String identifier,
    required String password,
  }) async {
    final credential = await _storage.readOfflineCredential();
    final cached = await _storage.readUser();
    if (credential == null || cached == null) {
      // Nadie entró nunca aquí: no hay contra qué comparar, y el fallo real es
      // el de red.
      return left(const NetworkFailure(
        'Sin señal. La primera vez hay que entrar con internet.',
      ));
    }

    if (!credential.matches(identifier)) {
      return left(const OfflineLoginFailure(
        'Sin señal: en este teléfono solo puede entrar quien ya entró antes.',
      ));
    }

    if (credential.isStale(DateTime.now())) {
      return left(const OfflineLoginFailure(
        'Este teléfono lleva demasiado sin conectarse. Buscá señal para entrar.',
      ));
    }

    final ok = await Isolate.run(() => credential.verify(password));
    if (!ok) return left(const AuthFailure('Usuario o contraseña incorrectos'));

    return right(AuthUser.fromJson(cached));
  }

  /// Restaura la sesión persistida. Devuelve `null` si no hay sesión.
  ///
  /// Sin señal devuelve la última ficha conocida en vez de rebotar al login:
  /// el aparato ya tiene su espejo y su cola, y mandar a la pantalla de entrada
  /// a quien no puede entrar dejaría la app inservible justo cuando lo offline
  /// tendría que estar sirviendo.
  Future<Either<AppFailure, AuthUser?>> restoreSession() async {
    try {
      if (!await _storage.hasSession()) return right(null);
      final user = await _remote.me();
      await _storage.saveUser(user.toJson());
      return right(user);
    } catch (error) {
      final failure = AppFailure.fromException(error);
      if (failure is AuthFailure) {
        // Sesión expirada e irrecuperable: limpiar y continuar sin sesión.
        await _storage.clearSession();
        return right(null);
      }
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = await _storage.readUser();
        if (cached != null) return right(AuthUser.fromJson(cached));
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
