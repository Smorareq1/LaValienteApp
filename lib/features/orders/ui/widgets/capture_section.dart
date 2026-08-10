import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// De qué color va el número de la sección.
///
/// Las maquetas alternan el magenta y el cian en pares: no es decorativo, es lo
/// que hace que al deslizar se distingan los bloques de la boleta sin leerlos.
enum CaptureAccent { primary, secondary }

/// Una de las siete secciones de la boleta (plan 0002 §3).
///
/// Van numeradas y plegadas porque la boleta de papel también se lee por
/// bloques: el número es el mismo orden que tiene impreso el formulario, y el
/// resumen de la cabecera permite revisar el pedido entero sin abrir nada.
class CaptureSection extends StatelessWidget {
  const CaptureSection({
    super.key,
    required this.step,
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.accent = CaptureAccent.primary,
    this.incomplete = false,
    this.trailing,
  });

  final int step;
  final String title;

  /// Lo que se lee con la sección cerrada ("3 tipos de prenda").
  final String summary;

  final bool expanded;
  final VoidCallback onToggle;

  final CaptureAccent accent;

  /// Marca "Falta" en la cabecera: la sección tiene algo pendiente sin lo cual
  /// el pedido no se puede guardar.
  final bool incomplete;

  /// Contenido libre a la derecha del resumen (el contador de piezas).
  final Widget? trailing;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final (badgeBackground, badgeForeground) = switch (accent) {
      CaptureAccent.primary => (AppColors.primary100, AppColors.primary700),
      CaptureAccent.secondary => (AppColors.secondary100, AppColors.secondary700),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            label: title,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBackground,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$step',
                        style: AppTypography.money(
                          fontSize: 12,
                          color: badgeForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.h3.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.helper.copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
                    if (incomplete) ...[const _MissingPill(), const SizedBox(width: 8)],
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray100)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: child,
              ),
            ),
        ],
      ),
    );
  }
}

/// "Falta" en la cabecera de una sección. No usa `AppBadge` porque ese átomo
/// nombra estados de un pedido, y esto es un aviso del formulario.
class _MissingPill extends StatelessWidget {
  const _MissingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        'Falta',
        style: AppTypography.bodySm.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.errorText,
        ),
      ),
    );
  }
}

/// Etiqueta de un campo, del mismo tamaño en toda la boleta.
class CaptureLabel extends StatelessWidget {
  const CaptureLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTypography.label.copyWith(fontSize: 12),
      ),
    );
  }
}

/// Encabezado de un bloque dentro de una sección: las tinas, el secado, los
/// extras. La rayita de color a la izquierda es lo que los separa entre sí sin
/// meter otra tarjeta dentro de la tarjeta.
class CaptureGroupLabel extends StatelessWidget {
  const CaptureGroupLabel(
    this.text, {
    super.key,
    this.accent = CaptureAccent.secondary,
  });

  final String text;
  final CaptureAccent accent;

  @override
  Widget build(BuildContext context) {
    final (dash, foreground) = switch (accent) {
      CaptureAccent.primary => (AppColors.primary500, AppColors.primary700),
      CaptureAccent.secondary => (AppColors.secondary500, AppColors.secondary700),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: dash,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.button(fontSize: 11.5, color: foreground).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso que no bloquea: el rango de un nivel, una diferencia que solo hay que
/// mirar. En ámbar y no en rojo porque no impide guardar.
class CaptureNotice extends StatelessWidget {
  const CaptureNotice({super.key, required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 15,
            color: isError ? AppColors.errorText : AppColors.warningText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isError ? AppColors.errorText : AppColors.warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso informativo de una sección, en el magenta de la marca: no es una
/// advertencia, es una aclaración de cómo funciona lo que se acaba de tocar.
class CaptureHint extends StatelessWidget {
  const CaptureHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: AppColors.primary700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
