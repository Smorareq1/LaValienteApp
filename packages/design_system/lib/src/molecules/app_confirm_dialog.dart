import 'package:flutter/material.dart';

import '../atoms/app_button.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Diálogo de confirmación, en variante normal y destructiva (Plan 0006 §15).
///
/// La variante destructiva no solo cambia de color: dice en el cuerpo qué pasa
/// después, porque "¿Estás seguro?" no le da a nadie con qué decidir.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.destructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Tiñe de rojo la acción y su ícono.
  final bool destructive;

  final IconData? icon;

  /// Abre el diálogo y responde si se confirmó. Descartarlo tocando fuera
  /// cuenta como cancelar.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
    IconData? icon,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        icon: icon,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? AppColors.errorText : AppColors.primary700;
    final tintBg = destructive ? AppColors.errorBg : AppColors.primary100;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tintBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 25, color: tint),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.helper.copyWith(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ConfirmButton(
                    label: confirmLabel,
                    destructive: destructive,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// La acción destructiva no está en las variantes de [AppButton] porque solo
/// existe aquí: un rojo sólido suelto en una pantalla invita a tocarlo.
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.destructive,
    required this.onPressed,
  });

  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!destructive) {
      return AppButton(label: label, fullWidth: true, onPressed: onPressed);
    }

    return Material(
      color: AppColors.errorText,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.button(fontSize: 14, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
