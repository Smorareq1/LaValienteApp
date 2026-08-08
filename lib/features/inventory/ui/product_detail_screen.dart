import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../models/product.dart';
import '../state/shelf_controller.dart';
import 'widgets/product_image.dart';

/// Detalle de un producto (Plan 0006 §8.2).
///
/// Tres bloques: qué es, qué lotes tiene y de dónde salió cada movimiento. El
/// kardex es la parte que importa —es lo que deja **explicar** un stock— y por
/// eso baja por el feed en vez de consultarse: un lote que amaneció con menos es
/// un número sin historia si el teléfono no tiene los movimientos.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  static const String path = '/inventory/:id';

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  /// `null` = todos. El filtro del kardex que pide el §8.2.
  MovementType? _filter;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(detail.valueOrNull?.product.name ?? 'Producto'),
      ),
      body: switch (detail) {
        AsyncError(:final error) => _Failed(error: '$error'),
        AsyncData(value: null) => const _Gone(),
        AsyncData(:final value?) => _Body(
          detail: value,
          filter: _filter,
          onFilter: (type) => setState(() => _filter = type),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.detail,
    required this.filter,
    required this.onFilter,
  });

  final ProductDetail detail;
  final MovementType? filter;
  final ValueChanged<MovementType?> onFilter;

  @override
  Widget build(BuildContext context) {
    final movements = [
      for (final movement in detail.movements)
        if (filter == null || movement.type == filter) movement,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _Head(product: detail.product),
        const SizedBox(height: 18),
        const AppSectionHeader(title: 'Lotes'),
        const SizedBox(height: 9),
        if (detail.lots.isEmpty)
          const _Nothing(
            message:
                'Este producto no tiene lotes. El stock entra registrando una '
                'compra, que es lo que le da precio y fecha.',
          )
        else
          for (final lot in detail.lots) ...[
            _LotRow(lot: lot, unit: detail.product.unit),
            const SizedBox(height: 7),
          ],
        const SizedBox(height: 12),
        const AppSectionHeader(title: 'Movimientos'),
        const SizedBox(height: 9),
        _TypeFilter(value: filter, onChanged: onFilter),
        const SizedBox(height: 10),
        if (movements.isEmpty)
          _Nothing(
            message: filter == null
                ? 'Todavía no hay movimientos de este producto.'
                : 'Ningún movimiento de tipo ${filter!.label.toLowerCase()}.',
          )
        else
          for (final movement in movements) ...[
            _MovementRow(movement: movement, unit: detail.product.unit),
            const SizedBox(height: 7),
          ],
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            productId: product.id,
            name: product.name,
            imagePath: product.imagePath,
            size: 76,
            radius: 20,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTypography.h3.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Se mide en ${product.unit}',
                  style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
                ),
                if (product.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.description!,
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 9),
                Text(
                  product.isSoldOut
                      ? 'Sin existencias'
                      : '${Fixed2.formatQuantity(product.stock)} en existencia',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: product.isSoldOut ? AppColors.errorText : AppColors.textPrimary,
                  ),
                ),
                // La diferencia entre lo que hay y lo que se vende: el resto son
                // lotes de la casa, que el mostrador no ofrece.
                if (product.sellableStock != product.stock)
                  Text(
                    product.sellableStock <= 0
                        ? 'Nada de esto se vende: es insumo propio'
                        : 'De eso, ${Fixed2.formatQuantity(product.sellableStock)} se venden',
                    style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({required this.lot, required this.unit});

  final ProductLot lot;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Lote ${lot.lotNumber}',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 7),
                    if (lot.isEmpty)
                      const AppStatusBadge(
                        label: 'Agotado',
                        tone: AppStatusTone.neutral,
                        size: AppStatusBadgeSize.sm,
                      )
                    else if (lot.isInternal)
                      const AppStatusBadge(
                        label: 'Uso interno',
                        tone: AppStatusTone.info,
                        size: AppStatusBadgeSize.sm,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${Fixed2.formatQuantity(lot.quantityAvailable)} de '
                  '${Fixed2.formatQuantity(lot.quantityReceived)} $unit · '
                  'recibido ${lot.receivedAt}',
                  style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lot.salePrice == null ? '—' : 'Q${Fixed2.format(lot.salePrice!)}',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: lot.salePrice == null
                      ? AppColors.textSecondary
                      : AppColors.primary700,
                ),
              ),
              Text(
                'costo —',
                style: AppTypography.helper.copyWith(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// El costo unitario se muestra siempre como «—» y no es un olvido: el feed no
/// manda `unit_cost` a propósito (plan 0005), porque el margen de compra no se
/// lee en el mostrador. Está aquí porque el §8.2 lo pide en la fila del lote.
class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.value, required this.onChanged});

  final MovementType? value;
  final ValueChanged<MovementType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        AppChip(
          label: 'Todos',
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        for (final type in MovementType.values)
          AppChip(
            label: type.label,
            selected: value == type,
            onTap: () => onChanged(value == type ? null : type),
          ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement, required this.unit});

  final InventoryMovement movement;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final delta = movement.stockDelta;
    final incoming = delta >= 0;

    return AppListCard(
      title: '${movement.type.label} · lote ${movement.lotNumber}',
      subtitle: switch ((movement.notes, movement.createdAt)) {
        (final String notes, final DateTime at) => '$notes · ${_when(at)}',
        (final String notes, null) => notes,
        (null, final DateTime at) => _when(at),
        _ => 'Sin fecha',
      },
      leading: AppListCardTile(
        icon: switch (movement.type) {
          MovementType.purchaseIn => Icons.local_shipping_outlined,
          MovementType.saleOut => Icons.local_mall_outlined,
          MovementType.internalUse => Icons.local_laundry_service_outlined,
          MovementType.adjustment => Icons.tune_rounded,
        },
        background: incoming ? AppColors.successBg : AppColors.warningBg,
        foreground: incoming ? AppColors.successText : AppColors.warningText,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            // El signo va aquí y no en la cabeza del lector: el kardex se lee
            // como un saldo corrido.
            '${incoming ? '+' : '−'}${Fixed2.formatQuantity(delta.abs())}',
            style: AppTypography.bodySm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: incoming ? AppColors.successText : AppColors.warningText,
            ),
          ),
          Text(
            unit,
            style: AppTypography.helper.copyWith(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static String _when(DateTime at) {
    final local = at.toLocal();
    return '${isoDate(local)} ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _Gone extends StatelessWidget {
  const _Gone();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Este producto ya no está',
        message: 'Puede que se haya archivado desde otro dispositivo.',
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
        title: 'No se pudo leer el producto',
        message: error,
      ),
    );
  }
}
