import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/inventory_remote_datasource.dart';
import '../../models/product.dart';
import '../../state/inventory_admin_controller.dart';
import 'product_image.dart';

/// Alta y edición de un producto (Plan 0006 §8.3).
///
/// **En línea.** Un producto nuevo tiene que existir arriba antes de que nadie
/// le registre un lote, y la foto se cuelga de un id que el servidor ya conoce.
class ProductFormSheet extends ConsumerStatefulWidget {
  const ProductFormSheet({super.key, this.product});

  /// `null` para crear.
  final ProductSummary? product;

  /// Las que trae la hoja de compras. Texto libre igual: la unidad la decide
  /// el proveedor y aparece una nueva cada tanto.
  static const List<String> unitSuggestions = ['bote', 'bolsa', 'galón', 'saco'];

  static Future<ProductSummary?> show(
    BuildContext context, {
    ProductSummary? product,
  }) {
    return AppBottomSheetScaffold.show<ProductSummary>(
      context: context,
      builder: (context) => ProductFormSheet(product: product),
    );
  }

  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _unit = TextEditingController(text: widget.product?.unit ?? '');
  late final _description = TextEditingController(
    text: widget.product?.description ?? '',
  );

  late bool _isActive = widget.product?.isActive ?? true;

  Uint8List? _image;
  String? _nameError;
  String? _unitError;
  String? _imageError;
  String? _formError;
  bool _picking = false;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  /// El tope del servidor. Se comprueba aquí para no gastar la subida en un
  /// archivo que va a rebotar.
  static const int _maxImageBytes = 5 * 1024 * 1024;

  @override
  void dispose() {
    for (final controller in [_name, _unit, _description]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Uint8List?> _pick(AppImageSource source) async {
    setState(() {
      _picking = true;
      _imageError = null;
    });
    try {
      final bytes = await ref.read(productImagePickerProvider).pick(source);
      if (!mounted) return null;
      if (bytes != null && bytes.lengthInBytes > _maxImageBytes) {
        setState(() => _imageError = 'La foto pasa de 5 MB. Prueba con otra.');
        return null;
      }
      if (bytes != null) setState(() => _image = bytes);
      return bytes;
    } catch (error) {
      if (mounted) setState(() => _imageError = 'No se pudo abrir la cámara: $error');
      return null;
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final unit = _unit.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Ponle el nombre con que se pide' : null;
      _unitError = unit.isEmpty ? '¿En qué se mide? Bote, bolsa, galón…' : null;
    });
    if (_nameError != null || _unitError != null) return;

    setState(() {
      _saving = true;
      _formError = null;
    });

    final description = _description.text.trim();
    final input = ProductInput(
      name: name,
      unit: unit,
      description: description.isEmpty ? null : description,
      isActive: _isActive,
    );

    final controller = ref.read(inventoryAdminControllerProvider.notifier);
    final result = _isEditing
        ? await controller.editProduct(widget.product!.id, input, image: _image)
        : await controller.createProduct(input, image: _image);

    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _saving = false;
        _formError = failure.message;
      }),
      (product) => Navigator.of(context).pop(product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.product;

    return AppBottomSheetScaffold(
      title: _isEditing ? 'Editar ${existing!.name}' : 'Nuevo producto',
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
              label: _isEditing ? 'Guardar' : 'Crear producto',
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
          AppImagePicker(
            bytes: _image,
            busy: _picking,
            errorText: _imageError,
            onPick: _pick,
            onRemove: _image == null ? null : () => setState(() => _image = null),
            placeholder: existing == null
                ? null
                : ProductImage(
                    productId: existing.id,
                    name: existing.name,
                    imagePath: existing.imagePath,
                    size: 108,
                    radius: 0,
                  ),
          ),
          const SizedBox(height: 16),
          AppFormField(
            label: 'NOMBRE',
            controller: _name,
            hintText: 'Jabón en polvo',
            errorText: _nameError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'UNIDAD',
            controller: _unit,
            hintText: 'bolsa',
            errorText: _unitError,
            helperText: 'Cómo se cuenta en la estantería, no cómo se pesa.',
          ),
          const SizedBox(height: 8),
          _UnitSuggestions(
            onPick: (unit) => setState(() {
              _unit.text = unit;
              _unitError = null;
            }),
          ),
          const SizedBox(height: 14),
          AppFormField(
            label: 'DESCRIPCIÓN',
            controller: _description,
            optional: true,
            maxLines: 3,
            hintText: 'Marca, presentación, lo que ayude a no confundirlo.',
          ),
          if (_isEditing) ...[
            const SizedBox(height: 14),
            _ArchiveSwitch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
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

class _UnitSuggestions extends StatelessWidget {
  const _UnitSuggestions({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final unit in ProductFormSheet.unitSuggestions)
          AppChip(label: unit, onTap: () => onPick(unit)),
      ],
    );
  }
}

/// Archivar no borra: los lotes, el kardex y las ventas de meses pasados
/// apuntan a este producto.
class _ArchiveSwitch extends StatelessWidget {
  const _ArchiveSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  value ? 'En uso' : 'Archivado',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value
                      ? 'Se ofrece en el mostrador y se le pueden registrar lotes.'
                      : 'Sale del mostrador; su historial y sus lotes se conservan.',
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
