import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Cabecera con gradiente de marca del shell autenticado: esquinas inferiores
/// redondeadas y los dos círculos decorativos de las maquetas.
///
/// Cada pantalla compone su propio contenido adentro (saludo + indicadores en
/// Inicio, título + perfil en Más).
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 0, 18, 26),
  });

  final Widget child;

  /// Espaciado interno. El alto de la barra de estado se suma arriba.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.shellHeader),
        child: Stack(
          children: [
            Positioned(
              top: -46,
              right: -26,
              child: _Circle(
                size: 128,
                color: AppColors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              bottom: -58,
              left: -34,
              child: _Circle(
                size: 118,
                color: AppColors.secondary500.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: padding.copyWith(top: padding.top + topInset + 14),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
