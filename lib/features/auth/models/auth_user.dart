/// Usuario autenticado (`CurrentUserRead` del backend).
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        roles: (json['roles'] as List<dynamic>).cast<String>(),
        permissions: (json['permissions'] as List<dynamic>).cast<String>(),
      );

  final String id;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasRole(String role) => roles.contains(role);
}
