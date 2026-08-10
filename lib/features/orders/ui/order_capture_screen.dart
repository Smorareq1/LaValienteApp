import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/time/business_date.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../customers/models/customer.dart';
import '../../customers/ui/widgets/customer_picker.dart';
import '../../scan/models/scan.dart';
import '../../scan/ui/scan_screen.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../domain/order_capture.dart';
import '../state/order_capture_controller.dart';
import 'widgets/capture_section.dart';
import 'widgets/garments_section.dart';
import 'widgets/order_saved_sheet.dart';
import 'widgets/promotions_section.dart';
import 'widgets/services_section.dart';

/// Toma de pedido (plan 0002).
///
/// La pantalla se lee como la boleta de papel: mismo orden de secciones, mismos
/// nombres. Ese es el principio rector del plan, y no es estético — es lo que
/// hace que entrenar a alguien cueste una tarde y no una semana.
///
/// Todo funciona contra la BD local (plan 0004 D1): el catálogo, la búsqueda de
/// clientes, el total. Guardar deja el pedido en pantalla y una operación en el
/// outbox; la red decide cuándo, no si.
class OrderCaptureScreen extends ConsumerStatefulWidget {
  const OrderCaptureScreen({
    super.key,
    this.orderId,
    this.scan,
    this.scanCustomer,
  });

  static const String path = '/orders/new';

  /// Con valor, la pantalla abre **corrigiendo** ese pedido (§7.3): mismas
  /// secciones, misma aritmética, pero precargada y guardando encima.
  final String? orderId;

  /// Con valor, la boleta llega prellenada desde una foto (§5.3 → plan 0003).
  /// Sigue siendo esta pantalla la que guarda, y sigue siendo una persona la
  /// que decide: el escaneo prellena, nunca confirma.
  final ScanResult? scan;

  /// El cliente que alguien **confirmó** en la pantalla del escaneo, sea porque
  /// dijo que sí a la sugerencia del §7.5 o porque lo registró ahí mismo. Viaja
  /// aparte del borrador justamente porque no salió de la foto: salió de una
  /// respuesta.
  final Customer? scanCustomer;

  @override
  ConsumerState<OrderCaptureScreen> createState() => _OrderCaptureScreenState();
}

class _OrderCaptureScreenState extends ConsumerState<OrderCaptureScreen> {
  /// Qué secciones arrancan abiertas: las que casi siempre se llenan. El
  /// encabezado, las observaciones y el pago se abren cuando hacen falta.
  final Set<int> _expanded = {2, 3, 5};

  final _booklet = TextEditingController();
  final _nit = TextEditingController();
  final _weight = TextEditingController();
  final _observations = TextEditingController();
  final _discountAmount = TextEditingController();
  final _discountDescription = TextEditingController();
  final _advance = TextEditingController();
  final _reference = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _booklet,
      _nit,
      _weight,
      _observations,
      _discountAmount,
      _discountDescription,
      _advance,
      _reference,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Los campos de texto viven en esta pantalla y no en el estado, así que una
  /// boleta precargada hay que volcarla en ellos — una sola vez, o cada
  /// redibujo pisaría lo que la persona está escribiendo.
  var _prefilled = false;

  void _prefill(OrderCaptureState state) {
    if (_prefilled || !(state.isEditing || state.isFromScan)) return;
    _prefilled = true;
    _booklet.text = state.bookletSerial;
    _nit.text = state.nit;
    _weight.text = state.weightText;
    _observations.text = state.observations;
    _discountAmount.text = state.discountAmountText;
    _discountDescription.text = state.discountDescription;
  }

  /// Vuelca el escaneo en cuanto el catálogo terminó de cargar.
  ///
  /// Aquí y no en el `build` del controlador porque el borrador llega por la
  /// navegación y no por la clave del provider: hacerlo parte de la clave
  /// obligaría a que `/orders/new` y `/orders/new` desde un escaneo fueran dos
  /// pantallas distintas para GoRouter.
  var _scanApplied = false;

