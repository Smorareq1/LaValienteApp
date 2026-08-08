/// Cuánto hace que pasó algo, dicho como se dice en voz alta.
///
/// Las marcas de sincronización no se leen como fechas sino como antigüedad: lo
/// que importa de "última sincronización" es si fue hace un minuto o hace tres
/// días, no a qué hora exacta ocurrió.
String relativeAge(DateTime moment, {DateTime Function() clock = DateTime.now}) {
  final elapsed = clock().difference(moment);
  if (elapsed.inSeconds < 60) return 'hace un momento';
  if (elapsed.inMinutes < 60) return 'hace ${elapsed.inMinutes} min';
  if (elapsed.inHours < 24) return 'hace ${elapsed.inHours} h';
  return 'hace ${elapsed.inDays} d';
}
