import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Caja con borde punteado.
///
/// El punteado marca lo que **todavía no existe** o lo que se agrega aparte: dar
/// de alta a un cliente nuevo, la nota suelta de una prenda. Un borde continuo
/// diría "esto ya es un dato", y no lo es hasta que alguien lo llena.
class AppDashedBox extends StatelessWidget {
  const AppDashedBox({
    super.key,
    required this.child,
    this.color = AppColors.primary300,
    this.backgroundColor = Colors.transparent,
    this.radius = 12,
    this.strokeWidth = 1.5,
    this.dash = 5,
    this.gap = 4,
  });

  final Widget child;
  final Color color;
  final Color backgroundColor;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        backgroundColor: backgroundColor,
        radius: radius,
        strokeWidth: strokeWidth,
        dash: dash,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.backgroundColor,
    required this.radius,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final Color backgroundColor;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    if (backgroundColor.a > 0) {
      canvas.drawRRect(rect, Paint()..color = backgroundColor);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // El borde se recorre como una sola línea y se va cortando: así las esquinas
    // redondeadas quedan punteadas igual que los lados rectos.
    for (final metric in (Path()..addRRect(rect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.backgroundColor != backgroundColor ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}
