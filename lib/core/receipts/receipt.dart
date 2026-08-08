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

/// El comprobante de un pedido.
///
/// [reference] llega ya formateado —`No. 42` o el folio provisional— porque el
/// número definitivo lo pone el servidor y el provisional se dice distinto; esa
/// distinción ya la resolvió quien construye la confirmación.
String orderReceipt({
  required String reference,
  required int total,
  required int paid,
  required String date,
  String? customerName,
  bool pendingSync = false,
}) {
  final balance = total - paid;
  final lines = <String>[
    businessName,
    '',
    'Pedido $reference',
    'Fecha: $date',
    if (customerName != null) 'Cliente: $customerName',
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
