import 'package:flutter/material.dart';

import '../../core/auth/app_permissions.dart';
import '../auth/models/auth_user.dart';

/// Un destino de la barra inferior del shell (Plan 0006 §3.1).
class ShellDestination {
  const ShellDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.anyOf = const [],
  });

  /// Ruta raíz de la rama.
  final String path;
  final String label;
  final IconData icon;

  /// Permisos que habilitan el destino; vacío = basta con tener sesión.
  /// Sin permiso el destino no se dibuja (§13: ocultar, no deshabilitar).
  final List<String> anyOf;

  bool isVisibleFor(AuthUser? user) {
    if (anyOf.isEmpty) return true;
    return user != null && user.hasAnyPermission(anyOf);
  }
}

/// Los 5 destinos del shell, en el orden de la barra inferior.
///
/// El índice en esta lista es el índice de rama del `StatefulShellRoute`, así
/// que agregar o reordenar destinos exige tocar el router en el mismo commit.
const List<ShellDestination> shellDestinations = [
  ShellDestination(
    path: '/home',
    label: 'Inicio',
    icon: Icons.home_outlined,
  ),
  ShellDestination(
    path: '/orders',
    label: 'Pedidos',
    icon: Icons.local_mall_outlined,
    anyOf: [AppPermissions.ordersRead],
  ),
  ShellDestination(
    path: '/cash',
    label: 'Caja',
    icon: Icons.account_balance_wallet_outlined,
    anyOf: [AppPermissions.expensesRead],
  ),
  ShellDestination(
    path: '/customers',
    label: 'Clientes',
    icon: Icons.person_outline,
    anyOf: [AppPermissions.customersRead],
  ),
  ShellDestination(
    path: '/more',
    label: 'Más',
    icon: Icons.menu_rounded,
  ),
];
