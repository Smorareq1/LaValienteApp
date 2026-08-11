import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/search_text.dart';
import '../../../../core/money/fixed2.dart';
import '../../../../core/money/payment_method.dart';
import '../../../../core/time/business_date.dart';
import '../../../inventory/models/product.dart';
import '../../../inventory/state/shelf_controller.dart';
import '../../../staff/domain/overtime.dart';
import '../../../staff/models/staff.dart';
import '../../../staff/state/attendance_controller.dart';
import '../../../sync/state/sync_engine.dart';
import '../../data/expenses_repository.dart';
import '../../models/expense.dart';
import '../../state/cash_day_controller.dart';

/// Anotar un gasto, o corregir uno ya anotado (Plan 0006 §7.2).
///
/// La fecha se puede mover porque la hoja de papel también se llena a
/// destiempo: alguien pagó el gas ayer y lo anota hoy. El servidor rechaza la de
/// un día ya cerrado, así que el calendario no deja pasar de hoy y la pantalla
/// de Caja ya bloquea el botón cuando la fecha que se está mirando está cerrada.
///
/// Las categorías **se observan aquí** y no llegan por parámetro: son un stream
/// de la BD local y quien abría la sheet las leía con un `read`, que devuelve
/// «cargando» en el mismo instante en que se pide. Esa lectura era siempre vacía
/// y la sheet abría diciendo que el teléfono no las había bajado, con el botón
/// de registrar sin nada que hacer.
class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({
    super.key,
    required this.date,
    this.initial,
    this.prefill,
  });

  /// El nombre con el que el servidor identifica la categoría de hora extra.
  ///
  /// Se compara por **nombre** y no por código porque el backend no le da uno:
  /// `OVERTIME_CATEGORY = "Horas extra"` en `expenses/models.py` es una
  /// constante de texto, y es lo único que baja por el feed. Si algún día la
  /// categoría se renombra en la base, este bloque deja de aparecer y el gasto
  /// se sigue pudiendo anotar a mano — se degrada, no se rompe.
  static const String overtimeCategoryName = 'Horas extra';

  /// Dónde se anota la compra de insumos, por el mismo mecanismo y con el mismo
  /// riesgo asumido: `SUPPLY_PURCHASE_CATEGORY` en `expenses/models.py`.
  static const String suppliesCategoryName = 'Compra de insumos';

  /// El día que la Caja está mirando; con el que abre el formulario.
  final DateTime date;

  /// El gasto que se está corrigiendo, si se está corrigiendo alguno.
  final Expense? initial;

  /// Un pago de hora extra que llega ya resuelto desde la asistencia (§9.1).
  final OvertimePrefill? prefill;

  /// Abre la sheet y devuelve lo capturado, o `null` si se canceló.
  static Future<ExpenseDraft?> show(
    BuildContext context, {
    required DateTime date,
    Expense? initial,
    OvertimePrefill? prefill,
  }) {
    return AppBottomSheetScaffold.show<ExpenseDraft>(
      context: context,
      builder: (context) => ExpenseSheet(
        date: date,
        initial: initial,
        prefill: prefill,
      ),
    );
  }

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

/// El pago de una jornada, ya decidido en la pantalla de asistencia.
///
/// Llega armado porque allá se sabe todo lo que hace falta —quién, qué jornada,
/// cuántos minutos se confirmaron— y volver a preguntarlo aquí sería hacer
/// teclear dos veces lo mismo.
class OvertimePrefill {
  const OvertimePrefill({
    required this.employeeId,
    required this.employeeName,
    required this.attendanceRecordId,
    required this.minutes,
    this.amount,
  });

  final String employeeId;
  final String employeeName;
  final String attendanceRecordId;
  final int minutes;

  /// En centavos. Nulo cuando no hay tarifa vigente que valúe los minutos: el
  /// monto lo escribe entonces una persona.
  final int? amount;

  String get concept => '$employeeName — hora extra';
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  late final TextEditingController _concept = TextEditingController(
    text: widget.initial?.concept ?? widget.prefill?.concept ?? '',
  );
  late final TextEditingController _amount = TextEditingController(
    text: _initialAmountText(),
  );
  late final TextEditingController _observations = TextEditingController(
    text: widget.initial?.observations ?? '',
  );

  late DateTime _date =
      parseIsoDate(widget.initial?.expenseDate ?? '') ?? widget.date;

