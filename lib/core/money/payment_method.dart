/// Cómo entró o salió el dinero (plan 0001 §5.3). Los dos valores son los del
/// backend, donde la columna se llama `method` en pagos, gastos y ventas.
///
/// Vive en `core/` y no en un módulo porque lo comparten tres: el pago de un
/// pedido, el gasto de la Caja y la venta de mostrador. Que el gasto tuviera su
/// propio enum sería tener dos definiciones de «efectivo» que un día se separan.
enum PaymentMethod {
  cash('cash', 'Efectivo'),
  transfer('transfer', 'Transferencia');

  const PaymentMethod(this.wire, this.label);

  final String wire;
  final String label;

  /// `null` si el servidor mandó un método que esta versión no conoce; se dice,
  /// no se adivina.
  static PaymentMethod? fromWire(String value) {
    for (final method in values) {
      if (method.wire == value) return method;
    }
    return null;
  }
}
