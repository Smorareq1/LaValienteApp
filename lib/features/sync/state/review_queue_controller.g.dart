// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_queue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewQueueHash() => r'c3c943ff2d6a4dc2da2bfac2e2f3f3d804c34d62';

/// La cola de revisión en vivo desde la BD local.
///
/// Copied from [reviewQueue].
@ProviderFor(reviewQueue)
final reviewQueueProvider =
    AutoDisposeStreamProvider<List<ReviewItem>>.internal(
      reviewQueue,
      name: r'reviewQueueProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reviewQueueHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewQueueRef = AutoDisposeStreamProviderRef<List<ReviewItem>>;
String _$reviewEntryHash() => r'c1a03a1a64f77623c006167b92de3015c5abfc9a';

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

/// Una entrada concreta, o `null` si ya se resolvió.
///
/// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
/// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
/// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
/// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
///
/// Copied from [reviewEntry].
@ProviderFor(reviewEntry)
const reviewEntryProvider = ReviewEntryFamily();

/// Una entrada concreta, o `null` si ya se resolvió.
///
/// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
/// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
/// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
/// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
///
/// Copied from [reviewEntry].
class ReviewEntryFamily extends Family<AsyncValue<ReviewItem?>> {
  /// Una entrada concreta, o `null` si ya se resolvió.
  ///
  /// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
  /// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
  /// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
  /// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
  ///
  /// Copied from [reviewEntry].
  const ReviewEntryFamily();

  /// Una entrada concreta, o `null` si ya se resolvió.
  ///
  /// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
  /// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
  /// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
  /// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
  ///
  /// Copied from [reviewEntry].
  ReviewEntryProvider call(String opId) {
    return ReviewEntryProvider(opId);
  }

  @override
  ReviewEntryProvider getProviderOverride(
    covariant ReviewEntryProvider provider,
  ) {
    return call(provider.opId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reviewEntryProvider';
}

/// Una entrada concreta, o `null` si ya se resolvió.
///
/// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
/// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
/// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
/// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
///
/// Copied from [reviewEntry].
class ReviewEntryProvider extends AutoDisposeProvider<AsyncValue<ReviewItem?>> {
  /// Una entrada concreta, o `null` si ya se resolvió.
  ///
  /// Se deriva de la lista en vez de consultarse aparte para que resolverla cierre
  /// la pantalla de detalle sola: la fila desaparece de la cola y este proveedor
  /// pasa a `null` en el mismo instante. Conserva el [AsyncValue] porque "todavía
  /// no cargó" y "ya no está" se ven igual en un `null` y significan lo contrario.
  ///
  /// Copied from [reviewEntry].
  ReviewEntryProvider(String opId)
    : this._internal(
        (ref) => reviewEntry(ref as ReviewEntryRef, opId),
        from: reviewEntryProvider,
        name: r'reviewEntryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reviewEntryHash,
        dependencies: ReviewEntryFamily._dependencies,
        allTransitiveDependencies: ReviewEntryFamily._allTransitiveDependencies,
        opId: opId,
      );

  ReviewEntryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.opId,
  }) : super.internal();

  final String opId;

  @override
  Override overrideWith(
    AsyncValue<ReviewItem?> Function(ReviewEntryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReviewEntryProvider._internal(
        (ref) => create(ref as ReviewEntryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        opId: opId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AsyncValue<ReviewItem?>> createElement() {
    return _ReviewEntryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewEntryProvider && other.opId == opId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, opId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReviewEntryRef on AutoDisposeProviderRef<AsyncValue<ReviewItem?>> {
  /// The parameter `opId` of this provider.
  String get opId;
}

class _ReviewEntryProviderElement
    extends AutoDisposeProviderElement<AsyncValue<ReviewItem?>>
    with ReviewEntryRef {
  _ReviewEntryProviderElement(super.provider);

  @override
  String get opId => (origin as ReviewEntryProvider).opId;
}

String _$reviewSubjectHash() => r'34ad95887dfe4623a7c964553144a089b0834c53';

/// Qué hay ahora sobre lo que la operación tocó (§11.2).
///
/// Copied from [reviewSubject].
@ProviderFor(reviewSubject)
const reviewSubjectProvider = ReviewSubjectFamily();

/// Qué hay ahora sobre lo que la operación tocó (§11.2).
///
/// Copied from [reviewSubject].
class ReviewSubjectFamily extends Family<AsyncValue<ReviewSubject?>> {
  /// Qué hay ahora sobre lo que la operación tocó (§11.2).
  ///
  /// Copied from [reviewSubject].
  const ReviewSubjectFamily();

  /// Qué hay ahora sobre lo que la operación tocó (§11.2).
  ///
  /// Copied from [reviewSubject].
  ReviewSubjectProvider call(String opId) {
    return ReviewSubjectProvider(opId);
  }

  @override
  ReviewSubjectProvider getProviderOverride(
    covariant ReviewSubjectProvider provider,
  ) {
    return call(provider.opId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reviewSubjectProvider';
}

/// Qué hay ahora sobre lo que la operación tocó (§11.2).
///
/// Copied from [reviewSubject].
class ReviewSubjectProvider extends AutoDisposeFutureProvider<ReviewSubject?> {
  /// Qué hay ahora sobre lo que la operación tocó (§11.2).
  ///
  /// Copied from [reviewSubject].
  ReviewSubjectProvider(String opId)
    : this._internal(
        (ref) => reviewSubject(ref as ReviewSubjectRef, opId),
        from: reviewSubjectProvider,
        name: r'reviewSubjectProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reviewSubjectHash,
        dependencies: ReviewSubjectFamily._dependencies,
        allTransitiveDependencies:
            ReviewSubjectFamily._allTransitiveDependencies,
        opId: opId,
      );

  ReviewSubjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.opId,
  }) : super.internal();

  final String opId;

  @override
  Override overrideWith(
    FutureOr<ReviewSubject?> Function(ReviewSubjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReviewSubjectProvider._internal(
        (ref) => create(ref as ReviewSubjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        opId: opId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ReviewSubject?> createElement() {
    return _ReviewSubjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewSubjectProvider && other.opId == opId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, opId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReviewSubjectRef on AutoDisposeFutureProviderRef<ReviewSubject?> {
  /// The parameter `opId` of this provider.
  String get opId;
}

class _ReviewSubjectProviderElement
    extends AutoDisposeFutureProviderElement<ReviewSubject?>
    with ReviewSubjectRef {
  _ReviewSubjectProviderElement(super.provider);

  @override
  String get opId => (origin as ReviewSubjectProvider).opId;
}

String _$reviewQueueControllerHash() =>
    r'65fb08bae38d320cd988c1960baed84ff176be94';

/// Las dos decisiones que se pueden tomar sobre una entrada: descartarla o
/// volver a mandarla.
///
/// Copied from [ReviewQueueController].
@ProviderFor(ReviewQueueController)
final reviewQueueControllerProvider =
    AutoDisposeNotifierProvider<ReviewQueueController, void>.internal(
      ReviewQueueController.new,
      name: r'reviewQueueControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reviewQueueControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReviewQueueController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
