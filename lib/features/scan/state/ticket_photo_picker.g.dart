// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_photo_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ticketPhotoPickerHash() => r'43039fb1811e1e375681adcc87eb701e393f3371';

/// La foto de una boleta, de la cámara o de la galería.
///
/// Aparte del de productos y con otros números, que es la razón de que exista:
/// una boleta se lee, un bote de jabón se reconoce. **2560 px de lado mayor y
/// calidad 90**, porque lo que hay que distinguir es un 1 de un 7 escritos a
/// lápiz sobre papel de talonario, y a 1440 px con calidad 82 esa diferencia se
/// pierde en el mismo JPEG. Cabe de sobra en el tope de 8 MB del `SCAN_MAX_IMAGE_MB`.
///
/// La galería se acepta además de la cámara, que es lo que la pregunta abierta 4
/// del plan 0003 recomendaba: llegan boletas fotografiadas y mandadas por
/// WhatsApp, y obligar a re-fotografiar una pantalla sería absurdo.
///
/// Copied from [ticketPhotoPicker].
@ProviderFor(ticketPhotoPicker)
final ticketPhotoPickerProvider =
    AutoDisposeProvider<TicketPhotoPicker>.internal(
      ticketPhotoPicker,
      name: r'ticketPhotoPickerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ticketPhotoPickerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TicketPhotoPickerRef = AutoDisposeProviderRef<TicketPhotoPicker>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
