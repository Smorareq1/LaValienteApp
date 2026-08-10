import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/catalog/models/catalog.dart';
import 'package:la_valiente/features/orders/data/order_mirrors.dart';
import 'package:la_valiente/features/orders/data/orders_local_datasource.dart';
import 'package:la_valiente/features/orders/data/orders_repository.dart';
import 'package:la_valiente/features/orders/domain/order_capture.dart';
import 'package:la_valiente/features/orders/domain/order_pricing.dart';
import 'package:la_valiente/features/orders/models/order.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_operation.dart';

/// Capturar un pedido no habla con nadie: si alguna ruta lo intentara, el
/// `UnimplementedError` la delataría.
class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _services = [
  ServiceType(
    id: 'st-tub',
    code: 'wash_tub',
    name: 'Lavado por tina',
    pricingMode: PricingMode.tiered,
    options: const [
      ServiceOption(
        id: 'so-tub-g',
        serviceTypeId: 'st-tub',
        code: 'G',
        name: 'Tina grande',
      ),
    ],
  ),
  const ServiceType(
    id: 'st-delivery',
    code: 'delivery',
    name: 'Entrega a domicilio',
    pricingMode: PricingMode.variable,
    options: [],
  ),
];

final _book = OrderPriceBook(
  services: _services,
  prices: const [
    ServicePrice(
      id: 'sp-tub-g',
      serviceTypeId: 'st-tub',
      serviceOptionId: 'so-tub-g',
      amount: '30.00',
      validFrom: '2026-01-01',
    ),
  ],
  onDate: '2026-08-03',
);

OrderCapture _capture({PaymentDraft? advance, String orderDate = '2026-08-03'}) {
  return OrderCapture(
    orderDate: orderDate,
    customerId: 'cliente-1',
    bookletSerial: '10433',
    nit: 'CF',
    garments: const [
      GarmentDraft(garmentTypeId: 'gt-camisa', quantity: 6, notes: 'una manchada'),
      GarmentDraft(garmentTypeId: 'gt-toalla', quantity: 2),
    ],
    charges: const [
      ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G', quantity: 200),
      ChargeDraft(serviceCode: 'delivery', amount: 1500),
    ],
    advancePayment: advance,
  );
}

/// Lleva el pedido de `recibido` a `listo` recorriendo la cadena.
///
/// Entregar **no** lo exige (plan 0001 D13); esto existe para las pruebas que
/// comprueban que la cadena sigue funcionando para quien quiera usarla.
Future<OrderDetail?> _advance(OrdersRepository repository, OrderDetail order) async {
  await repository.changeStatus(order, OrderStatus.inProgress);
  final inProgress = (await repository.detail(order.id))!;
  await repository.changeStatus(inProgress, OrderStatus.ready);
  return repository.detail(order.id);
}

