import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/state/auth_controller.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import 'widgets/settings_group.dart';

/// Pantalla "Más" (Plan 0006 §3.1): el acceso a los módulos que no tienen tab
/// propio, más el perfil y el cierre de sesión.
///
/// Cada entrada está detrás de su permiso; sin permiso no se renderiza, y un
/// grupo sin entradas visibles desaparece completo (§13).
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static const String path = '/more';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Column(
      children: [
        _MoreHeader(user: user),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 14, AppSpacing.md, 28),
            children: [
              SettingsGroup(
                label: 'Operación',
                children: [
                  if (user.can(AppPermissions.inventoryRead))
                    SettingsRow(
                      title: 'Insumos',
                      subtitle: 'Productos, lotes y existencias',
                      icon: Icons.inventory_2_outlined,
                      iconBackground: AppColors.secondary100,
                      iconColor: AppColors.secondary700,
                      onTap: () => context.push('/inventory'),
                    ),
                  if (user.can(AppPermissions.attendanceRecord) ||
                      user.can(AppPermissions.staffRead))
                    SettingsRow(
                      title: 'Personal',
                      subtitle: 'Asistencia, empleados y turnos',
                      icon: Icons.badge_outlined,
                      iconBackground: AppColors.warningBg,
                      iconColor: AppColors.warningText,
                      onTap: () => context.push('/staff'),
                    ),
                ],
              ),
              SettingsGroup(
                label: 'Administración',
                children: [
                  if (user.can(AppPermissions.catalogManage))
                    SettingsRow(
                      title: 'Catálogo',
                      subtitle: 'Servicios, precios y tipos de prenda',
                      icon: Icons.sell_outlined,
                      iconBackground: AppColors.primary100,
                      iconColor: AppColors.primary700,
                      onTap: () => context.push('/catalog'),
                    ),
                  if (user.can(AppPermissions.promotionsManage))
                    SettingsRow(
                      title: 'Promociones',
                      subtitle: 'Descuentos y vigencias',
                      icon: Icons.local_offer_outlined,
                      iconBackground: AppColors.primary100,
                      iconColor: AppColors.primary700,
                      onTap: () => context.push('/promotions'),
                    ),
                  if (user.can(AppPermissions.dailyCloseRead))
                    SettingsRow(
                      title: 'Cierres de días pasados',
                      subtitle: 'Ver el acta de cualquier día',
                      icon: Icons.calendar_month_outlined,
                      iconBackground: AppColors.successBg,
                      iconColor: AppColors.successText,
                      onTap: () => context.push('/cash/history'),
                    ),
                ],
              ),
              SettingsGroup(
                label: 'Sistema',
                children: [
                  SettingsRow(
                    title: 'Sincronización',
                    subtitle: 'Estado, pendientes y cola de revisión',
                    icon: Icons.sync_rounded,
                    iconBackground: AppColors.secondary100,
                    iconColor: AppColors.secondary700,
                    onTap: () => context.push('/sync'),
                  ),
                  SettingsRow(
                    title: 'Ajustes',
                    subtitle: 'Perfil, contraseña y dispositivos',
                    icon: Icons.settings_outlined,
                    iconBackground: AppColors.gray100,
                    iconColor: AppColors.textSecondary,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _LogoutButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Azúcar para leer permisos de un usuario que puede ser `null` mientras se
/// restaura la sesión.
extension on AuthUser? {
  bool can(String permission) => this?.hasPermission(permission) ?? false;
}

class _MoreHeader extends StatelessWidget {
  const _MoreHeader({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Más',
            style: AppTypography.h3.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials(user?.displayName),
                  style: AppTypography.money(
                    fontSize: 18,
                    color: AppColors.primary700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final role in user?.roles ?? const <String>[])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.22),
                              borderRadius: AppRadius.fullAll,
                            ),
                            child: Text(
                              role,
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary100,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return '··';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDA29B), width: 1.5),
          ),
          padding: const EdgeInsets.all(13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, size: 17, color: AppColors.errorText),
              const SizedBox(width: 8),
              Text(
                'Cerrar sesión',
                style: AppTypography.button(fontSize: 14, color: AppColors.errorText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