  /// La categoría **elegida a mano**. Nula mientras nadie toque un chip: cuál se
  /// usa entonces lo decide [_resolvedCategory], que necesita la lista y por eso
  /// no se puede fijar aquí — cuando la sheet abre todavía no ha llegado.
  late String? _categoryId = widget.initial?.categoryId;

  late PaymentMethod _method = widget.initial?.method ?? PaymentMethod.cash;
  late bool _isPending = widget.initial?.isPending ?? false;

  /// A quién y qué jornada se está pagando. Nacen del gasto que se corrige o de
  /// lo que la asistencia mandó resuelto.
  late String? _employeeId = widget.initial?.employeeId ?? widget.prefill?.employeeId;
  late String? _recordId =
      widget.initial?.attendanceRecordId ?? widget.prefill?.attendanceRecordId;

  /// Unidades por producto: los insumos que esta compra trae (§8.1).
  final Map<String, int> _units = {};

  /// Si el concepto y el monto los escribió una persona. Mientras no, los pone
  /// la cuenta de insumos; después de que alguien los toque no se pisan, por lo
  /// mismo que el monto de una hora extra no se pisa (D8).
  ///
  /// Un gasto que se está corrigiendo, o el pago que llega resuelto desde la
  /// asistencia, nacen tocados: esas cifras ya las decidió alguien.
  late bool _conceptTouched = widget.initial != null || widget.prefill != null;
  late bool _amountTouched = _conceptTouched;

  bool _suppliesOpen = false;

  String? _conceptError;
  String? _amountError;
  bool _employeeMissing = false;

  bool get _isEditing => widget.initial != null;

  String _initialAmountText() {
    final editing = widget.initial;
    if (editing != null) return Fixed2.format(editing.amount);
    final suggested = widget.prefill?.amount;
    return suggested == null ? '' : Fixed2.format(suggested);
  }

  /// La categoría que el formulario está usando ahora mismo.
  ///
  /// El orden es el de lo que se sabe con más certeza: lo que alguien eligió, lo
  /// que el gasto ya decía, lo que la compra de insumos o el pago de una jornada
  /// implican, y por último la primera de la lista.
  ExpenseCategory? _resolvedCategory(List<ExpenseCategory> categories) {
    if (categories.isEmpty) return null;

    ExpenseCategory? byId(String? id) {
      if (id == null) return null;
      for (final category in categories) {
        if (category.id == id) return category;
      }
      return null;
    }

    ExpenseCategory? byName(String name) {
      for (final category in categories) {
        if (category.name == name) return category;
      }
      return null;
    }

    return byId(_categoryId) ??
        (_units.isEmpty ? null : byName(ExpenseSheet.suppliesCategoryName)) ??
        (widget.prefill == null
            ? null
            : byName(ExpenseSheet.overtimeCategoryName)) ??
        categories.first;
  }

  /// El bloque de hora extra se muestra por la categoría elegida, no por cómo se
  /// abrió la sheet: anotar el pago de una jornada desde la Caja es tan válido
  /// como hacerlo desde la asistencia.
  bool _isOvertime(ExpenseCategory? category) =>
      category?.name == ExpenseSheet.overtimeCategoryName;

  @override
  void dispose() {
    _concept.dispose();
    _amount.dispose();
    _observations.dispose();
    super.dispose();
  }

  void _confirm(List<ExpenseCategory> categories) {
    final category = _resolvedCategory(categories);
    final overtime = _isOvertime(category);
    final concept = _concept.text.trim();
    final amount = Fixed2.parse(_amount.text) ?? 0;

    setState(() {
      _conceptError = concept.isEmpty ? 'Escribí en qué se gastó' : null;
      _amountError = amount <= 0 ? 'Escribí cuánto se gastó' : null;
      // El servidor lo exige: una jornada se le paga a alguien.
      _employeeMissing = overtime && _employeeId == null;
    });
    if (_conceptError != null ||
        _amountError != null ||
        category == null ||
        _employeeMissing) {
      return;
    }

    Navigator.of(context).pop(
      ExpenseDraft(
        expenseDate: isoDate(_date),
        categoryId: category.id,
        concept: concept,
        amount: amount,
        method: _method,
        status: _isPending ? ExpenseStatus.pending : ExpenseStatus.paid,
        observations: _observations.text,
        employeeId: overtime ? _employeeId : null,
        attendanceRecordId: overtime ? _recordId : null,
      ),
    );
  }

