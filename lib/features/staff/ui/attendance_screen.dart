import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/time/business_date.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../cash/data/expenses_repository.dart';
import '../../cash/models/expense.dart';
import '../../cash/state/cash_day_controller.dart';
import '../../cash/ui/widgets/expense_sheet.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../data/attendance_repository.dart';
import '../domain/overtime.dart';
import '../models/staff.dart';
import '../state/attendance_controller.dart';
import 'employees_screen.dart';
import 'staff_settings_screen.dart';
import 'widgets/clock_sheet.dart';
import 'widgets/date_chip.dart';

/// Asistencia del día (Plan 0006 §9.1).
///
/// Sustituye el "Entró 6:50 / Salió 13:00" que hoy se escribe en el campo de
/// observaciones de la hoja. Es una lista de **personas**, no de jornadas: quien
/// todavía no ha entrado es justamente a quien hay que marcarle la entrada, así
/// que aparece igual, con su botón.
///
/// Funciona sin señal: las dos operaciones que salen de aquí van al outbox como
/// cualquier captura del mostrador (plan 0005 §6.4).
class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  static const String path = '/staff';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(attendanceDateFilterProvider);
    final days = ref.watch(attendanceDayProvider(isoDate(date)));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(date: date, days: days.valueOrNull ?? const []),
          Expanded(
            child: switch (days) {
              AsyncError(:final error) => _Failed(error: '$error'),
              AsyncData(:final value) when value.isEmpty => const _NoStaff(),
              AsyncData(:final value) => _StaffList(days: value, date: date),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.date, required this.days});

  final DateTime date;
  final List<EmployeeDay> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = businessDate();
    final working = days
        .where((day) => day.state == AttendanceState.working)
        .length;
    final complete = days
        .where((day) => day.state == AttendanceState.complete)
        .length;
    final unmarked = days.length - working - complete;

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Back(),
              Expanded(
                child: Text(
                  'Asistencia',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              const _AdminMenu(),
              DateChip(
                date: date,
                today: today,
                helpText: 'Día de la jornada',
                onChanged: (value) => ref
                    .read(attendanceDateFilterProvider.notifier)
                    .update(value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Count(
                  label: 'Trabajando',
                  value: working,
                  icon: Icons.bolt_rounded,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Count(
                  label: 'Completas',
                  value: complete,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Count(
                  label: 'Sin marcar',
                  value: unmarked,
                  icon: Icons.remove_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, required this.icon});

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.primary100),
          const SizedBox(height: 5),
          Text(
            '$value',
            style: AppTypography.h3.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          Text(
            label,
            style: AppTypography.helper.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary100,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffList extends StatelessWidget {
  const _StaffList({required this.days, required this.date});

  final List<EmployeeDay> days;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, index) =>
          _EmployeeCard(day: days[index], date: date),
    );
  }
}

/// La tarjeta de una persona: su estado del día y lo único que se puede hacer
/// con ella ahora mismo.
class _EmployeeCard extends ConsumerWidget {
  const _EmployeeCard({required this.day, required this.date});

  final EmployeeDay day;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(
                initials: day.employee.initials,
                style: switch (day.state) {
                  AttendanceState.working => AppAvatarStyle.secondary,
                  _ => AppAvatarStyle.primary,
                },
                size: 40,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.employee.fullName,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.stateLabel,
                      style: AppTypography.bodySm.copyWith(
                        color: switch (day.state) {
                          AttendanceState.working => AppColors.secondary700,
                          AttendanceState.unmarked => AppColors.textSecondary,
                          AttendanceState.complete => AppColors.textSecondary,
                        },
                        fontWeight: day.state == AttendanceState.working
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Lo que se capturó aquí y todavía no subió. Se marca en su fila en
              // vez de esconderse: el mostrador tiene que poder distinguir lo que
              // el servidor ya sabe de lo que solo sabe este teléfono.
              if (day.record?.isPending ?? false)
                const AppStatusBadge(
                  label: 'Sin subir',
                  tone: AppStatusTone.warning,
                  size: AppStatusBadgeSize.sm,
                ),
            ],
          ),
          if (day.state == AttendanceState.complete) ...[
            const SizedBox(height: 10),
            _CompletedRow(day: day),
          ],
          const SizedBox(height: 11),
          _Actions(day: day, date: date),
        ],
      ),
    );
  }
}

/// El resumen de una jornada cerrada: cuánto trabajó y qué hora extra quedó
/// confirmada.
class _CompletedRow extends StatelessWidget {
  const _CompletedRow({required this.day});

  final EmployeeDay day;

