import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/money/fixed2.dart';
import '../../cash/data/expenses_repository.dart';
import '../../customers/data/customers_repository.dart';
import '../../orders/data/orders_repository.dart';
import '../../orders/models/order.dart';
import '../../staff/data/attendance_repository.dart';
import '../data/sync_repository.dart';
import '../models/review_item.dart';
import '../models/review_subject.dart';
import 'sync_engine.dart';

part 'review_queue_controller.g.dart';

/// La cola de revisión en vivo desde la BD local.
@riverpod
Stream<List<ReviewItem>> reviewQueue(Ref ref) {
  return ref.watch(syncRepositoryProvider).watchReviewItems();
}

/// Una entrada concreta, o `null` si ya se resolvió.
///
/// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
/// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
/// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
/// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
@riverpod
AsyncValue<ReviewItem?> reviewEntry(Ref ref, String opId) {
  return ref
      .watch(reviewQueueProvider)
      .whenData((items) => items.where((item) => item.opId == opId).firstOrNull);
}

/// Qué hay ahora sobre lo que la operación tocó (§11.2).
@riverpod
Future<ReviewSubject?> reviewSubject(Ref ref, String opId) async {
  final item = ref.watch(reviewEntryProvider(opId)).valueOrNull;
  if (item == null) return null;

  final orders = ref.watch(ordersRepositoryProvider);

  if (item.kind == ReviewKind.orderCreate) {
    // La boleta rechazada no existe en el servidor; lo que interesa es la que
    // ya se quedó con esa serie, que es casi siempre la misma boleta capturada
    // dos veces (§8).
    final serial = item.bookletSerial;
    if (serial == null) return null;
    final twin = await orders.byBookletSerial(serial, excluding: item.entityId);
    return twin == null ? null : _fromOrder(twin, holdsTheBooklet: true);
  }

  final orderId = item.orderId;
  if (orderId != null) {
    final order = await orders.detail(orderId);
    return order == null ? null : _fromOrder(order);
  }

  final customerId = item.customerId;
  if (customerId == null || item.kind == ReviewKind.customerCreate) return null;

  final customer = await ref.watch(customersRepositoryProvider).byId(customerId);
  if (customer == null) return null;

  return ReviewSubject(
    headline: customer.fullName,
    route: '/customers/${customer.id}',
    openLabel: 'Ver el cliente',
    version: customer.version,
    facts: [
      if (customer.phone != null) ReviewFact('Teléfono', customer.phone!),
      if (customer.nit != null) ReviewFact('NIT', customer.nit!),
      ReviewFact('Estado', customer.isActive ? 'Activo' : 'Archivado'),
    ],
  );
}

ReviewSubject _fromOrder(OrderDetail order, {bool holdsTheBooklet = false}) {
  return ReviewSubject(
    headline: 'Pedido ${order.reference}',
    route: '/orders/${order.id}',
    openLabel: 'Ver el pedido',
    version: order.version,
    holdsTheBooklet: holdsTheBooklet,
    facts: [
      ReviewFact('Cliente', order.customerName),
      if (order.bookletSerial != null) ReviewFact('Boleta', order.bookletSerial!),
      ReviewFact('Estado', order.status?.label ?? '—'),
      ReviewFact('Piezas', '${order.totalPieces}'),
      ReviewFact('Total', 'Q${Fixed2.format(order.total)}'),
      if (order.balance > 0) ReviewFact('Saldo', 'Q${Fixed2.format(order.balance)}'),
    ],
  );
}

/// Las dos decisiones que se pueden tomar sobre una entrada: descartarla o
/// volver a mandarla.
@riverpod
class ReviewQueueController extends _$ReviewQueueController {
  @override
  void build() {}

  /// La captura no sube. Si era un alta, se retira también del dispositivo.
  Future<void> discard(ReviewItem item) {
    return ref.read(syncRepositoryProvider).discardReview(item);
  }

  /// Cierra la entrada sin tocar nada más: la persona ya resolvió el problema
  /// por otro camino —típicamente corrigiendo la boleta, que deja su propia
  /// operación esperando en el outbox.
  Future<void> resolve(ReviewItem item) {
    return ref.read(syncRepositoryProvider).resolveReview(item);
  }

  /// Vuelve a mandarla tal como se capturó.
  ///
  /// Solo las operaciones que llevan `base_version` necesitan refrescarla, y de
  /// esas llegan aquí la de clientes y la de gastos: corregir una boleta que
  /// chocó no se reintenta a ciegas —se vuelve a corregir sobre lo que el
  /// servidor tiene— porque fusionar dos versiones de una boleta es adivinar
  /// (D6). Un gasto es una fila de cinco campos y volver a mandarla tal cual es
  /// una decisión que se puede tomar mirando las dos versiones.
  Future<void> retry(ReviewItem item) async {
    int? baseVersion;
    if (item.kind == ReviewKind.customerUpdate) {
      final customer = await ref.read(customersRepositoryProvider).byId(item.entityId);
      baseVersion = customer?.version;
    }
    if (item.kind == ReviewKind.expenseUpdate) {
      final expense = await ref.read(expensesRepositoryProvider).byId(item.entityId);
      baseVersion = expense?.version;
    }
    if (item.kind == ReviewKind.attendanceUpdate) {
      final record = await ref.read(attendanceRepositoryProvider).byId(item.entityId);
      baseVersion = record?.version;
    }
    await ref.read(syncRepositoryProvider).retryReview(item, baseVersion: baseVersion);
    // Quien acaba de decidir espera que salga ahora, no en el siguiente ciclo
    // periódico: reintentar es una acción, no una captura de mostrador. Por eso
    // se pide a mano y no se deja al disparador del outbox, que se aparta
    // mientras el motor está en backoff —y una operación que llega a esta cola
    // viene justamente de un fallo—.
    ref.read(syncEngineProvider.notifier).syncSoon();
  }
}
