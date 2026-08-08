import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog_admin.dart';
import '../../state/catalog_admin_controller.dart';

/// Alta y edición de un tipo de prenda (Plan 0006 §10.2).
///
/// Es lo más simple del catálogo: un nombre. Los 21 de la boleta vienen
/// sembrados y esto existe para el 22.º —la prenda que aparece una vez y hay que
/// poder anotar sin esperar a nadie.
class GarmentFormSheet extends ConsumerStatefulWidget {
  const GarmentFormSheet({super.key, this.garment});

  /// `null` para crear.
  final AdminGarment? garment;

  static Future<AdminGarment?> show(BuildContext context, {AdminGarment? garment}) {
    return AppBottomSheetScaffold.show<AdminGarment>(
      context: context,
      builder: (context) => GarmentFormSheet(garment: garment),
    );
  }

  @override
  ConsumerState<GarmentFormSheet> createState() => _GarmentFormSheetState();
}

class _GarmentFormSheetState extends ConsumerState<GarmentFormSheet> {
  late final _name = TextEditingController(text: widget.garment?.name ?? '');
  late final _notes = TextEditingController(text: widget.garment?.notes ?? '');

  late bool _isActive = widget.garment?.isActive ?? true;

  String? _nameError;
  String? _formError;
  bool _saving = false;

  bool get _isEditing => widget.garment != null;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Ponle el nombre con que se anota' : null;
    });
    if (_nameError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final notes = _notes.text.trim();
    final controller = ref.read(garmentsAdminControllerProvider.notifier);
    final result = _isEditing
        ? await controller.edit(
            widget.garment!.id,
            name: name,
            notes: notes.isEmpty ? null : notes,
            sortOrder: widget.garment!.sortOrder,
            isActive: _isActive,
          )
        : await controller.create(name: name, notes: notes.isEmpty ? null : notes);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (garment) => Navigator.of(context).pop(garment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetScaffold(
      title: _isEditing ? 'Editar ${widget.garment!.name}' : 'Nueva prenda',
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
              label: _isEditing ? 'Guardar' : 'Crear prenda',
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
            hintText: 'Edredón matrimonial',
            errorText: _nameError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'NOTAS',
            controller: _notes,
            optional: true,
            maxLines: 2,
            hintText: 'Lo que haya que recordar al recibirla.',
          ),
          if (_isEditing) ...[
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
                          _isActive ? 'Se ofrece' : 'Apagada',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _isActive
                              ? 'Aparece al tomar un pedido.'
                              : 'Deja de aparecer; los pedidos que la usan la conservan.',
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
          ],
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
