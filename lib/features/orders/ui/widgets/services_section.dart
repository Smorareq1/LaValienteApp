import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/money/fixed2.dart';
import '../../../catalog/models/catalog.dart';
import '../../domain/order_pricing.dart';
import '../../state/order_capture_controller.dart';
import 'capture_section.dart';

/// Sección [5] de la boleta: qué se le hace a la ropa (plan 0002 §3.5).
///
/// La lista se pinta **desde el catálogo**, no desde una lista escrita a mano:
/// agregar un servicio en la administración lo hace aparecer aquí sin tocar la
/// app. Lo único que decide el código es el control, y lo decide por modalidad
/// de cobro — escalonado se cuenta por opción, variable se teclea, el resto es
/// un stepper.
class ServicesSection extends StatelessWidget {
  const ServicesSection({
    super.key,
    required this.services,
    required this.book,
    required this.quantities,
    required this.variableAmounts,
    required this.washByWeight,
    required this.weightText,
    required this.onServiceChanged,
    required this.onVariableChanged,
    required this.onWashByWeightChanged,
    required this.onWeightChanged,
  });

  final List<ServiceType> services;
  final OrderPriceBook book;
  final Map<String, int> quantities;
  final Map<String, String> variableAmounts;
  final bool washByWeight;
  final String weightText;

  final void Function(String serviceCode, String? optionCode, int quantity) onServiceChanged;
  final void Function(String serviceCode, String amount) onVariableChanged;
  final ValueChanged<bool> onWashByWeightChanged;
  final ValueChanged<String> onWeightChanged;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        'El catálogo de servicios todavía no ha bajado a este dispositivo. '
        'Sincronizá y volvé a intentar.',
        style: AppTypography.helper.copyWith(fontSize: 12),
      );
    }

    final blocks = <Widget>[];

    for (final service in services) {
      if (service.code == kWashByWeightCode) {
        blocks.add(
          _WashByWeight(
            service: service,
            unitPrice: book.unitPrice(service, null),
            enabled: washByWeight,
            weightText: weightText,
            onEnabledChanged: onWashByWeightChanged,
            onWeightChanged: onWeightChanged,
          ),
        );
        continue;
      }

      switch (service.pricingMode) {
        case PricingMode.variable:
          blocks.add(
            _VariableService(
              service: service,
              amount: variableAmounts[service.code] ?? '',
              onChanged: (value) => onVariableChanged(service.code, value),
            ),
          );
        case PricingMode.tiered:
          blocks.add(
            _ServiceGroup(
              title: service.name,
              rows: [
                for (final option in service.options)
                  _CountedRow(
                    key: ValueKey('${service.code}/${option.code}'),
                    title: option.name,
                    detail: _detail(
                      book.unitPrice(service, option),
                      quantities[serviceKey(service.code, option.code)] ?? 0,
                      service.unitLabel,
                    ),
                    quantity: quantities[serviceKey(service.code, option.code)] ?? 0,
                    onChanged: (value) =>
                        onServiceChanged(service.code, option.code, value),
                  ),
              ],
            ),
          );
        case PricingMode.perUnit:
          blocks.add(
            _ServiceGroup(
              rows: [
                _CountedRow(
                  key: ValueKey(service.code),
                  title: service.name,
                  detail: _detail(
                    book.unitPrice(service, null),
                    quantities[serviceKey(service.code)] ?? 0,
                    service.unitLabel,
                  ),
                  quantity: quantities[serviceKey(service.code)] ?? 0,
                  onChanged: (value) => onServiceChanged(service.code, null, value),
                ),
              ],
            ),
          );
        case null:
          // Modalidad desconocida: se dice, no se dibuja un control inventado.
          blocks.add(
            CaptureNotice(
              message:
                  '${service.name} llegó con una forma de cobro que esta versión '
                  'de la app no conoce. Actualizá para poder usarlo.',
            ),
          );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final block in blocks)
          Padding(padding: const EdgeInsets.only(bottom: 10), child: block),
      ],
    );
  }

  /// `Q10.00 c/u` cuando está en cero, `2 × Q10.00 = Q20.00` cuando ya se contó.
  ///
  /// El cambio de texto es lo que hace visible el cálculo mientras se captura:
  /// nadie tiene que multiplicar de cabeza para revisar la línea.
  static String _detail(int? unitPrice, int quantity, String? unitLabel) {
    if (unitPrice == null) return 'Sin precio vigente';
    final unit = 'Q${Fixed2.format(unitPrice)}';
    if (quantity <= 0) {
      return unitLabel == null ? '$unit c/u' : '$unit por $unitLabel';
    }
    final amount = Fixed2.multiply(unitPrice, quantity * 100);
    return '$quantity × $unit = Q${Fixed2.format(amount)}';
  }
}

