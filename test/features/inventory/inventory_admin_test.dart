import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/inventory/data/inventory_remote_datasource.dart';
import 'package:la_valiente/features/inventory/models/product.dart';
import 'package:la_valiente/features/inventory/ui/widgets/lot_form_sheet.dart';
import 'package:la_valiente/features/inventory/ui/widgets/movement_form_sheet.dart';
import 'package:la_valiente/features/inventory/ui/widgets/product_form_sheet.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';

/// El servidor de inventario, de mentira. Los tres sheets del §8.3–§8.5 van en
/// línea, así que lo que hay que fingir es la red.
class _FakeRemote implements InventoryRemoteDataSource {
  final List<LotInput> lots = [];
  final List<MovementInput> movements = [];

  @override
  Future<ProductLot> registerLot(String productId, LotInput input) async {
    lots.add(input);
    return ProductLot(
      id: 'lote-nuevo',
      lotNumber: 7,
      quantityReceived: input.quantityReceived,
      quantityAvailable: input.quantityReceived,
      receivedAt: input.receivedAt,
      version: 1,
      salePrice: input.salePrice,
    );
  }

  @override
  Future<void> recordMovement(MovementInput input) async => movements.add(input);

  @override
  Future<ProductSummary> createProduct(ProductInput input) async =>
      throw UnimplementedError();

  @override
  Future<ProductSummary> updateProduct(String id, ProductInput input) async =>
      throw UnimplementedError();

  @override
  Future<ProductSummary> setImage(String id, Uint8List bytes) async =>
      throw UnimplementedError();
}

const _product = ProductSummary(
  id: 'prod-1',
  name: 'Jabón en polvo',
  unit: 'bolsa',
  isActive: true,
  stock: 500,
  sellableStock: 500,
  version: 1,
);

const _lot = ProductLot(
  id: 'lote-1',
  lotNumber: 1,
  quantityReceived: 1200,
  quantityAvailable: 500,
  receivedAt: '2026-07-01',
  version: 1,
  salePrice: 2500,
);

/// El motor de sincronización, quieto y contando.
///
/// Guardar en línea pide un ciclo para que el espejo local vea lo que se acaba
/// de crear —sin él la pantalla de atrás sigue sin el producto hasta que alguien
/// sincroniza a mano—. Aquí no hay ni base de datos ni servidor detrás del
/// motor, así que se finge; lo que sí importa es que se le pida.
class _IdleSyncEngine extends SyncEngine {
  static int cycles = 0;

  @override
  SyncEngineState build() => const SyncEngineState();

  @override
  Future<void> sync({String reason = 'a mano'}) async => cycles++;
}

Future<void> _open(WidgetTester tester, _FakeRemote remote, Widget sheet) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _IdleSyncEngine.cycles = 0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryRemoteDataSourceProvider.overrideWithValue(remote),
        syncEngineProvider.overrideWith(_IdleSyncEngine.new),
      ],
      child: MaterialApp(home: Scaffold(body: sheet)),
    ),
  );
  await tester.pumpAndSettle();
}

/// Abre la sheet como se abre de verdad —modal, con su alto máximo y su barra de
/// acciones fija— y en una pantalla de teléfono. El scroll solo existe en ese
/// contexto: montada suelta en un `Scaffold` de 1600 de alto no hay nada que
/// desplazar, y por eso este defecto vivió tanto.
Future<void> _openOnPhone(WidgetTester tester, _FakeRemote remote) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _IdleSyncEngine.cycles = 0;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        inventoryRemoteDataSourceProvider.overrideWithValue(remote),
        syncEngineProvider.overrideWith(_IdleSyncEngine.new),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => LotFormSheet.show(context, product: _product),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

