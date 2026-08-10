import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/errors/app_failure.dart';
import 'package:la_valiente/core/money/payment_method.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/inventory/data/inventory_local_datasource.dart';
import 'package:la_valiente/features/inventory/data/inventory_mirrors.dart';
import 'package:la_valiente/features/inventory/data/inventory_repository.dart';
import 'package:la_valiente/features/inventory/domain/supply_sale_pricing.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';

class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late AppDatabase database;
  late InventoryLocalDataSource local;
  late InventoryRepository repository;
  late SyncLocalDataSource syncLocal;

  var ids = 0;

  Future<void> addProduct(String id, String name) {
    return database
        .into(database.productEntries)
        .insert(ProductEntriesCompanion.insert(id: id, name: name, unit: 'bote'));
  }

  Future<void> addLot(
    String id, {
    required String productId,
    required int number,
    required String available,
    String? price,
    String receivedAt = '2026-07-01',
  }) {
    return database
        .into(database.productLotEntries)
        .insert(
          ProductLotEntriesCompanion.insert(
            id: id,
            productId: productId,
            lotNumber: number,
            quantityReceived: available,
            quantityAvailable: available,
            salePrice: Value(price),
            receivedAt: receivedAt,
          ),
        );
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    syncLocal = SyncLocalDataSource(database);
    local = InventoryLocalDataSource(database);
    ids = 0;
    repository = InventoryRepository(
      database: database,
      local: local,
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
      clock: () => DateTime.utc(2026, 7, 18, 20),
    );

    await addProduct('jabon', 'Jabón en polvo');
    await addLot('lote-1', productId: 'jabon', number: 1, available: '5.00', price: '25.00');
    await addLot(
      'lote-2',
      productId: 'jabon',
      number: 2,
      available: '10.00',
      price: '30.00',
      receivedAt: '2026-07-10',
    );
  });

  tearDown(() => database.close());

  group('el estante', () {
    test('trae los lotes vendibles en orden de llegada', () async {
      final shelf = await local.shelf();

      expect(shelf, hasLength(1));
      expect(shelf.single.lots.map((lot) => lot.lotNumber), [1, 2]);
      expect(shelf.single.available, 1500);
      // El precio de la siguiente unidad es el del lote más viejo.
      expect(shelf.single.nextSalePrice, 2500);
    });

    test('un lote sin precio de venta no cuenta como existencia vendible', () async {
      await addLot(
        'lote-interno',
        productId: 'jabon',
        number: 3,
        available: '99.00',
        receivedAt: '2026-06-01',
      );

      final shelf = await local.shelf();
      expect(shelf.single.available, 1500);
    });

    test('una venta capturada sin señal baja el stock de la pantalla', () async {
      // La fila del lote sigue diciendo lo que el servidor sabía —el pull no
      // pisa filas `pending`—, así que sin este descuento el último bote se
      // podría vender dos veces sin que la pantalla dijera nada.
      await repository.createSale(
        SupplySaleDraft(
          saleDate: '2026-07-18',
          lines: [
            priceLine(
              productId: 'jabon',
              productName: 'Jabón en polvo',
              quantity: 600,
              lots: (await local.shelf()).single.lots,
            ),
          ],
        ),
        soldById: 'sebas',
      );

      final shelf = await local.shelf();
      expect(shelf.single.available, 900);
      // Se descuenta del más viejo: el lote 1 se agotó y el precio siguiente ya
      // es el del lote 2.
      expect(shelf.single.lots.map((lot) => lot.lotNumber), [2]);
      expect(shelf.single.nextSalePrice, 3000);
    });

    test('un producto archivado desaparece del mostrador', () async {
      await (database.update(database.productEntries)
            ..where((row) => row.id.equals('jabon')))
          .write(const ProductEntriesCompanion(isActive: Value(false)));

      expect(await local.shelf(), isEmpty);
    });
  });

  group('captura de la venta', () {
    Future<List<PricedSaleLine>> lines(int quantity) async {
      final shelf = await local.shelf();
      return [
        priceLine(
          productId: 'jabon',
          productName: 'Jabón en polvo',
          quantity: quantity,
          lots: shelf.single.lots,
        ),
      ];
    }

    test('escribe cabecera, líneas y operación en una sola transacción', () async {
      final result = await repository.createSale(
        SupplySaleDraft(saleDate: '2026-07-18', lines: await lines(200)),
        soldById: 'sebas',
      );

      final sale = result.getRight().toNullable()!;
      expect(sale.total, 5000);

      final header = await database.select(database.supplySaleEntries).getSingle();
      expect(header.id, sale.id);
      expect(header.syncStatus, RowSyncStatus.pending.name);
      expect(header.soldById, 'sebas');

      final items = await database.select(database.supplySaleItemEntries).get();
      expect(items.single.productId, 'jabon');
      // El lote lo decide el FIFO del servidor: el mostrador no lo conoce.
      expect(items.single.lotId, isNull);

      final pending = await syncLocal.pendingOperations(limit: 10);
      expect(pending.single.entity, 'supply_sale');
      expect(pending.single.opType, 'create');
      expect(pending.single.entityId, sale.id);
    });

    test('el cuerpo lleva productos y cantidades, nunca lotes ni precios', () async {
      await repository.createSale(
        SupplySaleDraft(
          saleDate: '2026-07-18',
          lines: await lines(200),
          method: PaymentMethod.transfer,
          reference: 'TRX-991',
        ),
        soldById: 'sebas',
      );

      final payload = (await syncLocal.pendingOperations(limit: 1)).single.payload;
      expect(payload['sale_date'], '2026-07-18');
      expect(payload['method'], 'transfer');
      expect(payload['reference'], 'TRX-991');
      expect(payload['lines'], [
        {'product_id': 'jabon', 'quantity': '2.00'},
      ]);
    });

    test('el mismo producto dos veces se rechaza antes de encolarlo', () async {
      // El servidor reparte cada línea contra el stock de la base y lo
      // rechazaría; se dice aquí, donde todavía se puede juntar en una línea.
      final line = (await lines(200)).single;
      final result = await repository.createSale(
        SupplySaleDraft(saleDate: '2026-07-18', lines: [line, line]),
        soldById: 'sebas',
      );

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      expect(await syncLocal.pendingCount(), 0);
      expect(await database.select(database.supplySaleEntries).get(), isEmpty);
    });

    test('una venta sin líneas se rechaza', () async {
      final result = await repository.createSale(
        const SupplySaleDraft(saleDate: '2026-07-18', lines: []),
        soldById: 'sebas',
      );

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      expect(await syncLocal.pendingCount(), 0);
    });

    test('vender más de lo contado se permite: el servidor decide', () async {
      final result = await repository.createSale(
        SupplySaleDraft(saleDate: '2026-07-18', lines: await lines(9900)),
        soldById: 'sebas',
      );

      expect(result.isRight(), isTrue);
      expect(await syncLocal.pendingCount(), 1);
    });
  });

  group('la venta en el día', () {
    test('aparece en su fecha con cuántos productos llevó', () async {
      final shelf = await local.shelf();
      await addProduct('suavizante', 'Suavizante');
      await addLot(
        'lote-s',
        productId: 'suavizante',
        number: 1,
        available: '4.00',
        price: '18.00',
      );

      await repository.createSale(
        SupplySaleDraft(
          saleDate: '2026-07-18',
          lines: [
            priceLine(
              productId: 'jabon',
              productName: 'Jabón en polvo',
              quantity: 100,
              lots: shelf.single.lots,
            ),
            priceLine(
              productId: 'suavizante',
              productName: 'Suavizante',
              quantity: 100,
              lots: (await local.shelf())
                  .firstWhere((product) => product.id == 'suavizante')
                  .lots,
            ),
          ],
        ),
        soldById: 'sebas',
      );

      final sales = await local.watchSalesByDate('2026-07-18').first;
      expect(sales, hasLength(1));
      // El join repite la venta una vez por línea: sin control contaría cuatro.
      expect(sales.single.itemCount, 2);
      expect(sales.single.total, 2500 + 1800);
      expect(sales.single.pendingSync, isTrue);
      expect(sales.single.customerName, isNull);

      expect(await local.watchSalesByDate('2026-07-19').first, isEmpty);
    });
  });

  group('el espejo de la venta', () {
    test('aplicada, retira las líneas que el servidor nunca conoció', () async {
      // El servidor crea sus propias filas con sus ids; dejar las locales
      // dejaría cada línea dos veces en cuanto el feed las traiga.
      final shelf = await local.shelf();
      final sale = (await repository.createSale(
        SupplySaleDraft(
          saleDate: '2026-07-18',
          lines: [
            priceLine(
              productId: 'jabon',
              productName: 'Jabón en polvo',
              quantity: 200,
              lots: shelf.single.lots,
            ),
          ],
        ),
        soldById: 'sebas',
      )).getRight().toNullable()!;

      await SupplySaleMirror(database).settle(sale.id, rejected: false);

      final items = await database.select(database.supplySaleItemEntries).get();
      expect(items.single.deletedAt, isNotNull);
      final header = await database.select(database.supplySaleEntries).getSingle();
      expect(header.syncStatus, RowSyncStatus.synced.name);
      expect(header.deletedAt, isNull);
    });

    test('rechazada, las líneas se quedan: son lo único que dice qué se capturó', () async {
      final shelf = await local.shelf();
      final sale = (await repository.createSale(
        SupplySaleDraft(
          saleDate: '2026-07-18',
          lines: [
            priceLine(
              productId: 'jabon',
              productName: 'Jabón en polvo',
              quantity: 200,
              lots: shelf.single.lots,
            ),
          ],
        ),
        soldById: 'sebas',
      )).getRight().toNullable()!;

      await SupplySaleMirror(database).settle(sale.id, rejected: true);

      final items = await database.select(database.supplySaleItemEntries).get();
      expect(items.single.deletedAt, isNull);
      expect(items.single.syncStatus, RowSyncStatus.rejected.name);
    });

    test('descartada desde la cola de revisión, se lleva sus líneas', () async {
      final shelf = await local.shelf();
      final sale = (await repository.createSale(
        SupplySaleDraft(
          saleDate: '2026-07-18',
          lines: [
            priceLine(
              productId: 'jabon',
              productName: 'Jabón en polvo',
              quantity: 200,
              lots: shelf.single.lots,
            ),
          ],
        ),
        soldById: 'sebas',
      )).getRight().toNullable()!;

      await SupplySaleMirror(database).settle(sale.id, rejected: true);
      await SupplySaleMirror(database).discard(sale.id);

      final header = await database.select(database.supplySaleEntries).getSingle();
      expect(header.deletedAt, isNotNull);
      // Y el stock que la venta se había llevado vuelve a estar disponible.
      expect((await local.shelf()).single.available, 1500);
    });
  });
}
