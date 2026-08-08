import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejos de insumos.
///
/// Productos, lotes y movimientos bajan y nunca suben (se administran en línea,
/// D11); la venta de mostrador sube, porque ocurre con un cliente enfrente y no
/// puede esperar señal.
List<TableMirror<DataClass>> inventoryMirrors(AppDatabase database) => [
  ProductMirror(database),
  ProductLotMirror(database),
  SupplySaleMirror(database),
  SupplySaleItemMirror(database),
  InventoryMovementMirror(database),
];

DateTime? _instant(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toUtc();

class ProductMirror extends TableMirror<ProductEntry> {
  const ProductMirror(super.database);

  @override
  String get entity => 'product';

  @override
  TableInfo<Table, ProductEntry> get table => database.productEntries;

  @override
  ProductEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ProductEntriesCompanion(
      name: Value(data['name'] as String),
      unit: Value(data['unit'] as String),
      description: Value(data['description'] as String?),
      imagePath: Value(data['image_path'] as String?),
      isActive: Value(data['is_active'] as bool),
      sortOrder: Value(data['sort_order'] as int),
    );
  }
}

class ProductLotMirror extends TableMirror<ProductLotEntry> {
  const ProductLotMirror(super.database);

  @override
  String get entity => 'product_lot';

  @override
  TableInfo<Table, ProductLotEntry> get table => database.productLotEntries;

  @override
  ProductLotEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ProductLotEntriesCompanion(
      productId: Value(data['product_id'] as String),
      lotNumber: Value(data['lot_number'] as int),
      quantityReceived: Value(data['quantity_received'] as String),
      quantityAvailable: Value(data['quantity_available'] as String),
      salePrice: Value(data['sale_price'] as String?),
      receivedAt: Value(data['received_at'] as String),
    );
  }
}

class SupplySaleMirror extends TableMirror<SupplySaleEntry> {
  const SupplySaleMirror(super.database);

  @override
  String get entity => 'supply_sale';

  @override
  TableInfo<Table, SupplySaleEntry> get table => database.supplySaleEntries;

  @override
  SupplySaleEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return SupplySaleEntriesCompanion(
      saleDate: Value(data['sale_date'] as String),
      customerId: Value(data['customer_id'] as String?),
      nit: Value(data['nit'] as String?),
      method: Value(data['method'] as String),
      reference: Value(data['reference'] as String?),
      total: Value(data['total'] as String),
      soldById: Value(data['sold_by_id'] as String),
      cancelledAt: Value(_instant(data['cancelled_at'])),
      cancelledById: Value(data['cancelled_by_id'] as String?),
      cancelReason: Value(data['cancel_reason'] as String?),
      createdAt: Value(_instant(data['created_at'])),
    );
  }

  /// La venta se resuelve y sus líneas capturadas se retiran.
  ///
  /// Aquí no vale la cascada de los pedidos —marcarlas `synced` y esperar el
  /// feed— porque **las líneas de una venta no tienen el id que el dispositivo
  /// les puso**. El mostrador elige productos y cantidades; qué lote las cubre
  /// y a qué precio lo decide el FIFO del servidor (D5), que crea las filas
  /// buenas con ids suyos. Dejar las locales dejaría cada línea dos veces: la
  /// preview y la de verdad.
  ///
  /// Rechazada es distinto: la venta no existe del otro lado, no va a bajar
  /// nada, y las líneas son lo único que dice qué se había capturado. Se quedan
  /// hasta que alguien decida en la cola de revisión.
  @override
  Future<void> settle(String entityId, {required bool rejected}) async {
    await super.settle(entityId, rejected: rejected);
    if (rejected) {
      await _markItems(entityId, RowSyncStatus.rejected);
      return;
    }
    await _tombstoneItems(entityId);
  }

  /// Descartar la venta se lleva sus líneas: son suyas y de nadie más.
  @override
  Future<void> discard(String entityId) async {
    await super.discard(entityId);
    await _tombstoneItems(entityId);
  }

  Future<void> _markItems(String saleId, RowSyncStatus status) {
    final items = database.supplySaleItemEntries;
    return database.customUpdate(
      'UPDATE ${items.actualTableName} SET sync_status = ? WHERE sale_id = ?',
      variables: [Variable<String>(status.name), Variable<String>(saleId)],
      updates: {items},
    );
  }

  Future<void> _tombstoneItems(String saleId) {
    final items = database.supplySaleItemEntries;
    // Solo las capturadas aquí (`pending`). Si el feed ya trajo las del
    // servidor, están `synced` y esta lápida no las toca.
    return database.customUpdate(
      'UPDATE ${items.actualTableName} SET deleted_at = ?, sync_status = ? '
      'WHERE sale_id = ? AND sync_status = ? AND deleted_at IS NULL',
      variables: [
        Variable<DateTime>(DateTime.now()),
        Variable<String>(RowSyncStatus.synced.name),
        Variable<String>(saleId),
        Variable<String>(RowSyncStatus.pending.name),
      ],
      updates: {items},
    );
  }
}

class SupplySaleItemMirror extends TableMirror<SupplySaleItemEntry> {
  const SupplySaleItemMirror(super.database);

  @override
  String get entity => 'supply_sale_item';

  @override
  TableInfo<Table, SupplySaleItemEntry> get table => database.supplySaleItemEntries;

  @override
  SupplySaleItemEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return SupplySaleItemEntriesCompanion(
      saleId: Value(data['sale_id'] as String),
      lotId: Value(data['lot_id'] as String?),
      // `productId` es columna local y el feed no la manda: la fila del servidor
      // nombra el lote, y el producto se resuelve por él.
      productId: const Value(null),
      description: Value(data['description'] as String),
      quantity: Value(data['quantity'] as String),
      unitPrice: Value(data['unit_price'] as String),
      amount: Value(data['amount'] as String),
    );
  }
}

class InventoryMovementMirror extends TableMirror<InventoryMovementEntry> {
  const InventoryMovementMirror(super.database);

  @override
  String get entity => 'inventory_movement';

  @override
  TableInfo<Table, InventoryMovementEntry> get table => database.inventoryMovementEntries;

  @override
  InventoryMovementEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return InventoryMovementEntriesCompanion(
      lotId: Value(data['lot_id'] as String),
      movementType: Value(data['movement_type'] as String),
      quantity: Value(data['quantity'] as String),
      unitPrice: Value(data['unit_price'] as String?),
      supplySaleItemId: Value(data['supply_sale_item_id'] as String?),
      notes: Value(data['notes'] as String?),
      createdById: Value(data['created_by_id'] as String),
      createdAt: Value(_instant(data['created_at'])),
    );
  }
}
