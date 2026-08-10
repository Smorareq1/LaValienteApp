import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/fixed2.dart';
import '../../customers/data/customers_repository.dart';
import '../../customers/models/customer.dart';
import '../../customers/ui/widgets/customer_form_sheet.dart';
import '../../orders/ui/order_capture_screen.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../domain/scan_warnings.dart';
import '../models/scan.dart';
import '../state/scan_controller.dart';
import '../state/shared_images_controller.dart';
import '../state/ticket_photo_picker.dart';
import 'widgets/scan_reading_view.dart';
import 'widgets/shared_queue_note.dart';

/// Escaneo de boleta (Plan 0006 §5.3 → Plan 0003).
///
/// Fotografía la boleta de papel, la manda al servidor y abre la toma de pedido
/// **prellenada**. Lo que no hace, y no puede hacer, es guardar: el borrador lo
/// revisa y confirma una persona, y el motor de precios recalcula cada monto
/// (plan 0003, principio inviolable y D4).
///
/// **Online-only** (D8): sin señal el botón no se ofrece y se dice por qué. La
/// captura a mano funciona entera sin este módulo, que es lo que hace que el
/// escaneo sea un atajo y nunca un punto único de falla.
class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  static const String path = '/orders/scan';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Expanded(
            child: switch (state) {
              ScanIdle() => const _Guide(),
              ScanSending(:final image) => _Sending(image: image),
              ScanFailed(:final image, :final failure) => _Failed(
                image: image,
                message: failure.message,
              ),
              ScanDone(:final image, :final result) => _Review(
                image: image,
                result: result,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Necesita señal',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Escanear boleta',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lo que se ve antes de la primera foto: cómo encuadrar, y las dos formas de
/// dar la boleta.
class _Guide extends ConsumerWidget {
  const _Guide();

  Future<void> _pick(BuildContext context, WidgetRef ref, AppImageSource source) async {
    final bytes = await ref.read(ticketPhotoPickerProvider).pick(source);
    if (bytes == null || !context.mounted) return;
    await ref.read(scanControllerProvider.notifier).send(bytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      children: [
        const SharedQueueNote(),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                size: 54,
                color: AppColors.primary500,
              ),
              const SizedBox(height: 12),
              Text(
                'Fotografía la boleta completa',
                style: AppTypography.h3.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'La app lee lo que puede y abre la boleta ya llena. Vos revisás '
                'y guardás: nada se guarda solo.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _Tips(),
        const SizedBox(height: 18),
        AppButton(
          label: 'Tomar la foto',
          fullWidth: true,
          icon: const Icon(Icons.photo_camera_rounded, size: 18),
          onPressed: () => _pick(context, ref, AppImageSource.camera),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Elegir de la galería',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          icon: const Icon(Icons.photo_library_outlined, size: 18),
          onPressed: () => _pick(context, ref, AppImageSource.gallery),
        ),
      ],
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  static const _tips = [
    (Icons.crop_free_rounded, 'Que quepa entera, sin cortar los bordes.'),
    (Icons.wb_sunny_outlined, 'Con luz pareja: la sombra tapa los números.'),
    (Icons.straighten_rounded, 'De frente, no de lado.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        children: [
          for (final (icon, text) in _tips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(icon, size: 17, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Sending extends StatelessWidget {
  const _Sending({required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return ScanReadingView(
      image: image,
      steps: ScanReadingView.ticketSteps,
    );
  }
}

class _Failed extends ConsumerWidget {
  const _Failed({required this.image, required this.message});

  final Uint8List image;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(child: _Photo(image: image)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Text(
                  message,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.errorText,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Reintentar',
                onPressed: () => ref.read(scanControllerProvider.notifier).retry(),
              ),
              const SizedBox(height: 9),
              // La salida que D8 promete: la captura a mano no depende de nada
              // de esto, y ofrecerla aquí es lo que hace que un fallo del
              // proveedor no detenga el mostrador.
              AppButton(
                label: 'Capturar a mano',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  ref.read(sharedImagesControllerProvider.notifier).done();
                  ref.read(scanControllerProvider.notifier).reset();
                  context.pushReplacement(OrderCaptureScreen.path);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lo que se leyó, antes de volcarlo en la boleta.
class _Review extends ConsumerStatefulWidget {
  const _Review({required this.image, required this.result});

  final Uint8List image;
  final ScanResult result;

  @override
  ConsumerState<_Review> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<_Review> {
  /// El cliente que se confirmó aquí, si se confirmó alguno. Arranca en `null`
  /// siempre: la sugerencia del §7.5 es una pregunta, y una pregunta sin
  /// contestar no es un sí.
  Customer? _customer;

  Future<void> _acceptMatch(CustomerMatch match) async {
    final customer = await ref
        .read(customersRepositoryProvider)
        .byId(match.customerId);
    if (!mounted) return;
    if (customer == null) {
      // El servidor sugirió a alguien que este dispositivo todavía no tiene
      // espejado. No es un error que valga la pena explicar: se busca a mano.
      setState(() => _customer = null);
      return;
    }
    setState(() => _customer = customer);
  }

  Future<void> _register(ScanDraft draft) async {
    final created = await CustomerFormSheet.show(
      context,
      prefill: CustomerPrefill(
        fullName: draft.customerName.value,
        phone: draft.customerPhone.value,
        address: draft.customerAddress.value,
      ),
    );
    if (created != null && mounted) setState(() => _customer = created);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final draft = result.draft;
    if (draft == null || draft.isEmpty) {
      return _Failed(
        image: widget.image,
        message:
            'De esta foto no se sacó nada aprovechable. Probá con más luz, o '
            'capturá la boleta a mano.',
      );
    }

    final warnings = scanWarnings(result.warnings);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _Summary(draft: draft),
              const SizedBox(height: 14),
              _CustomerBlock(
                draft: draft,
                chosen: _customer,
                onAccept: _acceptMatch,
                onRegister: () => _register(draft),
                onClear: () => setState(() => _customer = null),
              ),
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 14),
                _Warnings(warnings: warnings),
              ],
              const SizedBox(height: 14),
              _PhotoCard(image: widget.image),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.gray100)),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Otra foto',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    // Esta foto se descartó, venga de donde venga: si era del
                    // lote compartido, sale de la cola y sigue la próxima.
                    ref.read(sharedImagesControllerProvider.notifier).done();
                    ref.read(scanControllerProvider.notifier).reset();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Usar y revisar',
                  onPressed: () {
                    // Cumplió: el borrador ya va camino de la boleta.
                    ref.read(sharedImagesControllerProvider.notifier).done();
                    // La boleta se abre precargada; guardar sigue siendo un acto
                    // deliberado en la pantalla del plan 0002.
                    context.pushReplacement(
                      OrderCaptureScreen.path,
                      extra: {'scan': result, 'customer': _customer},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// El cliente: la sugerencia del §7.5, o el alta prellenada si no hubo ninguna.
///
/// Es el único bloque de esta pantalla con botones, y por eso existe: todo lo
/// demás se corrige después en la boleta, pero el cliente es lo que la boleta
/// **no** puede prellenar sola, y resolverlo aquí —donde la foto está a la
/// vista— ahorra el viaje al buscador con la boleta ya abierta.
class _CustomerBlock extends StatelessWidget {
  const _CustomerBlock({
    required this.draft,
    required this.chosen,
    required this.onAccept,
    required this.onRegister,
    required this.onClear,
  });

  final ScanDraft draft;
  final Customer? chosen;
  final Future<void> Function(CustomerMatch) onAccept;
  final VoidCallback onRegister;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final name = draft.customerName.value;
    final match = draft.customerMatch;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: chosen == null ? AppColors.border : AppColors.success,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (chosen case final Customer customer) ...[
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 19,
                  color: AppColors.successText,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    customer.fullName,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: onClear, child: const Text('Cambiar')),
              ],
            ),
            Text(
              'La boleta se abre a su nombre. Podés cambiarlo ahí mismo.',
              style: AppTypography.helper.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ] else if (match case final CustomerMatch suggestion) ...[
            _MatchNote(match: suggestion),
            const SizedBox(height: 10),
            AppButton(
              label: 'Sí, es ${suggestion.fullName}',
              fullWidth: true,
              icon: const Icon(Icons.person_rounded, size: 17),
              onPressed: () => onAccept(suggestion),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Es otra persona',
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: onRegister,
            ),
          ] else if (name != null && name.trim().isNotEmpty) ...[
            Text(
              'Se leyó «$name» y no coincide con ningún cliente registrado. '
              'Podés darlo de alta con lo que la boleta ya dice.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Registrar a $name',
              fullWidth: true,
              icon: const Icon(Icons.person_add_alt_rounded, size: 17),
              onPressed: onRegister,
            ),
          ] else
            Text(
              'De la foto no salió ningún nombre. El cliente se elige en la '
              'boleta, con el buscador de siempre.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.draft});

  final ScanDraft draft;

  @override
  Widget build(BuildContext context) {
    final pieces = draft.garments.fold(0, (sum, line) => sum + line.quantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Esto se leyó',
                  style: AppTypography.h3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (draft.reviewCount > 0)
                AppStatusBadge(
                  label: draft.reviewCount == 1
                      ? '1 por revisar'
                      : '${draft.reviewCount} por revisar',
                  tone: AppStatusTone.warning,
                  size: AppStatusBadgeSize.sm,
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Row(
            label: 'Cliente',
            value: draft.customerName.value ?? '—',
            needsReview: draft.customerName.needsReview,
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Boleta',
            value: draft.bookletSerial.value ?? '—',
            needsReview: draft.bookletSerial.needsReview,
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Prendas',
            value: pieces == 0 ? '—' : '$pieces piezas',
          ),
          const SizedBox(height: 8),
          _Row(
            label: 'Servicios',
            value: draft.charges.isEmpty
                ? '—'
                : draft.charges.map((line) => line.description).join(' · '),
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total estimado',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Q${Fixed2.format(draft.estimatedTotal)}',
                style: AppTypography.money(fontSize: 19),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lo calcula el catálogo, no la foto: los montos escritos en la '
            'boleta solo sirven para avisar si algo no cuadra.',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.needsReview = false,
  });

  final String label;
  final String value;
  final bool needsReview;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (needsReview) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.error_outline_rounded,
            size: 15,
            color: AppColors.warningText,
          ),
        ],
      ],
    );
  }
}

/// La sugerencia de cliente del §7.5. Se enseña como pregunta, no como hecho.
class _MatchNote extends StatelessWidget {
  const _MatchNote({required this.match});

  final CustomerMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        match.isExact
            ? '¿Es ${match.fullName}${match.phone == null ? "" : ", ${match.phone}"}? '
                  'El teléfono coincide con un cliente ya registrado.'
            : '¿Será ${match.fullName}? El nombre se parece al de un cliente ya '
                  'registrado. Lo confirmás en la boleta.',
        style: AppTypography.bodySm.copyWith(color: AppColors.primary700),
      ),
    );
  }
}

class _Warnings extends StatelessWidget {
  const _Warnings({required this.warnings});

  final List<ScanWarning> warnings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final warning in warnings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: warning.tone == ScanWarningTone.serious
                    ? AppColors.errorBg
                    : AppColors.warningBg,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    warning.tone == ScanWarningTone.serious
                        ? Icons.report_problem_rounded
                        : Icons.info_outline_rounded,
                    size: 17,
                    color: warning.tone == ScanWarningTone.serious
                        ? AppColors.errorText
                        : AppColors.warningText,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      warning.message,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13,
                        color: warning.tone == ScanWarningTone.serious
                            ? AppColors.errorText
                            : AppColors.warningText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: Image.memory(image, fit: BoxFit.contain),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Image.memory(image, fit: BoxFit.contain, width: double.infinity),
      ),
    );
  }
}
