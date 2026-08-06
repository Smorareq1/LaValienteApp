import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../auth/state/auth_controller.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/catalog.dart';
import '../../customers/data/customers_repository.dart';
import '../../customers/models/customer.dart';
import '../../promotions/data/promotions_repository.dart';
import '../data/orders_repository.dart';
import '../domain/order_capture.dart';
import '../domain/order_pricing.dart';
import '../models/order.dart';
import '../models/saved_order.dart';

part 'order_capture_controller.g.dart';

/// Clave de un servicio en el mapa de cantidades: `código` o `código/opción`.
///
/// Las opciones de un servicio escalonado se cuentan por separado —1 tina
/// grande y 1 pequeña son dos líneas— así que la cantidad no puede colgar del
/// servicio sino de la combinación.
String serviceKey(String serviceCode, [String? optionCode]) =>
    optionCode == null ? serviceCode : '$serviceCode/$optionCode';

/// La boleta en pantalla: lo capturado más el catálogo con el que se calcula.
class OrderCaptureState {
  const OrderCaptureState({
    required this.orderDate,
    required this.services,
    required this.garmentTypes,
    required this.book,
    required this.promotions,
    this.editing,
    this.customer,
    this.bookletSerial = '',
    this.nit = '',
    this.weightText = '',
    this.washByWeight = false,
    this.observations = '',
    this.garmentQuantities = const {},
    this.garmentNotes = const {},
    this.serviceQuantities = const {},
    this.variableAmounts = const {},
    this.selectedPromotions = const [],
    this.discountAmountText = '',
    this.discountDescription = '',
    this.advanceAmountText = '',
    this.paymentMethod = PaymentMethod.cash,
    this.paymentReference = '',
    this.saving = false,
  });

  final DateTime orderDate;
  final List<ServiceType> services;
  final List<GarmentType> garmentTypes;
  final OrderPriceBook book;

  /// Las promociones que el dispositivo conoce, indexadas por la fecha del
  /// pedido. Cambiar la fecha lo rehace igual que al libro de precios.
  final PromotionBook promotions;

  /// El pedido que se está corrigiendo, o `null` si es una boleta nueva
  /// (plan 0001 §7.3). Lo que cambia no es la pantalla sino a dónde va: la
  /// captura crea, la corrección reemplaza.
  final OrderDetail? editing;

  bool get isEditing => editing != null;

  final Customer? customer;
  final String bookletSerial;
  final String nit;

  /// El texto tal como se está tecleando. Se guarda crudo y no como número para
  /// que "12." mientras alguien escribe "12.5" no se borre solo.
  final String weightText;

  final bool washByWeight;
  final String observations;

  /// `garmentTypeId` → cantidad, y → nota de esa línea.
  final Map<String, int> garmentQuantities;
  final Map<String, String> garmentNotes;

  /// [serviceKey] → cantidad, para los servicios que se cuentan.
  final Map<String, int> serviceQuantities;

  /// `código` → texto del monto, para los servicios `variable` (motorista).
  final Map<String, String> variableAmounts;

  /// Los códigos de las promociones marcadas, en el orden en que se marcaron:
  /// así las líneas de la boleta salen como la persona las fue eligiendo.
  final List<String> selectedPromotions;

  final String discountAmountText;
  final String discountDescription;

  final String advanceAmountText;
  final PaymentMethod paymentMethod;
  final String paymentReference;

  final bool saving;

  int? get weightLbs => Fixed2.parse(weightText);

  int get totalPieces =>
      garmentQuantities.values.fold(0, (sum, quantity) => sum + quantity);

  int get advanceAmount => Fixed2.parse(advanceAmountText) ?? 0;

