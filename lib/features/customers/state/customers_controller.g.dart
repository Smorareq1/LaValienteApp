// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerSearchResultsHash() =>
    r'0793ffbb2d7d1a8d4c7267afb442a8fa7b28e8df';

/// Clientes que coinciden con la búsqueda actual, en vivo desde la BD local.
///
/// Copied from [customerSearchResults].
@ProviderFor(customerSearchResults)
final customerSearchResultsProvider =
    AutoDisposeStreamProvider<List<Customer>>.internal(
      customerSearchResults,
      name: r'customerSearchResultsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerSearchResultsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerSearchResultsRef = AutoDisposeStreamProviderRef<List<Customer>>;
String _$customerCountHash() => r'3faff4a9718a43985314dd0795fea25f3e175ae4';

/// Total de clientes activos, para la cabecera.
///
/// Copied from [customerCount].
@ProviderFor(customerCount)
final customerCountProvider = AutoDisposeStreamProvider<int>.internal(
  customerCount,
  name: r'customerCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerCountRef = AutoDisposeStreamProviderRef<int>;
String _$customerByIdHash() => r'8b710ac29f659264d7b7b742d95402db7cbb1aba';

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

/// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
///
/// Copied from [customerById].
@ProviderFor(customerById)
const customerByIdProvider = CustomerByIdFamily();

/// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
///
/// Copied from [customerById].
class CustomerByIdFamily extends Family<AsyncValue<Customer?>> {
  /// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
  ///
  /// Copied from [customerById].
  const CustomerByIdFamily();

  /// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
  ///
  /// Copied from [customerById].
  CustomerByIdProvider call(String id) {
    return CustomerByIdProvider(id);
  }

  @override
  CustomerByIdProvider getProviderOverride(
    covariant CustomerByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerByIdProvider';
}

/// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
///
/// Copied from [customerById].
class CustomerByIdProvider extends AutoDisposeStreamProvider<Customer?> {
  /// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
  ///
  /// Copied from [customerById].
  CustomerByIdProvider(String id)
    : this._internal(
        (ref) => customerById(ref as CustomerByIdRef, id),
        from: customerByIdProvider,
        name: r'customerByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerByIdHash,
        dependencies: CustomerByIdFamily._dependencies,
        allTransitiveDependencies:
            CustomerByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<Customer?> Function(CustomerByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerByIdProvider._internal(
        (ref) => create(ref as CustomerByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Customer?> createElement() {
    return _CustomerByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerByIdRef on AutoDisposeStreamProviderRef<Customer?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerByIdProviderElement
    extends AutoDisposeStreamProviderElement<Customer?>
    with CustomerByIdRef {
  _CustomerByIdProviderElement(super.provider);

  @override
  String get id => (origin as CustomerByIdProvider).id;
}

String _$customerSearchQueryHash() =>
    r'ccb0b1be794b935a44f28b5028f7cc1b354f8756';

/// Lo que hay escrito en el buscador de la lista de clientes.
///
/// Vive fuera de la pantalla para que volver de un detalle no borre lo que la
/// persona buscó: la rama del shell conserva la pantalla, pero el estado del
/// filtro es de la sesión de trabajo, no del widget.
///
/// Copied from [CustomerSearchQuery].
@ProviderFor(CustomerSearchQuery)
final customerSearchQueryProvider =
    AutoDisposeNotifierProvider<CustomerSearchQuery, String>.internal(
      CustomerSearchQuery.new,
      name: r'customerSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomerSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