  @override
  Widget build(BuildContext context) {
    final record = day.record!;
    final worked = day.workedMinutes;
    final amount = day.confirmedOvertimeAmount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'De ${record.clockIn.label} a ${record.clockOut!.label}'
            '${worked == null ? '' : ' · ${formatMinutes(worked)}'}',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (day.awaitsOvertimePayment) ...[
            const SizedBox(height: 3),
            Text(
              amount == null
                  // Sin tarifa no se puede valuar, y decir Q0.00 sería afirmar
                  // que la hora extra no se paga.
                  ? '${formatMinutes(record.overtimeMinutes)} de hora extra · falta '
                        'la tarifa del día'
                  : '${formatMinutes(record.overtimeMinutes)} de hora extra · Q$amount',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.secondary700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lo que se puede hacer con esta persona hoy. Una sola acción a la vez, porque
/// el día solo puede estar en un estado.
class _Actions extends ConsumerWidget {
  const _Actions({required this.day, required this.date});

  final EmployeeDay day;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PermissionGate(
      anyOf: const [AppPermissions.attendanceRecord],
      child: switch (day.state) {
        AttendanceState.unmarked => AppButton(
          label: 'Marcar entrada',
          icon: const Icon(Icons.login_rounded),
          variant: AppButtonVariant.outline,
          fullWidth: true,
          onPressed: () => _clockIn(context, ref),
        ),
        AttendanceState.working => AppButton(
          label: 'Marcar salida',
          icon: const Icon(Icons.logout_rounded),
          fullWidth: true,
          onPressed: () => _clockOut(context, ref),
        ),
        // La jornada ya está cerrada. Lo único que queda por hacer es pagar la
        // hora extra que se confirmó, y solo si se confirmó alguna.
        AttendanceState.complete =>
          day.awaitsOvertimePayment
              ? _OvertimeCta(day: day, date: date)
              : const SizedBox.shrink(),
      },
    );
  }

  Future<void> _clockIn(BuildContext context, WidgetRef ref) async {
    final shifts =
        ref.read(workShiftsProvider).valueOrNull ?? const <WorkShift>[];
    final now = DateTime.now();

    final draft = await ClockInSheet.show(
      context,
      employee: day.employee,
      shifts: shifts,
      now: ClockTime(now.hour, now.minute),
    );
    if (draft == null || !context.mounted) return;

    final result = await ref
        .read(attendanceRepositoryProvider)
        .clockIn(
          employeeId: day.employee.id,
          workDate: isoDate(date),
          clockIn: draft.at,
          shiftId: draft.shiftId,
          notes: draft.notes,
        );
    if (!context.mounted) return;

    result.match(
      (failure) => _tell(context, failure.message),
      (record) => _tell(
        context,
        '${day.employee.fullName} entró a las ${record.clockIn.label}',
      ),
    );
  }

  Future<void> _clockOut(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();

    final draft = await ClockOutSheet.show(
      context,
      day: day,
      now: ClockTime(now.hour, now.minute),
    );
    if (draft == null || !context.mounted) return;

    final result = await ref
        .read(attendanceRepositoryProvider)
        .clockOut(
          day.record!,
          at: draft.at,
          overtimeMinutes: draft.overtimeMinutes,
        );
    if (!context.mounted) return;

    result.match(
      (failure) => _tell(context, failure.message),
      (record) => _tell(
        context,
        record.overtimeMinutes > 0
            ? 'Jornada cerrada con ${formatMinutes(record.overtimeMinutes)} de hora extra'
            : 'Jornada cerrada',
      ),
    );
  }

  static void _tell(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// El puente del §9.1 al §7.2: la hora extra confirmada se paga como un gasto
/// del día (plan 0005 D8).
///
/// El gasto se anota desde aquí y no manda a la Caja a empezar de cero: quién,
/// qué jornada y cuántos minutos ya están decididos en esta pantalla, y volver a
/// preguntarlos sería hacer teclear dos veces lo mismo.
class _OvertimeCta extends ConsumerWidget {
  const _OvertimeCta({required this.day, required this.date});

  final EmployeeDay day;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = day.confirmedOvertimeAmount;

    return PermissionGate(
      anyOf: const [AppPermissions.expensesCreate],
      child: AppButton(
        label: amount == null
            ? 'Registrar el pago'
            : 'Registrar pago de Q$amount',
        icon: const Icon(Icons.payments_outlined),
        variant: AppButtonVariant.outline,
        fullWidth: true,
        onPressed: () => _pay(context, ref),
      ),
    );
  }

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final categories =
        ref.read(cashExpensesCategoriesProvider).valueOrNull ??
        const <ExpenseCategory>[];
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    final draft = await ExpenseSheet.show(
      context,
      categories: categories,
      date: date,
      prefill: OvertimePrefill(
        employeeId: day.employee.id,
        employeeName: day.employee.fullName,
        attendanceRecordId: day.record!.id,
        minutes: day.confirmedOvertimeMinutes,
        amount: day.hourlyRate == null
            ? null
            : overtimeAmount(
                minutes: day.confirmedOvertimeMinutes,
                hourlyRate: day.hourlyRate!,
              ),
      ),
    );
    if (draft == null || !context.mounted) return;

    final result = await ref
        .read(expensesRepositoryProvider)
        .create(draft, createdById: user.id);
    if (!context.mounted) return;

    result.match(
      (failure) => _Actions._tell(context, failure.message),
      (expense) => _Actions._tell(
        context,
        'Pago registrado en la caja del día por Q${Fixed2.format(expense.amount)}',
      ),
    );
  }
}

class _NoStaff extends StatelessWidget {
  const _NoStaff();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.badge_outlined,
        title: 'Todavía no hay personal',
        message:
            'Los empleados se dan de alta en Personal › Empleados, y bajan a este '
            'teléfono en la siguiente sincronización.',
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudo leer la asistencia',
        message: error,
      ),
    );
  }
}

/// Volver a «Más», de donde se llega a esta pantalla.
/// La entrada a las dos pantallas de administración (§9.2 y §9.3).
///
/// Vive aquí y no en «Más» porque es donde se cae en cuenta de que hacen falta:
/// alguien que no está en la lista, o una hora extra que no se puede valuar
/// porque nadie ha dado de alta la tarifa.
class _AdminMenu extends StatelessWidget {
  const _AdminMenu();

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      anyOf: const [AppPermissions.staffManage],
      child: PopupMenuButton<String>(
        tooltip: 'Administrar',
        icon: const Icon(Icons.more_vert_rounded, color: AppColors.white),
        onSelected: (path) => context.push(path),
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: EmployeesScreen.path,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.groups_outlined),
              title: Text('Empleados'),
            ),
          ),
          PopupMenuItem(
            value: StaffSettingsScreen.path,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.schedule_rounded),
              title: Text('Turnos y tarifas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Volver',
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      ),
    );
  }
}
