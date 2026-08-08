import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/receipts/receipt.dart';
import '../../../core/money/payment_method.dart';
import '../../../core/time/business_date.dart';
import '../../auth/state/auth_controller.dart';
import '../../customers/models/customer.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../inventory/domain/supply_sale_pricing.dart';
import '../../inventory/models/product.dart';
import '../../customers/ui/widgets/customer_picker.dart';
import '../../inventory/state/shelf_controller.dart';
import '../state/cash_day_controller.dart';

/// Venta de insumo en el mostrador (Plan 0006 §7.3).
///
/// Vive **fuera del shell**, como la toma de pedido y por lo mismo: el footer
/// con el TOTAL ocupa el sitio de la barra de cinco destinos.
///
/// El mostrador elige productos y cantidades, nunca lotes ni precios. Lo que se
/// ve aquí es una vista previa contra el inventario que este teléfono alcanzó a
/// bajar; el servidor reparte contra el estante de verdad al aplicar la venta
/// (plan 0005 D5) y el feed corrige el total.
class SupplySaleScreen extends ConsumerStatefulWidget {
  const SupplySaleScreen({super.key});

  static const String path = '/cash/supply-sale';

  @override
  ConsumerState<SupplySaleScreen> createState() => _SupplySaleScreenState();
}

class _SupplySaleScreenState extends ConsumerState<SupplySaleScreen> {
  /// Cantidades por producto, en unidades enteras. El mostrador vende botes y
  /// bolsas; una fracción de bote no es algo que nadie pida de pie.
  final Map<String, int> _units = {};

  final TextEditingController _nit = TextEditingController();
  final TextEditingController _reference = TextEditingController();

  Customer? _customer;
  PaymentMethod _method = PaymentMethod.cash;
  bool _saving = false;

  @override
  void dispose() {
    _nit.dispose();
    _reference.dispose();
    super.dispose();
  }

  List<PricedSaleLine> _lines(List<ProductShelf> shelf) {
    return [
      for (final product in shelf)
        if ((_units[product.id] ?? 0) > 0)
          priceLine(
            productId: product.id,
            productName: product.name,
            quantity: (_units[product.id] ?? 0) * 100,
            lots: product.lots,
          ),
    ];
  }

