import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sync_status.dart';
import '../../state/sync_status_controller.dart';

/// Indicador global de sincronización del AppBar (Plan 0006 §11.1).
///
/// ✓ sincronizado · ⟳ sincronizando · N pendientes (naranja) · ! en revisión
/// (rojo). Al tocarlo se abre el detalle de sincronización.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusControllerProvider);

    final child = switch (status.state) {
      SyncState.synced => const _RoundIndicator(
          icon: Icons.check_rounded,
          tooltip: 'Todo sincronizado',
        ),
      SyncState.syncing => const _RoundIndicator(
          icon: Icons.sync_rounded,
          tooltip: 'Sincronizando…',
        ),
      SyncState.pending => _CountIndicator(
          icon: Icons.sync_rounded,
          count: status.pendingCount,
          background: AppColors.warningBg,
          foreground: AppColors.warningText,
          tooltip: '${status.pendingCount} operaciones pendientes de sincronizar',
        ),
      SyncState.needsReview => _CountIndicator(
          icon: Icons.error_outline_rounded,
          count: status.reviewCount,
          background: AppColors.errorBg,
          foreground: AppColors.errorText,
          tooltip: '${status.reviewCount} capturas necesitan revisión',
        ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullAll,
      child: child,
    );
  }
}

class _RoundIndicator extends StatelessWidget {
  const _RoundIndicator({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.18),
          borderRadius: AppRadius.fullAll,
        ),
        child: Icon(icon, size: 16, color: AppColors.white),
      ),
    );
  }
}

class _CountIndicator extends StatelessWidget {
  const _CountIndicator({
    required this.icon,
    required this.count,
    required this.background,
    required this.foreground,
    required this.tooltip,
  });

  final IconData icon;
  final int count;
  final Color background;
  final Color foreground;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.fullAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
