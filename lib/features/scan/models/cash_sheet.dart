/// Lo que el servidor sacó de una foto de la hoja «Registro Diario».
///
/// La diferencia con `scan.dart` no es de forma sino de consecuencia. Aquel es
/// un borrador que termina en una boleta que alguien guarda; **este termina en
/// dinero cobrado y ropa entregada**. Por eso ninguna fila de aquí se manda como
/// llegó: la pantalla de revisión las enseña una por una, editables, y lo que
/// viaja de vuelta es [CashSheetApply] — ids y montos, sin una sola confianza
/// dentro. Lo que la foto propone y lo que la persona confirma son dos tipos
/// distintos a propósito.
library;

import '../../../core/money/fixed2.dart';
import 'scan.dart';

/// Cómo quedó una fila de ingreso después de buscarla en la base.
enum CashIncomeStatus {
  /// Existe la boleta y debe justo lo que dice el papel.
  matched,

  /// Se leyó un número que ninguna boleta lleva.
  notFound,

  /// El número no se pudo leer, así que no se buscó nada.
  unreadable,

  /// La boleta no debe nada: ya se cobró.
  settled,

  /// Existe, pero el papel y el saldo no dicen lo mismo.
  amountMismatch,

  /// Fila azul: venta de un insumo, no una boleta de ropa.
  supply,

  /// La boleta está anulada.
  cancelled;

  static CashIncomeStatus fromWire(String value) => switch (value) {
    'matched' => matched,
    'not_found' => notFound,
    'settled' => settled,
    'amount_mismatch' => amountMismatch,
    'supply' => supply,
    'cancelled' => cancelled,
    _ => unreadable,
  };

  /// Si esta fila puede cobrar algo tal como está.
  bool get isCollectable => this == matched || this == amountMismatch;
}

/// Cómo quedó una fila de gasto.
enum CashExpenseStatus {
  matched,

  /// Ninguna categoría corresponde a esas palabras: la elige una persona.
  noCategory,

  /// Falta el monto o la descripción: no alcanza para escribirlo.
  incomplete;

  static CashExpenseStatus fromWire(String value) => switch (value) {
    'matched' => matched,
    'no_category' => noCategory,
    _ => incomplete,
  };
}

/// Una boleta cobrada, según el papel, y la que el servidor encontró.
class CashIncomeRow {
  const CashIncomeRow({
    required this.index,
    required this.status,
    this.bookletSerial = const DraftField<String>(),
    this.customerText = const DraftField<String>(),
    this.amountRead = const DraftField<int>(),
    this.method = 'cash',
    this.invoiceRequested = false,
    this.orderId,
    this.orderDate,
    this.dailyNumber,
    this.orderStatus,
    this.orderTotal,
    this.balance,
    this.amountSuggested,
    this.canDeliver = false,
  });

  factory CashIncomeRow.fromJson(Map<String, dynamic> json) {
    int? cents(Object? value) => Fixed2.parse(value?.toString());
    Map<String, dynamic>? at(String key) => json[key] as Map<String, dynamic>?;

    return CashIncomeRow(
      index: json['index'] as int,
      status: CashIncomeStatus.fromWire(json['status'] as String? ?? ''),
      bookletSerial: DraftField.fromJson<String>(
        at('booklet_serial'),
        (value) => value?.toString(),
      ),
      customerText: DraftField.fromJson<String>(
        at('customer_text'),
        (value) => value?.toString(),
      ),
      amountRead: DraftField.fromJson<int>(at('amount_read'), cents),
      method: json['method'] as String? ?? 'cash',
      invoiceRequested: json['invoice_requested'] as bool? ?? false,
      orderId: json['order_id'] as String?,
      orderDate: json['order_date'] as String?,
      dailyNumber: json['daily_number'] as int?,
      orderStatus: json['order_status'] as String?,
      orderTotal: cents(json['order_total']),
      balance: cents(json['balance']),
      amountSuggested: cents(json['amount_suggested']),
      canDeliver: json['can_deliver'] as bool? ?? false,
    );
  }

  final int index;
  final CashIncomeStatus status;
  final DraftField<String> bookletSerial;
  final DraftField<String> customerText;

