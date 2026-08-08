import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
