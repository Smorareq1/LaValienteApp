import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shell/ui/widgets/gradient_header.dart';
import '../models/review_item.dart';
import '../state/review_queue_controller.dart';

/// Cola de revisión (Plan 0006 §11.2, Plan 0004 §8).
///
/// Aquí termina lo que el servidor no pudo aplicar. Es la pantalla que le da
/// nombre a un pedido marcado en rojo: sin ella, una corrección que chocó con
/// otro dispositivo se vería como un error sin explicación y sin salida.
///
/// **Nada desaparece solo.** Cada entrada espera una decisión y se cierra
/// cuando alguien la toma, no cuando el motor vuelve a intentarlo.
class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  static const String path = '/sync/review';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(reviewQueueProvider);
    final items = queue.valueOrNull ?? const <ReviewItem>[];

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _Header(count: queue.hasValue ? items.length : null),
          Expanded(
            child: items.isEmpty && queue.hasValue
                ? const _Empty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      16,
                      AppSpacing.md,
                      28,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _ReviewCard(item: items[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(8, 0, 18, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            tooltip: 'Volver',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (count) {
                    null => '',
                    0 => 'Nada esperando',
                    1 => '1 captura',
                    _ => '$count capturas',
                  },
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Revisión',
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

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 28, AppSpacing.md, 28),
      children: const [
        AppEmptyState(
          icon: Icons.check_rounded,
          title: 'Nada que revisar',
          message: 'Todo lo capturado en este teléfono lo aceptó el servidor.',
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item});

  final ReviewItem item;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: item.kind.title,
      subtitle: item.subtitle,
      onTap: () => context.push('${ReviewQueueScreen.path}/${item.opId}'),
      leading: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(reviewIcon(item.kind), size: 18, color: AppColors.errorText),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusBadge(
            label: item.outcome.label,
            tone: AppStatusTone.error,
            size: AppStatusBadgeSize.sm,
          ),
          const SizedBox(height: 4),
          Text(
            reviewAge(item.createdAt),
            style: AppTypography.helper.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/// Ícono por tipo de captura: en una lista de rechazos, saber si lo que falló
/// fue un cobro o un cambio de estado es lo primero que se mira.
IconData reviewIcon(ReviewKind kind) => switch (kind) {
  ReviewKind.orderCreate => Icons.receipt_long_rounded,
  ReviewKind.orderUpdate => Icons.edit_rounded,
  ReviewKind.orderStatus => Icons.local_laundry_service_rounded,
  ReviewKind.orderDeliver => Icons.local_shipping_rounded,
  ReviewKind.orderCancel => Icons.block_rounded,
  ReviewKind.paymentCreate => Icons.payments_rounded,
  ReviewKind.customerCreate ||
  ReviewKind.customerUpdate ||
  ReviewKind.customerArchive => Icons.person_rounded,
  ReviewKind.unknown => Icons.help_outline_rounded,
};

/// Cuánto lleva esperando. Una captura de hace tres días no es lo mismo que una
/// de hace diez minutos, aunque el motivo sea idéntico.
String reviewAge(DateTime moment) {
  final elapsed = DateTime.now().difference(moment);
  if (elapsed.inMinutes < 1) return 'recién';
  if (elapsed.inMinutes < 60) return 'hace ${elapsed.inMinutes} min';
  if (elapsed.inHours < 24) return 'hace ${elapsed.inHours} h';
  return 'hace ${elapsed.inDays} d';
}