  Future<void> _save(List<PricedSaleLine> lines) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    final result = await ref
        .read(inventoryRepositoryProvider)
        .createSale(
          SupplySaleDraft(
            saleDate: isoDate(ref.read(cashDateFilterProvider)),
            lines: lines,
            method: _method,
            customerId: _customer?.id,
            nit: _nit.text,
            reference: _method == PaymentMethod.transfer ? _reference.text : null,
          ),
          soldById: user.id,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    result.match(
      (failure) => ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failure.message))),
      (sale) {
        // El comprobante se arma **antes** de salir: las líneas con su precio
        // están aquí y no en la venta guardada, que solo lleva el total.
        final receipt = supplySaleReceipt(
          total: sale.total,
          date: formatBusinessDate(ref.read(cashDateFilterProvider)),
          customerName: _customer?.fullName,
          method: _method.label,
          items: [
            for (final line in lines)
              (
                name: line.productName,
                quantity: line.quantity,
                amount: line.amount,
              ),
          ],
        );
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('Venta registrada por Q${Fixed2.format(sale.total)}'),
              action: SnackBarAction(
                label: 'Compartir',
                onPressed: () => Share.share(receipt),
              ),
            ),
          );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shelfAsync = ref.watch(shelfProvider);
    final shelf = shelfAsync.valueOrNull ?? const <ProductShelf>[];
    final lines = _lines(shelf);
    final sale = priceSale(lines);
    final pieces = _units.values.fold(0, (sum, value) => sum + value);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: const Text('Venta de insumo'),
        titleTextStyle: AppTypography.h3.copyWith(fontSize: 17),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: shelfAsync.isLoading && shelf.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary500))
          : shelf.isEmpty
          ? const _EmptyShelf()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              children: [
                Text('PRODUCTOS', style: AppTypography.label),
                const SizedBox(height: 9),
                for (final product in shelf)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _ProductCard(
                      product: product,
                      units: _units[product.id] ?? 0,
                      onChanged: (value) => setState(() {
                        if (value <= 0) {
                          _units.remove(product.id);
                        } else {
                          _units[product.id] = value;
                        }
                      }),
                    ),
                  ),
                const SizedBox(height: 6),
                Text('CLIENTE · opcional', style: AppTypography.label),
                const SizedBox(height: 4),
                Text(
                  'Sin cliente queda como venta de mostrador.',
                  style: AppTypography.helper.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 9),
                CustomerPicker(
                  customer: _customer,
                  onChanged: (customer) => setState(() => _customer = customer),
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'NIT',
                  controller: _nit,
                  hintText: 'CF',
                  optional: true,
                  suffix: AppButton(
                    label: 'CF',
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.sm,
                    onPressed: () => setState(() => _nit.text = 'CF'),
                  ),
                ),
                const SizedBox(height: 16),
                Text('PAGO', style: AppTypography.label),
                const SizedBox(height: 7),
                AppSegmented<PaymentMethod>(
                  value: _method,
                  options: const [
                    AppSegmentedOption(
                      value: PaymentMethod.cash,
                      label: 'Efectivo',
                      icon: Icons.payments_outlined,
                    ),
                    AppSegmentedOption(
                      value: PaymentMethod.transfer,
                      label: 'Transferencia',
                      icon: Icons.swap_horiz_rounded,
                    ),
                  ],
                  onChanged: (method) => setState(() => _method = method),
                ),
                if (_method == PaymentMethod.transfer) ...[
                  const SizedBox(height: 14),
                  AppFormField(
                    label: 'REFERENCIA',
                    controller: _reference,
                    hintText: 'No. de la transferencia',
                    optional: true,
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  'La venta se cobra al momento: no queda saldo pendiente.',
                  style: AppTypography.helper.copyWith(fontSize: 11.5),
                ),
              ],
            ),
      bottomNavigationBar: AppSummaryBar(
        total: Fixed2.toDouble(sale.total),
        caption: pieces == 0
            ? 'Sin productos'
            : '$pieces ${pieces == 1 ? 'unidad' : 'unidades'} · ${lines.length} '
                  '${lines.length == 1 ? 'producto' : 'productos'}',
        actionLabel: 'Registrar venta',
        busy: _saving,
        // Un stock corto **no** bloquea (plan 0005 D12): el aviso ya está en la
        // tarjeta del producto, y quien tiene el bote en la mano sabe mejor que
        // un inventario de hace tres horas.
        note: sale.isEmpty
            ? 'Agregá al menos un producto'
            : sale.hasShortages
            ? 'Algún producto pasa del stock que este teléfono tiene contado. Se '
                  'puede vender igual; el servidor lo revisa al sincronizar.'
            : null,
        noteIsWarning: sale.hasShortages,
        onAction: sale.canSave && !_saving ? () => _save(lines) : null,
      ),
    );
  }
}

/// Una tarjeta de producto con su stock, su precio y su stepper.
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.units,
    required this.onChanged,
  });

  final ProductShelf product;
  final int units;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final price = product.nextSalePrice;
    final short = units * 100 > product.available;
    final available = Fixed2.formatQuantity(product.available);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: short ? AppColors.warning : AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Marcador con la inicial en vez de la foto: la imagen del
              // producto se sirve autenticada desde el servidor y hace falta
              // caché local para que exista sin señal — eso llega con
              // `AppImagePicker`, en la fase UI 7.
              _ProductTile(name: product.name),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      product.isSoldOut
                          ? 'Sin existencias · ${product.unit}'
                          : '$available ${product.unit} · '
                                '${price == null ? 'sin precio' : 'Q${Fixed2.format(price)} c/u'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.helper.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppStepper(
                value: units,
                size: AppStepperSize.md,
                onChanged: onChanged,
              ),
            ],
          ),
          if (short) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.warningText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Este teléfono solo tiene contadas $available. Se puede vender: '
                    'el servidor valida al sincronizar.',
                    style: AppTypography.helper.copyWith(
                      fontSize: 11,
                      color: AppColors.warningText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '·' : name.trim()[0].toUpperCase();

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        initial,
        style: AppTypography.money(fontSize: 15, color: AppColors.secondary700),
      ),
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
      child: AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No hay productos para vender',
        message:
            'Los productos y sus lotes se administran desde el servidor. Si acabás '
            'de agregarlos, sincronizá para que bajen a este teléfono.',
      ),
    );
  }
}
