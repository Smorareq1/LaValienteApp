import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/fixed2.dart';
import '../../cash/data/expenses_repository.dart';
import '../../cash/models/expense.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../../staff/data/attendance_repository.dart';
import '../../staff/models/staff.dart';
import '../domain/cash_sheet_warnings.dart';
import '../domain/scan_warnings.dart';
import '../models/cash_sheet.dart';
import '../state/cash_sheet_controller.dart';
import '../state/shared_images_controller.dart';
import '../state/ticket_photo_picker.dart';
import 'widgets/cash_income_tile.dart';
import 'widgets/scan_reading_view.dart';
import 'widgets/shared_queue_note.dart';

/// Importar la hoja «Registro Diario» desde una foto (plan 0005 §1).
///
/// Es la pantalla que más consecuencias tiene de toda la app y por eso se lee
/// como se lee: **una lista de filas con casilla**, no un botón de «importar».
/// Lo que se marca se cobra y se entrega; lo que no se marca no pasa nada. Y lo
/// que el servidor no pudo cuadrar llega desmarcado y arriba, porque es lo único
/// que necesita una decisión.
///
/// Nada aquí es automático, ni siquiera lo que cuadra perfecto: llega marcado,
/// pero el botón de abajo dice cuánto se va a cobrar antes de tocarlo.
class CashSheetScanScreen extends ConsumerWidget {
  const CashSheetScanScreen({super.key});

  static const String path = '/cash/scan';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashSheetControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: switch (state) {
              CashSheetIdle() => const _Guide(),
              CashSheetSending(:final image) => ScanReadingView(
                image: image,
                title: 'Leyendo la hoja del día',
                steps: ScanReadingView.cashSteps,
              ),
              CashSheetFailed(:final failure) => _Failed(message: failure.message),
              CashSheetReview() => _Review(review: state),
              CashSheetApplied(:final result) => _Applied(result: result),
            },
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
                  'Necesita señal',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Importar hoja del día',
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

class _Guide extends ConsumerWidget {
  const _Guide();

