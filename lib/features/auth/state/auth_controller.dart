import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/auth_repository.dart';
import '../models/auth_user.dart';

part 'auth_controller.g.dart';

/// Estado global de autenticación.
///
/// - `AsyncLoading`: restaurando sesión al arrancar.
/// - `AsyncData(null)`: sin sesión → el router redirige a login.
/// - `AsyncData(user)`: sesión activa → el router permite rutas protegidas.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthUser?> build() async {
    final result = await ref.watch(authRepositoryProvider).restoreSession();
    return result.fold((_) => null, (user) => user);
  }

  /// Intenta iniciar sesión con usuario o correo. Devuelve el fallo para que
  /// la UI lo muestre, o `null` si fue exitoso (el router redirige solo al
  /// cambiar el estado).
  Future<AppFailure?> login({required String identifier, required String password}) async {
    final result = await ref
        .read(authRepositoryProvider)
        .login(identifier: identifier, password: password);
    return result.fold(
      (failure) => failure,
      (user) {
        state = AsyncData(user);
        return null;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
