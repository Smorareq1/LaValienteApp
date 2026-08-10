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
String _$inventoryProductsHash() => r'be4cc610e43d84c76558715958f4c113bc5e461a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
/// la pantalla se arma igual sin señal.
///
/// Copied from [inventoryProducts].
@ProviderFor(inventoryProducts)
const inventoryProductsProvider = InventoryProductsFamily();

/// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
/// la pantalla se arma igual sin señal.
///
/// Copied from [inventoryProducts].
class InventoryProductsFamily extends Family<AsyncValue<List<ProductSummary>>> {
  /// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
  /// la pantalla se arma igual sin señal.
  ///
  /// Copied from [inventoryProducts].
  const InventoryProductsFamily();

  /// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
  /// la pantalla se arma igual sin señal.
  ///
  /// Copied from [inventoryProducts].
  InventoryProductsProvider call({bool includeArchived = false}) {
    return InventoryProductsProvider(includeArchived: includeArchived);
  }

  @override
  InventoryProductsProvider getProviderOverride(
    covariant InventoryProductsProvider provider,
  ) {
    return call(includeArchived: provider.includeArchived);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inventoryProductsProvider';
}

/// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
/// la pantalla se arma igual sin señal.
///
/// Copied from [inventoryProducts].
class InventoryProductsProvider
    extends AutoDisposeStreamProvider<List<ProductSummary>> {
  /// Los productos del inventario (§8.1). Lectura desde el espejo local, así que
  /// la pantalla se arma igual sin señal.
  ///
  /// Copied from [inventoryProducts].
  InventoryProductsProvider({bool includeArchived = false})
    : this._internal(
        (ref) => inventoryProducts(
          ref as InventoryProductsRef,
          includeArchived: includeArchived,
        ),
        from: inventoryProductsProvider,
        name: r'inventoryProductsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$inventoryProductsHash,
        dependencies: InventoryProductsFamily._dependencies,
        allTransitiveDependencies:
            InventoryProductsFamily._allTransitiveDependencies,
        includeArchived: includeArchived,
      );

  InventoryProductsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.includeArchived,
  }) : super.internal();

  final bool includeArchived;

  @override
  Override overrideWith(
    Stream<List<ProductSummary>> Function(InventoryProductsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InventoryProductsProvider._internal(
        (ref) => create(ref as InventoryProductsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        includeArchived: includeArchived,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ProductSummary>> createElement() {
    return _InventoryProductsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InventoryProductsProvider &&
        other.includeArchived == includeArchived;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, includeArchived.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InventoryProductsRef
    on AutoDisposeStreamProviderRef<List<ProductSummary>> {
  /// The parameter `includeArchived` of this provider.
  bool get includeArchived;
}

class _InventoryProductsProviderElement
    extends AutoDisposeStreamProviderElement<List<ProductSummary>>
    with InventoryProductsRef {
  _InventoryProductsProviderElement(super.provider);

  @override
  bool get includeArchived =>
      (origin as InventoryProductsProvider).includeArchived;
}

String _$productDetailHash() => r'dd640fd3f37b7a145c05dc95ee04314addbb41b9';

/// Un producto con sus lotes y su kardex (§8.2).
///
/// Copied from [productDetail].
@ProviderFor(productDetail)
const productDetailProvider = ProductDetailFamily();

/// Un producto con sus lotes y su kardex (§8.2).
///
/// Copied from [productDetail].
class ProductDetailFamily extends Family<AsyncValue<ProductDetail?>> {
  /// Un producto con sus lotes y su kardex (§8.2).
  ///
  /// Copied from [productDetail].
  const ProductDetailFamily();

  /// Un producto con sus lotes y su kardex (§8.2).
  ///
  /// Copied from [productDetail].
  ProductDetailProvider call(String productId) {
    return ProductDetailProvider(productId);
  }

  @override
  ProductDetailProvider getProviderOverride(
    covariant ProductDetailProvider provider,
  ) {
    return call(provider.productId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'productDetailProvider';
}

/// Un producto con sus lotes y su kardex (§8.2).
///
/// Copied from [productDetail].
class ProductDetailProvider extends AutoDisposeStreamProvider<ProductDetail?> {
  /// Un producto con sus lotes y su kardex (§8.2).
  ///
  /// Copied from [productDetail].
  ProductDetailProvider(String productId)
    : this._internal(
        (ref) => productDetail(ref as ProductDetailRef, productId),
        from: productDetailProvider,
        name: r'productDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$productDetailHash,
        dependencies: ProductDetailFamily._dependencies,
        allTransitiveDependencies:
            ProductDetailFamily._allTransitiveDependencies,
        productId: productId,
      );

  ProductDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.productId,
  }) : super.internal();

  final String productId;

  @override
  Override overrideWith(
    Stream<ProductDetail?> Function(ProductDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProductDetailProvider._internal(
        (ref) => create(ref as ProductDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        productId: productId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ProductDetail?> createElement() {
    return _ProductDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.productId == productId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, productId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProductDetailRef on AutoDisposeStreamProviderRef<ProductDetail?> {
  /// The parameter `productId` of this provider.
  String get productId;
}

class _ProductDetailProviderElement
    extends AutoDisposeStreamProviderElement<ProductDetail?>
    with ProductDetailRef {
  _ProductDetailProviderElement(super.provider);

  @override
  String get productId => (origin as ProductDetailProvider).productId;
}

String _$inventorySearchHash() => r'f25a952b093b038ba59310ade525179e6f4a14ec';

/// Lo que se escribió en el buscador de Insumos.
///
/// Copied from [InventorySearch].
@ProviderFor(InventorySearch)
final inventorySearchProvider =
    AutoDisposeNotifierProvider<InventorySearch, String>.internal(
      InventorySearch.new,
      name: r'inventorySearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventorySearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InventorySearch = AutoDisposeNotifier<String>;
String _$inventoryShowArchivedHash() =>
    r'9d9dd1f0805249479d1beae58f80c0d72a9d2f6a';

/// Si se están mostrando también los productos archivados. Solo tiene sentido
/// con `inventory.manage`: quien no administra no los ve nunca.
///
/// Copied from [InventoryShowArchived].
@ProviderFor(InventoryShowArchived)
final inventoryShowArchivedProvider =
    AutoDisposeNotifierProvider<InventoryShowArchived, bool>.internal(
      InventoryShowArchived.new,
      name: r'inventoryShowArchivedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryShowArchivedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InventoryShowArchived = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
