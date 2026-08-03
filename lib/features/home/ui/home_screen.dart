import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../../sync/state/sync_status_controller.dart';
import '../../sync/ui/widgets/sync_status_indicator.dart';
import '../models/home_summary.dart';
import '../state/home_summary_controller.dart';
import 'widgets/cash_summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/workshop_card.dart';

/// Pantalla Inicio (Plan 0006 §4.1): responde "¿cómo va el día?" y lanza las
/// acciones más frecuentes sin buscar en los tabs.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String path = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryControllerProvider);
    final summary = summaryAsync.valueOrNull ?? const HomeSummary.empty();
    final syncStatus = ref.watch(syncStatusControllerProvider);

    return Column(
      children: [
        const _HomeHeader(),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary500,
            onRefresh: () => ref.read(homeSummaryControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              children: [
                if (syncStatus.hasReview) ...[
                  _ReviewBanner(
                    count: syncStatus.reviewCount,
                    onTap: () => context.push('/sync/review'),
                  ),
                  const SizedBox(height: 18),
                ],
                PermissionGate(
                  anyOf: const [AppPermissions.dailyCloseRead],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSectionHeader(
                        title: 'Caja al momento',
                        actionLabel: 'Ver Caja',
                        onActionTap: () => context.go('/cash'),
                      ),
                      CashSummaryCard(summary: summary),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                PermissionGate(
                  anyOf: const [AppPermissions.ordersRead],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSectionHeader(
                        title: 'En el taller',
                        accentColor: AppColors.secondary500,
                        actionLabel: 'Ver pedidos',
                        onActionTap: () => context.go('/orders'),
                      ),
                      WorkshopCard(
                        summary: summary,
                        onStatusTap: (status) =>
                            context.go('/orders', extra: {'status': status}),
                        onDeliveredTap: () =>
                            context.go('/orders', extra: {'status': 'delivered'}),
                      ),
                      const SizedBox(height: 18),
                      _ReadyOrdersSection(orders: summary.readyOrders),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                const _QuickActionsSection(),
                if (summary.lastSyncedAtLabel != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Última sincronización: ${summary.lastSyncedAtLabel}',
                    textAlign: TextAlign.center,
                    style: AppTypography.helper.copyWith(fontSize: 11.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Cabecera: saludo, nombre, indicador de sync y avatar.
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    return GradientHeader(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(TimeOfDay.now()),
                  style: AppTypography.helper.copyWith(
                    fontSize: 12,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  user?.displayName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SyncStatusIndicator(onTap: () => context.push('/sync')),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => context.go('/more'),
            borderRadius: AppRadius.fullAll,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.22),
                borderRadius: AppRadius.fullAll,
              ),
              child: Text(
                _initials(user?.displayName),
                style: AppTypography.money(fontSize: 13, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting(TimeOfDay now) {
    if (now.hour < 12) return 'Buenos días';
    if (now.hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
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

/// Banner de la cola de revisión: solo aparece si hay operaciones esperando
/// una decisión (Plan 0006 §4.1).
class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.errorBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECDCA)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count ${count == 1 ? 'captura necesita' : 'capturas necesitan'} tu decisión',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF912018),
                      ),
                    ),
                    Text(
                      'Abrir cola de revisión',
                      style: AppTypography.helper.copyWith(
                        fontSize: 12,
                        color: AppColors.errorText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.errorText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista corta de pedidos listos para entregar.
class _ReadyOrdersSection extends StatelessWidget {
  const _ReadyOrdersSection({required this.orders});

  final List<ReadyOrder> orders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: 'Listos para entregar',
          accentColor: AppColors.secondary500,
          trailing: orders.isEmpty
              ? null
              : AppStatusBadge(label: '${orders.length}', tone: AppStatusTone.success),
        ),
        if (orders.isEmpty)
          const AppEmptyState(
            icon: Icons.check_rounded,
            title: 'Nada listo por ahora',
            message: 'Los pedidos aparecen aquí al marcarse como listos.',
          )
        else
          for (final order in orders)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ReadyOrderCard(order: order),
            ),
      ],
    );
  }
}

class _ReadyOrderCard extends StatelessWidget {
  const _ReadyOrderCard({required this.order});

  final ReadyOrder order;

  @override
  Widget build(BuildContext context) {
    final subtitle = order.pendingSync
        ? 'Folio ${order.reference} · sin sincronizar'
        : [
            'No. ${order.reference}',
            '${order.pieces} pzas',
            if (order.receivedAtLabel != null) order.receivedAtLabel!,
          ].join(' · ');

    return AppListCard(
      title: order.customerName,
      subtitle: subtitle,
      onTap: () => context.push('/orders/${order.id}'),
      leading: AppListCardTile(
        label: order.reference,
        background: order.pendingSync ? AppColors.warningBg : AppColors.primary100,
        foreground: order.pendingSync ? AppColors.warningText : AppColors.primary700,
      ),
      titleSuffix: order.pendingSync
          ? const Icon(Icons.sync_rounded, size: 13, color: AppColors.warningText)
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(order.total, size: AppMoneySize.sm),
          const SizedBox(height: 3),
          order.isPaid
              ? const AppStatusBadge(
                  label: 'Pagado',
                  tone: AppStatusTone.success,
                  size: AppStatusBadgeSize.sm,
                )
              : AppStatusBadge(
                  label:
                      'Saldo ${AppMoneyText.format(order.balance, showDecimals: false)}',
                  tone: AppStatusTone.error,
                  size: AppStatusBadgeSize.sm,
                ),
        ],
      ),
    );
  }
}

/// Las 4 acciones más frecuentes, cada una detrás de su permiso.
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(title: 'Acciones rápidas'),
        PermissionGate(
          anyOf: const [AppPermissions.ordersCreate],
          child: Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: PrimaryQuickAction(
              title: 'Nuevo pedido',
              subtitle: 'Tomar la boleta del cliente',
              icon: Icons.add_rounded,
              onTap: () => context.push('/orders/new'),
            ),
          ),
        ),
        // IntrinsicHeight iguala el alto de las dos tarjetas aunque un título
        // ocupe dos líneas; sin él, `stretch` pediría alto infinito al ListView.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PermissionGate(
                  anyOf: const [AppPermissions.expensesCreate],
                  child: QuickActionTile(
                    title: 'Registrar gasto',
                    icon: Icons.remove_circle_outline_rounded,
                    iconBackground: AppColors.errorBg,
                    iconColor: AppColors.errorText,
                    onTap: () => context.go('/cash'),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: PermissionGate(
                  anyOf: const [AppPermissions.supplySalesCreate],
                  child: QuickActionTile(
                    title: 'Venta de insumo',
                    icon: Icons.local_mall_outlined,
                    iconBackground: AppColors.secondary100,
                    iconColor: AppColors.secondary700,
                    onTap: () => context.push('/cash/supply-sale'),
                  ),
                ),
              ),
            ],
          ),
        ),
        PermissionGate(
          anyOf: const [AppPermissions.attendanceRecord],
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: QuickActionRow(
              title: 'Asistencia',
              icon: Icons.schedule_rounded,
              iconBackground: AppColors.warningBg,
              iconColor: AppColors.warningText,
              onTap: () => context.push('/staff'),
            ),
          ),
        ),
      ],
    );
  }
}
