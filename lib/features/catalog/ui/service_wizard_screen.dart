import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/catalog.dart';
import '../models/catalog_admin.dart';
import '../state/catalog_admin_controller.dart';

/// Crear un servicio desde cero (Plan 0006 §10.1).
///
/// Un asistente y no una sheet porque son **tres decisiones encadenadas**: qué
/// es, en qué tramos se divide y cuánto cuesta cada uno. Y sobre todo porque no
/// puede terminar a medias: `POST /catalog/service-types` no acepta precios —un
/// precio es una ventana con fecha (plan 0001 D1) y se registra aparte—, así que
/// un formulario de un solo paso dejaría servicios mudos, que el motor de
/// precios cuenta como faltantes y el servidor rechaza al guardar un pedido.
///
/// **El código y la modalidad se deciden aquí y ya no se tocan.** El código es a
/// lo que apuntarán los pedidos y la modalidad es cómo se cobra: cambiarla
/// dejaría boletas viejas calculadas con una regla que ya no existe. Por eso el
/// paso 1 avisa de eso mientras se escriben.
class ServiceWizardScreen extends ConsumerStatefulWidget {
  const ServiceWizardScreen({super.key});

  static const String path = '/catalog/services/new';

  @override
  ConsumerState<ServiceWizardScreen> createState() =>
      _ServiceWizardScreenState();
}

class _ServiceWizardScreenState extends ConsumerState<ServiceWizardScreen> {
  int _step = 0;

  // Paso 1.
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _unitLabel = TextEditingController();
  PricingMode _mode = PricingMode.perUnit;

  // Paso 2: los tramos, cada uno con sus controladores.
  final List<_OptionDraft> _options = [_OptionDraft()];

  // Paso 3: precios por código de opción, `null` para el del propio servicio.
  final Map<String?, TextEditingController> _prices = {
    null: TextEditingController(),
  };
  DateTime _validFrom = businessDate();

  String? _codeError;
  String? _nameError;
  String? _stepError;
  bool _saving = false;

  /// Un servicio de precio variable no tiene precio que registrar, así que su
  /// asistente son dos pasos y no tres.
  bool get _needsPrices => _mode != PricingMode.variable;
  bool get _isTiered => _mode == PricingMode.tiered;

  List<int> get _steps => [
    0,
    if (_isTiered) 1,
    if (_needsPrices) 2,
  ];

  int get _position => _steps.indexOf(_step) + 1;

