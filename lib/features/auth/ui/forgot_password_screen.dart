import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_failure.dart';
import '../data/auth_repository.dart';
import 'reset_password_screen.dart';
import 'widgets/auth_header.dart';

/// Paso 1 de la recuperación: solicitar el código con usuario o correo.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String path = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();

  bool _submitting = false;
  String? _identifierError;
  String? _formError;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifierController.text.trim();
    setState(() {
      _identifierError = identifier.isEmpty ? 'Ingresá tu usuario o correo' : null;
      _formError = null;
    });
    if (_submitting || _identifierError != null) return;
    setState(() => _submitting = true);

    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(identifier: identifier);

    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => setState(() {
        _formError = switch (failure) {
          NetworkFailure() => 'Sin conexión con el servidor. Verificá tu red.',
          _ => 'No se pudo enviar el código. Intentá de nuevo.',
        };
      }),
      (_) => context.pushReplacement(ResetPasswordScreen.path, extra: identifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: 'Recuperar contraseña',
              subtitle: 'Te enviaremos un código para restablecerla',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, AppSpacing.xl, 26, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormField(
                    label: 'Usuario o correo',
                    controller: _identifierController,
                    hintText: 'sebasm',
                    errorText: _identifierError,
                    helperText: 'Si la cuenta existe, recibirás un código de 6 dígitos.',
                    enabled: !_submitting,
                    prefixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.username],
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 18, color: AppColors.errorText),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formError!,
                              style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Enviar código',
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    elevated: true,
                    loading: _submitting,
                    trailingIcon: const Icon(Icons.send_rounded),
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Ya tengo un código',
                    variant: AppButtonVariant.outline,
                    fullWidth: true,
                    onPressed: _submitting
                        ? null
                        : () => context.pushReplacement(
                              ResetPasswordScreen.path,
                              extra: _identifierController.text.trim(),
                            ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Volver a iniciar sesión',
                    variant: AppButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: _submitting ? null : () => context.pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
