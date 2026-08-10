import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tokens tipográficos: Poppins para títulos, Nunito para texto y UI.
abstract final class AppTypography {
  /// Display · Poppins 800 · 34.
  static TextStyle get display => GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  /// Título H2 · Poppins 700 · 24.
  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Subtítulo H3 · Poppins 600 · 18.
  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Cuerpo · Nunito 600 · 16.
  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Cuerpo pequeño · Nunito 600 · 14.
  static TextStyle get bodySm => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Etiqueta de campo · Nunito 700 · 13.
  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.gray800,
      );

  /// Etiqueta / caption · Nunito 700 · 12 · mayúsculas.
  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.gray500,
      );

  /// Texto de ayuda · Nunito 600 · 12.
  static TextStyle get helper => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );

  /// Cifra monetaria · Poppins 800 · interlineado 1 para que las cifras
  /// grandes no arrastren espacio de más dentro de las tarjetas.
  static TextStyle money({double fontSize = 16, Color color = AppColors.textPrimary}) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1,
        color: color,
      );

  /// Texto de botón · Poppins 700.
  static TextStyle button({double fontSize = 14, Color color = AppColors.white}) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static String get headingFontFamily => GoogleFonts.poppins().fontFamily!;
  static String get bodyFontFamily => GoogleFonts.nunito().fontFamily!;
}
