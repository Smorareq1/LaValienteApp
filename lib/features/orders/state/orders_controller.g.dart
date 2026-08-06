// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersForDayHash() => r'7311ce475ec831d22e5ccd9f5cae68ea4bc87888';

/// Los pedidos del día elegido, tal como están en la BD local.
///
/// Copied from [ordersForDay].
@ProviderFor(ordersForDay)
final ordersForDayProvider =
    AutoDisposeStreamProvider<List<OrderListItem>>.internal(
      ordersForDay,
      name: r'ordersForDayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersForDayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersForDayRef = AutoDisposeStreamProviderRef<List<OrderListItem>>;
String _$filteredOrdersHash() => r'20a78ed2c09fda4bd530faab4a2a9f02130ea28c';

/// Los del día, ya pasados por los filtros de estado y búsqueda.
///
/// El filtrado va en Dart y no en SQL a propósito: son los pedidos de **un**
/// día, ya están en memoria, y hacerlo aquí deja que la búsqueda cubra a la vez
/// el nombre del cliente, el correlativo y la serie de la boleta sin tres
/// consultas ni un índice más.
///
/// Copied from [filteredOrders].
@ProviderFor(filteredOrders)
final filteredOrdersProvider =
    AutoDisposeProvider<List<OrderListItem>>.internal(
      filteredOrders,
      name: r'filteredOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredOrdersRef = AutoDisposeProviderRef<List<OrderListItem>>;
String _$listedTotalHash() => r'1a05505806145f24ddea2796609a3bd1ae62ba74';

/// Cuánto suman los pedidos listados. Es la semilla visual del cierre del día:
/// los anulados no cuentan, porque ese dinero nunca entró.
///
/// Copied from [listedTotal].
@ProviderFor(listedTotal)
final listedTotalProvider = AutoDisposeProvider<int>.internal(
  listedTotal,
  name: r'listedTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$listedTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListedTotalRef = AutoDisposeProviderRef<int>;
String _$orderDetailHash() => r'a46a8361d922536b4e3487b8c8dc40dbc8dbdd4a';

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

/// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
/// que nadie tenga que refrescar.
///
/// Copied from [orderDetail].
@ProviderFor(orderDetail)
const orderDetailProvider = OrderDetailFamily();

/// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
/// que nadie tenga que refrescar.
///
/// Copied from [orderDetail].
class OrderDetailFamily extends Family<AsyncValue<OrderDetail?>> {
  /// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
  /// que nadie tenga que refrescar.
  ///
  /// Copied from [orderDetail].
  const OrderDetailFamily();

  /// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
  /// que nadie tenga que refrescar.
  ///
  /// Copied from [orderDetail].
  OrderDetailProvider call(String orderId) {
    return OrderDetailProvider(orderId);
  }

  @override
  OrderDetailProvider getProviderOverride(
    covariant OrderDetailProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderDetailProvider';
}

/// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
/// que nadie tenga que refrescar.
///
/// Copied from [orderDetail].
class OrderDetailProvider extends AutoDisposeStreamProvider<OrderDetail?> {
  /// El detalle de un pedido, en vivo: cobrar o entregar redibuja la pantalla sin
  /// que nadie tenga que refrescar.
  ///
  /// Copied from [orderDetail].
  OrderDetailProvider(String orderId)
    : this._internal(
        (ref) => orderDetail(ref as OrderDetailRef, orderId),
        from: orderDetailProvider,
        name: r'orderDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderDetailHash,
        dependencies: OrderDetailFamily._dependencies,
        allTransitiveDependencies: OrderDetailFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  Override overrideWith(
    Stream<OrderDetail?> Function(OrderDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailProvider._internal(
        (ref) => create(ref as OrderDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<OrderDetail?> createElement() {
    return _OrderDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderDetailRef on AutoDisposeStreamProviderRef<OrderDetail?> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailProviderElement
    extends AutoDisposeStreamProviderElement<OrderDetail?>
    with OrderDetailRef {
  _OrderDetailProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailProvider).orderId;
}

String _$orderDateFilterHash() => r'4d5b5f7828b32fdcaaa8225b404ed9647ba528fc';

/// El día que se está mirando. Por omisión, el de negocio (plan 0001 D8) y no
/// el del reloj: un pedido tomado a las 19:00 en Cobán pertenece a hoy, aunque
/// en UTC ya sea mañana.
///
/// Copied from [OrderDateFilter].
@ProviderFor(OrderDateFilter)
final orderDateFilterProvider =
    AutoDisposeNotifierProvider<OrderDateFilter, DateTime>.internal(
      OrderDateFilter.new,
      name: r'orderDateFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderDateFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderDateFilter = AutoDisposeNotifier<DateTime>;
String _$orderStatusFilterHash() => r'ae9a306d3408dfb184b49b1337f3b99495bcb22e';

/// Estado por el que se filtra, o `null` para "Todos".
///
/// Copied from [OrderStatusFilter].
@ProviderFor(OrderStatusFilter)
final orderStatusFilterProvider =
    AutoDisposeNotifierProvider<OrderStatusFilter, OrderStatus?>.internal(
      OrderStatusFilter.new,
      name: r'orderStatusFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderStatusFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderStatusFilter = AutoDisposeNotifier<OrderStatus?>;
String _$orderSearchQueryHash() => r'32984708df1b179bc73997c6134fee9d9674bbf7';

/// See also [OrderSearchQuery].
@ProviderFor(OrderSearchQuery)
final orderSearchQueryProvider =
    AutoDisposeNotifierProvider<OrderSearchQuery, String>.internal(
      OrderSearchQuery.new,
      name: r'orderSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
