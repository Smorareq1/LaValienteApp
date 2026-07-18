import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_gradients.dart';
import '../tokens/app_typography.dart';

enum AppAvatarStyle { brand, primary, secondary, neutral }

/// Avatar circular con iniciales.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.style = AppAvatarStyle.primary,
    this.size = 44,
  });

  final String initials;
  final AppAvatarStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (Gradient? gradient, Color? background, Color foreground) = switch (style) {
      AppAvatarStyle.brand => (AppGradients.brand, null, AppColors.white),
      AppAvatarStyle.primary => (null, AppColors.primary100, AppColors.primary700),
      AppAvatarStyle.secondary => (null, AppColors.secondary100, AppColors.secondary700),
      AppAvatarStyle.neutral => (null, AppColors.gray100, AppColors.gray500),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        gradient: gradient,
      ),
      child: Text(
        initials,
        style: AppTypography.button(fontSize: size * 0.36, color: foreground)
            .copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
