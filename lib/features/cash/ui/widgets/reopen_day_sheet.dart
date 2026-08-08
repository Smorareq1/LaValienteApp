import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Reabrir un día cerrado (Plan 0006 §7.4).
///
/// El motivo es obligatorio y lo exige también el servidor (mínimo tres
/// caracteres): reabrir no borra el acta, le pone encima un nombre y una razón,
/// y un día cerrado en Q764 que después se reabrió es un hecho que alguien
/// tendrá que explicar (plan 0005 D9).
class ReopenDaySheet extends StatefulWidget {
  const ReopenDaySheet({super.key});

  /// Devuelve el motivo, o `null` si se echó atrás.
  static Future<String?> show(BuildContext context) {
    return AppBottomSheetScaffold.show<String>(
      context: context,
      builder: (context) => const ReopenDaySheet(),
    );
  }

  @override
  State<ReopenDaySheet> createState() => _ReopenDaySheetState();
}

class _ReopenDaySheetState extends State<ReopenDaySheet> {
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
      setState(() => _error = 'Escribí por qué se reabre');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Reabrir el día',
      subtitle: 'El acta queda como rastro, no se borra',
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
              label: 'Reabrir día',
              icon: const Icon(Icons.lock_open_rounded),
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
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.warningText,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'La fecha vuelve a aceptar gastos, cobros y ventas, y el día '
                    'queda pendiente de cerrarse otra vez. El acta anterior se '
                    'conserva con tu nombre y este motivo.',
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warningText,
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
            hintText: 'Ej. faltó anotar el gas',
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
