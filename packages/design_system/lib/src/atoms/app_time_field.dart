import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// `6:50`, la hora tal como se dice.
///
/// Sin cero delante y sin segundos: `06:50:00` es como viaja por el cable, no
/// como la lee quien marca una entrada.
String formatClock(int hour, int minute) =>
    '$hour:${minute.toString().padLeft(2, '0')}';

/// Campo de hora: se lee como un campo y abre el reloj al tocarlo.
///
/// Gemelo de [AppDateField], y por la misma razón — la hora de una jornada y la
/// de un turno se escriben en dos pantallas distintas y tienen que verse igual.
class AppTimeField extends StatelessWidget {
  const AppTimeField({
    super.key,
    required this.hour,
    required this.minute,
    required this.onChanged,
    this.enabled = true,
    this.helpText,
  });

  final int hour;
  final int minute;

  /// `null` deja el campo en solo lectura.
  final void Function(int hour, int minute)? onChanged;

  final bool enabled;
  final String? helpText;

  bool get _active => enabled && onChanged != null;

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      helpText: helpText ?? 'Hora',
      cancelText: 'Cancelar',
      confirmText: 'Listo',
    );
    if (picked != null) onChanged!(picked.hour, picked.minute);
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
                Icons.schedule_rounded,
                size: 18,
                color: _active ? AppColors.primary500 : AppColors.gray400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  formatClock(hour, minute),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
