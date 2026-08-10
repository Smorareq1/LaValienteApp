import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticket_photo_picker.g.dart';

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
@riverpod
TicketPhotoPicker ticketPhotoPicker(Ref ref) => const TicketPhotoPicker();

class TicketPhotoPicker {
  const TicketPhotoPicker();

  Future<Uint8List?> pick(AppImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source == AppImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 2560,
      maxHeight: 2560,
      imageQuality: 90,
    );
    if (picked == null) return null;
    return picked.readAsBytes();
  }
}
