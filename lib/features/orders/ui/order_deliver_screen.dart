import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../auth/state/auth_controller.dart';
import '../data/orders_repository.dart';
import '../domain/order_capture.dart';
import '../models/order.dart';
import '../state/orders_controller.dart';
import 'widgets/capture_section.dart';
import 'widgets/payment_sheet.dart';

/// Entrega de un pedido (Plan 0006 §5.5).
///
/// La pantalla es una conciliación, no un botón: cada tipo de prenda arranca
/// con lo que se recibió y se baja solo si algo no volvió. Ese hueco es la
/// pérdida, y quedarse sin registrarlo es como se pierde la discusión tres
/// semanas después.
class OrderDeliverScreen extends ConsumerStatefulWidget {
  const OrderDeliverScreen({super.key, required this.orderId});

  final String orderId;

  static String pathFor(String orderId) => '/orders/$orderId/deliver';

  @override
  ConsumerState<OrderDeliverScreen> createState() => _OrderDeliverScreenState();
}

class _OrderDeliverScreenState extends ConsumerState<OrderDeliverScreen> {
  /// Id de línea → cuántas piezas vuelven. Se llena la primera vez que se lee
  /// el pedido y desde ahí manda lo que la persona toque.
  final Map<String, int> _delivered = {};
  bool _initialised = false;

  PaymentDraft? _payment;
  bool _saving = false;

  void _seed(OrderDetail order) {
    if (_initialised) return;
    _initialised = true;
    for (final line in order.garments) {
      // El default es "volvió todo": lo normal, y lo que evita que alguien con
      // prisa registre una pérdida por no tocar el control.
      _delivered[line.id] = line.quantityDelivered ?? line.quantity;
    }
  }

  Future<void> _collect(OrderDetail order) async {
    final payment = await PaymentSheet.show(
      context,
      balance: order.balance,
      title: 'Cobro al entregar',
    );
    if (payment != null) setState(() => _payment = payment);
  }

  Future<void> _confirm(OrderDetail order) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    final result = await ref
        .read(ordersRepositoryProvider)
        .deliver(
          order,
          delivered: _delivered,
          actorId: user.id,
          payment: _payment,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    result.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido ${order.reference} entregado')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(orderDetailProvider(widget.orderId));
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
        ),
        title: Text(
          'Entregar pedido',
          style: AppTypography.h3.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: switch (detail) {
        AsyncData(value: final order?) => _buildBody(order),
        AsyncData() => const Center(child: Text('Ese pedido ya no existe')),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
      bottomNavigationBar: switch (detail) {
        AsyncData(value: final order?) => _footer(order, user?.id),
        _ => null,
      },
    );
  }

  Widget _buildBody(OrderDetail order) {
    _seed(order);

    final short = [
      for (final line in order.garments)
        if ((_delivered[line.id] ?? line.quantity) < line.quantity) line,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        _Card(
          title: 'Prendas que vuelven',
          child: Column(
            children: [
              for (final line in order.garments)
                _GarmentRow(
                  line: line,
                  delivered: _delivered[line.id] ?? line.quantity,
                  onChanged: (value) => setState(() => _delivered[line.id] = value),
                ),
            ],
          ),
        ),
        if (short.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CaptureNotice(
              isError: true,
              message: short.length == 1
                  ? 'Falta ${short.single.quantity - (_delivered[short.single.id] ?? 0)} '
                        '${short.single.name.toLowerCase()}. Quedará registrado en el pedido.'
                  : '${short.length} tipos de prenda vuelven incompletos. '
                        'Quedará registrado en el pedido.',
            ),
          ),
        _Card(
          title: 'Cuentas',
          child: Column(
            children: [
              _Line(label: 'Total', amount: order.total),
              const SizedBox(height: 6),
              _Line(label: 'Pagado', amount: order.paid),
              const Divider(height: 20),
              _Line(label: 'Saldo', amount: order.balance, strong: true),
              if (_payment != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cobrando Q${Fixed2.format(_payment!.amount)} '
                          'en ${_payment!.method.label.toLowerCase()}',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successText,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _payment = null),
                        tooltip: 'Quitar el cobro',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: AppColors.successText,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (order.balance > 0) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: 'Cobrar al entregar',
                  variant: AppButtonVariant.outline,
                  icon: const Icon(Icons.payments_outlined),
                  fullWidth: true,
                  onPressed: () => _collect(order),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _footer(OrderDetail order, String? actorId) {
    final remaining = order.balance - (_payment?.amount ?? 0);
    final user = ref.watch(authControllerProvider).valueOrNull;
    // Fiar es una decisión, no un descuido: solo quien puede la toma, y el
    // botón se muestra deshabilitado con el porqué en vez de desaparecer (§13).
    final canLend = user?.hasPermission(AppPermissions.ordersDeliverUnpaid) ?? false;
    final blocked = remaining > 0 && !canLend;

    return AppSummaryBar(
      total: Fixed2.toDouble(remaining),
      totalLabel: remaining > 0 ? 'QUEDA DEBIENDO' : 'SALDO',
      caption: '${order.garments.length} tipos de prenda',
      actionLabel: 'Confirmar entrega',
      note: blocked
          ? 'Queda saldo pendiente: solo un administrador puede entregar fiado.'
          : remaining > 0
          ? 'Se entrega con Q${Fixed2.format(remaining)} pendientes.'
          : null,
      noteIsWarning: true,
      busy: _saving,
      onAction: blocked || actorId == null ? null : () => _confirm(order),
    );
  }
}

class _GarmentRow extends StatelessWidget {
  const _GarmentRow({
    required this.line,
    required this.delivered,
    required this.onChanged,
  });

  final OrderGarmentLine line;
  final int delivered;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final short = delivered < line.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: short ? AppColors.errorBg : AppColors.gray50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: short ? AppColors.error : AppColors.gray100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: short ? AppColors.errorText : AppColors.textPrimary,
                  ),
                ),
                Text(
                  short
                      ? 'Se recibieron ${line.quantity}; faltan ${line.quantity - delivered}'
                      : 'Se recibieron ${line.quantity}',
                  style: AppTypography.helper.copyWith(
                    fontSize: 11.5,
                    color: short ? AppColors.errorText : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          AppStepper(
            value: delivered,
            max: line.quantity,
            size: AppStepperSize.md,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
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
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: AppTypography.h3.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.amount, this.strong = false});

  final String label;
  final int amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            fontSize: 13,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        AppMoneyText(
          Fixed2.toDouble(amount),
          size: strong ? AppMoneySize.lg : AppMoneySize.md,
        ),
      ],
    );
  }
}
