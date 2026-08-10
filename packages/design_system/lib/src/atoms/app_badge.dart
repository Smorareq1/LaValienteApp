import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Estados de una orden en la lavandería.
enum AppBadgeStatus { received, inProgress, ready, delivered, cancelled, paymentPending }

/// Etiqueta de estado (píldora con punto de color).
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.status, this.compact = false});

  const AppBadge.received({super.key, this.compact = false})
      : status = AppBadgeStatus.received;
  const AppBadge.inProgress({super.key, this.compact = false})
      : status = AppBadgeStatus.inProgress;
  const AppBadge.ready({super.key, this.compact = false}) : status = AppBadgeStatus.ready;
  const AppBadge.delivered({super.key, this.compact = false})
      : status = AppBadgeStatus.delivered;
  const AppBadge.cancelled({super.key, this.compact = false})
      : status = AppBadgeStatus.cancelled;
  const AppBadge.paymentPending({super.key, this.compact = false})
      : status = AppBadgeStatus.paymentPending;

  final AppBadgeStatus status;

  /// Versión angosta, para cuando la píldora comparte fila con un título largo.
  final bool compact;

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
      // Rojo y no gris: anular una boleta es un hecho que alguien tuvo que
      // decidir y que deja el dinero sin entrar. Un gris lo haría parecer un
      // estado más de la cadena, y no lo es — es la salida de emergencia.
      AppBadgeStatus.cancelled => (
          'Anulado',
          AppColors.errorBg,
          AppColors.errorText,
          AppColors.error,
        ),
      AppBadgeStatus.paymentPending => (
          'Pago pendiente',
          AppColors.errorBg,
          AppColors.errorText,
          AppColors.error,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
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
              fontSize: compact ? 11 : 12,
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
