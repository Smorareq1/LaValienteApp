import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Tamaños de [AppStepper].
enum AppStepperSize {
  /// Compacto, para las filas de servicio.
  sm,

  /// El de las filas de prenda y de las listas de entrega.
  md,

  /// Táctil grande, para una sola cantidad protagonista en pantalla.
  lg,
}

/// De qué mitad de la boleta es el stepper.
///
/// Las prendas se cuentan en magenta y los servicios en cian: son los dos
/// bloques de la boleta de papel y el color los separa sin necesidad de leer.
enum AppStepperAccent { primary, secondary }

/// Control `− n +` para capturar cantidades sin teclado.
///
/// Es el átomo central de la toma de pedido (Plan 0002): el objetivo es que
/// contar prendas no exija tipear. El `+` va relleno del color de acento y el
/// `−` en blanco con borde, porque agregar es lo que se hace todo el día y
/// quitar es la excepción.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.size = AppStepperSize.md,
    this.accent = AppStepperAccent.primary,
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
  final AppStepperAccent accent;
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
      AppStepperSize.sm => (32.0, 14.0, 26.0, 14.0),
      AppStepperSize.md => (34.0, 15.0, 30.0, 15.0),
      AppStepperSize.lg => (44.0, 20.0, 40.0, 19.0),
    };

    final (addColor, addIconColor, activeColor) = switch (accent) {
      AppStepperAccent.primary => (
          AppColors.primary500,
          AppColors.white,
          AppColors.primary700,
        ),
      AppStepperAccent.secondary => (
          AppColors.secondary500,
          const Color(0xFF06485F),
          AppColors.secondary700,
        ),
    };

    // Un valor en cero se atenúa: comunica "todavía no contaste nada" sin
    // necesidad de texto extra.
    final valueColor = enabled && value > min ? activeColor : AppColors.gray300;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove_rounded,
          size: buttonSize,
          iconSize: iconSize,
          enabled: _canDecrease,
          tooltip: 'Quitar uno',
          background: enabled ? AppColors.white : AppColors.gray100,
          border: AppColors.border,
          foreground: _canDecrease ? AppColors.gray600 : AppColors.gray300,
          onPressed: () => _change(-step),
        ),
        const SizedBox(width: 3),
        SizedBox(
          width: valueWidth,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.money(fontSize: fontSize, color: valueColor),
          ),
        ),
        const SizedBox(width: 3),
        _StepperButton(
          icon: Icons.add_rounded,
          size: buttonSize,
          iconSize: iconSize,
          enabled: _canIncrease,
          tooltip: 'Agregar uno',
          background: _canIncrease ? addColor : AppColors.gray200,
          foreground: _canIncrease ? addIconColor : AppColors.gray400,
          onPressed: () => _change(step),
        ),
      ],
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
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.border,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool enabled;
  final String tooltip;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border!, width: 1.5),
        ),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}
