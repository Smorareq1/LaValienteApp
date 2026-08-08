import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/staff/domain/overtime.dart';

/// Las cifras salen de la hoja de Registro Diario del 18/07/26, que es de donde
/// salió el plan 0005: turno de la mañana de 6:00 a 11:00 y la hora extra a Q20.
const _rate = 2000; // Q20.00 la hora, en centavos.
const _morning = (startsAt: ClockTime(6, 0), endsAt: ClockTime(11, 0));

void main() {
  group('la hora de reloj', () {
    test('entiende el formato del cable y el corto', () {
      expect(ClockTime.parse('06:50:00'), const ClockTime(6, 50));
      expect(ClockTime.parse('06:50'), const ClockTime(6, 50));
    });

    test('sin salida marcada no hay hora que interpretar', () {
      expect(ClockTime.parse(null), isNull);
      expect(ClockTime.parse(''), isNull);
      expect(ClockTime.parse('25:00:00'), isNull);
    });

    test('sale al cable con ceros y a la pantalla sin ellos', () {
      expect(const ClockTime(6, 50).wire, '06:50:00');
      expect(const ClockTime(6, 50).label, '6:50');
      expect(const ClockTime(13, 5).label, '13:05');
    });
  });

  group('la sugerencia', () {
    test('son los minutos trabajados de más sobre el turno', () {
      // Entró a las 6:00 y salió a las 13:00: ocho horas contra un turno de
      // cinco.
      expect(
        suggestedOvertimeMinutes(
          clockIn: const ClockTime(6, 0),
          clockOut: const ClockTime(13, 0),
          shift: _morning,
        ),
        120,
      );
    });

    test('quien todavía trabaja no tiene minutos extra', () {
      expect(
        suggestedOvertimeMinutes(clockIn: const ClockTime(6, 0), shift: _morning),
        0,
      );
    });

    test('sin turno no hay nada que exceder, así que no se sugiere nada', () {
      // No es que la persona no haya trabajado de más: es que el sistema no
      // sabe contra qué medirlo y le toca decirlo a alguien.
      expect(
        suggestedOvertimeMinutes(
          clockIn: const ClockTime(6, 0),
          clockOut: const ClockTime(16, 0),
        ),
        0,
      );
    });

    test('salir antes no deja minutos negativos', () {
      expect(
        suggestedOvertimeMinutes(
          clockIn: const ClockTime(6, 0),
          clockOut: const ClockTime(9, 30),
          shift: _morning,
        ),
        0,
      );
    });
  });

  group('el monto', () {
    test('media hora a Q20 son Q10 — la fila de la hoja', () {
      expect(overtimeAmount(minutes: 30, hourlyRate: _rate), 1000);
    });

    test('se prorratea al minuto, no se redondea a la hora', () {
      // Diez minutos son Q3.33 y no una hora completa: es política del negocio,
      // leída de la hoja.
      expect(overtimeAmount(minutes: 10, hourlyRate: _rate), 333);
      expect(overtimeAmount(minutes: 50, hourlyRate: _rate), 1667);
    });

    test('el medio centavo sube, como el money() del servidor', () {
      // Un minuto a Q0.90 la hora son Q0.015 exactos.
      expect(overtimeAmount(minutes: 1, hourlyRate: 90), 2);
    });

    test('cero minutos no cuestan nada, ni siquiera un centavo de redondeo', () {
      expect(overtimeAmount(minutes: 0, hourlyRate: _rate), 0);
      expect(overtimeAmount(minutes: -30, hourlyRate: _rate), 0);
    });

    test('sin tarifa vigente no hay monto, y eso no es Q0.00', () {
      // Un hueco que alguien tiene que llenar dando de alta la tarifa. Enseñar
      // cero sería afirmar que la hora extra no se paga.
      expect(formatOvertimeAmount(minutes: 120, hourlyRate: null), isNull);
      expect(formatOvertimeAmount(minutes: 120, hourlyRate: _rate), '40.00');
    });
  });

  group('lo que se lee en pantalla', () {
    test('los minutos se dicen en horas cuando pasan de una', () {
      expect(formatMinutes(45), '45 min');
      expect(formatMinutes(60), '1 h');
      expect(formatMinutes(95), '1 h 35 min');
      expect(formatMinutes(120), '2 h');
    });

    test('la jornada abierta no tiene duración todavía', () {
      expect(workedMinutes(clockIn: const ClockTime(6, 0)), isNull);
      expect(
        workedMinutes(clockIn: const ClockTime(6, 0), clockOut: const ClockTime(13, 0)),
        420,
      );
    });
  });
}
