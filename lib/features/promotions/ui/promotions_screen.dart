import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/promotion.dart';
import '../state/promotions_admin_controller.dart';
import 'widgets/promotion_form_sheet.dart';

/// Administración de promociones (Plan 0006 §10.3).
///
/// Es de las pocas pantallas **en línea**: lo operativo funciona sin señal, pero
/// crear una promoción no es una captura de mostrador. Sin red se dice y se
/// ofrece reintentar, que es lo que §14 pide para las pantallas de gestión.
class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  static const String path = '/promotions';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotions = ref.watch(promotionsAdminControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(count: promotions.valueOrNull?.length),
          Expanded(
            child: switch (promotions) {
              AsyncData(:final value) => _PromotionList(promotions: value),
              AsyncError(:final error) => _LoadError(
                message: '$error',
                onRetry: () => ref.invalidate(promotionsAdminControllerProvider),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PromotionFormSheet.show(context),
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Promoción'),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          _BackButton(onPressed: context.pop),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == null ? '' : '$count en total',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Promociones',
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

class _PromotionList extends StatelessWidget {
  const _PromotionList({required this.promotions});

  final List<Promotion> promotions;

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.local_offer_outlined,
            title: 'Todavía no hay promociones',
            message:
                'Las que crees aquí aparecen como chips en la toma de pedido, '
                'incluso sin señal.',
          ),
        ),
      );
    }

    final today = isoDate(businessDate());

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 96),
      itemCount: promotions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) => _PromotionCard(
        promotion: promotions[index],
        standing: PromotionStanding.of(promotions[index], today),
      ),
    );
  }
}

class _PromotionCard extends ConsumerWidget {
  const _PromotionCard({required this.promotion, required this.standing});

  final Promotion promotion;
  final PromotionStanding standing;

  /// Lo que rebaja, dicho como se lee: "50%", "Q5.00 de menos", "queda en Q35".
  String get _value => switch (promotion.discountType) {
    DiscountType.percentage => '${Fixed2.format(promotion.value)}%'.replaceAll('.00', ''),
    DiscountType.fixedAmount => 'Q${Fixed2.format(promotion.value)} de menos',
    DiscountType.specialPrice => 'queda en Q${Fixed2.format(promotion.value)}',
    null => 'tipo desconocido',
  };

  String get _scope {
    final codes = promotion.appliesToServiceCodes;
    if (codes == null || codes.isEmpty) return 'todo el pedido';
    return codes.length == 1 ? '1 servicio' : '${codes.length} servicios';
  }

  String get _window {
    final until = promotion.validTo;
    return until == null
        ? 'desde ${_readable(promotion.validFrom)}'
        : '${_readable(promotion.validFrom)} → ${_readable(until)}';
  }

  static String _readable(String isoDate) {
    final parts = isoDate.split('-');
    return parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : isoDate;
  }

  AppStatusTone get _tone => switch (standing) {
    PromotionStanding.live => AppStatusTone.success,
    PromotionStanding.scheduled => AppStatusTone.info,
    PromotionStanding.expired => AppStatusTone.neutral,
    PromotionStanding.off => AppStatusTone.warning,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppListCard(
      title: promotion.name,
      subtitle: '$_value · $_scope · $_window',
      leading: AppListCardTile(
        icon: standing == PromotionStanding.live
            ? Icons.local_offer_rounded
            : Icons.local_offer_outlined,
        background: standing == PromotionStanding.live
            ? AppColors.primary100
            : AppColors.gray100,
        foreground: standing == PromotionStanding.live
            ? AppColors.primary700
            : AppColors.gray500,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusBadge(label: standing.label, tone: _tone),
          const SizedBox(width: 4),
          // Prender y apagar sin abrir el formulario: es lo que se hace a
          // diario, y una promoción de temporada se apaga entre semanas.
          IconButton(
            tooltip: promotion.isActive ? 'Apagar' : 'Encender',
            icon: Icon(
              promotion.isActive
                  ? Icons.toggle_on_rounded
                  : Icons.toggle_off_outlined,
              color: promotion.isActive ? AppColors.primary500 : AppColors.gray400,
              size: 26,
            ),
            onPressed: () => _toggle(context, ref),
          ),
        ],
      ),
      onTap: () => PromotionFormSheet.show(context, promotion: promotion),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(promotionsAdminControllerProvider.notifier)
        .setActive(promotion.id, isActive: !promotion.isActive);

    if (!context.mounted) return;
    result.match(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {},
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'No se pudieron cargar las promociones',
              message:
                  'Esta pantalla necesita conexión: administrar promociones se '
                  'hace contra el servidor, no contra el dispositivo.',
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Reintentar',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const Tooltip(
          message: 'Volver',
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(Icons.arrow_back_rounded, size: 19, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