  /// Elegir a la persona, y con ella su jornada del día si la tiene.
  ///
  /// Los dos van juntos porque el servidor no admite una jornada suelta, y
  /// porque elegirlos por separado dejaría abierta la combinación imposible: la
  /// jornada de alguien pagada a otro.
  void _pickJornada(EmployeeDay? day) {
    setState(() {
      _employeeId = day?.employee.id;
      _recordId = day?.record?.id;
      _employeeMissing = false;

      if (day == null) return;
      if (_concept.text.trim().isEmpty) {
        _concept.text = '${day.employee.fullName} — hora extra';
      }
      // El monto se sugiere solo si el campo está vacío: quien ya escribió una
      // cifra la escribió por algo, y pisarla sería contradecir a la persona que
      // decide (D8).
      final minutes = day.confirmedOvertimeMinutes;
      final amount = day.hourlyRate;
      if (_amount.text.trim().isEmpty && minutes > 0 && amount != null) {
        _amount.text = Fixed2.format(
          overtimeAmount(minutes: minutes, hourlyRate: amount),
        );
        _amountError = null;
      }
    });
  }

  /// Suma y cuenta lo que la compra lleva: «3 Detergente · 2 Cloro», Q97.50.
  void _setUnits(List<ProductSummary> products, String productId, int units) {
    setState(() {
      if (units <= 0) {
        _units.remove(productId);
      } else {
        _units[productId] = units;
        _suppliesOpen = true;
      }

      final chosen = [
        for (final product in products)
          if ((_units[product.id] ?? 0) > 0) product,
      ];

      if (!_conceptTouched) {
        _concept.text = [
          for (final product in chosen) '${_units[product.id]} ${product.name}',
        ].join(' · ');
        if (chosen.isNotEmpty) _conceptError = null;
      }
      if (!_amountTouched) {
        final total = chosen.fold<int>(
          0,
          (sum, product) =>
              sum + Fixed2.multiply(product.nextSalePrice ?? 0, _units[product.id]! * 100),
        );
        _amount.text = total <= 0 ? '' : Fixed2.format(total);
        if (total > 0) _amountError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = businessDate();
    final categoriesAsync = ref.watch(cashExpensesCategoriesProvider);
    final categories = categoriesAsync.valueOrNull;
    final category = _resolvedCategory(categories ?? const []);
    final products =
        ref.watch(inventoryProductsProvider()).valueOrNull ?? const <ProductSummary>[];

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
              // Sin categoría no hay gasto que mandar. El botón se apaga en vez
              // de no hacer nada al tocarlo: el aviso de arriba dice qué falta.
              onPressed: category == null
                  ? null
                  : () => _confirm(categories ?? const []),
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
          if (categories == null)
            const _LoadingCategories()
          else if (categories.isEmpty)
            const _NoCategories()
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final option in categories)
                  AppChip(
                    label: option.name,
                    selected: option.id == category?.id,
                    onTap: () => setState(() => _categoryId = option.id),
                  ),
              ],
            ),
          if (_isOvertime(category)) ...[
            const SizedBox(height: 14),
            _OvertimeBlock(
              date: _date,
              employeeId: _employeeId,
              recordId: _recordId,
              employeeMissing: _employeeMissing,
              onPicked: _pickJornada,
            ),
          ],
          const SizedBox(height: 14),
          _SuppliesBlock(
            products: products,
            units: _units,
            open: _suppliesOpen,
            onToggle: () => setState(() => _suppliesOpen = !_suppliesOpen),
            onChanged: (productId, units) =>
                _setUnits(products, productId, units),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'CONCEPTO',
            controller: _concept,
            hintText: 'Gas — 2 sacos',
            errorText: _conceptError,
            onChanged: (_) => setState(() {
              _conceptTouched = true;
              _conceptError = null;
            }),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'MONTO',
            controller: _amount,
            hintText: 'Q 0.00',
            errorText: _amountError,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: decimalInputFormatters,
            onChanged: (_) => setState(() {
              _amountTouched = true;
              _amountError = null;
            }),
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

/// Los insumos de la compra, con la misma cuenta que las prendas de una boleta.
///
/// El mostrador no escribe «Q97.50 de jabón»: cuenta botes. Se ponen 3
/// detergentes y 2 cloros y el concepto y el monto salen solos, valuados al
/// precio de venta que el teléfono conoce — que es el único precio que baja al
/// dispositivo (el de compra no viaja en el feed, a propósito).
///
/// Va plegado mientras nadie lo abra: la mayoría de los gastos —el gas, la
/// moto— no son insumos, y una lista de productos en medio del formulario
/// estorbaría a quien solo viene a anotar Q200 de gas.
class _SuppliesBlock extends StatefulWidget {
  const _SuppliesBlock({
    required this.products,
    required this.units,
    required this.open,
    required this.onToggle,
    required this.onChanged,
  });

  final List<ProductSummary> products;
  final Map<String, int> units;
  final bool open;
  final VoidCallback onToggle;
  final void Function(String productId, int units) onChanged;

  /// Cuántos se ven antes de tener que buscar o desplegar el resto.
  static const int visibleByDefault = 6;

  @override
  State<_SuppliesBlock> createState() => _SuppliesBlockState();
}

class _SuppliesBlockState extends State<_SuppliesBlock> {
  String _query = '';
  bool _showAll = false;

  List<ProductSummary> get _visible {
    final needle = normalizeForSearch(_query);
    if (needle.isNotEmpty) {
      return widget.products
          .where((product) => normalizeForSearch(product.name).contains(needle))
          .toList();
    }
    if (_showAll) return widget.products;

    // Los que ya tienen cantidad no se pueden esconder: acortar la lista no
    // puede ocultar lo que la persona ya contó.
    final counted = widget.products
        .where((product) => (widget.units[product.id] ?? 0) > 0)
        .toList();
    final rest = widget.products
        .where((product) => (widget.units[product.id] ?? 0) == 0)
        .take(_SuppliesBlock.visibleByDefault)
        .toList();
    return [...counted, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final counted = widget.units.values.fold(0, (sum, units) => sum + units);
    final visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: widget.onToggle,
          borderRadius: BorderRadius.circular(9),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  counted == 0
                      ? 'INSUMOS · opcional'
                      : 'INSUMOS · $counted ${counted == 1 ? 'unidad' : 'unidades'}',
                  style: AppTypography.label,
                ),
              ),
              Icon(
                widget.open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (!widget.open)
          Text(
            'Contá lo que compraste y el concepto y el monto se llenan solos.',
            style: AppTypography.helper.copyWith(fontSize: 11.5),
          )
        else if (widget.products.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Este teléfono todavía no bajó los insumos. Sincronizá y volvé a '
              'intentarlo, o escribí el gasto a mano.',
              style: AppTypography.helper.copyWith(fontSize: 11.5),
            ),
          )
        else ...[
          const SizedBox(height: 4),
          Text(
            'Se valúan al precio de venta. Anota el gasto: el inventario se '
            'mueve al registrar el lote.',
            style: AppTypography.helper.copyWith(fontSize: 11.5),
          ),
          const SizedBox(height: 9),
          if (widget.products.length > _SuppliesBlock.visibleByDefault) ...[
            AppSearchField(
              hintText: 'Buscar un insumo…',
              backgroundColor: AppColors.gray100,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 9),
          ],
          if (visible.isEmpty)
            Text(
              'Ningún insumo con ese nombre.',
              style: AppTypography.helper.copyWith(fontSize: 11.5),
            ),
          for (final product in visible)
            _SupplyRow(
              key: ValueKey(product.id),
              product: product,
              units: widget.units[product.id] ?? 0,
              onChanged: (units) => widget.onChanged(product.id, units),
            ),
          if (_query.isEmpty &&
              widget.products.length > _SuppliesBlock.visibleByDefault)
            Center(
              child: AppButton(
                label: _showAll
                    ? 'Ver solo los primeros'
                    : 'Ver los ${widget.products.length} insumos',
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                onPressed: () => setState(() => _showAll = !_showAll),
              ),
            ),
        ],
      ],
    );
  }
}

