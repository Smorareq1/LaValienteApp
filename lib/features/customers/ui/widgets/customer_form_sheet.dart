import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../data/customers_repository.dart';
import '../../models/customer.dart';

/// Alta y edición de un cliente (Plan 0006 §6.3).
///
/// Solo el nombre es obligatorio. Es deliberado: el mostrador captura mientras
/// alguien espera con la ropa en la mano, y exigir el teléfono ahí llevaría a
/// que se inventaran números para poder seguir.
class CustomerFormSheet extends ConsumerStatefulWidget {
  const CustomerFormSheet({super.key, this.customer});

  /// `null` para dar de alta; con valor, edita ese cliente.
  final Customer? customer;

  /// Abre la sheet y devuelve el cliente guardado, o `null` si se canceló.
  static Future<Customer?> show(BuildContext context, {Customer? customer}) {
    return AppBottomSheetScaffold.show<Customer>(
      context: context,
      builder: (context) => CustomerFormSheet(customer: customer),
    );
  }

  @override
  ConsumerState<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<CustomerFormSheet> {
  late final _name = TextEditingController(text: widget.customer?.fullName ?? '');
  late final _phone = TextEditingController(text: widget.customer?.phone ?? '');
  late final _nit = TextEditingController(text: widget.customer?.nit ?? '');
  late final _email = TextEditingController(text: widget.customer?.email ?? '');
  late final _address = TextEditingController(text: widget.customer?.address ?? '');
  late final _notes = TextEditingController(text: widget.customer?.notes ?? '');

  String? _nameError;
  String? _formError;
  bool _saving = false;

  bool get _isEditing => widget.customer != null;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _nit, _email, _address, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      setState(() => _nameError = 'Escribe el nombre del cliente');
      return;
    }

    setState(() {
      _nameError = null;
      _formError = null;
      _saving = true;
    });

    final repository = ref.read(customersRepositoryProvider);
    final existing = widget.customer;
    final result = existing == null
        ? await repository.create(
            fullName: _name.text,
            phone: _phone.text,
            nit: _nit.text,
            email: _email.text,
            address: _address.text,
            notes: _notes.text,
          )
        : await repository.update(
            existing,
            fullName: _name.text,
            phone: _phone.text,
            nit: _nit.text,
            email: _email.text,
            address: _address.text,
            notes: _notes.text,
          );

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        // La validación del nombre es la única que la app conoce; cualquier
        // otro fallo es de la BD local y no pertenece a ningún campo.
        if (failure is ValidationFailure) {
          _nameError = failure.message;
        } else {
          _formError = failure.message;
        }
      }),
      (customer) => Navigator.of(context).pop(customer),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: _isEditing ? 'Editar cliente' : 'Nuevo cliente',
      subtitle: 'Solo el nombre es obligatorio',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancelar',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: AppButton(
              label: _isEditing ? 'Guardar cambios' : 'Guardar cliente',
              icon: const Icon(Icons.check_rounded),
              fullWidth: true,
              elevated: true,
              loading: _saving,
              onPressed: _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            label: 'NOMBRE COMPLETO',
            controller: _name,
            hintText: 'Ej. Sandra Chávez',
            errorText: _nameError,
            prefixIcon: const Icon(Icons.person_outline),
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'TELÉFONO',
            controller: _phone,
            hintText: '0000-0000',
            helperText: 'Casi siempre se pide: es como se avisa que ya está listo',
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NIT',
            controller: _nit,
            hintText: '1234567-8',
            optional: true,
            prefixIcon: const Icon(Icons.receipt_long_outlined),
            textInputAction: TextInputAction.next,
            suffix: _CfButton(onPressed: () => _nit.text = 'CF'),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'CORREO',
            controller: _email,
            hintText: 'nombre@correo.com',
            optional: true,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'DIRECCIÓN',
            controller: _address,
            hintText: 'Calle, zona, referencia…',
            optional: true,
            maxLines: 3,
            prefixIcon: const Icon(Icons.place_outlined),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NOTAS',
            controller: _notes,
            hintText: 'Preferencias, horarios, lo que haya que recordar',
            optional: true,
            maxLines: 3,
            prefixIcon: const Icon(Icons.sticky_note_2_outlined),
          ),
          if (_formError != null) ...[
            const SizedBox(height: 14),
            _FormError(message: _formError!),
          ],
        ],
      ),
    );
  }
}

/// Atajo al NIT de consumidor final, que es el que se teclea todo el día.
class _CfButton extends StatelessWidget {
  const _CfButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary100,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Text(
            'CF',
            style: AppTypography.button(fontSize: 12.5, color: AppColors.primary700),
          ),
        ),
      ),
    );
  }
}

class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.errorText),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.errorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
