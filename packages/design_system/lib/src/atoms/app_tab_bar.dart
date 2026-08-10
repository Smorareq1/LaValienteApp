import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Una pestaña de [AppTabBar].
class AppTab {
  const AppTab({required this.label, this.count, this.icon});

  final String label;

  /// Cuántos elementos hay detrás. Va en la propia pestaña porque en Caja
  /// decide si vale la pena cambiar de lado: "Gastos · 0" se lee sin tocarla.
  final int? count;

  final IconData? icon;
}

/// Pestañas de una pantalla (Plan 0006 §15).
///
/// Se diferencia de [AppSegmented] en para qué sirve, no en cómo se ve: el
/// segmentado elige el **valor de un campo** —efectivo o transferencia— y esto
/// elige **qué lista se está mirando**. Mezclarlos haría que un formulario y una
/// navegación se vieran igual.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<AppTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _Tab(
                tab: tabs[i],
                selected: i == index,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.selected, required this.onTap});

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.primary500 : AppColors.gray500;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              // El subrayado va del mismo grosor esté o no seleccionada, en
              // transparente cuando no: si apareciera y desapareciera, la fila
              // entera saltaría 2px al cambiar de pestaña.
              bottom: BorderSide(
                width: 2.5,
                color: selected ? AppColors.primary500 : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tab.icon != null) ...[
                Icon(tab.icon, size: 15, color: foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
              if (tab.count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary100 : AppColors.gray100,
                    borderRadius: AppRadius.fullAll,
                  ),
                  child: Text(
                    '${tab.count}',
                    style: AppTypography.helper.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.primary700 : AppColors.gray500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