  void _applyScan(OrderCaptureState state) {
    final scan = widget.scan;
    if (_scanApplied || scan == null || state.isFromScan) return;
    _scanApplied = true;
    // Fuera del frame en curso: `applyScan` publica estado nuevo y hacerlo
    // durante el `build` que lo leyó es justo lo que Riverpod prohíbe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(orderCaptureControllerProvider(widget.orderId).notifier)
          .applyScan(scan, customer: widget.scanCustomer);
    });
  }

  void _toggle(int step) {
    setState(() {
      if (!_expanded.remove(step)) _expanded.add(step);
    });
  }

  void _clearForm() {
    ref.read(orderCaptureControllerProvider(widget.orderId).notifier).clear();
    for (final controller in [
      _booklet,
      _nit,
      _weight,
      _observations,
      _discountAmount,
      _discountDescription,
      _advance,
      _reference,
    ]) {
      controller.clear();
    }
  }

  /// Vaciar la boleta pregunta antes.
  ///
  /// El botón vive al pie de la lista, justo donde cae el pulgar al terminar de
  /// contar prendas, y lo que borra es una boleta entera que no está guardada en
  /// ninguna parte. La confirmación no es ceremonia: es lo que separa un toque
  /// distraído de volver a preguntarle todo al cliente.
  Future<void> _askClear() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '¿Limpiar la boleta?',
      message: 'Se borra todo lo capturado —cliente, prendas, servicios y '
          'descuentos— y no se puede recuperar.',
      confirmLabel: 'Limpiar',
      cancelLabel: 'Seguir capturando',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed && mounted) _clearForm();
  }

  Future<void> _save() async {
    final result = await ref
        .read(orderCaptureControllerProvider(widget.orderId).notifier)
        .save();
    if (!mounted) return;

    await result.match(
      (failure) async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (saved) async {
        if (widget.orderId != null) {
          // Corregir termina donde empezó: en el detalle del pedido, que ya
          // muestra los montos nuevos porque lee de la BD local.
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Pedido corregido')));
          // El `true` es para quien llegó desde la cola de revisión: solo una
          // corrección guardada cierra la entrada, y volver sin guardar tiene
          // que dejarla esperando decisión.
          context.pop(true);
          return;
        }
        // El controlador ya vació la boleta; los campos de texto viven en esta
        // pantalla y hay que vaciarlos aquí.
        _clearForm();
        final again = await OrderSavedSheet.show(context, saved);
        if (again == false && mounted) context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(
      orderCaptureControllerProvider(widget.orderId),
    );
    final loaded = asyncState.valueOrNull;
    if (loaded != null) {
      _applyScan(loaded);
      _prefill(loaded);
    }

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _Header(
            state: loaded,
            // El escaneo solo se ofrece en una boleta en blanco: corrigiendo no
            // tiene sentido, y una que ya vino de una foto no se vuelve a leer.
            canScan: loaded != null && !loaded.isEditing && !loaded.isFromScan,
          ),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'No se pudo abrir la boleta',
                    message: '$error',
                  ),
                ),
              ),
              data: (state) => _Form(
                state: state,
                expanded: _expanded,
                onToggle: _toggle,
                booklet: _booklet,
                nit: _nit,
                weight: _weight,
                observations: _observations,
                discountAmount: _discountAmount,
                discountDescription: _discountDescription,
                advance: _advance,
                reference: _reference,
                onClear: _askClear,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: asyncState.maybeWhen(
        data: (state) => _Footer(state: state, onSave: _save),
        orElse: () => null,
      ),
    );
  }
}

/// La cabecera de la boleta: de dónde se vuelve, qué boleta es y el atajo al
/// escaneo. Va sobre el gradiente de marca como el resto de las pantallas.
class _Header extends ConsumerWidget {
  const _Header({required this.state, required this.canScan});

  final OrderCaptureState? state;
  final bool canScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editing = state?.editing;

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        children: [
          _HeaderIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Volver',
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing == null
                      ? 'Sin No. asignado'
                      : '${editing.reference} · el No. y la fecha no cambian',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  editing == null ? 'Nueva boleta' : 'Corregir boleta',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          if (canScan) ...[const SizedBox(width: 10), const _ScanChip()],
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox.square(
            dimension: 34,
            child: Icon(icon, size: 22, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

/// La entrada al escaneo desde la boleta en blanco (§5.2).
///
/// Es online-only (D8), así que sin señal se muestra apagado y lo dice al
/// tocarlo: esconderlo dejaría a quien lo busca creyendo que la app lo perdió.
class _ScanChip extends ConsumerWidget {
  const _ScanChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityChangesProvider).valueOrNull ?? true;
    final radius = BorderRadius.circular(12);

    return Material(
      color: online ? AppColors.secondary500 : AppColors.white.withValues(alpha: 0.2),
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          if (online) {
            context.push(ScanScreen.path);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Escanear necesita señal. Capturá a mano mientras tanto.'),
            ),
          );
        },
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 16,
                color: online ? const Color(0xFF06485F) : AppColors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'Escanear',
                style: AppTypography.button(
                  fontSize: 12,
                  color: online ? const Color(0xFF06485F) : AppColors.white,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onSave});

  final OrderCaptureState state;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final priced = state.priced;
    final blockers = state.blockers;
    final charges = priced.charges.length;

    return AppSummaryBar(
      total: Fixed2.toDouble(priced.total),
      lines: [
        AppSummaryLine(
          label: 'Subtotal',
          amount: Fixed2.toDouble(priced.subtotal),
        ),
        if (priced.discountTotal > 0)
          AppSummaryLine(
            label: 'Desc.',
            amount: Fixed2.toDouble(priced.discountTotal),
            emphasis: true,
          ),
      ],
      pills: [
        AppSummaryPill('${state.totalPieces} pzas'),
        AppSummaryPill(
          '$charges ${charges == 1 ? 'cargo' : 'cargos'}',
          tone: AppSummaryTone.secondary,
        ),
      ],
      actionLabel: state.isEditing ? 'Guardar cambios' : 'Guardar pedido',
      note: blockers.isEmpty ? null : blockers.first,
      noteIsWarning: blockers.isNotEmpty,
      busy: state.saving,
      onAction: state.canSave ? onSave : null,
    );
  }
}

