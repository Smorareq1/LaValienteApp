import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/fixed2.dart';
import '../../../../core/time/business_date.dart';
import '../../models/catalog_admin.dart';
import '../../state/catalog_admin_controller.dart';

/// Nuevo precio de un servicio (Plan 0006 §10.1).
///
/// No edita el vigente: abre una **ventana nueva** desde una fecha, y el
/// servidor cierra la anterior el día antes (plan 0001 D1). Es el mismo patrón
/// que la tarifa de hora extra, y por la misma razón: una boleta de la semana
/// pasada tiene que seguir valiendo lo que valía esa semana.
class PriceFormSheet extends ConsumerStatefulWidget {
  const PriceFormSheet({super.key, required this.service, this.option});

  final AdminService service;

  /// La opción a la que se le pone precio, en un servicio por tramos.
  final AdminServiceOption? option;

  static Future<AdminPrice?> show(
    BuildContext context, {
    required AdminService service,
    AdminServiceOption? option,
  }) {
    return AppBottomSheetScaffold.show<AdminPrice>(
      context: context,
      builder: (context) => PriceFormSheet(service: service, option: option),
    );
  }

  @override
  ConsumerState<PriceFormSheet> createState() => _PriceFormSheetState();
}

class _PriceFormSheetState extends ConsumerState<PriceFormSheet> {
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

  int? get _currentPrice => widget.option?.currentPrice ?? widget.service.currentPrice;

  Future<void> _save() async {
    final amount = Fixed2.parse(_amount.text);

    setState(() {
      // Cero se acepta: un servicio de cortesía es un precio, no un hueco. Lo
      // que no se acepta es que no haya número.
      _amountError = switch (amount) {
        null || < 0 => 'Escribe el precio, aunque sea cero',
        _ => null,
      };
    });
    if (_amountError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final result = await ref
        .read(priceRegistrarProvider.notifier)
        .register(
          widget.service.id,
          amount: amount!,
          validFrom: isoDate(_from),
          optionId: widget.option?.id,
        );

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (price) => Navigator.of(context).pop(price),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentPrice;

    return AppBottomSheetScaffold(
      title: widget.option == null
          ? 'Nuevo precio de ${widget.service.name}'
          : 'Nuevo precio de ${widget.option!.name}',
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
              label: 'Registrar precio',
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
          if (current != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: AppRadius.mdAll,
              ),
              child: Text(
                'Hoy se cobra Q${Fixed2.format(current)}.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.primary700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          AppFormField(
            label: 'PRECIO',
            controller: _amount,
            hintText: '12.50',
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
            today: businessDate(),
            onChanged: (picked) => setState(() => _from = picked),
            helpText: 'Desde cuándo se cobra así',
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
              'Los pedidos ya tomados no cambian: cada boleta guardó el precio '
              'del día en que se capturó.',
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
