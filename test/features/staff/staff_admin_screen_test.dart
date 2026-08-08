import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/staff/data/staff_remote_datasource.dart';
import 'package:la_valiente/features/staff/domain/overtime.dart';
import 'package:la_valiente/features/staff/models/staff.dart';
import 'package:la_valiente/features/staff/ui/employees_screen.dart';
import 'package:la_valiente/features/staff/ui/staff_settings_screen.dart';

/// El servidor de personal, de mentira. Estas dos pantallas van **en línea**, así
/// que lo que hay que fingir es la red y no la BD local.
class _FakeRemote implements StaffRemoteDataSource {
  _FakeRemote({
    this.employeeRows = const [],
    this.shiftRows = const [],
    this.rateRows = const [],
  });

  List<Employee> employeeRows;
  List<WorkShift> shiftRows;
  List<PayrollRate> rateRows;

  bool fails = false;

  /// Lo que se mandó registrar, para comprobarlo sin espiar la UI.
  final List<({int amount, String validFrom})> registeredRates = [];

  @override
  Future<List<Employee>> employees() async {
    if (fails) throw Exception('sin red');
    return employeeRows;
  }

  @override
  Future<List<WorkShift>> shifts() async {
    if (fails) throw Exception('sin red');
    return shiftRows;
  }

  @override
  Future<List<PayrollRate>> rates({String code = PayrollRate.overtimeCode}) async {
    if (fails) throw Exception('sin red');
    return rateRows;
  }

  /// Vacío a propósito: es lo que devuelve el servidor real cuando quien abre
  /// el formulario no puede listar cuentas, y el campo tiene que decirlo en vez
  /// de enseñar un desplegable sin opciones.
  @override
  Future<List<SystemUser>> users() async => const [];

  @override
  Future<PayrollRate> registerRate({
    required int amount,
    required String validFrom,
    String code = PayrollRate.overtimeCode,
  }) async {
    registeredRates.add((amount: amount, validFrom: validFrom));
    return PayrollRate(
      id: 'tarifa-nueva',
      code: code,
      amount: amount,
      validFrom: validFrom,
      version: 1,
    );
  }

  @override
  Future<Employee> createEmployee(EmployeeInput input) async =>
      throw UnimplementedError();

  @override
  Future<Employee> updateEmployee(String id, EmployeeInput input) async =>
      throw UnimplementedError();

  @override
  Future<WorkShift> createShift(ShiftInput input) async => throw UnimplementedError();

  @override
  Future<WorkShift> updateShift(String id, ShiftInput input) async =>
      throw UnimplementedError();
}

Employee _employee({
  required String id,
  required String name,
  String? phone,
  String? userId,
  bool active = true,
}) {
  return Employee(
    id: id,
    fullName: name,
    isActive: active,
    version: 1,
    phone: phone,
    userId: userId,
  );
}

WorkShift _shift({
  required String id,
  required String name,
  required ClockTime from,
  required ClockTime to,
  bool active = true,
}) {
  return WorkShift(
    id: id,
    code: id,
    name: name,
    startsAt: from,
    endsAt: to,
    isActive: active,
    sortOrder: 0,
    version: 1,
  );
}