  /// Las líneas tal como se mandarían, en el orden del catálogo.
  List<ChargeDraft> get charges {
    final drafts = <ChargeDraft>[];

    for (final service in services) {
      if (service.code == kWashByWeightCode) {
        // El lavado por peso toma su cantidad del encabezado, no de un stepper:
        // son el mismo número escrito una sola vez (§3.1).
        if (washByWeight) {
          drafts.add(
            ChargeDraft(serviceCode: service.code, quantity: weightLbs ?? 0),
          );
        }
        continue;
      }

      if (service.pricingMode == PricingMode.variable) {
        final amount = Fixed2.parse(variableAmounts[service.code]);
        if (amount != null && amount > 0) {
          drafts.add(ChargeDraft(serviceCode: service.code, amount: amount));
        }
        continue;
      }

      if (service.pricingMode == PricingMode.tiered) {
        for (final option in service.options) {
          final quantity = serviceQuantities[serviceKey(service.code, option.code)] ?? 0;
          if (quantity > 0) {
            drafts.add(
              ChargeDraft(
                serviceCode: service.code,
                optionCode: option.code,
                quantity: quantity * 100,
              ),
            );
          }
        }
        continue;
      }

      final quantity = serviceQuantities[serviceKey(service.code)] ?? 0;
      if (quantity > 0) {
        drafts.add(ChargeDraft(serviceCode: service.code, quantity: quantity * 100));
      }
    }

    return drafts;
  }

  List<GarmentDraft> get garments => [
    for (final entry in garmentQuantities.entries)
      if (entry.value > 0)
        GarmentDraft(
          garmentTypeId: entry.key,
          quantity: entry.value,
          notes: _clean(garmentNotes[entry.key]),
        ),
  ];

  /// Las promociones marcadas primero y el descuento manual al final, que es el
  /// orden en que se leen en la boleta.
  List<DiscountDraft> get discounts {
    final drafts = <DiscountDraft>[
      for (final code in selectedPromotions) PromotionDiscount(code),
    ];

    final amount = Fixed2.parse(discountAmountText);
    if (amount != null && amount > 0) {
      // El servidor exige al menos dos caracteres de motivo. Un descuento sin
      // explicación es un descuento que nadie va a poder justificar después,
      // pero rebotarlo a la cola de revisión por eso sería peor que ponerle un
      // nombre.
      final description = discountDescription.trim();
      drafts.add(
        ManualDiscount(
          description: description.length < 2 ? 'Descuento' : description,
          amount: amount,
        ),
      );
    }

    return drafts;
  }

  PricedOrder get priced => priceOrder(
    charges: charges,
    discounts: discounts,
    book: book,
    promotions: promotions,
    weightLbs: washByWeight ? weightLbs : null,
    totalPieces: totalPieces,
  );


  /// Lo que falta para poder guardar, en el orden en que se lee la boleta.
  ///
  /// Los tres primeros son del formulario (§4) y los demás los pone el motor de
  /// cálculo. Se juntan aquí porque quien captura no distingue de dónde sale
  /// cada uno: solo quiere saber qué le falta.
  List<String> get blockers {
    final missing = <String>[];
    if (customer == null) missing.add('el cliente');
    if (totalPieces == 0) missing.add('las prendas');
    if (priced.charges.isEmpty) missing.add('un cargo');

    final issues = [
      if (missing.isNotEmpty) 'Falta ${_join(missing)} para guardar.',
      ...priced.blockers,
    ];

    final advance = Fixed2.parse(advanceAmountText);
    if (advance != null && advance > priced.total) {
      // El vuelto que se da en el mostrador no es dinero que se quedó en la
      // caja; el servidor rechaza el pago y aquí se dice antes de mandarlo.
      issues.add('El anticipo no puede ser mayor que el total.');
    }

    final paid = editing?.paid ?? 0;
    if (paid > priced.total) {
      // Corregir hacia abajo un pedido ya cobrado es una devolución, y devolver
      // dinero es un movimiento de caja que todavía no existe (§7.3).
      issues.add(
        'Ya se cobraron Q${Fixed2.format(paid)}: el pedido no puede quedar en '
        'Q${Fixed2.format(priced.total)}.',
      );
    }

    return issues;
  }

  bool get canSave => blockers.isEmpty && !saving;

  OrderCapture toCapture() => OrderCapture(
    orderDate: isoDate(orderDate),
    customerId: customer!.id,
    bookletSerial: _clean(bookletSerial),
    nit: _clean(nit),
    weightLbs: washByWeight ? weightLbs : null,
    observations: _clean(observations),
    garments: garments,
    charges: charges,
    discounts: discounts,
    advancePayment: advanceAmount <= 0
        ? null
        : PaymentDraft(
            amount: advanceAmount,
            method: paymentMethod,
            reference: paymentMethod == PaymentMethod.transfer
                ? _clean(paymentReference)
                : null,
          ),
  );

