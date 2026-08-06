/// Números de dos decimales guardados como enteros.
///
/// Es el mismo formato que usan el catálogo, los montos de un pedido y las
/// cantidades que admiten fracción (las libras): dos cifras decimales, ni una
/// más. Guardarlos como `int` —centavos, centésimas— y no como `double` es lo
/// que hace que Q108.75 siga siendo Q108.75 después de sumarlo cincuenta veces.
///
/// El servidor los manda y los recibe como texto (`"2.50"`) por la misma razón,
/// así que este es también el traductor de la frontera: `parse` al entrar,
/// `format` al salir.
abstract final class Fixed2 {
  /// Interpreta `"12.50"`, `"12,5"` o `" 12 "` como 1250.
  ///
  /// Devuelve `null` si el texto no es un número, para que quien captura pueda
  /// tener el campo a medio escribir sin que la pantalla grite. Un texto con
  /// más de dos decimales se trunca, no se redondea: nadie teclea centésimas de
  /// centavo queriendo.
  static int? parse(String? text) {
    final trimmed = text?.trim().replaceAll(',', '.');
    if (trimmed == null || trimmed.isEmpty) return null;

    final match = RegExp(r'^(-?)(\d*)(?:\.(\d*))?$').firstMatch(trimmed);
    if (match == null) return null;

    final whole = match.group(2) ?? '';
    final fraction = match.group(3) ?? '';
    if (whole.isEmpty && fraction.isEmpty) return null;

    final units = whole.isEmpty ? 0 : int.parse(whole);
    final cents = int.parse(fraction.padRight(2, '0').substring(0, 2));
    final value = units * 100 + cents;
    return match.group(1) == '-' ? -value : value;
  }

  /// 1250 → `"12.50"`. Este es el texto que viaja al servidor y el que se
  /// guarda en la fila espejo.
  static String format(int value) {
    final sign = value < 0 ? '-' : '';
    final absolute = value.abs();
    final cents = absolute % 100;
    return '$sign${absolute ~/ 100}.${cents.toString().padLeft(2, '0')}';
  }

  /// Para pintarlo con `AppMoneyText`, que trabaja en `double`.
  ///
  /// La conversión se hace al final y solo para dibujar: mientras el número
  /// sirva para calcular sigue siendo entero.
  static double toDouble(int value) => value / 100;

  /// `unidad × cantidad`, redondeado a dos decimales alejándose del cero.
  ///
  /// Es el `money()` del backend (plan 0001 §6.2): se redondea **por línea** y
  /// después se suma, no al revés, para que las líneas impresas cuadren con el
  /// subtotal impreso. Un cliente que revisa la boleta a mano no puede
  /// encontrarla descuadrada por un centavo.
  static int multiply(int unit, int quantity) {
    // `unit * quantity` queda en diezmilésimas; el medio que se suma antes de
    // dividir es lo que convierte el truncamiento entero en redondeo half-up.
    final product = unit * quantity;
    final rounded = (product.abs() * 2 + 100) ~/ 200;
    return product < 0 ? -rounded : rounded;
  }
}
