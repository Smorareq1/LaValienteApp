// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_capture_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderCaptureControllerHash() =>
    r'769463013cd3e4af4c74a07962a91694dc4b5f21';

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

abstract class _$OrderCaptureController
    extends BuildlessAutoDisposeAsyncNotifier<OrderCaptureState> {
  late final String? orderId;

  FutureOr<OrderCaptureState> build(String? orderId);
}

/// El estado de la toma de pedido (plan 0002).
///
/// Todo el cálculo vive del lado del dispositivo mientras se captura: la
/// pantalla tiene que responder con o sin señal, y el total del footer se
/// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
/// aplica la operación (D5).
///
/// Copied from [OrderCaptureController].
@ProviderFor(OrderCaptureController)
const orderCaptureControllerProvider = OrderCaptureControllerFamily();

/// El estado de la toma de pedido (plan 0002).
///
/// Todo el cálculo vive del lado del dispositivo mientras se captura: la
/// pantalla tiene que responder con o sin señal, y el total del footer se
/// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
/// aplica la operación (D5).
///
/// Copied from [OrderCaptureController].
class OrderCaptureControllerFamily
    extends Family<AsyncValue<OrderCaptureState>> {
  /// El estado de la toma de pedido (plan 0002).
  ///
  /// Todo el cálculo vive del lado del dispositivo mientras se captura: la
  /// pantalla tiene que responder con o sin señal, y el total del footer se
  /// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
  /// aplica la operación (D5).
  ///
  /// Copied from [OrderCaptureController].
  const OrderCaptureControllerFamily();

  /// El estado de la toma de pedido (plan 0002).
  ///
  /// Todo el cálculo vive del lado del dispositivo mientras se captura: la
  /// pantalla tiene que responder con o sin señal, y el total del footer se
  /// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
  /// aplica la operación (D5).
  ///
  /// Copied from [OrderCaptureController].
  OrderCaptureControllerProvider call(String? orderId) {
    return OrderCaptureControllerProvider(orderId);
  }

  @override
  OrderCaptureControllerProvider getProviderOverride(
    covariant OrderCaptureControllerProvider provider,
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
  String? get name => r'orderCaptureControllerProvider';
}

/// El estado de la toma de pedido (plan 0002).
///
/// Todo el cálculo vive del lado del dispositivo mientras se captura: la
/// pantalla tiene que responder con o sin señal, y el total del footer se
/// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
/// aplica la operación (D5).
///
/// Copied from [OrderCaptureController].
class OrderCaptureControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          OrderCaptureController,
          OrderCaptureState
        > {
  /// El estado de la toma de pedido (plan 0002).
  ///
  /// Todo el cálculo vive del lado del dispositivo mientras se captura: la
  /// pantalla tiene que responder con o sin señal, y el total del footer se
  /// recalcula con cada tecla. La cifra oficial llega después, cuando el servidor
  /// aplica la operación (D5).
  ///
  /// Copied from [OrderCaptureController].
  OrderCaptureControllerProvider(String? orderId)
    : this._internal(
        () => OrderCaptureController()..orderId = orderId,
        from: orderCaptureControllerProvider,
        name: r'orderCaptureControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderCaptureControllerHash,
        dependencies: OrderCaptureControllerFamily._dependencies,
        allTransitiveDependencies:
            OrderCaptureControllerFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderCaptureControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String? orderId;

  @override
  FutureOr<OrderCaptureState> runNotifierBuild(
    covariant OrderCaptureController notifier,
  ) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderCaptureController Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderCaptureControllerProvider._internal(
        () => create()..orderId = orderId,
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
  AutoDisposeAsyncNotifierProviderElement<
    OrderCaptureController,
    OrderCaptureState
  >
  createElement() {
    return _OrderCaptureControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderCaptureControllerProvider && other.orderId == orderId;
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
mixin OrderCaptureControllerRef
    on AutoDisposeAsyncNotifierProviderRef<OrderCaptureState> {
  /// The parameter `orderId` of this provider.
  String? get orderId;
}

class _OrderCaptureControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          OrderCaptureController,
          OrderCaptureState
        >
    with OrderCaptureControllerRef {
  _OrderCaptureControllerProviderElement(super.provider);

  @override
  String? get orderId => (origin as OrderCaptureControllerProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
