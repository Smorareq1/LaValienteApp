import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Anular un pedido (Plan 0006 §5.7).
///
/// El motivo es obligatorio: un pedido anulado sin explicación es uno que nadie
/// va a poder justificar en el cierre. Y se avisa que no se deshace, porque no
/// se deshace: corregir es anular y volver a capturar (plan 0001 §7.3).
class CancelOrderSheet extends StatefulWidget {
  const CancelOrderSheet({super.key, required this.reference});

  final String reference;

  /// Devuelve el motivo, o `null` si se echó atrás.
  static Future<String?> show(BuildContext context, {required String reference}) {
    return AppBottomSheetScaffold.show<String>(
      context: context,
      builder: (context) => CancelOrderSheet(reference: reference),
    );
  }

  @override
  State<CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<CancelOrderSheet> {
  final TextEditingController _reason = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _reason.text.trim();
    if (reason.length < 3) {
      setState(() => _error = 'Escribí por qué se anula');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Anular el pedido ${widget.reference}',
      subtitle: 'Quedará registrado, no se borra',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Mejor no',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Anular pedido',
              icon: const Icon(Icons.block_rounded),
              variant: AppButtonVariant.primary,
              fullWidth: true,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.errorText,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Esto no se puede deshacer. Para corregir un pedido se anula '
                    'y se captura de nuevo. El dinero ya cobrado no se toca: '
                    'devolverlo es un movimiento de caja aparte.',
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.errorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'MOTIVO',
            controller: _reason,
            hintText: 'Ej. el cliente se arrepintió',
            errorText: _error,
            maxLines: 3,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
    );
  }
}
