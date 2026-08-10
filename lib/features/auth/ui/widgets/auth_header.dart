import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Cabecera de autenticación: gradiente de marca con esquinas inferiores
/// redondeadas, círculos decorativos y tarjeta blanca con el logo.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(44),
        bottomRight: Radius.circular(44),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.authHeader),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: _DecorativeCircle(
                size: 150,
                color: AppColors.white.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: _DecorativeCircle(
                size: 140,
                color: AppColors.secondary500.withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(28, topPadding + 64, 28, 70),
              // Ancho completo a propósito. Como hijo sin posicionar del Stack,
              // el Column recibe restricciones flojas y se encogería al ancho de
              // su línea más larga, anclado arriba a la izquierda: el `center`
              // por omisión centraría dentro de esa caja angosta y no dentro de
              // la cabecera. Con el ancho fijo el centrado es contra la pantalla.
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x59000000),
                            offset: Offset(0, 16),
                            blurRadius: 30,
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_la_valiente.png',
                        width: 180,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

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
