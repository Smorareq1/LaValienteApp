import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/access.dart';
import '../../state/access_controller.dart';

/// Alta de una cuenta (Plan 0006 §12).
///
/// Solo crea. Los roles se reparten después, en la sheet de acceso: son dos
/// decisiones distintas —quién entra y qué puede hacer— y juntarlas obligaría a
/// resolver la segunda con prisa, mientras se teclea una contraseña.
class NewAccountSheet extends ConsumerStatefulWidget {
  const NewAccountSheet({super.key});

  static Future<SystemUser?> show(BuildContext context) {
    return AppBottomSheetScaffold.show<SystemUser>(
      context: context,
      builder: (context) => const NewAccountSheet(),
    );
  }

  @override
  ConsumerState<NewAccountSheet> createState() => _NewAccountSheetState();
}

class _NewAccountSheetState extends ConsumerState<NewAccountSheet> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  String? _emailError;
  String? _phoneError;
  String? _formError;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _username,
      _password,
      _fullName,
      _email,
      _phone,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Las mismas reglas que `identity/schemas.py`, comprobadas aquí para que el
  /// error salga **bajo el campo** (§14) y no como la frase de pydantic sobre un
  /// regex, que no la puede leer nadie de mostrador.
  bool _validate() {
    final username = _username.text.trim();
    final password = _password.text;
    final email = _email.text.trim();
    final phone = _phone.text.trim();

    setState(() {
      _usernameError = switch (username) {
        '' => 'Ponle un usuario',
        _ when !NewAccount.usernamePattern.hasMatch(username) =>
          'Entre 3 y 50 caracteres: empieza con letra y sigue con minúsculas, '
              'números, punto o guion bajo.',
        _ => null,
      };
      _passwordError = password.length < NewAccount.minPasswordLength
          ? 'Al menos ${NewAccount.minPasswordLength} caracteres'
          : null;
      // Solo se exige que parezca un correo si escribieron uno: es opcional.
      _emailError = email.isNotEmpty && !email.contains('@')
          ? 'Eso no parece un correo'
          : null;
      _phoneError = phone.isNotEmpty && !NewAccount.phonePattern.hasMatch(phone)
          ? 'De 8 a 15 dígitos, con o sin código de país'
          : null;
    });

    return _usernameError == null &&
        _passwordError == null &&
        _emailError == null &&
        _phoneError == null;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final result = await ref
        .read(usersAdminControllerProvider.notifier)
        .register(
          NewAccount(
            username: _username.text.trim(),
            password: _password.text,
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
          ),
        );

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (user) {
        Navigator.of(context).pop(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.username} ya puede entrar. Falta darle su rol.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Nueva cuenta',
      subtitle: 'Se guarda en el servidor: esta pantalla necesita señal.',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.secondary,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: AppButton(
              label: 'Crear cuenta',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        children: [
          AppFormField(
            label: 'USUARIO',
            controller: _username,
            hintText: 'mostrador',
            errorText: _usernameError,
            helperText: 'Con esto entra a la app. No se puede cambiar después.',
            textInputAction: TextInputAction.next,
            // El backend guarda el usuario en minúsculas; escribirlo así desde
            // el principio evita que alguien teclee «Marta» y luego no entienda
            // por qué entra con «marta».
            inputFormatters: [_LowerCaseFormatter()],
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'CONTRASEÑA',
            controller: _password,
            obscureText: true,
            showObscureToggle: true,
            errorText: _passwordError,
            helperText:
                'Se la cambia luego desde Ajustes, con el enlace por correo.',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NOMBRE COMPLETO',
            controller: _fullName,
            optional: true,
            hintText: 'Marta González',
            helperText: 'Es lo que se lee en la app; sin él se muestra el usuario.',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'CORREO',
            controller: _email,
            optional: true,
            hintText: 'marta@lavaliente.gt',
            errorText: _emailError,
            helperText:
                'Sin correo no puede recuperar la contraseña sola: habría que '
                'crearle otra cuenta.',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'TELÉFONO',
            controller: _phone,
            optional: true,
            hintText: '55555555',
            errorText: _phoneError,
            keyboardType: TextInputType.phone,
          ),
          if (_formError != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Text(
                _formError!,
                style: AppTypography.bodySm.copyWith(color: AppColors.errorText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LowerCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final lowered = newValue.text.toLowerCase();
    // La selección se conserva tal cual: pasar a minúsculas no cambia el largo,
    // así que el cursor sigue donde estaba.
    return lowered == newValue.text
        ? newValue
        : TextEditingValue(
            text: lowered,
            selection: newValue.selection,
            composing: TextRange.empty,
          );
  }
}
