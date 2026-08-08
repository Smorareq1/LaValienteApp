// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_close_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$closeHistoryHash() => r'9a7262f86c738c5ee07760bfb445483b1e45397e';

/// El histórico de cierres (§7.5), lo más reciente primero.
///
/// Trae también las actas reabiertas: un día cerrado en Q764 y luego reabierto
/// es un hecho, y esconderlo dejaría el rastro contando solo la mitad.
///
/// Copied from [closeHistory].
@ProviderFor(closeHistory)
final closeHistoryProvider =
    AutoDisposeFutureProvider<List<DayClosureRecord>>.internal(
      closeHistory,
      name: r'closeHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$closeHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CloseHistoryRef = AutoDisposeFutureProviderRef<List<DayClosureRecord>>;
String _$dayCloseControllerHash() =>
    r'ab3ef92de7c591e6b789e71671a1a9072106a17d';

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

abstract class _$DayCloseController
    extends BuildlessAutoDisposeAsyncNotifier<DayCloseSheet> {
  late final String date;

  FutureOr<DayCloseSheet> build(String date);
}

/// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
///
/// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
/// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
/// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
/// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
/// al firmar, mandan las cifras del servidor.
///
/// Copied from [DayCloseController].
@ProviderFor(DayCloseController)
const dayCloseControllerProvider = DayCloseControllerFamily();

/// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
///
/// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
/// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
/// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
/// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
/// al firmar, mandan las cifras del servidor.
///
/// Copied from [DayCloseController].
class DayCloseControllerFamily extends Family<AsyncValue<DayCloseSheet>> {
  /// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
  ///
  /// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
  /// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
  /// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
  /// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
  /// al firmar, mandan las cifras del servidor.
  ///
  /// Copied from [DayCloseController].
  const DayCloseControllerFamily();

  /// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
  ///
  /// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
  /// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
  /// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
  /// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
  /// al firmar, mandan las cifras del servidor.
  ///
  /// Copied from [DayCloseController].
  DayCloseControllerProvider call(String date) {
    return DayCloseControllerProvider(date);
  }

  @override
  DayCloseControllerProvider getProviderOverride(
    covariant DayCloseControllerProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dayCloseControllerProvider';
}

/// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
///
/// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
/// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
/// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
/// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
/// al firmar, mandan las cifras del servidor.
///
/// Copied from [DayCloseController].
class DayCloseControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DayCloseController,
          DayCloseSheet
        > {
  /// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
  ///
  /// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
  /// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
  /// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
  /// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
  /// al firmar, mandan las cifras del servidor.
  ///
  /// Copied from [DayCloseController].
  DayCloseControllerProvider(String date)
    : this._internal(
        () => DayCloseController()..date = date,
        from: dayCloseControllerProvider,
        name: r'dayCloseControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dayCloseControllerHash,
        dependencies: DayCloseControllerFamily._dependencies,
        allTransitiveDependencies:
            DayCloseControllerFamily._allTransitiveDependencies,
        date: date,
      );

  DayCloseControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  FutureOr<DayCloseSheet> runNotifierBuild(
    covariant DayCloseController notifier,
  ) {
    return notifier.build(date);
  }

  @override
  Override overrideWith(DayCloseController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DayCloseControllerProvider._internal(
        () => create()..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DayCloseController, DayCloseSheet>
  createElement() {
    return _DayCloseControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DayCloseControllerProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DayCloseControllerRef
    on AutoDisposeAsyncNotifierProviderRef<DayCloseSheet> {
  /// The parameter `date` of this provider.
  String get date;
}

class _DayCloseControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DayCloseController,
          DayCloseSheet
        >
    with DayCloseControllerRef {
  _DayCloseControllerProviderElement(super.provider);

  @override
  String get date => (origin as DayCloseControllerProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
