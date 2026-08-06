import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/catalog/models/catalog.dart';
import 'package:la_valiente/features/orders/domain/order_pricing.dart';
import 'package:la_valiente/features/promotions/models/promotion.dart';

/// El catálogo sembrado, reducido a lo que estas pruebas necesitan.
ServiceType _service(
  String code,
  String name,
  PricingMode mode, {
  List<ServiceOption> options = const [],
  String? unitLabel,
}) {
  return ServiceType(
    id: 'st-$code',
    code: code,
    name: name,
    pricingMode: mode,
    unitLabel: unitLabel,
    options: options,
  );
}

ServiceOption _option(String service, String code, String name, {int? min, int? max}) {
  return ServiceOption(
    id: 'so-$service-$code',
    serviceTypeId: 'st-$service',
    code: code,
    name: name,
    minQuantity: min,
    maxQuantity: max,
  );
}

ServicePrice _price(
  String service,
  String amount, {
  String? option,
  String from = '2026-01-01',
  String? to,
}) {
  return ServicePrice(
    id: 'sp-$service-${option ?? ''}',
    serviceTypeId: 'st-$service',
    serviceOptionId: option == null ? null : 'so-$service-$option',
    amount: amount,
    validFrom: from,
    validTo: to,
  );
}

final _services = [
  _service(kWashByWeightCode, 'Lavado por peso', PricingMode.perUnit, unitLabel: 'lb'),
  _service(
    'wash_tub',
    'Lavado por tina',
    PricingMode.tiered,
    options: [
      _option('wash_tub', 'G', 'Tina grande'),
      _option('wash_tub', 'P', 'Tina pequeña'),
    ],
  ),
  _service(
    kHandWashCode,
    'Lavado a mano',
    PricingMode.tiered,
    options: [
      _option(kHandWashCode, 'N2', 'Nivel 2 (1 a 4 piezas)', min: 1, max: 4),
      _option(kHandWashCode, 'N3', 'Nivel 3 (5 a 9 piezas)', min: 5, max: 9),
    ],
  ),
  _service('extra_softener', 'Rins (suavizante)', PricingMode.perUnit),
  _service('delivery', 'Entrega a domicilio', PricingMode.variable),
];

final _prices = [
  _price(kWashByWeightCode, '2.50'),
  _price('wash_tub', '30.00', option: 'G'),
  _price('wash_tub', '20.00', option: 'P'),
  _price(kHandWashCode, '5.00', option: 'N2'),
  _price(kHandWashCode, '10.00', option: 'N3'),
  _price('extra_softener', '10.00'),
];

Promotion _promotion(
  String code,
  String name,
  DiscountType type,
  int value, {
  List<String>? services,
  String from = '2026-01-01',
  String? to,
  bool active = true,
}) {
  return Promotion(
    id: 'promo-$code',
    code: code,
    name: name,
    discountType: type,
    value: value,
    appliesToServiceCodes: services,
    validFrom: from,
    validTo: to,
    isActive: active,
  );
}

/// Las promociones sembradas, adaptadas al catálogo de estas pruebas.
PromotionBook _promotions({String onDate = '2026-08-03'}) {
  return PromotionBook(
    onDate: onDate,
    promotions: [
      _promotion(
        'domicilio_50',
        '50% en domicilio',
        DiscountType.percentage,
        5000,
        services: ['delivery'],
      ),
      _promotion('rins_q5', 'Q5 menos en rins', DiscountType.fixedAmount, 500),
      _promotion(
        'tina_jul',
        'Tina a Q25 en julio',
        DiscountType.specialPrice,
        2500,
        services: ['wash_tub'],
        from: '2026-07-15',
        to: '2026-07-30',
      ),
      _promotion(
        'apagada',
        'Promo apagada',
        DiscountType.percentage,
        1000,
        active: false,
      ),
    ],
  );
}

OrderPriceBook _book({String onDate = '2026-08-03', List<ServicePrice>? prices}) {
  return OrderPriceBook(
    services: _services,
    prices: prices ?? _prices,
    onDate: onDate,
  );
}

