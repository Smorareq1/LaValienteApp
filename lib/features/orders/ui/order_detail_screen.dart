import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/fixed2.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../data/orders_repository.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/order.dart';
import '../state/orders_controller.dart';
import 'order_deliver_screen.dart';
import 'orders_screen.dart';
import 'widgets/cancel_order_sheet.dart';
import 'widgets/payment_sheet.dart';

/// Detalle de un pedido (Plan 0006 §5.4).
///
/// Todo el pedido en modo lectura, y abajo lo que se puede hacer con él según
/// su estado y los permisos de quien lo mira. Las acciones no se listan todas
/// apagadas: lo que este estado no permite simplemente no está, porque un botón
/// gris que nunca se enciende es una pregunta sin respuesta.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(orderDetailProvider(orderId));

    return switch (detail) {
      AsyncData(value: final order?) => _Detail(order: order),
      AsyncData() => const _Missing(),
      AsyncError(:final error) => _Failed(message: '$error'),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: AppEmptyState(
        icon: Icons.help_outline_rounded,
        title: 'Ese pedido ya no está',
        message: 'Puede haberse borrado en otro dispositivo.',
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AppEmptyState(
        icon: Icons.storage_rounded,
        title: 'No se pudo leer el pedido',
        message: message,
      ),
    );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.order});

  final OrderDetail order;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  OrderDetail get order => widget.order;

  /// Corre una acción del ciclo y avisa cómo fue.
  ///
  /// El éxito se confirma aunque la pantalla ya se redibuje sola con la BD
  /// local: sin aviso, tocar "Marcar listo" y ver cambiar una píldora pequeña
  /// se parece demasiado a no haber hecho nada.
  Future<void> _run(
    Future<Either<AppFailure, void>> Function() action,
    String done,
  ) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);

    final messenger = ScaffoldMessenger.of(context);
    result.match(
      (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => messenger.showSnackBar(SnackBar(content: Text(done))),
    );
  }

  Future<void> _advance(OrderStatus next) async {
    final repository = ref.read(ordersRepositoryProvider);
    await _run(
      () => repository.changeStatus(order, next),
      'Pedido ${order.reference}: ${next.label.toLowerCase()}',
    );
  }

  Future<void> _pay() async {
    final payment = await PaymentSheet.show(context, balance: order.balance);
    if (payment == null || !mounted) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    final repository = ref.read(ordersRepositoryProvider);
    await _run(
      () => repository.addPayment(order, payment: payment, actorId: user.id),
      'Pago de Q${Fixed2.format(payment.amount)} registrado',
    );
  }

  Future<void> _cancel() async {
    final reason = await CancelOrderSheet.show(context, reference: order.reference);
    if (reason == null || !mounted) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    final repository = ref.read(ordersRepositoryProvider);
    await _run(
      () => repository.cancel(order, reason: reason, actorId: user.id),
      'Pedido ${order.reference} anulado',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(),
        Expanded(child: _body()),
      ],
    );
  }

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      children: [
        _HeaderCard(order: order),
        _GarmentsCard(order: order),
        _MoneyCard(order: order),
        _PaymentsCard(order: order),
        _AuditCard(order: order),
        _Actions(
          order: order,
          busy: _busy,
          onAdvance: _advance,
          onPay: _pay,
          onCancel: _cancel,
        ),
      ],
    );
  }
}

