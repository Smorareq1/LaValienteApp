import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/app_permissions.dart';
import '../../../../core/money/fixed2.dart';
import '../../../auth/state/auth_controller.dart';
import '../../../orders/ui/widgets/payment_sheet.dart';
import '../../data/deliveries_repository.dart';
import '../../models/delivery_line.dart';
import '../../state/deliveries_controller.dart';

/// El repaso del final del día: las boletas marcadas, con lo que pagó cada una
/// (plan 0006 §7.1.1).
///
/// Cada línea llega en «pagó todo» porque es lo que pasa casi siempre; solo se
/// toca la que pagó de menos. Esa es toda la diferencia entre un repaso de diez
/// boletas que toma un minuto y uno que toma diez.
class DeliveryBatchSheet extends ConsumerStatefulWidget {
  const DeliveryBatchSheet({super.key});

  /// Abre la hoja y devuelve cómo terminó, o `null` si se canceló.
  static Future<DeliveryOutcome?> show(BuildContext context) {
    return AppBottomSheetScaffold.show<DeliveryOutcome>(
      context: context,
      builder: (context) => const DeliveryBatchSheet(),
    );
  }

  @override
  ConsumerState<DeliveryBatchSheet> createState() => _DeliveryBatchSheetState();
}

class _DeliveryBatchSheetState extends ConsumerState<DeliveryBatchSheet> {
  bool _saving = false;

  Future<void> _editPayment(DeliveryLine line) async {
    // Una boleta que dejó de más no tiene nada que cobrar; lo suyo es un vuelto,
    // y la fila ya lo dice. Abrir la hoja de cobro sobre un saldo negativo solo
    // podría terminar en un error.
    if (line.credit > 0) return;

    final payment = await PaymentSheet.show(
      context,
      balance: line.balance,
      title: 'Cobro de ${line.label}',
    );
    if (payment == null) return;

    ref
        .read(deliverySelectionProvider.notifier)
        .setPayment(
          line.orderId,
          amount: payment.amount,
          method: payment.method,
          reference: payment.reference,
        );
  }

  Future<void> _confirm(DeliveryBatch batch) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    final outcome = await ref
        .read(deliveriesRepositoryProvider)
        .deliverAll(batch.lines, actorId: user.id);
    if (!mounted) return;

    // Solo se desmarca lo que sí salió: lo que falló se queda marcado para
    // volver a intentarlo sin buscarlo otra vez en la lista. Y se desmarca
    // aunque el lote no haya salido limpio, porque una boleta ya entregada no
    // puede seguir contando entre las marcadas.
    ref.read(deliverySelectionProvider.notifier).forget(outcome.deliveredIds);

