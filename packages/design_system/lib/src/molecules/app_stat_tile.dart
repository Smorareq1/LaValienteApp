import 'package:flutter/material.dart';

import '../atoms/app_money_text.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Con qué intención se lee la cifra.
///
/// No es decoración: en Caja las tres cifras del resumen se leen juntas y de un
/// vistazo, y el color es lo que separa "entró" de "salió" antes de que nadie
/// lea la etiqueta.
enum AppStatTone {
  /// Cifra informativa, sin carga (el total del día).
  neutral,

  /// Dinero que entró.
  positive,

  /// Dinero que salió.
  negative,

  /// La cifra protagonista del bloque.
  brand,
}

/// Cifra grande con su etiqueta (Plan 0006 §15).
///
/// La usan Inicio, Caja y el acta del cierre. Recibe un monto y no un texto ya
/// formateado para que el formato del dinero viva en un solo sitio
/// ([AppMoneyText]) y no se escriba distinto en cada pantalla.
class AppStatTile extends StatelessWidget {
  const AppStatTile({
    super.key,
    required this.label,
    required this.amount,
    this.tone = AppStatTone.neutral,
    this.caption,
    this.icon,
    this.signed = false,
    this.compact = false,
    this.onTap,
  });

  final String label;
  final double amount;
  final AppStatTone tone;

  /// Segunda línea pequeña bajo la cifra ("21 cobros").
  final String? caption;

  final IconData? icon;

  /// Antepone `+`/`−`, para las cifras que son movimiento y no saldo.
  final bool signed;

  /// Versión angosta, para cuando van tres en una fila.
  final bool compact;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, labelColor, amountColor) = switch (tone) {
      AppStatTone.neutral => (AppColors.gray50, AppColors.gray500, AppColors.textPrimary),
      AppStatTone.positive => (
        AppColors.successBg,
        AppColors.successText,
        const Color(0xFF054F31),
      ),
      AppStatTone.negative => (AppColors.errorBg, AppColors.errorText, const Color(0xFF912018)),
      AppStatTone.brand => (AppColors.primary50, AppColors.primary700, AppColors.primary700),
    };

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 13,
        vertical: compact ? 9 : 12,
      ),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.mdAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: labelColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.helper.copyWith(
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          AppMoneyText(
            amount,
            size: compact ? AppMoneySize.md : AppMoneySize.lg,
            color: amountColor,
            decimalColor: labelColor,
            signed: signed,
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.helper.copyWith(fontSize: 10.5, color: labelColor),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: content,
      ),
    );
  }
}
