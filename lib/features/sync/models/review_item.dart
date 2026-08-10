/// Un dato suelto de la comparación de §11.2: etiqueta y valor ya legibles.
class ReviewFact {
  const ReviewFact(this.label, this.value);

  final String label;
  final String value;
}

/// Cómo terminó la operación según el servidor.
///
/// Los dos van a la misma cola porque los dos necesitan a alguien, pero no son
/// lo mismo: uno es una regla de negocio que no se cumplió, el otro una carrera
/// entre dos dispositivos que nadie puede resolver adivinando (D6).
enum ReviewOutcome {
  /// Una regla de dominio o un permiso la rechazaron.
  rejected,

  /// Otro dispositivo ya había cambiado la fila.
  conflict;

  static ReviewOutcome fromWire(String value) => switch (value) {
    'conflict' => ReviewOutcome.conflict,
    _ => ReviewOutcome.rejected,
  };

  String get label => switch (this) {
    ReviewOutcome.rejected => 'Rechazada',
    ReviewOutcome.conflict => 'Chocó',
  };
}

/// Qué se estaba intentando hacer, que es lo que decide qué se puede hacer
/// ahora.
///
/// Se clasifica por `entity` + `op_type` y no por el texto del motivo: el
/// servidor contesta en prosa y libre, y colgar las acciones de una frase que
/// mañana se puede reescribir sería construir sobre arena.
enum ReviewKind {
  orderCreate,
  orderUpdate,
  orderStatus,
  orderDeliver,
  orderCancel,
  paymentCreate,
  customerCreate,
  customerUpdate,
  customerArchive,
  expenseCreate,
  expenseUpdate,
  supplySaleCreate,
  attendanceCreate,
  attendanceUpdate,
  unknown;

  static ReviewKind fromOperation(String entity, String opType) =>
      switch ((entity, opType)) {
        ('order', 'create') => ReviewKind.orderCreate,
        ('order', 'update') => ReviewKind.orderUpdate,
        ('order', 'status') => ReviewKind.orderStatus,
        ('order', 'deliver') => ReviewKind.orderDeliver,
        ('order', 'cancel') => ReviewKind.orderCancel,
        ('order_payment', 'create') => ReviewKind.paymentCreate,
        ('customer', 'create') => ReviewKind.customerCreate,
        ('customer', 'update') => ReviewKind.customerUpdate,
        ('customer', 'archive') => ReviewKind.customerArchive,
        ('expense', 'create') => ReviewKind.expenseCreate,
        ('expense', 'update') => ReviewKind.expenseUpdate,
        // Anular una venta no aparece: el §7 le da `supply_sales.cancel` solo al
        // admin y el mostrador no lo captura, así que ninguna operación de esa
        // forma sale de esta app.
        ('supply_sale', 'create') => ReviewKind.supplySaleCreate,
        // Marcar entrada y marcar salida son la misma entidad y el mismo
        // permiso, pero dos operaciones: la segunda edita la fila que abrió la
        // primera, y por eso una llega aquí con `base_version` y la otra no.
        ('attendance_record', 'create') => ReviewKind.attendanceCreate,
        ('attendance_record', 'update') => ReviewKind.attendanceUpdate,
        _ => ReviewKind.unknown,
      };

  /// Titular de la tarjeta: qué se intentó, en el lenguaje del mostrador.
  String get title => switch (this) {
    ReviewKind.orderCreate => 'Boleta nueva',
    ReviewKind.orderUpdate => 'Corrección de boleta',
    ReviewKind.orderStatus => 'Cambio de estado',
    ReviewKind.orderDeliver => 'Entrega',
    ReviewKind.orderCancel => 'Anulación',
    ReviewKind.paymentCreate => 'Cobro',
    ReviewKind.customerCreate => 'Cliente nuevo',
    ReviewKind.customerUpdate => 'Datos de un cliente',
    ReviewKind.customerArchive => 'Archivar un cliente',
    ReviewKind.expenseCreate => 'Gasto nuevo',
    ReviewKind.expenseUpdate => 'Corrección de un gasto',
    ReviewKind.supplySaleCreate => 'Venta de insumo',
    ReviewKind.attendanceCreate => 'Entrada de una jornada',
    ReviewKind.attendanceUpdate => 'Cierre de una jornada',
    ReviewKind.unknown => 'Operación',
  };

  /// La captura creó algo que el servidor nunca llegó a tener.
  ///
  /// Es la línea que separa descartar de olvidar: si la operación era un alta,
  /// descartarla tiene que retirar también la fila local, porque nadie más la
  /// va a corregir — el feed no puede traer lo que no existe. En todo lo demás
  /// el servidor ya tiene la verdad y basta con cerrar la entrada.
  bool get createsLocalRow =>
      this == ReviewKind.orderCreate ||
      this == ReviewKind.paymentCreate ||
      this == ReviewKind.customerCreate ||
      this == ReviewKind.expenseCreate ||
      this == ReviewKind.supplySaleCreate ||
      this == ReviewKind.attendanceCreate;
}

