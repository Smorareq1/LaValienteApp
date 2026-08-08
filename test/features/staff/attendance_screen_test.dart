import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/time/business_date.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/staff/ui/attendance_screen.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

void main() {
  late AppDatabase database;
  var closed = false;

  final today = isoDate(businessDate());

  /// Misma receta que en las demás pruebas de pantalla: desmontar y dejar correr
  /// el temporizador que drift agenda al cancelar un stream, antes de cerrar.
  void staffTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await database.close();
      closed = true;
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    closed = false;
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    if (!closed) await database.close();
  });

  Future<void> seedEmployee({String name = 'Claudia Pérez'}) {
    return database
        .into(database.employeeEntries)
        .insert(EmployeeEntriesCompanion.insert(id: 'emp-1', fullName: name));
  }

  /// El turno de la mañana del plan 0005: 6:00 a 11:00.
  Future<void> seedShift() {
    return database
        .into(database.workShiftEntries)
        .insert(
          WorkShiftEntriesCompanion.insert(
            id: 'turno-1',
            code: 'morning',
            name: 'Mañana',
            startsAt: '06:00:00',
            endsAt: '11:00:00',
          ),
        );
  }

  Future<void> seedRecord({
    String clockIn = '06:00:00',
    String? clockOut,
    int overtime = 0,
  }) {
    return database
        .into(database.attendanceRecordEntries)
        .insert(
          AttendanceRecordEntriesCompanion.insert(
            id: 'jornada-1',
            employeeId: 'emp-1',
            workDate: today,
            shiftId: const Value('turno-1'),
            clockIn: clockIn,
            clockOut: Value(clockOut),
            overtimeMinutes: Value(overtime),
          ),
        );
  }

  Future<void> seedRate() {
    return database
        .into(database.payrollRateEntries)
        .insert(
          PayrollRateEntriesCompanion.insert(
            id: 'tarifa-1',
            code: 'overtime_hour',
            amount: '20.00',
            validFrom: '2026-01-01',
          ),
        );
  }

  Future<void> open(
    WidgetTester tester, {
    List<String> permissions = const [AppPermissions.all],
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          authControllerProvider.overrideWith(
            () => _FakeAuthController(
              AuthUser(
                id: 'u1',
                username: 'mostrador',
                fullName: 'Marta González',
                roles: const ['admin'],
                permissions: permissions,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AttendanceScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  staffTest('sin personal lo dice en vez de mostrar una lista vacía', (tester) async {
    await open(tester);
    expect(find.text('Todavía no hay personal'), findsOneWidget);
  });

  staffTest('quien no ha marcado aparece igual, con su botón', (tester) async {
    // La pantalla es una lista de personas, no de jornadas: a quien no ha
    // entrado es justo a quien hay que marcarle la entrada.
    await seedEmployee();
    await open(tester);

    expect(find.text('Claudia Pérez'), findsOneWidget);
    // Dos veces: el contador de la cabecera y el estado de la tarjeta. Dicen lo
    // mismo a propósito, así que la prueba no puede pedir una sola.
    expect(find.text('Sin marcar'), findsNWidgets(2));
    expect(find.text('Marcar entrada'), findsOneWidget);
  });

  staffTest('quien entró y no ha salido se muestra trabajando', (tester) async {
    await seedEmployee();
    await seedShift();
    await seedRecord();
    await open(tester);

    expect(find.text('Trabajando desde 6:00'), findsOneWidget);
    expect(find.text('Marcar salida'), findsOneWidget);
  });

  staffTest('una jornada cerrada con hora extra ofrece pagarla', (tester) async {
    // 6:00 a 13:00 sobre un turno de cinco horas: dos horas de más, confirmadas
    // a Q20 la hora.
    await seedEmployee();
    await seedShift();
    await seedRecord(clockOut: '13:00:00', overtime: 120);
    await seedRate();
    await open(tester);

    expect(find.textContaining('Jornada completa'), findsOneWidget);
    expect(find.textContaining('2 h de hora extra'), findsOneWidget);
    expect(find.text('Registrar pago de Q40.00'), findsOneWidget);
  });

  staffTest('sin tarifa vigente no se inventa un monto', (tester) async {
    // Q0.00 afirmaría que la hora extra no se paga. Es un hueco que alguien
    // tiene que llenar dando de alta la tarifa.
    await seedEmployee();
    await seedShift();
    await seedRecord(clockOut: '13:00:00', overtime: 120);
    await open(tester);

    expect(find.textContaining('falta la tarifa del día'), findsOneWidget);
    expect(find.text('Registrar el pago'), findsOneWidget);
  });

  staffTest('sin permiso de marcar, la tarjeta no ofrece botón', (tester) async {
    await seedEmployee();
    await open(tester, permissions: const [AppPermissions.staffRead]);

    expect(find.text('Claudia Pérez'), findsOneWidget);
    expect(find.text('Marcar entrada'), findsNothing);
  });
}
