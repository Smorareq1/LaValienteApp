import 'package:flutter/widgets.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Tamaños de [AppMoneyText]. El tamaño define el cuerpo de los enteros; los
/// decimales siempre se muestran más pequeños y atenuados, como en las maquetas.
enum AppMoneySize {
  /// Cifra protagonista de una pantalla (resumen de Caja, TOTAL de un pedido).
  hero,

  /// Cifra de una tarjeta o fila destacada.
  lg,

  /// Cifra dentro de una lista o tabla.
  md,

  /// Cifra secundaria (subtotales, líneas de detalle).
  sm,
}

/// Cifra monetaria en quetzales con formato `Q#,##0.00`.
///
/// Los decimales van en un cuerpo menor y en gris para que el ojo se enganche
/// primero al número entero, que es lo que el mostrador necesita leer rápido.
class AppMoneyText extends StatelessWidget {
  const AppMoneyText(
    this.amount, {
    super.key,
    this.size = AppMoneySize.md,
    this.color,
    this.decimalColor,
    this.showDecimals = true,
    this.signed = false,
  });

  /// Monto en quetzales.
  final double amount;
  final AppMoneySize size;

  /// Color de la parte entera. Por defecto el texto primario.
  final Color? color;

  /// Color de los decimales. Por defecto `gray400`.
  final Color? decimalColor;

  /// Si es `false` se omite la parte decimal (útil en chips y badges).
  final bool showDecimals;

  /// Antepone `+`/`−` al monto (para movimientos de caja).
  final bool signed;

  /// Formatea [amount] como `Q#,##0.00` — sin `intl`, que no es dependencia
  /// del paquete.
  static String format(double amount, {bool showDecimals = true, bool signed = false}) {
    final negative = amount < 0;
    final absolute = amount.abs();
    final buffer = StringBuffer();

    if (signed) {
      buffer.write(negative ? '− ' : '+ ');
    } else if (negative) {
      buffer.write('−');
    }

    buffer.write('Q');
    buffer.write(_groupInteger(absolute));
    if (showDecimals) buffer.write(_decimals(absolute));
    return buffer.toString();
  }

  static String _groupInteger(double absolute) {
    final integer = absolute.floor().toString();
    final grouped = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) grouped.write(',');
      grouped.write(integer[i]);
    }
    return grouped.toString();
  }

  static String _decimals(double absolute) {
    // Se redondea a dos decimales sobre el valor absoluto ya truncado arriba.
    final cents = ((absolute - absolute.floor()) * 100).round();
    return '.${cents.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final (integerSize, decimalSize) = switch (size) {
      AppMoneySize.hero => (30.0, 16.0),
      AppMoneySize.lg => (20.0, 12.0),
      AppMoneySize.md => (16.0, 11.0),
      AppMoneySize.sm => (14.0, 10.0),
    };

    final absolute = amount.abs();
    final integerPart = StringBuffer();
    if (signed) {
      integerPart.write(amount < 0 ? '− ' : '+ ');
    } else if (amount < 0) {
      integerPart.write('−');
    }
    integerPart
      ..write('Q')
      ..write(_groupInteger(absolute));

    return Text.rich(
      TextSpan(
        text: integerPart.toString(),
        style: AppTypography.money(
          fontSize: integerSize,
          color: color ?? AppColors.textPrimary,
        ),
        children: [
          if (showDecimals)
            TextSpan(
              text: _decimals(absolute),
              style: AppTypography.money(
                fontSize: decimalSize,
                color: decimalColor ?? AppColors.gray400,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
