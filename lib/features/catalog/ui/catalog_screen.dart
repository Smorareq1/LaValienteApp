import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/fixed2.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/catalog.dart';
import '../models/catalog_admin.dart';
import '../state/catalog_admin_controller.dart';
import 'service_wizard_screen.dart';
import 'widgets/garment_form_sheet.dart';

/// Catálogo (Plan 0006 §10.1 y §10.2).
///
/// Dos pestañas porque son dos cosas distintas que se administran en el mismo
/// sitio: **qué se cobra** y **sobre qué se cobra**. Los precios no se editan
/// aquí —eso vive en el detalle de cada servicio, con su historial— porque
/// cambiar un precio no es corregir un dato: es abrir una ventana nueva.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  static const String path = '/catalog';

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesAdminControllerProvider);
    final garments = ref.watch(garmentsAdminControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            tab: _tab,
            services: services.valueOrNull?.length,
            garments: garments.valueOrNull?.length,
            onTab: (index) => setState(() => _tab = index),
          ),
          Expanded(
            child: _tab == 0
                ? _Services(services: services, ref: ref)
                : _Garments(garments: garments, ref: ref),
          ),
        ],
      ),
      // Una prenda es un nombre y cabe en una sheet; un servicio pide código,
      // modalidad, sus tramos y el precio de cada uno, así que se crea en el
      // asistente del §10.1, que no termina hasta que se puede cobrar.
      floatingActionButton: _tab == 1
          ? FloatingActionButton.extended(
              onPressed: () => GarmentFormSheet.show(context),
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Prenda'),
            )
          : FloatingActionButton.extended(
              onPressed: () => context.push(ServiceWizardScreen.path),
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Servicio'),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tab,
    required this.onTab,
    this.services,
    this.garments,
  });

  final int tab;
  final ValueChanged<int> onTab;
  final int? services;
  final int? garments;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  'Catálogo',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTabBar(
            index: tab,
            onChanged: onTab,
            tabs: [
              AppTab(label: 'Servicios', count: services),
              AppTab(label: 'Prendas', count: garments),
            ],
          ),
        ],
      ),
    );
  }
}

class _Services extends StatelessWidget {
  const _Services({required this.services, required this.ref});

  final AsyncValue<List<AdminService>> services;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return switch (services) {
      AsyncData(value: final list) when list.isEmpty => const Padding(
        padding: EdgeInsets.all(24),
        child: AppEmptyState(
          icon: Icons.sell_outlined,
          title: 'No hay servicios',
          message: 'Sin servicios no se puede tomar un pedido.',
        ),
      ),
      AsyncData(value: final list) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _ServiceRow(service: list[index]),
      ),
      AsyncError(:final error) => _Failed(
        message: '$error',
        onRetry: () => ref.invalidate(servicesAdminControllerProvider),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service});

  final AdminService service;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: service.name,
      subtitle: service.modeLabel,
      leading: AppListCardTile(
        icon: switch (service.pricingMode) {
          PricingMode.perUnit => Icons.straighten_rounded,
          PricingMode.tiered => Icons.layers_outlined,
          PricingMode.variable => Icons.edit_note_rounded,
          null => Icons.help_outline_rounded,
        },
        background: service.isActive ? AppColors.primary50 : AppColors.gray100,
        foreground: service.isActive ? AppColors.primary700 : AppColors.gray400,
      ),
      titleSuffix: service.isActive
          ? null
          : const AppStatusBadge(
              label: 'Apagado',
              tone: AppStatusTone.neutral,
              size: AppStatusBadgeSize.sm,
            ),
      trailing: service.currentPrice == null
          ? null
          : Text(
              'Q${Fixed2.format(service.currentPrice!)}',
              style: AppTypography.bodySm.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary700,
              ),
            ),
      onTap: () => context.push('/catalog/services/${service.id}'),
    );
  }
}

class _Garments extends StatelessWidget {
  const _Garments({required this.garments, required this.ref});

  final AsyncValue<List<AdminGarment>> garments;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return switch (garments) {
      AsyncData(value: final list) when list.isEmpty => const Padding(
        padding: EdgeInsets.all(24),
        child: AppEmptyState(
          icon: Icons.checkroom_outlined,
          title: 'No hay tipos de prenda',
          message: 'Los 21 de la boleta vienen sembrados; si no hay ninguno, '
              'algo pasó con la siembra.',
        ),
      ),
      AsyncData(value: final list) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _GarmentRow(garment: list[index]),
      ),
      AsyncError(:final error) => _Failed(
        message: '$error',
        onRetry: () => ref.invalidate(garmentsAdminControllerProvider),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _GarmentRow extends StatelessWidget {
  const _GarmentRow({required this.garment});

  final AdminGarment garment;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: garment.name,
      subtitle: garment.notes,
      leading: AppListCardTile(
        icon: Icons.checkroom_outlined,
        background: garment.isActive ? AppColors.secondary50 : AppColors.gray100,
        foreground: garment.isActive ? AppColors.secondary700 : AppColors.gray400,
      ),
      titleSuffix: garment.isActive
          ? null
          : const AppStatusBadge(
              label: 'Apagada',
              tone: AppStatusTone.neutral,
              size: AppStatusBadgeSize.sm,
            ),
      onTap: () => GarmentFormSheet.show(context, garment: garment),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo leer el catálogo',
        message: message,
        action: AppButton(label: 'Reintentar', onPressed: onRetry),
      ),
    );
  }
}
