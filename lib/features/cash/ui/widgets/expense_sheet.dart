import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/money/fixed2.dart';
import '../../../../core/money/payment_method.dart';
import '../../../../core/time/business_date.dart';
import '../../data/expenses_repository.dart';
import '../../models/expense.dart';

/// Anotar un gasto, o corregir uno ya anotado (Plan 0006 §7.2).
///
/// La fecha se puede mover porque la hoja de papel también se llena a
/// destiempo: alguien pagó el gas ayer y lo anota hoy. El servidor rechaza la de
/// un día ya cerrado, así que el calendario no deja pasar de hoy y la pantalla
/// de Caja ya bloquea el botón cuando la fecha que se está mirando está cerrada.
class ExpenseSheet extends StatefulWidget {
  const ExpenseSheet({
    super.key,
    required this.categories,
    required this.date,
    this.initial,
  });

  final List<ExpenseCategory> categories;

  /// El día que la Caja está mirando; con el que abre el formulario.
  final DateTime date;

  /// El gasto que se está corrigiendo, si se está corrigiendo alguno.
  final Expense? initial;

  /// Abre la sheet y devuelve lo capturado, o `null` si se canceló.
  static Future<ExpenseDraft?> show(
    BuildContext context, {
    required List<ExpenseCategory> categories,
    required DateTime date,
    Expense? initial,
  }) {
    return AppBottomSheetScaffold.show<ExpenseDraft>(
      context: context,
      builder: (context) =>
          ExpenseSheet(categories: categories, date: date, initial: initial),
    );
  }

  @override
  State<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<ExpenseSheet> {
  late final TextEditingController _concept = TextEditingController(
    text: widget.initial?.concept ?? '',
  );
  late final TextEditingController _amount = TextEditingController(
    text: widget.initial == null ? '' : Fixed2.format(widget.initial!.amount),
  );
  late final TextEditingController _observations = TextEditingController(
    text: widget.initial?.observations ?? '',
  );

  late DateTime _date =
      parseIsoDate(widget.initial?.expenseDate ?? '') ?? widget.date;
  late String? _categoryId = widget.initial?.categoryId ?? _firstCategoryId();
  late PaymentMethod _method = widget.initial?.method ?? PaymentMethod.cash;
  late bool _isPending = widget.initial?.isPending ?? false;

  String? _conceptError;
  String? _amountError;
  bool _categoryMissing = false;

  bool get _isEditing => widget.initial != null;

  String? _firstCategoryId() =>
      widget.categories.isEmpty ? null : widget.categories.first.id;

  @override
  void dispose() {
    _concept.dispose();
    _amount.dispose();
    _observations.dispose();
    super.dispose();
  }

  void _confirm() {
    final concept = _concept.text.trim();
    final amount = Fixed2.parse(_amount.text) ?? 0;
    final categoryId = _categoryId;

    setState(() {
      _conceptError = concept.isEmpty ? 'Escribí en qué se gastó' : null;
      _amountError = amount <= 0 ? 'Escribí cuánto se gastó' : null;
      _categoryMissing = categoryId == null;
    });
    if (_conceptError != null || _amountError != null || categoryId == null) return;

    Navigator.of(context).pop(
      ExpenseDraft(
        expenseDate: isoDate(_date),
        categoryId: categoryId,
        concept: concept,
        amount: amount,
        method: _method,
        status: _isPending ? ExpenseStatus.pending : ExpenseStatus.paid,
        observations: _observations.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = businessDate();

    return AppBottomSheetScaffold(
      title: _isEditing ? 'Corregir el gasto' : 'Registrar gasto',
      subtitle: _isEditing
          ? 'Queda el rastro de la corrección'
          : 'Sale de la caja del día',
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
              label: _isEditing ? 'Guardar' : 'Registrar',
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
          Text('FECHA', style: AppTypography.label),
          const SizedBox(height: 7),
          AppDateField(
            value: _date,
            today: today,
            // Un gasto de mañana no existe: nadie paga por adelantado un día que
            // no ha ocurrido, y el servidor lo rechazaría.
            lastDate: today,
            helpText: 'Día del gasto',
            onChanged: (picked) => setState(() => _date = picked),
          ),
          const SizedBox(height: 14),
          Text('CATEGORÍA', style: AppTypography.label),
          const SizedBox(height: 7),
          if (widget.categories.isEmpty)
            const _NoCategories()
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final category in widget.categories)
                  AppChip(
                    label: category.name,
                    selected: category.id == _categoryId,
                    onTap: () => setState(() {
                      _categoryId = category.id;
                      _categoryMissing = false;
                    }),
                  ),
              ],
            ),
          if (_categoryMissing) ...[
            const SizedBox(height: 6),
            Text(
              'Elegí la categoría',
              style: AppTypography.helper.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 14),
          AppFormField(
            label: 'CONCEPTO',
            controller: _concept,
            hintText: 'Gas — 2 sacos',
            errorText: _conceptError,
            onChanged: (_) => setState(() => _conceptError = null),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'MONTO',
            controller: _amount,
            hintText: 'Q 0.00',
            errorText: _amountError,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
            onChanged: (_) => setState(() => _amountError = null),
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
          const SizedBox(height: 14),
          _PendingSwitch(
            value: _isPending,
            onChanged: (value) => setState(() => _isPending = value),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'OBSERVACIONES',
            controller: _observations,
            hintText: 'Lo que haga falta recordar',
            maxLines: 3,
            optional: true,
          ),
        ],
      ),
    );
  }
}

/// El «pago atrasado» de la hoja: el gasto cuenta contra el día y el dinero
/// sigue en el cajón. Es un interruptor y no un segmentado porque lo normal, con
/// diferencia, es que ya se haya pagado.
class _PendingSwitch extends StatelessWidget {
  const _PendingSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 9, 9, 9),
      decoration: BoxDecoration(
        color: value ? AppColors.warningBg : AppColors.gray50,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Queda pendiente de pago',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: value ? AppColors.warningText : AppColors.textPrimary,
                  ),
                ),
                Text(
                  value
                      ? 'Cuenta en el día, pero no salió del cajón'
                      : 'El dinero ya salió de la caja',
                  style: AppTypography.helper.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.warning,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NoCategories extends StatelessWidget {
  const _NoCategories();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        'Este teléfono todavía no bajó las categorías de gasto. Sincronizá y '
        'volvé a intentarlo.',
        style: AppTypography.bodySm.copyWith(
          fontSize: 12.5,
          color: AppColors.warningText,
        ),
      ),
    );
  }
}
