import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

enum AppButtonSize { sm, md, lg }

/// Botón del sistema: variantes primario, secundario, contorno y ghost;
/// tamaños sm/md/lg; estados disabled y loading; icono opcional.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.fullWidth = false,
    this.loading = false,
    this.elevated = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final bool loading;

  /// Aplica el glow de marca (solo tiene sentido en el variante primario).
  final bool elevated;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final (padding, radius, fontSize) = switch (size) {
      AppButtonSize.sm => (
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          10.0,
          12.0,
        ),
      AppButtonSize.md => (
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          13.0,
          14.0,
        ),
      AppButtonSize.lg => (
          const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          15.0,
          16.0,
        ),
    };

    final (background, foreground, side) = switch (variant) {
      AppButtonVariant.primary => (
          AppColors.primary500,
          AppColors.white,
          BorderSide.none,
        ),
      AppButtonVariant.secondary => (
          AppColors.secondary500,
          const Color(0xFF083344),
          BorderSide.none,
        ),
      AppButtonVariant.outline => (
          AppColors.white,
          AppColors.primary500,
          const BorderSide(color: AppColors.primary500, width: 2),
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppColors.primary500,
          BorderSide.none,
        ),
    };

    final overlay = switch (variant) {
      AppButtonVariant.primary => AppColors.primary600,
      AppButtonVariant.secondary => AppColors.secondary600,
      AppButtonVariant.outline || AppButtonVariant.ghost => AppColors.primary50,
    };

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox.square(
            dimension: fontSize + 2,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foreground, size: fontSize + 4),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTypography.button(fontSize: fontSize, color: foreground)),
        if (trailingIcon != null && !loading) ...[
          const SizedBox(width: 8),
          IconTheme(
            data: IconThemeData(color: foreground, size: fontSize + 4),
            child: trailingIcon!,
          ),
        ],
      ],
    );

    final button = Material(
      color: _enabled ? background : AppColors.gray200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: _enabled ? side : BorderSide.none,
      ),
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(radius),
        overlayColor: WidgetStatePropertyAll(overlay.withValues(alpha: 0.35)),
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: _enabled ? foreground : AppColors.gray400),
            child: _enabled
                ? child
                : _DisabledForeground(color: AppColors.gray400, child: child),
          ),
        ),
      ),
    );

    final decorated = elevated && _enabled && variant == AppButtonVariant.primary
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: AppShadows.primaryButton,
            ),
            child: button,
          )
        : button;

    return fullWidth ? SizedBox(width: double.infinity, child: decorated) : decorated;
  }
}

class _DisabledForeground extends StatelessWidget {
  const _DisabledForeground({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: color),
      child: DefaultTextStyle.merge(style: TextStyle(color: color), child: child),
    );
  }
}
