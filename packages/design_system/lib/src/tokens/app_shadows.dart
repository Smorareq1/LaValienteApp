import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Tokens de elevación.
abstract final class AppShadows {
  /// Sombra sutil para tarjetas planas.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1416181D),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  /// Sombra media para tarjetas elevadas.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x2E16181D),
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -8,
    ),
  ];

  /// Sombra de marca (magenta) para elementos destacados.
  static const List<BoxShadow> brand = [
    BoxShadow(
      color: Color(0x66E2168B),
      offset: Offset(0, 18),
      blurRadius: 40,
      spreadRadius: -14,
    ),
  ];

  /// Glow del botón primario.
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: Color(0x99E2168B),
      offset: Offset(0, 14),
      blurRadius: 28,
      spreadRadius: -10,
    ),
  ];

  /// Anillo de foco para inputs (equivale a `box-shadow: 0 0 0 4px primary100`).
  static const List<BoxShadow> focusRing = [
    BoxShadow(color: AppColors.primary100, spreadRadius: 4),
  ];
}
