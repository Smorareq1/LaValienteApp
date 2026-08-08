import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../../../core/time/business_date.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../data/expenses_repository.dart';
import '../domain/cash_day.dart';
import '../models/cash_entry.dart';
import '../models/expense.dart';
import '../state/cash_day_controller.dart';
import 'supply_sale_screen.dart';
import 'widgets/expense_sheet.dart';

/// Caja del día (Plan 0006 §7.1): la hoja de Registro Diario en pantalla.
///
/// Ingresos a un lado y gastos al otro, como el papel que reemplaza. Todo sale
/// de la BD local, así que el día se arma igual sin señal; lo que todavía no
/// subió se marca en su fila en vez de esconderse.
class CashScreen extends ConsumerStatefulWidget {
  const CashScreen({super.key});

  static const String path = '/cash';

  @override
  ConsumerState<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(cashDayProvider);

    return Stack(
      children: [
        Column(
          children: [
            _CashHeader(day: day),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (day.closure != null) ...[
                            _ClosedBanner(closure: day.closure!),
                            const SizedBox(height: 12),
                          ],
                          _DaySummary(day: day),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabsHeader(
                      child: ColoredBox(
                        color: AppColors.background,
                        child: AppTabBar(
                          index: _tab,
                          onChanged: (index) => setState(() => _tab = index),
                          tabs: [
                            AppTab(
                              label: 'Ingresos',
                              count: day.incomes.length,
                              icon: Icons.arrow_upward_rounded,
                            ),
                            AppTab(
                              label: 'Gastos',
                              count: day.expenses.length,
                              icon: Icons.arrow_downward_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_tab == 0)
                    _IncomeList(entries: day.incomes)
                  else
                    _ExpenseList(day: day),
                ],
              ),
            ),
          ],
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: _CashFooter(day: day)),
      ],
    );
  }
}

/// Cabecera: el día, y el efectivo que debería estar en el cajón ahora mismo.
///
/// La cifra grande es el arqueo y no el total cobrado: lo que se compara con el
/// cajón físico es el efectivo que entró menos el que salió, y una transferencia
/// no está en ningún cajón.
class _CashHeader extends ConsumerWidget {
  const _CashHeader({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(cashDateFilterProvider);
    final today = businessDate();

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Caja del día',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              _DayChip(
                date: date,
                today: today,
                onChanged: (value) =>
                    ref.read(cashDateFilterProvider.notifier).update(value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CashOnHandCard(day: day),
        ],
      ),
    );
  }
}

class _CashOnHandCard extends StatelessWidget {
  const _CashOnHandCard({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context) {
    final income = day.income;
    final paid = day.paidExpenses;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 14,
                color: AppColors.primary100,
              ),
              const SizedBox(width: 6),
              Text(
                'Efectivo en caja ahora',
                style: AppTypography.helper.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppMoneyText(
            Fixed2.toDouble(day.cashOnHand),
            size: AppMoneySize.hero,
            color: AppColors.white,
            decimalColor: AppColors.primary100,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x3DFFFFFF)),
          const SizedBox(height: 10),
          Row(
            children: [
              _HeaderFigure(label: 'Entró en efectivo', amount: income.cash),
              _HeaderFigure(label: 'Salió en efectivo', amount: -paid.cash),
              _HeaderFigure(label: 'Por transferencia', amount: income.transfer),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderFigure extends StatelessWidget {
  const _HeaderFigure({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.helper.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary100,
            ),
          ),
          AppMoneyText(
            Fixed2.toDouble(amount),
            size: AppMoneySize.sm,
            color: AppColors.white,
            decimalColor: AppColors.primary100,
            showDecimals: false,
          ),
        ],
      ),
    );
  }
}

/// El candado del §14: la fecha ya se cerró y no admite escrituras.
class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner({required this.closure});

  final DayClosure closure;

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
                  'Día cerrado a las $time',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Solo lectura: para cambiar algo hay que reabrir el día',
                  style: AppTypography.helper.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Las tres cifras del §7.1 y el reparto efectivo/transferencia.
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppStatTile(
                    label: 'Ingresos',
                    amount: Fixed2.toDouble(day.incomeTotal),
                    tone: AppStatTone.positive,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: AppStatTile(
                    label: 'Gastos',
                    amount: Fixed2.toDouble(day.expensesTotal),
                    tone: AppStatTone.negative,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: AppStatTile(
                    label: 'Neto',
                    amount: Fixed2.toDouble(day.netTotal),
                    tone: AppStatTone.brand,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          if (day.pendingExpensesTotal > 0) ...[
            const SizedBox(height: 10),
            _PendingNote(amount: day.pendingExpensesTotal),
          ],
        ],
      ),
    );
  }
}

