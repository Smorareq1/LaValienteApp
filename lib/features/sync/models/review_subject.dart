import 'review_item.dart';

/// El otro lado de la comparación de §11.2: lo que el dispositivo tiene
/// **ahora** sobre aquello que la operación tocó.
///
/// No sale de la respuesta del push. Un conflicto vuelve del servidor con el
/// motivo y nada más —`server_data` viene vacío cuando la operación ni siquiera
/// se pudo aplicar—, así que la versión buena es la que bajó por el feed
/// después: el espejo local de una fila rechazada deja de estar protegido justo
/// para eso. Y tiene la ventaja de ser el estado de ahora y no el de aquel
/// intento.
class ReviewSubject {
  const ReviewSubject({
    required this.headline,
    required this.facts,
    required this.route,
    required this.openLabel,
    this.version,
    this.holdsTheBooklet = false,
  });

  /// Cómo se llama en el mostrador: "Pedido #7", "Elena Ramírez".
  final String headline;

  final List<ReviewFact> facts;

  /// Dónde verlo completo.
  final String route;

  final String openLabel;

  /// La versión que conoce el dispositivo, para reintentar sin repetir el
  /// choque (D6).
  final int? version;

  /// Este es el pedido que ya se quedó con la serie de la boleta rechazada, no
  /// la boleta rechazada en sí. Cambia lo que hay que leer: no es "así quedó lo
  /// tuyo" sino "esto es lo que ya estaba".
  final bool holdsTheBooklet;
}
