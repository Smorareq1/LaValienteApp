import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/money/fixed2.dart';
import '../../models/cash_sheet.dart';
import '../../state/cash_sheet_controller.dart';

/// Una fila de cobro de la hoja del día, lista para confirmarse o corregirse.
///
/// Es la unidad de decisión de toda la importación, y por eso enseña las tres
/// cosas que hacen falta para decidir y ninguna más: **qué boleta**, **cuánto
/// dice el papel frente a cuánto se debe**, y **si la ropa se va con el cobro**.
///
/// El monto se puede escribir. No es un adorno: la lectura se equivoca, y sin
/// esto la única salida ante un dígito mal leído sería desmarcar la fila y
/// cobrarla a mano en otra pantalla — que es exactamente el trabajo que esto
/// venía a quitar.
class CashIncomeTile extends StatefulWidget {
  const CashIncomeTile({
    required this.row,
    required this.edit,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final CashIncomeRow row;
  final IncomeEdit edit;
  final bool enabled;
  final ValueChanged<IncomeEdit> onChanged;

  @override
  State<CashIncomeTile> createState() => _CashIncomeTileState();
}

class _CashIncomeTileState extends State<CashIncomeTile> {
  late final _amount = TextEditingController(
    text: widget.edit.amount == 0 ? '' : Fixed2.format(widget.edit.amount),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  bool get _canCollect => widget.row.orderId != null && widget.row.status.isCollectable;

  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final edit = widget.edit;
    final (tone, note) = _status(row);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: switch (tone) {
            AppStatusTone.success => AppColors.border,
            AppStatusTone.error => AppColors.error,
            _ => AppColors.warning,
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: edit.selected,
                onChanged: !widget.enabled || !_canCollect
                    ? null
                    : (value) =>
                          widget.onChanged(edit.copyWith(selected: value)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Boleta ${row.bookletSerial.value ?? "—"}',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (row.customerText.value case final name?)
                      Text(
                        name,
                        style: AppTypography.helper.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (row.isTransfer)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: AppStatusBadge(
                    label: 'Transf.',
                    tone: AppStatusTone.info,
                    size: AppStatusBadgeSize.sm,
                  ),
                ),
              if (row.invoiceRequested)
                const AppStatusBadge(
                  label: 'Factura',
                  tone: AppStatusTone.brand,
                  size: AppStatusBadgeSize.sm,
                ),
            ],
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2, bottom: 6),
              child: Text(
                note,
                style: AppTypography.helper.copyWith(
                  color: tone == AppStatusTone.error
                      ? AppColors.errorText
                      : AppColors.warningText,
                ),
              ),
            ),
          if (_canCollect) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: AppTextField(
                    controller: _amount,
                    hintText: 'Monto',
                    enabled: widget.enabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (value) => widget.onChanged(
                      edit.copyWith(amount: Fixed2.parse(value) ?? 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (row.balance case final balance?)
                        Text(
                          'Debe Q${Fixed2.format(balance)}',
                          style: AppTypography.helper.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      const SizedBox(height: 2),
                      AppSegmented<String>(
                        value: edit.method,
                        enabled: widget.enabled,
                        options: const [
                          AppSegmentedOption(value: 'cash', label: 'Efectivo'),
                          AppSegmentedOption(
                            value: 'transfer',
                            label: 'Transfer.',
                          ),
                        ],
                        onChanged: (value) =>
                            widget.onChanged(edit.copyWith(method: value)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (row.canDeliver)
              // Entregar es una decisión aparte de cobrar, y la hoja registra
              // las dos: hay boletas que se pagan y se quedan en la lavandería.
              CheckboxListTile(
                value: edit.deliver,
                onChanged: !widget.enabled
                    ? null
                    : (value) => widget.onChanged(
                        edit.copyWith(deliver: value ?? false),
                      ),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'Entregar la ropa también',
                  style: AppTypography.bodySm.copyWith(fontSize: 13),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Qué le pasa a esta fila, en una frase.
  (AppStatusTone, String?) _status(CashIncomeRow row) {
    return switch (row.status) {
      CashIncomeStatus.matched => (AppStatusTone.success, null),
      CashIncomeStatus.amountMismatch => (
        AppStatusTone.warning,
        'El papel dice Q${Fixed2.format(row.amountRead.value ?? 0)} y la boleta '
            'debe Q${Fixed2.format(row.balance ?? 0)}. Se cobra lo que pongas, '
            'nunca más que el saldo.',
      ),
      CashIncomeStatus.notFound => (
        AppStatusTone.error,
        'Ninguna boleta lleva ese número. Revisá el dígito o buscala a mano.',
      ),
      CashIncomeStatus.unreadable => (
        AppStatusTone.error,
        'El número no se pudo leer.',
      ),
      CashIncomeStatus.settled => (
        AppStatusTone.warning,
        'Esta boleta ya está cobrada. No se vuelve a cobrar.',
      ),
      CashIncomeStatus.cancelled => (
        AppStatusTone.error,
        'Esta boleta está anulada.',
      ),
      CashIncomeStatus.supply => (
        AppStatusTone.warning,
        'Fila azul: es una venta de insumo, no una boleta. Registrala en la '
            'pantalla de venta de insumos.',
      ),
    };
  }
}
