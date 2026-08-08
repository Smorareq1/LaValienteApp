// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$devicesControllerHash() => r'8227bbf929d40b4f517d47c7ffca0bef281fd9c7';

/// Los dispositivos registrados (Plan 0006 §12).
///
/// Copied from [DevicesController].
@ProviderFor(DevicesController)
final devicesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      DevicesController,
      List<SyncDevice>
    >.internal(
      DevicesController.new,
      name: r'devicesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$devicesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DevicesController = AutoDisposeAsyncNotifier<List<SyncDevice>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
