// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncDetailsHash() => r'5582a043c45b03da71d0dd047172d0703d138747';

/// Diagnóstico del motor para la pantalla de Sincronización.
///
/// Copied from [syncDetails].
@ProviderFor(syncDetails)
final syncDetailsProvider = StreamProvider<SyncDetails>.internal(
  syncDetails,
  name: r'syncDetailsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncDetailsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncDetailsRef = StreamProviderRef<SyncDetails>;
String _$pendingOperationsCountHash() =>
    r'31245f7e245d668bf35da993ac1d1afaca66f022';

/// Operaciones esperando en el outbox, en vivo desde la BD local.
///
/// Copied from [pendingOperationsCount].
@ProviderFor(pendingOperationsCount)
final pendingOperationsCountProvider = StreamProvider<int>.internal(
  pendingOperationsCount,
  name: r'pendingOperationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingOperationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOperationsCountRef = StreamProviderRef<int>;
String _$pendingByEntityHash() => r'7c6eb0ba0f6d557d0ffeed2cabb5e6f50fedfa34';

/// Lo que espera subir, desglosado por entidad (§11.1).
///
/// Copied from [pendingByEntity].
@ProviderFor(pendingByEntity)
final pendingByEntityProvider = StreamProvider<Map<String, int>>.internal(
  pendingByEntity,
  name: r'pendingByEntityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingByEntityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingByEntityRef = StreamProviderRef<Map<String, int>>;
String _$reviewQueueCountHash() => r'10925bf0082de37e5fa33352c321a9e679250065';

/// Capturas que el servidor rechazó y esperan una decisión humana (§8).
///
/// Copied from [reviewQueueCount].
@ProviderFor(reviewQueueCount)
final reviewQueueCountProvider = StreamProvider<int>.internal(
  reviewQueueCount,
  name: r'reviewQueueCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewQueueCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReviewQueueCountRef = StreamProviderRef<int>;
String _$syncStatusControllerHash() =>
    r'4afc71762701a4b739ebe2f72a26ba0a6718f9ad';

/// Estado de la cola de sincronización que consume el AppBar del shell.
///
/// Compone tres fuentes: la fase del motor, el outbox y la cola de revisión.
/// El orden de prioridad no es estético — lo que necesita una decisión humana
/// tapa a lo que solo necesita esperar, y un motor caído tapa a una cola que
/// espera, porque una cola que espera avanza sola y un motor caído no.
///
/// Copied from [SyncStatusController].
@ProviderFor(SyncStatusController)
final syncStatusControllerProvider =
    NotifierProvider<SyncStatusController, SyncStatus>.internal(
      SyncStatusController.new,
      name: r'syncStatusControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncStatusControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncStatusController = Notifier<SyncStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
