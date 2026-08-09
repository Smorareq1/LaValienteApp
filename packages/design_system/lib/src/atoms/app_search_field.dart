import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Campo de búsqueda con retardo y botón de limpiar (Plan 0006 §15).
///
/// El retardo no es cosmético: cada pulsación reconstruye la consulta a la BD
/// local, y escribir "González" dispararía ocho consultas de las que solo
/// importa la última.
///
/// Limpiar sí avisa de inmediato — quien toca la ✕ quiere ver la lista
/// completa ya, no dentro de un cuarto de segundo.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.controller,
    this.hintText = 'Buscar…',
    this.debounce = const Duration(milliseconds: 250),
    this.autofocus = false,
    this.backgroundColor = AppColors.white,
  });

  /// Recibe el texto ya reposado.
  final ValueChanged<String> onChanged;

  /// Controlador propio si la pantalla necesita leer o fijar el texto.
  final TextEditingController? controller;

  final String hintText;
  final Duration debounce;
  final bool autofocus;

  /// El fondo de la caja. Gris cuando el campo va dentro de una tarjeta blanca
  /// —así se lee como un control y no como otro renglón del formulario.
  final Color backgroundColor;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _timer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Solo se destruye el controlador que creó este widget.
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_hasText != value.isNotEmpty) {
      setState(() => _hasText = value.isNotEmpty);
    }
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    setState(() => _hasText = false);
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: AppColors.gray400),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _timer?.cancel();
                widget.onChanged(value);
              },
              style: AppTypography.bodySm.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: AppTypography.bodySm.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray400,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              onPressed: _clear,
              tooltip: 'Limpiar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.gray500,
              ),
            ),
        ],
      ),
    );
  }
}
