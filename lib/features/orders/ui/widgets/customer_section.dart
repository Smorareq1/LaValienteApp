import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/ui/widgets/permission_gate.dart';
import '../../../../core/auth/app_permissions.dart';
import '../../../customers/data/customers_repository.dart';
import '../../../customers/models/customer.dart';
import '../../../customers/ui/widgets/customer_form_sheet.dart';
import '../../../customers/ui/widgets/customer_initials.dart';

/// Sección [2] de la boleta: quién trae la ropa (plan 0002 §3.2).
///
/// Busca contra la BD local, igual que la pantalla de Clientes: el mostrador
/// tiene que poder encontrar a alguien sin señal, y quien acaba de darse de alta
/// hace diez segundos aparece aquí aunque el servidor todavía no lo sepa.
class CustomerSection extends ConsumerStatefulWidget {
  const CustomerSection({
    super.key,
    required this.customer,
    required this.onChanged,
  });

  final Customer? customer;
  final ValueChanged<Customer?> onChanged;

  @override
  ConsumerState<CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends ConsumerState<CustomerSection> {
  String _query = '';

  Future<void> _createCustomer() async {
    final created = await CustomerFormSheet.show(context);
    if (created != null) widget.onChanged(created);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.customer;
    if (selected != null) {
      return _SelectedCustomer(
        customer: selected,
        onChange: () {
          setState(() => _query = '');
          widget.onChanged(null);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AppSearchField(
            hintText: 'Buscar por nombre o teléfono…',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: 10),
        _Results(query: _query, onPick: widget.onChanged),
        const SizedBox(height: 10),
        PermissionGate(
          anyOf: const [AppPermissions.customersCreate],
          child: AppButton(
            label: 'Cliente nuevo',
            variant: AppButtonVariant.outline,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            fullWidth: true,
            onPressed: _createCustomer,
          ),
        ),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query, required this.onPick});

  final String query;
  final ValueChanged<Customer> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sin texto se muestran los primeros clientes igual: en una lavandería de
    // barrio los mismos nombres se repiten todos los días, y tener los más
    // recientes a mano ahorra teclear.
    final customers = ref.watch(customersRepositoryProvider).watch(query: query, limit: 6);

    return StreamBuilder<List<Customer>>(
      stream: customers,
      builder: (context, snapshot) {
        final results = snapshot.data ?? const <Customer>[];
        if (results.isEmpty) {
          return Text(
            snapshot.connectionState == ConnectionState.waiting
                ? 'Buscando…'
                : 'Nadie con ese nombre. Podés darlo de alta aquí mismo.',
            style: AppTypography.helper.copyWith(fontSize: 12),
          );
        }

        return Column(
          children: [
            for (final customer in results)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _CustomerRow(customer: customer, onTap: () => onPick(customer)),
              ),
          ],
        );
      },
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray50,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              CustomerInitials(name: customer.fullName, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      customer.phone ?? 'Sin teléfono',
                      style: AppTypography.helper.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.gray300),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCustomer extends StatelessWidget {
  const _SelectedCustomer({required this.customer, required this.onChange});

  final Customer customer;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        children: [
          CustomerInitials(name: customer.fullName, size: 38),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  [
                    customer.phone ?? 'Sin teléfono',
                    if (customer.nit != null) 'NIT ${customer.nit}',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.helper.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Cambiar',
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.sm,
            onPressed: onChange,
          ),
        ],
      ),
    );
  }
}
