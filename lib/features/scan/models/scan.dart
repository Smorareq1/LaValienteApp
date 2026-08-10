/// Lo que el servidor sacó de una foto de boleta (Plan 0003 §6, §7).
///
/// Nada de esto es un pedido: es un **borrador** que una persona revisa y
/// confirma. El principio inviolable del plan 0003 vive en esa distinción, y
/// aquí se nota en que ningún tipo de este archivo se puede guardar por su
/// cuenta — todo termina volcado en la toma de pedido del plan 0002, que es la
/// única pantalla que escribe.
library;

import '../../../core/money/fixed2.dart';

/// Debajo de esto el campo no se prellena: se muestra vacío y marcado.
const double kIllegibleBelow = 0.50;

/// Debajo de esto se prellena pero se marca «revisar» (§4).
const double kConfidentAtLeast = 0.85;

/// Un valor leído, con qué tan seguro y qué se vio literalmente.
class DraftField<T> {
  const DraftField({
    this.value,
    this.confidence = 0,
    this.rawText,
    this.needsReview = false,
  });

  static DraftField<T> fromJson<T>(
    Map<String, dynamic>? json,
    T? Function(Object?) parse,
  ) {
    if (json == null) return DraftField<T>();
    return DraftField<T>(
      value: parse(json['value']),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      rawText: json['raw_text'] as String?,
      needsReview: json['needs_review'] as bool? ?? false,
    );
  }

  final T? value;
  final double confidence;

  /// Los trazos tal como el modelo los leyó. Es lo que distingue una mala
  /// transcripción de una mala letra cuando quien captura no está de acuerdo.
  final String? rawText;

  final bool needsReview;

  bool get hasValue => value != null;
}

/// Una prenda ya resuelta contra el catálogo del dispositivo.
class DraftGarment {
  const DraftGarment({
    required this.garmentTypeId,
    required this.name,
    required this.quantity,
    this.confidence = 0,
    this.needsReview = false,
  });

  factory DraftGarment.fromJson(Map<String, dynamic> json) => DraftGarment(
    garmentTypeId: json['garment_type_id'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as int,
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    needsReview: json['needs_review'] as bool? ?? false,
  );

  final String garmentTypeId;
  final String name;
  final int quantity;
  final double confidence;
  final bool needsReview;
}

/// Una línea de servicio, en la forma que la toma de pedido ya entiende.
class DraftCharge {
  const DraftCharge({
    required this.serviceCode,
    this.optionCode,
    this.quantity = 100,
    this.amount,
    this.description = '',
    this.confidence = 0,
    this.needsReview = false,
  });

  factory DraftCharge.fromJson(Map<String, dynamic> json) => DraftCharge(
    serviceCode: json['service_code'] as String,
    optionCode: json['option_code'] as String?,
    // Centésimas, como el resto de la app: el servidor manda «12.5» y aquí
    // vale 1250.
    quantity: Fixed2.parse(json['quantity']?.toString()) ?? 100,
    amount: Fixed2.parse(json['amount']?.toString()),
    description: json['description'] as String? ?? '',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    needsReview: json['needs_review'] as bool? ?? false,
  );

  final String serviceCode;
  final String? optionCode;

  /// Centésimas: 100 es «uno».
  final int quantity;

  /// Centavos tecleados, solo para servicios de precio variable.
  final int? amount;

  final String description;
  final double confidence;
  final bool needsReview;
}

/// Un cliente que **se parece** al de la boleta (§7.5).
///
/// Una sugerencia y nunca una decisión: la pantalla pregunta «¿Es María López,
/// 5512-3456?» y alguien contesta. Aceptarla sola archivaría la ropa de una
/// persona bajo el nombre de otra, y le entregaría su historial.
class CustomerMatch {
  const CustomerMatch({
    required this.customerId,
    required this.fullName,
    required this.score,
    required this.matchedOn,
    this.phone,
  });

  factory CustomerMatch.fromJson(Map<String, dynamic> json) => CustomerMatch(
    customerId: json['customer_id'] as String,
    fullName: json['full_name'] as String,
    score: (json['score'] as num?)?.toDouble() ?? 0,
    matchedOn: json['matched_on'] as String? ?? 'name',
    phone: json['phone'] as String?,
  );

  final String customerId;
  final String fullName;
  final String? phone;
  final double score;

  /// `phone` o `name`. El teléfono es el único identificador real de la boleta:
  /// dos personas comparten nombre, nadie comparte número.
  final String matchedOn;

