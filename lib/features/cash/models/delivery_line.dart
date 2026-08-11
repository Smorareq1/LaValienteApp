import '../../../core/money/payment_method.dart';
import '../../orders/models/order.dart';

/// Una boleta marcada para entregar: cuánto paga ahora y cómo (plan 0006 §7.1.1).
///
/// Guarda el saldo **del momento en que se marcó** y no un puntero al pedido: el
/// repaso del cierre se arma con varias boletas a la vez y puede tardar un par
/// de minutos, y si en el medio entra un pago desde otro teléfono, lo que hay
/// que ver es que la cifra cambió — no que el total de la hoja se mueva solo
/// mientras alguien lo está leyendo.
class DeliveryLine {
  const DeliveryLine({
    required this.orderId,
    required this.reference,
    required this.customerName,
    required this.balance,
    required this.amount,
    required this.method,
    this.bookletSerial,
    this.paymentReference,
  });

  /// Arranca en «pagó todo», que es el caso normal.
  ///
  /// Una boleta que ya dejó más de lo que costó arranca en cero y no en su
  /// saldo: el saldo es negativo y cobrar menos veinte no es un movimiento de
  /// caja. Lo que hay que devolverle vive en [credit].
  factory DeliveryLine.of(OrderListItem order) => DeliveryLine(
    orderId: order.id,
    reference: order.reference,
    customerName: order.customerName,
    bookletSerial: order.bookletSerial,
    balance: order.balance,
    amount: order.balance > 0 ? order.balance : 0,
    method: PaymentMethod.cash,
  );

  final String orderId;

  /// `#44` o `P-3` mientras la boleta no ha subido.
  final String reference;

  /// La serie de imprenta, que es por donde el mostrador la llama de verdad.
  final String? bookletSerial;

  final String customerName;

  /// Saldo al marcarla, en centavos.
  final int balance;

  /// Lo que paga ahora. Puede ser 0: entregar sin cobrar nada es fiar entero.
  final int amount;

  final PaymentMethod method;
  final String? paymentReference;

  /// Lo que queda debiendo después de este cobro.
  int get pending => balance - amount;

  bool get isPartial => pending > 0;

  /// Lo que hay que devolverle al cliente al entregar, en centavos: dejó un
  /// anticipo mayor que lo que la boleta terminó costando.
  int get credit => balance < 0 ? -balance : 0;

  /// Cómo se nombra en pantalla: la serie si la tiene, si no el correlativo.
  String get label => bookletSerial ?? reference;

  DeliveryLine copyWith({int? amount, PaymentMethod? method, String? paymentReference}) {
    return DeliveryLine(
      orderId: orderId,
      reference: reference,
      customerName: customerName,
      bookletSerial: bookletSerial,
      balance: balance,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }
}

/// Lo marcado, ya sumado: lo que entra a la caja y lo que queda a deber.
class DeliveryBatch {
  const DeliveryBatch(this.lines);

  final List<DeliveryLine> lines;

  int get count => lines.length;

  bool get isEmpty => lines.isEmpty;

  /// Saldo total de las boletas marcadas, antes de tocar los montos.
  ///
  /// Las que dejaron de más suman cero y no en negativo: un anticipo sobrante de
  /// una boleta no cancela la deuda de otra, y sumarlos daría un total que no es
  /// ni lo que hay por cobrar ni lo que hay por devolver.
  int get balance =>
      lines.fold(0, (sum, line) => sum + (line.balance > 0 ? line.balance : 0));

  /// Lo que entra a la caja con los montos como están.
  int get collected => lines.fold(0, (sum, line) => sum + line.amount);

  /// Lo que se entrega fiado.
  int get pending =>
      lines.fold(0, (sum, line) => sum + (line.isPartial ? line.pending : 0));

  /// Lo que hay que devolver entre todas.
  int get credit => lines.fold(0, (sum, line) => sum + line.credit);

  bool get hasPending => pending > 0;

  /// Cuántas boletas quedan con saldo. Es lo que decide si hace falta el
  /// permiso de fiar, y también lo que se le dice a la persona.
  int get partialCount => lines.where((line) => line.isPartial).length;
}
