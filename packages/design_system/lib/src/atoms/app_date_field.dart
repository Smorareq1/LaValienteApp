import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

const List<String> _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// `22 jul 2026`, y `Hoy · 22 jul 2026` cuando la fecha es la de [today].
///
/// El "Hoy" delante no es decoración: la mayoría de las boletas se capturan el
/// mismo día, y quien lee el campo necesita ver de un vistazo que no está
/// registrando algo en la fecha equivocada.
String formatBusinessDate(DateTime date, {DateTime? today}) {
  final label = '${date.day} ${_months[date.month - 1]} ${date.year}';
  final reference = today;
  if (reference != null &&
      date.year == reference.year &&
      date.month == reference.month &&
      date.day == reference.day) {
    return 'Hoy · $label';
  }
  return label;
}

/// Campo de fecha: se lee como un campo y abre el calendario al tocarlo.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.today,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.helpText,
  });

  final DateTime value;

  /// `null` deja el campo en solo lectura (una fecha ya cerrada, por ejemplo).
  final ValueChanged<DateTime>? onChanged;

  /// Referencia para la etiqueta "Hoy". Por omisión, la fecha del dispositivo;
  /// quien trabaje con la fecha de negocio debe pasarla explícita.
  final DateTime? today;

  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? helpText;

  bool get _active => enabled && onChanged != null;

  Future<void> _pick(BuildContext context) async {
    final now = today ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: lastDate ?? DateTime(now.year + 1, 12, 31),
      helpText: helpText ?? 'Fecha del pedido',
      cancelText: 'Cancelar',
      confirmText: 'Elegir',
    );
    if (picked != null) onChanged!(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _active ? AppColors.white : AppColors.gray100,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: _active ? () => _pick(context) : null,
        borderRadius: AppRadius.mdAll,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: _active ? AppColors.primary500 : AppColors.gray400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  formatBusinessDate(value, today: today ?? DateTime.now()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 15,
                    color: _active ? AppColors.textPrimary : AppColors.gray400,
                  ),
                ),
              ),
              if (_active)
                const Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: AppColors.gray400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
