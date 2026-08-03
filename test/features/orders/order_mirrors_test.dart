// `drift` y `matcher` exportan ambos `isNull`/`isNotNull`; aquí se quieren los
// del matcher, así que de drift solo entra lo que hace falta.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/features/orders/data/order_mirrors.dart';
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
}
