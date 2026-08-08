// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncEngineHash() => r'ac03a8ef57724e24b08fce1e1906447f0ab28162';

/// Decide **cuándo** sincronizar. El *cómo* vive en [SyncRepository].
///
/// Dispara con los cuatro eventos del plan (§5): recuperar conectividad, app a
/// primer plano, mutación local (con debounce) y un periódico de red. Nunca
/// corre dos ciclos a la vez: el segundo se engancha al que ya está en vuelo,
/// porque dos push simultáneos del mismo outbox mandarían las mismas
/// operaciones dos veces.
///
/// Copied from [SyncEngine].
@ProviderFor(SyncEngine)
final syncEngineProvider =
    NotifierProvider<SyncEngine, SyncEngineState>.internal(
      SyncEngine.new,
      name: r'syncEngineProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncEngineHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncEngine = Notifier<SyncEngineState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