/// El aviso de que esta boleta la llenó una máquina (plan 0003 §4).
///
/// No es decorativo: quien captura tiene que saber que lo que está viendo es una
/// lectura y no un dato, porque la diferencia entre revisar y confiar es lo que
/// separa este módulo de uno que guarda pedidos equivocados.
class _ScannedBanner extends StatelessWidget {
  const _ScannedBanner({required this.reviewCount});

  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.document_scanner_outlined,
            size: 18,
            color: AppColors.warningText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reviewCount == 0
                  ? 'Boleta escaneada. Revisá los campos antes de guardar: el '
                        'cliente hay que confirmarlo a mano.'
                  : 'Boleta escaneada. $reviewCount ${reviewCount == 1 ? "campo salió" : "campos salieron"} '
                        'dudoso${reviewCount == 1 ? "" : "s"} — revisalos antes de guardar.',
              style: AppTypography.bodySm.copyWith(
                fontSize: 13,
                color: AppColors.warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form({
    required this.state,
    required this.expanded,
    required this.onToggle,
    required this.booklet,
    required this.nit,
    required this.weight,
    required this.observations,
    required this.discountAmount,
    required this.discountDescription,
    required this.advance,
    required this.reference,
    required this.onClear,
  });

  final OrderCaptureState state;
  final Set<int> expanded;
  final ValueChanged<int> onToggle;
  final TextEditingController booklet;
  final TextEditingController nit;
  final TextEditingController weight;
  final TextEditingController observations;
  final TextEditingController discountAmount;
  final TextEditingController discountDescription;
  final TextEditingController advance;
  final TextEditingController reference;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      orderCaptureControllerProvider(state.editing?.id).notifier,
    );
    final priced = state.priced;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        if (state.isFromScan) ...[
          _ScannedBanner(reviewCount: state.scanReviewCount),
          const SizedBox(height: 10),
        ],
        CaptureSection(
          step: 1,
          title: 'Encabezado',
          summary: _headerSummary(state),
          accent: CaptureAccent.secondary,
          expanded: expanded.contains(1),
          onToggle: () => onToggle(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CaptureLabel('Fecha del pedido'),
              AppDateField(
                value: state.orderDate,
                today: businessDate(),
                onChanged: controller.setDate,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppFormField(
                      label: 'Serie boleta',
                      controller: booklet,
                      hintText: '10433',
                      keyboardType: TextInputType.number,
                      onChanged: controller.setBookletSerial,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppFormField(
                      label: 'Peso (lbs)',
                      controller: weight,
                      hintText: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: decimalInputFormatters,
                      onChanged: controller.setWeight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'El peso queda ligado al cargo «Lavado por peso» de la sección 5.',
                style: AppTypography.helper.copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
        CaptureSection(
          step: 2,
          title: 'Cliente',
          summary: _customerSummary(state),
          incomplete: state.customer == null,
          expanded: expanded.contains(2),
          onToggle: () => onToggle(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerPicker(
                customer: state.customer,
                onChanged: (customer) {
                  controller.setCustomer(customer);
                  // El NIT sale del cliente: el suyo si lo tiene registrado y
                  // `CF` si no, que es lo que se factura a quien no lo da. Al
                  // soltar al cliente se va con él, porque un NIT huérfano es
                  // una factura a nombre de quien no vino.
                  nit.text = customer == null
                      ? ''
                      : OrderCaptureController.nitOf(customer);
                },
              ),
              // El NIT vive con el cliente y no en el encabezado: es un dato
              // *de él*, y enseñarlo antes de saber quién es deja un campo que
              // no se sabe a quién pertenece.
              if (state.customer != null) ...[
                const SizedBox(height: 14),
                const CaptureLabel('NIT'),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: const ValueKey('nit-field'),
                        controller: nit,
                        hintText: 'CF',
                        onChanged: controller.setNit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CfButton(
                      onPressed: () {
                        nit.text = 'CF';
                        controller.setNit('CF');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Sale del cliente: el suyo, o CF si no tiene. Se puede cambiar.',
                  style: AppTypography.helper.copyWith(fontSize: 11.5),
                ),
              ],
            ],
          ),
        ),
        CaptureSection(
          step: 3,
          title: 'Prendas',
          summary: _garmentSummary(state),
          incomplete: state.totalPieces == 0,
          expanded: expanded.contains(3),
          onToggle: () => onToggle(3),
          trailing: _PiecesCounter(pieces: state.totalPieces),
          child: GarmentsSection(
            garmentTypes: state.garmentTypes,
            quantities: state.garmentQuantities,
            notes: state.garmentNotes,
            onQuantityChanged: controller.setGarment,
            onNoteChanged: controller.setGarmentNote,
          ),
        ),
        CaptureSection(
          step: 4,
          title: 'Observaciones',
          summary: state.observations.trim().isEmpty
              ? 'Sin observaciones'
              : state.observations.trim(),
          accent: CaptureAccent.secondary,
          expanded: expanded.contains(4),
          onToggle: () => onToggle(4),
          child: AppTextField(
            controller: observations,
            hintText: 'Notas generales del pedido…',
            maxLines: 3,
            onChanged: controller.setObservations,
          ),
        ),
        CaptureSection(
          step: 5,
          title: 'Servicios',
          summary: _serviceSummary(state),
          accent: CaptureAccent.secondary,
          incomplete: priced.charges.isEmpty,
          expanded: expanded.contains(5),
          onToggle: () => onToggle(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ServicesSection(
                services: state.services,
                book: state.book,
                quantities: state.serviceQuantities,
                variableAmounts: state.variableAmounts,
                washByWeight: state.washByWeight,
                weightText: state.weightText,
                onServiceChanged: controller.setService,
                onVariableChanged: controller.setVariableAmount,
                onWashByWeightChanged: controller.setWashByWeight,
                onWeightChanged: (value) {
                  controller.setWeight(value);
                  if (weight.text != value) weight.text = value;
                },
              ),
              for (final warning in priced.warnings)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CaptureNotice(message: warning),
                ),
            ],
          ),
        ),
        CaptureSection(
          step: 6,
          title: 'Descuentos',
          summary: _discountSummary(state),
          incomplete: priced.discountIssues.isNotEmpty,
          expanded: expanded.contains(6),
          onToggle: () => onToggle(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PromotionsSection(
                promotions: state.promotions.live,
                lines: priced.charges,
                selected: state.selectedPromotions,
                onToggle: controller.togglePromotion,
              ),
              // Lo que impide guardar por culpa de un descuento se dice aquí y
              // no solo en el footer: el footer alcanza a mostrar un renglón, y
              // el motivo vive en esta sección.
              for (final issue in priced.discountIssues)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: PromotionIssue(message: issue),
                ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: CaptureHint(
                  message: 'El servidor confirma el descuento al guardar.',
                ),
              ),
              PermissionGate(
                anyOf: const [AppPermissions.ordersManualDiscount],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const CaptureGroupLabel(
                      'Descuento manual',
                      accent: CaptureAccent.primary,
                    ),
                    AppFormField(
                      label: 'Monto Q',
                      controller: discountAmount,
                      hintText: 'Q 0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: decimalInputFormatters,
                      onChanged: (value) =>
                          controller.setDiscount(amount: value),
                    ),
                    const SizedBox(height: 12),
                    AppFormField(
                      label: 'Motivo',
                      controller: discountDescription,
                      hintText: 'Ej. cliente frecuente',
                      onChanged: (value) =>
                          controller.setDiscount(description: value),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'El monto a mano queda a tu nombre; una promoción la calcula '
                      'el servidor al guardar.',
                      style: AppTypography.helper.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // El pago inicial no aparece al corregir: el dinero recibido es un
        // hecho que ocurrió, y se cobra o se anula desde el detalle, no
        // reescribiendo la boleta (§7.3).
        if (!state.isEditing)
          CaptureSection(
            step: 7,
            title: 'Pago inicial',
            summary: _advanceSummary(state),
            expanded: expanded.contains(7),
            onToggle: () => onToggle(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  label: 'Monto Q',
                  controller: advance,
                  hintText: 'Q 0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: decimalInputFormatters,
                  onChanged: (value) => controller.setAdvance(amount: value),
                ),
                const SizedBox(height: 12),
                const CaptureLabel('Método'),
                AppSegmented<PaymentMethod>(
                  value: state.paymentMethod,
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
                  onChanged: (method) => controller.setAdvance(method: method),
                ),
                if (state.paymentMethod == PaymentMethod.transfer) ...[
                  const SizedBox(height: 12),
                  AppFormField(
                    label: 'Referencia',
                    controller: reference,
                    hintText: 'No. de boleta o referencia',
                    onChanged: (value) =>
                        controller.setAdvance(reference: value),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  'Normalmente se paga al entregar; el anticipo es la excepción.',
                  style: AppTypography.helper.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        // Vaciar una corrección no tendría a dónde volver: dejaría la pantalla
        // en blanco pero seguiría apuntando al pedido. Para deshacer se sale.
        if (!state.isEditing) _ClearButton(onPressed: onClear),
      ],
    );
  }

  static String _headerSummary(OrderCaptureState state) {
    final parts = <String>[
      formatBusinessDate(state.orderDate, today: businessDate()),
      if (state.bookletSerial.trim().isNotEmpty)
        'boleta ${state.bookletSerial.trim()}',
      if (state.weightLbs != null && state.weightLbs! > 0)
        '${Fixed2.format(state.weightLbs!)} lbs',
    ];
    return parts.join(' · ');
  }

  /// El cliente con el NIT que se le va a facturar: los dos viven en esta
  /// sección, y con ella cerrada es lo único que hay que revisar de un vistazo.
  static String _customerSummary(OrderCaptureState state) {
    final customer = state.customer;
    if (customer == null) return 'Sin cliente seleccionado';
    final nit = state.nit.trim();
    return nit.isEmpty ? customer.fullName : '${customer.fullName} · NIT $nit';
  }

  static String _garmentSummary(OrderCaptureState state) {
    final kinds = state.garmentQuantities.values
        .where((quantity) => quantity > 0)
        .length;
    if (kinds == 0) return 'Ninguna prenda agregada';
    return kinds == 1 ? '1 tipo de prenda' : '$kinds tipos de prenda';
  }

  static String _serviceSummary(OrderCaptureState state) {
    final priced = state.priced;
    if (priced.charges.isEmpty) return 'Ningún servicio agregado';
    final label = priced.charges.length == 1 ? 'cargo' : 'cargos';
    return '${priced.charges.length} $label · Q${Fixed2.format(priced.subtotal)}';
  }

  static String _discountSummary(OrderCaptureState state) {
    final priced = state.priced;
    if (priced.discountIssues.isNotEmpty) return priced.discountIssues.first;
    if (priced.discountTotal <= 0) return 'Sin descuento';

    final promotions = priced.discounts
        .where((line) => line.promotionId != null)
        .length;
    final label = promotions == 0
        ? ''
        : promotions == 1
        ? ' · 1 promoción'
        : ' · $promotions promociones';
    return '−Q${Fixed2.format(priced.discountTotal)}$label';
  }

  static String _advanceSummary(OrderCaptureState state) {
    final amount = state.advanceAmount;
    if (amount <= 0) return 'No paga por adelantado';
    return 'Q${Fixed2.format(amount)} · ${state.paymentMethod.label.toLowerCase()}';
  }
}

class _PiecesCounter extends StatelessWidget {
  const _PiecesCounter({required this.pieces});

  final int pieces;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pieces > 0 ? AppColors.primary100 : AppColors.gray100,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        '$pieces pzas',
        style: AppTypography.money(
          fontSize: 12,
          color: pieces > 0 ? AppColors.primary700 : AppColors.gray400,
        ),
      ),
    );
  }
}

/// Vaciar la boleta se pinta en gris y no en magenta: es lo contrario de la
/// acción principal, y un botón de marca al pie invitaría a tocarlo.
class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.delete_outline_rounded, size: 16),
        label: Text(
          'Limpiar boleta',
          style: AppTypography.button(fontSize: 12.5, color: AppColors.gray500)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gray500,
          overlayColor: AppColors.errorText,
        ),
      ),
    );
  }
}

/// Atajo al NIT de consumidor final, que es el que se teclea todo el día.
class _CfButton extends StatelessWidget {
  const _CfButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Material(
      color: AppColors.primary100,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Text(
            'CF',
            style: AppTypography.button(fontSize: 13, color: AppColors.primary700)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