  /// Centavos, como todo el dinero de la app.
  final DraftField<int> amountRead;

  final String method;
  final bool invoiceRequested;

  final String? orderId;
  final String? orderDate;
  final int? dailyNumber;
  final String? orderStatus;
  final int? orderTotal;
  final int? balance;

  /// Lo que se cobraría si la fila se confirma como está. Nunca es más que el
  /// saldo: el servidor ya lo recortó, y el vuelto no es un ingreso.
  final int? amountSuggested;

  final bool canDeliver;

  bool get isTransfer => method == 'transfer';
}

/// Un gasto del día, listo para archivarse en cuanto tenga categoría.
class CashExpenseRow {
  const CashExpenseRow({
    required this.index,
    required this.status,
    this.concept = const DraftField<String>(),
    this.amount = const DraftField<int>(),
    this.observations = const DraftField<String>(),
    this.categoryId,
    this.categoryName,
    this.matchedOn,
    this.expenseStatus = 'paid',
    this.method = 'cash',
    this.employeeId,
    this.employeeName,
  });

  factory CashExpenseRow.fromJson(Map<String, dynamic> json) {
    int? cents(Object? value) => Fixed2.parse(value?.toString());
    Map<String, dynamic>? at(String key) => json[key] as Map<String, dynamic>?;

    return CashExpenseRow(
      index: json['index'] as int,
      status: CashExpenseStatus.fromWire(json['status'] as String? ?? ''),
      concept: DraftField.fromJson<String>(
        at('concept'),
        (value) => value?.toString(),
      ),
      amount: DraftField.fromJson<int>(at('amount'), cents),
      observations: DraftField.fromJson<String>(
        at('observations'),
        (value) => value?.toString(),
      ),
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      matchedOn: json['matched_on'] as String?,
      expenseStatus: json['expense_status'] as String? ?? 'paid',
      method: json['method'] as String? ?? 'cash',
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
    );
  }

  final int index;
  final CashExpenseStatus status;
  final DraftField<String> concept;
  final DraftField<int> amount;
  final DraftField<String> observations;
  final String? categoryId;
  final String? categoryName;

  /// `exact` cuando se escribió el nombre de la categoría, `keyword` cuando fue
  /// una palabra del vocabulario de la hoja. Se enseña para ser honestos sobre
  /// de dónde salió la categoría que aparece marcada.
  final String? matchedOn;

  final String expenseStatus;
  final String method;
  final String? employeeId;
  final String? employeeName;

  bool get isPending => expenseStatus == 'pending';
}

/// Las horas del pie del bloque.
class CashAttendanceRow {
  const CashAttendanceRow({
    required this.index,
    this.employeeText = const DraftField<String>(),
    this.clockIn = const DraftField<String>(),
    this.clockOut = const DraftField<String>(),
    this.employeeId,
    this.employeeName,
  });

  factory CashAttendanceRow.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? at(String key) => json[key] as Map<String, dynamic>?;
    String? text(Object? value) => value?.toString();

    return CashAttendanceRow(
      index: json['index'] as int,
      employeeText: DraftField.fromJson<String>(at('employee_text'), text),
      clockIn: DraftField.fromJson<String>(at('clock_in'), text),
      clockOut: DraftField.fromJson<String>(at('clock_out'), text),
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
    );
  }

  final int index;
  final DraftField<String> employeeText;
  final DraftField<String> clockIn;
  final DraftField<String> clockOut;
  final String? employeeId;
  final String? employeeName;

  bool get isUsable =>
      employeeId != null && clockIn.hasValue && clockOut.hasValue;
}

/// Un bloque de la hoja: un día.
class CashSheetDay {
  const CashSheetDay({
    required this.closeDate,
    this.incomes = const [],
    this.expenses = const [],
    this.attendance = const [],
    this.incomeTotalRead,
    this.expensesTotalRead,
    this.accumulatedRead,
    this.incomeTotalRows = 0,
    this.expensesTotalRows = 0,
    this.warnings = const [],
  });

