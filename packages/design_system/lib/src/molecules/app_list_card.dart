import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Tarjeta de entidad para listas: cuadro guía, título, subtítulo y bloque
/// final (monto, badge, chevron).
///
/// La usan pedidos, clientes, gastos, lotes y las filas de Inicio, así que las
/// tres zonas se pasan como slots en vez de campos cerrados.
class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.titleSuffix,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final String? subtitle;

  /// Cuadro guía a la izquierda — normalmente un [AppListCardTile].
  final Widget? leading;

  /// Contenido alineado a la derecha (monto + badge, o un chevron).
  final Widget? trailing;

  /// Ícono pequeño junto al título (ej. el reloj de "sin sincronizar").
  final Widget? titleSuffix;

  final VoidCallback? onTap;

  /// Resalta la tarjeta con el borde de marca.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(
              color: selected ? AppColors.primary300 : AppColors.border,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (titleSuffix != null) ...[
                          const SizedBox(width: 5),
                          titleSuffix!,
                        ],
                      ],
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.helper.copyWith(fontSize: 11.5),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuadro guía de [AppListCard]: un recuadro de color con texto corto (el
/// número de pedido) o un ícono.
class AppListCardTile extends StatelessWidget {
  const AppListCardTile({
    super.key,
    this.label,
    this.icon,
    required this.background,
    required this.foreground,
    this.size = 42,
  }) : assert(label != null || icon != null, 'Se requiere label o icon');

  final String? label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.31),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.45, color: foreground)
          : Text(
              label!,
              style: AppTypography.money(fontSize: size * 0.31, color: foreground),
            ),
    );
  }
}
