import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/fixed2.dart';
import '../../../../core/time/business_date.dart';
import '../../../catalog/data/catalog_repository.dart';
import '../../../catalog/models/catalog.dart';
import '../../data/promotions_remote_datasource.dart';
import '../../models/promotion.dart';
import '../../state/promotions_admin_controller.dart';

/// Alta y edición de una promoción (Plan 0006 §10.3).
///
/// El **código no se edita**: es a lo que apunta cada pedido ya tomado, y
/// cambiarlo dejaría boletas hablando de una promoción que ya no existe. Lo
/// demás sí, porque una promoción se corrige antes de usarse y las boletas
/// viejas conservan su propia copia de lo que se les rebajó (D2).
class PromotionFormSheet extends ConsumerStatefulWidget {
  const PromotionFormSheet({super.key, this.promotion});

  /// `null` para crear.
  final Promotion? promotion;

  static Future<Promotion?> show(BuildContext context, {Promotion? promotion}) {
    return AppBottomSheetScaffold.show<Promotion>(
      context: context,
      builder: (context) => PromotionFormSheet(promotion: promotion),
    );
  }

  @override
  ConsumerState<PromotionFormSheet> createState() => _PromotionFormSheetState();
}

class _PromotionFormSheetState extends ConsumerState<PromotionFormSheet> {
  late final _code = TextEditingController(text: widget.promotion?.code ?? '');
  late final _name = TextEditingController(text: widget.promotion?.name ?? '');
  late final _description = TextEditingController(
    text: widget.promotion?.description ?? '',
  );
  late final _value = TextEditingController(
    text: widget.promotion == null ? '' : Fixed2.format(widget.promotion!.value),
  );

  late DiscountType _type = widget.promotion?.discountType ?? DiscountType.percentage;
  late DateTime _from = _parseDate(widget.promotion?.validFrom) ?? businessDate();
  late DateTime? _to = _parseDate(widget.promotion?.validTo);
  late Set<String> _services = {...?widget.promotion?.appliesToServiceCodes};
  late bool _isActive = widget.promotion?.isActive ?? true;

  late final Future<List<ServiceType>> _catalog =
      ref.read(catalogRepositoryProvider).services();

  String? _codeError;
  String? _nameError;
  String? _valueError;
  String? _formError;
  bool _saving = false;

  bool get _isEditing => widget.promotion != null;

  @override
  void dispose() {
    for (final controller in [_code, _name, _description, _value]) {
      controller.dispose();
    }
    super.dispose();
  }

  static DateTime? _parseDate(String? isoDate) {
    if (isoDate == null) return null;
    return DateTime.tryParse(isoDate);
  }

  /// El rótulo del monto cambia con el tipo porque el número significa cosas
  /// distintas: 50 es medio pedido, Q50 son cincuenta quetzales.
  (String, String, String) get _valueCopy => switch (_type) {
    DiscountType.percentage => (
      'PORCENTAJE',
      '50',
      'Ej. 50 rebaja la mitad de lo que suman los servicios marcados.',
    ),
    DiscountType.fixedAmount => (
      'MONTO EN QUETZALES',
      '5.00',
      'Ej. Q5.00 de menos, sin importar el tamaño del pedido.',
    ),
    DiscountType.specialPrice => (
      'PRECIO AL QUE QUEDA',
      '35.00',
      'Los servicios marcados quedan en este precio; el descuento es la diferencia.',
    ),
  };

