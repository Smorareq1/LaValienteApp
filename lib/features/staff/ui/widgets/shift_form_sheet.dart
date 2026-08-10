import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/staff_remote_datasource.dart';
import '../../domain/overtime.dart';
import '../../models/staff.dart';
import '../../state/staff_admin_controller.dart';

/// Alta y edición de un turno (Plan 0006 §9.3).
///
/// La ventana del turno es contra lo que se mide la hora extra, así que moverla
/// cambia lo que el sistema **sugiere** de mañana en adelante. No cambia lo ya
/// pagado: esos minutos los confirmó una persona y el gasto los congeló (D8).
class ShiftFormSheet extends ConsumerStatefulWidget {
  const ShiftFormSheet({super.key, this.shift});

  /// `null` para crear.
  final WorkShift? shift;

  static Future<WorkShift?> show(BuildContext context, {WorkShift? shift}) {
    return AppBottomSheetScaffold.show<WorkShift>(
      context: context,
      builder: (context) => ShiftFormSheet(shift: shift),
    );
  }

  @override
  ConsumerState<ShiftFormSheet> createState() => _ShiftFormSheetState();
}

class _ShiftFormSheetState extends ConsumerState<ShiftFormSheet> {
  late final _code = TextEditingController(text: widget.shift?.code ?? '');
  late final _name = TextEditingController(text: widget.shift?.name ?? '');

  late ClockTime _startsAt = widget.shift?.startsAt ?? const ClockTime(6, 0);
  late ClockTime _endsAt = widget.shift?.endsAt ?? const ClockTime(11, 0);
  late bool _isActive = widget.shift?.isActive ?? true;

  String? _codeError;
  String? _nameError;
  String? _formError;
  bool _saving = false;

  bool get _isEditing => widget.shift != null;

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  static bool _isValidCode(String code) =>
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(code);

  Future<void> _save() async {
    final code = _code.text.trim().toLowerCase();
    final name = _name.text.trim();

    setState(() {
      _codeError = _isEditing || _isValidCode(code)
          ? null
          : 'Solo minúsculas, números y guion bajo, empezando por letra';
      _nameError = name.isEmpty ? 'Ponle el nombre con que se le llama' : null;
      _formError = _endsAt.minutesOfDay <= _startsAt.minutesOfDay
          ? 'Un turno tiene que terminar después de empezar, el mismo día.'
          : null;
    });

    if (_codeError != null || _nameError != null || _formError != null) return;

    setState(() => _saving = true);

    final input = ShiftInput(
      code: code,
      name: name,
      startsAt: _startsAt,
      endsAt: _endsAt,
      sortOrder: widget.shift?.sortOrder ?? 0,
      isActive: _isActive,
    );

    final controller = ref.read(shiftsAdminControllerProvider.notifier);
    final result = _isEditing
        ? await controller.edit(widget.shift!.id, input)
        : await controller.create(input);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (shift) => Navigator.of(context).pop(shift),
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = minutesBetween(_startsAt, _endsAt);

    return AppBottomSheetScaffold(
      title: _isEditing ? 'Editar el turno ${widget.shift!.name}' : 'Nuevo turno',
      subtitle: 'Se guarda en el servidor: esta pantalla necesita señal.',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.secondary,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: AppButton(
              label: _isEditing ? 'Guardar' : 'Crear turno',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        // El scroll lo hace la sheet; ver AppBottomSheetScaffold.
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        children: [
          if (!_isEditing) ...[
            AppFormField(
              label: 'CÓDIGO',
              controller: _code,
              hintText: 'morning',
              errorText: _codeError,
              helperText: 'No se puede cambiar después: es por lo que una jornada '
                  'ya marcada nombra su turno.',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
          ],
          AppFormField(
            label: 'NOMBRE',
            controller: _name,
            hintText: 'Mañana',
            errorText: _nameError,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMPIEZA', style: AppTypography.label),
                    const SizedBox(height: 7),
                    AppTimeField(
                      hour: _startsAt.hour,
                      minute: _startsAt.minute,
                      helpText: 'Hora de entrada del turno',
                      onChanged: (hour, minute) =>
                          setState(() => _startsAt = ClockTime(hour, minute)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TERMINA', style: AppTypography.label),
                    const SizedBox(height: 7),
                    AppTimeField(
                      hour: _endsAt.hour,
                      minute: _endsAt.minute,
                      helpText: 'Hora de salida del turno',
                      onChanged: (hour, minute) =>
                          setState(() => _endsAt = ClockTime(hour, minute)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (duration > 0) ...[
            const SizedBox(height: 10),
            _DurationNote(minutes: duration),
          ],
          if (_isEditing) ...[
            const SizedBox(height: 14),
            _ActiveSwitch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
          if (_formError != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Text(
                _formError!,
                style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cuánto dura el turno, que es contra lo que se mide la hora extra. Se enseña
/// mientras se escribe porque es la consecuencia real de mover las dos horas.
class _DurationNote extends StatelessWidget {
  const _DurationNote({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        'Turno de ${formatMinutes(minutes)}. Lo que se trabaje de más se sugiere '
        'como hora extra, y alguien lo confirma.',
        style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value ? 'En uso' : 'Fuera de uso',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value
                      ? 'Se ofrece al marcar una entrada.'
                      : 'Deja de ofrecerse; las jornadas que ya lo usan lo conservan.',
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
