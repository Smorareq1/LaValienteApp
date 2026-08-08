import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/fixed2.dart';
import '../../../../core/money/payment_method.dart';
import '../../../../core/time/business_date.dart';
import '../../data/inventory_remote_datasource.dart';
import '../../models/product.dart';
import '../../state/inventory_admin_controller.dart';

/// Alta de lote: una compra que llega (Plan 0006 §8.4).
///
/// Dos cosas entran juntas y por eso están en la misma sheet: el **stock**, que
/// va al kardex, y el **gasto**, que va al día. La estantería y la caja dejan de
/// cuadrar en el momento en que uno se puede escribir sin el otro (plan 0005
/// §6.3), así que el gasto viaja pegado al lote en la misma llamada.
///
/// El **número de lote lo asigna el sistema** (D3) y se enseña al confirmar.
class LotFormSheet extends ConsumerStatefulWidget {
  const LotFormSheet({super.key, required this.product});

  final ProductSummary product;

  static Future<ProductLot?> show(
    BuildContext context, {
    required ProductSummary product,
  }) {
    return AppBottomSheetScaffold.show<ProductLot>(
      context: context,
      builder: (context) => LotFormSheet(product: product),
    );
  }

  @override
  ConsumerState<LotFormSheet> createState() => _LotFormSheetState();
}

class _LotFormSheetState extends ConsumerState<LotFormSheet> {
  final _quantity = TextEditingController();
  final _unitCost = TextEditingController();
  final _salePrice = TextEditingController();
  final _notes = TextEditingController();
  final _total = TextEditingController();

  DateTime _receivedAt = businessDate();
  bool _registerExpense = true;
  bool _totalEdited = false;
  PaymentMethod _method = PaymentMethod.cash;
  bool _pending = false;

  String? _quantityError;
  String? _totalError;
  String? _formError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _quantity.addListener(_syncTotal);
    _unitCost.addListener(_syncTotal);
  }

  @override
  void dispose() {
    for (final controller in [_quantity, _unitCost, _salePrice, _notes, _total]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// El total sigue a cantidad × costo mientras nadie lo haya tocado a mano. En
  /// cuanto alguien lo escribe deja de moverse: la factura manda sobre la cuenta
  /// —trae fletes, impuestos o un redondeo del proveedor.
  void _syncTotal() {
    if (_totalEdited) return;
    final quantity = Fixed2.parse(_quantity.text);
    final cost = Fixed2.parse(_unitCost.text);
    final next = quantity == null || cost == null
        ? ''
        : Fixed2.format(Fixed2.multiply(cost, quantity));
    if (_total.text != next) _total.text = next;
  }

  Future<void> _save() async {
    final quantity = Fixed2.parse(_quantity.text);
    final total = Fixed2.parse(_total.text);

    setState(() {
      _quantityError = switch (quantity) {
        null || <= 0 => 'Cuánto llegó, en ${widget.product.unit}',
        _ => null,
      };
      _totalError = _registerExpense && (total == null || total <= 0)
          ? 'El gasto necesita un monto'
          : null;
    });
    if (_quantityError != null || _totalError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final notes = _notes.text.trim();
    final input = LotInput(
      quantityReceived: quantity!,
      receivedAt: isoDate(_receivedAt),
      unitCost: Fixed2.parse(_unitCost.text),
      salePrice: Fixed2.parse(_salePrice.text),
      notes: notes.isEmpty ? null : notes,
      expense: _registerExpense
          ? LotExpenseInput(
              total: total!,
              method: _method.wire,
              pending: _pending,
              observations: notes.isEmpty ? null : notes,
            )
          : null,
    );

    final result = await ref
        .read(inventoryAdminControllerProvider.notifier)
        .registerLot(widget.product.id, input);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (lot) => Navigator.of(context).pop(lot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.product.unit;

    return AppBottomSheetScaffold(
      title: 'Entró ${widget.product.name}',
      subtitle: 'El número de lote lo pone el sistema.',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.secondary,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Registrar lote',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        children: [
          AppFormField(
            label: 'CANTIDAD RECIBIDA',
            controller: _quantity,
            hintText: '12',
            errorText: _quantityError,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                unit,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'COSTO POR $unit'.toUpperCase(),
            controller: _unitCost,
            optional: true,
            hintText: '18.00',
            helperText: 'Con esto sabrás tu ganancia.',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 4),
              child: Text('Q'),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'PRECIO DE VENTA',
            controller: _salePrice,
            optional: true,
            hintText: '25.00',
            helperText: 'Vacío significa que la casa se lo queda: no se vende.',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 4),
              child: Text('Q'),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          Text('FECHA DE RECEPCIÓN', style: AppTypography.label),
          const SizedBox(height: 7),
          AppDateField(
            value: _receivedAt,
            today: businessDate(),
            onChanged: (picked) => setState(() => _receivedAt = picked),
            helpText: 'Cuándo llegó',
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NOTAS',
            controller: _notes,
            optional: true,
            hintText: 'Factura 3341',
            helperText: 'Queda en el movimiento de entrada, no en el lote.',
          ),
          const SizedBox(height: 16),
          _ExpenseBlock(
            enabled: _registerExpense,
            total: _total,
            totalError: _totalError,
            method: _method,
            pending: _pending,
            onToggle: (value) => setState(() => _registerExpense = value),
            onTotalEdited: () => _totalEdited = true,
            onMethod: (value) => setState(() => _method = value),
            onPending: (value) => setState(() => _pending = value),
          ),
          if (_formError != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Text(
                _formError!,
                style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// El lado del dinero. Va encendido por omisión porque una compra que llega
/// casi siempre se pagó; apagarlo es para el lote que entra sin comprarse —una
/// devolución, un traslado, un conteo que apareció.
class _ExpenseBlock extends StatelessWidget {
  const _ExpenseBlock({
    required this.enabled,
    required this.total,
    required this.totalError,
    required this.method,
    required this.pending,
    required this.onToggle,
    required this.onTotalEdited,
    required this.onMethod,
    required this.onPending,
  });

  final bool enabled;
  final TextEditingController total;
  final String? totalError;
  final PaymentMethod method;
  final bool pending;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTotalEdited;
  final ValueChanged<PaymentMethod> onMethod;
  final ValueChanged<bool> onPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar el gasto',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Se asienta en «Compra de insumos» del día.',
                      style: AppTypography.helper.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: enabled, onChanged: onToggle),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppFormField(
                    label: 'TOTAL DE LA COMPRA',
                    controller: total,
                    errorText: totalError,
                    helperText: 'Sale de cantidad × costo, y se puede corregir: '
                        'la factura manda.',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 4),
                      child: Text('Q'),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => onTotalEdited(),
                  ),
                  const SizedBox(height: 12),
                  Text('CÓMO SE PAGÓ', style: AppTypography.label),
                  const SizedBox(height: 7),
                  AppSegmented<PaymentMethod>(
                    value: method,
                    onChanged: onMethod,
                    options: [
                      for (final option in PaymentMethod.values)
                        AppSegmentedOption(value: option, label: option.label),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Queda pendiente de pago',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Switch(value: pending, onChanged: onPending),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
