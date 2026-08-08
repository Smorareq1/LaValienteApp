import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';


/// El día que la pantalla está mirando, sobre la cabecera con gradiente.
///
/// Es gemelo del `_DayChip` de la Caja. Se duplica a propósito y por ahora:
/// sacarlo a un componente compartido toca `cash_screen.dart`, que en este
/// momento está creciendo con el cierre del día en otra rama. Unificarlos es
/// trabajo del pase de pulido (§UI 10), cuando las dos pantallas estén quietas.
class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.today,
    required this.onChanged,
    this.helpText = 'Día',
  });

  final DateTime date;
  final DateTime today;
  final ValueChanged<DateTime> onChanged;
  final String helpText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.18),
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(today.year - 1),
            // Nunca hacia adelante: una jornada del futuro no existe.
            lastDate: today,
            helpText: helpText,
            cancelText: 'Cancelar',
            confirmText: 'Ver',
          );
          if (picked != null) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.white),
              const SizedBox(width: 7),
              Text(
                formatBusinessDate(date, today: today),
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
