import 'package:flutter/material.dart';

import '../atoms/app_money_text.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
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

/// De qué habla una pastilla del resumen.
enum AppSummaryTone {
  /// Lo que el cliente trae: piezas, unidades. Magenta.
  primary,

  /// Lo que se le hace: cargos, servicios. Cian.
  secondary,
}

/// El recuento pequeño que acompaña al total ("12 pzas", "4 cargos").
class AppSummaryPill {
  const AppSummaryPill(this.label, {this.tone = AppSummaryTone.primary});

  final String label;
  final AppSummaryTone tone;
}

/// Footer fijo con el total y la acción principal.
///
/// Es el "resumen de la boleta" del plan 0002 §3.8: vive pegado abajo, se
/// recalcula con cada cambio y **no se va con el scroll**. El total es la
/// pregunta que el cliente hace de pie frente al mostrador, así que la respuesta
/// no puede estar a tres deslizadas de distancia.
///
/// La acción ocupa todo el ancho debajo de la cifra y no a su lado: es el único
/// botón de la pantalla y no tiene con quién competir por el espacio.
class AppSummaryBar extends StatelessWidget {
  const AppSummaryBar({
    super.key,
    required this.total,
    required this.actionLabel,
    required this.onAction,
    this.totalLabel = 'TOTAL',
    this.lines = const [],
    this.caption,
    this.pills = const [],
    this.note,
    this.noteIsWarning = false,
    this.busy = false,
  });

  final double total;
  final String totalLabel;

  /// Cifras de arriba (subtotal, descuento). Vacío deja solo el total.
  final List<AppSummaryLine> lines;

  /// Texto pequeño bajo el total, cuando el recuento no cabe en pastillas.
  final String? caption;

  /// Recuentos a la derecha del total. Tienen prioridad sobre [caption].
  final List<AppSummaryPill> pills;

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
            color: Color(0x1F16181D),
            blurRadius: 30,
            spreadRadius: -18,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lines.isNotEmpty) _Lines(lines: lines),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              totalLabel,
                              style: AppTypography.caption.copyWith(fontSize: 10.5),
                            ),
                            const SizedBox(width: 6),
                            Flexible(child: AppMoneyText(total, size: AppMoneySize.hero)),
                          ],
                        ),
                        if (pills.isEmpty && caption != null)
                          Text(
                            caption!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.helper.copyWith(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  if (pills.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final pill in pills)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _Pill(pill: pill),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 9),
              _ActionButton(
                label: actionLabel,
                enabled: enabled,
                busy: busy,
                onTap: onAction,
              ),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (noteIsWarning) ...[
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 15,
                          color: AppColors.errorText,
                        ),
                        const SizedBox(width: 7),
                      ],
                      Expanded(
                        child: Text(
                          note!,
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: noteIsWarning
                                ? AppColors.errorText
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines({required this.lines});

  final List<AppSummaryLine> lines;

  @override
  Widget build(BuildContext context) {
    // Wrap y no Row: en un teléfono angosto el descuento se va al renglón de
    // abajo en vez de recortarse, que es la cifra que nadie querría no ver.
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Wrap(
        spacing: 10,
        children: [
          for (final line in lines)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${line.label} ',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: line.emphasis ? AppColors.primary700 : AppColors.gray500,
                  ),
                ),
                AppMoneyText(
                  line.amount,
                  size: AppMoneySize.sm,
                  color: line.emphasis ? AppColors.primary700 : AppColors.gray500,
                  decimalColor: line.emphasis
                      ? AppColors.primary300
                      : AppColors.gray400,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.pill});

  final AppSummaryPill pill;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (pill.tone) {
      AppSummaryTone.primary => (AppColors.primary100, AppColors.primary700),
      AppSummaryTone.secondary => (AppColors.secondary100, AppColors.secondary700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.fullAll),
      child: Text(
        pill.label,
        style: AppTypography.bodySm.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: foreground,
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.white),
                  ),
                )
              else
                const Icon(Icons.check_rounded, size: 19, color: AppColors.white),
              const SizedBox(width: 9),
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
