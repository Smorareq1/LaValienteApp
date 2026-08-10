// `drift` y `matcher` exportan ambos `isNull`/`isNotNull`; aquí se quieren los
// del matcher, así que de drift solo entra lo que hace falta.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/features/orders/data/order_mirrors.dart';
import 'package:la_valiente/features/orders/data/orders_local_datasource.dart';
import 'package:la_valiente/features/orders/domain/order_capture.dart';
import 'package:la_valiente/features/orders/domain/order_pricing.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';

SyncChange _change(String entity, String id, Map<String, Object?> data, {int version = 1}) {
  return SyncChange(
    entity: entity,
    id: id,
    version: version,
    syncSeq: version,
    deleted: false,
    data: {'id': id, 'version': version, ...data},
  );
}

SyncChange _order(
  String id, {
  String status = 'received',
  int version = 1,
  Object? deliveredAt,
  Object? cancelReason,
}) {
  return _change(
    'order',
    id,
    {
      'order_date': '2026-07-20',
      'daily_number': 4,
      'booklet_serial': '045213',
      'customer_id': 'c1',
      'nit': null,
      'weight_lbs': '12.50',
      'total_pieces': 9,
      'observations': null,
      'status': status,
      'subtotal': '116.25',
      'discount_total': '7.50',
      'total': '108.75',
      'received_by_id': 'u1',
      'delivered_at': deliveredAt,
      'delivered_by_id': deliveredAt == null ? null : 'u1',
      'cancelled_at': null,
      'cancelled_by_id': null,
      'cancel_reason': cancelReason,
    },
    version: version,
  );
}

/// La prenda que el servidor creó a partir de la captura: la misma camisa, con
/// el id que minteó él.
SyncChange _serverGarment(String id, {int? delivered}) {
  return _change('order_garment', id, {
    'order_id': 'o1',
    'garment_type_id': 'gt1',
    'quantity': 8,
    'quantity_delivered': delivered,
    'notes': null,
  });
}

