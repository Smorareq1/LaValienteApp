import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/fixed2.dart';
import '../../sync/data/sync_repository.dart';
import '../domain/order_capture.dart';
import '../domain/order_pricing.dart';
import '../models/order.dart';
import '../models/saved_order.dart';
import 'orders_local_datasource.dart';

part 'orders_repository.g.dart';

/// Pedidos, contra la BD local siempre (plan 0004 D1).
///
/// Guardar una boleta son seis escrituras que tienen que ir juntas: las cinco
/// filas espejo —para que el pedido esté en la pantalla antes de que nadie
/// piense en la señal— y la operación en el outbox, para que el servidor se
/// entere. Van en una transacción porque un corte a la mitad dejaría un pedido
/// que nadie va a subir, o una operación que habla de líneas que en el
/// dispositivo no existen.
class OrdersRepository {
  const OrdersRepository({
    required AppDatabase database,
    required OrdersLocalDataSource local,
    required SyncRepository sync,
    String Function() uuid = _defaultUuid,
    DateTime Function() clock = DateTime.now,
  }) : _database = database,
       _local = local,
       _sync = sync,
       _uuid = uuid,
       _clock = clock;

  final AppDatabase _database;
  final OrdersLocalDataSource _local;
  final SyncRepository _sync;
  final String Function() _uuid;
  final DateTime Function() _clock;

  static String _defaultUuid() => const Uuid().v4();