  OrderCaptureState copyWith({
    DateTime? orderDate,
    List<ServiceType>? services,
    List<GarmentType>? garmentTypes,
    OrderPriceBook? book,
    PromotionBook? promotions,
    OrderDetail? editing,
    Customer? customer,
    bool clearCustomer = false,
    String? bookletSerial,
    String? nit,
    String? weightText,
    bool? washByWeight,
    String? observations,
    Map<String, int>? garmentQuantities,
    Map<String, String>? garmentNotes,
    Map<String, int>? serviceQuantities,
    Map<String, String>? variableAmounts,
    List<String>? selectedPromotions,
    String? discountAmountText,
    String? discountDescription,
    String? advanceAmountText,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    bool? saving,
  }) {
    return OrderCaptureState(
      orderDate: orderDate ?? this.orderDate,
      services: services ?? this.services,
      garmentTypes: garmentTypes ?? this.garmentTypes,
      book: book ?? this.book,
      promotions: promotions ?? this.promotions,
      editing: editing ?? this.editing,
      customer: clearCustomer ? null : (customer ?? this.customer),
      bookletSerial: bookletSerial ?? this.bookletSerial,
      nit: nit ?? this.nit,
      weightText: weightText ?? this.weightText,
      washByWeight: washByWeight ?? this.washByWeight,
      observations: observations ?? this.observations,
      garmentQuantities: garmentQuantities ?? this.garmentQuantities,
      garmentNotes: garmentNotes ?? this.garmentNotes,
      serviceQuantities: serviceQuantities ?? this.serviceQuantities,
      variableAmounts: variableAmounts ?? this.variableAmounts,
      selectedPromotions: selectedPromotions ?? this.selectedPromotions,
      discountAmountText: discountAmountText ?? this.discountAmountText,
      discountDescription: discountDescription ?? this.discountDescription,
      advanceAmountText: advanceAmountText ?? this.advanceAmountText,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      saving: saving ?? this.saving,
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static String _join(List<String> items) {
    if (items.length == 1) return items.first;
    return '${items.sublist(0, items.length - 1).join(', ')} y ${items.last}';
  }
}

/// El estado de la toma de pedido (plan 0002).
///
/// Todo el cálculo vive del lado del dispositivo mientras se captura: la
/// pantalla tiene que responder con o sin señal, y el total del footer se
/// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
/// aplica la operación (D5).
@riverpod
class OrderCaptureController extends _$OrderCaptureController {
  /// [orderId] con valor abre la pantalla **corrigiendo** ese pedido (§7.3):
  /// la boleta se precarga tal como está guardada y guardar reemplaza en vez de
  /// crear.
  @override
  Future<OrderCaptureState> build(String? orderId) async {
    if (orderId == null) return _load(businessDate());

    final order = await ref.read(ordersRepositoryProvider).detail(orderId);
    if (order == null) throw StateError('Ese pedido ya no está en el dispositivo');

    final blank = await _load(_parseDate(order.orderDate));
    return _prefill(blank, order);
  }

  static DateTime _parseDate(String isoDate) =>
      DateTime.tryParse(isoDate) ?? businessDate();

  /// Reconstruye la boleta en pantalla a partir de lo guardado.
  ///
  /// Las líneas guardan ids del catálogo y la pantalla piensa en códigos, así
  /// que hay que traducir de vuelta: es el precio de que la boleta sea una copia
  /// congelada (D2) y no una consulta al catálogo de hoy.
  Future<OrderCaptureState> _prefill(OrderCaptureState blank, OrderDetail order) async {
    final customer = await ref
        .read(customersRepositoryProvider)
        .byId(order.customerId);

    final byServiceId = {for (final service in blank.services) service.id: service};
    final quantities = <String, int>{};
    final variableAmounts = <String, String>{};
    var washByWeight = false;

    for (final line in order.charges) {
      final service = byServiceId[line.serviceTypeId];
      if (service == null) continue;

      if (service.code == kWashByWeightCode) {
        // Las libras salen del encabezado, no de un stepper: son el mismo
        // número escrito una sola vez (§3.1).
        washByWeight = true;
        continue;
      }
      if (service.pricingMode == PricingMode.variable) {
        variableAmounts[service.code] = Fixed2.format(line.amount);
        continue;
      }

      String? optionCode;
      for (final option in service.options) {
        if (option.id == line.serviceOptionId) optionCode = option.code;
      }
      // Los steppers cuentan unidades y la línea guarda centésimas.
      quantities[serviceKey(service.code, optionCode)] = (line.quantity / 100).round();
    }

    final promotionCodes = {
      for (final promotion in blank.promotions.all) promotion.id: promotion.code,
    };
    final selected = <String>[];
    var manualAmount = '';
    var manualDescription = '';
    for (final line in order.discounts) {
      if (line.isManual) {
        manualAmount = Fixed2.format(line.amount);
        manualDescription = line.description;
        continue;
      }
      final code = promotionCodes[line.promotionId];
      if (code != null) selected.add(code);
    }

    return blank.copyWith(
      editing: order,
      customer: customer,
      bookletSerial: order.bookletSerial ?? '',
      nit: order.nit ?? '',
      weightText: order.weightLbs == null ? '' : Fixed2.format(order.weightLbs!),
      washByWeight: washByWeight,
      observations: order.observations ?? '',
      garmentQuantities: {
        for (final line in order.garments) line.garmentTypeId: line.quantity,
      },
      garmentNotes: {
        for (final line in order.garments)
          if (line.notes != null) line.garmentTypeId: line.notes!,
      },
      serviceQuantities: quantities,
      variableAmounts: variableAmounts,
      selectedPromotions: selected,
      discountAmountText: manualAmount,
      discountDescription: manualDescription,
    );
  }

  Future<OrderCaptureState> _load(DateTime date, {OrderCaptureState? from}) async {
    final catalog = ref.read(catalogRepositoryProvider);
    final services = from?.services ?? await catalog.services();
    final garmentTypes = from?.garmentTypes ?? await catalog.garmentTypes();
    final prices = await catalog.prices();
    final promotions = await ref.read(promotionsRepositoryProvider).all();

    final on = isoDate(date);
    final book = OrderPriceBook(services: services, prices: prices, onDate: on);
    final promotionBook = PromotionBook(promotions: promotions, onDate: on);

    final loaded =
        (from ?? OrderCaptureState(
                  orderDate: date,
                  services: services,
                  garmentTypes: garmentTypes,
                  book: book,
                  promotions: promotionBook,
                ))
            .copyWith(orderDate: date, book: book, promotions: promotionBook);

    // Una promoción que estaba marcada y no rige en la fecha nueva se suelta:
    // dejarla puesta convertiría un cambio de fecha en un bloqueo que hay que
    // ir a buscar a la sección 6 para entender.
    final live = {for (final promotion in promotionBook.live) promotion.code};
    if (loaded.selectedPromotions.any((code) => !live.contains(code))) {
      return loaded.copyWith(
        selectedPromotions: [
          for (final code in loaded.selectedPromotions)
            if (live.contains(code)) code,
        ],
      );
    }
    return loaded;
  }

  void _update(OrderCaptureState Function(OrderCaptureState) change) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(change(current));
  }

  /// Cambiar la fecha rehace el libro de precios: un pedido atrasado se cobra
  /// con lo que regía ese día, no con lo de hoy (D1).
  Future<void> setDate(DateTime date) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(await _load(date, from: current));
  }

