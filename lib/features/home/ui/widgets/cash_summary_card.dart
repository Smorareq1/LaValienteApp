import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../models/home_summary.dart';

/// Tarjeta "Caja al momento": lo cobrado hasta ahora, cómo se reparte entre
/// efectivo y transferencia, y los dos números que la encargada necesita para
/// cuadrar (gastos del día y saldo por cobrar).
///
/// El resultado neto no se muestra aquí a propósito: se cierra en Caja al
/// terminar la jornada (Plan 0005 §6.1).
class CashSummaryCard extends StatelessWidget {
  const CashSummaryCard({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cobrado hasta ahora',
                      style: AppTypography.helper.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppMoneyText(summary.collectedToday, size: AppMoneySize.hero),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const _LiveBadge(),
            ],
          ),
          const SizedBox(height: 14),
          _PaymentSplitBar(summary: summary),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Gastos del día',
                  amount: summary.expensesToday,
                  background: AppColors.gray50,
                  labelColor: AppColors.gray500,
                  amountColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'Por cobrar',
                  amount: summary.receivable,
                  background: summary.receivable > 0
                      ? AppColors.errorBg
                      : AppColors.gray50,
                  labelColor: summary.receivable > 0
                      ? AppColors.errorText
                      : AppColors.gray500,
                  amountColor: summary.receivable > 0
                      ? const Color(0xFF912018)
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Text(
              'El resultado del día se cierra en Caja al terminar la jornada',
              textAlign: TextAlign.center,
              style: AppTypography.helper.copyWith(
                fontSize: 11.5,
                color: AppColors.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de arqueo efectivo vs. transferencia.
class _PaymentSplitBar extends StatelessWidget {
  const _PaymentSplitBar({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final cashShare = summary.cashShare;
    final hasCollection = summary.collectedToday > 0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: hasCollection
                ? Row(
                    children: [
                      Expanded(
                        flex: (cashShare * 1000).round(),
                        child: const ColoredBox(color: AppColors.success),
                      ),
                      Expanded(
                        flex: ((1 - cashShare) * 1000).round(),
                        child: const ColoredBox(color: AppColors.primary400),
                      ),
                    ],
                  )
                : const ColoredBox(color: AppColors.gray100),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SplitLegend(
                color: AppColors.success,
                label: 'Efectivo',
                amount: summary.collectedCash,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SplitLegend(
                color: AppColors.primary400,
                label: 'Transferencia',
                amount: summary.collectedTransfer,
                alignEnd: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SplitLegend extends StatelessWidget {
  const _SplitLegend({
    required this.color,
    required this.label,
    required this.amount,
    this.alignEnd = false,
  });

  final Color color;
  final String label;
  final double amount;

  /// Alinea la leyenda a la derecha (la de transferencia).
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        // Con montos largos el texto se recorta en vez de desbordar la tarjeta.
        Flexible(
          child: Text(
            '$label ${AppMoneyText.format(amount, showDecimals: false)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.helper.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.amount,
    required this.background,
    required this.labelColor,
    required this.amountColor,
  });

  final String label;
  final double amount;
  final Color background;
  final Color labelColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.helper.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 2),
          AppMoneyText(amount, size: AppMoneySize.md, color: amountColor),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: const BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'en vivo',
            style: AppTypography.helper.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary700,
            ),
          ),
        ],
      ),
    );
  }
}
