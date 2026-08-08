import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/access.dart';
import '../state/access_controller.dart';
import 'widgets/new_account_sheet.dart';
import 'widgets/user_access_sheet.dart';

/// Usuarios y roles (Plan 0006 §12).
///
/// La pantalla que la pregunta abierta 4 daba por pospuesta a la fase 2. La
/// premisa que la posponía —«identity no expone el alta de una cuenta»— no era
/// cierta: `POST /auth/register` existe desde el principio y siempre estuvo
/// detrás de `authorization.users.manage`. Lo único que de verdad faltaba era
/// **apagar** una cuenta, y eso llegó con `PATCH /authorization/users/{id}`.
///
/// **En línea**, como toda la administración, y con más razón que ninguna: una
/// credencial creada sin señal existiría en un teléfono y en ningún otro sitio.
///
/// Lo que sigue fuera es el **primer** administrador, que sale de
/// `create_superuser.py` por el huevo y la gallina: alguien tiene que tener el
/// permiso antes de que nadie pueda repartirlo.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  static const String path = '/settings/users';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersAdminControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(active: users.valueOrNull?.where((u) => u.isActive).length),
          Expanded(
            child: switch (users) {
              AsyncData(:final value) => _List(users: value),
              AsyncError(:final error) => _LoadError(
                message: '$error',
                onRetry: () => ref.invalidate(usersAdminControllerProvider),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NewAccountSheet.show(context),
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text('Cuenta'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.active});

  final int? active;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active == null ? '' : '$active con acceso',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Usuarios y roles',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({required this.users});

  final List<SystemUser> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: AppEmptyState(
          icon: Icons.badge_outlined,
          title: 'No hay cuentas todavía',
          message:
              'Crea una cuenta para quien deba entrar a la app y dale el rol '
              'que le corresponde.',
        ),
      );
    }

    // La cuenta con la que se está viendo la pantalla se marca: es la única que
    // no se puede apagar, y saber cuál es antes de tocarla evita el intento.
    final me = ref.watch(authControllerProvider).valueOrNull?.id;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          _UserRow(user: users[index], isMe: users[index].id == me),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.isMe});

  final SystemUser user;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: user.displayName,
      subtitle: switch ((user.username, user.roles.isEmpty)) {
        (final String username, true) => '$username · sin rol',
        (final String username, false) => '$username · ${user.roles.join(", ")}',
      },
      leading: AppListCardTile(
        label: user.initials,
        background: user.isActive ? AppColors.primary50 : AppColors.gray100,
        foreground: user.isActive ? AppColors.primary700 : AppColors.gray400,
      ),
      titleSuffix: switch ((user.isActive, isMe)) {
        (false, _) => const AppStatusBadge(
          label: 'Sin acceso',
          tone: AppStatusTone.neutral,
          size: AppStatusBadgeSize.sm,
        ),
        (true, true) => const AppStatusBadge(
          label: 'Tú',
          tone: AppStatusTone.brand,
          size: AppStatusBadgeSize.sm,
        ),
        _ => null,
      },
      onTap: () => UserAccessSheet.show(context, user: user, isMe: isMe),
    );
  }
}

/// Sin red esta pantalla no tiene nada que enseñar, y decirlo es más honesto que
/// una lista vacía que parecería que nadie tiene acceso.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron leer las cuentas',
        message: message,
        action: AppButton(label: 'Reintentar', onPressed: onRetry),
      ),
    );
  }
}
