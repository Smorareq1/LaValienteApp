import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

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
    this.incomplete = false,
    this.trailing,
  });

  final int step;
  final String title;

  /// Lo que se lee con la sección cerrada ("3 tipos de prenda").
  final String summary;

  final bool expanded;
  final VoidCallback onToggle;

  /// Marca "Falta" en la cabecera: la sección tiene algo pendiente sin lo cual
  /// el pedido no se puede guardar.
  final bool incomplete;

  /// Contenido libre a la derecha del resumen (el contador de piezas).
  final Widget? trailing;

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$step',
                        style: AppTypography.money(
                          fontSize: 13,
                          color: AppColors.primary700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                        size: 20,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 14),
              child: child,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        'Falta',
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          letterSpacing: 0,
          fontWeight: FontWeight.w800,
          color: AppColors.warningText,
        ),
      ),
    );
  }
}

/// Etiqueta pequeña sobre un campo, del mismo tamaño en toda la boleta.
class CaptureLabel extends StatelessWidget {
  const CaptureLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTypography.caption.copyWith(fontSize: 10.5)),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 16,
            color: isError ? AppColors.errorText : AppColors.warningText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
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
