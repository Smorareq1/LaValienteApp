import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Estado vacío de una lista: ícono en círculo, título, explicación y, cuando
/// existe, la acción natural del contexto (Plan 0006 §14).
///
/// El borde punteado distingue "aquí todavía no hay nada" de una tarjeta con
/// contenido real.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// CTA de la acción natural ("Sin pedidos hoy → + Pedido").
  final Widget? action;

  /// Reduce el espaciado para estados vacíos dentro de una tarjeta.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // Va como foregroundPainter para que el trazo quede por encima del
      // relleno blanco de la tarjeta.
      foregroundPainter: const _DashedBorderPainter(
        color: AppColors.border,
        radius: 18,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: dense ? 18 : 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: _content(),
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: AppColors.gray100,
            borderRadius: AppRadius.fullAll,
          ),
          child: Icon(icon, size: 28, color: AppColors.gray400),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        if (message != null) ...[
          const SizedBox(height: 3),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: AppTypography.helper.copyWith(fontSize: 12.5),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 16),
          action!,
        ],
      ],
    );
  }
}

/// Dibuja el contorno punteado del estado vacío. Flutter no soporta
/// `BorderStyle.dashed`, así que el trazo se recorre a mano.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double dash = 5;
  static const double gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(0.5),
      );

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
