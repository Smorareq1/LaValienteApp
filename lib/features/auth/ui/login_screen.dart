import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_failure.dart';
import '../state/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'widgets/auth_header.dart';

/// Pantalla de inicio de sesión — screen 06 del design system.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String path = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _identifierError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _identifierError = identifier.isEmpty ? 'Ingresá tu usuario o correo' : null;
      _passwordError = password.isEmpty ? 'Ingresá tu contraseña' : null;
      _formError = null;
    });
    return _identifierError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (_submitting || !_validate()) return;
    setState(() => _submitting = true);

    final failure = await ref.read(authControllerProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _formError = switch (failure) {
        null => null,
        AuthFailure() => 'Usuario o contraseña incorrectos',
        NetworkFailure() => 'Sin conexión con el servidor. Verificá tu red.',
        ValidationFailure(:final message) => message,
        _ => 'Algo salió mal. Intentá de nuevo.',
      };
    });
    // Si el login fue exitoso el auth guard del router redirige a Home.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: '¡Hola de nuevo!',
              subtitle: 'Ingresá para gestionar la lavandería',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, AppSpacing.xl, 26, AppSpacing.lg),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormField(
                      label: 'Usuario o correo',
                      controller: _identifierController,
                      hintText: 'sebasm',
                      errorText: _identifierError,
                      enabled: !_submitting,
                      prefixIcon: const Icon(Icons.person_outline),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppFormField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      errorText: _passwordError,
                      enabled: !_submitting,
                      obscureText: true,
                      showObscureToggle: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _submitting
                            ? null
                            : () => context.push(ForgotPasswordScreen.path),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.primary600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                            const Icon(Icons.error_outline,
                                size: 18, color: AppColors.errorText),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formError!,
                                style: AppTypography.bodySm
                                    .copyWith(color: AppColors.errorText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Iniciar sesión',
                      size: AppButtonSize.lg,
                      fullWidth: true,
                      elevated: true,
                      loading: _submitting,
                      trailingIcon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