Future<void> _pump(WidgetTester tester, _FakeRemote remote, Widget screen) async {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [staffRemoteDataSourceProvider.overrideWithValue(remote)],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('empleados', () {
    testWidgets('sin personal lo dice en vez de dejar la lista vacía', (tester) async {
      await _pump(tester, _FakeRemote(), const EmployeesScreen());
      expect(find.text('Todavía no hay personal'), findsOneWidget);
    });

    testWidgets('quien está de baja sigue en la lista, marcado', (tester) async {
      // Dar de baja no borra: la asistencia y las horas extra ya pagadas apuntan
      // a esa persona. Esconderla la volvería imposible de reactivar.
      final remote = _FakeRemote(
        employeeRows: [
          _employee(id: 'e1', name: 'Claudia Pérez'),
          _employee(id: 'e2', name: 'Rosa Méndez', active: false),
        ],
      );
      await _pump(tester, remote, const EmployeesScreen());

      expect(find.text('Rosa Méndez'), findsOneWidget);
      expect(find.text('De baja'), findsOneWidget);
    });

    testWidgets('quien tiene cuenta lo dice, porque es la excepción', (tester) async {
      final remote = _FakeRemote(
        employeeRows: [
          _employee(id: 'e1', name: 'Marta González', phone: '5555 5555', userId: 'u1'),
        ],
      );
      await _pump(tester, remote, const EmployeesScreen());

      expect(find.text('5555 5555 · entra al sistema'), findsOneWidget);
    });

    testWidgets('sin red se dice y se ofrece reintentar', (tester) async {
      // Una lista vacía aquí se leería como "no hay personal", que es lo
      // contrario de lo que pasa.
      final remote = _FakeRemote()..fails = true;
      await _pump(tester, remote, const EmployeesScreen());

      expect(find.text('No se pudo leer el personal'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('turnos y tarifas', () {
    testWidgets('un turno se lee con su ventana y su duración', (tester) async {
      final remote = _FakeRemote(
        shiftRows: [
          _shift(
            id: 'morning',
            name: 'Mañana',
            from: const ClockTime(6, 0),
            to: const ClockTime(11, 0),
          ),
        ],
      );
      await _pump(tester, remote, const StaffSettingsScreen());

      expect(find.text('Mañana'), findsOneWidget);
      expect(find.text('6:00 a 11:00 · 5 h'), findsOneWidget);
    });

    testWidgets('la tarifa vigente se distingue del historial', (tester) async {
      // La vieja no se borra: una jornada de marzo se valúa con la tarifa de
      // marzo, y por eso la ventana cerrada sigue a la vista.
      final remote = _FakeRemote(
        rateRows: [
          PayrollRate(
            id: 'r2',
            code: PayrollRate.overtimeCode,
            amount: 2500,
            validFrom: '2026-06-01',
            version: 1,
          ),
          PayrollRate(
            id: 'r1',
            code: PayrollRate.overtimeCode,
            amount: 2000,
            validFrom: '2026-01-01',
            validTo: '2026-05-31',
            version: 1,
          ),
        ],
      );
      await _pump(tester, remote, const StaffSettingsScreen());

      expect(find.text('Q25.00 la hora'), findsOneWidget);
      expect(find.text('Vigente'), findsOneWidget);
      expect(find.text('Del 2026-01-01 al 2026-05-31'), findsOneWidget);
    });

    testWidgets('sin tarifa lo explica en vez de callarlo', (tester) async {
      await _pump(tester, _FakeRemote(), const StaffSettingsScreen());
      expect(find.textContaining('No hay tarifa'), findsOneWidget);
    });

    testWidgets('registrar una tarifa manda el monto en centavos', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, remote, const StaffSettingsScreen());

      await tester.tap(find.text('Nueva'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppTextField).first, '22.50');
      await tester.tap(find.text('Registrar tarifa'));
      await tester.pumpAndSettle();

      // Q22.50 son 2250 centavos: el dinero no pasa por un double en ningún
      // punto del camino.
      expect(remote.registeredRates.single.amount, 2250);
    });

    testWidgets('una tarifa en cero se rechaza antes de salir', (tester) async {
      final remote = _FakeRemote();
      await _pump(tester, remote, const StaffSettingsScreen());

      await tester.tap(find.text('Nueva'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(AppTextField).first, '0');
      await tester.tap(find.text('Registrar tarifa'));
      await tester.pumpAndSettle();

      expect(find.text('La tarifa tiene que ser mayor que cero'), findsOneWidget);
      expect(remote.registeredRates, isEmpty);
    });
  });
}
