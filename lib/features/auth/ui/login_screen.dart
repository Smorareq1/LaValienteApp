import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../state/auth_controller.dart';
import 'widgets/auth_header.dart';

/// Pantalla de inicio de sesión — screen 06 del design system.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String path = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _emailError = email.isEmpty
          ? 'Ingresá tu correo'
          : !_emailRegex.hasMatch(email)
              ? 'Ingresá un correo válido'
              : null;
      _passwordError = password.isEmpty ? 'Ingresá tu contraseña' : null;
      _formError = null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (_submitting || !_validate()) return;
    setState(() => _submitting = true);

    final failure = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _formError = switch (failure) {
        null => null,
        AuthFailure() => 'Correo o contraseña incorrectos',
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
                      label: 'Correo electrónico',
                      controller: _emailController,
                      hintText: 'usuario@lavaliente.gt',
                      errorText: _emailError,
                      enabled: !_submitting,
                      prefixIcon: const Icon(Icons.person_outline),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
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
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.gray400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '¿Problemas para entrar? Contactá al administrador',
                            style: AppTypography.helper,
                          ),
                        ),
                      ],
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
