import 'package:flutter/material.dart';

/// Tokens de color del Design System La Valiente v1.0.
abstract final class AppColors {
  // Marca — Magenta (primario). Base 500.
  static const Color primary50 = Color(0xFFFDF1F8);
  static const Color primary100 = Color(0xFFFCE0EF);
  static const Color primary300 = Color(0xFFF49BCE);
  static const Color primary400 = Color(0xFFEC5AAC);
  static const Color primary500 = Color(0xFFE2168B);
  static const Color primary600 = Color(0xFFC51379);
  static const Color primary700 = Color(0xFFA50E67);
  static const Color primary = primary500;

  // Marca — Cian (secundario). Base 500.
  static const Color secondary50 = Color(0xFFF0FBFF);
  static const Color secondary100 = Color(0xFFE1F6FE);
  static const Color secondary300 = Color(0xFFA9E4F9);
  static const Color secondary400 = Color(0xFF7AD5F6);
  static const Color secondary500 = Color(0xFF49C5F3);
  static const Color secondary600 = Color(0xFF2AA3DC);
  static const Color secondary700 = Color(0xFF1B84B8);
  static const Color secondary = secondary500;

  // Neutros.
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFB);
  static const Color gray100 = Color(0xFFF2F3F6);
  static const Color gray200 = Color(0xFFE5E7EC);
  static const Color gray300 = Color(0xFFC7CBD2);
  static const Color gray400 = Color(0xFF9CA1AC);
  static const Color gray500 = Color(0xFF767C88);
  static const Color gray600 = Color(0xFF565B66);
  static const Color gray800 = Color(0xFF3A3E47);
  static const Color gray900 = Color(0xFF16181D);

  /// Fondo base de la app.
  static const Color background = gray100;
  static const Color surface = white;
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textMuted = gray400;
  static const Color border = gray200;

  // Semánticos (estados de órdenes).
  static const Color success = Color(0xFF17B26A);
  static const Color successBg = Color(0xFFDCFAE6);
  static const Color successText = Color(0xFF067647);

  static const Color warning = Color(0xFFF79009);
  static const Color warningBg = Color(0xFFFEF0D9);
  static const Color warningText = Color(0xFFB54708);

  static const Color error = Color(0xFFF04438);
  static const Color errorBg = Color(0xFFFEE4E2);
  static const Color errorText = Color(0xFFB42318);

  static const Color info = secondary500;
  static const Color infoBg = secondary100;
  static const Color infoText = secondary700;
}
