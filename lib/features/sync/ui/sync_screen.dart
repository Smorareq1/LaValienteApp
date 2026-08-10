import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/time/relative_time.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../data/sync_repository.dart';
import '../models/sync_details.dart';
import '../models/sync_entity_label.dart';
import '../models/sync_status.dart';
import '../state/sync_engine.dart';
import '../state/sync_status_controller.dart';
import 'review_queue_screen.dart';

/// Pantalla de Sincronización (Plan 0006 §11): qué está subido, qué falta y
/// por qué.
///
/// Cuando algo "no aparece en la otra tableta", esta pantalla tiene que
/// responder sin que nadie abra un log: cuántas capturas esperan, cuándo fue
/// el último ciclo y qué falló.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  static const String path = '/sync';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusControllerProvider);
    final engine = ref.watch(syncEngineProvider);
    final details = ref.watch(syncDetailsProvider).valueOrNull;
    final pending = ref.watch(pendingByEntityProvider).valueOrNull ?? const {};

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _Header(status: status),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 28),
              children: [
                _StatusCard(status: status, engine: engine),
                if (status.hasReview) ...[
                  const SizedBox(height: 12),
                  _ReviewLink(count: status.reviewCount),
                ],
                const SizedBox(height: 18),
                AppButton(
                  label: 'Sincronizar ahora',
                  icon: const Icon(Icons.sync_rounded, size: 17, color: AppColors.white),
                  fullWidth: true,
                  loading: engine.progress.isRunning,
                  onPressed: () => ref.read(syncEngineProvider.notifier).sync(),
                ),
                if (pending.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const AppSectionHeader(title: 'Esperando subir'),
                  _PendingByType(pending: pending),
                ],
                const SizedBox(height: 24),
                const AppSectionHeader(
                  title: 'Diagnóstico',
                  accentColor: AppColors.secondary500,
                ),
                _Diagnostics(details: details, engine: engine),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Entrada a la cola de revisión desde el estado de sincronización.
///
/// La tarjeta de arriba ya dice que hay capturas rechazadas; sin esta puerta,
/// decirlo solo serviría para preocupar.
class _ReviewLink extends StatelessWidget {
  const _ReviewLink({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: count == 1 ? '1 captura necesita tu decisión' : '$count capturas necesitan tu decisión',
      subtitle: 'Abrir la cola de revisión',
      onTap: () => context.push(ReviewQueueScreen.path),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.priority_high_rounded,
          size: 18,
          color: AppColors.errorText,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Pendientes por tipo (§11.1).
class _PendingByType extends StatelessWidget {
  const _PendingByType({required this.pending});

  final Map<String, int> pending;

  @override
  Widget build(BuildContext context) {
    final entries = pending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          for (final entry in entries)
            _Row(
              label: syncEntityLabel(entry.key, count: entry.value),
              value: '${entry.value}',
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(8, 0, 18, 22),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            tooltip: 'Volver',
          ),
          Expanded(
            child: Text(
              'Sincronización',
              style: AppTypography.h3.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
          if (status.lastSyncedAt != null)
            Text(
              relativeAge(status.lastSyncedAt!),
              style: AppTypography.bodySm.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary100,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.engine});

  final SyncStatus status;
  final SyncEngineState engine;

  @override
  Widget build(BuildContext context) {
    final (icon, tone, headline, detail) = switch (status.state) {
      SyncState.synced => (
        Icons.check_circle_rounded,
        AppStatusTone.success,
        'Todo sincronizado',
        'No hay capturas esperando subir.',
      ),
      SyncState.syncing => (
        Icons.sync_rounded,
        AppStatusTone.info,
        'Sincronizando…',
        'Subiendo lo capturado y bajando los cambios del servidor.',
      ),
      SyncState.pending => (
        Icons.schedule_rounded,
        AppStatusTone.warning,
        '${status.pendingCount} esperando subir',
        'Se suben solas al recuperar conexión. Nada se pierde mientras tanto.',
      ),
      // El mensaje del fallo va tal cual y no traducido a "revisá tu red": el
      // motor ya distingue no alcanzar al servidor de que el servidor no
      // conteste, y aplanar las dos cosas manda a revisar el wifi a quien tiene
      // el wifi perfecto.
      SyncState.failed => (
        Icons.cloud_off_rounded,
        AppStatusTone.error,
        'La última sincronización falló',
        status.failureMessage ?? 'El ciclo no pudo terminar.',
      ),
      SyncState.needsReview => (
        Icons.error_outline_rounded,
        AppStatusTone.error,
        '${status.reviewCount} necesitan revisión',
        'El servidor no pudo aplicarlas. Requieren una decisión.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  headline,
                  style: AppTypography.h3.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              AppStatusBadge(
                label: switch (status.state) {
                  SyncState.synced => 'Al día',
                  SyncState.syncing => 'En curso',
                  SyncState.pending => 'Pendiente',
                  SyncState.failed => 'Falló',
                  SyncState.needsReview => 'Revisar',
                },
                tone: tone,
                size: AppStatusBadgeSize.sm,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          if (engine.nextAttemptAt != null) ...[
            const SizedBox(height: 10),
            Text(
              'Siguiente intento ${_relativeFuture(engine.nextAttemptAt!)} '
              '(${engine.consecutiveFailures} ${engine.consecutiveFailures == 1 ? 'intento fallido' : 'intentos fallidos'}).',
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                color: AppColors.warningText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Diagnostics extends StatelessWidget {
  const _Diagnostics({required this.details, required this.engine});

  final SyncDetails? details;
  final SyncEngineState engine;

  @override
  Widget build(BuildContext context) {
    final data = details;
    if (data == null) {
      return const AppEmptyState(
        icon: Icons.sync_rounded,
        title: 'Sin datos todavía',
        message: 'El motor aún no ha completado un ciclo en este dispositivo.',
      );
    }

    final skew = data.clockSkew;
    final skewIsOff = skew != null && skew.abs() > kClockSkewWarnThreshold;

    return Column(
      children: [
        _Row(
          label: 'Dispositivo',
          value: data.deviceId == null ? 'Sin registrar' : _shortId(data.deviceId!),
        ),
        _Row(
          label: 'Descarga inicial',
          value: data.bootstrapCompleted ? 'Completa' : 'Pendiente',
        ),
        _Row(label: 'Cursor del feed', value: '${data.pullCursor}'),
        _Row(
          label: 'Último ciclo',
          value: data.lastCycleAt == null ? 'Nunca' : relativeAge(data.lastCycleAt!),
        ),
        if (skew != null)
          _Row(
            label: 'Reloj del equipo',
            value: skewIsOff
                ? 'Desfasado ${skew.abs().inMinutes} min — revisá la hora'
                : 'En hora',
            tone: skewIsOff ? AppColors.errorText : null,
          ),
        if (data.lastError != null)
          _Row(label: 'Último error', value: data.lastError!, tone: AppColors.errorText),
      ],
    );
  }

  static String _shortId(String id) => id.length <= 8 ? id : '${id.substring(0, 8)}…';
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.tone});

  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: tone ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeFuture(DateTime moment) {
  final remaining = moment.difference(DateTime.now());
  if (remaining.isNegative) return 'en breve';
  if (remaining.inSeconds < 60) return 'en ${remaining.inSeconds} s';
  return 'en ${remaining.inMinutes} min';
}
