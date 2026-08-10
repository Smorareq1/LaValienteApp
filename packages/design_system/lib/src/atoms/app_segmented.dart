import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Una opción de [AppSegmented].
class AppSegmentedOption<T> {
  const AppSegmentedOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Selector de 2–3 opciones excluyentes, todas visibles a la vez.
///
/// Se usa donde un desplegable sería un paso de más: el método de pago, el tipo
/// de movimiento. La regla para elegirlo es esa — si las opciones caben en la
/// pantalla, se muestran; el mostrador no debería abrir un menú para decir
/// "efectivo".
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<AppSegmentedOption<T>> options;
  final T value;

  /// `null` deja el control en solo lectura.
  final ValueChanged<T>? onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: option.label,
                icon: option.icon,
                selected: option.value == value,
                onTap: active ? () => onChanged!(option.value) : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // El seleccionado se levanta con fondo blanco en vez de pintarse de color:
    // así el segmentado no compite con el botón primario de la pantalla.
    final foreground = onTap == null
        ? AppColors.gray400
        : selected
        ? AppColors.primary500
        : AppColors.gray500;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md - 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
