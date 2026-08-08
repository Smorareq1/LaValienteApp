// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminServiceHash() => r'c3318978a35d1264b098f23d61d631528b5127b4';

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

/// Un servicio con su historial de precios (§10.1).
///
/// Copied from [adminService].
@ProviderFor(adminService)
const adminServiceProvider = AdminServiceFamily();

/// Un servicio con su historial de precios (§10.1).
///
/// Copied from [adminService].
class AdminServiceFamily extends Family<AsyncValue<AdminService>> {
  /// Un servicio con su historial de precios (§10.1).
  ///
  /// Copied from [adminService].
  const AdminServiceFamily();

  /// Un servicio con su historial de precios (§10.1).
  ///
  /// Copied from [adminService].
  AdminServiceProvider call(String id) {
    return AdminServiceProvider(id);
  }

  @override
  AdminServiceProvider getProviderOverride(
    covariant AdminServiceProvider provider,
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
  String? get name => r'adminServiceProvider';
}

/// Un servicio con su historial de precios (§10.1).
///
/// Copied from [adminService].
class AdminServiceProvider extends AutoDisposeFutureProvider<AdminService> {
  /// Un servicio con su historial de precios (§10.1).
  ///
  /// Copied from [adminService].
  AdminServiceProvider(String id)
    : this._internal(
        (ref) => adminService(ref as AdminServiceRef, id),
        from: adminServiceProvider,
        name: r'adminServiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminServiceHash,
        dependencies: AdminServiceFamily._dependencies,
        allTransitiveDependencies:
            AdminServiceFamily._allTransitiveDependencies,
        id: id,
      );

  AdminServiceProvider._internal(
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
    FutureOr<AdminService> Function(AdminServiceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminServiceProvider._internal(
        (ref) => create(ref as AdminServiceRef),
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
  AutoDisposeFutureProviderElement<AdminService> createElement() {
    return _AdminServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminServiceProvider && other.id == id;
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
mixin AdminServiceRef on AutoDisposeFutureProviderRef<AdminService> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AdminServiceProviderElement
    extends AutoDisposeFutureProviderElement<AdminService>
    with AdminServiceRef {
  _AdminServiceProviderElement(super.provider);

  @override
  String get id => (origin as AdminServiceProvider).id;
}

String _$servicePricesHash() => r'8f7aa100f26faf9c38ae71831def9acae9d9f3e9';

/// See also [servicePrices].
@ProviderFor(servicePrices)
const servicePricesProvider = ServicePricesFamily();

/// See also [servicePrices].
class ServicePricesFamily extends Family<AsyncValue<List<AdminPrice>>> {
  /// See also [servicePrices].
  const ServicePricesFamily();

  /// See also [servicePrices].
  ServicePricesProvider call(String serviceId) {
    return ServicePricesProvider(serviceId);
  }

  @override
  ServicePricesProvider getProviderOverride(
    covariant ServicePricesProvider provider,
  ) {
    return call(provider.serviceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'servicePricesProvider';
}

/// See also [servicePrices].
class ServicePricesProvider
    extends AutoDisposeFutureProvider<List<AdminPrice>> {
  /// See also [servicePrices].
  ServicePricesProvider(String serviceId)
    : this._internal(
        (ref) => servicePrices(ref as ServicePricesRef, serviceId),
        from: servicePricesProvider,
        name: r'servicePricesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$servicePricesHash,
        dependencies: ServicePricesFamily._dependencies,
        allTransitiveDependencies:
            ServicePricesFamily._allTransitiveDependencies,
        serviceId: serviceId,
      );

  ServicePricesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serviceId,
  }) : super.internal();

  final String serviceId;

  @override
  Override overrideWith(
    FutureOr<List<AdminPrice>> Function(ServicePricesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServicePricesProvider._internal(
        (ref) => create(ref as ServicePricesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serviceId: serviceId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AdminPrice>> createElement() {
    return _ServicePricesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServicePricesProvider && other.serviceId == serviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServicePricesRef on AutoDisposeFutureProviderRef<List<AdminPrice>> {
  /// The parameter `serviceId` of this provider.
  String get serviceId;
}

class _ServicePricesProviderElement
    extends AutoDisposeFutureProviderElement<List<AdminPrice>>
    with ServicePricesRef {
  _ServicePricesProviderElement(super.provider);

  @override
  String get serviceId => (origin as ServicePricesProvider).serviceId;
}

String _$servicesAdminControllerHash() =>
    r'3022c715359a56b2869ca22003ac2aeb275195ba';

/// Los servicios de la pantalla de administración (§10.1).
///
/// Copied from [ServicesAdminController].
@ProviderFor(ServicesAdminController)
final servicesAdminControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ServicesAdminController,
      List<AdminService>
    >.internal(
      ServicesAdminController.new,
      name: r'servicesAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$servicesAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ServicesAdminController =
    AutoDisposeAsyncNotifier<List<AdminService>>;
String _$priceRegistrarHash() => r'3757aae820c9c12ba06108e162fa5665b00b5753';

/// Registra un precio nuevo.
///
/// Recarga en vez de insertar porque este POST **cambia otra fila**: la ventana
/// vigente queda cerrada el día anterior, y esa fecha la pone el servidor.
///
/// Copied from [PriceRegistrar].
@ProviderFor(PriceRegistrar)
final priceRegistrarProvider =
    AutoDisposeNotifierProvider<PriceRegistrar, void>.internal(
      PriceRegistrar.new,
      name: r'priceRegistrarProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$priceRegistrarHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PriceRegistrar = AutoDisposeNotifier<void>;
String _$garmentsAdminControllerHash() =>
    r'446660a2fd1c381a41cdbe17f30067fee52dfdc3';

/// Los tipos de prenda (§10.2).
///
/// Copied from [GarmentsAdminController].
@ProviderFor(GarmentsAdminController)
final garmentsAdminControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      GarmentsAdminController,
      List<AdminGarment>
    >.internal(
      GarmentsAdminController.new,
      name: r'garmentsAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$garmentsAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GarmentsAdminController =
    AutoDisposeAsyncNotifier<List<AdminGarment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
