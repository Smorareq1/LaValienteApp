/// Las cuentas del sistema y los roles que las visten (Plan 0006 §12).
///
/// Vive aquí y no en `staff` porque son dos cosas distintas que la lavandería
/// confunde a diario: un **empleado** es quien trabaja aquí y un **usuario** es
/// quien entra a la app. Casi siempre coinciden, pero no siempre —hay personal
/// que nunca toca el teléfono y hay una cuenta de dueña que no marca asistencia—
/// y el modelo los tiene separados desde el plan 0005 D6. `SystemUser` empezó
/// dentro del datasource de personal, para el desplegable de «usuario
/// vinculado»; se mudó al llegar la pantalla que los administra, que es la que
/// de verdad los posee.
library;

/// Una cuenta, tal como la lista `GET /authorization/users`.
class SystemUser {
  const SystemUser({
    required this.id,
    required this.username,
    required this.isActive,
    this.fullName,
    this.email,
    this.roles = const [],
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) => SystemUser(
    id: json['id'] as String,
    username: json['username'] as String,
    // `POST /auth/register` responde con la vista de sesión, que no trae
    // `is_active` porque una cuenta recién creada no puede estar apagada.
    isActive: json['is_active'] as bool? ?? true,
    fullName: json['full_name'] as String?,
    email: json['email'] as String?,
    roles: [
      for (final role in (json['roles'] as List<dynamic>? ?? const []))
        role as String,
    ],
  );

  final String id;
  final String username;
  final bool isActive;
  final String? fullName;
  final String? email;

  /// Códigos de rol (`admin`, `collaborator`), no sus nombres largos.
  final List<String> roles;

  /// `Marta González (mostrador)`, o solo el usuario si no tiene nombre.
  String get label =>
      fullName == null || fullName!.isEmpty ? username : '$fullName ($username)';

  /// Lo que se enseña en grande en la tarjeta: el nombre si lo hay, y si no el
  /// usuario, que siempre existe.
  String get displayName =>
      fullName == null || fullName!.isEmpty ? username : fullName!;

  /// Las iniciales del avatar.
  String get initials {
    final source = displayName.trim();
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  SystemUser withRoles(List<String> updated) => SystemUser(
    id: id,
    username: username,
    isActive: isActive,
    fullName: fullName,
    email: email,
    roles: updated,
  );
}

/// Un rol, tal como lo lista `GET /authorization/roles`.
///
/// Los roles **no se crean desde la app**: componer uno es decidir qué puede
/// hacer alguien permiso por permiso, y esa decisión se toma con el catálogo de
/// `permissions.py` delante, no de pie en el mostrador. Aquí solo se reparten
/// los que ya existen.
class AccessRole {
  const AccessRole({
    required this.id,
    required this.code,
    required this.name,
    required this.isSystem,
    this.description,
  });

  factory AccessRole.fromJson(Map<String, dynamic> json) => AccessRole(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    isSystem: json['is_system'] as bool? ?? false,
    description: json['description'] as String?,
  );

  final String id;
  final String code;
  final String name;
  final bool isSystem;
  final String? description;
}

/// Lo que el formulario de alta manda a `POST /auth/register`.
///
/// Los patrones son los del backend (`identity/schemas.py`), repetidos aquí a
/// propósito: el §14 pide el error **anclado al campo**, y un 422 devuelve una
/// frase de pydantic sobre un regex que nadie de mostrador puede leer.
class NewAccount {
  const NewAccount({
    required this.username,
    required this.password,
    this.fullName,
    this.email,
    this.phone,
  });

  /// `^[a-z][a-z0-9_.]{2,49}$`: empieza con letra, minúsculas, de 3 a 50.
  static final RegExp usernamePattern = RegExp(r'^[a-z][a-z0-9_.]{2,49}$');

  /// `^\+?[0-9]{8,15}$`.
  static final RegExp phonePattern = RegExp(r'^\+?[0-9]{8,15}$');

  static const int minPasswordLength = 8;

  final String username;
  final String password;
  final String? fullName;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    'password': password,
    // Se omiten en vez de mandarse nulos: son opcionales y un `null` explícito
    // no aporta nada que la ausencia no diga.
    if (fullName != null && fullName!.isNotEmpty) 'full_name': fullName,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
  };
}
