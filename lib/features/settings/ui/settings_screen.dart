import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/time/relative_time.dart';
import '../../access/ui/users_screen.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/state/auth_controller.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../../sync/data/devices_remote_datasource.dart';
import '../../sync/state/devices_controller.dart';

/// Ajustes (Plan 0006 §12).
///
/// Cuatro cosas: quién eres, quién más entra al sistema, con qué aparatos, y
/// cómo salir. Las dos de en medio piden su permiso y se ocultan sin él (§13).
///
/// Usuarios y roles vive en su **propia pantalla** y no en una sección de esta:
/// los dispositivos son una lista corta que se revoca de un toque, y las cuentas
/// llevan alta, roles y acceso, que es más de lo que cabe bajo el perfil sin
/// enterrar el botón de cerrar sesión.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String path = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final canSeeDevices =
        user?.hasPermission(AppPermissions.syncDevicesManage) ?? false;
    final canManageUsers =
        user?.hasPermission(AppPermissions.usersManage) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (user != null) _Profile(user: user),
                const SizedBox(height: 18),
                const _PasswordCard(),
                if (canManageUsers) ...[
                  const SizedBox(height: 22),
                  const _UsersEntry(),
                ],
                if (canSeeDevices) ...[
                  const SizedBox(height: 22),
                  const _Devices(),
                ],
                const SizedBox(height: 22),
                const _SignOut(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La puerta a «Usuarios y roles».
///
/// El primer administrador sigue saliendo de `create_superuser.py` —alguien
/// tiene que tener el permiso antes de que nadie pueda repartirlo— y de ahí en
/// adelante las cuentas se administran desde aquí.
class _UsersEntry extends StatelessWidget {
  const _UsersEntry();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(title: 'Accesos'),
        const SizedBox(height: 9),
        AppListCard(
          title: 'Usuarios y roles',
          subtitle: 'Quién entra a la app y qué puede hacer',
          leading: const AppListCardTile(
            icon: Icons.badge_outlined,
            background: AppColors.primary50,
            foreground: AppColors.primary700,
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.gray400,
          ),
          onTap: () => context.push(UsersScreen.path),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Ajustes',
              style: AppTypography.h3.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.user});

  final AuthUser user;

  /// Las iniciales del avatar. Un usuario sin nombre completo cae en su
  /// username, que siempre tiene al menos una letra.
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(initials: _initials(user.displayName), size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTypography.h3.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  user.username,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (user.roles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final role in user.roles)
                        AppStatusBadge(
                          label: role,
                          tone: AppStatusTone.info,
                          size: AppStatusBadgeSize.sm,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cambiar la contraseña reusa la recuperación por correo que ya existe.
///
/// El backend no tiene un «cambiar contraseña estando dentro»: tiene el flujo de
/// recuperación, que verifica por correo. Mandar por ahí es más seguro que
/// inventar un endpoint, y es honesto decir por dónde llega.
class _PasswordCard extends ConsumerStatefulWidget {
  const _PasswordCard();

  @override
  ConsumerState<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends ConsumerState<_PasswordCard> {
  bool _sending = false;
  String? _message;

  Future<void> _request() async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _sending = true;
      _message = null;
    });

    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(identifier: user.email ?? user.username);

    if (!mounted) return;
    setState(() {
      _sending = false;
      _message = result.match(
        (failure) => failure.message,
        (_) => 'Listo. Te llegó un correo con el enlace para cambiarla.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contraseña',
            style: AppTypography.bodySm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Se cambia por correo, con un enlace que caduca.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Mandarme el enlace',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.secondary,
            loading: _sending,
            onPressed: _sending ? null : _request,
          ),
          if (_message != null) ...[
            const SizedBox(height: 10),
            Text(
              _message!,
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Devices extends ConsumerWidget {
  const _Devices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(title: 'Dispositivos'),
        const SizedBox(height: 9),
        switch (devices) {
          AsyncData(value: final list) when list.isEmpty => const _Note(
            message: 'Ningún dispositivo se ha registrado todavía.',
          ),
          AsyncData(value: final list) => Column(
            children: [
              for (final device in list) ...[
                _DeviceRow(device: device),
                const SizedBox(height: 7),
              ],
            ],
          ),
          AsyncError(:final error) => _Note(message: '$error'),
          _ => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
      ],
    );
  }
}

class _DeviceRow extends ConsumerWidget {
  const _DeviceRow({required this.device});

  final SyncDevice device;

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    // Confirmación fuerte porque no es apagar un interruptor: el aparato borra
    // su base local en el siguiente contacto (plan 0004 D11), y lo que no haya
    // subido se va con ella.
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '¿Revocar ${device.name}?',
      message:
          'Ese teléfono dejará de sincronizar y borrará todo lo que tenga '
          'guardado la próxima vez que se conecte. Lo que haya capturado y no '
          'haya subido se pierde.',
      confirmLabel: 'Revocar',
      destructive: true,
      icon: Icons.phonelink_erase_rounded,
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref
        .read(devicesControllerProvider.notifier)
        .revoke(device.id);

    if (!context.mounted) return;
    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.name} quedó fuera.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppListCard(
      title: device.name,
      subtitle: switch ((device.platform, device.lastSeenAt)) {
        (final String platform, final DateTime seen) =>
          '$platform · visto ${relativeAge(seen)}',
        (final String platform, null) => '$platform · nunca ha sincronizado',
        (null, final DateTime seen) => 'Visto ${relativeAge(seen)}',
        _ => 'Nunca ha sincronizado',
      },
      leading: AppListCardTile(
        icon: Icons.smartphone_rounded,
        background: device.isRevoked ? AppColors.gray100 : AppColors.primary50,
        foreground: device.isRevoked ? AppColors.gray400 : AppColors.primary700,
      ),
      titleSuffix: device.isRevoked
          ? const AppStatusBadge(
              label: 'Revocado',
              tone: AppStatusTone.error,
              size: AppStatusBadgeSize.sm,
            )
          : null,
      trailing: device.isRevoked
          ? null
          : IconButton(
              tooltip: 'Revocar',
              icon: const Icon(Icons.block_rounded, size: 19),
              color: AppColors.errorText,
              onPressed: () => _revoke(context, ref),
            ),
    );
  }
}

class _SignOut extends ConsumerWidget {
  const _SignOut();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Cerrar sesión',
      variant: AppButtonVariant.secondary,
      fullWidth: true,
      icon: const Icon(Icons.logout_rounded, size: 17),
      onPressed: () async {
        final confirmed = await AppConfirmDialog.show(
          context: context,
          title: '¿Cerrar sesión?',
          message:
              'Lo que esté capturado y sin subir se queda en este teléfono '
              'esperando a que alguien vuelva a entrar.',
          confirmLabel: 'Cerrar sesión',
          icon: Icons.logout_rounded,
        );
        if (confirmed) await ref.read(authControllerProvider.notifier).logout();
      },
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
