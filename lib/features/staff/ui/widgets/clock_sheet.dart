import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/overtime.dart';
import '../../models/staff.dart';

/// Lo que se captura al marcar una entrada.
class ClockInDraft {
  const ClockInDraft({required this.at, this.shiftId, this.notes});

  final ClockTime at;
  final String? shiftId;
  final String? notes;
}

/// Lo que se captura al cerrar una jornada: la hora y los minutos que quien
/// marca **confirma** que se pagan.
class ClockOutDraft {
  const ClockOutDraft({required this.at, required this.overtimeMinutes});

  final ClockTime at;
  final int overtimeMinutes;
}

/// Marcar la entrada de alguien (Plan 0006 §9.1).
///
/// La hora abre en la de ahora porque el caso normal es marcar a la persona que
/// acaba de llegar, pero se puede mover: la jornada también se copia de la hoja
/// de papel a media tarde.
class ClockInSheet extends StatefulWidget {
  const ClockInSheet({
    super.key,
    required this.employee,
    required this.shifts,
    required this.now,
  });

  final Employee employee;
  final List<WorkShift> shifts;
  final ClockTime now;

  static Future<ClockInDraft?> show(
    BuildContext context, {
    required Employee employee,
    required List<WorkShift> shifts,
    required ClockTime now,
  }) {
    return AppBottomSheetScaffold.show<ClockInDraft>(
      context: context,
      builder: (context) =>
          ClockInSheet(employee: employee, shifts: shifts, now: now),
    );
  }

  @override
  State<ClockInSheet> createState() => _ClockInSheetState();
}

class _ClockInSheetState extends State<ClockInSheet> {
  final TextEditingController _notes = TextEditingController();

  late ClockTime _at = widget.now;
  late String? _shiftId = _suggestedShiftId();

