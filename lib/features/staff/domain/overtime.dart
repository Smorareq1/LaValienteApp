/// Cuánto vale una hora extra (plan 0005 §6.2).
///
/// Gemelo Dart de `BACKEND/src/modules/staff/overtime.py`, por el mismo motivo
/// que `supply_sale_pricing.dart` lo es de `allocation.py`: el mostrador enseña
/// la cifra antes de que el servidor la vea, y una cuenta que no coincide con la
/// del servidor se descubre discutiendo con un empleado sobre su pago.
///
/// Lógica pura: sin base de datos, sin Riverpod, sin widgets. La cadena del plan
/// tiene cuatro eslabones y este archivo es dueño de dos —el sistema **sugiere**
/// los minutos y **valúa** los que alguien confirmó. Confirmar no está aquí, y
/// pagar tampoco: el pago es un gasto del día (D8).
library;

import '../../../core/money/fixed2.dart';

const int _minutesPerHour = 60;

/// Una hora de reloj, como viene del feed: `HH:MM:SS`.
///
/// Es su propio tipo y no un `DateTime` porque una hora de reloj no tiene día ni
/// zona. Meterla en un `DateTime` obligaría a inventarle una fecha y a recordar
/// ignorarla en cada comparación.
class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute);

  final int hour;
  final int minute;

  /// `06:50:00` o `06:50`. Devuelve `null` si el texto no es una hora, que es lo
  /// que pasa cuando alguien todavía no ha marcado salida.
  static ClockTime? parse(String? text) {
    if (text == null) return null;
    final parts = text.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return ClockTime(hour, minute);
  }

  /// El formato del cable: siempre `HH:MM:SS`.
  String get wire =>
      '${_pad(hour)}:${_pad(minute)}:00';

  /// El formato de la pantalla: `6:50`, como se dice en voz alta.
  String get label => '$hour:${_pad(minute)}';

  int get minutesOfDay => hour * _minutesPerHour + minute;

  @override
  int compareTo(ClockTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => wire;

  static String _pad(int value) => value.toString().padLeft(2, '0');
}

/// Minutos de reloj entre dos horas del mismo día.
///
/// Negativo si la segunda viene antes, cosa que quien llama nunca deja pasar: el
/// turno y la jornada lo rechazan en la base (`ends_at > starts_at`,
/// `clock_out > clock_in`). Una jornada que cruza medianoche no es representable
/// con horas de reloj, y los turnos de cinco horas del plan nunca lo hacen.
int minutesBetween(ClockTime start, ClockTime end) =>
    end.minutesOfDay - start.minutesOfDay;

/// Minutos trabajados de más respecto del turno — una sugerencia, nunca una
/// decisión (D8).
///
/// Cero mientras la persona no ha marcado salida, y cero para un rato trabajado
/// fuera de todo turno: no hay duración programada que exceder, así que el
/// sistema no tiene nada que sugerir y le toca a alguien decir qué se debe. Cero
/// aquí significa "no hay sugerencia", que es justo por lo que quien llama lo
/// mantiene separado de los minutos confirmados en vez de escribirlo encima.
int suggestedOvertimeMinutes({
  required ClockTime clockIn,
  ClockTime? clockOut,
  ({ClockTime startsAt, ClockTime endsAt})? shift,
}) {
  if (clockOut == null || shift == null) return 0;
  final worked = minutesBetween(clockIn, clockOut);
  final scheduled = minutesBetween(shift.startsAt, shift.endsAt);
  final extra = worked - scheduled;
  return extra > 0 ? extra : 0;
}

/// Lo que cuestan `minutes` de hora extra a `hourlyRate`, prorrateado al minuto.
///
/// Media hora a Q20 son Q10 —la "Claudia Extra Q10" de la hoja de la que salió
/// el plan—. Prorratear en vez de redondear a la hora completa es política del
/// negocio, leída de esa misma fila.
///
/// Ambos en centavos, como todo el dinero del sistema.
int overtimeAmount({required int minutes, required int hourlyRate}) {
  if (minutes <= 0) return 0;
  // El medio que se suma antes de dividir es lo que convierte la división
  // entera en el redondeo half-up del `money()` del backend.
  return (minutes * hourlyRate * 2 + _minutesPerHour) ~/ (_minutesPerHour * 2);
}

/// Cuánto duró la jornada, o `null` mientras la persona sigue trabajando.
int? workedMinutes({required ClockTime clockIn, ClockTime? clockOut}) =>
    clockOut == null ? null : minutesBetween(clockIn, clockOut);

/// `95` → `1 h 35 min`. Los minutos sueltos no se leen a la primera cuando pasan
/// de una hora, y una hora extra es exactamente lo que se paga.
String formatMinutes(int minutes) {
  if (minutes < _minutesPerHour) return '$minutes min';
  final hours = minutes ~/ _minutesPerHour;
  final rest = minutes % _minutesPerHour;
  return rest == 0 ? '$hours h' : '$hours h $rest min';
}

/// El monto sugerido, ya en texto de dinero, o `null` si no hay tarifa que lo
/// valúe.
///
/// `null` no es gratis: es un hueco que alguien tiene que llenar dando de alta
/// la tarifa, y la pantalla lo dice así en vez de enseñar Q0.00.
String? formatOvertimeAmount({required int minutes, required int? hourlyRate}) {
  if (hourlyRate == null) return null;
  return Fixed2.format(overtimeAmount(minutes: minutes, hourlyRate: hourlyRate));
}
