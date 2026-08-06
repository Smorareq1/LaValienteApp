/// Cuánto cuesta un pedido, calculado en el dispositivo (plan 0001 §6).
///
/// Es el gemelo de `BACKEND/src/modules/orders/pricing.py` y tiene que dar el
/// mismo número: el mostrador captura sin red y necesita ver el total mientras
/// lo arma. Pero **la cifra oficial sigue siendo la del servidor** (D5, y D10
/// del plan 0004): esto es una vista previa, y si el precio cambió mientras el
/// dispositivo estaba fuera de línea, manda lo que devuelva el push.
///
/// Una diferencia deliberada con el backend: allá un pedido mal armado lanza
/// `ConflictError`; aquí sale como una lista de faltantes. Capturar es un
/// proceso —hay minutos en los que el pedido está a medias— y una excepción por
/// cada tecla convertiría el footer en un campo minado. La pantalla usa esa
/// lista para decir "falta un cargo" y para dejar el botón de guardar apagado.
library;

import '../../../core/money/fixed2.dart';
import '../../catalog/models/catalog.dart';
import '../../promotions/models/promotion.dart';

/// Lavado por libra: el único servicio cuya cantidad también es un campo del
/// encabezado, y por eso el único que hay que vigilar contra él.
const String kWashByWeightCode = 'wash_by_weight';

/// Lavado a mano, cobrado por nivel de piezas (N2/N3/N4).
const String kHandWashCode = 'hand_wash';

/// Una línea tal como la capturó el mostrador: qué, cuántos, y nada más.
class ChargeDraft {
  const ChargeDraft({
    required this.serviceCode,
    this.optionCode,
    this.quantity = 100,
    this.amount,
  });

  final String serviceCode;
  final String? optionCode;

  /// Centésimas: 100 es "uno". Fraccionaria solo en lavado por peso.
  final int quantity;

  /// Centavos tecleados. Solo para servicios `variable`, donde el monto es lo
  /// que cobró el motorista y no sale de ningún catálogo.
  final int? amount;
}

/// Dinero de menos. O lo decide una promoción, o lo decide un admin a mano.
sealed class DiscountDraft {
  const DiscountDraft();
}

/// Un monto tecleado con su motivo. Exige `orders.manual_discount`.
class ManualDiscount extends DiscountDraft {
  const ManualDiscount({required this.description, required this.amount});

  final String description;

  /// Centavos.
  final int amount;
}

/// Una promoción elegida por su código.
///
/// No lleva monto a propósito (D5): la app estima para el footer, pero lo que
/// viaja es el código y quien decide cuánto rebaja es el servidor.
class PromotionDiscount extends DiscountDraft {
  const PromotionDiscount(this.promotionCode);

  final String promotionCode;
}

/// Una línea ya resuelta, lista para guardarse como copia congelada (D2).
class PricedCharge {
  const PricedCharge({
    required this.serviceCode,
    required this.serviceTypeId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.optionCode,
    this.serviceOptionId,
  });

  final String serviceCode;
  final String? optionCode;
  final String serviceTypeId;
  final String? serviceOptionId;
  final String description;
  final int quantity;
  final int unitPrice;
  final int amount;
}

class PricedDiscount {
  const PricedDiscount({
    required this.description,
    required this.amount,
    this.promotionId,
    this.promotionCode,
  });

  /// Copia congelada del nombre de la promoción, o el motivo que se tecleó
  /// (D2): renombrar la promoción mañana no reescribe la boleta de hoy.
  final String description;

  final int amount;

  /// `null` en un descuento manual.
  final String? promotionId;
  final String? promotionCode;
}

/// El resultado del cálculo, con lo que impide guardar y lo que solo avisa.
class PricedOrder {
  const PricedOrder({
    required this.charges,
    required this.discounts,
    required this.subtotal,
    required this.discountTotal,
    required this.total,
    this.warnings = const [],
    this.blockers = const [],
    this.discountIssues = const [],
  });