  bool get isExact => matchedOn == 'phone';
}

/// El prellenado de la toma de pedido.
class ScanDraft {
  const ScanDraft({
    this.orderDate = const DraftField<String>(),
    this.dailyNumber = const DraftField<int>(),
    this.bookletSerial = const DraftField<String>(),
    this.nit = const DraftField<String>(),
    this.weightLbs = const DraftField<int>(),
    this.observations = const DraftField<String>(),
    this.customerName = const DraftField<String>(),
    this.customerPhone = const DraftField<String>(),
    this.customerAddress = const DraftField<String>(),
    this.customerMatch,
    this.garments = const [],
    this.charges = const [],
    this.estimatedSubtotal = 0,
    this.estimatedTotal = 0,
    this.totalRead,
  });

  factory ScanDraft.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) => value?.toString();
    int? cents(Object? value) => Fixed2.parse(value?.toString());
    int? whole(Object? value) => value is int ? value : int.tryParse('$value');

    Map<String, dynamic>? at(String key) => json[key] as Map<String, dynamic>?;

    return ScanDraft(
      orderDate: DraftField.fromJson<String>(at('order_date'), text),
      dailyNumber: DraftField.fromJson<int>(at('daily_number'), whole),
      bookletSerial: DraftField.fromJson<String>(at('booklet_serial'), text),
      nit: DraftField.fromJson<String>(at('nit'), text),
      weightLbs: DraftField.fromJson<int>(at('weight_lbs'), cents),
      observations: DraftField.fromJson<String>(at('observations'), text),
      customerName: DraftField.fromJson<String>(at('customer_name'), text),
      customerPhone: DraftField.fromJson<String>(at('customer_phone'), text),
      customerAddress: DraftField.fromJson<String>(at('customer_address'), text),
      customerMatch: at('customer_match') == null
          ? null
          : CustomerMatch.fromJson(at('customer_match')!),
      garments: [
        for (final line in (json['garments'] as List<dynamic>? ?? const []))
          DraftGarment.fromJson(line as Map<String, dynamic>),
      ],
      charges: [
        for (final line in (json['charges'] as List<dynamic>? ?? const []))
          DraftCharge.fromJson(line as Map<String, dynamic>),
      ],
      estimatedSubtotal: cents(json['estimated_subtotal']) ?? 0,
      estimatedTotal: cents(json['estimated_total']) ?? 0,
      totalRead: cents(json['total_read']),
    );
  }

  final DraftField<String> orderDate;
  final DraftField<int> dailyNumber;
  final DraftField<String> bookletSerial;
  final DraftField<String> nit;

  /// Centésimas de libra.
  final DraftField<int> weightLbs;

  final DraftField<String> observations;
  final DraftField<String> customerName;
  final DraftField<String> customerPhone;
  final DraftField<String> customerAddress;
  final CustomerMatch? customerMatch;
  final List<DraftGarment> garments;
  final List<DraftCharge> charges;

  /// Centavos. Es una **vista previa**: la cifra oficial la pone el servidor al
  /// aplicar la operación (plan 0004 D10), igual que en la captura a mano.
  final int estimatedSubtotal;
  final int estimatedTotal;

  /// Lo que decía el papel, si se leyó. Se guarda aparte del calculado para
  /// poder enseñar los dos lados de una discrepancia sin cobrar nunca el leído.
  final int? totalRead;

  /// Cuántos campos quedaron marcados para revisar. Es lo que la pantalla dice
  /// arriba de todo, porque es lo único que la persona tiene que hacer.
  int get reviewCount => [
    orderDate,
    dailyNumber,
    bookletSerial,
    nit,
    weightLbs,
    observations,
    customerName,
    customerPhone,
  ].where((field) => field.needsReview).length +
      garments.where((line) => line.needsReview).length +
      charges.where((line) => line.needsReview).length;

  bool get isEmpty =>
      garments.isEmpty && charges.isEmpty && !customerName.hasValue;
}

/// La respuesta de `POST /scans` y `GET /scans/{id}`.
class ScanResult {
  const ScanResult({
    required this.id,
    required this.status,
    this.draft,
    this.warnings = const [],
    this.latencyMs,
    this.error,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    id: json['id'] as String,
    status: json['status'] as String,
    draft: json['draft'] == null
        ? null
        : ScanDraft.fromJson(json['draft'] as Map<String, dynamic>),
    warnings: [
      for (final code in (json['warnings'] as List<dynamic>? ?? const []))
        code as String,
    ],
    latencyMs: json['latency_ms'] as int?,
    error: json['error'] as String?,
  );

  final String id;
  final String status;
  final ScanDraft? draft;

  /// Códigos, no frases. El servidor es el único que puede detectarlos; la app
  /// es la que habla español — la misma regla del cierre y del motor de sync.
  final List<String> warnings;

  final int? latencyMs;
  final String? error;

  bool get isCompleted => status == 'completed' && draft != null;
}
