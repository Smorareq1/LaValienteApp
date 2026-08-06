import 'package:flutter/material.dart';

import '../atoms/app_money_text.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Una cifra secundaria de la barra: subtotal, descuento, saldo.
class AppSummaryLine {
  const AppSummaryLine({required this.label, required this.amount, this.emphasis = false});

  final String label;
  final double amount;

  /// Un descuento se pinta distinto porque resta: quien revisa la boleta tiene
  /// que poder encontrarlo sin leer las etiquetas.
  final bool emphasis;
}

/// Footer fijo con el total y la acción principal.
///
/// Es el "resumen de la boleta" del plan 0002 §3.8: vive pegado abajo, se
/// recalcula con cada cambio y **no se va con el scroll**. El total es la
/// pregunta que el cliente hace de pie frente al mostrador, así que la respuesta
/// no puede estar a tres deslizadas de distancia.
class AppSummaryBar extends StatelessWidget {
  const AppSummaryBar({
    super.key,
    required this.total,
    required this.actionLabel,
    required this.onAction,
    this.totalLabel = 'TOTAL',
    this.lines = const [],
    this.caption,
    this.note,
    this.noteIsWarning = false,
    this.busy = false,
  });

  final double total;
  final String totalLabel;

  /// Cifras de arriba (subtotal, descuento). Vacío deja solo el total.
  final List<AppSummaryLine> lines;

  /// Texto pequeño junto al total ("12 pzas · 4 cargos").
  final String? caption;

  /// Aviso bajo el botón. En rojo si [noteIsWarning].
  final String? note;
  final bool noteIsWarning;

  final String actionLabel;

  /// `null` deshabilita la acción; el aviso de [note] es el que explica por qué.
  final VoidCallback? onAction;

  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onAction != null && !busy;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (lines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      for (final line in lines)
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${line.label} ',
                                style: AppTypography.helper.copyWith(fontSize: 11.5),
                              ),
                              AppMoneyText(
                                line.amount,
                                size: AppMoneySize.sm,
                                color: line.emphasis
                                    ? AppColors.primary600
                                    : AppColors.gray600,
                                decimalColor: AppColors.gray400,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // La cifra manda sobre el botón: en una pantalla angosta se
                  // recorta el texto de la acción antes que el total, que es lo
                  // que el cliente está mirando.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalLabel,
                          style: AppTypography.caption.copyWith(fontSize: 10.5),
                        ),
                        AppMoneyText(total, size: AppMoneySize.hero),
                        if (caption != null)
                          Text(
                            caption!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.helper.copyWith(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: _ActionButton(
                      label: actionLabel,
                      enabled: enabled,
                      busy: busy,
                      onTap: onAction,
                    ),
                  ),
                ],
              ),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    note!,
                    textAlign: TextAlign.center,
                    style: AppTypography.helper.copyWith(
                      fontSize: 11.5,
                      color: noteIsWarning ? AppColors.warningText : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Deshabilitado se pinta en magenta claro, no en gris: sigue leyéndose como
    // el botón de guardar, solo que todavía no se puede. El aviso de abajo dice
    // qué falta.
    return Material(
      color: enabled ? AppColors.primary500 : AppColors.primary300,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.white),
                  ),
                )
              else
                const Icon(Icons.check_rounded, size: 18, color: AppColors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