void main() {
  late AppDatabase database;
  late OrdersRepository repository;
  late SyncLocalDataSource syncLocal;

  var ids = 0;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    syncLocal = SyncLocalDataSource(database);
    ids = 0;
    repository = OrdersRepository(
      database: database,
      local: OrdersLocalDataSource(database),
      sync: SyncRepository(
        local: syncLocal,
        remote: _UnusedServer(),
        storage: _UnusedStorage(),
        mirrors: const {},
        device: const DeviceDescriptor(
          name: 'Tablet',
          platform: 'android',
          appVersion: '1.0.0',
        ),
        uuid: () => 'op-${++ids}',
      ),
      uuid: () => 'id-${++ids}',
      clock: () => DateTime.utc(2026, 8, 3, 15),
    );
  });

  tearDown(() => database.close());

  Future<void> save({PaymentDraft? advance, String orderDate = '2026-08-03'}) async {
    final capture = _capture(advance: advance, orderDate: orderDate);
    final priced = priceOrder(
      charges: capture.charges,
      discounts: capture.discounts,
      book: _book,
      totalPieces: capture.totalPieces,
    );
    final result = await repository.create(
      capture: capture,
      priced: priced,
      receivedById: 'usuario-1',
    );
    expect(result.isRight(), isTrue, reason: '${result.getLeft().toNullable()?.message}');
  }

  test('el pedido queda completo en la BD local y con una sola operación encolada', () async {
    await save();

    final orders = await database.select(database.orderEntries).get();
    expect(orders, hasLength(1));
    expect(orders.single.customerId, 'cliente-1');
    expect(orders.single.status, 'received');
    expect(orders.single.totalPieces, 8);
    expect(orders.single.subtotal, '75.00');
    expect(orders.single.total, '75.00');
    expect(orders.single.receivedById, 'usuario-1');
    expect(orders.single.syncStatus, RowSyncStatus.pending.name);

    expect(await database.select(database.orderGarmentEntries).get(), hasLength(2));
    expect(await database.select(database.orderChargeEntries).get(), hasLength(2));

    // Una boleta es **una** operación: prendas y cargos viajan dentro de ella.
    final pending = await syncLocal.pendingOperations(limit: 10);
    expect(pending, hasLength(1));
    expect(pending.single.entity, 'order');
    expect(pending.single.opType, 'create');
  });

  test('el cuerpo lleva cantidades y elecciones, nunca precios de catálogo', () async {
    await save();

    final operation = (await syncLocal.pendingOperations(limit: 1)).single;
    final payload = jsonDecode(jsonEncode(operation.payload)) as Map<String, dynamic>;

    expect(payload['order_date'], '2026-08-03');
    expect(payload['customer_id'], 'cliente-1');
    expect(payload['nit'], 'CF');

    final charges = payload['charges'] as List<dynamic>;
    final tub = charges.first as Map<String, dynamic>;
    expect(tub['service_code'], 'wash_tub');
    expect(tub['option_code'], 'G');
    expect(tub['quantity'], '2.00');
    // El precio no viaja: lo resuelve el servidor con el catálogo de la fecha.
    expect(tub.containsKey('amount'), isFalse);

    // Salvo en los variables, donde el monto es lo que cobró el motorista.
    final delivery = charges.last as Map<String, dynamic>;
    expect(delivery['amount'], '15.00');

    expect(payload['advance_payment'], isNull);
  });

  test('la fila del pedido guarda los montos como texto, no como double', () async {
    await save();

    final charge = (await database.select(database.orderChargeEntries).get())
        .firstWhere((row) => row.serviceTypeId == 'st-tub');
    expect(charge.quantity, '2.00');
    expect(charge.unitPrice, '30.00');
    expect(charge.amount, '60.00');
    expect(charge.description, 'Lavado por tina — Tina grande');
  });

  group('anticipo', () {
    test('se guarda como pago del pedido y viaja con su id', () async {
      await save(
        advance: const PaymentDraft(
          amount: 2000,
          method: PaymentMethod.transfer,
          reference: 'TRX-9',
        ),
      );

      final payment = (await database.select(database.orderPaymentEntries).get()).single;
      expect(payment.amount, '20.00');
      expect(payment.method, 'transfer');
      expect(payment.isAdvance, isTrue);
      expect(payment.reference, 'TRX-9');
      expect(payment.receivedById, 'usuario-1');

      final operation = (await syncLocal.pendingOperations(limit: 1)).single;
      final advance = operation.payload['advance_payment'] as Map<String, dynamic>;
      expect(advance['amount'], '20.00');
      expect(advance['is_advance'], isTrue);
      // El id lo mintió el dispositivo: es lo que hace idempotente el reintento.
      expect(advance['id'], payment.id);
    });
  });

  group('folio provisional', () {
    test('numera hacia atrás por fecha mientras el servidor no asigne el suyo', () async {
      await save();
      await save();
      await save(orderDate: '2026-08-04');

      final numbers = (await database.select(database.orderEntries).get())
          .map((row) => '${row.orderDate}:${row.dailyNumber}')
          .toList()
        ..sort();
      expect(numbers, ['2026-08-03:-1', '2026-08-03:-2', '2026-08-04:-1']);
    });

    test('no choca con un correlativo real que ya bajó del servidor', () async {
      await save();

      final saved = (await database.select(database.orderEntries).get()).single;
      // Lo que hace el feed al volver el pedido: el número real es positivo.
      await (database.update(database.orderEntries)
            ..where((row) => row.id.equals(saved.id)))
          .write(const OrderEntriesCompanion(dailyNumber: Value(7)));

      await save();

      final numbers = (await database.select(database.orderEntries).get())
          .map((row) => row.dailyNumber)
          .toList()
        ..sort();
      expect(numbers, [-1, 7]);
    });
  });

  group('resolución de la operación', () {
    test('al aplicarse, las líneas dejan de estar protegidas contra el pull', () async {
      await save(advance: const PaymentDraft(amount: 1000));

      final order = (await database.select(database.orderEntries).get()).single;
      await OrderMirror(database).settle(order.id, rejected: false);

      Future<List<String>> statuses(Future<List<dynamic>> rows) async =>
          (await rows).map((row) => (row as dynamic).syncStatus as String).toList();

      expect(
        await statuses(database.select(database.orderEntries).get()),
        everyElement(RowSyncStatus.synced.name),
      );
      expect(
        await statuses(database.select(database.orderGarmentEntries).get()),
        everyElement(RowSyncStatus.synced.name),
      );
      expect(
        await statuses(database.select(database.orderChargeEntries).get()),
        everyElement(RowSyncStatus.synced.name),
      );
      // Sin la cascada el anticipo se quedaría `pending` para siempre y el feed
      // nunca podría corregirle el monto.
      expect(
        await statuses(database.select(database.orderPaymentEntries).get()),
        everyElement(RowSyncStatus.synced.name),
      );
    });

    test('un rechazo marca todas las filas para la cola de revisión', () async {
      await save();

      final order = (await database.select(database.orderEntries).get()).single;
      await OrderMirror(database).settle(order.id, rejected: true);

      final charges = await database.select(database.orderChargeEntries).get();
      expect(
        charges.map((row) => row.syncStatus),
        everyElement(RowSyncStatus.rejected.name),
      );
    });

    test('descartar la boleta se lleva sus líneas y su anticipo', () async {
      await save(advance: const PaymentDraft(amount: 1000));

      final order = (await database.select(database.orderEntries).get()).single;
      await OrderMirror(database).settle(order.id, rejected: true);
      await OrderMirror(database).discard(order.id);

      // Todos los lectores filtran tombstones, así que la boleta desaparece de
      // la pantalla; y el anticipo se va con ella, para que no quede dinero
      // contado en un pedido que ya no existe.
      expect(await repository.detail(order.id), isNull);
      expect(await repository.watchByDate('2026-08-03').first, isEmpty);

      final payments = await database.select(database.orderPaymentEntries).get();
      expect(payments.single.deletedAt, isNotNull);
    });
  });

  group('ciclo de vida', () {
    /// Guarda una boleta y devuelve su detalle, que es lo que reciben las
    /// acciones del ciclo.
    Future<OrderDetail> saved({PaymentDraft? advance}) async {
      await save(advance: advance);
      final row = (await database.select(database.orderEntries).get()).last;
      return (await repository.detail(row.id))!;
    }

    Future<List<SyncOperation>> operations() => syncLocal.pendingOperations(limit: 20);

    test('avanzar de estado escribe la fila y encola la operación', () async {
      final order = await saved();

      final result = await repository.changeStatus(order, OrderStatus.inProgress);
      expect(result.isRight(), isTrue);

      final updated = (await repository.detail(order.id))!;
      expect(updated.status, OrderStatus.inProgress);
      expect(updated.isPending, isTrue);

      final last = (await operations()).last;
      expect(last.entity, 'order');
      expect(last.opType, 'status');
      expect(last.entityId, order.id);
      expect(last.payload['status'], 'in_progress');
    });

    test('no se puede saltar un paso de la cadena', () async {
      final order = await saved();

      final result = await repository.changeStatus(order, OrderStatus.ready);

      expect(result.isLeft(), isTrue);
      expect((await repository.detail(order.id))!.status, OrderStatus.received);
      // Y no queda una operación que el servidor tendría que rechazar.
      expect(await operations(), hasLength(1));
    });

    test('entregar y anular no salen por el cambio de estado', () async {
      final order = await saved();

      expect(
        (await repository.changeStatus(order, OrderStatus.delivered)).isLeft(),
        isTrue,
      );
      expect(
        (await repository.changeStatus(order, OrderStatus.cancelled)).isLeft(),
        isTrue,
      );
    });

    test('un pago se guarda y viaja como entidad propia con su id', () async {
      final order = await saved();
      expect(order.balance, 7500);

      final result = await repository.addPayment(
        order,
        payment: const PaymentDraft(amount: 2500),
        actorId: 'usuario-1',
      );
      expect(result.isRight(), isTrue);

      final updated = (await repository.detail(order.id))!;
      expect(updated.paid, 2500);
      expect(updated.balance, 5000);
      expect(updated.payments.single.isAdvance, isFalse);

      final last = (await operations()).last;
      expect(last.entity, 'order_payment');
      expect(last.opType, 'create');
      // `entity_id` es el id del pago: es lo que hace idempotente el reintento.
      expect(last.entityId, updated.payments.single.id);
      expect(last.payload['order_id'], order.id);
      expect(last.payload['amount'], '25.00');
    });

    test('un pago no puede exceder el saldo', () async {
      final order = await saved();

      final result = await repository.addPayment(
        order,
        payment: const PaymentDraft(amount: 9900),
        actorId: 'usuario-1',
      );

      expect(result.isLeft(), isTrue);
      expect((await repository.detail(order.id))!.payments, isEmpty);
    });

    test('entregar concilia las prendas y cobra el saldo', () async {
      var order = await saved();
      order = (await _advance(repository, order))!;

      final result = await repository.deliver(
        order,
        // Volvieron 5 de 6 camisas; las toallas completas.
        delivered: {
          order.garments.first.id: 5,
          order.garments.last.id: 2,
        },
        actorId: 'usuario-1',
        payment: const PaymentDraft(amount: 7500, method: PaymentMethod.transfer),
      );
      expect(result.isRight(), isTrue);

      final updated = (await repository.detail(order.id))!;
      expect(updated.status, OrderStatus.delivered);
      expect(updated.deliveredById, 'usuario-1');
      expect(updated.deliveredAt, isNotNull);
      expect(updated.balance, 0);
      expect(updated.garments.first.quantityDelivered, 5);
      expect(updated.garments.first.isShort, isTrue);
      expect(updated.garments.last.isShort, isFalse);

      final last = (await operations()).last;
      expect(last.entity, 'order');
      expect(last.opType, 'deliver');
      final garments = last.payload['garments'] as List<dynamic>;
      expect(garments, hasLength(2));
      expect(
        (garments.first as Map<String, dynamic>)['quantity_delivered'],
        5,
      );
      final payment = last.payload['payment'] as Map<String, dynamic>;
      expect(payment['amount'], '75.00');
      expect(payment['method'], 'transfer');
      expect(payment['is_advance'], isFalse);
    });

    test('se entrega una boleta que nunca salió de recibido', () async {
      // El día normal (plan 0001 D13): nadie la pasó por «en proceso» ni
      // «lista», y aun así se entrega y se cobra al cierre.
      final order = await saved();

      final result = await repository.deliver(
        order,
        delivered: {for (final line in order.garments) line.id: line.quantity},
        actorId: 'usuario-1',
        payment: const PaymentDraft(amount: 7500),
      );
      expect(result.isRight(), isTrue);

      final updated = (await repository.detail(order.id))!;
      expect(updated.status, OrderStatus.delivered);
      expect(updated.paid, 7500);
    });

    test('una boleta ya entregada no se entrega de nuevo', () async {
      var order = await saved();
      await repository.deliver(order, delivered: const {}, actorId: 'usuario-1');
      order = (await repository.detail(order.id))!;

      final before = (await operations()).length;
      final result = await repository.deliver(
        order,
        delivered: const {},
        actorId: 'usuario-1',
      );

      expect(result.isLeft(), isTrue);
      // Y no queda una segunda operación que el servidor tendría que rechazar.
      expect(await operations(), hasLength(before));
    });

    test('anular guarda el motivo y deja el dinero cobrado en su sitio', () async {
      final order = await saved(advance: const PaymentDraft(amount: 3000));

      final result = await repository.cancel(
        order,
        reason: 'El cliente se arrepintió',
        actorId: 'usuario-1',
      );
      expect(result.isRight(), isTrue);

      final updated = (await repository.detail(order.id))!;
      expect(updated.status, OrderStatus.cancelled);
      expect(updated.cancelReason, 'El cliente se arrepintió');
      expect(updated.cancelledById, 'usuario-1');
      // Devolverlo es un movimiento de caja propio; borrarlo dejaría el cajón
      // corto sin nada a qué apuntar.
      expect(updated.paid, 3000);

      final last = (await operations()).last;
      expect(last.opType, 'cancel');
      expect(last.payload['reason'], 'El cliente se arrepintió');
    });

    test('anular exige un motivo de verdad', () async {
      final order = await saved();

      expect((await repository.cancel(order, reason: '  ', actorId: 'u')).isLeft(), isTrue);
      expect((await repository.detail(order.id))!.status, OrderStatus.received);
    });

    test('un pedido anulado ya no admite pagos', () async {
      var order = await saved();
      await repository.cancel(order, reason: 'Error de captura', actorId: 'usuario-1');
      order = (await repository.detail(order.id))!;

      final result = await repository.addPayment(
        order,
        payment: const PaymentDraft(amount: 1000),
        actorId: 'usuario-1',
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('lectura', () {
    test('la lista del día trae cliente, total y saldo', () async {
      await database
          .into(database.customerEntries)
          .insert(
            CustomerEntriesCompanion.insert(id: 'cliente-1', fullName: 'Ana Pérez'),
          );
      await save(advance: const PaymentDraft(amount: 2000));
      await save(orderDate: '2026-08-04');

      final items = await repository.watchByDate('2026-08-03').first;

      expect(items, hasLength(1));
      expect(items.single.customerName, 'Ana Pérez');
      expect(items.single.total, 7500);
      expect(items.single.paid, 2000);
      expect(items.single.balance, 5500);
      expect(items.single.hasBalance, isTrue);
      expect(items.single.reference, 'P-1');
      expect(items.single.isPending, isTrue);
    });

    test('un cliente que todavía no bajó no deja la fila en blanco', () async {
      await save();

      final items = await repository.watchByDate('2026-08-03').first;

      expect(items.single.customerName, 'Cliente sin sincronizar');
    });

    test('el detalle se redibuja cuando cambia una tabla que no es la del pedido',
        () async {
      await save();
      final order = (await repository.detail(
        (await database.select(database.orderEntries).get()).single.id,
      ))!;

      final saldos = <int>[];
      final sub = repository.watchDetail(order.id).listen((detail) {
        if (detail != null) saldos.add(detail.balance);
      });
      await Future<void>.delayed(Duration.zero);

      await repository.addPayment(
        order,
        payment: const PaymentDraft(amount: 2500),
        actorId: 'usuario-1',
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      // Cobrar solo inserta una fila en `order_payments`; si el stream mirara
      // únicamente la tabla del pedido, el saldo se habría quedado viejo.
      expect(saldos.first, 7500);
      expect(saldos.last, 5000);
    });
  });

  group('corregir la boleta', () {
    /// La boleta como debería quedar: una tina en vez de dos y sin domicilio.
    OrderCapture corrected() {
      return const OrderCapture(
        orderDate: '2026-08-03',
        customerId: 'cliente-1',
        bookletSerial: '10433',
        nit: 'CF',
        observations: 'Corregido en el mostrador',
        garments: [GarmentDraft(garmentTypeId: 'gt-camisa', quantity: 4)],
        charges: [ChargeDraft(serviceCode: 'wash_tub', optionCode: 'G')],
      );
    }

    Future<OrderDetail> edit(OrderDetail order, {OrderCapture? capture}) async {
      final wanted = capture ?? corrected();
      final result = await repository.update(
        order,
        capture: wanted,
        priced: priceOrder(
          charges: wanted.charges,
          discounts: wanted.discounts,
          book: _book,
          totalPieces: wanted.totalPieces,
        ),
      );
      expect(result.isRight(), isTrue, reason: '${result.getLeft().toNullable()?.message}');
      return (await repository.detail(order.id))!;
    }

    test('reemplaza las líneas y recalcula el total', () async {
      await save();
      final order = (await repository.detail('id-1'))!;
      expect(order.total, 7500);

      final after = await edit(order);

      expect(after.charges, hasLength(1));
      expect(after.charges.single.amount, 3000);
      expect(after.total, 3000);
      expect(after.totalPieces, 4);
      expect(after.observations, 'Corregido en el mostrador');
      expect(after.garments, hasLength(1));
    });

    test('las líneas viejas quedan como lápidas, no se borran', () async {
      await save();
      final order = (await repository.detail('id-1'))!;
      await edit(order);

      final charges = await database.select(database.orderChargeEntries).get();
      // Las dos de antes siguen ahí, marcadas; la nueva es la única viva.
      expect(charges, hasLength(3));
      expect(charges.where((row) => row.deletedAt != null), hasLength(2));
      expect(charges.where((row) => row.deletedAt == null), hasLength(1));
    });

    test('la fecha, el correlativo y el estado no se tocan', () async {
      await save();
      final order = (await repository.detail('id-1'))!;
      final after = await edit(order);

      expect(after.orderDate, order.orderDate);
      expect(after.dailyNumber, order.dailyNumber);
      expect(after.status, order.status);
    });

    test('el pago que ya estaba sigue en el pedido', () async {
      await save(advance: const PaymentDraft(amount: 2000));
      final order = (await repository.detail('id-1'))!;
      final after = await edit(order);

      expect(after.payments, hasLength(1));
      expect(after.paid, 2000);
      expect(after.balance, 1000);
    });

    test('la operación viaja como order/update con su base_version', () async {
      await save();
      final order = (await repository.detail('id-1'))!;
      await edit(order);

      final operations = await syncLocal.pendingOperations(limit: 10);
      final update = operations.firstWhere((op) => op.opType == 'update');
      expect(update.entity, 'order');
      expect(update.entityId, order.id);
      expect(update.baseVersion, order.version);

      final payload = jsonDecode(jsonEncode(update.payload)) as Map<String, dynamic>;
      // Ni la fecha ni el pago: lo primero pertenece al día, lo segundo es un
      // hecho que ocurrió.
      expect(payload.containsKey('order_date'), isFalse);
      expect(payload.containsKey('advance_payment'), isFalse);
      expect(payload['observations'], 'Corregido en el mostrador');
      expect((payload['charges'] as List<dynamic>), hasLength(1));
    });

    group('la boleta que el servidor nunca aceptó', () {
      /// Deja la boleta como la deja un `order/create` rechazado: marcada para
      /// revisión y todavía en la versión 0, o sea sin copia del servidor.
      Future<OrderDetail> refused({PaymentDraft? advance}) async {
        await save(advance: advance);
        await OrderMirror(database).settle('id-1', rejected: true);
        // El `create` rechazado sale del outbox al caer a la cola de revisión.
        final queued = await syncLocal.pendingOperations(limit: 50);
        await syncLocal.removeOperations(queued.map((op) => op.opId));
        return (await repository.detail('id-1'))!;
      }

      test('corregirla la vuelve a dar de alta, no a actualizar', () async {
        final order = await refused();
        expect(order.needsReview, isTrue);
        expect(order.version, 0);

        await edit(order);

        final operation = (await syncLocal.pendingOperations(limit: 10)).single;
        // Un `update` hablaría de un pedido que el servidor no conoce; el id lo
        // minteó este dispositivo, así que darlo de alta otra vez es lo correcto.
        expect(operation.opType, 'create');
        expect(operation.entityId, 'id-1');
        expect(operation.baseVersion, isNull);

        final payload = jsonDecode(jsonEncode(operation.payload)) as Map<String, dynamic>;
        expect(payload['order_date'], '2026-08-03');
        expect(payload['observations'], 'Corregido en el mostrador');
      });

      test('el alta reemitida se lleva el anticipo con su id original', () async {
        final order = await refused(advance: const PaymentDraft(amount: 1000));
        await edit(order);

        final operation = (await syncLocal.pendingOperations(limit: 10)).single;
        final payload = jsonDecode(jsonEncode(operation.payload)) as Map<String, dynamic>;
        final advance = payload['advance_payment'] as Map<String, dynamic>;

        // Sin esto el servidor daría de alta la boleta sin el pago que el
        // cliente sí hizo; y el id repetido es lo que impide cobrarlo dos veces.
        expect(advance['amount'], '10.00');
        expect(advance['id'], order.payments.single.id);
      });

      test('una boleta que solo espera turno sigue corrigiéndose como update', () async {
        await save();
        final order = (await repository.detail('id-1'))!;
        expect(order.isPending, isTrue);
        expect(order.version, 0);

        await edit(order);

        // También está en la versión 0, pero su `create` sigue en el outbox y se
        // aplicará antes que esta corrección, que va detrás en el mismo orden.
        final operations = await syncLocal.pendingOperations(limit: 10);
        expect(operations.map((op) => op.opType), ['create', 'update']);
      });
    });

    test('bajar del total ya cobrado se rechaza y no toca nada', () async {
      await save(advance: const PaymentDraft(amount: 5000));
      final order = (await repository.detail('id-1'))!;

      final capture = corrected();
      final result = await repository.update(
        order,
        capture: capture,
        priced: priceOrder(
          charges: capture.charges,
          discounts: capture.discounts,
          book: _book,
          totalPieces: capture.totalPieces,
        ),
      );

      expect(result.isLeft(), isTrue);
      final after = (await repository.detail('id-1'))!;
      expect(after.total, 7500);
      expect(after.charges, hasLength(2));
      expect(
        (await syncLocal.pendingOperations(limit: 10)).where((op) => op.opType == 'update'),
        isEmpty,
      );
    });

    test('un pedido entregado ya no se corrige', () async {
      await save();
      final ready = await _advance(repository, (await repository.detail('id-1'))!);
      await repository.deliver(ready!, delivered: const {}, actorId: 'usuario-1');
      final delivered = (await repository.detail('id-1'))!;

      final capture = corrected();
      final result = await repository.update(
        delivered,
        capture: capture,
        priced: priceOrder(
          charges: capture.charges,
          discounts: capture.discounts,
          book: _book,
          totalPieces: capture.totalPieces,
        ),
      );

      expect(result.isLeft(), isTrue);
      expect((await repository.detail('id-1'))!.total, 7500);
    });
  });

  test('un pedido sin cargos no se guarda ni deja basura en la BD', () async {
    final capture = OrderCapture(
      orderDate: '2026-08-03',
      customerId: 'cliente-1',
      garments: const [GarmentDraft(garmentTypeId: 'gt-camisa', quantity: 1)],
      charges: const [],
    );
    final result = await repository.create(
      capture: capture,
      priced: priceOrder(charges: const [], discounts: const [], book: _book),
      receivedById: 'usuario-1',
    );

    expect(result.isLeft(), isTrue);
    expect(await database.select(database.orderEntries).get(), isEmpty);
    expect(await syncLocal.pendingOperations(limit: 10), isEmpty);
  });
}