  Future<void> _save() async {
    final code = _code.text.trim().toLowerCase();
    final name = _name.text.trim();
    final value = Fixed2.parse(_value.text);

    setState(() {
      _codeError = _isEditing || _isValidCode(code)
          ? null
          : 'Solo minúsculas, números y guion bajo, empezando por letra';
      _nameError = name.isEmpty ? 'Ponle un nombre que se lea en el chip' : null;
      _valueError = switch (value) {
        null || <= 0 => 'El valor tiene que ser mayor que cero',
        > 10000 when _type == DiscountType.percentage =>
          'Un porcentaje no puede pasar de 100',
        _ => null,
      };
      if (_to != null && _to!.isBefore(_from)) {
        _formError = 'La promoción no puede terminar antes de empezar.';
      } else {
        _formError = null;
      }
    });

    if (_codeError != null ||
        _nameError != null ||
        _valueError != null ||
        _formError != null) {
      return;
    }

    setState(() => _saving = true);

    final input = PromotionInput(
      code: code,
      name: name,
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      discountType: _type,
      value: value!,
      // Vacío significa "todo el pedido", que es como lo entiende el servidor:
      // una lista vacía no rebajaría nada y sería otra cosa.
      appliesToServiceCodes: _services.isEmpty ? null : _services.toList(),
      validFrom: isoDate(_from),
      validTo: _to == null ? null : isoDate(_to!),
      isActive: _isActive,
    );

    final controller = ref.read(promotionsAdminControllerProvider.notifier);
    final existing = widget.promotion;
    final result = existing == null
        ? await controller.create(input)
        : await controller.edit(existing.id, input);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (promotion) => Navigator.of(context).pop(promotion),
    );
  }

  static bool _isValidCode(String code) =>
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(code);

  @override
  Widget build(BuildContext context) {
    final (valueLabel, valueHint, valueHelp) = _valueCopy;
    final today = businessDate();

    return AppBottomSheetScaffold(
      title: _isEditing ? 'Editar promoción' : 'Nueva promoción',
      subtitle: 'Los pedidos ya tomados conservan lo que se les rebajó',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: _isEditing ? 'Guardar cambios' : 'Crear promoción',
              icon: const Icon(Icons.check_rounded),
              fullWidth: true,
              elevated: true,
              loading: _saving,
              onPressed: _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'CÓDIGO',
            controller: _code,
            hintText: 'domicilio_50',
            enabled: !_isEditing,
            errorText: _codeError,
            helperText: _isEditing
                ? 'No se cambia: es a lo que apuntan los pedidos ya tomados'
                : 'Con el que viaja en el pedido; no se puede cambiar después',
            prefixIcon: const Icon(Icons.tag_rounded),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NOMBRE',
            controller: _name,
            hintText: '50% en domicilio',
            errorText: _nameError,
            helperText: 'Es lo que se lee en el chip de la toma y en la boleta',
            prefixIcon: const Icon(Icons.local_offer_outlined),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'DESCRIPCIÓN',
            controller: _description,
            hintText: 'Para qué es, o hasta cuándo se pensó',
            optional: true,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text('TIPO', style: AppTypography.caption.copyWith(fontSize: 10.5)),
          const SizedBox(height: 6),
          AppSegmented<DiscountType>(
            value: _type,
            options: const [
              AppSegmentedOption(
                value: DiscountType.percentage,
                label: 'Porcentaje',
                icon: Icons.percent_rounded,
              ),
              AppSegmentedOption(
                value: DiscountType.fixedAmount,
                label: 'Monto fijo',
                icon: Icons.payments_outlined,
              ),
              AppSegmentedOption(
                value: DiscountType.specialPrice,
                label: 'Precio esp.',
                icon: Icons.sell_outlined,
              ),
            ],
            onChanged: (type) => setState(() {
              _type = type;
              _valueError = null;
            }),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: valueLabel,
            controller: _value,
            hintText: valueHint,
            errorText: _valueError,
            helperText: valueHelp,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
          ),
          const SizedBox(height: 16),
          Text(
            'SERVICIOS A LOS QUE APLICA',
            style: AppTypography.caption.copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 6),
          _ServicePicker(
            catalog: _catalog,
            selected: _services,
            onChanged: (codes) => setState(() => _services = codes),
          ),
          const SizedBox(height: 16),
          Text('VIGENCIA', style: AppTypography.caption.copyWith(fontSize: 10.5)),
          const SizedBox(height: 6),
          AppDateField(
            value: _from,
            today: today,
            onChanged: (date) => setState(() {
              _from = date;
              _formError = null;
            }),
          ),
          const SizedBox(height: 10),
          _UntilField(
            value: _to,
            today: today,
            onChanged: (date) => setState(() {
              _to = date;
              _formError = null;
            }),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              activeThumbColor: AppColors.primary500,
              title: Text(
                'Activa',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Apagada no se ofrece en la toma, aunque esté dentro de sus fechas',
                style: AppTypography.helper.copyWith(fontSize: 11.5),
              ),
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
          if (_formError != null) ...[
            const SizedBox(height: 14),
            _FormError(message: _formError!),
          ],
        ],
      ),
    );
  }
}

/// Los servicios a los que muerde la promoción. Ninguno marcado = el pedido
/// entero, y eso se dice en voz alta en vez de dejarlo a la intuición.
class _ServicePicker extends StatelessWidget {
  const _ServicePicker({
    required this.catalog,
    required this.selected,
    required this.onChanged,
  });

  final Future<List<ServiceType>> catalog;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceType>>(
      future: catalog,
      builder: (context, snapshot) {
        final services = snapshot.data;
        if (services == null) {
          return Text(
            'Cargando servicios…',
            style: AppTypography.helper.copyWith(fontSize: 12),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final service in services)
                  AppChip(
                    label: service.name,
                    selected: selected.contains(service.code),
                    onTap: () {
                      final next = Set<String>.from(selected);
                      if (!next.remove(service.code)) next.add(service.code);
                      onChanged(next);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              selected.isEmpty
                  ? 'Sin ninguno marcado, aplica a todo el pedido.'
                  : 'Aplica solo sobre estos ${selected.length} servicios.',
              style: AppTypography.helper.copyWith(fontSize: 11.5),
            ),
          ],
        );
      },
    );
  }
}

/// La fecha de fin, que puede no existir: una promoción abierta corre hasta que
/// alguien la apague.
class _UntilField extends StatelessWidget {
  const _UntilField({
    required this.value,
    required this.today,
    required this.onChanged,
  });

  final DateTime? value;
  final DateTime today;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AppButton(
          label: 'Ponerle fecha de fin',
          variant: AppButtonVariant.ghost,
          icon: const Icon(Icons.event_busy_outlined),
          onPressed: () => onChanged(today),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppDateField(
            value: value!,
            today: today,
            onChanged: onChanged,
          ),
        ),
        IconButton(
          onPressed: () => onChanged(null),
          icon: const Icon(Icons.close_rounded),
          color: AppColors.gray500,
          tooltip: 'Sin fecha de fin',
        ),
      ],
    );
  }
}

class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.errorText),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.errorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
