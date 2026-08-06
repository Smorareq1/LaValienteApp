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
  final Set<String> _noteOpen = {};

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
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AppSearchField(
            hintText: 'Buscar tipo de prenda…',
            onChanged: (value) => setState(() => _query = value),
          ),
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
            noteOpen: _noteOpen.contains(type.id),
            onToggleNote: () => setState(() {
              if (!_noteOpen.remove(type.id)) _noteOpen.add(type.id);
            }),
            onQuantityChanged: (value) => widget.onQuantityChanged(type.id, value),
            onNoteChanged: (value) => widget.onNoteChanged(type.id, value),
          ),
        if (_query.isEmpty && widget.garmentTypes.length > GarmentsSection.visibleByDefault)
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: _showAll
                  ? 'Ver solo las más usadas'
                  : 'Ver los ${widget.garmentTypes.length} tipos de prenda',
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.sm,
              onPressed: () => setState(() => _showAll = !_showAll),
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
    required this.noteOpen,
    required this.onToggleNote,
    required this.onQuantityChanged,
    required this.onNoteChanged,
  });

  final GarmentType type;
  final int quantity;
  final String note;
  final bool noteOpen;
  final VoidCallback onToggleNote;
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
    final hasNote = widget.note.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: counted ? AppColors.primary50 : AppColors.gray50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: counted ? AppColors.primary100 : AppColors.gray100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: counted ? AppColors.primary700 : AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onToggleNote,
                tooltip: 'Nota de esta prenda',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  hasNote
                      ? Icons.sticky_note_2_rounded
                      : Icons.sticky_note_2_outlined,
                  size: 18,
                  color: hasNote ? AppColors.primary500 : AppColors.gray300,
                ),
              ),
              AppStepper(
                value: quantity,
                size: AppStepperSize.md,
                onChanged: widget.onQuantityChanged,
              ),
            ],
          ),
          if (widget.noteOpen || hasNote)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: AppTextField(
                controller: _note,
                hintText: 'Ej. camisa blanca manchada',
                onChanged: widget.onNoteChanged,
              ),
            ),
        ],
      ),
    );
  }
}