void main() {
  group('líneas', () {
    test('un servicio por unidad se multiplica por su cantidad', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'extra_softener', quantity: 300)],
        discounts: const [],
        book: _book(),
      );

      expect(result.charges.single.description, 'Rins (suavizante)');
      expect(result.charges.single.amount, 3000);
      expect(result.subtotal, 3000);
      expect(result.blockers, isEmpty);
    });

    test('un servicio escalonado toma el precio de su opción y lo dice en la línea', () {
      final result = priceOrder(
        charges: [
          const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G'),
          const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'P'),
        ],
        discounts: const [],
        book: _book(),
      );

      expect(result.charges.map((line) => line.description), [
        'Lavado por tina — Tina grande',
        'Lavado por tina — Tina pequeña',
      ]);
      expect(result.subtotal, 5000);
    });

    test('un servicio variable cobra lo que se tecleó, sin catálogo detrás', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'delivery', amount: 2500)],
        discounts: const [],
        book: _book(),
      );

      expect(result.charges.single.amount, 2500);
      expect(result.charges.single.quantity, 100);
    });

    test('un servicio variable sin monto no se cobra en cero: se bloquea', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'delivery')],
        discounts: const [],
        book: _book(),
      );

      expect(result.charges, isEmpty);
      expect(result.blockers.single, contains('necesita un monto'));
    });

    test('un escalonado sin opción elegida se bloquea', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub')],
        discounts: const [],
        book: _book(),
      );

      expect(result.blockers.single, contains('hay que elegir una'));
    });

    test('sin precio vigente en la fecha no se inventa un cero', () {
      final book = _book(
        onDate: '2025-12-31',
        prices: [_price('extra_softener', '10.00', from: '2026-01-01')],
      );
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'extra_softener')],
        discounts: const [],
        book: book,
      );

      expect(result.charges, isEmpty);
      expect(result.blockers.single, contains('no tiene precio vigente'));
    });

    test('el precio que rige es el de la fecha del pedido, no el de hoy', () {
      final book = _book(
        onDate: '2026-06-15',
        prices: [
          _price('extra_softener', '8.00', from: '2026-01-01', to: '2026-06-30'),
          _price('extra_softener', '10.00', from: '2026-07-01'),
        ],
      );
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'extra_softener')],
        discounts: const [],
        book: book,
      );

      expect(result.charges.single.unitPrice, 800);
    });
  });

  group('redondeo', () {
    test('cada línea se redondea antes de sumarse', () {
      // 12.5 lb × Q2.50 = Q31.25 exacto; lo que se comprueba es que el subtotal
      // sea la suma de las líneas impresas y no de valores sin redondear.
      final result = priceOrder(
        charges: [
          const ChargeDraft(serviceCode: kWashByWeightCode, quantity: 1250),
          const ChargeDraft(serviceCode: 'extra_softener'),
        ],
        discounts: const [],
        book: _book(),
        weightLbs: 1250,
      );

      expect(result.charges.first.amount, 3125);
      expect(result.subtotal, result.charges.fold<int>(0, (sum, l) => sum + l.amount));
      expect(result.subtotal, 4125);
    });
  });

  group('peso', () {
    test('cobrar por peso sin libras se bloquea', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: kWashByWeightCode, quantity: 0)],
        discounts: const [],
        book: _book(),
      );

      expect(result.blockers.single, contains('necesita las libras'));
    });

    test('el peso del encabezado y el que se cobra tienen que ser el mismo', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: kWashByWeightCode, quantity: 2100)],
        discounts: const [],
        book: _book(),
        weightLbs: 1200,
      );

      expect(result.blockers.single, contains('no coincide'));
    });
  });

  group('descuentos', () {
    test('restan del subtotal', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [ManualDiscount(description: 'Cliente frecuente', amount: 500)],
        book: _book(),
      );

      expect(result.subtotal, 3000);
      expect(result.discountTotal, 500);
      expect(result.total, 2500);
      expect(result.blockers, isEmpty);
    });

    test('un descuento mayor que el subtotal se bloquea y no deja un total negativo', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [ManualDiscount(description: 'Error de dedo', amount: 9900)],
        book: _book(),
      );

      expect(result.blockers.single, contains('no puede ser mayor que el subtotal'));
      expect(result.total, 0);
    });
  });

  group('advertencias', () {
    test('un nivel fuera de su rango avisa pero no detiene la venta', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: kHandWashCode, optionCode: 'N2')],
        discounts: const [],
        book: _book(),
        totalPieces: 12,
      );

      expect(result.blockers, isEmpty);
      expect(result.canSave, isTrue);
      expect(result.warnings.single, contains('Nivel 2'));
      expect(result.warnings.single, contains('12'));
    });

    test('dentro del rango no dice nada', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: kHandWashCode, optionCode: 'N3')],
        discounts: const [],
        book: _book(),
        totalPieces: 7,
      );

      expect(result.warnings, isEmpty);
    });
  });

  group('promociones', () {
    test('un porcentaje rebaja solo las líneas a las que aplica', () {
      final result = priceOrder(
        charges: [
          const ChargeDraft(serviceCode: 'delivery', amount: 1500),
          const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G'),
        ],
        discounts: const [PromotionDiscount('domicilio_50')],
        book: _book(),
        promotions: _promotions(),
      );

      // La mitad de Q15.00, no la mitad del pedido.
      expect(result.subtotal, 4500);
      expect(result.discountTotal, 750);
      expect(result.total, 3750);
      expect(result.blockers, isEmpty);
    });

    test('el monto fijo no depende del tamaño del pedido', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'extra_softener', quantity: 300)],
        discounts: const [PromotionDiscount('rins_q5')],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discountTotal, 500);
    });

    test('el precio especial rebaja la diferencia contra lo que costaría', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [PromotionDiscount('tina_jul')],
        book: _book(onDate: '2026-07-20'),
        promotions: _promotions(onDate: '2026-07-20'),
      );

      // La tina grande cuesta Q30 y queda en Q25.
      expect(result.discountTotal, 500);
      expect(result.total, 2500);
    });

    test('la línea guarda el nombre de la promoción y a cuál apunta', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'delivery', amount: 1500)],
        discounts: const [PromotionDiscount('domicilio_50')],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discounts.single.description, '50% en domicilio');
      expect(result.discounts.single.promotionId, 'promo-domicilio_50');
      expect(result.discounts.single.promotionCode, 'domicilio_50');
    });

    test('una promoción que no muerde ninguna línea se dice, no se descarta', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [PromotionDiscount('domicilio_50')],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discounts, isEmpty);
      expect(result.discountIssues.single, contains('no rebaja nada'));
      expect(result.canSave, isFalse);
    });

    test('una promoción vencida se rechaza diciendo que no está vigente', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [PromotionDiscount('tina_jul')],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discountIssues.single, contains('no está vigente el 03/08/2026'));
    });

    test('una promoción apagada no se ofrece ni se aplica', () {
      expect(_promotions().live.map((promotion) => promotion.code), [
        'domicilio_50',
        'rins_q5',
      ]);

      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [PromotionDiscount('apagada')],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discountIssues.single, contains('no está vigente'));
    });

    test('un código que no existe se rechaza por su nombre', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [PromotionDiscount('black_friday')],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discountIssues.single, contains('black_friday'));
    });

    test('la misma promoción dos veces no rebaja dos veces', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'delivery', amount: 1500)],
        discounts: const [
          PromotionDiscount('domicilio_50'),
          PromotionDiscount('domicilio_50'),
        ],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.discounts.length, 1);
      expect(result.discountIssues.single, contains('dos veces'));
    });

    test('una promoción y un descuento manual conviven en la misma boleta', () {
      final result = priceOrder(
        charges: [
          const ChargeDraft(serviceCode: 'delivery', amount: 1500),
          const ChargeDraft(serviceCode: 'extra_softener', quantity: 100),
        ],
        discounts: const [
          PromotionDiscount('domicilio_50'),
          ManualDiscount(description: 'Cliente frecuente', amount: 300),
        ],
        book: _book(),
        promotions: _promotions(),
      );

      expect(result.subtotal, 2500);
      expect(result.discounts.map((line) => line.amount), [750, 300]);
      expect(result.total, 1450);
      expect(result.blockers, isEmpty);
    });

    test('el chip estima lo mismo que después se aplica', () {
      final priced = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'delivery', amount: 1500)],
        discounts: const [],
        book: _book(),
        promotions: _promotions(),
      );

      expect(
        estimatePromotion(_promotions().byCode('domicilio_50')!, priced.charges),
        750,
      );
    });

    test('sin libro de promociones, cualquier código se rechaza', () {
      final result = priceOrder(
        charges: [const ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
        discounts: const [PromotionDiscount('domicilio_50')],
        book: _book(),
      );

      expect(result.discountIssues.single, contains('No hay ninguna promoción'));
    });
  });

  test('un pedido sin cargos no se puede guardar', () {
    final result = priceOrder(charges: const [], discounts: const [], book: _book());

    expect(result.canSave, isFalse);
    expect(result.total, 0);
  });
}
