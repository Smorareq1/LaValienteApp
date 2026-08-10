import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/customer.dart';
import '../state/customers_controller.dart';
import 'widgets/customer_form_sheet.dart';
import 'widgets/customer_initials.dart';

/// Lista de clientes (Plan 0006 §6.1).
///
/// Lee de la BD local, así que funciona igual sin señal y la búsqueda no
/// espera a nadie (plan 0004 D1).
class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  static const String path = '/customers';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(customerSearchResultsProvider);
    final query = ref.watch(customerSearchQueryProvider);

    return Stack(
      children: [
        Column(
          children: [
            _CustomersHeader(
              onSearch: (value) =>
                  ref.read(customerSearchQueryProvider.notifier).update(value),
            ),
            Expanded(
              child: switch (results) {
                AsyncData(:final value) => _CustomerList(
                    customers: value,
                    query: query,
                  ),
                AsyncError(:final error) => _LoadError(message: '$error'),
                _ => const _ListSkeleton(),
              },
            ),
          ],
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _NewCustomerBar(),
        ),
      ],
    );
  }
}

class _CustomersHeader extends ConsumerWidget {
  const _CustomersHeader({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(customerCountProvider).valueOrNull;

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total == null
                ? ''
                : '$total ${total == 1 ? 'registrado' : 'registrados'}',
            style: AppTypography.bodySm.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary100,
            ),
          ),
          Text(
            'Clientes',
            style: AppTypography.h3.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 14),
          AppSearchField(
            hintText: 'Nombre o teléfono…',
            onChanged: onSearch,
          ),
        ],
      ),
    );
  }
}

class _CustomerList extends StatelessWidget {
  const _CustomerList({required this.customers, required this.query});

  final List<Customer> customers;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 150),
        child: query.isEmpty
            ? const _NoCustomersYet()
            : _NoMatches(query: query),
      );
    }

    // El tope se avisa en vez de esconderse: una lista cortada en silencio
    // hace pensar que un cliente no existe.
    final truncated = customers.length >= customerListLimit;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 150),
      itemCount: customers.length + (truncated ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        if (index == customers.length) return const _TruncatedNotice();
        return _CustomerCard(customer: customers[index]);
      },
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (customer.phone != null) customer.phone!,
      if (customer.nit != null) 'NIT ${customer.nit}',
    ];

    return AppListCard(
      title: customer.fullName,
      subtitle: details.isEmpty ? 'Sin teléfono ni NIT' : details.join(' · '),
      leading: CustomerInitials(name: customer.fullName),
      titleSuffix: switch (customer) {
        Customer(needsReview: true) => const Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: AppColors.errorText,
          ),
        Customer(isPending: true) => const Icon(
            Icons.schedule_rounded,
            size: 13,
            color: AppColors.warningText,
          ),
        _ => null,
      },
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.gray300,
      ),
      onTap: () => context.push('${CustomersScreen.path}/${customer.id}'),
    );
  }
}

class _TruncatedNotice extends StatelessWidget {
  const _TruncatedNotice();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Se muestran los primeros $customerListLimit. '
        'Busca por nombre o teléfono para encontrar el resto.',
        textAlign: TextAlign.center,
        style: AppTypography.helper.copyWith(fontSize: 12),
      ),
    );
  }
}

class _NoCustomersYet extends StatelessWidget {
  const _NoCustomersYet();

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.people_outline,
      title: 'Todavía no hay clientes',
      message: 'Se registran al recibir el primer pedido, o desde aquí.',
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: 'Nadie coincide con "$query"',
      message: 'Prueba con menos letras, o con el teléfono.',
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    // Skeletons y no spinner de pantalla completa (§14).
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 150),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) => Container(
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 150),
      child: AppEmptyState(
        icon: Icons.storage_rounded,
        title: 'No se pudo leer la lista',
        message: message,
      ),
    );
  }
}

/// Acción primaria fija sobre la barra inferior, como en la maqueta.
class _NewCustomerBar extends StatelessWidget {
  const _NewCustomerBar();

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      anyOf: const [AppPermissions.customersCreate],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: AppButton(
          label: 'Nuevo cliente',
          icon: const Icon(Icons.add_rounded),
          size: AppButtonSize.lg,
          fullWidth: true,
          elevated: true,
          onPressed: () => CustomerFormSheet.show(context),
        ),
      ),
    );
  }
}