  void setCustomer(Customer? customer) {
    _update((current) {
      if (customer == null) return current.copyWith(clearCustomer: true);
      // El NIT del cliente se prellena solo si el campo está vacío: quien ya
      // escribió uno distinto lo hizo a propósito (§3.1).
      final nit = current.nit.trim().isEmpty ? (customer.nit ?? '') : current.nit;
      return current.copyWith(customer: customer, nit: nit);
    });
  }

  void setBookletSerial(String value) =>
      _update((current) => current.copyWith(bookletSerial: value));

  void setNit(String value) => _update((current) => current.copyWith(nit: value));

  void setWeight(String value) => _update((current) => current.copyWith(weightText: value));

  void setWashByWeight(bool value) =>
      _update((current) => current.copyWith(washByWeight: value));

  void setObservations(String value) =>
      _update((current) => current.copyWith(observations: value));

  void setGarment(String garmentTypeId, int quantity) {
    _update((current) {
      final quantities = Map<String, int>.from(current.garmentQuantities);
      if (quantity <= 0) {
        quantities.remove(garmentTypeId);
      } else {
        quantities[garmentTypeId] = quantity;
      }
      return current.copyWith(garmentQuantities: quantities);
    });
  }

  void setGarmentNote(String garmentTypeId, String note) {
    _update((current) {
      final notes = Map<String, String>.from(current.garmentNotes);
      if (note.trim().isEmpty) {
        notes.remove(garmentTypeId);
      } else {
        notes[garmentTypeId] = note;
      }
      return current.copyWith(garmentNotes: notes);
    });
  }

