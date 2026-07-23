import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_controller.dart';

/// Muestra [child] solo si el usuario actual tiene alguno de los permisos
/// requeridos (códigos `resource.action` del backend). Con esto los módulos
/// de la app simplemente no se renderizan para quien no tiene acceso.
///
/// ```dart
/// PermissionGate(
///   anyOf: ['orders.read'],
///   child: OrdersModuleCard(),
/// )
/// ```
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.anyOf,
    required this.child,
    this.fallback,
  });

  /// Permisos que habilitan el contenido; basta con tener uno.
  final List<String> anyOf;
  final Widget child;

  /// Qué renderizar sin permiso (por defecto, nada).
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final allowed = user != null && user.hasAnyPermission(anyOf);
    return allowed ? child : (fallback ?? const SizedBox.shrink());
  }
}
