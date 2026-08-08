import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../auth/state/auth_controller.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/product.dart';
import '../state/shelf_controller.dart';
import 'widgets/product_form_sheet.dart';
import 'widgets/product_image.dart';

/// Insumos (Plan 0006 §8.1).
///
/// Lee del espejo local, así que la estantería se ve igual sin señal. Lo que no
/// se puede sin señal es **cambiarla**: dar de alta un producto o un lote es
/// administración en línea (plan 0005 D11), y esos botones llevan a pantallas
/// que lo dicen.
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  static const String path = '/inventory';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage =
        ref
            .watch(authControllerProvider)
            .valueOrNull
            ?.hasPermission(AppPermissions.inventoryManage) ??
        false;
    // Los archivados solo existen para quien administra: al colaborador le
    // sobran, y el interruptor que los enseña también.
    final showArchived = canManage && ref.watch(inventoryShowArchivedProvider);
    final query = ref.watch(inventorySearchProvider).trim().toLowerCase();
    final products = ref.watch(
      inventoryProductsProvider(includeArchived: showArchived),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(canManage: canManage, showArchived: showArchived),
          Expanded(
            child: switch (products) {
              AsyncError(:final error) => _Failed(error: '$error'),
              AsyncData(:final value) => _Grid(
                products: _filter(value, query),
                hasAny: value.isNotEmpty,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
      // Dar de alta un producto es administración en línea (plan 0005 D11), así
      // que el botón solo existe para quien puede hacerlo.
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => ProductFormSheet.show(context),
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Producto'),
            )
          : null,
    );
  }

  static List<ProductSummary> _filter(
    List<ProductSummary> products,
    String query,
  ) {
    if (query.isEmpty) return products;
    return [
      for (final product in products)
        if (product.name.toLowerCase().contains(query)) product,
    ];
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.canManage, required this.showArchived});

  final bool canManage;
  final bool showArchived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Back(),
              Expanded(
                child: Text(
                  'Insumos',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (canManage)
                _ArchivedToggle(
                  value: showArchived,
                  onTap: () =>
                      ref.read(inventoryShowArchivedProvider.notifier).toggle(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AppSearchField(
            hintText: 'Buscar un producto…',
            onChanged: (value) =>
                ref.read(inventorySearchProvider.notifier).update(value),
          ),
        ],
      ),
    );
  }
}

class _ArchivedToggle extends StatelessWidget {
  const _ArchivedToggle({required this.value, required this.onTap});

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: value ? 0.3 : 0.18),
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.inventory_rounded : Icons.inventory_2_outlined,
                size: 14,
                color: AppColors.white,
              ),
              const SizedBox(width: 7),
              Text(
                'Archivados',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.products, required this.hasAny});

  final List<ProductSummary> products;

  /// Si hay productos en el teléfono, aunque el buscador los esté escondiendo.
  /// Separa "no hay inventario" de "no encontré esto", que se arreglan distinto.
  final bool hasAny;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: AppEmptyState(
          icon: hasAny ? Icons.search_off_rounded : Icons.inventory_2_outlined,
          title: hasAny
              ? 'Ningún producto con ese nombre'
              : 'Todavía no hay insumos',
          message: hasAny
              ? null
              : 'Los productos se dan de alta en línea y bajan a este teléfono en '
                    'la siguiente sincronización.',
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductCard(product: products[index]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => context.push('/inventory/${product.id}'),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProductImage(
                    productId: product.id,
                    name: product.name,
                    imagePath: product.imagePath,
                    size: 46,
                  ),
                  const Spacer(),
                  if (!product.isActive)
                    const AppStatusBadge(
                      label: 'Archivado',
                      tone: AppStatusTone.neutral,
                      size: AppStatusBadgeSize.sm,
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _StockLine(product: product),
              const SizedBox(height: 3),
              Text(
                switch (product.nextSalePrice) {
                  null => product.isInternalOnly ? 'Uso interno' : 'Sin precio',
                  final price => 'Q${Fixed2.format(price)} el ${product.unit}',
                },
                style: AppTypography.helper.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: product.nextSalePrice == null
                      ? AppColors.textSecondary
                      : AppColors.primary700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuánto queda. Un producto agotado se dice con palabras y no con un cero, que
/// se lee como un dato incompleto.
class _StockLine extends StatelessWidget {
  const _StockLine({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    if (product.isSoldOut) {
      return Text(
        'Sin existencias',
        style: AppTypography.bodySm.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.errorText,
        ),
      );
    }

    return Text(
      '${Fixed2.formatQuantity(product.stock)} ${product.unit}'
      '${product.stock == 100 ? '' : 's'} en existencia',
      style: AppTypography.bodySm.copyWith(
        fontSize: 12.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudo leer el inventario',
        message: error,
      ),
    );
  }
}

/// Volver a «Más», de donde se llega a esta pantalla.
class _Back extends StatelessWidget {
  const _Back();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Volver',
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      ),
    );
  }
}
