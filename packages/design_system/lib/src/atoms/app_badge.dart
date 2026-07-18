import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Estados de una orden en la lavandería.
enum AppBadgeStatus { received, inProgress, ready, delivered, paymentPending }

/// Etiqueta de estado (píldora con punto de color).
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.status});

  const AppBadge.received({super.key}) : status = AppBadgeStatus.received;
  const AppBadge.inProgress({super.key}) : status = AppBadgeStatus.inProgress;
  const AppBadge.ready({super.key}) : status = AppBadgeStatus.ready;
  const AppBadge.delivered({super.key}) : status = AppBadgeStatus.delivered;
  const AppBadge.paymentPending({super.key}) : status = AppBadgeStatus.paymentPending;

  final AppBadgeStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground, dot) = switch (status) {
      AppBadgeStatus.received => (
          'Recibido',
          AppColors.infoBg,
          AppColors.infoText,
          AppColors.info,
        ),
      AppBadgeStatus.inProgress => (
          'En proceso',
          AppColors.warningBg,
          AppColors.warningText,
          AppColors.warning,
        ),
      AppBadgeStatus.ready => (
          'Listo',
          AppColors.successBg,
          AppColors.successText,
          AppColors.success,
        ),
      AppBadgeStatus.delivered => (
          'Entregado',
          AppColors.primary100,
          AppColors.primary700,
          AppColors.primary500,
        ),
      AppBadgeStatus.paymentPending => (
          'Pago pendiente',
          AppColors.errorBg,
          AppColors.errorText,
          AppColors.error,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
