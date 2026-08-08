import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// De dónde sale la foto.
enum AppImageSource { camera, gallery }

/// Elegir una foto: preview, cámara o galería, y quitarla.
///
/// El componente **no** habla con la cámara. Pide la foto a quien lo usa a
/// través de [onPick] y solo se encarga de enseñarla, porque el plugin que abre
/// la cámara es una dependencia de la app y el design system no depende de nada
/// más que de Flutter.
class AppImagePicker extends StatelessWidget {
  const AppImagePicker({
    super.key,
    required this.onPick,
    this.bytes,
    this.placeholder,
    this.onRemove,
    this.busy = false,
    this.errorText,
    this.size = 108,
  });

  /// Los bytes de la foto elegida en esta sesión, si ya se eligió una.
  final Uint8List? bytes;

  /// Lo que se enseña mientras no hay foto nueva: normalmente la que el
  /// producto ya tiene.
  final Widget? placeholder;

  /// Devuelve los bytes de la foto, o `null` si quien elige se arrepintió.
  final Future<Uint8List?> Function(AppImageSource source) onPick;

  /// `null` esconde el botón de quitar, que es lo correcto cuando no hay foto.
  final VoidCallback? onRemove;

  final bool busy;
  final String? errorText;
  final double size;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<AppImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.of(context).pop(AppImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(context).pop(AppImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null) await onPick(source);
  }

  @override
  Widget build(BuildContext context) {
    final picked = bytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Preview(
              size: size,
              busy: busy,
              child: picked != null
                  ? Image.memory(picked, fit: BoxFit.cover)
                  : placeholder,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => _pick(context),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 17),
                    label: Text(picked == null ? 'Poner una foto' : 'Cambiar la foto'),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: busy ? null : onRemove,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Quitar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    'Se sube al guardar. Se reduce sola, así que no importa que '
                    'la foto salga pesada.',
                    style: AppTypography.helper.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTypography.helper.copyWith(color: AppColors.errorText),
          ),
        ],
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.size, required this.busy, this.child});

  final double size;
  final bool busy;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: Container(
        width: size,
        height: size,
        color: AppColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child ??
                const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 30,
                    color: AppColors.gray400,
                  ),
                ),
            if (busy)
              ColoredBox(
                color: AppColors.gray900.withValues(alpha: 0.35),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
