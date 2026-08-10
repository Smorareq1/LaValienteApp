/// Lo que el servidor sacó de la foto de una boleta **que ya existe**
/// (`POST /scans/lookup`, plan 0006 §7.1.1).
///
/// El otro escaneo produce un borrador para capturar; este produce una
/// respuesta a «¿cuál boleta es esta?». La diferencia importa: un borrador
/// equivocado lo corrige quien lo está mirando, y una búsqueda equivocada
/// entrega la ropa de otra persona. Por eso acá no hay nada que se pueda
/// guardar — solo identificadores que la pantalla contrasta contra su propio
/// espejo antes de marcar nada.
library;

import '../../../core/money/fixed2.dart';
import 'scan.dart';

/// Una boleta que la foto podría estar señalando.
class TicketLookupMatch {
  const TicketLookupMatch({
    required this.orderId,
    required this.orderDate,
    required this.dailyNumber,
    required this.customerId,
    required this.status,
    required this.totalPieces,
    required this.total,
    required this.paidTotal,
    required this.balance,
    required this.matchedOn,
    this.bookletSerial,
  });

  factory TicketLookupMatch.fromJson(Map<String, dynamic> json) => TicketLookupMatch(
    orderId: json['order_id'] as String,
    orderDate: json['order_date'] as String,
    dailyNumber: json['daily_number'] as int,
    customerId: json['customer_id'] as String,
    status: json['status'] as String,
    totalPieces: json['total_pieces'] as int? ?? 0,
    total: Fixed2.parse(json['total']?.toString()) ?? 0,
    paidTotal: Fixed2.parse(json['paid_total']?.toString()) ?? 0,
    balance: Fixed2.parse(json['balance']?.toString()) ?? 0,
    matchedOn: json['matched_on'] as String? ?? 'daily_number',
    bookletSerial: json['booklet_serial'] as String?,
  );

  final String orderId;
  final String orderDate;
  final int dailyNumber;
  final String customerId;

  /// El del servidor (`received`, `delivered`…). Se compara como texto y no se
  /// convierte al enum: acá solo sirve para decir «esa ya se entregó», y un
  /// estado que esta versión no conozca no debe romper la búsqueda.
  final String status;

  final int totalPieces;

  /// Centavos.
  final int total;
  final int paidTotal;
  final int balance;

  /// `booklet_serial` o `daily_number`. El serial va impreso y vale para todo el
  /// talonario; el número va a mano y solo es único dentro de su día.
  final String matchedOn;

  final String? bookletSerial;

  bool get isBySerial => matchedOn == 'booklet_serial';
}

/// La respuesta de `POST /scans/lookup`.
class TicketLookupResult {
  const TicketLookupResult({
    required this.id,
    required this.status,
    this.orderDate = const DraftField<String>(),
    this.dailyNumber = const DraftField<int>(),
    this.bookletSerial = const DraftField<String>(),
    this.matches = const [],
    this.warnings = const [],
    this.latencyMs,
    this.error,
  });

  factory TicketLookupResult.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) => value?.toString();
    int? whole(Object? value) => value is int ? value : int.tryParse('$value');
    Map<String, dynamic>? at(String key) => json[key] as Map<String, dynamic>?;

    return TicketLookupResult(
      id: json['id'] as String,
      status: json['status'] as String,
      orderDate: DraftField.fromJson<String>(at('order_date'), text),
      dailyNumber: DraftField.fromJson<int>(at('daily_number'), whole),
      bookletSerial: DraftField.fromJson<String>(at('booklet_serial'), text),
      matches: [
        for (final match in (json['matches'] as List<dynamic>? ?? const []))
          TicketLookupMatch.fromJson(match as Map<String, dynamic>),
      ],
      warnings: [
        for (final code in (json['warnings'] as List<dynamic>? ?? const []))
          code as String,
      ],
      latencyMs: json['latency_ms'] as int?,
      error: json['error'] as String?,
    );
  }

  final String id;
  final String status;

  /// Lo que se leyó del papel. Viaja aunque no haya coincidencia, y ahí es
  /// cuando más sirve: es lo que se deja escrito en el buscador para que la
  /// persona corrija el dígito en vez de volver a tomar la foto.
  final DraftField<String> orderDate;
  final DraftField<int> dailyNumber;
  final DraftField<String> bookletSerial;

  final List<TicketLookupMatch> matches;

  /// Códigos, no frases: `ticket_unreadable`, `no_match:9`,
  /// `serial_and_number_disagree`.
  final List<String> warnings;

  final int? latencyMs;
  final String? error;

  /// Lo que se leyó, como se teclearía en el buscador. El serial primero porque
  /// es el impreso.
  String? get asSearchText {
    if (bookletSerial.hasValue) return bookletSerial.value;
    if (dailyNumber.hasValue) return '${dailyNumber.value}';
    return null;
  }
}
