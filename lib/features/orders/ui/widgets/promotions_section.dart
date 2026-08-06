import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/money/fixed2.dart';
import '../../../promotions/models/promotion.dart';
import '../../domain/order_pricing.dart';
import 'capture_section.dart';

/// Los chips de promoción de la sección 6 (plan 0002 §3.6).
///
/// Se ven **con o sin permiso de descuento manual**: elegir una promoción
/// vigente es trabajo de mostrador —la decisión ya la tomó quien la creó—,
/// mientras que teclear un monto a mano sigue siendo del admin.
///
/// Cada chip dice lo que rebajaría en esta boleta. Es una estimación del
/// dispositivo, igual que el total del footer: lo que se manda es el código y
/// el servidor vuelve a hacer la cuenta al aplicar la operación (D5).
class PromotionsSection extends StatelessWidget {
  const PromotionsSection({
    super.key,
    required this.promotions,
    required this.lines,
    required this.selected,
    required this.onToggle,
  });

  /// Las promociones en vigor en la fecha del pedido.
  final List<Promotion> promotions;

  /// Las líneas ya cotizadas, para estimar cuánto rebaja cada una.
  final List<PricedCharge> lines;

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return Text(
        'No hay promociones vigentes para esta fecha.',
        style: AppTypography.helper.copyWith(fontSize: 12),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final promotion in promotions)
          _PromotionChip(
            promotion: promotion,
            amount: estimatePromotion(promotion, lines),
            selected: selected.contains(promotion.code),
            onTap: () => onToggle(promotion.code),
          ),
      ],
    );
  }
}

class _PromotionChip extends StatelessWidget {
  const _PromotionChip({
    required this.promotion,
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final Promotion promotion;

  /// Lo que rebajaría ahora mismo, en centavos. Cero es "todavía no muerde
  /// nada": el chip lo dice en vez de esconderse, porque la promoción existe y
  /// lo que falta es agregar el servicio al que aplica.
  final int amount;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.gray600;

    return Material(
      color: selected ? AppColors.primary500 : AppColors.gray100,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.fullAll,
        child: Semantics(
          selected: selected,
          button: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.local_offer_outlined,
                  size: 15,
                  color: foreground,
                ),
                const SizedBox(width: 7),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        promotion.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: foreground,
                        ),
                      ),
                      Text(
                        amount > 0
                            ? '−Q${Fixed2.format(amount)}'
                            : 'sin efecto en esta boleta',
                        style: AppTypography.money(
                          fontSize: 11,
                          color: selected ? AppColors.white : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El aviso de la sección cuando una promoción marcada no se puede aplicar.
///
/// Reusa [CaptureNotice] en rojo: no es una advertencia que se pueda ignorar
/// —el pedido no se guarda así— y el footer solo alcanza a mostrar la primera.
class PromotionIssue extends StatelessWidget {
  const PromotionIssue({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      CaptureNotice(message: message, isError: true);
}