/// La diferencia entre lo que el día debe y lo que salió del cajón. Es la
/// advertencia del cierre, dicha antes de llegar a él.
class _PendingNote extends StatelessWidget {
  const _PendingNote({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 14, color: AppColors.warningText),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Q${Fixed2.format(amount)} en gastos pendientes: cuentan en el día, '
            'pero todavía no salieron del cajón.',
            style: AppTypography.helper.copyWith(
              fontSize: 11.5,
              color: AppColors.warningText,
            ),
          ),
        ),
      ],
    );
  }
}

/// Mantiene las pestañas pegadas arriba mientras la lista se desplaza: la
/// pregunta "¿estoy viendo ingresos o gastos?" no se puede perder de vista.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  const _TabsHeader({required this.child});

  final Widget child;

  static const double _height = 46;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: _height, child: child);
  }

  @override
  bool shouldRebuild(_TabsHeader oldDelegate) => oldDelegate.child != child;
}

class _IncomeList extends StatelessWidget {
  const _IncomeList({required this.entries});

  final List<CashEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 200),
          child: AppEmptyState(
            icon: Icons.savings_outlined,
            title: 'Todavía no entra nada',
            message: 'Los cobros de pedidos y las ventas de insumo aparecen acá.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
      sliver: SliverList.separated(
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) => _IncomeCard(entry: entries[index]),
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({required this.entry});

  final CashEntry entry;

  @override
  Widget build(BuildContext context) {
    final isSale = entry.kind == CashEntryKind.supplySale;
    final at = entry.at?.toLocal();
    final subtitle = [
      if (at != null)
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}',
      entry.method?.label.toLowerCase() ?? 'método desconocido',
      if (entry.subtitle != null) entry.subtitle!,
    ].join(' · ');

    return AppListCard(
      title: entry.title,
      subtitle: subtitle,
      onTap: entry.route == null ? null : () => context.push(entry.route!),
      leading: AppListCardTile(
        icon: isSale ? Icons.local_mall_outlined : Icons.arrow_upward_rounded,
        background: isSale ? AppColors.secondary100 : AppColors.successBg,
        foreground: isSale ? AppColors.secondary700 : AppColors.successText,
      ),
      titleSuffix: entry.needsReview
          ? const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.errorText)
          : entry.pendingSync
          ? const Icon(Icons.schedule_rounded, size: 13, color: AppColors.warningText)
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(
            Fixed2.toDouble(entry.amount),
            size: AppMoneySize.md,
            color: AppColors.successText,
          ),
          if (isSale) ...[
            const SizedBox(height: 4),
            const AppStatusBadge(
              label: 'Insumo',
              tone: AppStatusTone.info,
              size: AppStatusBadgeSize.sm,
            ),
          ] else if (entry.method == PaymentMethod.transfer) ...[
            const SizedBox(height: 4),
            const AppStatusBadge(
              label: 'Transferencia',
              tone: AppStatusTone.brand,
              size: AppStatusBadgeSize.sm,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (day.expenses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 200),
          child: AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Ningún gasto este día',
            message: 'Lo que salga de la caja se anota con el botón de abajo.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
      sliver: SliverList.separated(
        itemCount: day.expenses.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) => index == day.expenses.length
            ? _ExpensesTotal(amount: day.expensesTotal)
            : _ExpenseCard(expense: day.expenses[index], locked: day.isClosed),
      ),
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({required this.expense, required this.locked});

  final Expense expense;
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = !locked && !expense.isLinked;

    return AppListCard(
      title: expense.concept,
      subtitle: [
        expense.categoryName,
        expense.method?.label.toLowerCase() ?? 'método desconocido',
      ].join(' · '),
      onTap: canEdit ? () => _edit(context, ref) : null,
      leading: AppListCardTile(
        icon: Icons.arrow_downward_rounded,
        background: AppColors.errorBg,
        foreground: AppColors.errorText,
      ),
      titleSuffix: expense.needsReview
          ? const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.errorText)
          : expense.pendingSync
          ? const Icon(Icons.schedule_rounded, size: 13, color: AppColors.warningText)
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(
            Fixed2.toDouble(expense.amount),
            size: AppMoneySize.md,
            color: AppColors.errorText,
          ),
          if (expense.isPending) ...[
            const SizedBox(height: 4),
            const AppStatusBadge(
              label: 'Pendiente',
              tone: AppStatusTone.warning,
              size: AppStatusBadgeSize.sm,
            ),
          ],
        ],
      ),
    );
  }

  /// Corregir exige `expenses.update`, que el colaborador no tiene (§13). Se
  /// comprueba aquí y no escondiendo la tarjeta: el gasto se tiene que ver
  /// igual, lo que cambia es si se puede tocar.
  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null || !user.hasPermission(AppPermissions.expensesUpdate)) {
      _say(context, 'Corregir un gasto es cosa de un administrador');
      return;
    }

    final categories =
        ref.read(cashExpensesCategoriesProvider).valueOrNull ?? const <ExpenseCategory>[];
    final draft = await ExpenseSheet.show(
      context,
      categories: categories,
      date: ref.read(cashDateFilterProvider),
      initial: expense,
    );
    if (draft == null || !context.mounted) return;

    final result = await ref.read(expensesRepositoryProvider).update(expense, draft);
    if (!context.mounted) return;
    result.match(
      (failure) => _say(context, failure.message),
      (_) => _say(context, 'Gasto corregido'),
    );
  }
}