  @override
  void dispose() {
    for (final controller in [_code, _name, _unitLabel]) {
      controller.dispose();
    }
    for (final option in _options) {
      option.dispose();
    }
    for (final price in _prices.values) {
      price.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- validación

  bool _validateIdentity() {
    final code = _code.text.trim();
    final name = _name.text.trim();

    setState(() {
      _codeError = switch (code) {
        '' => 'Ponle un código',
        _ when !NewService.codePattern.hasMatch(code) =>
          'Minúsculas, números y guion bajo; empieza con letra. Así: '
              'tinas_grandes',
        _ when code.length > 50 => 'Máximo 50 caracteres',
        _ => null,
      };
      _nameError = name.isEmpty ? 'Ponle un nombre' : null;
    });

    return _codeError == null && _nameError == null;
  }

  bool _validateOptions() {
    var ok = true;
    final seen = <String>{};

    setState(() {
      for (final option in _options) {
        final code = option.code.text.trim();
        final name = option.name.text.trim();
        final min = int.tryParse(option.min.text.trim());
        final max = int.tryParse(option.max.text.trim());

        option.codeError = switch (code) {
          '' => 'Falta el código',
          _ when !NewService.optionCodePattern.hasMatch(code) =>
            'Solo letras y números, hasta 20',
          _ when !seen.add(code) => 'Ese código ya está en otro tramo',
          _ => null,
        };
        option.nameError = name.isEmpty ? 'Falta el nombre' : null;
        // El servidor rechaza el rango invertido; decirlo aquí ahorra el viaje.
        option.rangeError = min != null && max != null && min > max
            ? 'El mínimo no puede ser mayor que el máximo'
            : null;

        if (option.codeError != null ||
            option.nameError != null ||
            option.rangeError != null) {
          ok = false;
        }
      }
      // Lo que falle se dice bajo su campo (§14), así que el aviso de pie sobra.
      _stepError = null;
    });

    return ok;
  }

  bool _validatePrices() {
    var ok = true;
    setState(() {
      for (final entry in _priceTargets) {
        final controller = _prices[entry.$1]!;
        final amount = Fixed2.parse(controller.text);
        // Cero se acepta —un servicio de cortesía es un precio— pero vacío no:
        // es justo el hueco que deja un servicio que no se puede cobrar.
        if (amount == null || amount < 0) ok = false;
      }
      _stepError = ok
          ? null
          : 'Falta el precio de algo. Sin precio nadie puede cobrarlo.';
    });
    return ok;
  }

  /// A qué hay que ponerle precio: el servicio, o cada uno de sus tramos.
  List<(String?, String)> get _priceTargets => _isTiered
      ? [
          for (final option in _options)
            (
              option.code.text.trim(),
              option.name.text.trim().isEmpty
                  ? option.code.text.trim()
                  : option.name.text.trim(),
            ),
        ]
      : [(null, _name.text.trim())];

  // ------------------------------------------------------------- navegación

  void _next() {
    final valid = switch (_step) {
      0 => _validateIdentity(),
      1 => _validateOptions(),
      _ => true,
    };
    if (!valid) return;

    final steps = _steps;
    final at = steps.indexOf(_step);
    if (at + 1 < steps.length) {
      setState(() {
        _step = steps[at + 1];
        _stepError = null;
        // Los campos de precio se crean al llegar al paso 3, cuando ya se sabe
        // cuántos tramos hay y cómo se llaman.
        if (_step == 2 && _isTiered) _syncPriceControllers();
      });
      return;
    }
    _save();
  }

  void _back() {
    final steps = _steps;
    final at = steps.indexOf(_step);
    if (at == 0) {
      context.pop();
      return;
    }
    setState(() {
      _step = steps[at - 1];
      _stepError = null;
    });
  }

  void _syncPriceControllers() {
    final codes = {for (final option in _options) option.code.text.trim()};
    for (final code in codes) {
      _prices.putIfAbsent(code, TextEditingController.new);
    }
    // Un tramo que se borró se lleva su campo: dejarlo mandaría un precio para
    // una opción que no existe.
    for (final key in _prices.keys.toList()) {
      if (key != null && !codes.contains(key)) {
        _prices.remove(key)!.dispose();
      }
    }
  }

  // ------------------------------------------------------------------ guardar

  Future<void> _save() async {
    if (_needsPrices && !_validatePrices()) return;

    setState(() {
      _saving = true;
      _stepError = null;
    });

    final unitLabel = _unitLabel.text.trim();
    final input = NewService(
      code: _code.text.trim(),
      name: _name.text.trim(),
      pricingMode: _mode,
      unitLabel: _mode == PricingMode.perUnit && unitLabel.isNotEmpty
          ? unitLabel
          : null,
      options: !_isTiered
          ? const []
          : [
              for (final (index, option) in _options.indexed)
                NewServiceOption(
                  code: option.code.text.trim(),
                  name: option.name.text.trim(),
                  minQuantity: int.tryParse(option.min.text.trim()),
                  maxQuantity: int.tryParse(option.max.text.trim()),
                  sortOrder: index,
                ),
            ],
    );

    final prices = <String?, int>{
      if (_needsPrices)
        for (final (code, _) in _priceTargets)
          if (Fixed2.parse(_prices[code]?.text) case final int amount)
            code: amount,
    };

    final result = await ref
        .read(serviceCreatorProvider.notifier)
        .create(input, prices: prices, validFrom: isoDate(_validFrom));

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _stepError = failure.message;
      }),
      (creation) {
        // El messenger se toma **antes** de navegar: después el contexto del
        // asistente ya está desmontado y buscarlo desde ahí revienta.
        final messenger = ScaffoldMessenger.of(context);
        // Se reemplaza en vez de apilar: volver desde el detalle tiene que
        // llevar al catálogo, no al asistente de algo ya creado.
        context.pushReplacement('/catalog/services/${creation.service.id}');
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              creation.isComplete
                  ? '${creation.service.name} ya se puede cobrar.'
                  : 'Se creó ${creation.service.name}, pero quedó sin precio: '
                        '${creation.unpriced.join(", ")}. Ponlo aquí antes de '
                        'ofrecerlo.',
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------- vista

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(position: _position, total: _steps.length, onBack: _back),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                switch (_step) {
                  0 => _identityStep(),
                  1 => _optionsStep(),
                  _ => _pricesStep(),
                },
                if (_stepError != null) ...[
                  const SizedBox(height: 16),
                  _Banner(message: _stepError!, tone: _BannerTone.error),
                ],
              ],
            ),
          ),
          _Footer(
            label: _position == _steps.length ? 'Crear servicio' : 'Siguiente',
            saving: _saving,
            onBack: _saving ? null : _back,
            onNext: _saving ? null : _next,
            backLabel: _position == 1 ? 'Cancelar' : 'Atrás',
          ),
        ],
      ),
    );
  }

  Widget _identityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(
          title: 'Qué se cobra',
          message:
              'El código y la modalidad se deciden ahora y no se cambian '
              'después: los pedidos ya tomados apuntan a ellos.',
        ),
        const SizedBox(height: 16),
        AppFormField(
          label: 'CÓDIGO',
          controller: _code,
          hintText: 'tinas_grandes',
          errorText: _codeError,
          helperText: 'Interno, para el sistema. No se ve al tomar un pedido.',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AppFormField(
          label: 'NOMBRE',
          controller: _name,
          hintText: 'Tinas grandes',
          errorText: _nameError,
          helperText: 'Esto es lo que se lee en la boleta y en la app.',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 18),
        Text('CÓMO SE COBRA', style: AppTypography.label),
        const SizedBox(height: 7),
        AppSegmented<PricingMode>(
          value: _mode,
          onChanged: (mode) => setState(() {
            _mode = mode;
            _stepError = null;
          }),
          options: const [
            AppSegmentedOption(value: PricingMode.perUnit, label: 'Por unidad'),
            AppSegmentedOption(value: PricingMode.tiered, label: 'Por tramos'),
            AppSegmentedOption(value: PricingMode.variable, label: 'Variable'),
          ],
        ),
        const SizedBox(height: 10),
        _Banner(
          tone: _BannerTone.info,
          message: switch (_mode) {
            PricingMode.perUnit =>
              'Un precio por cada unidad: Q12.50 la libra, y 8 libras cuestan '
                  'Q100.',
            PricingMode.tiered =>
              'Cada tramo lleva su precio: tina pequeña Q25, tina grande Q35. '
                  'Los defines en el paso siguiente.',
            PricingMode.variable =>
              'El monto lo teclea quien captura, cada vez. Es lo que hace la '
                  'mensajería, donde el motorista decide el cobro.',
          },
        ),
        if (_mode == PricingMode.perUnit) ...[
          const SizedBox(height: 16),
          AppFormField(
            label: 'UNIDAD',
            controller: _unitLabel,
            optional: true,
            hintText: 'libra',
            helperText: 'Se lee como «Q12.50 por libra».',
          ),
        ],
      ],
    );
  }

  Widget _optionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(
          title: 'Los tramos',
          message:
              'Cada tramo es una opción con su precio. El rango de piezas es '
              'opcional y el de arriba puede quedar abierto: «de 6 en '
              'adelante» es un tramo válido.',
        ),
        const SizedBox(height: 16),
        for (final (index, option) in _options.indexed) ...[
          _OptionCard(
            draft: option,
            index: index,
            // Un servicio por tramos necesita al menos uno: el servidor lo
            // rechaza sin ninguno, así que el último no se puede quitar.
            onRemove: _options.length == 1
                ? null
                : () => setState(() => _options.removeAt(index).dispose()),
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 10),
        ],
        AppButton(
          label: 'Agregar tramo',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          icon: const Icon(Icons.add_rounded, size: 17),
          onPressed: () => setState(() => _options.add(_OptionDraft())),
        ),
      ],
    );
  }

  Widget _pricesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepTitle(
          title: 'Cuánto cuesta',
          message:
              'Sin precio el servicio existe pero nadie puede cobrarlo: la '
              'toma de pedido lo marca como faltante y el servidor rechaza la '
              'boleta.',
        ),
        const SizedBox(height: 16),
        for (final (code, label) in _priceTargets) ...[
          AppFormField(
            label: label.toUpperCase(),
            controller: _prices[code]!,
            hintText: '35.00',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 4),
              child: Text('Q'),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
          ),
          const SizedBox(height: 14),
        ],
        Text('VIGENTE DESDE', style: AppTypography.label),
        const SizedBox(height: 7),
        AppDateField(
          value: _validFrom,
          today: businessDate(),
          onChanged: (picked) => setState(() => _validFrom = picked),
          helpText: 'Desde cuándo se cobra así',
        ),
        const SizedBox(height: 14),
        const _Banner(
          tone: _BannerTone.neutral,
          message:
              'Los precios no se editan: para cambiarlos se abre una ventana '
              'nueva desde el detalle, y las boletas viejas conservan la suya.',
        ),
      ],
    );
  }
}

