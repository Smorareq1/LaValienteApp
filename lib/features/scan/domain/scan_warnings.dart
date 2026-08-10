import '../../../core/money/fixed2.dart';

/// Qué tan fuerte se dice el aviso de un escaneo.
enum ScanWarningTone {
  /// Cambia lo que se va a cobrar. Hay que mirarlo antes de guardar.
  serious,

  /// Vale la pena leerlo, pero no cambia el total.
  notable,
}

/// Una línea del bloque de avisos del escaneo (Plan 0003 §7).
class ScanWarning {
  const ScanWarning(this.message, {this.tone = ScanWarningTone.notable});

  final String message;
  final ScanWarningTone tone;
}

/// Traduce los avisos del escaneo a la frase que se muestra.
///
/// El servidor manda **códigos** (`total_mismatch:108.75:98.75`,
/// `garment_unmatched:Sombrero`) y no frases, por lo mismo que en el cierre y en
/// la cola de revisión: es el único que puede detectarlos —tiene el catálogo, el
/// motor de precios y la foto— pero la app es la que habla español. Colgar la
/// interfaz de una frase que mañana se reescribe sería construir sobre arena.
List<ScanWarning> scanWarnings(List<String> codes) => [
  for (final code in codes) _translate(code),
];

ScanWarning _translate(String code) {
  final separator = code.indexOf(':');
  final name = separator < 0 ? code : code.substring(0, separator);
  final value = separator < 0 ? '' : code.substring(separator + 1);

  switch (name) {
    case 'total_mismatch':
      final parts = value.split(':');
      final read = _money(parts.isNotEmpty ? parts[0] : '');
      final computed = _money(parts.length > 1 ? parts[1] : '');
      return ScanWarning(
        'La boleta dice $read y el sistema calcula $computed. Casi siempre es '
        'una cantidad mal leída: revisa las líneas antes de guardar.',
        tone: ScanWarningTone.serious,
      );
    case 'pricing_failed':
      return ScanWarning(
        'No se pudieron calcular los montos ($value). Los servicios hay que '
        'ponerlos a mano.',
        tone: ScanWarningTone.serious,
      );
    case 'no_services_read':
      return const ScanWarning(
        'No se leyó ningún servicio. Las prendas y el cliente sí están; los '
        'servicios hay que marcarlos a mano.',
        tone: ScanWarningTone.serious,
      );
    case 'weight_mismatch':
      final parts = value.split(':');
      return ScanWarning(
        'El peso del encabezado (${parts.first} lb) no cuadra con las libras '
        'que se cobran (${parts.length > 1 ? parts[1] : "?"} lb). Se tomaron '
        'las que se cobran.',
        tone: ScanWarningTone.serious,
      );
    case 'weight_taken_from_charge':
      return const ScanWarning(
        'El peso del encabezado no se leyó; se tomó de las libras que se '
        'cobran.',
      );
    case 'garment_unmatched':
      return ScanWarning(
        '«$value» no es ninguna de las prendas de la boleta, así que no se '
        'agregó. Ponla a mano si hace falta.',
      );
    case 'phone_unreadable':
      return ScanWarning(
        'El teléfono no se leyó completo («$value»). Quedó vacío a propósito: '
        'un número a medias se marca igual.',
      );
    case 'nit_unreadable':
      return ScanWarning('El NIT no se pudo leer («$value»).');
    case 'date_unreadable':
      return ScanWarning(
        'La fecha de la boleta no se entiende («$value»); se usó la de hoy.',
      );
    case 'date_far_from_today':
      return ScanWarning(
        'La boleta dice $value, que queda lejos de hoy. Suele ser el año mal '
        'leído.',
      );
    case 'pricing':
      // Los del motor de precios viajan con su propio texto del servidor: son
      // el aviso de nivel fuera de rango del plan 0001 §6.3.
      return ScanWarning('El cálculo marcó algo: $value');
    default:
      // Un código que esta versión no conoce no se descarta en silencio, igual
      // que en el cierre: algo que valía la pena leer antes de guardar no puede
      // desaparecer porque el teléfono tenga una app vieja.
      return ScanWarning('El servidor marcó algo más para revisar ($code).');
  }
}

String _money(String amount) => 'Q${Fixed2.format(Fixed2.parse(amount) ?? 0)}';
