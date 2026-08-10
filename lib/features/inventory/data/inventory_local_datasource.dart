import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../domain/supply_sale_pricing.dart';
import '../models/product.dart';

part 'inventory_local_datasource.g.dart';

/// Lectura y escritura de insumos en la BD local. I/O puro sobre Drift.
class InventoryLocalDataSource {
  const InventoryLocalDataSource(this._database);

  final AppDatabase _database;

  /// Lo que hay para vender, producto por producto.
  ///
  /// Se dispara con las tres tablas que pueden cambiarlo: los productos, los
  /// lotes y las líneas de venta —una venta capturada aquí baja el stock de la
  /// pantalla sin que el servidor haya contestado todavía.
  Stream<List<ProductShelf>> watchShelf() {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.productEntries,
            _database.productLotEntries,
            _database.supplySaleItemEntries,
          },
        )
        .watch()
        .asyncMap((_) => shelf());
  }

  Future<List<ProductShelf>> shelf() async {
    final products =
        await (_database.select(_database.productEntries)
              ..where((row) => row.deletedAt.isNull() & row.isActive.equals(true))
              ..orderBy([
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.name),
              ]))
            .get();

    final lotRows =
        await (_database.select(_database.productLotEntries)
              ..where((row) => row.deletedAt.isNull())
              // Orden de llegada, que es el orden del FIFO. El número de lote
              // desempata: dos lotes recibidos el mismo día salen en el orden en
              // que se registraron.
              ..orderBy([
                (row) => OrderingTerm.asc(row.receivedAt),
                (row) => OrderingTerm.asc(row.lotNumber),
              ]))
            .get();

    final committed = await _committedByProduct();

    final byProduct = <String, List<LotStock>>{};
    for (final row in lotRows) {
      final price = Fixed2.parse(row.salePrice);
      final quantity = Fixed2.parse(row.quantityAvailable) ?? 0;
      if (price == null || quantity <= 0) continue;
      byProduct
          .putIfAbsent(row.productId, () => [])
          .add(
            LotStock(
              lotId: row.id,
              lotNumber: row.lotNumber,
              quantityAvailable: quantity,
              salePrice: price,
            ),
          );
    }

    return [
      for (final product in products)
        ProductShelf(
          id: product.id,
          name: product.name,
          unit: product.unit,
          imagePath: product.imagePath,
          lots: _minus(byProduct[product.id] ?? const [], committed[product.id] ?? 0),
        ),
    ];
  }

  /// El inventario, no el mostrador (§8.1).
  ///
  /// A diferencia de [watchShelf], aquí entra **todo** el stock: los lotes de
  /// consumo interno, que no tienen precio y el FIFO de venta salta, son
  /// suavizante que la lavandería sí tiene. Y no se descuenta lo capturado sin
  /// señal: esta pantalla dice qué hay registrado, no qué se puede vender ahora.
  Stream<List<ProductSummary>> watchProducts({bool includeArchived = false}) {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {_database.productEntries, _database.productLotEntries},
        )
        .watch()
        .asyncMap((_) => products(includeArchived: includeArchived));
  }

  Future<List<ProductSummary>> products({bool includeArchived = false}) async {
    final rows =
        await (_database.select(_database.productEntries)
              ..where(
                (row) => includeArchived
                    ? row.deletedAt.isNull()
                    : row.deletedAt.isNull() & row.isActive.equals(true),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.name),
              ]))
            .get();

    final lots = await _liveLots();
    return [for (final row in rows) _toSummary(row, lots[row.id] ?? const [])];
  }

  /// Un producto con sus lotes y su kardex (§8.2).
  Stream<ProductDetail?> watchDetail(String productId) {
    return _database
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _database.productEntries,
            _database.productLotEntries,
            _database.inventoryMovementEntries,
          },
        )
        .watch()
        .asyncMap((_) => detail(productId));
  }

  Future<ProductDetail?> detail(String productId) async {
    final row =
        await (_database.select(_database.productEntries)
              ..where((product) => product.id.equals(productId))
              ..limit(1))
            .getSingleOrNull();
    if (row == null || row.deletedAt != null) return null;

    final lots = (await _liveLots())[productId] ?? const <ProductLot>[];
    final movements = await _movementsFor(lots.map((lot) => lot.id).toList());

    return ProductDetail(
      product: _toSummary(row, lots),
      lots: lots,
      movements: movements,
    );
  }

  /// Los lotes vivos agrupados por producto, en orden de llegada (el del FIFO).
  Future<Map<String, List<ProductLot>>> _liveLots() async {
    final rows =
        await (_database.select(_database.productLotEntries)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([
                (row) => OrderingTerm.asc(row.receivedAt),
                (row) => OrderingTerm.asc(row.lotNumber),
              ]))
            .get();

    final byProduct = <String, List<ProductLot>>{};
    for (final row in rows) {
      byProduct
          .putIfAbsent(row.productId, () => [])
          .add(
            ProductLot(
              id: row.id,
              lotNumber: row.lotNumber,
              quantityReceived: Fixed2.parse(row.quantityReceived) ?? 0,
              quantityAvailable: Fixed2.parse(row.quantityAvailable) ?? 0,
              receivedAt: row.receivedAt,
              salePrice: Fixed2.parse(row.salePrice),
              version: row.version,
            ),
          );
    }
    return byProduct;
  }

  /// El kardex de unos lotes, de lo más reciente a lo más viejo.
  ///
  /// Vacío si el producto no tiene lotes: sin `IN ()` que armar, la consulta se
  /// ahorra y devuelve lo mismo.
  Future<List<InventoryMovement>> _movementsFor(List<String> lotIds) async {
    if (lotIds.isEmpty) return const [];

    final movements = _database.inventoryMovementEntries;
    final lots = _database.productLotEntries;

    final rows =
        await (_database.select(movements).join([
              innerJoin(lots, lots.id.equalsExp(movements.lotId)),
            ])
              ..where(movements.deletedAt.isNull() & movements.lotId.isIn(lotIds))
              ..orderBy([OrderingTerm.desc(movements.createdAt)]))
            .get();

    return [
      for (final row in rows)
        InventoryMovement(
          id: row.readTable(movements).id,
          lotId: row.readTable(movements).lotId,
          lotNumber: row.readTable(lots).lotNumber,
          type: MovementType.fromWire(row.readTable(movements).movementType),
          quantity: Fixed2.parse(row.readTable(movements).quantity) ?? 0,
          unitPrice: Fixed2.parse(row.readTable(movements).unitPrice),
          notes: row.readTable(movements).notes,
          createdAt: row.readTable(movements).createdAt,
        ),
    ];
  }

  static ProductSummary _toSummary(ProductEntry row, List<ProductLot> lots) {
    var stock = 0;
    var sellable = 0;
    int? nextPrice;
    for (final lot in lots) {
      if (lot.quantityAvailable <= 0) continue;
      stock += lot.quantityAvailable;
      if (lot.salePrice == null) continue;
      sellable += lot.quantityAvailable;
      // Los lotes vienen en orden de llegada, así que el primero vendible con
      // existencias es el que saldría (D5).
      nextPrice ??= lot.salePrice;
    }

    return ProductSummary(
      id: row.id,
      name: row.name,
      unit: row.unit,
      isActive: row.isActive,
      stock: stock,
      sellableStock: sellable,
      version: row.version,
      imagePath: row.imagePath,
      description: row.description,
      nextSalePrice: nextPrice,
    );
  }

  /// Lo que las ventas todavía sin confirmar ya se llevaron, por producto.
  ///
  /// La fila del lote sigue diciendo lo que el servidor sabía, porque el pull no
  /// pisa filas `pending` y una venta capturada sin señal no movió nada allá.
  /// Sin este descuento, el último bote se podría vender dos veces sin que la
  /// pantalla dijera nada.
  Future<Map<String, int>> _committedByProduct() async {
    final items = _database.supplySaleItemEntries;
    final rows =
        await (_database.select(items)..where(
              (row) =>
                  row.deletedAt.isNull() &
                  row.syncStatus.equals(RowSyncStatus.pending.name) &
                  row.productId.isNotNull(),
            ))
            .get();

    final committed = <String, int>{};
    for (final row in rows) {
      final productId = row.productId;
      if (productId == null) continue;
      committed[productId] = (committed[productId] ?? 0) + (Fixed2.parse(row.quantity) ?? 0);
    }
    return committed;
  }

  /// Descuenta [quantity] de los lotes más viejos, que es de donde saldría.
  static List<LotStock> _minus(List<LotStock> lots, int quantity) {
    if (quantity <= 0) return lots;

    final remaining = <LotStock>[];
    var pending = quantity;
    for (final lot in lots) {
      if (pending <= 0) {
        remaining.add(lot);
        continue;
      }
      final taken = pending < lot.quantityAvailable ? pending : lot.quantityAvailable;
      pending -= taken;
      final left = lot.quantityAvailable - taken;
      if (left > 0) {
        remaining.add(
          LotStock(
            lotId: lot.lotId,
            lotNumber: lot.lotNumber,
            quantityAvailable: left,
            salePrice: lot.salePrice,
          ),
        );
      }
    }
    return remaining;
  }

  /// Las ventas de [date] que siguen en pie, de la más reciente a la más vieja.
  Stream<List<SupplySaleSummary>> watchSalesByDate(String date) {
    final sales = _database.supplySaleEntries;
    final customers = _database.customerEntries;
    final items = _database.supplySaleItemEntries;

    final query =
        _database.select(sales).join([
            leftOuterJoin(customers, customers.id.equalsExp(sales.customerId)),
            leftOuterJoin(items, items.saleId.equalsExp(sales.id) & items.deletedAt.isNull()),
          ])
          ..where(sales.deletedAt.isNull() & sales.saleDate.equals(date))
          ..orderBy([OrderingTerm.desc(sales.createdAt)]);

    return query.watch().map((rows) {
      final byId = <String, SupplySaleEntry>{};
      final names = <String, String?>{};
      final counted = <String, Set<String>>{};

      for (final row in rows) {
        final sale = row.readTable(sales);
        byId[sale.id] = sale;
        names[sale.id] = row.readTableOrNull(customers)?.fullName;
        final item = row.readTableOrNull(items);
        // El join repite la venta una vez por línea: sin este control una venta
        // de tres productos contaría nueve.
        if (item != null) counted.putIfAbsent(sale.id, () => {}).add(item.id);
      }

      return [
        for (final sale in byId.values)
          SupplySaleSummary(
            id: sale.id,
            saleDate: sale.saleDate,
            total: Fixed2.parse(sale.total) ?? 0,
            method: PaymentMethod.fromWire(sale.method),
            syncStatus: RowSyncStatus.values.byName(sale.syncStatus),
            itemCount: counted[sale.id]?.length ?? 0,
            customerName: names[sale.id],
            createdAt: sale.createdAt,
            cancelledAt: sale.cancelledAt,
          ),
      ];
    });
  }

  /// Escribe la venta capturada aquí: cabecera y líneas, todas `pending`.
  ///
  /// Las líneas llevan el **producto** y no el lote: cuál sale es la respuesta
  /// del FIFO del servidor, y el mostrador no la conoce. Su id es de este
  /// dispositivo y el servidor nunca lo verá — por eso el espejo las retira
  /// cuando la venta se aplica y baja la versión buena.
  Future<void> insertSale({
    required String saleId,
    required String saleDate,
    required List<PricedSaleLine> lines,
    required List<String> lineIds,
    required int total,
    required PaymentMethod method,
    required String soldById,
    required DateTime capturedAt,
    String? customerId,
    String? nit,
    String? reference,
  }) async {
    const pending = RowSyncStatus.pending;

    await _database
        .into(_database.supplySaleEntries)
        .insert(
          SupplySaleEntriesCompanion.insert(
            id: saleId,
            syncStatus: Value(pending.name),
            saleDate: saleDate,
            customerId: Value(customerId),
            nit: Value(nit),
            method: method.wire,
            reference: Value(reference),
            total: Fixed2.format(total),
            soldById: soldById,
            createdAt: Value(capturedAt),
          ),
        );

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      await _database
          .into(_database.supplySaleItemEntries)
          .insert(
            SupplySaleItemEntriesCompanion.insert(
              id: lineIds[i],
              syncStatus: Value(pending.name),
              saleId: saleId,
              productId: Value(line.productId),
              description: line.productName,
              quantity: Fixed2.format(line.quantity),
              unitPrice: Fixed2.format(line.unitPrice),
              amount: Fixed2.format(line.amount),
            ),
          );
    }
  }
}

@Riverpod(keepAlive: true)
InventoryLocalDataSource inventoryLocalDataSource(Ref ref) {
  return InventoryLocalDataSource(ref.watch(appDatabaseProvider));
}