/// Una boleta capturada en el dispositivo: prenda, cargo y descuento, los tres
/// con ids del teléfono, y el anticipo si se dio.
Future<void> _capture(OrdersLocalDataSource local, {PaymentDraft? advance}) {
  return local.insertCapture(
    orderId: 'o1',
    capture: OrderCapture(
      orderDate: '2026-07-20',
      customerId: 'c1',
      garments: const [GarmentDraft(garmentTypeId: 'gt1', quantity: 8)],
      charges: const [ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
      discounts: const [ManualDiscount(description: 'Cortesía', amount: 750)],
      advancePayment: advance,
    ),
    priced: const PricedOrder(
      charges: [
        PricedCharge(
          serviceCode: 'wash_tub',
          optionCode: 'G',
          serviceTypeId: 's1',
          serviceOptionId: 'op1',
          description: 'Lavado por tina — Tina grande',
          quantity: 100,
          unitPrice: 3000,
          amount: 3000,
        ),
      ],
      discounts: [PricedDiscount(description: 'Cortesía', amount: 750)],
      subtotal: 3000,
      discountTotal: 750,
      total: 2250,
    ),
    dailyNumber: -1,
    receivedById: 'u1',
    capturedAt: DateTime.utc(2026, 7, 20, 15),
    garmentIds: const ['local-g'],
    chargeIds: const ['local-ch'],
    discountIds: const ['local-d'],
    paymentId: advance == null ? null : 'local-p',
  );
}

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  Future<OrderEntry?> readOrder(String id) {
    return (database.select(
      database.orderEntries,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  test('los cinco espejos declaran las entidades que el feed nombra', () {
    final names = orderMirrors(database).map((mirror) => mirror.entity);

    expect(names, [
      'order',
      'order_garment',
      'order_charge',
      'order_discount',
      'order_payment',
    ]);
  });

  test('un pedido baja con sus montos tal cual, sin pasar por double', () async {
    await OrderMirror(database).apply(_order('o1'));

    final row = await readOrder('o1');
    // Q108.75 tiene que seguir siendo Q108.75: el total es lo único que el
    // cliente revisa, y un double lo convierte en algo que no lo es.
    expect(row!.total, '108.75');
    expect(row.subtotal, '116.25');
    expect(row.discountTotal, '7.50');
    expect(row.weightLbs, '12.50');
    expect(row.dailyNumber, 4);
    expect(row.status, 'received');
  });

  test('la fecha de negocio se guarda como texto, sin hora ni zona', () async {
    await OrderMirror(database).apply(_order('o1'));

    // Guardarla como instante la correría de día: a las 20:00 en Cobán ya es
    // el día siguiente en UTC, y el correlativo dejaría de cuadrar.
    expect((await readOrder('o1'))!.orderDate, '2026-07-20');
  });

  test('el ciclo de vida llega al espejo, no solo el estado', () async {
    final mirror = OrderMirror(database);
    await mirror.apply(_order('o1'));
    await mirror.apply(
      _order('o1', status: 'delivered', version: 2, deliveredAt: '2026-07-20T22:15:00+00:00'),
    );

    final row = await readOrder('o1');
    expect(row!.status, 'delivered');
    expect(row.version, 2);
    // La app tiene que poder dibujar un pedido entregado sin volver a preguntar.
    // Drift guarda el instante y lo devuelve en hora local, así que lo que se
    // compara es el instante y no cómo se escribe.
    expect(row.deliveredAt!.toUtc(), DateTime.utc(2026, 7, 20, 22, 15));
    expect(row.deliveredById, 'u1');
  });

  test('las líneas se guardan aparte y apuntan a su pedido', () async {
    await OrderChargeMirror(database).apply(
      _change('order_charge', 'ch1', {
        'order_id': 'o1',
        'service_type_id': 's1',
        'service_option_id': 'op1',
        'description': 'Lavado por tina — Tina grande',
        'quantity': '1.00',
        'unit_price': '30.00',
        'amount': '30.00',
      }),
    );
    await OrderGarmentMirror(database).apply(
      _change('order_garment', 'g1', {
        'order_id': 'o1',
        'garment_type_id': 'gt1',
        'quantity': 8,
        'quantity_delivered': 7,
        'notes': 'camisa blanca manchada',
      }),
    );

    final charge = await (database.select(
      database.orderChargeEntries,
    )..where((row) => row.orderId.equals('o1'))).getSingle();
    expect(charge.description, 'Lavado por tina — Tina grande');
    expect(charge.amount, '30.00');

    final garment = await (database.select(
      database.orderGarmentEntries,
    )..where((row) => row.orderId.equals('o1'))).getSingle();
    // El hueco contra lo recibido es el reporte de pérdidas.
    expect(garment.quantity, 8);
    expect(garment.quantityDelivered, 7);
  });

  test('un pago llega sin que se reenvíe el pedido al que pertenece', () async {
    await OrderPaymentMirror(database).apply(
      _change('order_payment', 'p1', {
        'order_id': 'o1',
        'amount': '40.00',
        'method': 'transfer',
        'is_advance': false,
        'reference': '99812',
        'received_by_id': 'u1',
        'paid_at': '2026-07-20T21:00:00+00:00',
      }),
    );

    final row = await (database.select(
      database.orderPaymentEntries,
    )..where((entry) => entry.id.equals('p1'))).getSingle();
    expect(row.orderId, 'o1');
    expect(row.amount, '40.00');
    expect(row.method, 'transfer');
    expect(row.isAdvance, isFalse);
    expect(row.paidAt.toUtc(), DateTime.utc(2026, 7, 20, 21));
    // El pedido no bajó, y no hacía falta: cada tabla tiene su propio sync_seq.
    expect(await readOrder('o1'), isNull);
  });

  test('un descuento manual llega sin promoción detrás', () async {
    await OrderDiscountMirror(database).apply(
      _change('order_discount', 'd1', {
        'order_id': 'o1',
        'promotion_id': null,
        'description': 'Cortesía',
        'amount': '7.50',
      }),
    );

    final row = await (database.select(
      database.orderDiscountEntries,
    )..where((entry) => entry.id.equals('d1'))).getSingle();
    expect(row.promotionId, isNull);
    expect(row.amount, '7.50');
  });

  group('una boleta aceptada suelta las líneas que capturó', () {
    late OrdersLocalDataSource local;

    setUp(() => local = OrdersLocalDataSource(database));

    test('la prenda del servidor no se suma a la que se capturó', () async {
      await _capture(local);
      await OrderMirror(database).settle('o1', rejected: false);
      await OrderGarmentMirror(database).apply(_serverGarment('srv-g'));

      // Ocho camisas capturadas y ocho camisas que bajaron son la misma línea
      // con dos ids: el pedido lleva una prenda, no dos.
      final detail = await local.detail('o1');
      expect(detail!.garments.map((line) => line.id), ['srv-g']);
    });

    test('el cargo y el descuento tampoco', () async {
      await _capture(local);
      await OrderMirror(database).settle('o1', rejected: false);
      await OrderChargeMirror(database).apply(
        _change('order_charge', 'srv-ch', {
          'order_id': 'o1',
          'service_type_id': 's1',
          'service_option_id': 'op1',
          'description': 'Lavado por tina — Tina grande',
          'quantity': '1.00',
          'unit_price': '30.00',
          'amount': '30.00',
        }),
      );
      await OrderDiscountMirror(database).apply(
        _change('order_discount', 'srv-d', {
          'order_id': 'o1',
          'promotion_id': null,
          'description': 'Cortesía',
          'amount': '7.50',
        }),
      );

      // Y con eso el detalle vuelve a cuadrar contra el total: dos cargos de
      // Q30 en una boleta de Q22.50 es lo que el cliente ve al reclamar.
      final detail = await local.detail('o1');
      expect(detail!.charges.map((line) => line.id), ['srv-ch']);
      expect(detail.discounts.map((line) => line.id), ['srv-d']);
    });

    test('el anticipo se queda: ese sí lleva el id del dispositivo', () async {
      await _capture(local, advance: const PaymentDraft(amount: 1000));
      await OrderMirror(database).settle('o1', rejected: false);

      // Retirarlo dejaría el pedido debiendo dinero que ya está en la caja, y
      // el feed lo va a encontrar por su id para actualizarlo en su lugar.
      final detail = await local.detail('o1');
      expect(detail!.payments.map((line) => line.id), ['local-p']);
      expect(detail.paid, 1000);
    });

    test('rechazada las conserva: son lo único que dice qué se capturó', () async {
      await _capture(local);
      await OrderMirror(database).settle('o1', rejected: true);

      // Del otro lado la boleta no existe, así que no va a bajar nada que las
      // reemplace. Se quedan hasta que alguien decida en la cola de revisión.
      final detail = await local.detail('o1');
      expect(detail!.garments.map((line) => line.id), ['local-g']);
      expect(detail.charges.map((line) => line.id), ['local-ch']);
      expect(detail.discounts.map((line) => line.id), ['local-d']);
    });

    test('entregar no se lleva las prendas que trajo el feed', () async {
      final mirror = OrderMirror(database);
      await _capture(local);
      await mirror.settle('o1', rejected: false);
      await OrderGarmentMirror(database).apply(_serverGarment('srv-g'));

      // El conteo de la entrega se escribe sobre la prenda del servidor y la
      // deja `pending` hasta que suba. `order/deliver` se resuelve por esta
      // misma entidad, y retirar por `pending` a secas la borraría.
      await local.markDelivered(
        id: 'o1',
        delivered: {'srv-g': 7},
        deliveredById: 'u1',
        at: DateTime.utc(2026, 7, 21, 16),
      );
      await mirror.settle('o1', rejected: false);

      final detail = await local.detail('o1');
      expect(detail!.garments.single.id, 'srv-g');
      expect(detail.garments.single.quantityDelivered, 7);
    });
  });
}
