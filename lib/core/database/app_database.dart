import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage_service.dart';
import 'encrypted_connection.dart';
import 'tables/catalog_tables.dart';
import 'tables/customer_tables.dart';
import 'tables/daily_close_tables.dart';
import 'tables/expense_tables.dart';
import 'tables/inventory_tables.dart';
import 'tables/order_tables.dart';
import 'tables/promotion_tables.dart';
// El código generado inlinea el default de `syncStatus`, que sale de este enum:
// sin el import, `app_database.g.dart` no compila.
import 'tables/synced_columns.dart';
import 'tables/sync_tables.dart';

part 'app_database.g.dart';

/// Base de datos local (Drift sobre SQLite cifrado con SQLCipher).
///
/// Es la **fuente de verdad local** del plan 0004: la app lee y escribe aquí
/// siempre, y el motor de sincronización reconcilia contra el servidor por
/// detrás. Las tablas espejo de cada entidad se agregan conforme cada módulo
/// entra al feed.
@DriftDatabase(
  tables: [
    // Motor de sincronización (PR S2).
    SyncStateEntries,
    OutboxEntries,
    ReviewEntries,
    DeferredChanges,
    // Espejo del catálogo y de clientes (PR S3).
    ServiceTypeEntries,
    ServiceOptionEntries,
    ServicePriceEntries,
    GarmentTypeEntries,
    CustomerEntries,
    // Espejo de pedidos (PR S4).
    OrderEntries,
    OrderGarmentEntries,
    OrderChargeEntries,
    OrderDiscountEntries,
    OrderPaymentEntries,
    // Espejo de promociones (PR 5).
    PromotionEntries,
    // Espejo del registro diario (PR 11): gastos, insumos y el acta del cierre.
    ExpenseCategoryEntries,
    ExpenseEntries,
    ProductEntries,
    ProductLotEntries,
    SupplySaleEntries,
    SupplySaleItemEntries,
    DailyClosureEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      // La v1 no declaraba ninguna tabla, así que subir a la v2 es crearlas.
      if (from < 2) {
        await migrator.createAll();
        return;
      }

      // Espejo del catálogo y de clientes (PR S3).
      if (from < 3) {
        await _createAll(migrator, [
          serviceTypeEntries,
          serviceOptionEntries,
          servicePriceEntries,
          garmentTypeEntries,
          customerEntries,
        ]);
      }

      // Espejo de pedidos (PR S4).
      if (from < 4) {
        await _createAll(migrator, [
          orderEntries,
          orderGarmentEntries,
          orderChargeEntries,
          orderDiscountEntries,
          orderPaymentEntries,
        ]);
      }

      // La hora de recepción, que la lista del día muestra en cada tarjeta.
      if (from < 5) {
        await migrator.addColumn(orderEntries, orderEntries.createdAt);
      }

      // Espejo de promociones (PR 5).
      if (from < 6) {
        await _createAll(migrator, [promotionEntries]);
      }

      // Espejo del registro diario (PR 11), lo que la Caja necesita para leerse
      // sin señal: las categorías y los gastos del día, los productos con sus
      // lotes para el mostrador, las ventas de insumo y el acta del cierre.
      if (from < 7) {
        await _createAll(migrator, [
          expenseCategoryEntries,
          expenseEntries,
          productEntries,
          productLotEntries,
          supplySaleEntries,
          supplySaleItemEntries,
          dailyClosureEntries,
        ]);
      }

      // Las tablas espejo nacen vacías y el cursor de pull se rebobina: el feed
      // vuelve a mandar todo desde el principio, que es más barato y más seguro
      // que inventar los datos que faltan. Hace falta incluso con
      // `deferred_changes`: eso guarda lo que llegó sin espejo, no lo que quedó
      // debajo del cursor y por lo tanto nunca se mandó.
      await (update(syncStateEntries)..where((row) => row.id.equals(0))).write(
        const SyncStateEntriesCompanion(
          pullCursor: Value(0),
          bootstrapCompleted: Value(false),
        ),
      );
    },
  );

  Future<void> _createAll(Migrator migrator, List<TableInfo<Table, dynamic>> tables) async {
    for (final table in tables) {
      await migrator.createTable(table);
    }
  }
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  final database = AppDatabase(openEncryptedDatabase(readKey: storage.databaseKey));
  ref.onDispose(database.close);
  return database;
}
