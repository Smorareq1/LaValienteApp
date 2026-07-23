import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';

/// Pantalla principal (placeholder): confirma la sesión activa y permite
/// cerrar sesión mientras se construyen los módulos reales.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: AppSpacing.md,
                ),
                decoration: const BoxDecoration(
                  gradient: AppGradients.appBar,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buenos días',
                            style: AppTypography.helper
                                .copyWith(color: AppColors.primary100),
                          ),
                          Text(
                            'Panel de control',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppAvatar(
                      initials: (user != null && user.username.length >= 2)
                          ? user.username.substring(0, 2).toUpperCase()
                          : '··',
                      style: AppAvatarStyle.brand,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text('Sesión iniciada', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user?.displayName ?? '',
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    if (user != null && user.roles.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final role in user.roles)
                            AppChip(label: role, selected: true),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Cerrar sesión',
                      variant: AppButtonVariant.outline,
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                    ),
                  ],
                ),
              ),
              // Ejemplo del patrón de gating: este módulo solo se renderiza
              // para usuarios con permisos de administración.
              PermissionGate(
                anyOf: const [
                  'authorization.users.manage',
                  'authorization.roles.manage',
                ],
                child: Container(
                  margin: const EdgeInsets.only(top: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_outlined,
                          color: AppColors.primary500),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Administración', style: AppTypography.label),
                            Text(
                              'Usuarios, roles y permisos',
                              style: AppTypography.helper,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
