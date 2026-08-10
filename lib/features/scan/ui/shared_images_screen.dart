import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../auth/state/auth_controller.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../state/cash_sheet_controller.dart';
import '../state/scan_controller.dart';
import '../state/shared_images_controller.dart';
import 'cash_sheet_scan_screen.dart';
import 'scan_screen.dart';

/// «¿Qué es esto?», para lo que llegó compartido desde WhatsApp.
///
/// La única pregunta que la app no puede contestar sola. Una boleta de talonario
/// y la hoja del día son las dos un papel con números escritos a mano, y mandar
/// una al lector de la otra no da un error claro: da una lectura plausible y
/// equivocada. Un toque aquí lo resuelve, y es el único toque que se pide antes
/// de que la lectura empiece.
///
/// Si vinieron varias fotos se dicen cuántas y se van leyendo de una en una: la
/// elección vale para todo el lote, porque nadie comparte una hoja de caja
/// mezclada con boletas.
class SharedImagesScreen extends ConsumerWidget {
  const SharedImagesScreen({super.key});

  static const String path = '/shared';

  void _asTicket(BuildContext context, WidgetRef ref) {
    final image = ref
        .read(sharedImagesControllerProvider.notifier)
        .takeNext(SharedKind.ticket);
    if (image == null) return;

    // La foto entra por el mismo camino que una de la cámara: el escaneo no
    // distingue de dónde vino, y no debería.
    unawaited(ref.read(scanControllerProvider.notifier).send(image));
    context.pushReplacement(ScanScreen.path);
  }

  void _asCashSheet(BuildContext context, WidgetRef ref) {
    final image = ref
        .read(sharedImagesControllerProvider.notifier)
        .takeNext(SharedKind.cashSheet);
    if (image == null) return;

    unawaited(ref.read(cashSheetControllerProvider.notifier).send(image));
    context.pushReplacement(CashSheetScanScreen.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shared = ref.watch(sharedImagesControllerProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final canImportClose =
        user?.hasAnyPermission(const [AppPermissions.scansImportClose]) ?? false;

    if (shared.isEmpty) {
      // Se consumió todo, o se entró a la ruta a mano. Volver a Inicio es la
      // salida honesta: no hay nada que enseñar.
      return const _Empty();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              children: [
                _Preview(shared: shared),
                const SizedBox(height: 18),
                Text(
                  '¿Qué mandaste?',
                  style: AppTypography.h3.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  shared.count == 1
                      ? 'Decime qué papel es y lo leo.'
                      : 'Decime qué papeles son y los voy leyendo de uno en uno.',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                _Choice(
                  icon: Icons.receipt_long_rounded,
                  title: 'Boleta nueva',
                  subtitle:
                      'La del talonario, con el cliente y los servicios. Se abre '
                      'la toma de pedido ya llena.',
                  onTap: () => _asTicket(context, ref),
                ),
                const SizedBox(height: 10),
                _Choice(
                  icon: Icons.table_chart_rounded,
                  title: 'Hoja del día (cierre)',
                  subtitle: canImportClose
                      ? 'El «Registro Diario», con las boletas cobradas y los '
                            'gastos. Se importa fila por fila.'
                      : 'Necesitás permiso para importar la hoja del día. '
                            'Pedíselo a un administrador.',
                  enabled: canImportClose,
                  onTap: () => _asCashSheet(context, ref),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    ref.read(sharedImagesControllerProvider.notifier).clear();
                    context.go('/');
                  },
                  child: const Text('Descartar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(sharedImagesControllerProvider).count;

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          const Icon(Icons.ios_share_rounded, color: AppColors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1 ? '1 foto compartida' : '$count fotos compartidas',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Importar desde WhatsApp',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La primera foto en grande y las que esperan detrás, en miniatura.
class _Preview extends StatelessWidget {
  const _Preview({required this.shared});

  final SharedImages shared;

  @override
  Widget build(BuildContext context) {
    final next = shared.next;
    if (next == null) return const SizedBox.shrink();

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ClipRRect(
            borderRadius: AppRadius.lgAll,
            child: Image.memory(next, fit: BoxFit.contain),
          ),
        ),
        if (shared.count > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: shared.count - 1,
              separatorBuilder: (context, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: AppRadius.smAll,
                child: Image.memory(
                  shared.pending[index + 1],
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Después de esta quedan ${shared.count - 1}.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.white : AppColors.gray100,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 30,
                color: enabled ? AppColors.primary500 : AppColors.gray400,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTypography.helper.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'No hay nada compartido',
                style: AppTypography.h3.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Ir al inicio', onPressed: () => context.go('/')),
            ],
          ),
        ),
      ),
    );
  }
}