/// Barra superior de la pantalla apilada. Vuelve a la lista cuando no hay nada
/// debajo: un enlace profundo abre el detalle sin pila y ahí `pop` no lleva a
/// ningún lado.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(10, 0, 16, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(OrdersScreen.path);
              }
            },
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          ),
          Text(
            'Pedido',
            style: AppTypography.bodySm.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary100,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final details = [
      order.orderDate,
      if (order.bookletSerial != null) 'boleta ${order.bookletSerial}',
      if (order.nit != null) 'NIT ${order.nit}',
      if (order.weightLbs != null) '${Fixed2.format(order.weightLbs!)} lbs',
    ].join(' · ');

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.reference,
                      style: AppTypography.money(
                        fontSize: 30,
                        color: order.isPending
                            ? AppColors.warningText
                            : AppColors.primary700,
                      ),
                    ),
                    Text(details, style: AppTypography.helper.copyWith(fontSize: 11.5)),
                  ],
                ),
              ),
              _StatusPill(status: order.status),
            ],
          ),
          if (order.isPending) ...[
            const SizedBox(height: 10),
            const _Notice(
              icon: Icons.schedule_rounded,
              message: 'Todavía no sube al servidor. El No. diario definitivo '
                  'llega al sincronizar.',
            ),
          ],
          if (order.needsReview) ...[
            const SizedBox(height: 10),
            const _Notice(
              icon: Icons.error_outline_rounded,
              isError: true,
              message: 'El servidor rechazó este pedido. Está en la cola de revisión.',
            ),
          ],
          const SizedBox(height: 12),
          Material(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => context.push('/customers/${order.customerId}'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: AppColors.gray500),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.gray300,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GarmentsCard extends StatelessWidget {
  const _GarmentsCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    if (order.garments.isEmpty) return const SizedBox.shrink();

    return _Card(
      title: 'Prendas',
      trailing: AppStatusBadge(
        label: '${order.totalPieces} pzas',
        tone: AppStatusTone.brand,
        size: AppStatusBadgeSize.sm,
      ),
      child: Column(
        children: [
          for (final line in order.garments)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.name,
                          style: AppTypography.bodySm.copyWith(fontSize: 13.5),
                        ),
                        if (line.notes != null)
                          Text(
                            line.notes!,
                            style: AppTypography.helper.copyWith(fontSize: 11.5),
                          ),
                      ],
                    ),
                  ),
                  // La diferencia entre lo recibido y lo entregado se pinta en
                  // rojo: es la única cifra de esta pantalla que alguien va a
                  // tener que explicar.
                  Text(
                    line.quantityDelivered == null
                        ? '${line.quantity}'
                        : '${line.quantityDelivered} de ${line.quantity}',
                    style: AppTypography.money(
                      fontSize: 14,
                      color: line.isShort ? AppColors.errorText : AppColors.textPrimary,
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

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Cargos y descuentos',
      child: Column(
        children: [
          for (final charge in order.charges)
            _AmountRow(
              label: charge.description,
              detail: charge.quantity == 100
                  ? null
                  : '${Fixed2.format(charge.quantity)} × Q${Fixed2.format(charge.unitPrice)}',
              amount: charge.amount,
            ),
          const Divider(height: 18),
          _AmountRow(label: 'Subtotal', amount: order.subtotal),
          for (final discount in order.discounts)
            _AmountRow(
              label: discount.description,
              amount: -discount.amount,
              highlight: true,
            ),
          const SizedBox(height: 6),
          _AmountRow(label: 'TOTAL', amount: order.total, strong: true),
        ],
      ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final settled = order.balance <= 0;

    return _Card(
      title: 'Pagos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.payments.isEmpty)
            Text(
              'Todavía no se ha cobrado nada.',
              style: AppTypography.helper.copyWith(fontSize: 12),
            ),
          for (final payment in order.payments)
            _AmountRow(
              label: payment.isAdvance ? 'Anticipo' : (payment.method?.label ?? 'Pago'),
              detail: _paidAtLabel(payment),
              amount: payment.amount,
              pending: payment.isPending,
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: settled ? AppColors.successBg : AppColors.errorBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Text(
                  settled ? 'Saldado' : 'Saldo pendiente',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: settled ? AppColors.successText : AppColors.errorText,
                  ),
                ),
                const Spacer(),
                AppMoneyText(
                  Fixed2.toDouble(order.balance < 0 ? 0 : order.balance),
                  size: AppMoneySize.lg,
                  color: settled ? AppColors.successText : AppColors.errorText,
                  decimalColor: settled ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _paidAtLabel(OrderPaymentLine payment) {
    final at = payment.paidAt.toLocal();
    final day = '${at.day.toString().padLeft(2, '0')}/${at.month.toString().padLeft(2, '0')}';
    final time = '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    final reference = payment.reference;
    return reference == null ? '$day · $time' : '$day · $time · $reference';
  }
}

class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      if (order.createdAt != null) ('Recibido', _moment(order.createdAt!)),
      if (order.deliveredAt != null) ('Entregado', _moment(order.deliveredAt!)),
      if (order.cancelledAt != null) ('Anulado', _moment(order.cancelledAt!)),
    ];

    if (entries.isEmpty && order.observations == null && order.cancelReason == null) {
      return const SizedBox.shrink();
    }

    return _Card(
      title: 'Observaciones y registro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.observations != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                order.observations!,
                style: AppTypography.bodySm.copyWith(fontSize: 13),
              ),
            ),
          if (order.cancelReason != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Notice(
                icon: Icons.block_rounded,
                isError: true,
                message: 'Anulado: ${order.cancelReason}',
              ),
            ),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    entry.$1,
                    style: AppTypography.bodySm.copyWith(fontSize: 12.5),
                  ),
                  const Spacer(),
                  Text(entry.$2, style: AppTypography.helper.copyWith(fontSize: 12)),
                ],
              ),
            ),
          // Quién hizo cada cosa se guarda, pero no se puede mostrar: los
          // usuarios no viajan por el feed, así que el dispositivo solo tiene
          // ids. Aparecerá cuando `identity` entre al feed.
        ],
      ),
    );
  }

  static String _moment(DateTime value) {
    final at = value.toLocal();
    final day = '${at.day.toString().padLeft(2, '0')}/${at.month.toString().padLeft(2, '0')}';
    final time = '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    return '$day a las $time';
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.order,
    required this.busy,
    required this.onAdvance,
    required this.onPay,
    required this.onCancel,
  });

  final OrderDetail order;
  final bool busy;
  final void Function(OrderStatus) onAdvance;
  final VoidCallback onPay;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    if (status == null) return const SizedBox.shrink();

    final actions = <Widget>[
      for (final next in status.nextSteps)
        PermissionGate(
          anyOf: const [AppPermissions.ordersUpdate],
          child: AppButton(
            label: next == OrderStatus.received
                ? 'Volver a recibido'
                : 'Marcar ${next.label.toLowerCase()}',
            variant: next == OrderStatus.received
                ? AppButtonVariant.ghost
                : AppButtonVariant.primary,
            icon: Icon(
              next == OrderStatus.received
                  ? Icons.undo_rounded
                  : Icons.arrow_forward_rounded,
            ),
            fullWidth: true,
            onPressed: busy ? null : () => onAdvance(next),
          ),
        ),
      if (status.canBeDelivered)
        PermissionGate(
          anyOf: const [AppPermissions.ordersDeliver],
          child: AppButton(
            label: 'Entregar',
            icon: const Icon(Icons.local_shipping_outlined),
            fullWidth: true,
            elevated: true,
            onPressed: busy
                ? null
                : () => context.push(OrderDeliverScreen.pathFor(order.id)),
          ),
        ),
      // Corregir la boleta (§7.3). Un pedido `listo` pide además el permiso de
      // admin, y por eso son dos puertas y no una: el colaborador ve el botón
      // mientras el pedido está en el local, y deja de verlo cuando ya se lavó.
      if (status.canBeEdited)
        PermissionGate(
          anyOf: status.needsAdminToEdit
              ? const [AppPermissions.ordersUpdateReady]
              : const [AppPermissions.ordersUpdate],
          child: AppButton(
            label: 'Editar',
            variant: AppButtonVariant.secondary,
            icon: const Icon(Icons.edit_outlined),
            fullWidth: true,
            onPressed: busy
                ? null
                : () => context.push('${OrdersScreen.path}/${order.id}/edit'),
          ),
        ),
      if (status.acceptsPayments && order.hasBalance)
        PermissionGate(
          anyOf: const [AppPermissions.ordersCollectPayment],
          child: AppButton(
            label: 'Registrar pago',
            variant: AppButtonVariant.secondary,
            icon: const Icon(Icons.payments_outlined),
            fullWidth: true,
            onPressed: busy ? null : onPay,
          ),
        ),
      if (status.canBeCancelled)
        PermissionGate(
          anyOf: const [AppPermissions.ordersCancel],
          child: AppButton(
            label: 'Anular pedido',
            variant: AppButtonVariant.outline,
            icon: const Icon(Icons.block_rounded),
            fullWidth: true,
            onPressed: busy ? null : onCancel,
          ),
        ),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final action in actions)
          Padding(padding: const EdgeInsets.only(bottom: 9), child: action),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.title, this.trailing});

  final String? title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.h3.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.detail,
    this.strong = false,
    this.highlight = false,
    this.pending = false,
  });

  final String label;
  final String? detail;
  final int amount;
  final bool strong;
  final bool highlight;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: strong ? 14 : 13,
                          fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (pending) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppColors.warningText,
                      ),
                    ],
                  ],
                ),
                if (detail != null)
                  Text(detail!, style: AppTypography.helper.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppMoneyText(
            Fixed2.toDouble(amount),
            size: strong ? AppMoneySize.lg : AppMoneySize.md,
            color: highlight ? AppColors.primary600 : null,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus? status;

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      return const AppStatusBadge(label: 'Estado desconocido');
    }

    return AppStatusBadge(
      label: status!.label,
      tone: switch (status!) {
        OrderStatus.received => AppStatusTone.info,
        OrderStatus.inProgress => AppStatusTone.warning,
        OrderStatus.ready => AppStatusTone.success,
        OrderStatus.delivered => AppStatusTone.brand,
        OrderStatus.cancelled => AppStatusTone.neutral,
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.message, this.isError = false});

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final foreground = isError ? AppColors.errorText : AppColors.warningText;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
