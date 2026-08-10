import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_failure.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';
import 'widgets/auth_header.dart';

/// Paso 2 de la recuperación: canjear el código de 6 dígitos por una nueva
/// contraseña.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialIdentifier});

  static const String path = '/reset-password';

  /// Usuario o correo con el que se pidió el código (prellenado desde el paso 1).
  final String? initialIdentifier;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final _identifierController =
      TextEditingController(text: widget.initialIdentifier ?? '');
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  String? _identifierError;
  String? _codeError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  static final _codeRegex = RegExp(r'^[0-9]{6}$');

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final identifier = _identifierController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _identifierError = identifier.isEmpty ? 'Ingresá tu usuario o correo' : null;
      _codeError = !_codeRegex.hasMatch(code) ? 'Ingresá el código de 6 dígitos' : null;
      _passwordError =
          password.length < 8 ? 'La contraseña debe tener al menos 8 caracteres' : null;
      _confirmError =
          _confirmController.text != password ? 'Las contraseñas no coinciden' : null;
      _formError = null;
    });
    return _identifierError == null &&
        _codeError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _submit() async {
    if (_submitting || !_validate()) return;
    setState(() => _submitting = true);

    final result = await ref.read(authRepositoryProvider).resetPassword(
          identifier: _identifierController.text.trim(),
          code: _codeController.text.trim(),
          newPassword: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => setState(() {
        _formError = switch (failure) {
          AuthFailure() => 'Código inválido o vencido. Pedí uno nuevo.',
          NetworkFailure() => 'Sin conexión con el servidor. Verificá tu red.',
          TimeoutFailure() => 'El servidor tardó demasiado. Probá de nuevo.',
          ValidationFailure(:final message) => message,
          _ => 'Algo salió mal. Intentá de nuevo.',
        };
      }),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada. Iniciá sesión con la nueva.'),
          ),
        );
        context.go(LoginScreen.path);
      },
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
              title: 'Nueva contraseña',
              subtitle: 'Ingresá el código que recibiste y tu nueva contraseña',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, AppSpacing.xl, 26, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormField(
                    label: 'Usuario o correo',
                    controller: _identifierController,
                    errorText: _identifierError,
                    enabled: !_submitting,
                    prefixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    label: 'Código de verificación',
                    controller: _codeController,
                    hintText: '123456',
                    errorText: _codeError,
                    enabled: !_submitting,
                    prefixIcon: const Icon(Icons.pin_outlined),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.oneTimeCode],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    label: 'Nueva contraseña',
                    controller: _passwordController,
                    errorText: _passwordError,
                    helperText: 'Mínimo 8 caracteres.',
                    enabled: !_submitting,
                    obscureText: true,
                    showObscureToggle: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    label: 'Confirmar contraseña',
                    controller: _confirmController,
                    errorText: _confirmError,
                    enabled: !_submitting,
                    obscureText: true,
                    showObscureToggle: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    textInputAction: TextInputAction.done,
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
                    label: 'Restablecer contraseña',
                    size: AppButtonSize.lg,
                    fullWidth: true,
                    elevated: true,
                    loading: _submitting,
                    trailingIcon: const Icon(Icons.check_rounded),
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Volver a iniciar sesión',
                    variant: AppButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: _submitting ? null : () => context.go(LoginScreen.path),
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