  void setService(String serviceCode, String? optionCode, int quantity) {
    _update((current) {
      final quantities = Map<String, int>.from(current.serviceQuantities);
      final key = serviceKey(serviceCode, optionCode);
      if (quantity <= 0) {
        quantities.remove(key);
      } else {
        quantities[key] = quantity;
      }
      return current.copyWith(serviceQuantities: quantities);
    });
  }

  void setVariableAmount(String serviceCode, String amount) {
    _update((current) {
      final amounts = Map<String, String>.from(current.variableAmounts);
      if (amount.trim().isEmpty) {
        amounts.remove(serviceCode);
      } else {
        amounts[serviceCode] = amount;
      }
      return current.copyWith(variableAmounts: amounts);
    });
  }

  /// Marca o desmarca una promoción. Se guarda el **código**, no el monto: lo
  /// que rebaja se recalcula con la boleta y lo confirma el servidor (D5).
  void togglePromotion(String code) {
    _update((current) {
      final selected = List<String>.from(current.selectedPromotions);
      if (!selected.remove(code)) selected.add(code);
      return current.copyWith(selectedPromotions: selected);
    });
  }

  void setDiscount({String? amount, String? description}) {
    _update(
      (current) => current.copyWith(
        discountAmountText: amount,
        discountDescription: description,
      ),
    );
  }

  void setAdvance({String? amount, PaymentMethod? method, String? reference}) {
    _update(
      (current) => current.copyWith(
        advanceAmountText: amount,
        paymentMethod: method,
        paymentReference: reference,
      ),
    );
  }

  /// Vacía la boleta sin perder el catálogo ni la fecha ya elegida.
  void clear() {
    _update(
      (current) => OrderCaptureState(
        orderDate: current.orderDate,
        services: current.services,
        garmentTypes: current.garmentTypes,
        book: current.book,
        promotions: current.promotions,
      ),
    );
  }

  Future<Either<AppFailure, SavedOrder>> save() async {
    final current = state.valueOrNull;
    if (current == null || !current.canSave) {
      final pending = current?.blockers ?? const <String>[];
      return Left(
        ValidationFailure(
          pending.isEmpty ? 'El pedido todavía no se puede guardar' : pending.first,
        ),
      );
    }

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return const Left(AuthFailure('La sesión ya no está activa'));

    state = AsyncData(current.copyWith(saving: true));

    final editing = current.editing;
    if (editing != null) {
      final corrected = await ref
          .read(ordersRepositoryProvider)
          .update(
            editing,
            capture: current.toCapture(),
            priced: current.priced,
          );
      // La pantalla **no** se vacía al corregir: se vuelve al detalle, que es
      // de donde se entró.
      _update((latest) => latest.copyWith(saving: false));
      return corrected.map(
        (_) => SavedOrder(
          id: editing.id,
          dailyNumber: editing.dailyNumber,
          total: current.priced.total,
          paid: editing.paid,
          warnings: current.priced.warnings,
        ),
      );
    }

    final result = await ref
        .read(ordersRepositoryProvider)
        .create(
          capture: current.toCapture(),
          priced: current.priced,
          receivedById: user.id,
        );

    // Al guardar bien la pantalla se vacía para la siguiente boleta, que es lo
    // que pasa en el mostrador: nunca se toma un pedido y se queda mirando.
    _update((latest) => latest.copyWith(saving: false));
    if (result.isRight()) clear();

    return result;
  }
}
