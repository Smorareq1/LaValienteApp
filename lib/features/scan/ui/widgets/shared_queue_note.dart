import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/shared_images_controller.dart';
import '../shared_images_screen.dart';

/// «Quedan N fotos de WhatsApp», con la salida hacia la siguiente.
///
/// Vive en el estado vacío de las dos pantallas de escaneo porque es justo donde
/// alguien aterriza al terminar con una foto del lote, y sin esto la cola sería
/// invisible: catorce boletas compartidas y ninguna señal de que quedaban trece.
class SharedQueueNote extends ConsumerWidget {
  const SharedQueueNote({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(sharedImagesPendingProvider);
    if (pending == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.secondary50,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: () => context.pushReplacement(SharedImagesScreen.path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.ios_share_rounded,
                  size: 19,
                  color: AppColors.secondary700,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    pending == 1
                        ? 'Queda 1 foto compartida por leer'
                        : 'Quedan $pending fotos compartidas por leer',
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondary700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