  Future<void> _pick(BuildContext context, WidgetRef ref, AppImageSource source) async {
    final bytes = await ref.read(ticketPhotoPickerProvider).pick(source);
    if (bytes == null || !context.mounted) return;
    await ref.read(cashSheetControllerProvider.notifier).send(bytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      children: [
        const SharedQueueNote(),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.table_chart_outlined,
                size: 54,
                color: AppColors.primary500,
              ),
              const SizedBox(height: 12),
              Text(
                'Fotografía la hoja completa',
                style: AppTypography.h3.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Se leen las boletas cobradas, los gastos y las horas. Vos '
                'revisás fila por fila y decidís qué entra: nada se cobra solo.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _Tips(),
        const SizedBox(height: 18),
        AppButton(
          label: 'Tomar la foto',
          fullWidth: true,
          icon: const Icon(Icons.photo_camera_rounded, size: 18),
          onPressed: () => _pick(context, ref, AppImageSource.camera),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Elegir de la galería',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          icon: const Icon(Icons.photo_library_outlined, size: 18),
          onPressed: () => _pick(context, ref, AppImageSource.gallery),
        ),
      ],
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  static const _tips = [
    (Icons.crop_free_rounded, 'La hoja entera, con los tres bloques a la vista.'),
    (Icons.wb_sunny_outlined, 'Sin sombra del clip ni de la mano encima.'),
    (Icons.format_color_fill_rounded, 'Los resaltados importan: rosado es transferencia.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        children: [
          for (final (icon, text) in _tips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(icon, size: 17, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
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

class _Failed extends ConsumerWidget {
  const _Failed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.errorBg,
            borderRadius: AppRadius.mdAll,
          ),
          child: Text(
            message,
            style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
          ),
        ),
        const SizedBox(height: 14),
        AppButton(
          label: 'Reintentar',
          fullWidth: true,
          onPressed: () => ref.read(cashSheetControllerProvider.notifier).retry(),
        ),
        const SizedBox(height: 9),
        AppButton(
          label: 'Otra foto',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          onPressed: () {
            ref.read(sharedImagesControllerProvider.notifier).done();
            ref.read(cashSheetControllerProvider.notifier).reset();
          },
        ),
        const SizedBox(height: 14),
        Text(
          'La caja se sigue llevando a mano igual que siempre: esto es un '
          'atajo, no el único camino.',
          style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// La hoja leída, fila por fila, editable.
class _Review extends ConsumerWidget {
  const _Review({required this.review});

  final CashSheetReview review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = review.day;
    final warnings = cashSheetWarnings([
      ...review.result.warnings,
      ...day.warnings,
    ]);
    final blocked = review.result.isAlreadyApplied;
    final categories = ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];
    final employees = ref.watch(scanEmployeesProvider).valueOrNull ?? const [];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              if (review.result.days.length > 1)
                _DayPicker(review: review),
              if (warnings.isNotEmpty) ...[
                _Warnings(warnings: warnings),
                const SizedBox(height: 14),
              ],
              _SectionTitle(
                title: 'Boletas cobradas',
                count: '${review.selectedIncomes} de ${day.incomes.length}',
                action: day.incomes.isEmpty
                    ? null
                    : TextButton(
                        onPressed: () => ref
                            .read(cashSheetControllerProvider.notifier)
                            .toggleAllIncomes(
                              selected: review.selectedIncomes == 0,
                            ),
                        child: Text(
                          review.selectedIncomes == 0
                              ? 'Marcar las que cuadran'
                              : 'Desmarcar todas',
                        ),
                      ),
              ),
              if (day.incomes.isEmpty)
                const _Nothing('No se leyó ninguna boleta cobrada en este día.')
              else
                for (final row in day.incomes)
                  CashIncomeTile(
                    row: row,
                    edit: review.incomes[row.index]!,
                    enabled: !blocked,
                    onChanged: (edit) => ref
                        .read(cashSheetControllerProvider.notifier)
                        .updateIncome(row.index, edit),
                  ),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Gastos',
                count: '${review.selectedExpenses} de ${day.expenses.length}',
              ),
              if (day.expenses.isEmpty)
                const _Nothing('No se leyó ningún gasto en este día.')
              else
                for (final row in day.expenses)
                  _ExpenseTile(
                    row: row,
                    edit: review.expenses[row.index]!,
                    categories: categories,
                    enabled: !blocked,
                    onChanged: (edit) => ref
                        .read(cashSheetControllerProvider.notifier)
                        .updateExpense(row.index, edit),
                  ),
              if (day.attendance.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Horas del personal',
                  count: '${review.selectedAttendance} de ${day.attendance.length}',
                ),
                for (final row in day.attendance)
                  _AttendanceTile(
                    row: row,
                    edit: review.attendance[row.index]!,
                    employees: employees,
                    enabled: !blocked,
                    onChanged: (edit) => ref
                        .read(cashSheetControllerProvider.notifier)
                        .updateAttendance(row.index, edit),
                  ),
              ],
              const SizedBox(height: 18),
              _PaperTotals(day: day),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: AppRadius.lgAll,
                child: Image.memory(review.image, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
        _ApplyBar(review: review, blocked: blocked),
      ],
    );
  }
}

/// Qué día de la hoja se está revisando.
class _DayPicker extends ConsumerWidget {
  const _DayPicker({required this.review});

  final CashSheetReview review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La foto trae ${review.result.days.length} días. Se importa uno por uno.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppSegmented<int>(
            value: review.dayIndex,
            options: [
              for (var index = 0; index < review.result.days.length; index++)
                AppSegmentedOption(
                  value: index,
                  label: review.result.days[index].closeDate.value ?? 'Sin fecha',
                ),
            ],
            onChanged: (index) =>
                ref.read(cashSheetControllerProvider.notifier).selectDay(index),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count, this.action});

  final String title;
  final String count;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          AppStatusBadge(
            label: count,
            tone: AppStatusTone.neutral,
            size: AppStatusBadgeSize.sm,
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        message,
        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _Warnings extends StatelessWidget {
  const _Warnings({required this.warnings});

  final List<ScanWarning> warnings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final warning in warnings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: warning.tone == ScanWarningTone.serious
                    ? AppColors.errorBg
                    : AppColors.warningBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    warning.tone == ScanWarningTone.serious
                        ? Icons.report_problem_rounded
                        : Icons.info_outline_rounded,
                    size: 17,
                    color: warning.tone == ScanWarningTone.serious
                        ? AppColors.errorText
                        : AppColors.warningText,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      warning.message,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13,
                        color: warning.tone == ScanWarningTone.serious
                            ? AppColors.errorText
                            : AppColors.warningText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Lo que dicen las sumas escritas en el papel, para cuadrar a ojo.
class _PaperTotals extends StatelessWidget {
  const _PaperTotals({required this.day});

  final CashSheetDay day;

  @override
  Widget build(BuildContext context) {
    if (day.incomeTotalRead == null && day.accumulatedRead == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lo que dice el papel',
            style: AppTypography.bodySm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (day.incomeTotalRead case final int total)
            _TotalRow(label: 'Ingresos', amount: total),
          if (day.expensesTotalRead case final int total)
            _TotalRow(label: 'Gastos', amount: total),
          if (day.accumulatedRead case final int total)
            _TotalRow(label: 'Total acumulado', amount: total, strong: true),
          const SizedBox(height: 6),
          Text(
            'Solo para cuadrar: lo que se cobra son las filas marcadas arriba.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.strong = false,
  });

  final String label;
  final int amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: strong ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            'Q${Fixed2.format(amount)}',
            style: AppTypography.money(fontSize: strong ? 16 : 14),
          ),
        ],
      ),
    );
  }
}

/// La barra de abajo: cuánto se va a cobrar, y el botón que lo hace.
class _ApplyBar extends ConsumerWidget {
  const _ApplyBar({required this.review, required this.blocked});

