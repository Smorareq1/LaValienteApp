import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Encabezado de sección: barrita de acento, título y, opcionalmente, una
/// acción de texto a la derecha ("Ver Caja ›") o un contador.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.accentColor = AppColors.primary500,
    this.actionLabel,
    this.onActionTap,
    this.trailing,
  }) : assert(
          actionLabel == null || trailing == null,
          'Usá actionLabel o trailing, no ambos',
        );

  final String title;

  /// Color de la barrita: magenta para dinero, cian para operación.
  final Color accentColor;

  final String? actionLabel;
  final VoidCallback? onActionTap;

  /// Contenido libre a la derecha (ej. un contador en badge).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (actionLabel != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary500,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary500,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
