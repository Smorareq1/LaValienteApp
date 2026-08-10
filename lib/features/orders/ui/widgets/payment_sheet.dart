import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/money/fixed2.dart';
import '../../domain/order_capture.dart';

/// Registrar un pago contra un pedido (Plan 0006 §5.6).
///
/// El monto arranca en el saldo entero porque lo normal es que se pague todo al
/// entregar; el abono parcial existe pero es la excepción, y quien la necesita
/// borra y escribe. El saldo restante se recalcula mientras se teclea, para que
/// nadie tenga que restar de cabeza con el cliente enfrente.
class PaymentSheet extends StatefulWidget {
  const PaymentSheet({
    super.key,
    required this.balance,
    this.title = 'Registrar pago',
  });

  /// Saldo del pedido, en centavos.
  final int balance;

  final String title;

  /// Abre la sheet y devuelve el pago, o `null` si se canceló.
  static Future<PaymentDraft?> show(
    BuildContext context, {
    required int balance,
    String title = 'Registrar pago',
  }) {
    return AppBottomSheetScaffold.show<PaymentDraft>(
      context: context,
      builder: (context) => PaymentSheet(balance: balance, title: title),
    );
  }

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: Fixed2.format(widget.balance),
  );
  final TextEditingController _reference = TextEditingController();

  PaymentMethod _method = PaymentMethod.cash;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  int get _typed => Fixed2.parse(_amount.text) ?? 0;

  void _confirm() {
    final amount = _typed;
    if (amount <= 0) {
      setState(() => _error = 'Escribí cuánto se está pagando');
      return;
    }
    if (amount > widget.balance) {
      // El vuelto no es un pago: registrar Q100 contra un saldo de Q75 pondría
      // veinticinco quetzales en los libros que nunca se quedaron en la caja.
      setState(() => _error = 'No se puede cobrar más que el saldo');
      return;
    }

    Navigator.of(context).pop(
      PaymentDraft(
        amount: amount,
        method: _method,
        reference: _method == PaymentMethod.transfer && _reference.text.trim().isNotEmpty
            ? _reference.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.balance - _typed;

    return AppBottomSheetScaffold(
      title: widget.title,
      subtitle: 'Saldo actual Q${Fixed2.format(widget.balance)}',
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
              label: 'Registrar',
              icon: const Icon(Icons.check_rounded),
              fullWidth: true,
              elevated: true,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFormField(
            label: 'MONTO',
            controller: _amount,
            hintText: 'Q 0.00',
            errorText: _error,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: 14),
          Text('MÉTODO', style: AppTypography.label),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: remaining > 0 ? AppColors.warningBg : AppColors.successBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Text(
                  remaining > 0 ? 'Queda debiendo' : 'Queda saldado',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: remaining > 0 ? AppColors.warningText : AppColors.successText,
                  ),
                ),
                const Spacer(),
                AppMoneyText(
                  Fixed2.toDouble(remaining < 0 ? 0 : remaining),
                  size: AppMoneySize.lg,
                  color: remaining > 0 ? AppColors.warningText : AppColors.successText,
                  decimalColor: remaining > 0 ? AppColors.warning : AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