    setState(() => _saving = false);
    Navigator.of(context).pop(outcome);
  }

  @override
  Widget build(BuildContext context) {
    final batch = ref.watch(deliveryBatchProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;

    // Fiar es una decisión de administrador, igual que en la pantalla de
    // entrega (§5.5). Se muestra el porqué en vez de esconder el botón.
    final canLend = user?.hasPermission(AppPermissions.ordersDeliverUnpaid) ?? false;
    final blocked = batch.hasPending && !canLend;

    if (batch.isEmpty) {
      return const AppBottomSheetScaffold(
        title: 'Sin boletas marcadas',
        child: AppEmptyState(
          icon: Icons.checklist_rounded,
          title: 'No queda ninguna marcada',
          message: 'Marca en la lista las boletas que entregaste.',
        ),
      );
    }

    return AppBottomSheetScaffold(
      title: batch.count == 1 ? 'Registrar 1 entrega' : 'Registrar ${batch.count} entregas',
      subtitle: 'Toca un monto si pagó de menos',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: batch.count == 1 ? 'Entregar' : 'Entregar ${batch.count}',
              icon: const Icon(Icons.check_rounded),
              fullWidth: true,
              elevated: true,
              loading: _saving,
              onPressed: blocked ? null : () => _confirm(batch),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in batch.lines)
            _LineRow(
              line: line,
              onEdit: _saving ? null : () => _editPayment(line),
              onRemove: _saving
                  ? null
                  : () => ref
                        .read(deliverySelectionProvider.notifier)
                        .setPayment(line.orderId, amount: line.balance, method: line.method),
            ),
          const Divider(height: 22),
          Row(
            children: [
              Text(
                'Entra a caja',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              AppMoneyText(Fixed2.toDouble(batch.collected), size: AppMoneySize.lg),
            ],
          ),
          if (batch.credit > 0) ...[
            const SizedBox(height: 12),
            _Notice(
              tone: _Tone.info,
              title: 'Hay Q${Fixed2.format(batch.credit)} que devolver',
              message: 'Alguna de estas boletas dejó de anticipo más de lo que '
                  'terminó costando. Esa diferencia sale del cajón al entregarla.',
            ),
          ],
          if (batch.hasPending) ...[
            const SizedBox(height: 12),
            _Notice(
              tone: blocked ? _Tone.error : _Tone.warning,
              title: blocked
                  ? 'Solo un administrador puede entregar fiado'
                  : 'Quedan Q${Fixed2.format(batch.pending)} sin cobrar',
              message: blocked
                  ? '${batch.partialCount} de estas boletas quedaría con saldo. '
                        'Cóbralas completas o pide que las entregue un administrador.'
                  : '${batch.partialCount == 1 ? 'Esa boleta queda entregada' : 'Esas boletas quedan entregadas'} '
                        'con saldo, y sus clientes con alerta de cobro.',
            ),
          ],
          const SizedBox(height: 12),
          _Notice(
            tone: _Tone.info,
            title: 'Cada boleta queda entregada con su cobro',
            message: 'El dinero entra a la caja de hoy. Si a alguna le falta ropa, '
                'entrégala desde el pedido para dejarlo anotado.',
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.onEdit, required this.onRemove});

  final DeliveryLine line;
  final VoidCallback? onEdit;

  /// Devuelve la línea a «pagó todo». No desmarca la boleta: quitarla de la
  /// hoja se hace en la lista, que es donde se marcó.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  // Los dos números: el correlativo con el que la app la
                  // nombra y la serie que lleva escrita el papel.
                  [
                    line.reference,
                    if (line.bookletSerial != null) line.bookletSerial!,
                  ].join(' · '),
                  style: AppTypography.helper.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: line.credit > 0
                    ? AppColors.secondary50
                    : line.isPartial
                    ? AppColors.warningBg
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  onTap: line.credit > 0 ? null : onEdit,
                  borderRadius: BorderRadius.circular(11),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: AppMoneyText(
                      Fixed2.toDouble(line.credit > 0 ? line.credit : line.amount),
                      size: AppMoneySize.md,
                      color: line.credit > 0
                          ? AppColors.secondary700
                          : line.isPartial
                          ? AppColors.warningText
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  line.credit > 0
                      ? 'se le devuelve · dejó de más'
                      : line.isPartial
                      ? 'pagó una parte · queda Q${Fixed2.format(line.pending)}'
                      : 'pagó todo · ${line.method.label.toLowerCase()}',
                  style: AppTypography.helper.copyWith(
                    fontSize: 11,
                    color: line.credit > 0
                        ? AppColors.secondary700
                        : line.isPartial
                        ? AppColors.warningText
                        : AppColors.textMuted,
                  ),
                ),
              ),
              if (line.isPartial)
                GestureDetector(
                  onTap: onRemove,
                  child: Text(
                    'cobrar todo',
                    style: AppTypography.helper.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _Tone { info, warning, error }

class _Notice extends StatelessWidget {
  const _Notice({required this.tone, required this.title, required this.message});

  final _Tone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (tone) {
      _Tone.info => (AppColors.secondary50, AppColors.secondary700, Icons.info_outline_rounded),
      _Tone.warning => (AppColors.warningBg, AppColors.warningText, Icons.schedule_rounded),
      _Tone.error => (AppColors.errorBg, AppColors.errorText, Icons.lock_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
                Text(
                  message,
                  style: AppTypography.helper.copyWith(fontSize: 11.5, color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
