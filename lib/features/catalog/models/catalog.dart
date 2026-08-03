import '../../../core/database/app_database.dart';

/// Cómo resuelve su precio un servicio (plan 0001 §5.2).
enum PricingMode {
  /// Precio por unidad: lavado por libra, tiempo extra de secado, agregados.
  perUnit,

  /// El precio lo lleva una de las opciones: tinas, secado, lavado a mano.
  tiered,

  /// Se teclea al capturar: el mensajero decide qué cuesta llevarlo.
  variable;

  /// El feed manda el valor del enum del servidor (`per_unit`). Uno desconocido
  /// no se adivina: el catálogo lo edita un admin y una modalidad nueva tiene
  /// que llegar con su versión de app, no interpretarse a medias.
  static PricingMode? fromWire(String value) => switch (value) {
        'per_unit' => PricingMode.perUnit,
        'tiered' => PricingMode.tiered,
        'variable' => PricingMode.variable,
        _ => null,
      };
}

class ServiceType {
  const ServiceType({
    required this.id,
    required this.code,
    required this.name,
    required this.pricingMode,
    required this.options,
    this.unitLabel,
    this.sortOrder = 0,
  });

  final String id;
  final String code;
  final String name;

  /// `null` si el servidor mandó una modalidad que esta versión no conoce.
  final PricingMode? pricingMode;

  final String? unitLabel;
  final int sortOrder;
  final List<ServiceOption> options;
}

class ServiceOption {
  const ServiceOption({
    required this.id,
    required this.serviceTypeId,
    required this.code,
    required this.name,
    this.minQuantity,
    this.maxQuantity,
    this.sortOrder = 0,
  });

  factory ServiceOption.fromRow(ServiceOptionEntry row) => ServiceOption(
        id: row.id,
        serviceTypeId: row.serviceTypeId,
        code: row.code,
        name: row.name,
        minQuantity: row.minQuantity,
        maxQuantity: row.maxQuantity,
        sortOrder: row.sortOrder,
      );

  final String id;
  final String serviceTypeId;
  final String code;
  final String name;
  final int? minQuantity;
  final int? maxQuantity;
  final int sortOrder;

  /// Si esta opción es la que corresponde a [quantity] piezas.
  bool covers(int quantity) {
    if (minQuantity != null && quantity < minQuantity!) return false;
    if (maxQuantity != null && quantity > maxQuantity!) return false;
    return true;
  }
}

class GarmentType {
  const GarmentType({
    required this.id,
    required this.name,
    this.notes,
    this.sortOrder = 0,
  });

  factory GarmentType.fromRow(GarmentTypeEntry row) => GarmentType(
        id: row.id,
        name: row.name,
        notes: row.notes,
        sortOrder: row.sortOrder,
      );

  final String id;
  final String name;
  final String? notes;
  final int sortOrder;
}

/// Un precio con su ventana de vigencia. Los precios no se editan: se sustituyen
/// cerrando el anterior y abriendo otro (plan 0001 D1), y por eso un pedido de
/// hace un mes se puede recalcular con el precio que regía ese día.
class ServicePrice {
  const ServicePrice({
    required this.id,
    required this.serviceTypeId,
    required this.amount,
    required this.validFrom,
    this.serviceOptionId,
    this.validTo,
  });

  factory ServicePrice.fromRow(ServicePriceEntry row) => ServicePrice(
        id: row.id,
        serviceTypeId: row.serviceTypeId,
        serviceOptionId: row.serviceOptionId,
        amount: row.price,
        validFrom: row.validFrom,
        validTo: row.validTo,
      );

  final String id;
  final String serviceTypeId;
  final String? serviceOptionId;

  /// Monto exacto tal como lo mandó el servidor (`"12.50"`). Sigue siendo texto
  /// a propósito: el total oficial lo calcula el servidor al aplicar (D10) y
  /// convertirlo a `double` aquí solo introduciría diferencias de centavos.
  final String amount;

  /// Fechas de negocio en `YYYY-MM-DD`, comparables como texto por serlo.
  final String validFrom;
  final String? validTo;

  bool covers(String isoDate) =>
      validFrom.compareTo(isoDate) <= 0 && (validTo == null || isoDate.compareTo(validTo!) <= 0);
}
