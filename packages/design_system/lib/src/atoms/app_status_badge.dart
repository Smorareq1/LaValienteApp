import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Color semántico de un [AppStatusBadge].
enum AppStatusTone { neutral, info, success, warning, error, brand }

enum AppStatusBadgeSize { sm, md }

/// Píldora de estado con texto libre.
///
/// A diferencia de [AppBadge], que tiene los estados de pedido cerrados, esta
/// sirve para cualquier etiqueta corta con color semántico: "Saldo Q85",
/// "Pendiente", "Insumo" o un contador.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.size = AppStatusBadgeSize.md,
  });

  final String label;
  final AppStatusTone tone;
  final AppStatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      AppStatusTone.neutral => (AppColors.gray100, AppColors.textSecondary),
      AppStatusTone.info => (AppColors.infoBg, AppColors.infoText),
      AppStatusTone.success => (AppColors.successBg, AppColors.successText),
      AppStatusTone.warning => (AppColors.warningBg, AppColors.warningText),
      AppStatusTone.error => (AppColors.errorBg, AppColors.errorText),
      AppStatusTone.brand => (AppColors.primary100, AppColors.primary700),
    };

    final (padding, fontSize) = switch (size) {
      AppStatusBadgeSize.sm => (
          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          10.5,
        ),
      AppStatusBadgeSize.md => (
          const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          11.0,
        ),
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.fullAll),
      child: Text(
        label,
        style: AppTypography.bodySm.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
