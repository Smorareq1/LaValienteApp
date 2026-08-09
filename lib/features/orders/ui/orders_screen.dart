import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/order.dart';
import '../state/orders_controller.dart';
import 'order_capture_screen.dart';
import 'widgets/order_status_badge.dart';

/// Lista de pedidos del día (Plan 0006 §5.1).
///
/// Lee la BD local, así que el día se arma igual sin señal: los pedidos que
/// todavía no subieron aparecen con su folio provisional y su marca, no
/// escondidos hasta que haya red.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.initialStatus});

  static const String path = '/orders';

  /// Estado con el que abre, cuando se llega desde los contadores de Inicio.
  final OrderStatus? initialStatus;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    final status = widget.initialStatus;
    if (status != null) {
      // Después del primer cuadro: tocar un provider durante `initState` sería
      // modificarlo mientras el árbol se construye.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(orderStatusFilterProvider.notifier).update(status);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(filteredOrdersProvider);
    final day = ref.watch(ordersForDayProvider);
    final query = ref.watch(orderSearchQueryProvider);
    final status = ref.watch(orderStatusFilterProvider);

    return Stack(
      children: [
        Column(
          children: [
            const _OrdersHeader(),
            Expanded(
              child: switch (day) {
                AsyncError(:final error) => _LoadError(message: '$error'),
                AsyncLoading() => const _ListSkeleton(),
                _ => _OrderList(orders: orders, query: query, status: status),
              },
            ),
          ],
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: _OrdersFooter()),
      ],
    );
  }
}

class _OrdersHeader extends ConsumerWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(orderDateFilterProvider);
    final status = ref.watch(orderStatusFilterProvider);
    final total = ref.watch(ordersForDayProvider).valueOrNull?.length;

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total == null ? '' : '$total ${total == 1 ? 'pedido' : 'pedidos'}',
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary100,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pedidos',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              _DayChip(
                date: date,
                onChanged: (value) =>
                    ref.read(orderDateFilterProvider.notifier).update(value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppSearchField(
            hintText: 'Cliente, No. diario o boleta…',
            onChanged: (value) => ref.read(orderSearchQueryProvider.notifier).update(value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _StatusChip(
                  label: 'Todos',
                  selected: status == null,
                  onTap: () => ref.read(orderStatusFilterProvider.notifier).update(null),
                ),
                for (final option in OrderStatus.values)
                  _StatusChip(
                    label: option.label,
                    selected: status == option,
                    onTap: () =>
                        ref.read(orderStatusFilterProvider.notifier).update(option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de fecha con calendario. Va en la cabecera porque la pregunta "¿de qué
/// día?" precede a todas las demás.
class _DayChip extends StatelessWidget {
  const _DayChip({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = businessDate();

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
            lastDate: DateTime(today.year + 1, 12, 31),
            helpText: 'Día de los pedidos',
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Material(
        color: selected ? AppColors.white : AppColors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.fullAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.fullAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primary600 : AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.query, required this.status});

  final List<OrderListItem> orders;
  final String query;
  final OrderStatus? status;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 170),
        child: query.isNotEmpty
            ? AppEmptyState(
                icon: Icons.search_off_rounded,
                title: 'Ningún pedido coincide con "$query"',
                message: 'Probá con el nombre del cliente o el No. diario.',
              )
            : status != null
            ? AppEmptyState(
                icon: Icons.filter_alt_off_outlined,
                title: 'Ningún pedido ${status!.label.toLowerCase()} este día',
                message: 'Tocá "Todos" para ver los demás.',
              )
            : const _EmptyDay(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 170),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.local_mall_outlined,
      title: 'Sin pedidos este día',
      message: 'Cuando se reciba el primero aparecerá aquí.',
      action: PermissionGate(
        anyOf: const [AppPermissions.ordersCreate],
        child: AppButton(
          label: 'Nuevo pedido',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => context.push(OrderCaptureScreen.path),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderListItem order;

  @override
  Widget build(BuildContext context) {
    final time = order.createdAt?.toLocal();
    final subtitle = [
      if (time != null)
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      '${order.totalPieces} pzas',
      if (order.bookletSerial != null) 'boleta ${order.bookletSerial}',
    ].join(' · ');

    return AppListCard(
      title: order.customerName,
      subtitle: subtitle,
      leading: AppListCardTile(
        label: order.reference,
        background: order.isPending ? AppColors.warningBg : AppColors.primary100,
        foreground: order.isPending ? AppColors.warningText : AppColors.primary700,
      ),
      titleSuffix: order.needsReview
          ? const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.errorText)
          : order.isPending
          ? const Icon(Icons.schedule_rounded, size: 13, color: AppColors.warningText)
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(order.totalAsDouble, size: AppMoneySize.md),
          const SizedBox(height: 4),
          OrderStatusPill(status: order.status),
          if (order.hasBalance) ...[
            const SizedBox(height: 4),
            AppStatusBadge(
              label: 'Debe Q${Fixed2.format(order.balance)}',
              tone: AppStatusTone.error,
              size: AppStatusBadgeSize.sm,
            ),
          ],
        ],
      ),
      onTap: () => context.push('${OrdersScreen.path}/${order.id}'),
    );
  }
}

/// Total del día y la acción primaria, fijos sobre la barra inferior.
class _OrdersFooter extends ConsumerWidget {
  const _OrdersFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(listedTotalProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Total listado',
                style: AppTypography.helper.copyWith(fontSize: 12),
              ),
              const Spacer(),
              AppMoneyText(Fixed2.toDouble(total), size: AppMoneySize.lg),
            ],
          ),
          const SizedBox(height: 9),
          PermissionGate(
            anyOf: const [AppPermissions.ordersCreate],
            child: AppButton(
              label: 'Nuevo pedido',
              icon: const Icon(Icons.add_rounded),
              size: AppButtonSize.lg,
              fullWidth: true,
              elevated: true,
              onPressed: () => context.push(OrderCaptureScreen.path),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 170),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) => Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 170),
      child: AppEmptyState(
        icon: Icons.storage_rounded,
        title: 'No se pudo leer los pedidos',
        message: message,
      ),
    );
  }
}
