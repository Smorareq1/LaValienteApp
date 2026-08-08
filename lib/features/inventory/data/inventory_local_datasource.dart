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
