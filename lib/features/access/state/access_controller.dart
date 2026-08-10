import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/access_remote_datasource.dart';
import '../models/access.dart';

part 'access_controller.g.dart';

/// Las cuentas de la pantalla de usuarios (§12).
@riverpod
class UsersAdminController extends _$UsersAdminController {
  @override
  Future<List<SystemUser>> build() =>
      ref.watch(accessRemoteDataSourceProvider).users();

  Future<Either<AppFailure, SystemUser>> register(NewAccount account) =>
      _write(() => ref.read(accessRemoteDataSourceProvider).register(account));

  Future<Either<AppFailure, SystemUser>> setActive(
    String userId, {
    required bool isActive,
  }) => _write(
    () => ref
        .read(accessRemoteDataSourceProvider)
        .setActive(userId, isActive: isActive),
  );

  /// Guardar roles es un `PUT` que responde 204: no devuelve la cuenta, así que
  /// la fila se actualiza con los códigos que se acaban de mandar en vez de
  /// pedir la lista entera de nuevo por una sola fila.
  Future<Either<AppFailure, SystemUser>> assignRoles(
    SystemUser user, {
    required Set<String> roleIds,
    required List<AccessRole> catalog,
  }) => _write(() async {
    await ref
        .read(accessRemoteDataSourceProvider)
        .replaceRoles(user.id, roleIds);
    final codes =
        [
          for (final role in catalog)
            if (roleIds.contains(role.id)) role.code,
        ]..sort();
    return user.withRoles(codes);
  });

  Future<Either<AppFailure, SystemUser>> _write(
    Future<SystemUser> Function() body,
  ) async {
    try {
      final saved = await body();
      final current = state.valueOrNull;
      if (current != null) state = AsyncData(_replacing(current, saved));
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }

  /// Las activas arriba y por usuario dentro de cada grupo, que es el orden en
  /// que `GET /authorization/users` las manda salvo por lo de activas primero:
  /// una cuenta apagada sigue existiendo pero no estorba la lista del día a día.
  static List<SystemUser> _replacing(List<SystemUser> current, SystemUser saved) {
    final updated = [
      for (final user in current)
        if (user.id == saved.id) saved else user,
    ];
    if (!current.any((user) => user.id == saved.id)) updated.add(saved);
    updated.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.username.compareTo(b.username);
    });
    return updated;
  }
}

/// El catálogo de roles que se pueden repartir. Vacío si el servidor niega
/// `authorization.roles.manage`, y la pantalla lo explica.
@riverpod
Future<List<AccessRole>> accessRoles(Ref ref) =>
    ref.watch(accessRemoteDataSourceProvider).roles();
