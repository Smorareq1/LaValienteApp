import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Grupo de opciones de la pantalla Más: rótulo en mayúsculas y tarjeta blanca
/// con las filas separadas por una línea que arranca después del ícono.
///
/// Si [children] queda vacío (porque el rol no puede usar ninguna entrada) el
/// grupo entero desaparece, incluido su rótulo (Plan 0006 §13).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
                color: AppColors.gray400,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.card,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.only(left: 60),
                      child: Divider(height: 1, color: AppColors.gray100),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de un [SettingsGroup]: ícono en cuadro de color, título, subtítulo
/// opcional y chevron.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  /// Reemplaza el chevron (ej. por un switch).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.helper.copyWith(
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    size: 17, color: AppColors.gray300),
          ],
        ),
      ),
    );
  }
}
