import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/fixed2.dart';
import '../models/catalog.dart';
import '../models/catalog_admin.dart';
import '../state/catalog_admin_controller.dart';
import 'widgets/price_form_sheet.dart';
import 'widgets/service_form_sheet.dart';

/// Detalle de un servicio con su historial de precios (Plan 0006 §10.1).
///
/// Un precio no se corrige: se **sustituye** abriendo una ventana nueva, y la
/// anterior queda cerrada el día antes (plan 0001 D1). Por eso el historial está
/// a la vista y por eso la pantalla dice, con todas sus letras, que los pedidos
/// ya tomados no cambian — es la pregunta que hace cualquiera antes de subir un
/// precio.
class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  static const String path = '/catalog/services/:id';

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(adminServiceProvider(serviceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(service.valueOrNull?.name ?? 'Servicio'),
        actions: [
          if (service.valueOrNull case final loaded?)
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => ServiceFormSheet.show(context, service: loaded),
            ),
        ],
      ),
      body: switch (service) {
        AsyncData(:final value) => _Body(service: value),
        AsyncError(:final error) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'No se pudo leer el servicio',
            message: '$error',
            action: AppButton(
              label: 'Reintentar',
              onPressed: () => ref.invalidate(adminServiceProvider(serviceId)),
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.service});

  final AdminService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(servicePricesProvider(service.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        _Head(service: service),
        if (service.pricingMode == PricingMode.tiered) ...[
          const SizedBox(height: 18),
          const AppSectionHeader(title: 'Opciones'),
          const SizedBox(height: 9),
          for (final option in service.options) ...[
            _OptionRow(option: option, service: service),
            const SizedBox(height: 7),
          ],
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: AppSectionHeader(title: 'Historial de precios')),
            if (service.hasPriceHistory && service.pricingMode != PricingMode.tiered)
              AppButton(
                label: 'Nuevo precio',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.secondary,
                icon: const Icon(Icons.add_rounded, size: 16),
                onPressed: () => PriceFormSheet.show(context, service: service),
              ),
          ],
        ),
        const SizedBox(height: 9),
        if (!service.hasPriceHistory)
          const _Note(
            message:
                'Este servicio no tiene precio que administrar: lo teclea quien '
                'captura el pedido, cada vez.',
          )
        else
          switch (prices) {
            AsyncData(value: final list) when list.isEmpty => const _Note(
              message: 'Todavía no tiene ningún precio.',
            ),
            AsyncData(value: final list) => Column(
              children: [
                for (final price in list) ...[
                  _PriceRow(price: price, service: service),
                  const SizedBox(height: 7),
                ],
              ],
            ),
            AsyncError(:final error) => _Note(message: '$error'),
            _ => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        const SizedBox(height: 14),
        const _HistoryNote(),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.service});

  final AdminService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                  service.name,
                  style: AppTypography.h3.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!service.isActive)
                const AppStatusBadge(
                  label: 'Apagado',
                  tone: AppStatusTone.neutral,
                  size: AppStatusBadgeSize.sm,
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            service.modeLabel,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 9),
          Text(
            // El código no se edita nunca: es a lo que apunta cada pedido ya
            // tomado. Se muestra porque es como se le nombra en el resto del
            // sistema y en los seeders.
            'Código: ${service.code}',
            style: AppTypography.helper.copyWith(color: AppColors.textMuted),
          ),
          if (service.currentPrice != null) ...[
            const SizedBox(height: 9),
            Text(
              'Hoy se cobra Q${Fixed2.format(service.currentPrice!)}'
              '${service.unitLabel == null ? '' : ' por ${service.unitLabel}'}',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Una opción de un servicio por tramos. Cada una lleva **su propio precio**,
/// así que el botón de precio nuevo vive en la fila y no arriba.
class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.option, required this.service});

  final AdminServiceOption option;
  final AdminService service;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: option.name,
      subtitle: option.rangeLabel.isEmpty ? null : option.rangeLabel,
      leading: AppListCardTile(
        label: option.code,
        background: AppColors.primary50,
        foreground: AppColors.primary700,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            option.currentPrice == null
                ? '—'
                : 'Q${Fixed2.format(option.currentPrice!)}',
            style: AppTypography.bodySm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: option.currentPrice == null
                  ? AppColors.textSecondary
                  : AppColors.primary700,
            ),
          ),
          IconButton(
            tooltip: 'Nuevo precio',
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: () =>
                PriceFormSheet.show(context, service: service, option: option),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, required this.service});

  final AdminPrice price;
  final AdminService service;

  @override
  Widget build(BuildContext context) {
    final current = price.isCurrent;
    final option = price.serviceOptionId == null
        ? null
        : service.options
              .where((each) => each.id == price.serviceOptionId)
              .firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: current ? AppColors.primary50 : AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: current ? AppColors.primary500 : AppColors.border,
          width: current ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q${Fixed2.format(price.amount)}'
                  '${option == null ? '' : ' · ${option.name}'}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: current ? AppColors.primary700 : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price.validTo == null
                      ? 'Desde el ${price.validFrom}'
                      : 'Del ${price.validFrom} al ${price.validTo}',
                  style: AppTypography.helper.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (current)
            const AppStatusBadge(
              label: 'Vigente',
              tone: AppStatusTone.success,
              size: AppStatusBadgeSize.sm,
            ),
        ],
      ),
    );
  }
}

/// La pregunta que hace cualquiera antes de subir un precio, contestada donde
/// se hace.
class _HistoryNote extends StatelessWidget {
  const _HistoryNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        'Los pedidos ya tomados no cambian. Cada boleta guardó el precio del día '
        'en que se capturó, así que un precio nuevo solo afecta a lo que entre '
        'de aquí en adelante.',
        style: AppTypography.bodySm.copyWith(color: AppColors.primary700),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.message});

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