  factory CashSheetDay.fromJson(Map<String, dynamic> json) {
    int? cents(Object? value) => Fixed2.parse(value?.toString());

    return CashSheetDay(
      closeDate: DraftField.fromJson<String>(
        json['close_date'] as Map<String, dynamic>?,
        (value) => value?.toString(),
      ),
      incomes: [
        for (final row in (json['incomes'] as List<dynamic>? ?? const []))
          CashIncomeRow.fromJson(row as Map<String, dynamic>),
      ],
      expenses: [
        for (final row in (json['expenses'] as List<dynamic>? ?? const []))
          CashExpenseRow.fromJson(row as Map<String, dynamic>),
      ],
      attendance: [
        for (final row in (json['attendance'] as List<dynamic>? ?? const []))
          CashAttendanceRow.fromJson(row as Map<String, dynamic>),
      ],
      incomeTotalRead: cents(json['income_total_read']),
      expensesTotalRead: cents(json['expenses_total_read']),
      accumulatedRead: cents(json['accumulated_read']),
      incomeTotalRows: cents(json['income_total_rows']) ?? 0,
      expensesTotalRows: cents(json['expenses_total_rows']) ?? 0,
      warnings: [
        for (final code in (json['warnings'] as List<dynamic>? ?? const []))
          code as String,
      ],
    );
  }

  final DraftField<String> closeDate;
  final List<CashIncomeRow> incomes;
  final List<CashExpenseRow> expenses;
  final List<CashAttendanceRow> attendance;

  /// Lo que dicen las sumas escritas en el papel. Se guardan aparte de lo que
  /// suman las filas para poder enseñar los dos lados de una diferencia.
  final int? incomeTotalRead;
  final int? expensesTotalRead;
  final int? accumulatedRead;

  final int incomeTotalRows;
  final int expensesTotalRows;

  final List<String> warnings;

  bool get isEmpty =>
      incomes.isEmpty && expenses.isEmpty && attendance.isEmpty;
}

/// La respuesta de `POST /scans/cash-close`.
class CashSheetResult {
  const CashSheetResult({
    required this.id,
    required this.status,
    this.days = const [],
    this.warnings = const [],
    this.latencyMs,
    this.error,
  });

  factory CashSheetResult.fromJson(Map<String, dynamic> json) {
    final draft = json['draft'] as Map<String, dynamic>?;
    return CashSheetResult(
      id: json['id'] as String,
      status: json['status'] as String,
      days: [
        for (final day in (draft?['days'] as List<dynamic>? ?? const []))
          CashSheetDay.fromJson(day as Map<String, dynamic>),
      ],
      warnings: [
        for (final code in (json['warnings'] as List<dynamic>? ?? const []))
          code as String,
      ],
      latencyMs: json['latency_ms'] as int?,
      error: json['error'] as String?,
    );
  }

  final String id;
  final String status;
  final List<CashSheetDay> days;
  final List<String> warnings;
  final int? latencyMs;
  final String? error;

  bool get isCompleted => status == 'completed' && days.isNotEmpty;

  /// La hoja ya se importó antes. Es el único aviso que **bloquea**: aplicar dos
  /// veces la misma hoja cobraría dos veces el mismo día.
  bool get isAlreadyApplied =>
      warnings.any((code) => code.startsWith('already_applied:'));
}

// ------------------------------------------------------------------ confirmar

/// Un cobro, tal como una persona lo dejó en la pantalla.
class CashIncomeApply {
  const CashIncomeApply({
    required this.index,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.deliver,
  });

  final int index;
  final String orderId;

  /// Centavos.
  final int amount;

  final String method;
  final bool deliver;

  Map<String, dynamic> toJson() => {
    'index': index,
    'order_id': orderId,
    'amount': Fixed2.format(amount),
    'method': method,
    'deliver': deliver,
  };
}

/// Un gasto confirmado.
class CashExpenseApply {
  const CashExpenseApply({
    required this.index,
    required this.categoryId,
    required this.concept,
    required this.amount,
    required this.method,
    required this.status,
    this.employeeId,
    this.observations,
  });

  final int index;
  final String categoryId;
  final String concept;
  final int amount;
  final String method;
  final String status;
  final String? employeeId;
  final String? observations;

