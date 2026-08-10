import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/fixed2.dart';
import '../../../../core/time/business_date.dart';
import '../../models/staff.dart';
import '../../state/staff_admin_controller.dart';

/// Nueva tarifa de hora extra (Plan 0006 §9.3).
///
/// No se edita la vigente: se **abre una ventana nueva** desde una fecha, y el
/// servidor cierra la anterior el día anterior (plan 0005 D7). Es el mismo
/// patrón que los precios del catálogo, y por la misma razón: una jornada de la
/// semana pasada tiene que seguir valiendo lo que valía esa semana.
class RateFormSheet extends ConsumerStatefulWidget {
  const RateFormSheet({super.key, this.current});

  /// La tarifa vigente, si la hay. Solo para mostrar de qué se viene.
  final PayrollRate? current;

  static Future<PayrollRate?> show(BuildContext context, {PayrollRate? current}) {
    return AppBottomSheetScaffold.show<PayrollRate>(
      context: context,
      builder: (context) => RateFormSheet(current: current),
    );
  }

  @override
  ConsumerState<RateFormSheet> createState() => _RateFormSheetState();
}

class _RateFormSheetState extends ConsumerState<RateFormSheet> {
  final _amount = TextEditingController();

  DateTime _from = businessDate();

  String? _amountError;
  String? _formError;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = Fixed2.parse(_amount.text);

    setState(() {
      _amountError = switch (amount) {
        null || <= 0 => 'La tarifa tiene que ser mayor que cero',
        _ => null,
      };
    });
    if (_amountError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final result = await ref
        .read(overtimeRatesControllerProvider.notifier)
        .register(amount: amount!, validFrom: isoDate(_from));

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (rate) => Navigator.of(context).pop(rate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = businessDate();

    return AppBottomSheetScaffold(
      title: 'Nueva tarifa de hora extra',
      subtitle: 'Se guarda en el servidor: esta pantalla necesita señal.',
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
              label: 'Registrar tarifa',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        // El scroll lo hace la sheet; ver AppBottomSheetScaffold.
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        children: [
          if (widget.current != null) _CurrentNote(rate: widget.current!),
          if (widget.current != null) const SizedBox(height: 14),
          AppFormField(
            label: 'MONTO POR HORA',
            controller: _amount,
            hintText: '20.00',
            errorText: _amountError,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 4),
              child: Text('Q'),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          Text('VIGENTE DESDE', style: AppTypography.label),
          const SizedBox(height: 7),
          AppDateField(
            value: _from,
            today: today,
            onChanged: (picked) => setState(() => _from = picked),
            helpText: 'Desde cuándo se paga así',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.mdAll,
            ),
            child: Text(
              'La tarifa que esté vigente se cierra el día anterior. La hora extra '
              'que ya se pagó conserva su monto: el gasto lo dejó escrito.',
              style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
            ),
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

class _CurrentNote extends StatelessWidget {
  const _CurrentNote({required this.rate});

  final PayrollRate rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        'Hoy se paga Q${Fixed2.format(rate.amount)} la hora, desde el '
        '${rate.validFrom}.',
        style: AppTypography.bodySm.copyWith(
          color: AppColors.primary700,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
