import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../core/database/search_text.dart';
import '../../../catalog/models/catalog.dart';

/// Sección [3] de la boleta: qué prendas entran (plan 0002 §3.3).
///
/// Los 21 tipos de la boleta no caben en pantalla, así que se muestran primero
/// los que ya tienen cantidad y un puñado más; el resto se despliega o se busca.
/// El total de piezas no se digita nunca: se suma solo, porque es el número que
/// en papel más se equivoca.
class GarmentsSection extends StatefulWidget {
  const GarmentsSection({
    super.key,
    required this.garmentTypes,
    required this.quantities,
    required this.notes,
    required this.onQuantityChanged,
    required this.onNoteChanged,
  });

  final List<GarmentType> garmentTypes;
  final Map<String, int> quantities;
  final Map<String, String> notes;
  final void Function(String garmentTypeId, int quantity) onQuantityChanged;
  final void Function(String garmentTypeId, String note) onNoteChanged;

  /// Cuántos tipos se muestran antes de tener que desplegar la lista completa.
  static const int visibleByDefault = 8;

  @override
  State<GarmentsSection> createState() => _GarmentsSectionState();
}

class _GarmentsSectionState extends State<GarmentsSection> {
  String _query = '';
  bool _showAll = false;

  List<GarmentType> get _visible {
    final needle = normalizeForSearch(_query);
    if (needle.isNotEmpty) {
      return widget.garmentTypes
          .where((type) => normalizeForSearch(type.name).contains(needle))
          .toList();
    }
    if (_showAll) return widget.garmentTypes;

    // Las que ya tienen cantidad no se pueden esconder: acortar la lista no
    // puede ocultar lo que la persona ya contó.
    final withQuantity = widget.garmentTypes
        .where((type) => (widget.quantities[type.id] ?? 0) > 0)
        .toList();
    final rest = widget.garmentTypes
        .where((type) => (widget.quantities[type.id] ?? 0) == 0)
        .take(GarmentsSection.visibleByDefault)
        .toList();
    return [...withQuantity, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.garmentTypes.isEmpty) {
      return Text(
        'El catálogo de prendas todavía no ha bajado a este dispositivo. '
        'Sincronizá y volvé a intentar.',
        style: AppTypography.helper.copyWith(fontSize: 12),
      );
    }

    final visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          hintText: 'Buscar prenda…',
          backgroundColor: AppColors.gray100,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          Text(
            'Ningún tipo de prenda con ese nombre.',
            style: AppTypography.helper.copyWith(fontSize: 12),
          ),
        for (final type in visible)
          _GarmentRow(
            // Sin la llave, filtrar la lista dejaría la nota de una prenda en la
            // fila que ocupe su lugar.
            key: ValueKey(type.id),
            type: type,
            quantity: widget.quantities[type.id] ?? 0,
            note: widget.notes[type.id] ?? '',
            onQuantityChanged: (value) => widget.onQuantityChanged(type.id, value),
            onNoteChanged: (value) => widget.onNoteChanged(type.id, value),
          ),
        if (_query.isEmpty && widget.garmentTypes.length > GarmentsSection.visibleByDefault)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Center(
              child: AppButton(
                label: _showAll
                    ? 'Ver solo las más usadas'
                    : 'Ver los ${widget.garmentTypes.length} tipos de prenda',
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                onPressed: () => setState(() => _showAll = !_showAll),
              ),
            ),
          ),
      ],
    );
  }
}

class _GarmentRow extends StatefulWidget {
  const _GarmentRow({
    super.key,
    required this.type,
    required this.quantity,
    required this.note,
    required this.onQuantityChanged,
    required this.onNoteChanged,
  });

  final GarmentType type;
  final int quantity;
  final String note;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String> onNoteChanged;

  @override
  State<_GarmentRow> createState() => _GarmentRowState();
}

class _GarmentRowState extends State<_GarmentRow> {
  // El controlador nace con la nota que ya había y no se vuelve a fijar desde
  // fuera: reconstruir el texto en cada `build` mandaría el cursor al inicio a
  // media palabra.
  late final TextEditingController _note = TextEditingController(text: widget.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final quantity = widget.quantity;
    final counted = quantity > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 7, 9, 7),
          decoration: BoxDecoration(
            color: counted ? AppColors.primary50 : AppColors.gray50,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: counted ? AppColors.primary100 : AppColors.gray100,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  type.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AppStepper(
                value: quantity,
                size: AppStepperSize.md,
                onChanged: widget.onQuantityChanged,
              ),
            ],
          ),
        ),
        // La nota aparece sola en cuanto la prenda entra al pedido: es donde va
        // "camisa blanca manchada", y esconderla tras un botón hace que nadie la
        // escriba.
        if (counted)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _NoteField(controller: _note, onChanged: widget.onNoteChanged),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// La nota de una prenda: borde punteado magenta sobre fondo rosa, para que se
/// lea como un apunte al margen y no como otro campo del formulario.
class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppDashedBox(
      radius: 11,
      backgroundColor: AppColors.primary50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.bodySm.copyWith(fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Nota (ej. camisa blanca manchada)',
            hintStyle: AppTypography.bodySm.copyWith(
              fontSize: 12,
              color: AppColors.gray400,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}
