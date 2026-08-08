import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../domain/close_warnings.dart';
import '../models/day_close.dart';
import '../state/day_close_controller.dart';
import 'widgets/reopen_day_sheet.dart';

/// Cierre del día (Plan 0006 §7.4): la pantalla-acta.
///
/// Es **online-only** y es la única pantalla de dinero que lo es. El acta
/// declara cuánto valió un día entero de la lavandería, y este dispositivo solo
/// conoce lo que pasó por sus manos: firmar con eso archivaría una cifra a la
/// que le falta lo que cobró la otra tableta. Por eso sin red no se cierra y se
/// dice (plan 0005 D11, plan 0006 §14).
///
/// Un día ya cerrado abre la misma pantalla en modo acta —solo lectura— con
/// **Reabrir** para quien tenga `daily_close.reopen`.
class DayCloseScreen extends ConsumerStatefulWidget {
  const DayCloseScreen({super.key, this.date});

  static const String path = '/cash/close';

  /// `YYYY-MM-DD`. Sin ella, el día de negocio de hoy, que es el que alguien
  /// quiere cerrar al terminar el turno.
  final String? date;

  @override
  ConsumerState<DayCloseScreen> createState() => _DayCloseScreenState();
}

class _DayCloseScreenState extends ConsumerState<DayCloseScreen> {
  final TextEditingController _notes = TextEditingController();
  bool _busy = false;

  late final String _date = widget.date ?? isoDate(businessDate());

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheet = ref.watch(dayCloseControllerProvider(_date));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(date: _date, sheet: sheet.valueOrNull),
          Expanded(
            child: switch (sheet) {
              AsyncData(:final value) => _Acta(
                date: _date,
                sheet: value,
                notes: _notes,
                busy: _busy,
                onClose: () => _close(value),
                onReopen: () => _reopen(value),
              ),
              AsyncError() => _OfflineState(
                onRetry: () => ref.invalidate(dayCloseControllerProvider(_date)),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }

  /// Cerrar pide confirmación porque bloquea la fecha, y el diálogo dice qué
  /// pasa después en vez de preguntar "¿estás seguro?".
  Future<void> _close(DayCloseSheet sheet) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      icon: Icons.lock_outline_rounded,
      title: 'Cerrar el día',
      message:
          'La fecha queda bloqueada: no se podrán anotar gastos, cobros ni '
          'ventas de ese día sin reabrirla. El neto se archiva en '
          'Q${Fixed2.format(sheet.preview.netTotal)}.',
      confirmLabel: 'Cerrar día',
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    final result = await ref
        .read(dayCloseControllerProvider(_date).notifier)
        .close(notes: _notes.text);
    if (!mounted) return;
    setState(() => _busy = false);

    result.match(
      (failure) => _say(failure.message),
      (record) {
        _notes.clear();
        _say('Día cerrado en Q${Fixed2.format(record.netTotal)}');
      },
    );
  }

  Future<void> _reopen(DayCloseSheet sheet) async {
    final reason = await ReopenDaySheet.show(context);
    if (reason == null || !mounted) return;

    setState(() => _busy = true);
    final result = await ref
        .read(dayCloseControllerProvider(_date).notifier)
        .reopen(reason: reason);
    if (!mounted) return;
    setState(() => _busy = false);

    result.match(
      (failure) => _say(failure.message),
      (_) => _say('Día reabierto: hay que volver a cerrarlo'),
    );
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date, this.sheet});

  final String date;
  final DayCloseSheet? sheet;

  @override
  Widget build(BuildContext context) {
    final day = parseIsoDate(date);
    final closed = sheet?.isClosed ?? false;

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
                  day == null
                      ? date
                      : formatBusinessDate(day, today: businessDate()),
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  closed ? 'Acta del día' : 'Cierre del día',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          if (closed)
            const Icon(Icons.lock_rounded, size: 19, color: AppColors.white),
        ],
      ),
    );
  }
}

/// El acta: totales, arqueo, advertencias y notas.
class _Acta extends StatelessWidget {
  const _Acta({
    required this.date,
    required this.sheet,
    required this.notes,
    required this.busy,
    required this.onClose,
    required this.onReopen,
  });

