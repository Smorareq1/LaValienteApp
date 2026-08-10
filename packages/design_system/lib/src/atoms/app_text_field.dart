import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Campo de texto del sistema.
///
/// Estados: predeterminado, enfocado (borde magenta + anillo), error y
/// deshabilitado — según los átomos del design system.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;

  /// Muestra el botón de mostrar/ocultar contraseña.
  final bool showObscureToggle;
  final Widget? prefixIcon;

  /// Acción pegada al campo: el atajo "CF" del NIT, una unidad, un botón de
  /// escaneo. Va dentro del borde para que se lea como parte del campo.
  final Widget? suffix;

  /// Mayor que 1 convierte el campo en multilínea (dirección, observaciones).
  final int maxLines;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  /// Filtra lo que se puede teclear. Impedir un carácter que después habría que
  /// rechazar con un mensaje sale más barato que el mensaje.
  final List<TextInputFormatter>? inputFormatters;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  late bool _obscured = widget.obscureText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final hasError = widget.errorText != null;

    final Color borderColor;
    double borderWidth = 1.5;
    if (!widget.enabled) {
      borderColor = AppColors.border;
    } else if (hasError) {
      borderColor = AppColors.error;
    } else if (focused) {
      borderColor = AppColors.primary500;
      borderWidth = 2;
    } else {
      borderColor = AppColors.border;
    }

    final iconColor = !widget.enabled
        ? AppColors.gray400
        : hasError
            ? AppColors.error
            : focused
                ? AppColors.primary500
                : AppColors.gray400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: widget.enabled ? AppColors.white : AppColors.gray100,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: focused && widget.enabled && !hasError
            ? const [BoxShadow(color: AppColors.primary100, spreadRadius: 4)]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        // En multilínea el ícono y la acción se alinean con la primera línea,
        // no con el centro de un campo que crece hacia abajo.
        crossAxisAlignment:
            widget.maxLines == 1 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: widget.maxLines == 1 ? 0 : 12),
              child: IconTheme(
                data: IconThemeData(color: iconColor, size: 20),
                child: widget.prefixIcon!,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: _obscured,
              maxLines: _obscured ? 1 : widget.maxLines,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: AppTypography.bodySm.copyWith(
                fontSize: 15,
                color: widget.enabled ? AppColors.textPrimary : AppColors.gray400,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: AppTypography.bodySm.copyWith(
                  fontSize: 15,
                  color: AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(top: widget.maxLines == 1 ? 0 : 6),
              child: widget.suffix!,
            ),
          ],
          if (widget.showObscureToggle)
            IconButton(
              onPressed: () => setState(() => _obscured = !_obscured),
              tooltip: _obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: Icon(
                _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 21,
                color: AppColors.gray500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Deja teclear solo lo que un campo de dos decimales sabe leer: dígitos y un
/// separador decimal. Es más barato impedir la coma de miles que explicarla
/// después con un mensaje de error.
final List<TextInputFormatter> decimalInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];