  /// El turno que cubre la hora de entrada. Es una sugerencia: quien marca puede
  /// quitarla, y trabajar fuera de todo turno es normal —es justo cuando no hay
  /// hora extra que sugerir después.
  String? _suggestedShiftId() {
    for (final shift in widget.shifts) {
      if (shift.covers(widget.now)) return shift.id;
    }
    return null;
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Marcar entrada',
      subtitle: widget.employee.fullName,
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Marcar entrada',
              icon: const Icon(Icons.login_rounded),
              fullWidth: true,
              elevated: true,
              onPressed: () => Navigator.of(context).pop(
                ClockInDraft(at: _at, shiftId: _shiftId, notes: _notes.text),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('HORA DE ENTRADA', style: AppTypography.label),
          const SizedBox(height: 7),
          AppTimeField(
            hour: _at.hour,
            minute: _at.minute,
            helpText: 'Hora de entrada',
            onChanged: (hour, minute) => setState(() {
              _at = ClockTime(hour, minute);
              _shiftId = _suggestedShiftId();
            }),
          ),
          const SizedBox(height: 14),
          Text('TURNO', style: AppTypography.label),
          const SizedBox(height: 7),
          if (widget.shifts.isEmpty)
            const _NoShifts()
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final shift in widget.shifts)
                  AppChip(
                    label: '${shift.name} · ${shift.scheduleLabel}',
                    selected: shift.id == _shiftId,
                    onTap: () => setState(
                      () => _shiftId = shift.id == _shiftId ? null : shift.id,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 7),
          Text(
            _shiftId == null
                ? 'Sin turno no se sugieren minutos extra: los dice una persona.'
                : 'La hora extra se mide contra este turno.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Text('NOTAS', style: AppTypography.label),
          const SizedBox(height: 7),
          AppTextField(
            controller: _notes,
            hintText: 'Opcional',
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// Cerrar la jornada y decidir qué hora extra se paga (Plan 0005 §6.2, D8).
///
/// El sistema propone los minutos, una persona decide, y lo que se guarda es la
/// decisión — puede quedar en cero. Por eso el campo viene lleno con la
/// sugerencia pero se puede escribir encima: son dos números distintos y la
/// pantalla no los confunde.
class ClockOutSheet extends StatefulWidget {
  const ClockOutSheet({super.key, required this.day, required this.now});

  final EmployeeDay day;
  final ClockTime now;

  static Future<ClockOutDraft?> show(
    BuildContext context, {
    required EmployeeDay day,
    required ClockTime now,
  }) {
    return AppBottomSheetScaffold.show<ClockOutDraft>(
      context: context,
      builder: (context) => ClockOutSheet(day: day, now: now),
    );
  }

  @override
  State<ClockOutSheet> createState() => _ClockOutSheetState();
}

class _ClockOutSheetState extends State<ClockOutSheet> {
  late final TextEditingController _minutes = TextEditingController(
    text: '${_suggestion()}',
  );

  late ClockTime _at = widget.now;
  String? _error;

  AttendanceRecord get _record => widget.day.record!;

  /// Los minutos que el sistema sugeriría con la hora que hay puesta ahora. Se
  /// recalcula al mover la hora, porque mover la salida cambia la propuesta.
  int _suggestion() {
    return suggestedOvertimeMinutes(
      clockIn: _record.clockIn,
      clockOut: _at,
      shift: widget.day.shift?.window,
    );
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  void _confirm() {
    final minutes = int.tryParse(_minutes.text.trim());
    setState(() {
      if (_at.compareTo(_record.clockIn) <= 0) {
        _error = 'La salida tiene que ser después de las ${_record.clockIn.label}';
      } else if (minutes == null || minutes < 0) {
        _error = 'Escribí los minutos extra, o 0 si no se pagan';
      } else {
        _error = null;
      }
    });
    if (_error != null) return;
    Navigator.of(context).pop(ClockOutDraft(at: _at, overtimeMinutes: minutes!));
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = _suggestion();
    final worked = workedMinutes(clockIn: _record.clockIn, clockOut: _at);
    final rate = widget.day.hourlyRate;
    final typed = int.tryParse(_minutes.text.trim()) ?? 0;
    final amount = formatOvertimeAmount(minutes: typed, hourlyRate: rate);

    return AppBottomSheetScaffold(
      title: 'Marcar salida',
      subtitle: widget.day.employee.fullName,
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Marcar salida',
              icon: const Icon(Icons.logout_rounded),
              fullWidth: true,
              elevated: true,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('HORA DE SALIDA', style: AppTypography.label),
          const SizedBox(height: 7),
          AppTimeField(
            hour: _at.hour,
            minute: _at.minute,
            helpText: 'Hora de salida',
            onChanged: (hour, minute) => setState(() {
              _at = ClockTime(hour, minute);
              // La sugerencia acompaña a la hora mientras nadie la haya
              // contradicho a mano.
              _minutes.text = '${_suggestion()}';
            }),
          ),
          const SizedBox(height: 10),
          _WorkedSummary(
            clockIn: _record.clockIn,
            clockOut: _at,
            workedMinutes: worked,
            shift: widget.day.shift,
          ),
          const SizedBox(height: 14),
          Text('MINUTOS EXTRA QUE SE PAGAN', style: AppTypography.label),
          const SizedBox(height: 7),
          AppTextField(
            controller: _minutes,
            hintText: '0',
            keyboardType: TextInputType.number,
            errorText: _error,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 7),
          Text(
            switch ((suggestion, amount)) {
              (0, _) => widget.day.shift == null
                  ? 'Esta jornada no tiene turno, así que no hay nada que sugerir.'
                  : 'No se pasó de su turno.',
              (_, final String value?) =>
                'Sugerido: ${formatMinutes(suggestion)}. Lo escrito son Q$value.',
              _ =>
                'Sugerido: ${formatMinutes(suggestion)}. No hay tarifa de hora '
                    'extra vigente para este día, así que todavía no se puede valuar.',
            },
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}


/// Cuánto lleva trabajado, contra el turno si lo hay.
class _WorkedSummary extends StatelessWidget {
  const _WorkedSummary({
    required this.clockIn,
    required this.clockOut,
    required this.workedMinutes,
    this.shift,
  });

  final ClockTime clockIn;
  final ClockTime clockOut;
  final int? workedMinutes;
  final WorkShift? shift;

  @override
  Widget build(BuildContext context) {
    final worked = workedMinutes;
    if (worked == null || worked <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        shift == null
            ? 'De ${clockIn.label} a ${clockOut.label} · ${formatMinutes(worked)}'
            : 'De ${clockIn.label} a ${clockOut.label} · ${formatMinutes(worked)} '
                  'sobre un turno de ${formatMinutes(shift!.durationMinutes)}',
        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _NoShifts extends StatelessWidget {
  const _NoShifts();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Todavía no bajaron los turnos a este teléfono. Se puede marcar la entrada '
      'igual; la hora extra habrá que decirla a mano.',
      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
    );
  }
}
