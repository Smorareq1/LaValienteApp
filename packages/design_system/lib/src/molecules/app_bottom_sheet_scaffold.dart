import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Estructura común de los formularios en bottom sheet: agarradera, título,
/// contenido con scroll y barra de acciones fija abajo.
///
/// Se abre con [show] para que todas las sheets compartan el mismo alto
/// máximo, el ajuste al teclado y el radio superior.
class AppBottomSheetScaffold extends StatelessWidget {
  const AppBottomSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  /// Botones del pie (normalmente un [Row] con la acción primaria).
  final Widget? actions;

  /// Por defecto cierra la sheet.
  final VoidCallback? onClose;

  /// Abre [builder] como bottom sheet modal con el comportamiento estándar.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      // Deja ver el contexto de atrás sin que la sheet llegue al borde.
      constraints: const BoxConstraints(maxWidth: 640),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Padding(
      // Levanta la sheet cuando aparece el teclado.
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (subtitle != null)
                          Text(subtitle!, style: AppTypography.helper),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.gray500,
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
            ),
            if (actions != null)
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.gray100)),
                ),
                child: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