  final String date;
  final DayCloseSheet sheet;
  final TextEditingController notes;
  final bool busy;
  final VoidCallback onClose;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final figures = sheet.closure ?? sheet.preview;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (sheet.closure != null) ...[
          _ClosedNote(closure: sheet.closure!),
          const SizedBox(height: 14),
        ],
        const AppSectionHeader(title: 'Totales del día'),
        _Totals(figures: figures),
        const SizedBox(height: 20),
        const AppSectionHeader(
          title: 'Arqueo',
          accentColor: AppColors.secondary500,
        ),
        _Arqueo(figures: figures),
        if (sheet.warnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          const AppSectionHeader(title: 'Antes de firmar'),
          for (final warning in sheet.warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WarningRow(warning: warning),
            ),
        ],
        const SizedBox(height: 20),
        if (sheet.isClosed)
          _FiledNotes(notes: sheet.closure?.notes)
        else
          AppFormField(
            label: 'Notas del cierre',
            optional: true,
            hintText: 'Lo que haya que dejar dicho de este día',
            maxLines: 3,
            controller: notes,
          ),
        const SizedBox(height: 20),
        if (sheet.isClosed)
          PermissionGate(
            anyOf: const [AppPermissions.dailyCloseReopen],
            child: AppButton(
              label: 'Reabrir el día',
              icon: const Icon(Icons.lock_open_rounded),
              variant: AppButtonVariant.outline,
              fullWidth: true,
              loading: busy,
              onPressed: busy ? null : onReopen,
            ),
          )
        else
          PermissionGate(
            anyOf: const [AppPermissions.dailyCloseClose],
            // Sin permiso de cerrar la pantalla sigue sirviendo: es la hoja del
            // día en cifras, y leerla es de quien tenga `daily_close.read`.
            fallback: const _ReadOnlyNote(),
            child: AppButton(
              label: 'Cerrar día',
              icon: const Icon(Icons.lock_outline_rounded),
              fullWidth: true,
              elevated: true,
              size: AppButtonSize.lg,
              loading: busy,
              onPressed: busy ? null : onClose,
            ),
          ),
      ],
    );
  }
}

/// Las cinco cifras del §6.1 del plan 0005, en el orden en que la hoja las suma.
class _Totals extends StatelessWidget {
  const _Totals({required this.figures});

  final DayFigures figures;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _Line(
            label: 'Ingresos por pedidos',
            amount: figures.ordersIncome,
            caption: figures.ordersDelivered == 1
                ? '1 pedido entregado'
                : '${figures.ordersDelivered} pedidos entregados',
          ),
          _Line(label: 'Ingresos por insumos', amount: figures.suppliesIncome),
          const Divider(height: 20, color: AppColors.border),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppStatTile(
                    label: 'Ingresos',
                    amount: Fixed2.toDouble(figures.incomeTotal),
                    tone: AppStatTone.positive,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: AppStatTile(
                    label: 'Gastos',
                    amount: Fixed2.toDouble(figures.expensesTotal),
                    tone: AppStatTone.negative,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppStatTile(
            label: 'NETO DEL DÍA',
            amount: Fixed2.toDouble(figures.netTotal),
            tone: AppStatTone.brand,
          ),
        ],
      ),
    );
  }
}

/// Efectivo contra transferencia, que es lo único con lo que se puede cuadrar un
/// cajón físico: una transferencia no está en ningún cajón.
class _Arqueo extends StatelessWidget {
  const _Arqueo({required this.figures});

  final DayFigures figures;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _Line(label: 'Entró en efectivo', amount: figures.cashIncome),
          _Line(label: 'Salió en efectivo', amount: -figures.cashExpenses),
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debería haber en el cajón',
                      style: AppTypography.helper.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppMoneyText(
                      Fixed2.toDouble(figures.cashOnHand),
                      size: AppMoneySize.lg,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 22,
                color: AppColors.gray400,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Line(label: 'Entró por transferencia', amount: figures.transferIncome),
          _Line(
            label: 'Salió por transferencia',
            amount: -figures.transferExpenses,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.amount, this.caption});

  final String label;
  final int amount;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (caption != null)
                  Text(
                    caption!,
                    style: AppTypography.helper.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          AppMoneyText(Fixed2.toDouble(amount), size: AppMoneySize.sm),
        ],
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.warning});

  final CloseWarning warning;

  @override
  Widget build(BuildContext context) {
    final serious = warning.tone == CloseWarningTone.serious;
    final background = serious ? AppColors.errorBg : AppColors.warningBg;
    final foreground = serious ? AppColors.errorText : AppColors.warningText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            serious ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              warning.message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12.5,
                height: 1.35,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quién firmó y cuándo. Es la primera pregunta de un día ya cerrado.
class _ClosedNote extends StatelessWidget {
  const _ClosedNote({required this.closure});

  final DayClosureRecord closure;

  @override
  Widget build(BuildContext context) {
    final at = closure.closedAt.toLocal();
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.gray600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cerrado a las $time',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Las cifras de abajo son las que quedaron archivadas, no un '
                  'recálculo de hoy.',
                  style: AppTypography.helper.copyWith(fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiledNotes extends StatelessWidget {
  const _FiledNotes({this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes!.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(title: 'Notas del cierre'),
        _Card(
          child: Text(
            notes!,
            style: AppTypography.bodySm.copyWith(fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Lo que ve quien puede leer el día pero no firmarlo (§13).
class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Cerrar el día es cosa de un administrador. Esta es la hoja del día en '
      'cifras, para cuadrar el cajón.',
      textAlign: TextAlign.center,
      style: AppTypography.helper.copyWith(fontSize: 12, height: 1.4),
    );
  }
}

/// Sin red no hay acta: es la única pantalla de dinero que no se puede resolver
/// con el espejo local, y decirlo es mejor que mostrar cifras a medias.
class _OfflineState extends StatelessWidget {
  const _OfflineState({required this.onRetry});

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
              title: 'El cierre necesita conexión',
              message:
                  'El acta suma lo que cobraron todos los dispositivos, y este '
                  'solo conoce lo suyo. La Caja sigue funcionando sin señal.',
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

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
