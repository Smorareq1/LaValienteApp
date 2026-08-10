import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/inventory_local_datasource.dart';
import '../data/inventory_repository.dart';
import '../models/product.dart';

part 'shelf_controller.g.dart';

/// Lo que hay para vender, en vivo desde la BD local.
///
/// Se rehace solo cuando cambia un producto, un lote o una línea de venta: una
/// venta capturada sin señal baja el stock de la pantalla en el acto, aunque el
/// servidor todavía no sepa nada de ella.
@riverpod
Stream<List<ProductShelf>> shelf(Ref ref) {
  return ref.watch(inventoryRepositoryProvider).watchShelf();
}

/// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
/// la pantalla se arma igual sin señal.
@riverpod
Stream<List<ProductSummary>> inventoryProducts(Ref ref, {bool includeArchived = false}) {
  return ref
      .watch(inventoryLocalDataSourceProvider)
      .watchProducts(includeArchived: includeArchived);
}

/// Un producto con sus lotes y su kardex (§8.2).
@riverpod
Stream<ProductDetail?> productDetail(Ref ref, String productId) {
  return ref.watch(inventoryLocalDataSourceProvider).watchDetail(productId);
}

/// Lo que se escribió en el buscador de Insumos.
@riverpod
class InventorySearch extends _$InventorySearch {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Si se están mostrando también los productos archivados. Solo tiene sentido
/// con `inventory.manage`: quien no administra no los ve nunca.
@riverpod
class InventoryShowArchived extends _$InventoryShowArchived {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