/// Un insumo con su precio y su contador, igual que una prenda de la boleta.
class _SupplyRow extends StatelessWidget {
  const _SupplyRow({
    super.key,
    required this.product,
    required this.units,
    required this.onChanged,
  });

  final ProductSummary product;
  final int units;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final price = product.nextSalePrice;
    final counted = units > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 9, 7),
        decoration: BoxDecoration(
          color: counted ? AppColors.primary50 : AppColors.gray50,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: counted ? AppColors.primary100 : AppColors.gray100,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray800,
                    ),
                  ),
                  Text(
                    // Sin precio el contador sigue sirviendo para el concepto,
                    // pero el monto lo tiene que escribir una persona: inventarlo
                    // sería poner una cifra que nadie pagó.
                    price == null
                        ? 'Sin precio · escribí el monto'
                        : 'Q${Fixed2.format(price)} el ${product.unit}',
                    style: AppTypography.helper.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppStepper(value: units, size: AppStepperSize.md, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Los campos que solo tienen sentido pagando una hora extra (§7.2).
///
/// Aparecen por la categoría elegida y desaparecen con ella. La jornada es
/// opcional —se puede pagar una hora extra que nadie marcó— pero la persona no:
/// el servidor rechaza una jornada sin su empleado, y un pago a nadie en
/// particular es la fila que aparece sin explicación a fin de mes.
class _OvertimeBlock extends ConsumerWidget {
  const _OvertimeBlock({
    required this.date,
    required this.employeeId,
    required this.recordId,
    required this.employeeMissing,
    required this.onPicked,
  });

  final DateTime date;
  final String? employeeId;
  final String? recordId;
  final bool employeeMissing;
  final ValueChanged<EmployeeDay?> onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(attendanceDayProvider(isoDate(date))).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('A QUIÉN SE LE PAGA', style: AppTypography.label),
        const SizedBox(height: 7),
        if (days == null)
          Text(
            'Cargando el personal…',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          )
        else if (days.isEmpty)
          Text(
            'No hay personal en este teléfono todavía. El gasto se puede anotar '
            'igual, sin quedar atado a una jornada.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          )
        else ...[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final day in days)
                AppChip(
                  label: day.employee.fullName,
                  selected: day.employee.id == employeeId,
                  onTap: () =>
                      onPicked(day.employee.id == employeeId ? null : day),
                ),
            ],
          ),
          const SizedBox(height: 7),
          _JornadaNote(
            day: _selected(days),
            linked: recordId != null,
          ),
        ],
        if (employeeMissing) ...[
          const SizedBox(height: 6),
          Text(
            'Elegí a quién se le está pagando',
            style: AppTypography.helper.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  EmployeeDay? _selected(List<EmployeeDay> days) {
    for (final day in days) {
      if (day.employee.id == employeeId) return day;
    }
    return null;
  }
}

/// Qué jornada se está pagando, dicho en una línea.
class _JornadaNote extends StatelessWidget {
  const _JornadaNote({required this.day, required this.linked});

  final EmployeeDay? day;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final selected = day;
    if (selected == null) {
      return Text(
        'Elegí a la persona y, si tiene jornada marcada hoy, el pago queda atado '
        'a ella.',
        style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
      );
    }

    final minutes = selected.confirmedOvertimeMinutes;
    final record = selected.record;

    return Text(
      switch ((record, minutes, linked)) {
        (null, _, _) =>
          '${selected.employee.fullName} no tiene jornada marcada este día. El '
              'pago se anota igual, suelto.',
        (_, 0, _) =>
          'Su jornada de hoy no tiene minutos extra confirmados. Se puede pagar '
              'igual, escribiendo el monto.',
        (_, final confirmed, true) =>
          'Jornada atada · ${formatMinutes(confirmed)} de hora extra confirmados.',
        (_, final confirmed, false) =>
          '${formatMinutes(confirmed)} de hora extra confirmados.',
      },
      style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
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

/// El stream de categorías todavía no dio su primer valor. Dura un parpadeo, y
/// decirlo es lo que separa «esperá» de «este teléfono no las tiene».
class _LoadingCategories extends StatelessWidget {
  const _LoadingCategories();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 9),
        Text(
          'Buscando las categorías…',
          style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// No hay ninguna categoría en el dispositivo. Se administran en línea (D11), así
/// que lo único que se puede hacer desde aquí es pedir un ciclo de
/// sincronización — y por eso el aviso trae el botón en vez de mandar a buscarlo
/// a otra pantalla.
class _NoCategories extends ConsumerWidget {
  const _NoCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Este teléfono todavía no bajó las categorías de gasto. Sin ellas el '
            'gasto no se puede clasificar.',
            style: AppTypography.bodySm.copyWith(
              fontSize: 12.5,
              color: AppColors.warningText,
            ),
          ),
          const SizedBox(height: 9),
          AppButton(
            label: 'Sincronizar ahora',
            icon: const Icon(Icons.sync_rounded),
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            onPressed: () => ref.read(syncEngineProvider.notifier).sync(),
          ),
        ],
      ),
    );
  }
}
