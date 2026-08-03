import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/gradient_header.dart';

/// Pantalla de un módulo que todavía no se construye.
///
/// La fase UI 1 arma la navegación completa (Plan 0006 §16); cada destino se
/// reemplaza por su pantalla real en la fase que le toca. Este marcador deja
/// la navegación entera recorrible y dice en voz alta qué falta.
///
/// Sirve tanto a los tabs de la barra inferior como a las entradas del hub
/// "Más", que se apilan encima del shell; de ahí que la cabecera decida sola si
/// dibuja el botón de volver.
class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.phase,
  });

  final String title;
  final IconData icon;

  /// Fase del plan que implementa esta pantalla (ej. "UI 4").
  final String phase;

  @override
  Widget build(BuildContext context) {
    // Un tab de la barra es la raíz de su rama y no tiene a dónde volver; una
    // entrada de "Más" se apiló sobre el shell y sin flecha quedaría encerrada.
    final canGoBack = context.canPop();

    return Column(
      children: [
        GradientHeader(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
          child: Row(
            children: [
              if (canGoBack) ...[
                _BackButton(onPressed: context.pop),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppEmptyState(
                icon: icon,
                title: 'En construcción',
                message: '$title se implementa en la fase $phase del plan de UI.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: 'Volver',
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 19,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