class _ExpensesTotal extends StatelessWidget {
  const _ExpensesTotal({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text(
            'Total de gastos',
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          AppMoneyText(Fixed2.toDouble(amount), size: AppMoneySize.lg),
        ],
      ),
    );
  }
}

/// Las dos acciones del mostrador, fijas sobre la barra inferior.
///
/// «Cerrar día» no está: su pantalla es la fase UI 8, y un botón que lleva a un
/// marcador en medio del flujo del mostrador es peor que no tenerlo.
class _CashFooter extends ConsumerWidget {
  const _CashFooter({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: PermissionGate(
              anyOf: const [AppPermissions.expensesCreate],
              child: AppButton(
                label: 'Gasto',
                icon: const Icon(Icons.remove_circle_outline_rounded),
                variant: AppButtonVariant.outline,
                fullWidth: true,
                onPressed: day.isClosed ? null : () => _addExpense(context, ref),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: PermissionGate(
              anyOf: const [AppPermissions.supplySalesCreate],
              child: AppButton(
                label: 'Venta',
                icon: const Icon(Icons.local_mall_outlined),
                fullWidth: true,
                elevated: true,
                onPressed: day.isClosed
                    ? null
                    : () => context.push(SupplySaleScreen.path),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addExpense(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    final categories =
        ref.read(cashExpensesCategoriesProvider).valueOrNull ?? const <ExpenseCategory>[];

    final draft = await ExpenseSheet.show(
      context,
      categories: categories,
      date: ref.read(cashDateFilterProvider),
    );
    if (draft == null || user == null || !context.mounted) return;

    final result = await ref
        .read(expensesRepositoryProvider)
        .create(draft, createdById: user.id);
    if (!context.mounted) return;
    result.match(
      (failure) => _say(context, failure.message),
      (expense) => _say(context, 'Gasto de Q${Fixed2.format(expense.amount)} registrado'),
    );
  }
}

/// Chip de fecha con calendario, igual que en la lista de pedidos: la pregunta
/// "¿de qué día?" precede a todas las demás.
class _DayChip extends StatelessWidget {
  const _DayChip({required this.date, required this.today, required this.onChanged});

  final DateTime date;
  final DateTime today;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.18),
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(today.year - 1),
            lastDate: today,
            helpText: 'Día de la caja',
            cancelText: 'Cancelar',
            confirmText: 'Ver',
          );
          if (picked != null) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.white),
              const SizedBox(width: 7),
              Text(
                formatBusinessDate(date, today: today),
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _say(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