  final List<PricedCharge> charges;
  final List<PricedDiscount> discounts;
  final int subtotal;
  final int discountTotal;
  final int total;

  /// Cosas que vale la pena decir en voz alta pero que no pueden detener al
  /// mostrador. La boleta de papel las resolvía con criterio humano y esto
  /// también.
  final List<String> warnings;

  /// Lo que sí detiene: sin esto el total estaría mal.
  final List<String> blockers;

  /// Los de [blockers] que salieron de la sección de descuentos, para que la
  /// sección los pueda mostrar donde están. El footer solo enseña el primero de
  /// todos, y una promoción rechazada tiene que explicarse junto a su chip.
  final List<String> discountIssues;

  bool get canSave => blockers.isEmpty && charges.isNotEmpty;
}

/// El catálogo congelado en una fecha, indexado como lo lee el motor.
class OrderPriceBook {
  OrderPriceBook({
    required List<ServiceType> services,
    required List<ServicePrice> prices,
    required this.onDate,
  }) : _services = {for (final service in services) service.code: service},
       _prices = prices.where((price) => price.covers(onDate)).toList();

  /// Fecha de negocio en `YYYY-MM-DD`.
  final String onDate;

  final Map<String, ServiceType> _services;
  final List<ServicePrice> _prices;

  ServiceType? service(String code) => _services[code];

  /// El precio vigente, o `null` si no hay ninguno.
  ///
  /// Nunca se cae a cero: un pedido que en silencio no cuesta nada es mucho peor
  /// que uno que se niega a tomarse.
  int? unitPrice(ServiceType service, ServiceOption? option) {
    for (final price in _prices) {
      if (price.serviceTypeId != service.id) continue;
      if (price.serviceOptionId != option?.id) continue;
      return Fixed2.parse(price.amount);
    }
    return null;
  }
}

/// Las promociones que el dispositivo conoce, para una fecha de pedido.
///
/// Guarda **todas** las que bajaron y no solo las vigentes, igual que el
/// servidor (plan 0004 §8): así se puede decir "esa promoción venció el 30 de
/// julio" en vez de "no existe" cuando alguien captura un pedido atrasado.
class PromotionBook {
  PromotionBook({required List<Promotion> promotions, required this.onDate})
    : _byCode = {for (final promotion in promotions) promotion.code: promotion};

  PromotionBook.empty({required this.onDate}) : _byCode = const {};

  /// Fecha de negocio en `YYYY-MM-DD`.
  final String onDate;

  final Map<String, Promotion> _byCode;

  /// Todas las conocidas, vigentes o no.
  Iterable<Promotion> get all => _byCode.values;

  /// Las que se pueden ofrecer en [onDate] — los chips de la sección 6.
  List<Promotion> get live =>
      [for (final promotion in _byCode.values) if (promotion.covers(onDate)) promotion];

  Promotion? byCode(String code) => _byCode[code];
}

/// Convierte lo capturado en lo que se debe (§6.2).
PricedOrder priceOrder({
  required List<ChargeDraft> charges,
  required List<DiscountDraft> discounts,
  required OrderPriceBook book,
  PromotionBook? promotions,
  int? weightLbs,
  int totalPieces = 0,
}) {
  final blockers = <String>[];
  final priced = <PricedCharge>[];

  for (final draft in charges) {
    final line = _priceCharge(draft, book, blockers);
    if (line != null) priced.add(line);
  }

  blockers.addAll(_weightIssues(charges, weightLbs));

  var subtotal = 0;
  for (final line in priced) {
    subtotal += line.amount;
  }

  final discountIssues = <String>[];
  final pricedDiscounts = _priceDiscounts(
    discounts,
    priced: priced,
    promotions: promotions ?? PromotionBook.empty(onDate: book.onDate),
    blockers: discountIssues,
  );
  var discountTotal = 0;
  for (final item in pricedDiscounts) {
    discountTotal += item.amount;
  }

  if (discountTotal > subtotal) {
    // §6.2 paso 4. Una boleta que le debe dinero al cliente no es un descuento,
    // es un error de dedo.
    discountIssues.add('El descuento no puede ser mayor que el subtotal.');
    discountTotal = subtotal;
  }

  return PricedOrder(
    charges: priced,
    discounts: pricedDiscounts,
    subtotal: subtotal,
    discountTotal: discountTotal,
    total: subtotal - discountTotal,
    warnings: _handWashWarnings(charges, book, totalPieces),
    blockers: [...blockers, ...discountIssues],
    discountIssues: discountIssues,
  );
}

