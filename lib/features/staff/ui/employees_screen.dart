import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shell/ui/widgets/gradient_header.dart';
import '../models/staff.dart';
import '../state/staff_admin_controller.dart';
import 'widgets/employee_form_sheet.dart';

/// Empleados (Plan 0006 §9.2).
///
/// **En línea**: dar de alta a alguien no es captura de mostrador, se decide una
/// vez y baja al dispositivo por el feed (plan 0005 D11). Sin red se dice y se
/// ofrece reintentar, que es lo que el §14 pide de las pantallas de gestión.
class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  static const String path = '/staff/employees';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesAdminControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(active: employees.valueOrNull?.where((e) => e.isActive).length),
          Expanded(
            child: switch (employees) {
              AsyncData(:final value) => _List(employees: value),
              AsyncError(:final error) => _LoadError(
                message: '$error',
                onRetry: () => ref.invalidate(employeesAdminControllerProvider),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => EmployeeFormSheet.show(context),
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text('Empleado'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.active});

  final int? active;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Row(
        children: [
          const _Back(),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active == null ? '' : '$active trabajando aquí',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  'Empleados',
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

class _List extends StatelessWidget {
  const _List({required this.employees});

  final List<Employee> employees;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: AppEmptyState(
          icon: Icons.groups_outlined,
          title: 'Todavía no hay personal',
          message:
              'Da de alta a quien trabaja aquí y aparecerá en la asistencia '
              'del día para marcarle entrada y salida.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      itemCount: employees.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _EmployeeRow(employee: employees[index]),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return AppListCard(
      title: employee.fullName,
      subtitle: switch ((employee.phone, employee.hasAccount)) {
        (final String phone, true) => '$phone · entra al sistema',
        (final String phone, false) => phone,
        (null, true) => 'Entra al sistema',
        _ => 'Sin teléfono',
      },
      leading: AppListCardTile(
        label: employee.initials,
        background: employee.isActive ? AppColors.primary50 : AppColors.gray100,
        foreground: employee.isActive ? AppColors.primary700 : AppColors.gray400,
      ),
      titleSuffix: employee.isActive
          ? null
          : const AppStatusBadge(
              label: 'De baja',
              tone: AppStatusTone.neutral,
              size: AppStatusBadgeSize.sm,
            ),
      onTap: () => EmployeeFormSheet.show(context, employee: employee),
    );
  }
}

/// Sin red esta pantalla no tiene nada que enseñar, y decirlo es más honesto que
/// una lista vacía que parecería que no hay personal.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo leer el personal',
        message: message,
        action: AppButton(label: 'Reintentar', onPressed: onRetry),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: 'Volver',
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
    );
  }
}
