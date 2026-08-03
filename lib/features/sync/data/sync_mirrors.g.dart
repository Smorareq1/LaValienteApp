// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_mirrors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncMirrorsHash() => r'692e5ca1cf86bc76c1374b05e81622c1f2fe6339';

/// Espejos registrados, por nombre de entidad en el feed.
///
/// Sumar un módulo al espejo local es agregar una línea aquí; el motor no se
/// toca. Lo que llegue de una entidad ausente de este mapa se guarda en
/// `deferred_changes` y se aplica sola cuando su espejo aparezca.
///
/// Vive aparte del contrato ([SyncEntityMirror]) a propósito: si el registro
/// estuviera en el mismo archivo, cada módulo importaría el registro de todos
/// los demás para poder implementar la interfaz.
///
/// Copied from [syncMirrors].
@ProviderFor(syncMirrors)
final syncMirrorsProvider = Provider<Map<String, SyncEntityMirror>>.internal(
  syncMirrors,
  name: r'syncMirrorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncMirrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncMirrorsRef = ProviderRef<Map<String, SyncEntityMirror>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
