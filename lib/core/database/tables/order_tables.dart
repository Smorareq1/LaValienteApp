import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tablas espejo de pedidos (plan 0004 §7.3: bidireccional; plan 0001 §5.3).
///
/// Un pedido baja como cinco filas y no como un documento anidado, igual que
/// viaja en el feed: cada tabla tiene su propio `sync_seq`, así que un pago
/// cobrado hoy llega sin reenviar el pedido entero. La app las vuelve a juntar
/// por `orderId`.
///
/// El dinero se guarda como texto por la misma razón que en el catálogo: un
/// `double` convierte Q108.75 en algo que no es Q108.75, y el error aparece
/// meses después en un total que nadie sabe explicar.

@DataClassName('OrderEntry')
class OrderEntries extends Table with SyncedColumns {
  /// Fecha de negocio en `YYYY-MM-DD` (D8). Sin hora ni zona: el día al que
  /// pertenece un pedido es un dato del local, no un instante UTC.
  TextColumn get orderDate => text().withLength(max: 10)();

  /// Correlativo del día, el número que la gente dice en voz alta.
  IntColumn get dailyNumber => integer()();

  TextColumn get bookletSerial => text().withLength(max: 20).nullable()();
  TextColumn get customerId => text()();
  TextColumn get nit => text().withLength(max: 20).nullable()();
  TextColumn get weightLbs => text().withLength(max: 20).nullable()();
  IntColumn get totalPieces => integer().withDefault(const Constant(0))();
  TextColumn get observations => text().nullable()();

  /// `received`, `in_progress`, `ready`, `delivered` o `cancelled`. String y no
  /// enum local: el ciclo de vida lo define el servidor, y un enum obligaría a
  /// migrar la BD el día que estrene un estado.
  TextColumn get status => text().withLength(max: 20)();

  TextColumn get subtotal => text().withLength(max: 20)();
  TextColumn get discountTotal => text().withLength(max: 20)();
  TextColumn get total => text().withLength(max: 20)();
  TextColumn get receivedById => text()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
  TextColumn get deliveredById => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelledById => text().nullable()();
  TextColumn get cancelReason => text().nullable()();

  /// Hora a la que se recibió la boleta. Anulable porque las filas que ya
  /// estaban en el dispositivo antes de que este campo viajara no la tienen, y
  /// porque no vale la pena inventarles una.
  DateTimeColumn get createdAt => dateTime().nullable()();

  // Sin `searchIndex` propio, a diferencia de clientes: buscar un pedido por
  // nombre se resuelve uniendo con `customer_entries`, que ya lo tiene. Copiarlo
  // aquí obligaría a reindexar todos los pedidos de alguien cada vez que
  // corrigen su nombre, y a que el pedido supiera esperar a que su cliente baje.
}

@DataClassName('OrderGarmentEntry')
class OrderGarmentEntries extends Table with SyncedColumns {
  TextColumn get orderId => text()();
  TextColumn get garmentTypeId => text()();
  IntColumn get quantity => integer()();

  /// Se llena al entregar; el hueco contra `quantity` es la pérdida.
  IntColumn get quantityDelivered => integer().nullable()();

  TextColumn get notes => text().nullable()();
}

@DataClassName('OrderChargeEntry')
class OrderChargeEntries extends Table with SyncedColumns {
  TextColumn get orderId => text()();
  TextColumn get serviceTypeId => text()();
  TextColumn get serviceOptionId => text().nullable()();

  /// Copia legible del catálogo al momento de capturar (D2): subir mañana el
  /// precio de la tina grande no puede reescribir lo que el pedido de hoy dice.
  TextColumn get description => text().withLength(max: 160)();

  TextColumn get quantity => text().withLength(max: 20)();
  TextColumn get unitPrice => text().withLength(max: 20)();
  TextColumn get amount => text().withLength(max: 20)();
}

@DataClassName('OrderDiscountEntry')
class OrderDiscountEntries extends Table with SyncedColumns {
  TextColumn get orderId => text()();

  /// Nulo = descuento manual, que exige `orders.manual_discount`.
  TextColumn get promotionId => text().nullable()();

  TextColumn get description => text().withLength(max: 160)();
  TextColumn get amount => text().withLength(max: 20)();
}

@DataClassName('OrderPaymentEntry')
class OrderPaymentEntries extends Table with SyncedColumns {
  TextColumn get orderId => text()();
  TextColumn get amount => text().withLength(max: 20)();

  /// `cash` o `transfer`.
  TextColumn get method => text().withLength(max: 20)();

  BoolColumn get isAdvance => boolean().withDefault(const Constant(false))();
  TextColumn get reference => text().withLength(max: 80).nullable()();
  TextColumn get receivedById => text()();
  DateTimeColumn get paidAt => dateTime()();
}