/// Resuelve los descuentos de la boleta (§6.2 paso 3).
///
/// Una promoción que no se puede aplicar sale como bloqueo y no se descarta en
/// silencio: quien la eligió cree que el cliente ya tiene su rebaja, y guardar
/// el pedido sin ella lo dejaría cobrando de más sin que nadie se enterara.
List<PricedDiscount> _priceDiscounts(
  List<DiscountDraft> discounts, {
  required List<PricedCharge> priced,
  required PromotionBook promotions,
  required List<String> blockers,
}) {
  final result = <PricedDiscount>[];
  final applied = <String>{};

  for (final draft in discounts) {
    switch (draft) {
      case ManualDiscount(:final description, :final amount):
        if (amount <= 0) continue;
        result.add(PricedDiscount(description: description, amount: amount));

      case PromotionDiscount(:final promotionCode):
        if (!applied.add(promotionCode)) {
          blockers.add('La promoción «$promotionCode» está puesta dos veces.');
          continue;
        }

        final promotion = promotions.byCode(promotionCode);
        if (promotion == null) {
          blockers.add('No hay ninguna promoción con el código «$promotionCode».');
          continue;
        }
        if (!promotion.covers(promotions.onDate)) {
          blockers.add(
            '«${promotion.name}» no está vigente el ${_readableDate(promotions.onDate)}.',
          );
          continue;
        }
        if (promotion.discountType == null) {
          blockers.add(
            'Esta versión de la app no sabe calcular «${promotion.name}».',
          );
          continue;
        }

        final amount = promotion.discountOn(_applicableBase(promotion, priced));
        if (amount <= 0) {
          blockers.add('«${promotion.name}» no rebaja nada en este pedido.');
          continue;
        }

        final name = promotion.name;
        result.add(
          PricedDiscount(
            description: name.length <= 160 ? name : name.substring(0, 160),
            amount: amount,
            promotionId: promotion.id,
            promotionCode: promotion.code,
          ),
        );
    }
  }

  return result;
}

/// Lo que suman las líneas sobre las que muerde [promotion].
///
/// Se filtra por el código del servicio que lleva cada línea ya cotizada, y no
/// emparejando con lo capturado: aquí una línea sin precio vigente se cae del
/// cálculo, y aparearlas por posición pondría el descuento sobre otro servicio.
int _applicableBase(Promotion promotion, List<PricedCharge> priced) {
  var base = 0;
  for (final line in priced) {
    if (promotion.appliesTo(line.serviceCode)) base += line.amount;
  }
  return base;
}

/// Lo que [promotion] rebajaría sobre unas líneas ya cotizadas, para escribirlo
/// en su chip antes de que nadie la elija. Cero significa que no muerde nada.
int estimatePromotion(Promotion promotion, List<PricedCharge> lines) =>
    promotion.discountOn(_applicableBase(promotion, lines));

/// `2026-07-30` → `30/07/2026`, para decirlo en un mensaje sin arrastrar el
/// formateador de fechas del design system hasta el dominio.
String _readableDate(String isoDate) {
  final parts = isoDate.split('-');
  return parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : isoDate;
}

ServiceOption? _optionByCode(ServiceType service, String? code) {
  if (code == null) return null;
  for (final option in service.options) {
    if (option.code == code) return option;
  }
  return null;
}