  final CashSheetReview review;
  final bool blocked;

  Future<void> _apply(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '¿Importar el día?',
      message:
          'Se van a cobrar Q${Fixed2.format(review.collectedTotal)} en '
          '${review.selectedIncomes} boletas y a registrar '
          '${review.selectedExpenses} gastos. Esto mueve dinero de verdad.',
      confirmLabel: 'Sí, importar',
      icon: Icons.playlist_add_check_rounded,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(cashSheetControllerProvider.notifier).apply();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (review.failure case final failure?) ...[
            Text(
              failure.message,
              style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Se va a cobrar',
                      style: AppTypography.helper.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Q${Fixed2.format(review.collectedTotal)}',
                      style: AppTypography.money(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: blocked ? 'Ya se importó' : 'Importar el día',
                  loading: review.applying,
                  onPressed: blocked || !review.hasSomethingToApply
                      ? null
                      : () => _apply(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lo que entró y lo que no.
class _Applied extends ConsumerWidget {
  const _Applied({required this.result});

  final CashSheetApplyResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failures = result.failures;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(
                failures.isEmpty
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                size: 46,
                color: failures.isEmpty
                    ? AppColors.successText
                    : AppColors.warningText,
              ),
              const SizedBox(height: 12),
              Text(
                'Día ${result.closeDate} importado',
                style: AppTypography.h3.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _TotalRow(
                label: '${result.paymentsApplied} cobros',
                amount: result.collectedTotal,
                strong: true,
              ),
              _TotalRow(
                label: '${result.expensesCreated} gastos',
                amount: result.expensesTotal,
              ),
              if (result.ordersDelivered > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${result.ordersDelivered} boletas quedaron entregadas.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              if (result.attendanceCreated > 0)
                Text(
                  '${result.attendanceCreated} jornadas registradas.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (failures.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Estas filas no entraron',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lo demás ya quedó registrado. Estas hay que hacerlas a mano.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          for (final row in failures)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Text(
                  'Fila ${row.index + 1}: ${row.reason ?? "no se pudo aplicar"}',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    color: AppColors.errorText,
                  ),
                ),
              ),
            ),
        ],
        const SizedBox(height: 18),
        AppButton(
          label: 'Listo',
          fullWidth: true,
          onPressed: () {
            ref.read(sharedImagesControllerProvider.notifier).done();
            ref.read(cashSheetControllerProvider.notifier).reset();
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}

/// Un gasto de la hoja, editable.
class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.row,
    required this.edit,
    required this.categories,
    required this.enabled,
    required this.onChanged,
  });

  final CashExpenseRow row;
  final ExpenseEdit edit;
  final List<ExpenseCategory> categories;
  final bool enabled;
  final ValueChanged<ExpenseEdit> onChanged;

  @override
  Widget build(BuildContext context) {
    final missingCategory = edit.categoryId == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: missingCategory ? AppColors.warning : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: edit.selected,
                onChanged: !enabled || !edit.isComplete
                    ? null
                    : (value) => onChanged(edit.copyWith(selected: value)),
              ),
              Expanded(
                child: Text(
                  edit.concept.isEmpty ? 'Sin descripción' : edit.concept,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Q${Fixed2.format(edit.amount)}',
                style: AppTypography.money(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: edit.categoryId,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
              hintText: 'Elegí la categoría',
            ),
            items: [
              for (final category in categories)
                DropdownMenuItem(value: category.id, child: Text(category.name)),
            ],
            onChanged: !enabled
                ? null
                : (value) => onChanged(edit.copyWith(categoryId: value)),
          ),
          if (row.matchedOn == 'keyword' && !missingCategory)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'La categoría la dedujo el sistema por la palabra escrita. '
                'Revisala.',
                style: AppTypography.helper.copyWith(
                  color: AppColors.warningText,
                ),
              ),
            ),
          if (edit.status == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Queda como pendiente: la hoja dice que todavía no se pagó.',
                style: AppTypography.helper.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (row.employeeName case final name?)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Se paga a $name.',
                style: AppTypography.helper.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Una jornada de la hoja.
class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({
    required this.row,
    required this.edit,
    required this.employees,
    required this.enabled,
    required this.onChanged,
  });

  final CashAttendanceRow row;
  final AttendanceEdit edit;
  final List<Employee> employees;
  final bool enabled;
  final ValueChanged<AttendanceEdit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: edit.selected,
                onChanged: !enabled || !edit.isComplete
                    ? null
                    : (value) => onChanged(edit.copyWith(selected: value)),
              ),
              Expanded(
                child: Text(
                  '${edit.clockIn.isEmpty ? "—" : edit.clockIn} a '
                  '${edit.clockOut ?? "—"}',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (row.clockOut.needsReview)
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: AppColors.warningText,
                ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: edit.employeeId,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
              hintText: row.employeeText.value == null
                  ? '¿De quién son estas horas?'
                  : '¿«${row.employeeText.value}» es…?',
            ),
            items: [
              for (final employee in employees)
                DropdownMenuItem(value: employee.id, child: Text(employee.fullName)),
            ],
            onChanged: !enabled
                ? null
                : (value) => onChanged(edit.copyWith(employeeId: value)),
          ),
          if (row.clockOut.needsReview)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'La salida estaba escrita como mañana y se leyó como tarde. '
                'Comprobala.',
                style: AppTypography.helper.copyWith(
                  color: AppColors.warningText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Las categorías de gasto que el dispositivo tiene espejadas.
final expenseCategoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(expensesRepositoryProvider).watchCategories();
});

/// Los empleados activos, para asignar horas y horas extra.
final scanEmployeesProvider = StreamProvider<List<Employee>>((ref) {
  return ref.watch(attendanceRepositoryProvider).watchEmployees();
});