/// Una captura que el servidor no aceptó y espera una decisión humana
/// (plan 0004 §8, plan 0006 §11.2).
///
/// El motor no descarta nada por su cuenta: lo que no se pudo aplicar queda
/// aquí con lo que se capturó y lo que el servidor respondió, para que una
/// persona decida con las dos versiones a la vista.
class ReviewItem {
  const ReviewItem({
    required this.opId,
    required this.entity,
    required this.opType,
    required this.entityId,
    required this.outcome,
    required this.localPayload,
    required this.createdAt,
    this.reason,
    this.serverData,
    this.serverVersion,
  });

  final String opId;
  final String entity;
  final String opType;

  /// El id que este dispositivo le dio a la entidad (D3).
  final String entityId;

  final ReviewOutcome outcome;

  /// El motivo tal como lo escribió el servidor. Se muestra literal y aparte:
  /// es un dato de diagnóstico, no la explicación que lee el mostrador.
  final String? reason;

  /// El comando que se capturó aquí.
  final Map<String, dynamic> localPayload;

  /// El estado que tiene el servidor, cuando lo mandó.
  final Map<String, dynamic>? serverData;

  final int? serverVersion;
  final DateTime createdAt;

  ReviewKind get kind => ReviewKind.fromOperation(entity, opType);

  /// El pedido al que apunta la operación, si apunta a alguno. Un cobro no lo
  /// nombra con su `entity_id` —ese es el id del pago— sino dentro del cuerpo.
  String? get orderId => switch (kind) {
    ReviewKind.orderCreate ||
    ReviewKind.orderUpdate ||
    ReviewKind.orderStatus ||
    ReviewKind.orderDeliver ||
    ReviewKind.orderCancel => entityId,
    ReviewKind.paymentCreate => localPayload['order_id'] as String?,
    _ => null,
  };

  String? get customerId => switch (kind) {
    ReviewKind.customerCreate ||
    ReviewKind.customerUpdate ||
    ReviewKind.customerArchive => entityId,
    _ => null,
  };

  /// La serie de imprenta de la boleta, que es como el mostrador llama a un
  /// pedido que todavía no tiene número del día.
  String? get bookletSerial => localPayload['booklet_serial'] as String?;

  /// Una línea que identifique la captura sin abrirla.
  String get subtitle => switch (kind) {
    ReviewKind.orderCreate || ReviewKind.orderUpdate =>
      bookletSerial == null ? 'Sin serie de boleta' : 'Boleta $bookletSerial',
    ReviewKind.orderStatus => 'Pasar a ${_statusLabel(localPayload['status'])}',
    ReviewKind.orderDeliver => 'Entregar la ropa al cliente',
    ReviewKind.orderCancel => 'Motivo: ${localPayload['reason'] ?? '—'}',
    ReviewKind.paymentCreate => 'Q${localPayload['amount'] ?? '0.00'}',
    ReviewKind.customerCreate ||
    ReviewKind.customerUpdate => (localPayload['full_name'] as String?) ?? '—',
    ReviewKind.customerArchive => 'Sacarlo de la lista',
    ReviewKind.expenseCreate ||
    ReviewKind.expenseUpdate => (localPayload['concept'] as String?) ?? '—',
    // Cuántas líneas y no cuánto: el total que se capturó es una vista previa,
    // y el servidor lo recalcula contra los lotes del momento (D10). Poner una
    // cifra aquí sería afirmar un monto que quizá nunca fue.
    ReviewKind.supplySaleCreate =>
      '${_count(localPayload['lines'])} ${_count(localPayload['lines']) == 1 ? 'producto' : 'productos'}',
    // Sin el nombre de la persona: el cuerpo lleva su id y nada más. Quién es se
    // resuelve contra el espejo y se muestra en el detalle, no aquí.
    ReviewKind.attendanceCreate => 'Entró a las ${_clock(localPayload['clock_in'])}',
    ReviewKind.attendanceUpdate => localPayload['clock_out'] != null
        ? 'Salió a las ${_clock(localPayload['clock_out'])}'
        : 'Corrección de la jornada',
    ReviewKind.unknown => '$entity · $opType',
  };

