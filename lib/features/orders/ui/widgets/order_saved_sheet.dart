import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../models/saved_order.dart';

/// Confirmación de una boleta guardada (plan 0002 §3.8).
///
/// Lo primero y más grande es el número, porque es lo que se dice en voz alta al
/// entregar el resguardo. Si el pedido todavía no subió se muestra el folio
/// provisional y se dice por qué: el número definitivo lo asigna el servidor, y
/// callarlo haría que alguien apuntara un `P-1` en la boleta de papel.
class OrderSavedSheet extends StatelessWidget {
  const OrderSavedSheet({super.key, required this.order});

  final SavedOrder order;

  /// Devuelve `true` si la persona quiere tomar otra boleta.
  static Future<bool?> show(BuildContext context, SavedOrder order) {
    return AppBottomSheetScaffold.show<bool>(
      context: context,
      builder: (context) => OrderSavedSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Pedido guardado',
      subtitle: order.pendingSync
          ? 'Queda pendiente de sincronizar'
          : 'Ya está registrado en el sistema',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Listo',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Nuevo pedido',
              icon: const Icon(Icons.add_rounded),
              fullWidth: true,
              elevated: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  order.pendingSync ? 'FOLIO PROVISIONAL' : 'NO. DIARIO',
                  style: AppTypography.caption.copyWith(fontSize: 10.5),
                ),
                const SizedBox(height: 4),
                Text(
                  order.reference,
                  style: AppTypography.money(fontSize: 38, color: AppColors.primary700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Line(label: 'Total', amount: order.totalAsDouble, strong: true),
          const SizedBox(height: 8),
          _Line(label: 'Saldo pendiente', amount: order.balanceAsDouble),
          if (order.pendingSync) ...[
            const SizedBox(height: 14),
            _Note(
              icon: Icons.sync_rounded,
              message:
                  'El número definitivo lo asigna el servidor al sincronizar. '
                  'Mientras tanto el pedido ya se puede consultar y cobrar aquí.',
            ),
          ],
          for (final warning in order.warnings) ...[
            const SizedBox(height: 10),
            _Note(icon: Icons.info_outline_rounded, message: warning, warning: true),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.amount, this.strong = false});

  final String label;
  final double amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            fontSize: 13.5,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        AppMoneyText(amount, size: strong ? AppMoneySize.lg : AppMoneySize.md),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.message, this.warning = false});

  final IconData icon;
  final String message;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final foreground = warning ? AppColors.warningText : AppColors.infoText;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: warning ? AppColors.warningBg : AppColors.infoBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
