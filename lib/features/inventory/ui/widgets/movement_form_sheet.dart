import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/fixed2.dart';
import '../../data/inventory_remote_datasource.dart';
import '../../models/product.dart';
import '../../state/inventory_admin_controller.dart';

/// Movimiento manual de stock (Plan 0006 §8.5).
///
/// Solo dos tipos se teclean: **uso interno** —lo que la lavandería se gasta— y
/// **ajuste** —lo que el conteo no cuadró—. Una compra sale de registrar un lote
/// y una venta de vender; dejarlas escribir aquí metería stock en el kardex sin
/// ningún documento detrás (plan 0005 D4).
class MovementFormSheet extends ConsumerStatefulWidget {
  const MovementFormSheet({
    super.key,
    required this.product,
    required this.lots,
  });

  final ProductSummary product;

  /// Los lotes con existencia. Un lote agotado no admite salidas.
  final List<ProductLot> lots;

  static Future<bool?> show(
    BuildContext context, {
    required ProductSummary product,
    required List<ProductLot> lots,
  }) {
    return AppBottomSheetScaffold.show<bool>(
      context: context,
      builder: (context) => MovementFormSheet(product: product, lots: lots),
    );
  }

  @override
  ConsumerState<MovementFormSheet> createState() => _MovementFormSheetState();
}

class _MovementFormSheetState extends ConsumerState<MovementFormSheet> {
  final _quantity = TextEditingController();
  final _notes = TextEditingController();

  MovementType _type = MovementType.internalUse;
  late String? _lotId = widget.lots.firstOrNull?.id;

  /// Solo para el ajuste: si el conteo salió corto o sobrado.
  bool _isShortage = true;

  String? _quantityError;
  String? _notesError;
  String? _formError;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _isAdjustment => _type == MovementType.adjustment;

  Future<void> _save() async {
    final quantity = Fixed2.parse(_quantity.text);
    final notes = _notes.text.trim();
    final lotId = _lotId;

    setState(() {
      _quantityError = switch (quantity) {
        null || <= 0 => 'Cuánto se movió, en ${widget.product.unit}',
        _ => null,
      };
      // El «¿por qué?» es obligatorio en un ajuste: un número que aparece o
      // desaparece sin explicación es justo lo que la hoja de papel no podía
      // responder.
      _notesError = _isAdjustment && notes.isEmpty
          ? '¿Por qué no cuadró? Sin esto el ajuste no se puede explicar'
          : null;
      _formError = lotId == null ? 'No hay ningún lote con existencia.' : null;
    });

    if (_quantityError != null || _notesError != null || _formError != null) {
      return;
    }

    setState(() => _saving = true);

    final result = await ref
        .read(inventoryAdminControllerProvider.notifier)
        .recordMovement(
          MovementInput(
            lotId: lotId!,
            type: _type,
            // El signo solo existe en el ajuste. Los demás tipos lo llevan en
            // el nombre, y el servidor rechaza un negativo ahí.
            quantity: _isAdjustment && _isShortage ? -quantity! : quantity!,
            notes: notes.isEmpty ? null : notes,
          ),
        );

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Mover ${widget.product.name}',
      subtitle: 'Queda una línea en el kardex con quién y cuándo.',
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
              label: 'Registrar',
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
          Text('TIPO', style: AppTypography.label),
          const SizedBox(height: 7),
          AppSegmented<MovementType>(
            value: _type,
            onChanged: (value) => setState(() => _type = value),
            options: [
              for (final type in MovementType.manual)
                AppSegmentedOption(value: type, label: type.label),
            ],
          ),
          const SizedBox(height: 14),
          Text('LOTE', style: AppTypography.label),
          const SizedBox(height: 7),
          if (widget.lots.isEmpty)
            const _Note(
              message:
                  'Este producto no tiene lotes con existencia. Un movimiento '
                  'sale de un lote, así que primero hay que registrar la compra.',
            )
          else
            _LotPicker(
              lots: widget.lots,
              unit: widget.product.unit,
              value: _lotId,
              onChanged: (id) => setState(() => _lotId = id),
            ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'CANTIDAD',
            controller: _quantity,
            hintText: '2',
            errorText: _quantityError,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                widget.product.unit,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          if (_isAdjustment) ...[
            const SizedBox(height: 12),
            Text('EL CONTEO SALIÓ', style: AppTypography.label),
            const SizedBox(height: 7),
            AppSegmented<bool>(
              value: _isShortage,
              onChanged: (value) => setState(() => _isShortage = value),
              options: const [
                AppSegmentedOption(value: true, label: 'Corto'),
                AppSegmentedOption(value: false, label: 'Sobrado'),
              ],
            ),
          ],
          const SizedBox(height: 14),
          AppFormField(
            label: _isAdjustment ? '¿POR QUÉ?' : 'NOTAS',
            controller: _notes,
            optional: !_isAdjustment,
            maxLines: 2,
            errorText: _notesError,
            hintText: _isAdjustment
                ? 'Se rompió un bote al bajarlo del estante.'
                : 'Para qué se usó.',
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

class _LotPicker extends StatelessWidget {
  const _LotPicker({
    required this.lots,
    required this.unit,
    required this.value,
    required this.onChanged,
  });

  final List<ProductLot> lots;
  final String unit;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          items: [
            for (final lot in lots)
              DropdownMenuItem<String?>(
                value: lot.id,
                child: Text(
                  'Lote ${lot.lotNumber} · quedan '
                  '${Fixed2.formatQuantity(lot.quantityAvailable)} $unit',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        message,
        style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
