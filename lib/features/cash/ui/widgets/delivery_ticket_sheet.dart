import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/app_permissions.dart';
import '../../../../core/money/fixed2.dart';
import '../../../../core/money/payment_method.dart';
import '../../../auth/state/auth_controller.dart';
import '../../../orders/models/order.dart';
import '../../models/delivery_line.dart';

/// La hoja de **una** boleta: se entrega y se cobra de una vez (plan 0006 §7.1.1).
///
/// Es lo que pasa en el mostrador la mayoría de las veces: llega el cliente,
/// pide su boleta, paga y se va con la ropa. Una boleta, un cobro, un acto — y
/// por eso tocar la fila abre esto y no una lista de marcados: el repaso en lote
/// es del final del día, cuando se cuadra lo que salió durante la jornada.
///
/// Las dos preguntas son las del papel y en ese orden: **cuánto pagó** —todo, o
/// una parte y el resto queda debiendo— y **cómo pagó**, efectivo o
/// transferencia. Arranca en «pagó todo» y en efectivo porque es lo que ocurre
/// casi siempre; lo demás son dos toques.
class DeliveryTicketSheet extends ConsumerStatefulWidget {
  const DeliveryTicketSheet({super.key, required this.order});

  final OrderListItem order;

  /// Abre la hoja y devuelve la línea a entregar, o `null` si se canceló.
  static Future<DeliveryLine?> show(BuildContext context, OrderListItem order) {
    return AppBottomSheetScaffold.show<DeliveryLine>(
      context: context,
      builder: (context) => DeliveryTicketSheet(order: order),
    );
  }

  @override
  ConsumerState<DeliveryTicketSheet> createState() => _DeliveryTicketSheetState();
}

class _DeliveryTicketSheetState extends ConsumerState<DeliveryTicketSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: Fixed2.format(widget.order.balance),
  );
  final TextEditingController _reference = TextEditingController();

  /// `false` es «pagó todo». Se guarda así y no como monto para que volver a
  /// «pagó todo» recupere el saldo entero sin que nadie lo teclee.
  bool _partial = false;

  PaymentMethod _method = PaymentMethod.cash;
  String? _error;

  int get _balance => widget.order.balance;

  /// Lo que paga ahora: el saldo entero, o lo tecleado si pagó una parte.
  int get _amountNow => _partial ? (Fixed2.parse(_amount.text) ?? 0) : _balance;

  int get _pending => _balance - _amountNow;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _confirm() {
    final amount = _amountNow;
    if (amount > _balance) {
      // El vuelto no es un pago: cobrar Q100 contra un saldo de Q75 pondría
      // veinticinco quetzales en los libros que nunca se quedaron en la caja.
      setState(() => _error = 'No se puede cobrar más que el saldo');
      return;
    }
    if (amount < 0) {
      setState(() => _error = 'El monto no puede ser negativo');
      return;
    }

    Navigator.of(context).pop(
      DeliveryLine.of(widget.order).copyWith(
        amount: amount,
        method: _method,
        paymentReference: _method == PaymentMethod.transfer && _reference.text.trim().isNotEmpty
            ? _reference.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final user = ref.watch(authControllerProvider).valueOrNull;
    // Fiar es una decisión de administrador (§5.5). Se dice el porqué en vez de
    // esconder el control: quien no puede tiene que saber qué pedir.
    final canLend = user?.hasPermission(AppPermissions.ordersDeliverUnpaid) ?? false;
    final blocked = _pending > 0 && !canLend;

    return AppBottomSheetScaffold(
      title: 'Entregar ${order.bookletSerial ?? order.reference}',
      subtitle: order.customerName,
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              // El botón dice qué va a pasar con el dinero, no «Confirmar»:
              // entregar con saldo y cobrar completo son dos cosas distintas y
              // la diferencia se lee justo antes de tocarlo.
              label: _pending > 0 ? 'Entregar con saldo' : 'Cobrar y entregar',
              icon: const Icon(Icons.check_rounded),
              fullWidth: true,
              elevated: true,
              onPressed: blocked ? null : _confirm,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Figures(order: order),
          const SizedBox(height: 16),
          Text('¿CUÁNTO PAGÓ?', style: AppTypography.label),
          const SizedBox(height: 7),
          AppSegmented<bool>(
            value: _partial,
            options: const [
              AppSegmentedOption(
                value: false,
                label: 'Pagó todo',
                icon: Icons.check_circle_outline_rounded,
              ),
              AppSegmentedOption(
                value: true,
                label: 'Queda debiendo',
                icon: Icons.schedule_rounded,
              ),
            ],
            onChanged: (partial) => setState(() {
              _partial = partial;
              _error = null;
              // Al pasar a «queda debiendo» el campo arranca en el saldo, que es
              // desde donde se baja: nadie teclea un abono desde cero.
              if (partial) _amount.text = Fixed2.format(_balance);
            }),
          ),
          if (_partial) ...[
            const SizedBox(height: 14),
            AppFormField(
              label: 'PAGA AHORA',
              controller: _amount,
              hintText: 'Q 0.00',
              errorText: _error,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              onChanged: (_) => setState(() => _error = null),
            ),
          ],
          const SizedBox(height: 14),
          Text('¿CÓMO PAGÓ?', style: AppTypography.label),
          const SizedBox(height: 7),
          AppSegmented<PaymentMethod>(
            value: _method,
            options: const [
              AppSegmentedOption(
                value: PaymentMethod.cash,
                label: 'Efectivo',
                icon: Icons.payments_outlined,
              ),
              AppSegmentedOption(
                value: PaymentMethod.transfer,
                label: 'Transferencia',
                icon: Icons.swap_horiz_rounded,
              ),
            ],
            onChanged: (method) => setState(() => _method = method),
          ),
          if (_method == PaymentMethod.transfer) ...[
            const SizedBox(height: 14),
            AppFormField(
              label: 'REFERENCIA',
              controller: _reference,
              hintText: 'No. de la transferencia',
              optional: true,
            ),
          ],
          const SizedBox(height: 16),
          _Result(
            entering: _amountNow,
            pending: _pending,
            method: _method,
            blocked: blocked,
          ),
        ],
      ),
    );
  }
}