/// Un tramo mientras se escribe. Los controladores viven aquí para que agregar y
/// quitar filas no revuelva el texto de las demás.
class _OptionDraft {
  final code = TextEditingController();
  final name = TextEditingController();
  final min = TextEditingController();
  final max = TextEditingController();

  String? codeError;
  String? nameError;
  String? rangeError;

  void dispose() {
    for (final controller in [code, name, min, max]) {
      controller.dispose();
    }
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.draft,
    required this.index,
    required this.onRemove,
    required this.onChanged,
  });

  final _OptionDraft draft;
  final int index;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tramo ${index + 1}',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Quitar tramo ${index + 1}',
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                  color: AppColors.errorText,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: AppFormField(
                  label: 'CÓDIGO',
                  controller: draft.code,
                  hintText: 'G',
                  errorText: draft.codeError,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppFormField(
                  label: 'NOMBRE',
                  controller: draft.name,
                  hintText: 'Tina grande',
                  errorText: draft.nameError,
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppFormField(
                  label: 'DESDE',
                  controller: draft.min,
                  optional: true,
                  hintText: '1',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppFormField(
                  label: 'HASTA',
                  controller: draft.max,
                  optional: true,
                  hintText: 'sin tope',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          if (draft.rangeError != null) ...[
            const SizedBox(height: 8),
            Text(
              draft.rangeError!,
              style: AppTypography.helper.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.position,
    required this.total,
    required this.onBack,
  });

  final int position;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paso $position de $total',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Nuevo servicio',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.label,
    required this.backLabel,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  final String label;
  final String backLabel;
  final bool saving;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: backLabel,
              variant: AppButtonVariant.secondary,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: AppButton(label: label, loading: saving, onPressed: onNext),
          ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

enum _BannerTone { info, neutral, error }

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.tone});

  final String message;
  final _BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      _BannerTone.info => (AppColors.primary50, AppColors.primary700),
      _BannerTone.neutral => (AppColors.background, AppColors.textSecondary),
      _BannerTone.error => (AppColors.errorBg, AppColors.errorText),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.mdAll),
      child: Text(
        message,
        style: AppTypography.bodySm.copyWith(fontSize: 13, color: foreground),
      ),
    );
  }
}
