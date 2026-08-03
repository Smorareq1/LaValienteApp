import '../../../core/auth/app_permissions.dart';

/// Usuario autenticado (`CurrentUserRead` del backend).
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.roles,
    required this.permissions,
    this.deniedPermissions = const [],
    this.email,
    this.fullName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String?,
        fullName: json['full_name'] as String?,
        roles: (json['roles'] as List<dynamic>).cast<String>(),
        permissions: (json['permissions'] as List<dynamic>).cast<String>(),
        deniedPermissions:
            (json['denied_permissions'] as List<dynamic>? ?? const []).cast<String>(),
      );

  final String id;
  final String username;
  final String? email;
  final String? fullName;
  final List<String> roles;

  /// Permisos concedidos. Puede contener el comodín [AppPermissions.all].
  final List<String> permissions;

  /// Permisos revocados a mano. Viajan aparte porque el comodín los volvería a
  /// conceder: la resta ya la hizo el servidor sobre los concretos, pero sobre
  /// el comodín solo se puede aplicar teniendo la lista.
  final List<String> deniedPermissions;

  /// Nombre a mostrar en la UI: nombre completo si existe, si no el username.
  String get displayName => fullName ?? username;

  /// Mismo veredicto que `IdentityService.has_permission` del backend: un
  /// `deny` gana siempre, y el comodín concede lo que nadie asignó.
  ///
  /// Que las dos capas usen la misma regla es lo que impide que la app muestre
  /// una sección que la API va a rechazar con 403.
  bool hasPermission(String permission) {
    if (deniedPermissions.contains(permission)) return false;
    return permissions.contains(permission) || permissions.contains(AppPermissions.all);
  }

  bool hasAnyPermission(Iterable<String> required) => required.any(hasPermission);

  bool hasRole(String role) => roles.contains(role);
}
