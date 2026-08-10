import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/fixed2.dart';
import '../state/order_capture_controller.dart';
import 'widgets/capture_section.dart';
import 'widgets/services_section.dart';

/// Sumar servicios a una boleta que ya está en el taller (Plan 0006 §5.4).
///
/// El caso es de todos los días: la ropa ya entró, alguien decide que además va
/// un secado, y hasta ahora eso obligaba a reabrir la boleta entera por
/// «Editar» —siete secciones para tocar una—. Esto abre **la lista del catálogo
/// tal como está en la toma de pedido**, con lo ya cobrado marcado, y guarda por
/// el mismo camino: es una corrección del pedido (§7.3), con su permiso y su
/// `base_version`.
///
/// Reusa el controlador de la captura en modo corrección, así que lo que hay en
/// pantalla es la boleta completa aunque solo se vean los servicios: guardar no
/// pierde prendas, descuentos ni observaciones.
class OrderServicesScreen extends ConsumerStatefulWidget {
  const OrderServicesScreen({super.key, required this.orderId});

  final String orderId;

  static String pathFor(String orderId) => '/orders/$orderId/services';

  @override
  ConsumerState<OrderServicesScreen> createState() => _OrderServicesScreenState();
}

class _OrderServicesScreenState extends ConsumerState<OrderServicesScreen> {
  Future<void> _save() async {
    final result = await ref
        .read(orderCaptureControllerProvider(widget.orderId).notifier)
        .save();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    result.match(
      (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (saved) {
        messenger.showSnackBar(
          SnackBar(content: Text('Servicios del pedido ${saved.reference} guardados')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(orderCaptureControllerProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        // El tema pinta los iconos en blanco, que es lo correcto sobre el
        // magenta; sobre blanco hay que decirlo o la flecha desaparece.
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
        ),
        title: Text(
          'Agregar servicios',
          style: AppTypography.h3.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: asyncState.when(
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
        data: _Form.new,
      ),
      bottomNavigationBar: asyncState.maybeWhen(
        data: (state) => _Footer(state: state, onSave: _save),
        orElse: () => null,
      ),
    );
  }
}

class _Form extends ConsumerWidget {
  const _Form(this.state);

  final OrderCaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      orderCaptureControllerProvider(state.editing?.id).notifier,
    );
    final priced = state.priced;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CaptureHint(
            message: 'Los servicios que ya lleva la boleta salen marcados. '
                'Súmale lo que haga falta y guardá: el total se recalcula.',
          ),
        ),
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
          onWeightChanged: controller.setWeight,
        ),
        for (final warning in priced.warnings)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CaptureNotice(message: warning),
          ),
      ],
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
    final charges = priced.charges.length;
    final paid = state.editing?.paid ?? 0;

    return AppSummaryBar(
      total: Fixed2.toDouble(priced.total),
      lines: [
        AppSummaryLine(label: 'Subtotal', amount: Fixed2.toDouble(priced.subtotal)),
        if (paid > 0) AppSummaryLine(label: 'Pagado', amount: Fixed2.toDouble(paid)),
      ],
      pills: [
        AppSummaryPill(
          '$charges ${charges == 1 ? 'cargo' : 'cargos'}',
          tone: AppSummaryTone.secondary,
        ),
      ],
      actionLabel: 'Guardar servicios',
      note: state.blockers.isEmpty ? null : state.blockers.first,
      noteIsWarning: state.blockers.isNotEmpty,
      busy: state.saving,
      onAction: state.canSave ? onSave : null,
    );
  }
}
