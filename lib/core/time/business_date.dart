/// La fecha de la lavandería (plan 0001 D8), igual que `src/core/business_time.py`.
///
/// Un pedido pertenece a un día del negocio, no a uno UTC: el correlativo diario
/// reinicia con él y el cierre del día se corta por él. Una boleta tomada a las
/// 19:00 en Cobán son las 01:00 UTC del día siguiente, y archivarla en mañana la
/// pondría en el cierre equivocado.
///
/// El desfase es fijo, no una zona IANA: Guatemala está en UTC−6 todo el año
/// desde 2006, y una base de zonas horaria ausente no puede cambiar en silencio
/// a qué día pertenece un pedido.
library;

const Duration _guatemalaOffset = Duration(hours: -6);

/// La fecha del negocio en [moment] (por omisión, ahora).
DateTime businessDate([DateTime? moment]) {
  final local = (moment ?? DateTime.now()).toUtc().add(_guatemalaOffset);
  return DateTime(local.year, local.month, local.day);
}

/// `YYYY-MM-DD`, que es como viajan las fechas de negocio y como se guardan en
/// la BD local: comparables como texto por serlo.
String isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// El intervalo UTC `[inicio, fin)` que cubre el día de negocio [date].
///
/// Gemelo de `business_day_bounds` del backend, y hace falta por lo mismo: hay
/// filas cuya única fecha es una marca de auditoría —el `paid_at` de un cobro—
/// y aun así se listan "por día". El día que se quiere decir es el de la
/// lavandería, no el UTC.
///
/// Semiabierto y no `<=` al final, para que un cobro hecho exactamente a
/// medianoche pertenezca a un día y no a los dos.
({DateTime start, DateTime end}) businessDayBounds(DateTime date) {
  final start = DateTime.utc(date.year, date.month, date.day).subtract(_guatemalaOffset);
  return (start: start, end: start.add(const Duration(days: 1)));
}

/// `YYYY-MM-DD` → la fecha, o `null` si el texto no lo es.
DateTime? parseIsoDate(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
}