  /// Lo capturado, en las palabras de la boleta.
  ///
  /// Sale del payload y no del espejo local a propósito: el espejo ya lo pisó
  /// el feed —una fila rechazada deja de estar protegida—, así que esto es lo
  /// único que queda de lo que la persona realmente escribió.
  List<ReviewFact> get capturedFacts => switch (kind) {
    ReviewKind.orderCreate || ReviewKind.orderUpdate => [
      ReviewFact('Boleta', bookletSerial ?? '—'),
      ReviewFact('Piezas', '${_sum(localPayload['garments'], 'quantity')}'),
      ReviewFact('Servicios', '${_count(localPayload['charges'])}'),
      if (_count(localPayload['discounts']) > 0)
        ReviewFact('Descuentos', '${_count(localPayload['discounts'])}'),
      if (localPayload['observations'] != null)
        ReviewFact('Observaciones', localPayload['observations'] as String),
    ],
    ReviewKind.orderStatus => [
      ReviewFact('Nuevo estado', _statusLabel(localPayload['status'])),
    ],
    ReviewKind.orderDeliver => [
      ReviewFact('Piezas devueltas', '${_sum(localPayload['garments'], 'quantity_delivered')}'),
      if (localPayload['payment'] case final Map<String, dynamic> payment)
        ReviewFact('Cobro al entregar', 'Q${payment['amount']}'),
    ],
    ReviewKind.orderCancel => [
      ReviewFact('Motivo', (localPayload['reason'] as String?) ?? '—'),
    ],
    ReviewKind.paymentCreate => [
      ReviewFact('Monto', 'Q${localPayload['amount']}'),
      ReviewFact('Método', _methodLabel(localPayload['method'])),
      if (localPayload['reference'] != null)
        ReviewFact('Referencia', localPayload['reference'] as String),
    ],
    ReviewKind.customerCreate || ReviewKind.customerUpdate => [
      ReviewFact('Nombre', (localPayload['full_name'] as String?) ?? '—'),
      if (localPayload['phone'] != null)
        ReviewFact('Teléfono', localPayload['phone'] as String),
      if (localPayload['nit'] != null) ReviewFact('NIT', localPayload['nit'] as String),
    ],
    ReviewKind.customerArchive => const [],
    ReviewKind.expenseCreate || ReviewKind.expenseUpdate => [
      ReviewFact('Concepto', (localPayload['concept'] as String?) ?? '—'),
      ReviewFact('Monto', 'Q${localPayload['amount'] ?? '0.00'}'),
      ReviewFact('Método', _methodLabel(localPayload['method'])),
      ReviewFact(
        'Estado',
        localPayload['status'] == 'pending' ? 'Queda pendiente de pago' : 'Pagado',
      ),
      if (localPayload['expense_date'] != null)
        ReviewFact('Fecha', localPayload['expense_date'] as String),
    ],
    ReviewKind.supplySaleCreate => [
      ReviewFact('Productos', '${_count(localPayload['lines'])}'),
      ReviewFact('Método', _methodLabel(localPayload['method'])),
      if (localPayload['sale_date'] != null)
        ReviewFact('Fecha', localPayload['sale_date'] as String),
      if (localPayload['nit'] != null) ReviewFact('NIT', localPayload['nit'] as String),
    ],
    ReviewKind.attendanceCreate || ReviewKind.attendanceUpdate => [
      if (localPayload['work_date'] != null)
        ReviewFact('Día', localPayload['work_date'] as String),
      if (localPayload['clock_in'] != null)
        ReviewFact('Entrada', _clock(localPayload['clock_in'])),
      if (localPayload['clock_out'] != null)
        ReviewFact('Salida', _clock(localPayload['clock_out'])),
      // Los minutos que alguien confirmó, no los que el sistema sugirió: la
      // sugerencia no viaja en el cuerpo y esa es toda la diferencia (D8).
      if (localPayload['overtime_minutes'] case final int minutes when minutes > 0)
        ReviewFact('Minutos extra', '$minutes'),
      if (localPayload['notes'] != null) ReviewFact('Notas', localPayload['notes'] as String),
    ],
    ReviewKind.unknown => const [],
  };

  static int _count(Object? list) => list is List ? list.length : 0;

  /// `06:50:00` → `6:50`. La hora tal como se dice, no como se transmite.
  static String _clock(Object? wire) {
    if (wire is! String) return '—';
    final parts = wire.split(':');
    if (parts.length < 2) return wire;
    return '${int.tryParse(parts[0]) ?? parts[0]}:${parts[1]}';
  }

  static int _sum(Object? list, String field) {
    if (list is! List) return 0;
    var total = 0;
    for (final line in list) {
      if (line is Map && line[field] is int) total += line[field] as int;
    }
    return total;
  }

  static String _methodLabel(Object? wire) =>
      wire == 'transfer' ? 'Transferencia' : 'Efectivo';

  // Los códigos son los de `OrderStatus.wire` y los del backend: `in_progress`
  // con g, que es como lo escribe `OrderStatus.IN_PROGRESS`.
  static String _statusLabel(Object? wire) => switch (wire) {
    'received' => 'recibido',
    'in_progress' => 'en proceso',
    'ready' => 'listo',
    'delivered' => 'entregado',
    'cancelled' => 'anulado',
    _ => '—',
  };
}