/// Total, anticipos y saldo: las tres cifras de la boleta, para que nadie tenga
/// que restar de cabeza con el cliente enfrente.
class _Figures extends StatelessWidget {
  const _Figures({required this.order});

  final OrderListItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _Line(label: 'Total', amount: order.total),
          if (order.paid > 0) ...[
            const SizedBox(height: 5),
            _Line(label: 'Anticipos', amount: order.paid),
          ],
          const Divider(height: 18),
          _Line(label: 'Saldo', amount: order.balance, strong: true),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${order.totalPieces} ${order.totalPieces == 1 ? 'pieza' : 'piezas'}',
              style: AppTypography.helper.copyWith(fontSize: 11),
            ),
          ),
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
            fontSize: strong ? 13.5 : 12.5,
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

/// Qué va a pasar al confirmar: lo que entra a la caja y lo que queda a deber.
class _Result extends StatelessWidget {
  const _Result({
    required this.entering,
    required this.pending,
    required this.method,
    required this.blocked,
  });

  final int entering;
  final int pending;
  final PaymentMethod method;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon, title, message) = blocked
        ? (
            AppColors.errorBg,
            AppColors.errorText,
            Icons.lock_outline_rounded,
            'Solo un administrador entrega fiado',
            'Cobrá la boleta completa o pedí que la entregue un administrador.',
          )
        : pending > 0
        ? (
            AppColors.warningBg,
            AppColors.warningText,
            Icons.schedule_rounded,
            'Queda debiendo Q${Fixed2.format(pending)}',
            'La boleta queda entregada con saldo, y el cliente con alerta de cobro. '
                'Entran Q${Fixed2.format(entering)} en ${method.label.toLowerCase()}.',
          )
        : (
            AppColors.successBg,
            AppColors.successText,
            Icons.check_circle_outline_rounded,
            'Entran Q${Fixed2.format(entering)} a la caja de hoy',
            'La boleta queda entregada y saldada, cobrada en '
                '${method.label.toLowerCase()}.',
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
                Text(
                  message,
                  style: AppTypography.helper.copyWith(fontSize: 11.5, color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
