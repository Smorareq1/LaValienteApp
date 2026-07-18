import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Gradientes de marca — solo para acentos y cabeceras.
abstract final class AppGradients {
  /// linear-gradient(120deg, #E2168B, #49C5F3).
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary500, AppColors.secondary500],
  );

  /// Cabecera de autenticación:
  /// linear-gradient(135deg, #E2168B 0%, #C51379 45%, #49C5F3 130%).
  static const LinearGradient authHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary500, AppColors.primary600, AppColors.secondary500],
    stops: [0.0, 0.45, 1.3],
  );

  /// Cabecera de app bar: linear-gradient(120deg, #E2168B, #C51379).
  static const LinearGradient appBar = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary500, AppColors.primary600],
  );
}
