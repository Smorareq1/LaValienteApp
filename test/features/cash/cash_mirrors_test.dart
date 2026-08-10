import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/features/cash/data/cash_mirrors.dart';
import 'package:la_valiente/features/inventory/data/inventory_mirrors.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';

/// Los cambios se arman con **exactamente** las claves que declara
/// `FEED_ENTITIES` en `BACKEND/src/modules/sync/registry.py`.
///
/// Es lo que estas pruebas comprueban: que el espejo lea los nombres que el
/// servidor manda. Un `salePrice` leído de `price` no falla al compilar ni al
/// analizar — falla en el primer pull, contra la base cifrada de un teléfono, y
/// se ve como una tabla que nunca se llena.
SyncChange change(String entity, String id, Map<String, dynamic> data) => SyncChange(
  entity: entity,
  id: id,
  version: 1,
  syncSeq: 1,
  deleted: false,
  data: {'id': id, 'version': 1, ...data},
);

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('la categoría de gasto baja entera', () async {
    await ExpenseCategoryMirror(database).apply(
      change('expense_category', 'cat-1', {
        'name': 'Compra de insumos',
        'is_active': true,
        'sort_order': 2,
      }),
    );

    final row = await database.select(database.expenseCategoryEntries).getSingle();
    expect(row.name, 'Compra de insumos');
    expect(row.sortOrder, 2);
    expect(row.isActive, isTrue);
  });

  test('el gasto baja con sus tres vínculos y su motivo de anulación', () async {
    await ExpenseMirror(database).apply(
      change('expense', 'gasto-1', {
        'expense_date': '2026-07-18',
        'category_id': 'cat-1',
        'concept': 'Gas — 2 sacos',
        'amount': '161.00',
        'method': 'cash',
        'status': 'paid',
        'employee_id': 'emp-1',
        'attendance_record_id': 'jornada-1',
        'product_lot_id': null,
        'observations': 'Factura 3341',
        'created_by_id': 'u1',
        'void_reason': null,
      }),
    );

    final row = await database.select(database.expenseEntries).getSingle();
    expect(row.amount, '161.00');
    expect(row.employeeId, 'emp-1');
    expect(row.attendanceRecordId, 'jornada-1');
    expect(row.productLotId, isNull);
    expect(row.observations, 'Factura 3341');
  });

  test('el acta del cierre baja con sus diez cifras', () async {
    await DailyClosureMirror(database).apply(
      change('daily_closure', 'acta-1', {
        'close_date': '2026-07-18',
        'orders_income': '950.00',
        'supplies_income': '45.00',
        'expenses_total': '231.00',
        'net_total': '764.00',
        'cash_income': '845.00',
        'transfer_income': '150.00',
        'cash_expenses': '161.00',
        'transfer_expenses': '70.00',
        'orders_delivered': 12,
        'notes': null,
        'closed_by_id': 'u1',
        'closed_at': '2026-07-19T01:12:00+00:00',
        'reopened_by_id': null,
        'reopen_reason': null,
      }),
    );

    final row = await database.select(database.dailyClosureEntries).getSingle();
    expect(row.netTotal, '764.00');
    expect(row.ordersDelivered, 12);
    // Drift devuelve los `DateTime` en hora local aunque se guarden en UTC.
    expect(row.closedAt.toUtc(), DateTime.utc(2026, 7, 19, 1, 12));
    expect(row.reopenedById, isNull);
  });

  test('el producto y el lote bajan; el costo unitario no viaja', () async {
    await ProductMirror(database).apply(
      change('product', 'prod-1', {
        'name': 'Jabón en polvo',
        'unit': 'bolsa',
        'description': null,
        'image_path': 'products/prod-1.jpg',
        'is_active': true,
        'sort_order': 0,
      }),
    );
    await ProductLotMirror(database).apply(
      change('product_lot', 'lote-1', {
        'product_id': 'prod-1',
        'lot_number': 3,
        'quantity_received': '12.00',
        'quantity_available': '5.00',
        'sale_price': '25.00',
        'received_at': '2026-07-01',
      }),
    );

    final product = await database.select(database.productEntries).getSingle();
    expect(product.imagePath, 'products/prod-1.jpg');

    final lot = await database.select(database.productLotEntries).getSingle();
    expect(lot.lotNumber, 3);
    expect(lot.quantityAvailable, '5.00');
    expect(lot.salePrice, '25.00');
    // `unit_cost` no está en el feed a propósito: el margen de compra no se lee
    // en el mostrador. Si algún día apareciera, el espejo lo seguiría ignorando.
  });

  test('una venta del servidor baja con su lote y sin producto', () async {
    await SupplySaleMirror(database).apply(
      change('supply_sale', 'venta-1', {
        'sale_date': '2026-07-18',
        'customer_id': null,
        'nit': 'CF',
        'method': 'cash',
        'reference': null,
        'total': '45.00',
        'sold_by_id': 'u1',
        'cancelled_at': null,
        'cancelled_by_id': null,
        'cancel_reason': null,
        'created_at': '2026-07-18T16:30:00+00:00',
      }),
    );
    await SupplySaleItemMirror(database).apply(
      change('supply_sale_item', 'linea-1', {
        'sale_id': 'venta-1',
        'lot_id': 'lote-1',
        'description': 'Jabón en polvo',
        'quantity': '2.00',
        'unit_price': '22.50',
        'amount': '45.00',
      }),
    );

    final sale = await database.select(database.supplySaleEntries).getSingle();
    expect(sale.total, '45.00');
    expect(sale.createdAt!.toUtc(), DateTime.utc(2026, 7, 18, 16, 30));

    final item = await database.select(database.supplySaleItemEntries).getSingle();
    expect(item.lotId, 'lote-1');
    // `productId` es columna local: la fila del servidor nombra el lote, y el
    // producto se resuelve por él.
    expect(item.productId, isNull);
  });

  test('un cambio borrado deja lápida, no borra la fila', () async {
    final mirror = ExpenseMirror(database);
    const data = {
      'expense_date': '2026-07-18',
      'category_id': 'cat-1',
      'concept': 'Gas',
      'amount': '161.00',
      'method': 'cash',
      'status': 'paid',
      'employee_id': null,
      'attendance_record_id': null,
      'product_lot_id': null,
      'observations': null,
      'created_by_id': 'u1',
      'void_reason': null,
    };

    await mirror.apply(change('expense', 'gasto-1', data));
    await mirror.apply(
      SyncChange(
        entity: 'expense',
        id: 'gasto-1',
        version: 2,
        syncSeq: 2,
        deleted: true,
        data: {'id': 'gasto-1', 'version': 2, ...data, 'void_reason': 'Se anotó dos veces'},
      ),
    );

    final row = await database.select(database.expenseEntries).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(row.voidReason, 'Se anotó dos veces');
  });
}
