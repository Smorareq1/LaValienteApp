/// El comprobante que se comparte (plan 0006 §17.1).
///
/// **Se comparte, no se imprime.** La decisión del 2026-08-07 descartó la
/// impresora térmica de la fase 1: ESC/POS por Bluetooth no se puede terminar
/// sin el aparato en la mano. El papel oficial sigue siendo la boleta de
/// imprenta; esto es el mensaje que se le manda al cliente.
///
/// Texto plano a propósito. Va al *share sheet* del sistema y de ahí a WhatsApp,
/// donde cualquier formato se pierde: negritas, tablas y alineación por espacios
/// se ven distintas en cada teléfono. Lo único que se garantiza es que las
/// líneas se lean en orden.
///
/// Lógica pura: sin widgets, sin plugins. Lo que abre el share sheet vive en la
/// pantalla; armar el texto se puede probar sin tocar el sistema.
library;

import '../money/fixed2.dart';

/// Cómo se nombra el negocio en el comprobante.
const String businessName = 'Lavandería La Valiente';

/// Una prenda del comprobante: cuántas y de qué tipo.
typedef ReceiptGarment = ({String name, int quantity});

/// El comprobante de un pedido.
///
/// [reference] llega ya formateado —`No. 42` o el folio provisional— porque el
/// número definitivo lo pone el servidor y el provisional se dice distinto; esa
/// distinción ya la resolvió quien construye la confirmación.
///
/// Lleva **el conteo de prendas y la hora de recepción** además de las cifras:
/// este mensaje es el resguardo del cliente, y lo que se discute al recoger la
/// ropa es cuántas piezas se dejaron y cuándo. Sin eso, el comprobante solo
/// sirve para saber cuánto se debe.
String orderReceipt({
  required String reference,
  required int total,
  required int paid,
  required String date,
  String? time,
  String? customerName,
  String? customerPhone,
  String? customerNit,
  List<ReceiptGarment> garments = const [],
  bool pendingSync = false,
}) {
  final balance = total - paid;
  final pieces = garments.fold(0, (sum, garment) => sum + garment.quantity);
  final lines = <String>[
    businessName,
    '',
    'Pedido $reference',
    // Fecha y hora en el mismo renglón: es un solo dato —cuándo se recibió la
    // ropa— y partirlo en dos haría contar renglones para leerlo.
    time == null ? 'Fecha: $date' : 'Recibido: $date, $time',
    if (customerName != null) 'Cliente: $customerName',
    if (customerPhone != null) 'Tel: $customerPhone',
    if (customerNit != null) 'NIT: $customerNit',
    if (garments.isNotEmpty) ...[
      '',
      'Prendas ($pieces ${pieces == 1 ? 'pieza' : 'piezas'}):',
      for (final garment in garments) '${garment.quantity} × ${garment.name}',
    ],
    '',
    'Total: Q${Fixed2.format(total)}',
    if (paid > 0) 'Anticipo: Q${Fixed2.format(paid)}',
    if (balance > 0)
      'Saldo pendiente: Q${Fixed2.format(balance)}'
    else
      'Pagado por completo',
    '',
    // Se dice porque cambia lo que el cliente debe esperar: mientras el pedido
    // no suba, ese número puede no ser el definitivo.
    if (pendingSync)
      'Este número es provisional hasta que el pedido termine de registrarse.',
    'Gracias por su preferencia.',
  ];
  return lines.join('\n');
}

/// El comprobante de una venta de insumo.
String supplySaleReceipt({
  required int total,
  required String date,
  required List<({String name, int quantity, int amount})> items,
  String? customerName,
  String? method,
}) {
  final lines = <String>[
    businessName,
    '',
    'Venta de insumos',
    'Fecha: $date',
    if (customerName != null) 'Cliente: $customerName',
    '',
    for (final item in items)
      '${Fixed2.formatQuantity(item.quantity)} × ${item.name} — '
          'Q${Fixed2.format(item.amount)}',
    '',
    'Total: Q${Fixed2.format(total)}',
    if (method != null) 'Pago: $method',
    '',
    'Gracias por su preferencia.',
  ];
  return lines.join('\n');
}
