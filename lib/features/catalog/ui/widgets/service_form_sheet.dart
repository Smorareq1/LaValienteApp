import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog.dart';
import '../../models/catalog_admin.dart';
import '../../state/catalog_admin_controller.dart';

/// Editar un servicio (Plan 0006 §10.1).
///
/// Solo el nombre, la unidad y si está encendido. **El código y la modalidad no
/// se tocan**: el código es a lo que apunta cada pedido ya tomado, y la
/// modalidad decide cómo se cobra —cambiarla dejaría boletas viejas calculadas
/// con una regla que ya no existe—. Un servicio con otra modalidad es un
/// servicio nuevo.
class ServiceFormSheet extends ConsumerStatefulWidget {
  const ServiceFormSheet({super.key, required this.service});

  final AdminService service;

  static Future<AdminService?> show(
    BuildContext context, {
    required AdminService service,
  }) {
    return AppBottomSheetScaffold.show<AdminService>(
      context: context,
      builder: (context) => ServiceFormSheet(service: service),
    );
  }

  @override
  ConsumerState<ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<ServiceFormSheet> {
  late final _name = TextEditingController(text: widget.service.name);
  late final _unitLabel = TextEditingController(
    text: widget.service.unitLabel ?? '',
  );

  late bool _isActive = widget.service.isActive;

  String? _nameError;
  String? _formError;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _unitLabel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    setState(() => _nameError = name.isEmpty ? 'Ponle un nombre' : null);
    if (_nameError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final unitLabel = _unitLabel.text.trim();
    final result = await ref
        .read(servicesAdminControllerProvider.notifier)
        .edit(
          widget.service.id,
          name: name,
          unitLabel: unitLabel.isEmpty ? null : unitLabel,
          isActive: _isActive,
        );

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (service) {
        ref.invalidate(adminServiceProvider(widget.service.id));
        Navigator.of(context).pop(service);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: 'Editar ${widget.service.name}',
      subtitle: 'El código y la modalidad no se cambian.',
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
              label: 'Guardar',
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
            label: 'NOMBRE',
            controller: _name,
            errorText: _nameError,
            textInputAction: TextInputAction.next,
          ),
          if (widget.service.pricingMode == PricingMode.perUnit) ...[
            const SizedBox(height: 14),
            AppFormField(
              label: 'UNIDAD',
              controller: _unitLabel,
              optional: true,
              hintText: 'libra',
              helperText: 'Se lee como «Q12.50 por libra».',
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isActive ? 'Se ofrece' : 'Apagado',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _isActive
                            ? 'Aparece al tomar un pedido.'
                            : 'Deja de aparecer; los pedidos que lo usan lo conservan.',
                        style: AppTypography.helper.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
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
