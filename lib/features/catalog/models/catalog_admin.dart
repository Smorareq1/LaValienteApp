import '../../../core/money/fixed2.dart';
import 'catalog.dart';

/// Un servicio tal como lo administra el §10.1.
///
/// No es [ServiceType]: aquel es lo que la toma de pedido necesita para cobrar,
/// y esto es lo que hace falta para **cambiarlo** —si está activo, su versión y
/// el precio que rige hoy—. El espejo local no guarda nada de eso porque el
/// mostrador no lo usa.
class AdminService {
  const AdminService({
    required this.id,
    required this.code,
    required this.name,
    required this.pricingMode,
    required this.isActive,
    required this.sortOrder,
    required this.version,
    required this.options,
    this.unitLabel,
    this.currentPrice,
  });

  factory AdminService.fromJson(Map<String, dynamic> json) => AdminService(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    pricingMode: PricingMode.fromWire(json['pricing_mode'] as String),
    isActive: json['is_active'] as bool,
    sortOrder: json['sort_order'] as int,
    version: json['version'] as int,
    unitLabel: json['unit_label'] as String?,
    currentPrice: Fixed2.parse(json['current_price'] as String?),
    options: [
      for (final option in (json['options'] as List<dynamic>? ?? const []))
        AdminServiceOption.fromJson(option as Map<String, dynamic>),
    ],
  );

  final String id;
  final String code;
  final String name;

  /// `null` si el servidor mandó una modalidad que esta versión no conoce.
  final PricingMode? pricingMode;

  final bool isActive;
  final int sortOrder;
  final int version;
  final String? unitLabel;

  /// Centavos. Solo para `per_unit`: un servicio por tramos cobra por opción.
  final int? currentPrice;

  final List<AdminServiceOption> options;

  /// Cómo se explica la modalidad en una línea, que es lo que la lista enseña
  /// bajo el nombre.
  String get modeLabel => switch (pricingMode) {
    PricingMode.perUnit => unitLabel == null
        ? 'Precio por unidad'
        : 'Precio por $unitLabel',
    PricingMode.tiered => 'Precio por tramos · ${options.length} opciones',
    PricingMode.variable => 'Precio que se teclea al capturar',
    null => 'Modalidad que esta versión no conoce',
  };

  /// Un servicio de precio variable no tiene precio que administrar: lo pone
  /// quien captura, cada vez.
  bool get hasPriceHistory => pricingMode != PricingMode.variable;
}

class AdminServiceOption {
  const AdminServiceOption({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
    required this.sortOrder,
    required this.version,
    this.minQuantity,
    this.maxQuantity,
    this.currentPrice,
  });

  factory AdminServiceOption.fromJson(Map<String, dynamic> json) =>
      AdminServiceOption(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        isActive: json['is_active'] as bool,
        sortOrder: json['sort_order'] as int,
        version: json['version'] as int,
        minQuantity: json['min_quantity'] as int?,
        maxQuantity: json['max_quantity'] as int?,
        currentPrice: Fixed2.parse(json['current_price'] as String?),
      );

  final String id;
  final String code;
  final String name;
  final bool isActive;
  final int sortOrder;
  final int version;
  final int? minQuantity;
  final int? maxQuantity;

  /// Centavos.
  final int? currentPrice;

  /// `de 1 a 5 piezas`, `desde 6`, o vacío si no tiene tramo.
  String get rangeLabel => switch ((minQuantity, maxQuantity)) {
    (final int min, final int max) => 'de $min a $max',
    (final int min, null) => 'desde $min',
    (null, final int max) => 'hasta $max',
    _ => '',
  };
}

/// Un tipo de prenda del §10.2. Los 21 de la boleta vienen sembrados.
class AdminGarment {
  const AdminGarment({
    required this.id,
    required this.name,
    required this.isActive,
    required this.sortOrder,
    required this.version,
    this.notes,
  });

  factory AdminGarment.fromJson(Map<String, dynamic> json) => AdminGarment(
    id: json['id'] as String,
    name: json['name'] as String,
    isActive: json['is_active'] as bool,
    sortOrder: json['sort_order'] as int,
    version: json['version'] as int,
    notes: json['notes'] as String?,
  );

  final String id;
  final String name;
  final bool isActive;
  final int sortOrder;
  final int version;
  final String? notes;
}

/// Una ventana de precio, como la devuelve el historial.
///
/// Los precios no se editan: se sustituyen cerrando el anterior y abriendo otro
/// (plan 0001 D1). Por eso el historial no es un adorno — es lo que deja que un
/// pedido de hace un mes siga valiendo lo que valía ese día.
class AdminPrice {
  const AdminPrice({
    required this.id,
    required this.amount,
    required this.validFrom,
    this.serviceOptionId,
    this.validTo,
  });

  factory AdminPrice.fromJson(Map<String, dynamic> json) => AdminPrice(
    id: json['id'] as String,
    amount: Fixed2.parse(json['price'] as String?) ?? 0,
    validFrom: json['valid_from'] as String,
    serviceOptionId: json['service_option_id'] as String?,
    validTo: json['valid_to'] as String?,
  );

  final String id;

  /// Centavos.
  final int amount;

  final String validFrom;
  final String? validTo;
  final String? serviceOptionId;

  bool get isCurrent => validTo == null;
}
