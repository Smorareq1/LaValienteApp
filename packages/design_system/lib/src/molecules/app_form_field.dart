import 'package:flutter/material.dart';

import '../atoms/app_text_field.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Molécula de campo de formulario: etiqueta + input + texto de ayuda o error.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.optional = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final bool showObscureToggle;
  final Widget? prefixIcon;
  final Widget? suffix;
  final int maxLines;

  /// Añade "· opcional" a la etiqueta. Marcar lo opcional en vez de lo
  /// obligatorio deja los formularios largos con menos ruido.
  final bool optional;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (optional)
          Text.rich(
            TextSpan(
              text: label,
              children: [
                TextSpan(
                  text: ' · opcional',
                  style: AppTypography.helper.copyWith(fontSize: 11),
                ),
              ],
            ),
            style: AppTypography.label,
          )
        else
          Text(label, style: AppTypography.label),
        const SizedBox(height: 7),
        AppTextField(
          controller: controller,
          hintText: hintText,
          errorText: errorText,
          enabled: enabled,
          obscureText: obscureText,
          showObscureToggle: showObscureToggle,
          prefixIcon: prefixIcon,
          suffix: suffix,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTypography.helper.copyWith(color: AppColors.error),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText!, style: AppTypography.helper),
        ],
      ],
    );
  }
}
