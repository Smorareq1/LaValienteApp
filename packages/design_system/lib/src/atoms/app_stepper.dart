import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Tamaños de [AppStepper].
enum AppStepperSize {
  /// Compacto, para filas de lista.
  md,

  /// Táctil grande — el de la toma de pedido, que se usa de pie y con prisa.
  lg,
}

/// Control `− n +` para capturar cantidades sin teclado.
///
/// Es el átomo central de la toma de pedido (Plan 0002): el objetivo es que
/// contar prendas no exija tipear.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.size = AppStepperSize.lg,
    this.enabled = true,
  });

  final int value;

  /// Recibe el nuevo valor ya acotado a [min] y [max]. Si es `null` el control
  /// queda en solo lectura.
  final ValueChanged<int>? onChanged;

  final int min;
  final int max;
  final int step;
  final AppStepperSize size;
  final bool enabled;

  bool get _canDecrease => enabled && onChanged != null && value > min;
  bool get _canIncrease => enabled && onChanged != null && value < max;

  void _change(int delta) {
    final next = (value + delta).clamp(min, max);
    if (next != value) onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final (buttonSize, iconSize, valueWidth, fontSize) = switch (size) {
      AppStepperSize.md => (34.0, 16.0, 34.0, 15.0),
      AppStepperSize.lg => (44.0, 20.0, 44.0, 19.0),
    };

    // Un valor en cero se atenúa: comunica "todavía no contaste nada" sin
    // necesidad de texto extra.
    final valueColor = !enabled
        ? AppColors.gray400
        : value == min
            ? AppColors.gray400
            : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.gray100,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            size: buttonSize,
            iconSize: iconSize,
            enabled: _canDecrease,
            tooltip: 'Quitar uno',
            onPressed: () => _change(-step),
          ),
          SizedBox(
            width: valueWidth,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.money(fontSize: fontSize, color: valueColor),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            size: buttonSize,
            iconSize: iconSize,
            enabled: _canIncrease,
            tooltip: 'Agregar uno',
            onPressed: () => _change(step),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: AppRadius.mdAll,
        child: SizedBox.square(
          dimension: size,
          child: Icon(
            icon,
            size: iconSize,
            color: enabled ? AppColors.primary500 : AppColors.gray300,
          ),
        ),
      ),
    );
  }
}
