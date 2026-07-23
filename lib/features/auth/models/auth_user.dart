/// Usuario autenticado (`CurrentUserRead` del backend).
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.roles,
    required this.permissions,
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
      );

  final String id;
  final String username;
  final String? email;
  final String? fullName;
  final List<String> roles;
  final List<String> permissions;

  /// Nombre a mostrar en la UI: nombre completo si existe, si no el username.
  String get displayName => fullName ?? username;

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasAnyPermission(Iterable<String> required) => required.any(permissions.contains);

  bool hasRole(String role) => roles.contains(role);
}
