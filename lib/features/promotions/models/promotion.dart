import 'dart:convert';

import '../../../core/database/app_database.dart';
import '../../../core/money/fixed2.dart';

/// Cómo rebaja una promoción (plan 0001 §5.4).
enum DiscountType {
  /// Un porcentaje de lo que suman las líneas a las que aplica.
  percentage('percentage', 'Porcentaje'),

  /// Una cantidad fija de quetzales, sin importar el tamaño del pedido.
  fixedAmount('fixed_amount', 'Monto fijo'),

  /// El precio al que queda el servicio; el descuento es la diferencia.
  specialPrice('special_price', 'Precio especial');

  const DiscountType(this.wire, this.label);

  final String wire;
  final String label;

  /// `null` si el servidor estrenó un tipo que esta versión no conoce. No se
  /// adivina: una promoción calculada a medias sale en el total de un cliente.
  static DiscountType? fromWire(String value) {
    for (final type in values) {
      if (type.wire == value) return type;
    }
    return null;
  }
}

/// Una promoción tal como bajó del feed.
///
/// Es el gemelo de `BACKEND/src/modules/promotions/models.py` y tiene que dar
/// el mismo número, con la misma salvedad que el resto del cálculo local: esto
/// es la **vista previa** del mostrador y la cifra oficial es la que devuelve el
/// servidor al aplicar la operación (D5).
class Promotion {
  const Promotion({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.value,
    required this.validFrom,
    this.description,
    this.appliesToServiceCodes,
    this.validTo,
    this.isActive = true,
  });

  factory Promotion.fromRow(PromotionEntry row) => Promotion(
    id: row.id,
    code: row.code,
    name: row.name,
    description: row.description,
    discountType: DiscountType.fromWire(row.discountType),
    value: Fixed2.parse(row.value) ?? 0,
    appliesToServiceCodes: decodeServiceCodes(row.appliesToServiceCodes),
    validFrom: row.validFrom,
    validTo: row.validTo,
    isActive: row.isActive,
  );

  /// Lo que devuelve `GET/POST/PATCH /promotions`, que es la pantalla de
  /// administración (§10.3) y la única parte de este módulo que va en línea.
  factory Promotion.fromJson(Map<String, dynamic> json) {
    final codes = json['applies_to_service_codes'];
    return Promotion(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: DiscountType.fromWire(json['discount_type'] as String),
      value: Fixed2.parse(json['value'] as String) ?? 0,
      appliesToServiceCodes: codes is List ? [for (final item in codes) '$item'] : null,
      validFrom: json['valid_from'] as String,
      validTo: json['valid_to'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  final String id;
  final String code;
  final String name;
  final String? description;

  /// `null` si el feed mandó un tipo que esta versión no sabe calcular.
  final DiscountType? discountType;

  /// Centésimas, como todo lo demás: `50%` es 5000 y `Q35.00` es 3500. Que un
  /// porcentaje y un precio compartan escala no es casualidad — el servidor los
  /// guarda en la misma columna por la misma razón.
  final int value;

  /// Los servicios a los que muerde, o `null` = el pedido entero.
  final List<String>? appliesToServiceCodes;

  /// Fechas de negocio en `YYYY-MM-DD`, comparables como texto por serlo.
  final String validFrom;
  final String? validTo;

  final bool isActive;

  /// Si está en vigor el día [isoDate].
  bool covers(String isoDate) {
    if (!isActive) return false;
    return validFrom.compareTo(isoDate) <= 0 &&
        (validTo == null || isoDate.compareTo(validTo!) <= 0);
  }

  /// Si esta promoción toca un cargo de [serviceCode].
  bool appliesTo(String serviceCode) {
    final codes = appliesToServiceCodes;
    if (codes == null) return true;
    return codes.contains(serviceCode);
  }

  /// Cuánto rebaja sobre [applicableBase] (centavos), nunca menos de cero.
  ///
  /// Se redondea aquí y una sola vez, igual que el backend: el descuento es una
  /// línea impresa de la boleta, y una línea que no cuadra con el total impreso
  /// es una discusión en el mostrador.
  int discountOn(int applicableBase) {
    final raw = switch (discountType) {
      // `value` viene en centésimas de punto porcentual; dividir entre 10000
      // deshace las dos escalas de un solo golpe, con medio punto sumado antes
      // para que el truncamiento entero se comporte como redondeo half-up.
      DiscountType.percentage => (applicableBase * value * 2 + 10000) ~/ 20000,
      DiscountType.fixedAmount => value,
      DiscountType.specialPrice => applicableBase - value,
      // Sin tipo conocido no hay descuento que estimar; la pantalla lo dice y
      // el servidor sigue siendo quien decide.
      null => 0,
    };
    return raw < 0 ? 0 : raw;
  }

  /// Decodifica la lista JSON de la fila espejo.
  ///
  /// Un texto ilegible **no** se toma como "aplica a todo el pedido": se
  /// devuelve una lista vacía, que no muerde nada. Una promoción que se nota
  /// rota es mejor que una que rebaja de más sin que nadie lo pidiera.
  static List<String>? decodeServiceCodes(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [for (final item in decoded) '$item'];
    } on FormatException {
      return const [];
    }
  }
}
