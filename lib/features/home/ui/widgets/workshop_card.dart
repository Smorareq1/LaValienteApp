import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../orders/models/order.dart';
import '../../models/home_summary.dart';

/// Tarjeta "En el taller": cuántos pedidos hay en cada estado. Tocar un
/// contador abre la lista de pedidos ya filtrada por ese estado.
class WorkshopCard extends StatelessWidget {
  const WorkshopCard({
    super.key,
    required this.summary,
    required this.onStatusTap,
    required this.onDeliveredTap,
  });

  final HomeSummary summary;

  /// Recibe el estado al que filtrar la lista. Viaja el enum y no su código en
  /// texto: escribirlo a mano fue justo lo que dejó "En proceso" abriendo la
  /// lista sin filtro, porque el estado del backend es `in_progress` y aquí
  /// decía `in_process`.
  final ValueChanged<OrderStatus> onStatusTap;
  final VoidCallback onDeliveredTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _StatusCount(
                    count: summary.receivedCount,
                    label: 'Recibidos',
                    color: AppColors.secondary700,
                    highlight: AppColors.secondary50,
                    onTap: () => onStatusTap(OrderStatus.received),
                  ),
                ),
                const _CountDivider(),
                Expanded(
                  child: _StatusCount(
                    count: summary.inProcessCount,
                    label: 'En proceso',
                    color: AppColors.warningText,
                    highlight: AppColors.warningBg,
                    onTap: () => onStatusTap(OrderStatus.inProgress),
                  ),
                ),
                const _CountDivider(),
                Expanded(
                  child: _StatusCount(
                    count: summary.readyCount,
                    label: 'Listos',
                    color: AppColors.successText,
                    highlight: AppColors.successBg,
                    onTap: () => onStatusTap(OrderStatus.ready),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onDeliveredTap,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray100)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded,
                      size: 15, color: AppColors.primary500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ya entregados hoy',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${summary.deliveredCount}',
                    style: AppTypography.money(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCount extends StatelessWidget {
  const _StatusCount({
    required this.count,
    required this.label,
    required this.color,
    required this.highlight,
    required this.onTap,
  });

  final int count;
  final String label;
  final Color color;
  final Color highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Sin pedidos en ese estado el número se atenúa: nada que abrir todavía.
    final effectiveColor = count > 0 ? color : AppColors.gray300;

    return InkWell(
      onTap: count > 0 ? onTap : null,
      borderRadius: BorderRadius.circular(15),
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count', style: AppTypography.money(fontSize: 26, color: effectiveColor)),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountDivider extends StatelessWidget {
  const _CountDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.gray100,
    );
  }
}
