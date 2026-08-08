// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shelfHash() => r'd53f6353915be7da419013ab1dea4fda19ac706e';

/// Lo que hay para vender, en vivo desde la BD local.
///
/// Se rehace solo cuando cambia un producto, un lote o una línea de venta: una
/// venta capturada sin señal baja el stock de la pantalla en el acto, aunque el
/// servidor todavía no sepa nada de ella.
///
/// Copied from [shelf].
@ProviderFor(shelf)
final shelfProvider = AutoDisposeStreamProvider<List<ProductShelf>>.internal(
  shelf,
  name: r'shelfProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shelfHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShelfRef = AutoDisposeStreamProviderRef<List<ProductShelf>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