PricedCharge? _priceCharge(ChargeDraft draft, OrderPriceBook book, List<String> blockers) {
  final service = book.service(draft.serviceCode);
  if (service == null) {
    blockers.add('El servicio «${draft.serviceCode}» ya no está en el catálogo.');
    return null;
  }

  if (service.pricingMode == null) {
    // El servidor mandó una modalidad de cobro que esta versión no conoce. No se
    // adivina: cobrarla como si fuera por unidad daría un total inventado.
    blockers.add('Esta versión de la app no sabe cómo se cobra ${service.name}.');
    return null;
  }

  if (service.pricingMode == PricingMode.variable) {
    final amount = draft.amount;
    if (amount == null || amount <= 0) {
      blockers.add('${service.name} se cobra a lo que costó, así que necesita un monto.');
      return null;
    }
    // La cantidad se queda en uno: la línea *es* la tarifa.
    return PricedCharge(
      serviceCode: service.code,
      serviceTypeId: service.id,
      description: service.name,
      quantity: 100,
      unitPrice: amount,
      amount: amount,
    );
  }

  if (draft.quantity <= 0) return null;

  ServiceOption? option;
  if (service.pricingMode == PricingMode.tiered) {
    option = _optionByCode(service, draft.optionCode);
    if (option == null) {
      blockers.add('${service.name} se cobra por opción y hay que elegir una.');
      return null;
    }
  }

  final unitPrice = book.unitPrice(service, option);
  if (unitPrice == null) {
    final what = option == null ? service.name : '${service.name} — ${option.name}';
    blockers.add('«$what» no tiene precio vigente el ${book.onDate}.');
    return null;
  }

  final description = option == null ? service.name : '${service.name} — ${option.name}';
  return PricedCharge(
    serviceCode: service.code,
    optionCode: option?.code,
    serviceTypeId: service.id,
    serviceOptionId: option?.id,
    description: description.length <= 160 ? description : description.substring(0, 160),
    quantity: draft.quantity,
    unitPrice: unitPrice,
    amount: Fixed2.multiply(unitPrice, draft.quantity),
  );
}

/// §6.3: el peso del encabezado y el peso que se cobra son un solo número.
///
/// Se capturan dos veces —una como campo grande arriba, otra como la cantidad de
/// la línea por libra— y dejarlos separarse produciría una boleta que dice 12 lb
/// y cobra 21.
List<String> _weightIssues(List<ChargeDraft> charges, int? weightLbs) {
  final byWeight = charges.where((line) => line.serviceCode == kWashByWeightCode);
  if (byWeight.isEmpty) return const [];

  if (weightLbs == null || weightLbs <= 0) {
    return const ['El lavado por peso necesita las libras.'];
  }

  var billed = 0;
  for (final line in byWeight) {
    billed += line.quantity;
  }
  if (billed != weightLbs) {
    return [
      'El peso de la boleta (${Fixed2.format(weightLbs)}) no coincide '
          'con las libras que se están cobrando (${Fixed2.format(billed)}).',
    ];
  }
  return const [];
}

/// §6.3: un nivel fuera de su rango de piezas se avisa, nunca se bloquea.
///
/// El mostrador elige el nivel con el cliente enfrente; la boleta de papel lo
/// resolvía con criterio, y negar la venta por eso sería peor que decirlo.
List<String> _handWashWarnings(
  List<ChargeDraft> charges,
  OrderPriceBook book,
  int totalPieces,
) {
  final warnings = <String>[];
  for (final line in charges) {
    if (line.serviceCode != kHandWashCode || line.optionCode == null) continue;
    if (line.quantity <= 0) continue;

    final service = book.service(line.serviceCode);
    final option = service == null ? null : _optionByCode(service, line.optionCode);
    if (option == null) continue;

    final low = option.minQuantity;
    final high = option.maxQuantity;
    if (low == null && high == null) continue;
    if (option.covers(totalPieces)) continue;

    final span = high != null ? 'de ${low ?? 0} a $high' : '${low ?? 0} o más';
    warnings.add('${option.name} es para $span piezas y el pedido lleva $totalPieces.');
  }
  return warnings;
}
