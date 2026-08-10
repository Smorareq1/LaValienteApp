import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/fixed2.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../domain/overtime.dart';
import '../models/staff.dart';
import '../state/staff_admin_controller.dart';
import 'widgets/rate_form_sheet.dart';
import 'widgets/shift_form_sheet.dart';

/// Turnos y tarifas (Plan 0006 §9.3).
///
/// Las dos cosas que hacen que la hora extra signifique algo: el turno define
/// cuánto se esperaba trabajar y la tarifa cuánto vale pasarse. **En línea**,
/// como toda la administración (plan 0005 D11).
class StaffSettingsScreen extends ConsumerWidget {
  const StaffSettingsScreen({super.key});

  static const String path = '/staff/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shifts = ref.watch(shiftsAdminControllerProvider);
    final rates = ref.watch(overtimeRatesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _ShiftsSection(shifts: shifts, ref: ref),
                const SizedBox(height: 22),
                _RatesSection(rates: rates, ref: ref),
              ],
            ),
          ),
        ],
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Con qué se mide la hora extra',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Turnos y tarifas',
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

class _ShiftsSection extends StatelessWidget {
  const _ShiftsSection({required this.shifts, required this.ref});

  final AsyncValue<List<WorkShift>> shifts;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: AppSectionHeader(title: 'Turnos')),
            AppButton(
              label: 'Nuevo',
              size: AppButtonSize.sm,
              variant: AppButtonVariant.secondary,
              icon: const Icon(Icons.add_rounded, size: 16),
              onPressed: () => ShiftFormSheet.show(context),
            ),
          ],
        ),
        const SizedBox(height: 9),
        switch (shifts) {
          AsyncData(value: final list) when list.isEmpty => const _Nothing(
            message:
                'No hay turnos. Sin turno una jornada se registra igual, pero '
                'nadie puede decir que alguien se pasó de la hora.',
          ),
          AsyncData(value: final list) => Column(
            children: [
              for (final shift in list) ...[
                _ShiftRow(shift: shift),
                const SizedBox(height: 7),
              ],
            ],
          ),
          AsyncError(:final error) => _Failed(
            message: '$error',
            onRetry: () => ref.invalidate(shiftsAdminControllerProvider),
          ),
          _ => const _Loading(),
        },
      ],
    );
  }
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({required this.shift});

  final WorkShift shift;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: shift.name,
      subtitle: '${shift.scheduleLabel} · ${formatMinutes(shift.durationMinutes)}',
      leading: AppListCardTile(
        icon: Icons.schedule_rounded,
        background: shift.isActive ? AppColors.primary50 : AppColors.gray100,
        foreground: shift.isActive ? AppColors.primary700 : AppColors.gray400,
      ),
      titleSuffix: shift.isActive
          ? null
          : const AppStatusBadge(
              label: 'Fuera de uso',
              tone: AppStatusTone.neutral,
              size: AppStatusBadgeSize.sm,
            ),
      onTap: () => ShiftFormSheet.show(context, shift: shift),
    );
  }
}

class _RatesSection extends StatelessWidget {
  const _RatesSection({required this.rates, required this.ref});

  final AsyncValue<List<PayrollRate>> rates;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: AppSectionHeader(title: 'Tarifa de hora extra')),
            AppButton(
              label: 'Nueva',
              size: AppButtonSize.sm,
              variant: AppButtonVariant.secondary,
              icon: const Icon(Icons.add_rounded, size: 16),
              onPressed: () => RateFormSheet.show(
                context,
                current: rates.valueOrNull?.where((rate) => rate.isCurrent).firstOrNull,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        switch (rates) {
          AsyncData(value: final list) when list.isEmpty => const _Nothing(
            message:
                'No hay tarifa. Sin ella la hora extra se puede confirmar pero no '
                'valuar, y la pantalla de asistencia lo dice en vez de poner Q0.00.',
          ),
          AsyncData(value: final list) => Column(
            children: [
              for (final rate in list) ...[
                _RateRow(rate: rate),
                const SizedBox(height: 7),
              ],
            ],
          ),
          AsyncError(:final error) => _Failed(
            message: '$error',
            onRetry: () => ref.invalidate(overtimeRatesControllerProvider),
          ),
          _ => const _Loading(),
        },
      ],
    );
  }
}

/// Una ventana de la tarifa. La vigente va destacada y el resto es historial:
/// se conserva porque una jornada de marzo se valúa con la tarifa de marzo.
class _RateRow extends StatelessWidget {
  const _RateRow({required this.rate});

  final PayrollRate rate;

  @override
  Widget build(BuildContext context) {
    final current = rate.isCurrent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: current ? AppColors.primary50 : AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: current ? AppColors.primary500 : AppColors.border,
          width: current ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${Fixed2.format(rate.amount)} la hora',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: current ? AppColors.primary700 : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rate.validTo == null
                      ? 'Desde el ${rate.validFrom}'
                      : 'Del ${rate.validFrom} al ${rate.validTo}',
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (current)
            const AppStatusBadge(
              label: 'Vigente',
              tone: AppStatusTone.success,
              size: AppStatusBadgeSize.sm,
            ),
        ],
      ),
    );
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing({required this.message});

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

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Reintentar',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
