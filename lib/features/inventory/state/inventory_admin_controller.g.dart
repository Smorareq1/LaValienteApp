// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productImagePickerHash() =>
    r'b9442af49af371cd8315ae4548ddaa3a51c81eac';

/// Abre la cámara o la galería y devuelve los bytes.
///
/// Se le pide una imagen ya reducida —1440 px de lado mayor, calidad 82— porque
/// la foto de un bote de jabón no necesita más y el servidor tiene un tope de
/// 5 MB. Reducir aquí evita subir 12 MB por una miniatura de 46 px.
///
/// Copied from [productImagePicker].
@ProviderFor(productImagePicker)
final productImagePickerProvider =
    AutoDisposeProvider<ProductImagePicker>.internal(
      productImagePicker,
      name: r'productImagePickerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productImagePickerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductImagePickerRef = AutoDisposeProviderRef<ProductImagePicker>;
String _$inventoryAdminControllerHash() =>
    r'ecb4d03428eb4ac057855f18701673b64d5298f8';

/// Las escrituras de administración de inventario (§8.3–§8.5).
///
/// No guarda lista: la que se ve sale del espejo local, que es lo que sigue
/// funcionando sin señal. Lo que hace este controlador es **escribir arriba** y
/// después invalidar lo que quedó viejo, para que la pantalla no siga enseñando
/// un stock que ya cambió mientras el feed baja.
///
/// Copied from [InventoryAdminController].
@ProviderFor(InventoryAdminController)
final inventoryAdminControllerProvider =
    AutoDisposeNotifierProvider<InventoryAdminController, void>.internal(
      InventoryAdminController.new,
      name: r'inventoryAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoryAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InventoryAdminController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
