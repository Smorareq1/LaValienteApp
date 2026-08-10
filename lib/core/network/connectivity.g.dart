// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityChangesHash() =>
    r'5f19b67b5cbdf45e0ab9c98ef68c2f9f94b5116c';

/// Emite `true` cuando el dispositivo vuelve a tener una interfaz de red.
///
/// Es una señal de *oportunidad*, no una garantía: tener wifi no significa que
/// el backend responda. Quien la escuche debe seguir tolerando el fallo.
/// Aislado en un provider para que las pruebas puedan sustituirlo sin tocar
/// canales de plataforma.
///
/// Copied from [connectivityChanges].
@ProviderFor(connectivityChanges)
final connectivityChangesProvider = StreamProvider<bool>.internal(
  connectivityChanges,
  name: r'connectivityChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityChangesRef = StreamProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
