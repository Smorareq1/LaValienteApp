import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../shell_destinations.dart';

/// Barra inferior del shell. Recibe solo los destinos visibles para el rol
/// actual, así que un colaborador sin `expenses.read` simplemente no ve Caja.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  /// Destinos ya filtrados por permiso.
  final List<ShellDestination> destinations;

  /// Índice dentro de [destinations], o `-1` si la ruta activa no es un tab.
  final int currentIndex;

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
        boxShadow: AppShadows.bottomNav,
      ),
      padding: EdgeInsets.fromLTRB(4, 10, 4, 10 + bottomInset),
      child: Row(
        children: [
          for (var i = 0; i < destinations.length; i++)
            Expanded(
              child: _NavItem(
                destination: destinations[i],
                selected: i == currentIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary500 : AppColors.gray400;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, size: 23, color: color),
              const SizedBox(height: 4),
              Text(
                destination.label,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
