import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/access.dart';
import '../../state/access_controller.dart';

/// Qué puede hacer una cuenta y si puede entrar (Plan 0006 §12).
///
/// Dos decisiones en una sheet porque se toman juntas —«a esta persona la paso a
/// admin» y «esta ya no trabaja aquí»— pero se guardan **por separado**: el
/// interruptor escribe al tocarlo y los roles al pulsar guardar. Un `PUT` de
/// roles y un `PATCH` de estado son dos llamadas distintas, y fingir que son una
/// sola dejaría la mitad hecha cuando una falle.
class UserAccessSheet extends ConsumerStatefulWidget {
  const UserAccessSheet({super.key, required this.user, this.isMe = false});

  final SystemUser user;

  /// La cuenta con la que se está viendo la pantalla. No se puede apagar a sí
  /// misma —el servidor lo rechaza— así que el interruptor ni se ofrece.
  final bool isMe;

  static Future<void> show(
    BuildContext context, {
    required SystemUser user,
    bool isMe = false,
  }) {
    return AppBottomSheetScaffold.show<void>(
      context: context,
      builder: (context) => UserAccessSheet(user: user, isMe: isMe),
    );
  }

  @override
  ConsumerState<UserAccessSheet> createState() => _UserAccessSheetState();
}

class _UserAccessSheetState extends ConsumerState<UserAccessSheet> {
  /// Ids de rol marcados. Arranca vacío y se llena en cuanto baja el catálogo:
  /// la cuenta trae los **códigos** de sus roles y el `PUT` pide **ids**.
  Set<String>? _selected;

  String? _formError;
  bool _savingRoles = false;
  bool _switching = false;

  late bool _isActive = widget.user.isActive;

  Set<String> _initialFrom(List<AccessRole> catalog) => {
    for (final role in catalog)
      if (widget.user.roles.contains(role.code)) role.id,
  };

  Future<void> _saveRoles(List<AccessRole> catalog) async {
    final selected = _selected;
    if (selected == null) return;

    setState(() {
      _savingRoles = true;
      _formError = null;
    });

    final result = await ref
        .read(usersAdminControllerProvider.notifier)
        .assignRoles(widget.user, roleIds: selected, catalog: catalog);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _savingRoles = false;
        _formError = failure.message;
      }),
      (_) => Navigator.of(context).pop(),
    );
  }

  Future<void> _toggleAccess(bool value) async {
    // Quitar el acceso corta sesiones abiertas, así que se confirma. Devolverlo
    // no rompe nada y va directo.
    if (!value) {
      final confirmed = await AppConfirmDialog.show(
        context: context,
        title: '¿Quitarle el acceso a ${widget.user.username}?',
        message:
            'No podrá entrar a la app y se le cerrará la sesión donde la tenga '
            'abierta. Lo que haya capturado se conserva, y el acceso se le '
            'puede devolver aquí mismo.',
        confirmLabel: 'Quitar acceso',
        destructive: true,
        icon: Icons.no_accounts_rounded,
      );
      if (!confirmed || !mounted) return;
    }

    setState(() {
      _switching = true;
      _formError = null;
    });

    final result = await ref
        .read(usersAdminControllerProvider.notifier)
        .setActive(widget.user.id, isActive: value);

    if (!mounted) return;

    setState(() {
      _switching = false;
      result.match(
        (failure) => _formError = failure.message,
        (user) => _isActive = user.isActive,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(accessRolesProvider);
    final catalog = roles.valueOrNull ?? const <AccessRole>[];
    _selected ??= roles.hasValue ? _initialFrom(catalog) : null;

    return AppBottomSheetScaffold(
      title: widget.user.displayName,
      subtitle: widget.user.email == null || widget.user.email!.isEmpty
          ? widget.user.username
          : '${widget.user.username} · ${widget.user.email}',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cerrar',
              variant: AppButtonVariant.secondary,
              onPressed: _savingRoles ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Guardar roles',
              loading: _savingRoles,
              onPressed: _selected == null || _savingRoles || catalog.isEmpty
                  ? null
                  : () => _saveRoles(catalog),
            ),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        children: [
          Text('ROLES', style: AppTypography.label),
          const SizedBox(height: 7),
          switch (roles) {
            AsyncData(value: final list) when list.isEmpty => const _Note(
              message:
                  'No se pudieron listar los roles. Verlos pide '
                  '«authorization.roles.manage», que no va incluido en el '
                  'permiso de administrar usuarios.',
            ),
            AsyncData(value: final list) => Column(
              children: [
                for (final role in list)
                  _RoleTile(
                    role: role,
                    checked: _selected!.contains(role.id),
                    onChanged: (value) => setState(() {
                      if (value) {
                        _selected!.add(role.id);
                      } else {
                        _selected!.remove(role.id);
                      }
                    }),
                  ),
              ],
            ),
            AsyncError(:final error) => _Note(message: '$error'),
            _ => const _Note(message: 'Leyendo los roles…'),
          },
          if (_selected != null && _selected!.isEmpty) ...[
            const SizedBox(height: 10),
            const _Note(
              message:
                  'Sin ningún rol la cuenta entra pero no ve nada: la app '
                  'oculta lo que su permiso no alcanza.',
            ),
          ],
          const SizedBox(height: 18),
          Text('ACCESO', style: AppTypography.label),
          const SizedBox(height: 7),
          if (widget.isMe)
            const _Note(
              message:
                  'Es tu propia cuenta. Nadie puede quitarse el acceso a sí '
                  'mismo: quedarías fuera de la pantalla que lo devuelve.',
            )
          else
            _AccessSwitch(
              value: _isActive,
              busy: _switching,
              onChanged: _switching ? null : _toggleAccess,
            ),
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

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.checked,
    required this.onChanged,
  });

  final AccessRole role;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          decoration: BoxDecoration(
            color: checked ? AppColors.primary50 : AppColors.background,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: checked ? AppColors.primary300 : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      role.description ?? role.code,
                      style: AppTypography.helper.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: checked,
                onChanged: (value) => onChanged(value ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quitar el acceso no borra la cuenta: los pedidos que recibió y los gastos que
/// anotó la siguen nombrando, y borrar la fila dejaría esa auditoría colgando.
class _AccessSwitch extends StatelessWidget {
  const _AccessSwitch({
    required this.value,
    required this.busy,
    required this.onChanged,
  });

  final bool value;
  final bool busy;
  final ValueChanged<bool>? onChanged;

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
                  value ? 'Puede entrar' : 'Sin acceso',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value
                      ? 'Entra a la app con su usuario y contraseña.'
                      : 'No puede entrar; lo que capturó se conserva.',
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.message});

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
