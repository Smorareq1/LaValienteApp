import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../access/models/access.dart';
import '../../data/staff_remote_datasource.dart';
import '../../models/staff.dart';
import '../../state/staff_admin_controller.dart';

/// Alta y edición de alguien del personal (Plan 0006 §9.2).
///
/// **Un empleado no es un usuario.** La mayoría del personal no entra a la app:
/// se le anota la jornada y ya. Vincular una cuenta es opcional y existe para el
/// caso contrario, quien sí opera el mostrador (plan 0005 D6).
class EmployeeFormSheet extends ConsumerStatefulWidget {
  const EmployeeFormSheet({super.key, this.employee});

  /// `null` para crear.
  final Employee? employee;

  static Future<Employee?> show(BuildContext context, {Employee? employee}) {
    return AppBottomSheetScaffold.show<Employee>(
      context: context,
      builder: (context) => EmployeeFormSheet(employee: employee),
    );
  }

  @override
  ConsumerState<EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends ConsumerState<EmployeeFormSheet> {
  late final _name = TextEditingController(text: widget.employee?.fullName ?? '');
  late final _phone = TextEditingController(text: widget.employee?.phone ?? '');
  late final _notes = TextEditingController(text: widget.employee?.notes ?? '');

  late String? _userId = widget.employee?.userId;
  late bool _isActive = widget.employee?.isActive ?? true;

  String? _nameError;
  String? _formError;
  bool _saving = false;

  bool get _isEditing => widget.employee != null;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Sin nombre no se le puede marcar la entrada' : null;
    });
    if (_nameError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final phone = _phone.text.trim();
    final notes = _notes.text.trim();
    final input = EmployeeInput(
      fullName: name,
      phone: phone.isEmpty ? null : phone,
      userId: _userId,
      notes: notes.isEmpty ? null : notes,
      isActive: _isActive,
    );

    final controller = ref.read(employeesAdminControllerProvider.notifier);
    final result = _isEditing
        ? await controller.edit(widget.employee!.id, input)
        : await controller.create(input);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (employee) => Navigator.of(context).pop(employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(systemUsersProvider);

    return AppBottomSheetScaffold(
      title: _isEditing ? 'Editar a ${widget.employee!.fullName}' : 'Nuevo empleado',
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
              label: _isEditing ? 'Guardar' : 'Dar de alta',
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
          AppFormField(
            label: 'NOMBRE COMPLETO',
            controller: _name,
            hintText: 'Claudia Pérez',
            errorText: _nameError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'TELÉFONO',
            controller: _phone,
            optional: true,
            hintText: '5555 5555',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _UserPicker(
            users: users,
            value: _userId,
            onChanged: (id) => setState(() => _userId = id),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NOTAS',
            controller: _notes,
            optional: true,
            maxLines: 3,
            hintText: 'Lo que haga falta recordar de esta persona.',
          ),
          if (_isEditing) ...[
            const SizedBox(height: 14),
            _ActiveSwitch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
          if (_formError != null) ...[
            const SizedBox(height: 14),
            _FormError(message: _formError!),
          ],
        ],
      ),
    );
  }
}

/// El desplegable de cuentas del sistema.
///
/// Si el servidor no deja listarlas —pide `authorization.users.manage`, que
/// `staff.manage` no implica— llega vacío y el campo lo dice en vez de mostrar
/// un desplegable sin opciones que parecería un error.
class _UserPicker extends StatelessWidget {
  const _UserPicker({
    required this.users,
    required this.value,
    required this.onChanged,
  });

  final AsyncValue<List<SystemUser>> users;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('USUARIO VINCULADO', style: AppTypography.label),
            const SizedBox(width: 6),
            Text(
              '· opcional',
              style: AppTypography.label.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 7),
        switch (users) {
          AsyncData(:final value) when value.isEmpty => const _PickerNote(
            message:
                'No hay cuentas que vincular, o este usuario no puede verlas. '
                'La mayoría del personal no entra a la app.',
          ),
          AsyncData(value: final options) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                isExpanded: true,
                hint: Text(
                  'Sin cuenta',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    child: Text('Sin cuenta'),
                  ),
                  for (final user in options)
                    DropdownMenuItem<String?>(
                      value: user.id,
                      child: Text(
                        user.isActive ? user.label : '${user.label} · inactiva',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
          AsyncError() => const _PickerNote(
            message: 'No se pudieron leer las cuentas. Se puede guardar sin vincular.',
          ),
          _ => const _PickerNote(message: 'Leyendo las cuentas…'),
        },
      ],
    );
  }
}

class _PickerNote extends StatelessWidget {
  const _PickerNote({required this.message});

  final String message;

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
        message,
        style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// Dar de baja no borra: la asistencia y las horas extra ya pagadas apuntan a
/// esta persona, así que se apaga y deja de salir en la lista del día.
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
                  value ? 'Trabaja aquí' : 'Ya no trabaja aquí',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value
                      ? 'Aparece en la lista de asistencia del día.'
                      : 'Sale de la lista del día; sus jornadas se conservan.',
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

class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        message,
        style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
      ),
    );
  }
}
