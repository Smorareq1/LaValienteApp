import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tablas espejo de insumos (plan 0005 §6.3; plan 0004 §7.3).
///
/// Productos y lotes bajan y nunca suben: el inventario se administra en línea
/// (D11). La venta de mostrador sí sube, porque es la que ocurre con un cliente
/// enfrente.

@DataClassName('ProductEntry')
class ProductEntries extends Table with SyncedColumns {
  TextColumn get name => text().withLength(max: 120)();

  /// Bote, bolsa, galón, saco… texto libre porque lo decide el proveedor.
  TextColumn get unit => text().withLength(max: 30)();

  TextColumn get description => text().nullable()();

  /// Ruta bajo `MEDIA_DIR` del servidor. Cambia cada vez que se reemplaza la
  /// foto, y ese cambio es lo que le dice a la app que la que tiene en caché ya
  /// no sirve.
  TextColumn get imagePath => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ProductLotEntry')
class ProductLotEntries extends Table with SyncedColumns {
  TextColumn get productId => text()();

  /// Correlativo por producto, el número con el que se habla del lote.
  IntColumn get lotNumber => integer()();

  TextColumn get quantityReceived => text().withLength(max: 20)();
  TextColumn get quantityAvailable => text().withLength(max: 20)();

  /// Nulo = el lote es consumo interno de la lavandería y el FIFO de venta lo
  /// salta. **No hay `unitCost`**: el feed no lo manda a propósito (el margen de
  /// compra no se lee en el mostrador) y por eso aquí tampoco existe.
  TextColumn get salePrice => text().withLength(max: 20).nullable()();

  /// Fecha de recepción en `YYYY-MM-DD`. Es la que ordena el FIFO.
  TextColumn get receivedAt => text().withLength(max: 10)();
}

@DataClassName('SupplySaleEntry')
class SupplySaleEntries extends Table with SyncedColumns {
  TextColumn get saleDate => text().withLength(max: 10)();
  TextColumn get customerId => text().nullable()();
  TextColumn get nit => text().withLength(max: 20).nullable()();
  TextColumn get method => text().withLength(max: 20)();
  TextColumn get reference => text().withLength(max: 80).nullable()();

  /// Lo que la venta suma al día. Mientras está `pending` es la vista previa que
  /// calculó el dispositivo; al aplicarse, el servidor la vuelve a valuar contra
  /// los lotes de ese momento y el feed pisa esta columna (D10).
  TextColumn get total => text().withLength(max: 20)();

  TextColumn get soldById => text()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelledById => text().nullable()();
  TextColumn get cancelReason => text().nullable()();

  /// Hora de la venta, que es lo que la lista de ingresos del día muestra.
  DateTimeColumn get createdAt => dateTime().nullable()();
}

@DataClassName('SupplySaleItemEntry')
class SupplySaleItemEntries extends Table with SyncedColumns {
  TextColumn get saleId => text()();

  /// El lote que cubrió la línea. **Nulo mientras la venta no ha subido**: qué
  /// lote sale es la respuesta del FIFO del servidor (D5), y el mostrador elige
  /// un producto, nunca un lote.
  TextColumn get lotId => text().nullable()();

  /// El producto que se eligió. Columna local, no del feed: es lo único que el
  /// dispositivo sabe de una línea capturada, y es lo que deja descontar el
  /// stock en pantalla antes de que el servidor conteste. En las filas que baja
  /// el feed va nulo y el producto se resuelve por el lote.
  TextColumn get productId => text().nullable()();

  TextColumn get description => text().withLength(max: 160)();
  TextColumn get quantity => text().withLength(max: 20)();
  TextColumn get unitPrice => text().withLength(max: 20)();
  TextColumn get amount => text().withLength(max: 20)();
}