class _ServiceGroup extends StatelessWidget {
  const _ServiceGroup({required this.rows, this.title});

  final String? title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) CaptureLabel(title!.toUpperCase()),
        ...rows,
      ],
    );
  }
}

class _CountedRow extends StatelessWidget {
  const _CountedRow({
    super.key,
    required this.title,
    required this.detail,
    required this.quantity,
    required this.onChanged,
  });

  final String title;
  final String detail;
  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Los servicios se marcan en cian y las prendas en magenta: son las dos
    // mitades de la boleta y el color las separa sin necesidad de leer.
    final active = quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.secondary50 : AppColors.gray50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: active ? AppColors.secondary300 : AppColors.gray100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.secondary700 : AppColors.textPrimary,
                  ),
                ),
                Text(detail, style: AppTypography.helper.copyWith(fontSize: 11.5)),
              ],
            ),
          ),
          AppStepper(value: quantity, size: AppStepperSize.md, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Lavado por peso: el interruptor y las libras, que son el mismo número que el
/// encabezado (§3.1). Se editan aquí y allá porque en la boleta de papel el peso
/// también está escrito dos veces.
class _WashByWeight extends StatefulWidget {
  const _WashByWeight({
    required this.service,
    required this.unitPrice,
    required this.enabled,
    required this.weightText,
    required this.onEnabledChanged,
    required this.onWeightChanged,
  });

  final ServiceType service;
  final int? unitPrice;
  final bool enabled;
  final String weightText;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onWeightChanged;

  @override
  State<_WashByWeight> createState() => _WashByWeightState();
}

class _WashByWeightState extends State<_WashByWeight> {
  late final TextEditingController _weight =
      TextEditingController(text: widget.weightText);

  @override
  void didUpdateWidget(_WashByWeight oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El peso también se teclea en el encabezado; si vino de allá, este campo se
    // pone al día. La comparación evita reescribirlo mientras alguien escribe
    // aquí, que le movería el cursor.
    if (widget.weightText != _weight.text) _weight.text = widget.weightText;
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.unitPrice;
    final lbs = Fixed2.parse(widget.weightText) ?? 0;
    final line = price == null || !widget.enabled
        ? null
        : Fixed2.multiply(price, lbs);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: widget.enabled ? AppColors.secondary50 : AppColors.gray50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: widget.enabled ? AppColors.secondary300 : AppColors.gray100,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.name,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: widget.enabled
                            ? AppColors.secondary700
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      price == null
                          ? 'Sin precio vigente'
                          : 'Q${Fixed2.format(price)} por libra',
                      style: AppTypography.helper.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.enabled,
                activeTrackColor: AppColors.secondary500,
                inactiveTrackColor: AppColors.gray200,
                thumbColor: const WidgetStatePropertyAll(AppColors.white),
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
                onChanged: widget.onEnabledChanged,
              ),
            ],
          ),
          if (widget.enabled) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _weight,
                    hintText: 'Libras',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                    onChanged: widget.onWeightChanged,
                  ),
                ),
                const SizedBox(width: 10),
                if (line != null)
                  AppMoneyText(Fixed2.toDouble(line), size: AppMoneySize.lg),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Servicio `variable`: recepción y entrega, donde el monto es lo que cobró el
/// motorista y no sale de ningún catálogo.
class _VariableService extends StatefulWidget {
  const _VariableService({
    required this.service,
    required this.amount,
    required this.onChanged,
  });

  final ServiceType service;
  final String amount;
  final ValueChanged<String> onChanged;

  @override
  State<_VariableService> createState() => _VariableServiceState();
}

class _VariableServiceState extends State<_VariableService> {
  late final TextEditingController _amount = TextEditingController(text: widget.amount);

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.service.name,
            style: AppTypography.bodySm.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 130,
          child: AppTextField(
            controller: _amount,
            hintText: 'Q 0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
