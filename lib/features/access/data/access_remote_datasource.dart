import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../models/access.dart';

part 'access_remote_datasource.g.dart';

/// I/O contra `identity` para la administración de accesos (Plan 0006 §12).
///
/// **En línea y sin espejo local**, más rotundamente que el resto de la gestión:
/// quién puede entrar al sistema no es un dato que un teléfono deba llevar
/// encima, y una cuenta creada sin señal sería una credencial que existe en un
/// aparato y en ningún otro sitio.
class AccessRemoteDataSource {
  const AccessRemoteDataSource(this._dio);

  final Dio _dio;

  /// Todas, incluidas las apagadas: esta es la pantalla que las administra y
  /// esconder una cuenta inactiva la volvería imposible de reactivar.
  Future<List<SystemUser>> users() async {
    final response = await _dio.get<List<dynamic>>('/authorization/users');
    return [
      for (final item in response.data ?? const [])
        SystemUser.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Los roles que se pueden repartir.
  ///
  /// Pide `authorization.roles.manage`, que `authorization.users.manage` **no**
  /// implica: son dos permisos distintos del catálogo y solo el comodín del
  /// administrador los junta. Si el servidor lo niega devuelve vacío y la
  /// pantalla lo explica, en vez de tumbar la lista de usuarios por un
  /// desplegable —el mismo trato que el «usuario vinculado» del §9.2.
  Future<List<AccessRole>> roles() async {
    try {
      final response = await _dio.get<List<dynamic>>('/authorization/roles');
      return [
        for (final item in response.data ?? const [])
          AccessRole.fromJson(item as Map<String, dynamic>),
      ];
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) return const [];
      rethrow;
    }
  }

  /// Crea la cuenta. El endpoint es `POST /auth/register` —el mismo del alta— y
  /// está detrás de `authorization.users.manage` desde que existe: registrarse
  /// solo no es una opción en este sistema.
  Future<SystemUser> register(NewAccount account) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: account.toJson(),
    );
    return SystemUser.fromJson(response.data!);
  }

  /// Encender o apagar una cuenta. Nunca se borra: un pedido de marzo nombra a
  /// quien lo recibió, y borrar la fila dejaría esa línea de auditoría colgando.
  Future<SystemUser> setActive(String userId, {required bool isActive}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/authorization/users/$userId',
      data: {'is_active': isActive},
    );
    return SystemUser.fromJson(response.data!);
  }

  /// Sustituye **todos** los roles de la cuenta, que es como el endpoint está
  /// escrito: no hay «agregar» ni «quitar», se manda la lista final.
  Future<void> replaceRoles(String userId, Set<String> roleIds) async {
    await _dio.put<void>(
      '/authorization/users/$userId/roles',
      data: {'role_ids': roleIds.toList()},
    );
  }
}

@Riverpod(keepAlive: true)
AccessRemoteDataSource accessRemoteDataSource(Ref ref) {
  return AccessRemoteDataSource(ref.watch(apiClientProvider));
}
