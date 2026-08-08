import '../../../core/database/tables/synced_columns.dart';
import '../domain/overtime.dart';
// El mismo módulo, con prefijo: `EmployeeDay` expone getters que se llaman igual
// que las funciones puras que consulta, y sin el prefijo el getter se llamaría a
// sí mismo.
import '../domain/overtime.dart' as overtime;

/// Alguien que trabaja en la lavandería (plan 0005 §6.2).
///
/// No es un usuario del sistema. La mayoría del personal no entra a la app: se
/// le anota la jornada y ya. [userId] es la cuenta de quien sí entra (D6).
class Employee {
  const Employee({
    required this.id,
    required this.fullName,
    required this.isActive,
    required this.version,
    this.phone,
    this.userId,
    this.notes,
  });

  final String id;
  final String fullName;
  final bool isActive;
  final int version;
  final String? phone;
  final String? userId;
  final String? notes;

  bool get hasAccount => userId != null;

  /// Las iniciales para el avatar, que es lo que la tarjeta muestra cuando no
  /// hay foto — y aquí nunca la hay.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

/// Un turno programado. Su duración es contra lo que se mide la hora extra.
class WorkShift {
  const WorkShift({
    required this.id,
    required this.code,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
    required this.sortOrder,
    required this.version,
  });

  final String id;
  final String code;
  final String name;
  final ClockTime startsAt;
  final ClockTime endsAt;
  final bool isActive;
  final int sortOrder;
  final int version;

  int get durationMinutes => minutesBetween(startsAt, endsAt);

  ({ClockTime startsAt, ClockTime endsAt}) get window =>
      (startsAt: startsAt, endsAt: endsAt);

  /// `6:00 a 11:00`, que es como se nombra un turno en voz alta.
  String get scheduleLabel => '${startsAt.label} a ${endsAt.label}';

  /// Si [moment] cae dentro de la ventana. Sirve para sugerir el turno al marcar
  /// entrada, no para decidir nada.
  bool covers(ClockTime moment) =>
      moment.minutesOfDay >= startsAt.minutesOfDay &&
      moment.minutesOfDay < endsAt.minutesOfDay;
}

/// Una tarifa con su ventana de vigencia.
///
/// Viaja entera y no solo el monto de hoy porque la app valúa jornadas de días
/// pasados: una tarifa que subió ayer no puede reescribir lo que se pagó la
/// semana pasada.
class PayrollRate {
  const PayrollRate({
    required this.id,
    required this.code,
    required this.amount,
    required this.validFrom,
    required this.version,
    this.validTo,
  });

  /// La única de la fase 1.
  static const String overtimeCode = 'overtime_hour';

  final String id;
  final String code;

  /// Por hora, en centavos.
  final int amount;

  /// `YYYY-MM-DD`.
  final String validFrom;
  final String? validTo;
  final int version;

  /// Comparación de texto porque las fechas son `YYYY-MM-DD` con cero a la
  /// izquierda, igual que en el resto del esquema.
  bool coversDate(String date) =>
      validFrom.compareTo(date) <= 0 && (validTo == null || validTo!.compareTo(date) >= 0);

  bool get isCurrent => validTo == null;
}

/// Una jornada: quién, qué día, de qué hora a qué hora.
class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.workDate,
    required this.clockIn,
    required this.overtimeMinutes,
    required this.syncStatus,
    required this.version,
    this.shiftId,
    this.clockOut,
    this.notes,
  });

  final String id;
  final String employeeId;
  final String workDate;
  final ClockTime clockIn;

  /// Nulo mientras la persona sigue trabajando.
  final ClockTime? clockOut;

  /// Los minutos que alguien **confirmó**. La sugerencia no está aquí: se
  /// calcula al leer, contra el turno (D8).
  final int overtimeMinutes;

  final String? shiftId;
  final String? notes;
  final RowSyncStatus syncStatus;
  final int version;

  bool get isOpen => clockOut == null;

  /// Todavía no subió: se capturó aquí y espera su turno en el outbox.
  bool get isPending => syncStatus == RowSyncStatus.pending;
}

/// En qué va el día de una persona. Es lo que decide qué botón ofrece su tarjeta.
enum AttendanceState {
  /// Nadie la ha marcado hoy.
  unmarked,

  /// Entró y no ha salido.
  working,

  /// La jornada está cerrada.
  complete,
}

/// Un empleado y su día, ya resueltos juntos (plan 0006 §9.1).
///
/// El turno y la tarifa se adjuntan aquí porque sin ellos los minutos extra no
/// se pueden ni sugerir ni valuar, y la pantalla necesita las dos cosas en la
/// misma tarjeta.
class EmployeeDay {
  const EmployeeDay({
    required this.employee,
    this.record,
    this.shift,
    this.hourlyRate,
  });

  final Employee employee;
  final AttendanceRecord? record;
  final WorkShift? shift;

  /// La tarifa vigente **el día de la jornada**, en centavos. Nula cuando
  /// ninguna cubre esa fecha, que es un hueco que hay que llenar y no una hora
  /// gratis.
  final int? hourlyRate;

  AttendanceState get state {
    if (record == null) return AttendanceState.unmarked;
    return record!.isOpen ? AttendanceState.working : AttendanceState.complete;
  }

  int? get workedMinutes => record == null
      ? null
      : overtime.workedMinutes(clockIn: record!.clockIn, clockOut: record!.clockOut);

  /// Lo que el sistema propondría pagar. Cero significa "no hay sugerencia":
  /// puede ser que no salió, que no hubo turno o que no se pasó de la hora.
  int get suggestedOvertimeMinutes {
    final current = record;
    if (current == null) return 0;
    return overtime.suggestedOvertimeMinutes(
      clockIn: current.clockIn,
      clockOut: current.clockOut,
      shift: shift?.window,
    );
  }

  /// Los minutos que ya se confirmaron sobre esta jornada.
  int get confirmedOvertimeMinutes => record?.overtimeMinutes ?? 0;

  /// Hay minutos confirmados esperando que alguien los pague.
  bool get awaitsOvertimePayment => confirmedOvertimeMinutes > 0;

  /// El monto de los minutos confirmados, o `null` sin tarifa que los valúe.
  String? get confirmedOvertimeAmount => formatOvertimeAmount(
    minutes: confirmedOvertimeMinutes,
    hourlyRate: hourlyRate,
  );

  /// Una línea con el estado del día, en las palabras de §9.1.
  String get stateLabel => switch (state) {
    AttendanceState.unmarked => 'Sin marcar',
    AttendanceState.working => 'Trabajando desde ${record!.clockIn.label}',
    AttendanceState.complete => shift == null
        ? 'Jornada completa'
        : 'Jornada completa (${shift!.name})',
  };
}
