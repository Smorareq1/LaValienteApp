import '../../../core/money/fixed2.dart';

/// Qué tan fuerte se dice el aviso.
///
/// Ninguno bloquea el cierre (plan 0005 §6.1) — un cierre que se negara por una
/// boleta sin entregar simplemente se esquivaría—, pero no todos pesan igual:
/// una captura sin subir cambia las cifras que se van a archivar, y una boleta
/// en el estante solo pide una llamada al cliente.
enum CloseWarningTone {
  /// Cambia lo que el acta va a decir.
  serious,

  /// Vale la pena leerlo antes de firmar.
  notable,
}

/// Una línea del bloque de advertencias del cierre (plan 0006 §7.4).
class CloseWarning {
  const CloseWarning(this.message, {this.tone = CloseWarningTone.notable});

  final String message;
  final CloseWarningTone tone;
}

/// Traduce las advertencias del cierre a la frase que se muestra.
///
/// El servidor manda **códigos** (`open_tickets:3`, `uncollected:120.00`,
/// `pending_expenses:80.00`, `reopened`) y no frases: es el único que puede
/// contarlas —sabe de las boletas que tomó la otra tableta y este teléfono
/// todavía no bajó—, pero la app es la que habla español.
///
/// [unsyncedCaptures] no viene de ahí y no podría: son las capturas de **este**
/// dispositivo que siguen en el outbox. El servidor no las ha visto, así que no
/// están en las cifras que se van a archivar, y esa es la advertencia que más
/// pesa de todas.
List<CloseWarning> closeWarnings({
  required List<String> codes,
  int unsyncedCaptures = 0,
}) {
  return [
    if (unsyncedCaptures > 0)
      CloseWarning(
        unsyncedCaptures == 1
            ? 'Una captura de este dispositivo todavía no sube: el acta se '
                  'archivaría sin ella.'
            : '$unsyncedCaptures capturas de este dispositivo todavía no suben: '
                  'el acta se archivaría sin ellas.',
        tone: CloseWarningTone.serious,
      ),
    for (final code in codes) _translate(code),
  ];
}

CloseWarning _translate(String code) {
  final separator = code.indexOf(':');
  final name = separator < 0 ? code : code.substring(0, separator);
  final value = separator < 0 ? '' : code.substring(separator + 1);

  switch (name) {
    case 'reopened':
      return const CloseWarning(
        'Este día se cerró y se volvió a abrir: hay que cerrarlo otra vez.',
        tone: CloseWarningTone.serious,
      );
    case 'open_tickets':
      final count = int.tryParse(value) ?? 0;
      return CloseWarning(
        count == 1
            ? 'Una boleta del día sigue sin entregarse.'
            : '$count boletas del día siguen sin entregarse.',
      );
    case 'uncollected':
      return CloseWarning(
        'Quedan ${_money(value)} sin cobrar en los pedidos del día.',
      );
    case 'pending_expenses':
      return CloseWarning(
        '${_money(value)} en gastos quedaron pendientes de pago: cuentan en el '
        'día, pero no salieron del cajón.',
      );
    default:
      // Un código que esta versión no conoce no se descarta en silencio: algo
      // que valía la pena leer antes de firmar no puede desaparecer porque el
      // teléfono tenga una app vieja.
      return CloseWarning('El servidor marcó algo más para revisar ($code).');
  }
}

String _money(String amount) => 'Q${Fixed2.format(Fixed2.parse(amount) ?? 0)}';