  /// Registra la boleta. El id lo genera el dispositivo (D3) para que la
  /// confirmación se pueda imprimir sin haber hablado con el servidor.
  Future<Either<AppFailure, SavedOrder>> create({
    required OrderCapture capture,
    required PricedOrder priced,
    required String receivedById,
  }) async {
    if (!priced.canSave) {
      return Left(
        ValidationFailure(
          priced.blockers.isEmpty ? 'El pedido necesita al menos un cargo' : priced.blockers.first,
        ),
      );
    }

    final orderId = _uuid();
    final garmentIds = [for (final _ in capture.garments) _uuid()];
    final chargeIds = [for (final _ in priced.charges) _uuid()];
    final discountIds = [for (final _ in priced.discounts) _uuid()];
    final paymentId = capture.advancePayment == null ? null : _uuid();
    final capturedAt = _clock();

    int dailyNumber;
    try {
      dailyNumber = await _database.transaction(() async {
        final provisional = await _local.nextProvisionalNumber(capture.orderDate);
        await _local.insertCapture(
          orderId: orderId,
          capture: capture,
          priced: priced,
          dailyNumber: provisional,
          receivedById: receivedById,
          capturedAt: capturedAt,
          garmentIds: garmentIds,
          chargeIds: chargeIds,
          discountIds: discountIds,
          paymentId: paymentId,
        );
        await _sync.enqueue(
          entity: 'order',
          opType: 'create',
          entityId: orderId,
          payload: buildCreatePayload(capture, paymentId: paymentId),
        );
        return provisional;
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    return Right(
      SavedOrder(
        id: orderId,
        dailyNumber: dailyNumber,
        total: priced.total,
        paid: capture.advancePayment?.amount ?? 0,
        warnings: priced.warnings,
        receivedAt: capturedAt,
      ),
    );
  }

  /// Corrige una boleta que sigue en el local (plan 0001 §7.3).
  ///
  /// Reemplaza, no parchea: lo que llega es la boleta como debería leerse, y el
  /// servidor la vuelve a calcular entera al aplicar la operación. Viaja con
  /// `base_version` porque una boleta que cambió mientras el teléfono estaba
  /// sin señal es un conflicto, no una sobrescritura (plan 0004 D6).
  ///
  /// Con una excepción: si el servidor **nunca aceptó** esta boleta, corregirla
  /// vuelve a mandarla como alta. Ver [_neverReachedTheServer].
  Future<Either<AppFailure, void>> update(
    OrderDetail order, {
    required OrderCapture capture,
    required PricedOrder priced,
  }) async {
    if (order.status?.canBeEdited != true) {
      return const Left(
        ValidationFailure('Un pedido entregado o anulado ya no se puede corregir'),
      );
    }
    if (!priced.canSave) {
      return Left(
        ValidationFailure(
          priced.blockers.isEmpty ? 'El pedido necesita al menos un cargo' : priced.blockers.first,
        ),
      );
    }
    if (priced.total < order.paid) {
      // Bajar del total ya cobrado es una devolución, y devolver dinero es un
      // movimiento de caja propio: el servidor lo rechaza y aquí se dice antes.
      return Left(
        ValidationFailure(
          'El pedido ya tiene Q${Fixed2.format(order.paid)} pagados: no puede quedar en '
          'Q${Fixed2.format(priced.total)}',
        ),
      );
    }

    final at = _clock();
    final garmentIds = [for (final _ in capture.garments) _uuid()];
    final chargeIds = [for (final _ in priced.charges) _uuid()];
    final discountIds = [for (final _ in priced.discounts) _uuid()];
    final reissue = _neverReachedTheServer(order);
    final advance = reissue ? _advanceOf(order) : null;

    return _write(() async {
      await _local.rewriteCapture(
        orderId: order.id,
        capture: capture,
        priced: priced,
        at: at,
        garmentIds: garmentIds,
        chargeIds: chargeIds,
        discountIds: discountIds,
      );
      await _sync.enqueue(
        entity: 'order',
        opType: reissue ? 'create' : 'update',
        entityId: order.id,
        // Un alta no lleva `base_version`: no hay versión anterior contra la
        // cual chocar.
        baseVersion: reissue ? null : order.version,
        payload: reissue
            ? buildCreatePayload(
                capture,
                advance: advance?.draft,
                paymentId: advance?.id,
              )
            : buildUpdatePayload(capture),
      );
    });
  }

  /// Si el servidor no tiene esta boleta y por lo tanto corregirla es volver a
  /// darla de alta.
  ///
  /// La combinación es la que lo dice: la fila está `rejected` —su operación
  /// cayó a la cola de revisión— y sigue en la versión `0`, o sea que el feed
  /// nunca trajo una copia del servidor. Mandarle un `update` sería hablarle de
  /// un pedido que no conoce; el id lo minteó este dispositivo (D3), así que
  /// darlo de alta otra vez es exactamente lo correcto.
  ///
  /// Ojo con confundirlo con una boleta `pending`: esa también está en la
  /// versión 0, pero su `order/create` sigue en el outbox y se aplicará antes
  /// que la corrección, que va detrás en el mismo orden de `seq`.
  static bool _neverReachedTheServer(OrderDetail order) =>
      order.needsReview && order.version == 0;

  /// El anticipo que ya está registrado en el dispositivo.
  ///
  /// Al reemitir el alta hay que llevarlo: la pantalla de corrección no lo
  /// pregunta —el dinero recibido es un hecho que ocurrió, no un campo
  /// editable— y sin él el servidor daría de alta la boleta sin el pago que el
  /// cliente sí hizo. Viaja con **su id original**, que es lo que impide que
  /// aparezca dos veces si el alta se reintenta.
  static ({PaymentDraft draft, String id})? _advanceOf(OrderDetail order) {
    for (final payment in order.payments) {
      final method = payment.method;
      if (!payment.isAdvance || method == null) continue;
      return (
        id: payment.id,
        draft: PaymentDraft(
          amount: payment.amount,
          method: method,
          reference: payment.reference,
        ),
      );
    }
    return null;
  }

  Stream<List<OrderListItem>> watchByDate(String orderDate) =>
      _local.watchByDate(orderDate);

  /// Las boletas que la lavandería todavía no devolvió, de cualquier fecha.
  /// Es la lista de entregas de Caja (plan 0006 §7.1.1).
  Stream<List<OrderListItem>> watchOpen() => _local.watchOpen();

  Stream<OrderDetail?> watchDetail(String id) => _local.watchDetail(id);

  Future<OrderDetail?> detail(String id) => _local.detail(id);

  /// El pedido que ya tiene esa serie de imprenta, dejando fuera [excluding].
  Future<OrderDetail?> byBookletSerial(String serial, {String? excluding}) async {
    final entry = await _local.byBookletSerial(serial, excluding: excluding);
    return entry == null ? null : _local.detail(entry.id);
  }

  /// Mueve el pedido por la cadena `recibido → en proceso → listo`.
  ///
  /// No viaja con `base_version`, igual que archivar un cliente: avanzar de
  /// estado es un cambio de estado, no una escritura sobre campos, y hacerlo
  /// encima de la corrección de otro dispositivo no es un conflicto — el pedido
  /// queda en proceso igual.
  Future<Either<AppFailure, void>> changeStatus(
    OrderDetail order,
    OrderStatus status,
  ) async {
    final current = order.status;
    if (current == null || !current.nextSteps.contains(status)) {
      return Left(ValidationFailure('Un pedido ${current?.label ?? '—'} no puede pasar a ${status.label}'));
    }

    return _write(() async {
      await _local.markStatus(order.id, status);
      await _sync.enqueue(
        entity: 'order',
        opType: 'status',
        entityId: order.id,
        payload: {'status': status.wire},
      );
    });
  }

  /// Entrega la ropa: cuánto volvió de cada prenda y, si se cobra al entregar,
  /// el pago final (plan 0001 §7.2).
  ///
  /// [delivered] va por **id de línea**, no por tipo de prenda: es la línea la
  /// que se corrige, y dos líneas del mismo tipo en un pedido son dos conteos
  /// distintos.
  Future<Either<AppFailure, void>> deliver(
    OrderDetail order, {
    required Map<String, int> delivered,
    required String actorId,
    PaymentDraft? payment,
  }) async {
    if (order.status?.canBeDelivered != true) {
      return const Left(
        ValidationFailure('Esta boleta ya está cerrada: no se puede entregar de nuevo'),
      );
    }
    if (payment != null && payment.amount > order.balance) {
      return const Left(ValidationFailure('El pago no puede ser mayor que el saldo'));
    }

    final at = _clock();
    final paymentId = payment == null ? null : _uuid();

    return _write(() async {
      if (payment != null && paymentId != null) {
        await _local.insertPayment(
          paymentId: paymentId,
          orderId: order.id,
          payment: payment,
          receivedById: actorId,
          paidAt: at,
        );
      }
      await _local.markDelivered(
        id: order.id,
        delivered: delivered,
        deliveredById: actorId,
        at: at,
      );
      await _sync.enqueue(
        entity: 'order',
        opType: 'deliver',
        entityId: order.id,
        payload: <String, dynamic>{
          'garments': [
            for (final line in order.garments)
              if (delivered.containsKey(line.id))
                <String, dynamic>{
                  'garment_type_id': line.garmentTypeId,
                  'quantity_delivered': delivered[line.id],
                },
          ],
          if (payment != null)
            'payment': <String, dynamic>{
              'amount': Fixed2.format(payment.amount),
              'method': payment.method.wire,
              'is_advance': false,
              'reference': payment.reference,
              'id': paymentId,
            },
        },
      );
    });
  }

  /// Cobra contra un pedido ya capturado (plan 0006 §5.6).
  ///
  /// Es su **propia entidad** de sync y no una edición del pedido: `entity_id`
  /// es el id del pago, y eso es lo que hace que reintentar el push no cobre
  /// dos veces.
  Future<Either<AppFailure, void>> addPayment(
    OrderDetail order, {
    required PaymentDraft payment,
    required String actorId,
  }) async {
    if (order.status?.acceptsPayments != true) {
      return const Left(ValidationFailure('Un pedido anulado ya no admite pagos'));
    }
    if (payment.amount <= 0) {
      return const Left(ValidationFailure('El monto tiene que ser mayor que cero'));
    }
    if (payment.amount > order.balance) {
      // El vuelto que se da en el mostrador no es dinero que se quedó en la
      // caja; el servidor lo rechaza y aquí se dice antes de mandarlo.
      return const Left(ValidationFailure('El pago no puede ser mayor que el saldo'));
    }

    final paymentId = _uuid();
    final at = _clock();

    return _write(() async {
      await _local.insertPayment(
        paymentId: paymentId,
        orderId: order.id,
        payment: payment,
        receivedById: actorId,
        paidAt: at,
      );
      await _sync.enqueue(
        entity: 'order_payment',
        opType: 'create',
        entityId: paymentId,
        payload: <String, dynamic>{
          'order_id': order.id,
          'amount': Fixed2.format(payment.amount),
          'method': payment.method.wire,
          'is_advance': false,
          'reference': payment.reference,
        },
      );
    });
  }

  /// Anula el pedido. El dinero ya cobrado **no se toca**: devolverlo es un
  /// movimiento de caja propio, y borrar el pago dejaría el cajón corto sin
  /// nada a qué apuntar (plan 0001 §7.3).
  Future<Either<AppFailure, void>> cancel(
    OrderDetail order, {
    required String reason,
    required String actorId,
  }) async {
    if (order.status?.canBeCancelled != true) {
      return const Left(
        ValidationFailure('Solo se puede anular un pedido recibido o en proceso'),
      );
    }
    final motive = reason.trim();
    if (motive.length < 3) {
      return const Left(ValidationFailure('Escribí el motivo de la anulación'));
    }

    final at = _clock();

    return _write(() async {
      await _local.markCancelled(
        id: order.id,
        reason: motive,
        cancelledById: actorId,
        at: at,
      );
      await _sync.enqueue(
        entity: 'order',
        opType: 'cancel',
        entityId: order.id,
        payload: {'reason': motive},
      );
    });
  }

  /// La fila espejo y la operación del outbox, en una transacción.
  ///
  /// Separarlas dejaría o un pedido que en la pantalla ya está entregado y que
  /// nadie va a subir, o una operación sobre un cambio que aquí no ocurrió.
  Future<Either<AppFailure, void>> _write(Future<void> Function() body) async {
    try {
      await _database.transaction(body);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
    return const Right(null);
  }

  /// El cuerpo de `order/create`, con los nombres de campo del backend.
  ///
  /// Van cantidades y elecciones, **nunca precios** (D5): los que la pantalla
  /// mostró son una vista previa, y el servidor los vuelve a resolver contra el
  /// catálogo vigente en la fecha del pedido. La única excepción es el monto de
  /// los servicios `variable`, que no sale de ningún catálogo porque lo decidió
  /// el motorista.
  ///
  /// [advance] permite mandar un anticipo que no viene de la pantalla: es el
  /// caso de una boleta que se rechazó y se vuelve a dar de alta corregida, con
  /// el pago que ya estaba registrado aquí.
  static Map<String, dynamic> buildCreatePayload(
    OrderCapture capture, {
    String? paymentId,
    PaymentDraft? advance,
  }) {
    final payment = advance ?? capture.advancePayment;

    return <String, dynamic>{
      'order_date': capture.orderDate,
      // Solo en el alta: es de dónde salió esta boleta, no un campo que se
      // corrija después. Una corrección posterior ya no es lo que el modelo
      // propuso, y contarla contra él falsearía la métrica de D7.
      if (capture.scanId != null) 'scan_id': capture.scanId,
      ..._body(capture),
      if (payment != null)
        'advance_payment': <String, dynamic>{
          'amount': Fixed2.format(payment.amount),
          'method': payment.method.wire,
          'is_advance': true,
          'reference': payment.reference,
          // El id lo pone el dispositivo para que el pago que quedó en la
          // pantalla y el que guarde el servidor sean el mismo, y para que
          // reintentar el push no cobre dos veces.
          'id': paymentId,
        },
    };
  }

  /// El cuerpo de `order/update`.
  ///
  /// Es el mismo que el de la captura **menos tres cosas**: la fecha, que
  /// pertenece al día en que se tomó la boleta; el estado, que tiene sus
  /// propias operaciones; y el pago, porque el dinero recibido es un hecho que
  /// ocurrió y se anula, no se edita.
  static Map<String, dynamic> buildUpdatePayload(OrderCapture capture) => _body(capture);

  static Map<String, dynamic> _body(OrderCapture capture) {
    return <String, dynamic>{
      'booklet_serial': capture.bookletSerial,
      'customer_id': capture.customerId,
      'nit': capture.nit,
      'weight_lbs': capture.weightLbs == null ? null : Fixed2.format(capture.weightLbs!),
      'observations': capture.observations,
      'garments': [
        for (final garment in capture.garments)
          <String, dynamic>{
            'garment_type_id': garment.garmentTypeId,
            'quantity': garment.quantity,
            'notes': garment.notes,
          },
      ],
      'charges': [
        for (final charge in capture.charges)
          <String, dynamic>{
            'service_code': charge.serviceCode,
            'option_code': charge.optionCode,
            'quantity': Fixed2.format(charge.quantity),
            if (charge.amount != null) 'amount': Fixed2.format(charge.amount!),
          },
      ],
      // Una promoción viaja como su código y **sin monto**: cuánto rebaja es
      // aritmética del servidor contra el catálogo de la fecha (D5). El monto
      // solo aparece en el descuento manual, que es donde alguien lo decidió.
      'discounts': [
        for (final discount in capture.discounts)
          switch (discount) {
            PromotionDiscount(:final promotionCode) => <String, dynamic>{
              'promotion_code': promotionCode,
            },
            ManualDiscount(:final description, :final amount) => <String, dynamic>{
              'description': description,
              'amount': Fixed2.format(amount),
            },
          },
      ],
    };
  }
}

@Riverpod(keepAlive: true)
OrdersRepository ordersRepository(Ref ref) {
  return OrdersRepository(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(ordersLocalDataSourceProvider),
    sync: ref.watch(syncRepositoryProvider),
  );
}
