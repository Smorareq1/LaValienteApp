import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../data/customers_repository.dart';
import '../models/customer.dart';
import '../state/customers_controller.dart';
import 'customers_screen.dart';
import 'widgets/customer_form_sheet.dart';
import 'widgets/customer_initials.dart';

/// Detalle de un cliente (Plan 0006 §6.2).
class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  static String pathFor(String id) => '/customers/$id';

  /// Vuelve atrás, o a la lista si no hay atrás: un enlace profundo abre esta
  /// pantalla sin nada debajo, y ahí `pop` no lleva a ningún lado.
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(CustomersScreen.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerByIdProvider(customerId));

    return switch (customer) {
      AsyncData(value: final found?) => _Detail(customer: found),
      // Sucede al archivarlo desde otro dispositivo, o al abrir un enlace
      // viejo. No es un error: el cliente simplemente ya no está.
      AsyncData() => const _Missing(),
      AsyncError(:final error) => _Missing(message: '$error'),
      _ => const _DetailSkeleton(),
    };
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.customer});

  final Customer customer;

  Future<void> _edit(BuildContext context) =>
      CustomerFormSheet.show(context, customer: customer);

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: 'Archivar a ${customer.fullName}',
      message: 'Deja de aparecer en las búsquedas y no se le podrán tomar '
          'pedidos nuevos. Sus pedidos anteriores se conservan.',
      confirmLabel: 'Archivar',
      destructive: true,
      icon: Icons.archive_outlined,
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref.read(customersRepositoryProvider).archive(customer);
    if (!context.mounted) return;

    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => CustomerDetailScreen.goBack(context),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _DetailHeader(customer: customer, onEdit: () => _edit(context)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              _DataCard(customer: customer),
              const SizedBox(height: 12),
              const AppSectionHeader(title: 'Pedidos recientes'),
              const _OrdersPlaceholder(),
              const SizedBox(height: 20),
              PermissionGate(
                anyOf: const [AppPermissions.customersArchive],
                child: _ArchiveButton(onPressed: () => _archive(context, ref)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.customer, required this.onEdit});

  final Customer customer;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderAction(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Volver',
                onPressed: () => CustomerDetailScreen.goBack(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cliente',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary100,
                  ),
                ),
              ),
              PermissionGate(
                anyOf: const [AppPermissions.customersUpdate],
                child: _HeaderAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Editar',
                  onPressed: onEdit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CustomerInitials(name: customer.fullName, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: AppTypography.h3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                    if (customer.isPending || customer.needsReview) ...[
                      const SizedBox(height: 5),
                      _SyncNotice(customer: customer),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado de sincronización de la ficha. Se dice, no se esconde: quien capturó
/// al cliente sin señal tiene que poder ver que todavía no ha subido.
class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = customer.needsReview
        ? (Icons.error_outline_rounded, 'Necesita revisión')
        : (Icons.schedule_rounded, 'Sin sincronizar');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.22),
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 18,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (customer.phone != null)
        _DataRow(
          icon: Icons.phone_outlined,
          value: customer.phone!,
          copyable: true,
        ),
      if (customer.nit != null)
        _DataRow(icon: Icons.receipt_long_outlined, value: 'NIT ${customer.nit}'),
      if (customer.email != null)
        _DataRow(icon: Icons.mail_outline_rounded, value: customer.email!),
      if (customer.address != null)
        _DataRow(icon: Icons.place_outlined, value: customer.address!),
      if (customer.notes != null)
        _DataRow(icon: Icons.sticky_note_2_outlined, value: customer.notes!),
    ];

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos',
            style: AppTypography.h3.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Text(
              'Solo tenemos el nombre. Toca el lápiz para agregar el teléfono.',
              style: AppTypography.helper.copyWith(fontSize: 12.5),
            )
          else
            for (final (index, row) in rows.indexed) ...[
              if (index > 0) const SizedBox(height: 10),
              row,
            ],
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.value,
    this.copyable = false,
  });

  final IconData icon;
  final String value;

  /// Copiar el teléfono ahorra dictárselo a otro teléfono a mano.
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gray400),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
        if (copyable)
          const Icon(Icons.copy_rounded, size: 15, color: AppColors.gray300),
      ],
    );

    if (!copyable) return row;

    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teléfono copiado')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}

/// Los pedidos del cliente llegan con UI 4. Se deja el hueco dicho en vez de
/// omitirlo: quien abre la ficha espera verlos, y una sección ausente parece
/// un error de la app.
class _OrdersPlaceholder extends StatelessWidget {
  const _OrdersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.local_mall_outlined,
      title: 'Aún no se ven los pedidos',
      message: 'El historial y el saldo de este cliente aparecerán aquí '
          'cuando entre el módulo de Pedidos.',
      dense: true,
    );
  }
}

class _ArchiveButton extends StatelessWidget {
  const _ArchiveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDA29B), width: 1.5),
          ),
          padding: const EdgeInsets.all(13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.archive_outlined, size: 17, color: AppColors.errorText),
              const SizedBox(width: 8),
              Text(
                'Archivar cliente',
                style: AppTypography.button(fontSize: 14, color: AppColors.errorText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hueco mientras la BD responde. Un esqueleto y no un spinner de pantalla
/// completa (§14): la lectura es local y dura un parpadeo, y una rueda girando
/// hace pensar que se está esperando a la red.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientHeader(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: SizedBox(height: 84, width: double.infinity),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppEmptyState(
          icon: Icons.person_off_outlined,
          title: 'Este cliente ya no está',
          message: message ?? 'Se archivó, o el enlace apunta a alguien que ya no existe.',
          action: AppButton(
            label: 'Volver a la lista',
            variant: AppButtonVariant.outline,
            onPressed: () => CustomerDetailScreen.goBack(context),
          ),
        ),
      ),
    );
  }
}
