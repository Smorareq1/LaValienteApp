// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_images_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedImagesPendingHash() =>
    r'7ef2e3a1bf96c9450e3c7ae7170c3615606bba9a';

/// Cuántas fotos compartidas quedan por leer, para el aviso de las pantallas de
/// escaneo. Un `int` y no el estado entero: quien lo mira solo necesita saber si
/// vale la pena ofrecer «la siguiente».
///
/// Copied from [sharedImagesPending].
@ProviderFor(sharedImagesPending)
final sharedImagesPendingProvider = Provider<int>.internal(
  sharedImagesPending,
  name: r'sharedImagesPendingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedImagesPendingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedImagesPendingRef = ProviderRef<int>;
String _$sharedImagesControllerHash() =>
    r'f0a1bb9ed08d5c65862e06000fce150f28da4913';

/// Recibe lo compartido y lo mantiene hasta que se consume.
///
/// `keepAlive` a propósito: el intent llega **antes** de que exista ninguna
/// pantalla de escaneo —de hecho es lo que abre la app— y un provider que se
/// desechara al cambiar de ruta perdería las fotos entre la elección del
/// documento y la pantalla que las lee.
///
/// Copied from [SharedImagesController].
@ProviderFor(SharedImagesController)
final sharedImagesControllerProvider =
    NotifierProvider<SharedImagesController, SharedImages>.internal(
      SharedImagesController.new,
      name: r'sharedImagesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedImagesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SharedImagesController = Notifier<SharedImages>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
