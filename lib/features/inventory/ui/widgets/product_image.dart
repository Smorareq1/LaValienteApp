import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_image_cache.dart';

/// La foto de un producto, o su inicial mientras no haya foto.
///
/// El respaldo no es un hueco gris: es la inicial sobre el color de marca, que
/// es lo que ya se enseñaba en la venta de insumo desde UI 6. Un producto sin
/// foto tiene que verse deliberado, no roto.
class ProductImage extends ConsumerWidget {
  const ProductImage({
    super.key,
    required this.productId,
    required this.name,
    this.imagePath,
    this.size = 56,
    this.radius = 16,
  });

  final String productId;
  final String name;
  final String? imagePath;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = _Initial(name: name, size: size, radius: radius);
    if (imagePath == null || imagePath!.isEmpty) return placeholder;

    return FutureBuilder<File?>(
      future: ref
          .watch(productImageCacheProvider)
          .fileFor(productId: productId, imagePath: imagePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) return placeholder;
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            // Un archivo a medio escribir o corrupto no puede tumbar la lista.
            errorBuilder: (context, _, _) => placeholder,
          ),
        );
      },
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.size, required this.radius});

  final String name;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        letter,
        style: AppTypography.h3.copyWith(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          color: AppColors.primary700,
        ),
      ),
    );
  }
}