  Map<String, dynamic> toJson() => {
    'index': index,
    'category_id': categoryId,
    'concept': concept,
    'amount': Fixed2.format(amount),
    'method': method,
    'status': status,
    if (employeeId != null) 'employee_id': employeeId,
    if (observations != null && observations!.isNotEmpty)
      'observations': observations,
  };
}

/// Una jornada confirmada.
class CashAttendanceApply {
  const CashAttendanceApply({
    required this.index,
    required this.employeeId,
    required this.clockIn,
    this.clockOut,
  });

  final int index;
  final String employeeId;

  /// `HH:MM`, como lo pide el servidor.
  final String clockIn;
  final String? clockOut;

  Map<String, dynamic> toJson() => {
    'index': index,
    'employee_id': employeeId,
    'clock_in': clockIn,
    if (clockOut != null) 'clock_out': clockOut,
  };
}

/// El cuerpo de `POST /scans/cash-close/{id}/apply`: un día, lo confirmado.
class CashSheetApply {
  const CashSheetApply({
    required this.closeDate,
    this.incomes = const [],
    this.expenses = const [],
    this.attendance = const [],
  });

  final String closeDate;
  final List<CashIncomeApply> incomes;
  final List<CashExpenseApply> expenses;
  final List<CashAttendanceApply> attendance;

  bool get isEmpty =>
      incomes.isEmpty && expenses.isEmpty && attendance.isEmpty;

  Map<String, dynamic> toJson() => {
    'close_date': closeDate,
    'incomes': [for (final row in incomes) row.toJson()],
    'expenses': [for (final row in expenses) row.toJson()],
    'attendance': [for (final row in attendance) row.toJson()],
  };
}

/// Qué pasó con una fila confirmada.
class CashAppliedRow {
  const CashAppliedRow({required this.index, required this.outcome, this.reason});

  factory CashAppliedRow.fromJson(Map<String, dynamic> json) => CashAppliedRow(
    index: json['index'] as int,
    outcome: json['outcome'] as String,
    reason: json['reason'] as String?,
  );

  final int index;

  /// `applied`, `skipped` o `failed`.
  final String outcome;

  final String? reason;

  bool get isApplied => outcome == 'applied';
  bool get isFailed => outcome == 'failed';
}

/// El resultado de importar un día.
class CashSheetApplyResult {
  const CashSheetApplyResult({
    required this.closeDate,
    this.paymentsApplied = 0,
    this.ordersDelivered = 0,
    this.expensesCreated = 0,
    this.attendanceCreated = 0,
    this.collectedTotal = 0,
    this.expensesTotal = 0,
    this.incomes = const [],
    this.expenses = const [],
    this.attendance = const [],
  });

  factory CashSheetApplyResult.fromJson(Map<String, dynamic> json) {
    List<CashAppliedRow> rows(String key) => [
      for (final row in (json[key] as List<dynamic>? ?? const []))
        CashAppliedRow.fromJson(row as Map<String, dynamic>),
    ];

    return CashSheetApplyResult(
      closeDate: json['close_date'] as String,
      paymentsApplied: json['payments_applied'] as int? ?? 0,
      ordersDelivered: json['orders_delivered'] as int? ?? 0,
      expensesCreated: json['expenses_created'] as int? ?? 0,
      attendanceCreated: json['attendance_created'] as int? ?? 0,
      collectedTotal: Fixed2.parse(json['collected_total']?.toString()) ?? 0,
      expensesTotal: Fixed2.parse(json['expenses_total']?.toString()) ?? 0,
      incomes: rows('incomes'),
      expenses: rows('expenses'),
      attendance: rows('attendance'),
    );
  }

  final String closeDate;
  final int paymentsApplied;
  final int ordersDelivered;
  final int expensesCreated;
  final int attendanceCreated;
  final int collectedTotal;
  final int expensesTotal;
  final List<CashAppliedRow> incomes;
  final List<CashAppliedRow> expenses;
  final List<CashAppliedRow> attendance;

  /// Las filas que no entraron. Es lo primero que la pantalla enseña al
  /// terminar: lo que se aplicó ya está, y lo que hay que resolver es esto.
  List<CashAppliedRow> get failures => [
    ...incomes.where((row) => row.isFailed),
    ...expenses.where((row) => row.isFailed),
    ...attendance.where((row) => row.isFailed),
  ];
}