void main() {
  group('alta de producto', () {
    testWidgets('sin nombre ni unidad no se crea nada', (tester) async {
      final remote = _FakeRemote();
      await _open(tester, remote, const ProductFormSheet());

      await tester.tap(find.text('Crear producto'));
      await tester.pumpAndSettle();

      expect(find.text('Ponle el nombre con que se pide'), findsOneWidget);
      expect(find.text('¿En qué se mide? Bote, bolsa, galón…'), findsOneWidget);
    });

    testWidgets('las unidades de la hoja se ofrecen como sugerencia', (tester) async {
      // Texto libre igual: la unidad la decide el proveedor y aparece una nueva
      // cada tanto. Las sugerencias solo ahorran teclear las de siempre.
      final remote = _FakeRemote();
      await _open(tester, remote, const ProductFormSheet());

      await tester.tap(find.widgetWithText(AppChip, 'galón'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppTextField, 'galón'), findsOneWidget);
    });
  });

  group('alta de lote', () {
    testWidgets('el total del gasto sale de cantidad × costo', (tester) async {
      final remote = _FakeRemote();
      await _open(tester, remote, const LotFormSheet(product: _product));

      await tester.enterText(find.byType(AppTextField).at(0), '12');
      await tester.enterText(find.byType(AppTextField).at(1), '18.00');
      await tester.pumpAndSettle();

      // 12 × Q18.00 = Q216.00, ya escrito y sin que nadie lo teclee.
      expect(find.widgetWithText(AppTextField, '216.00'), findsOneWidget);
    });

    testWidgets('un total escrito a mano le gana a la cuenta', (tester) async {
      // La factura trae fletes o un redondeo del proveedor: manda la factura.
      final remote = _FakeRemote();
      await _open(tester, remote, const LotFormSheet(product: _product));

      await tester.enterText(find.byType(AppTextField).at(0), '12');
      await tester.enterText(find.byType(AppTextField).at(1), '18.00');
      await tester.pumpAndSettle();

      final total = find.widgetWithText(AppTextField, '216.00');
      await tester.enterText(total, '230.00');
      await tester.pumpAndSettle();

      // Mover el costo ya no arrastra el total.
      await tester.enterText(find.byType(AppTextField).at(1), '19.00');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppTextField, '230.00'), findsOneWidget);
    });

    testWidgets('el lote y su gasto viajan en la misma llamada', (tester) async {
      // La estantería y la caja dejan de cuadrar en cuanto uno se puede
      // escribir sin el otro.
      final remote = _FakeRemote();
      await _open(tester, remote, const LotFormSheet(product: _product));

      await tester.enterText(find.byType(AppTextField).at(0), '12');
      await tester.enterText(find.byType(AppTextField).at(1), '18.00');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar lote'));
      await tester.pumpAndSettle();

      final sent = remote.lots.single;
      expect(sent.quantityReceived, 1200);
      expect(sent.expense!.total, 21600);
      // Y se pide un ciclo: el lote vive arriba y la estantería se lee del
      // espejo local, así que sin esto la compra no aparece hasta que alguien
      // vaya a Sincronizar y vuelva.
      expect(_IdleSyncEngine.cycles, 1);
    });

    testWidgets('sin precio de venta el lote es de la casa', (tester) async {
      final remote = _FakeRemote();
      await _open(tester, remote, const LotFormSheet(product: _product));

      await tester.enterText(find.byType(AppTextField).at(0), '5');
      await tester.enterText(find.byType(AppTextField).at(1), '10.00');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar lote'));
      await tester.pumpAndSettle();

      expect(remote.lots.single.salePrice, isNull);
    });

    testWidgets('apagar el gasto registra solo el stock', (tester) async {
      final remote = _FakeRemote();
      await _open(tester, remote, const LotFormSheet(product: _product));

      await tester.enterText(find.byType(AppTextField).at(0), '3');
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar lote'));
      await tester.pumpAndSettle();

      expect(remote.lots.single.expense, isNull);
    });

    testWidgets('el total de la compra se alcanza arrastrando la sheet', (
      tester,
    ) async {
      // En el mostrador el TOTAL queda bajo el pliegue, y la sheet no rodaba: la
      // lista de adentro se quedaba con el gesto de arrastre sin tener nada que
      // desplazar, así que el campo era inalcanzable y el gasto no se podía
      // corregir.
      final remote = _FakeRemote();
      await _openOnPhone(tester, remote);

      const screen = 640.0;
      final total = find.text('TOTAL DE LA COMPRA');
      expect(
        tester.getTopLeft(total).dy,
        greaterThan(screen),
        reason: 'el total tiene que arrancar fuera de la pantalla',
      );

      await tester.drag(find.text('CANTIDAD RECIBIDA'), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(total).dy, lessThan(screen));
    });

    testWidgets('sin cantidad no se registra nada', (tester) async {
      final remote = _FakeRemote();
      await _open(tester, remote, const LotFormSheet(product: _product));

      await tester.tap(find.text('Registrar lote'));
      await tester.pumpAndSettle();

      expect(find.text('Cuánto llegó, en bolsa'), findsOneWidget);
      expect(remote.lots, isEmpty);
    });
  });

  group('movimiento manual', () {
    testWidgets('solo se ofrecen los dos tipos que se teclean', (tester) async {
      // Una compra sale de registrar un lote y una venta de vender. Dejarlas
      // aquí metería stock sin ningún documento detrás.
      final remote = _FakeRemote();
      await _open(
        tester,
        remote,
        const MovementFormSheet(product: _product, lots: [_lot]),
      );

      expect(find.text('Uso interno'), findsOneWidget);
      expect(find.text('Ajuste'), findsOneWidget);
      expect(find.text('Compra'), findsNothing);
      expect(find.text('Venta'), findsNothing);
    });

    testWidgets('un uso interno sale positivo, con el signo en el tipo', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _open(
        tester,
        remote,
        const MovementFormSheet(product: _product, lots: [_lot]),
      );

      await tester.enterText(find.byType(AppTextField).first, '2');
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      final sent = remote.movements.single;
      expect(sent.type, MovementType.internalUse);
      expect(sent.quantity, 200);
    });

    testWidgets('un ajuste corto sale negativo', (tester) async {
      final remote = _FakeRemote();
      await _open(
        tester,
        remote,
        const MovementFormSheet(product: _product, lots: [_lot]),
      );

      await tester.tap(find.text('Ajuste'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, '1');
      await tester.enterText(find.byType(AppTextField).last, 'Se rompió un bote');
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(remote.movements.single.quantity, -100);
    });

    testWidgets('un ajuste sin explicación no sale', (tester) async {
      // Un número que aparece o desaparece sin motivo es justo lo que la hoja
      // de papel no podía responder.
      final remote = _FakeRemote();
      await _open(
        tester,
        remote,
        const MovementFormSheet(product: _product, lots: [_lot]),
      );

      await tester.tap(find.text('Ajuste'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, '1');
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Sin esto el ajuste no se puede explicar'),
        findsOneWidget,
      );
      expect(remote.movements, isEmpty);
    });

    testWidgets('sin lotes con existencia lo explica', (tester) async {
      final remote = _FakeRemote();
      await _open(
        tester,
        remote,
        const MovementFormSheet(product: _product, lots: []),
      );

      expect(
        find.textContaining('no tiene lotes con existencia'),
        findsOneWidget,
      );
    });
  });
}
