import 'package:design_system/design_system.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/inventory/ui/inventory_screen.dart';
import 'package:la_valiente/features/inventory/ui/product_detail_screen.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

void main() {
  late AppDatabase database;
  var closed = false;

  void inventoryTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await database.close();
      closed = true;
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    closed = false;
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    if (!closed) await database.close();
  });

  Future<void> seedProduct({
    String id = 'prod-1',
    String name = 'Jabón en polvo',
    String unit = 'bolsa',
    bool isActive = true,
  }) {
    return database
        .into(database.productEntries)
        .insert(
          ProductEntriesCompanion.insert(
            id: id,
            name: name,
            unit: unit,
            isActive: Value(isActive),
          ),
        );
  }

  Future<void> seedLot({
    String id = 'lote-1',
    String productId = 'prod-1',
    int number = 1,
    String available = '5.00',
    String? price = '25.00',
    String receivedAt = '2026-07-01',
  }) {
    return database
        .into(database.productLotEntries)
        .insert(
          ProductLotEntriesCompanion.insert(
            id: id,
            productId: productId,
            lotNumber: number,
            quantityReceived: '12.00',
            quantityAvailable: available,
            salePrice: Value(price),
            receivedAt: receivedAt,
          ),
        );
  }

  Future<void> open(
    WidgetTester tester,
    Widget screen, {
    List<String> permissions = const [AppPermissions.all],
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          authControllerProvider.overrideWith(
            () => _FakeAuthController(
              AuthUser(
                id: 'u1',
                username: 'mostrador',
                fullName: 'Marta González',
                roles: const ['admin'],
                permissions: permissions,
              ),
            ),
          ),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('la cuadrícula', () {
    inventoryTest('sin productos lo dice', (tester) async {
      await open(tester, const InventoryScreen());
      expect(find.text('Todavía no hay insumos'), findsOneWidget);
    });

    inventoryTest('muestra el stock y el precio de la siguiente unidad', (tester) async {
      await seedProduct();
      await seedLot();
      await open(tester, const InventoryScreen());

      expect(find.text('Jabón en polvo'), findsOneWidget);
      expect(find.textContaining('5 bolsas en existencia'), findsOneWidget);
      expect(find.text('Q25.00 el bolsa'), findsOneWidget);
    });

    inventoryTest('un producto agotado lo dice con palabras, no con un cero', (
      tester,
    ) async {
      await seedProduct();
      await seedLot(available: '0.00');
      await open(tester, const InventoryScreen());

      expect(find.text('Sin existencias'), findsOneWidget);
    });

    inventoryTest('el stock incluye los lotes de la casa, que no se venden', (
      tester,
    ) async {
      // Un lote sin precio es consumo interno: el mostrador no lo ofrece, pero
      // el inventario sí lo tiene. Es la diferencia entre esta pantalla y la
      // estantería de la venta de insumo.
      await seedProduct();
      await seedLot(price: null);
      await open(tester, const InventoryScreen());

      expect(find.textContaining('5 bolsas en existencia'), findsOneWidget);
      expect(find.text('Uso interno'), findsOneWidget);
    });

    inventoryTest('sin permiso de administrar no aparecen los archivados', (
      tester,
    ) async {
      await seedProduct();
      await open(
        tester,
        const InventoryScreen(),
        permissions: const [AppPermissions.inventoryRead],
      );

      expect(find.text('Archivados'), findsNothing);
    });
  });

  group('el detalle', () {
    inventoryTest('lista los lotes y muestra el costo como desconocido', (
      tester,
    ) async {
      // `unit_cost` no viaja en el feed a propósito: el margen de compra no se
      // lee en el mostrador, así que la fila del lote lo dice con un guion.
      await seedProduct();
      await seedLot(number: 3);
      await open(tester, const ProductDetailScreen(productId: 'prod-1'));

      expect(find.text('Lote 3'), findsOneWidget);
      expect(find.textContaining('5 de 12 bolsa'), findsOneWidget);
      expect(find.text('costo —'), findsOneWidget);
    });

    inventoryTest('un lote sin precio se marca como uso interno', (tester) async {
      await seedProduct();
      await seedLot(price: null);
      await open(tester, const ProductDetailScreen(productId: 'prod-1'));

      // Se busca la insignia del lote y no el texto suelto: «Uso interno» es
      // también uno de los filtros del kardex, y ese está siempre.
      expect(
        find.descendant(
          of: find.byType(AppStatusBadge),
          matching: find.text('Uso interno'),
        ),
        findsOneWidget,
      );
    });

    inventoryTest('sin movimientos lo dice en vez de dejar el hueco', (tester) async {
      await seedProduct();
      await seedLot();
      await open(tester, const ProductDetailScreen(productId: 'prod-1'));

      expect(find.textContaining('Todavía no hay movimientos'), findsOneWidget);
    });

    inventoryTest('el kardex pone el signo, para leerse como un saldo', (tester) async {
      await seedProduct();
      await seedLot();
      await database
          .into(database.inventoryMovementEntries)
          .insert(
            InventoryMovementEntriesCompanion.insert(
              id: 'mov-1',
              lotId: 'lote-1',
              movementType: 'sale_out',
              quantity: '2.00',
              createdById: 'u1',
              createdAt: Value(DateTime.utc(2026, 7, 18, 16, 30)),
            ),
          );
      await open(tester, const ProductDetailScreen(productId: 'prod-1'));

      expect(find.text('Venta · lote 1'), findsOneWidget);
      expect(find.text('−2'), findsOneWidget);
    });

    inventoryTest('un producto que ya no está lo explica', (tester) async {
      await open(tester, const ProductDetailScreen(productId: 'no-existe'));
      expect(find.text('Este producto ya no está'), findsOneWidget);
    });
  });
}
