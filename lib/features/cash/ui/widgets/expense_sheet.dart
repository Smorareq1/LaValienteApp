import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/money/fixed2.dart';
import '../../../../core/money/payment_method.dart';
import '../../../../core/time/business_date.dart';
import '../../../staff/domain/overtime.dart';
import '../../../staff/models/staff.dart';
import '../../../staff/state/attendance_controller.dart';
import '../../data/expenses_repository.dart';
import '../../models/expense.dart';

/// Anotar un gasto, o corregir uno ya anotado (Plan 0006 §7.2).
///
/// La fecha se puede mover porque la hoja de papel también se llena a
/// destiempo: alguien pagó el gas ayer y lo anota hoy. El servidor rechaza la de
/// un día ya cerrado, así que el calendario no deja pasar de hoy y la pantalla
/// de Caja ya bloquea el botón cuando la fecha que se está mirando está cerrada.
class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({
    super.key,
    required this.categories,
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

  final List<ExpenseCategory> categories;

  /// El día que la Caja está mirando; con el que abre el formulario.
  final DateTime date;

  /// El gasto que se está corrigiendo, si se está corrigiendo alguno.
  final Expense? initial;

  /// Un pago de hora extra que llega ya resuelto desde la asistencia (§9.1).
  final OvertimePrefill? prefill;

  /// Abre la sheet y devuelve lo capturado, o `null` si se canceló.
  static Future<ExpenseDraft?> show(
    BuildContext context, {
    required List<ExpenseCategory> categories,
    required DateTime date,
    Expense? initial,
    OvertimePrefill? prefill,
  }) {
    return AppBottomSheetScaffold.show<ExpenseDraft>(
      context: context,
      builder: (context) => ExpenseSheet(
        categories: categories,
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
  late String? _categoryId =
      widget.initial?.categoryId ?? _overtimeCategoryId() ?? _firstCategoryId();
  late PaymentMethod _method = widget.initial?.method ?? PaymentMethod.cash;
  late bool _isPending = widget.initial?.isPending ?? false;

  /// A quién y qué jornada se está pagando. Nacen del gasto que se corrige o de
  /// lo que la asistencia mandó resuelto.
  late String? _employeeId = widget.initial?.employeeId ?? widget.prefill?.employeeId;
  late String? _recordId =
      widget.initial?.attendanceRecordId ?? widget.prefill?.attendanceRecordId;

  String? _conceptError;
  String? _amountError;
  bool _categoryMissing = false;
  bool _employeeMissing = false;

  bool get _isEditing => widget.initial != null;

  String _initialAmountText() {
    final editing = widget.initial;
    if (editing != null) return Fixed2.format(editing.amount);
    final suggested = widget.prefill?.amount;
    return suggested == null ? '' : Fixed2.format(suggested);
  }

  String? _firstCategoryId() =>
      widget.categories.isEmpty ? null : widget.categories.first.id;

  /// Solo cuando el pago viene de la asistencia: es la categoría que le
  /// corresponde y preseleccionarla ahorra el paso obvio.
  String? _overtimeCategoryId() {
    if (widget.prefill == null) return null;
    for (final category in widget.categories) {
      if (category.name == ExpenseSheet.overtimeCategoryName) return category.id;
    }
    return null;
  }

  /// El bloque de hora extra se muestra por la categoría elegida, no por cómo se
  /// abrió la sheet: anotar el pago de una jornada desde la Caja es tan válido
  /// como hacerlo desde la asistencia.
  bool get _isOvertime {
    for (final category in widget.categories) {
      if (category.id == _categoryId) {
        return category.name == ExpenseSheet.overtimeCategoryName;
      }
    }
    return false;
  }

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
      // El servidor lo exige: una jornada se le paga a alguien.
      _employeeMissing = _isOvertime && _employeeId == null;
    });
    if (_conceptError != null ||
        _amountError != null ||
        categoryId == null ||
        _employeeMissing) {
      return;
    }

    Navigator.of(context).pop(
      ExpenseDraft(
        expenseDate: isoDate(_date),
        categoryId: categoryId,
        concept: concept,
        amount: amount,
        method: _method,
        status: _isPending ? ExpenseStatus.pending : ExpenseStatus.paid,
        observations: _observations.text,
        employeeId: _isOvertime ? _employeeId : null,
        attendanceRecordId: _isOvertime ? _recordId : null,
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
          if (_isOvertime) ...[
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
