import 'package:flutter/material.dart';

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
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
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
        children: [
          if (widget.prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: iconColor, size: 20),
              child: widget.prefixIcon!,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: _obscured,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
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
