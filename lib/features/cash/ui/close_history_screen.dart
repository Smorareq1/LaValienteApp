import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/day_close.dart';
import '../state/day_close_controller.dart';
import 'day_close_screen.dart';

/// Histórico de cierres (Plan 0006 §7.5): los días ya firmados, por fecha.
///
/// Va contra la API como el cierre y por lo mismo: el espejo local solo tiene
/// las actas que el feed alcanzó a bajar, y esta pantalla se abre justamente
/// para buscar un día viejo. Un mes hacia atrás por omisión, igual que el
/// backend.
class CloseHistoryScreen extends ConsumerWidget {
  const CloseHistoryScreen({super.key});

  static const String path = '/cash/history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(closeHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(count: history.valueOrNull?.length),
          Expanded(
            child: switch (history) {
              AsyncData(:final value) => _HistoryList(records: value),
              AsyncError() => _LoadError(
                onRetry: () => ref.invalidate(closeHistoryProvider),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(6, 0, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            tooltip: 'Volver',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == null
                      ? ''
                      : '$count ${count == 1 ? 'acta' : 'actas'} · último mes',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Cierres de días pasados',
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

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.records});

  final List<DayClosureRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.event_note_outlined,
            title: 'Todavía no hay días cerrados',
            message:
                'El acta de cada día aparece aquí en cuanto alguien cierra la '
                'caja desde la pantalla de Caja.',
          ),
        ),
      );
    }

    final today = businessDate();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) =>
          _ClosureCard(record: records[index], today: today),
    );
  }
}

class _ClosureCard extends StatelessWidget {
  const _ClosureCard({required this.record, required this.today});

  final DayClosureRecord record;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final day = parseIsoDate(record.closeDate);
    final at = record.closedAt.toLocal();
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

    return AppListCard(
      title: day == null ? record.closeDate : formatBusinessDate(day, today: today),
      subtitle: [
        'Ingresos Q${Fixed2.format(record.incomeTotal)}',
        'Gastos Q${Fixed2.format(record.expensesTotal)}',
        'cerrado $time',
      ].join(' · '),
      // Una fecha con acta reabierta se sigue abriendo: la pantalla del cierre
      // muestra el día como está hoy, que es lo que alguien viene a ver.
      onTap: () => context.push('${DayCloseScreen.path}?date=${record.closeDate}'),
      leading: AppListCardTile(
        icon: record.isReopened ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
        background: record.isReopened ? AppColors.warningBg : AppColors.successBg,
        foreground: record.isReopened ? AppColors.warningText : AppColors.successText,
      ),
      titleSuffix: record.isReopened
          ? const Icon(
              Icons.history_rounded,
              size: 13,
              color: AppColors.warningText,
            )
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(Fixed2.toDouble(record.netTotal), size: AppMoneySize.md),
          const SizedBox(height: 3),
          if (record.isReopened)
            const AppStatusBadge(
              label: 'Reabierto',
              tone: AppStatusTone.warning,
              size: AppStatusBadgeSize.sm,
            )
          else
            Text('neto', style: AppTypography.helper.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'No se pudo cargar el histórico',
              message:
                  'Las actas viven en el servidor: esta pantalla necesita '
                  'conexión para buscarlas.',
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Reintentar',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
