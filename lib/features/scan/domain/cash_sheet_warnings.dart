import '../../../core/money/fixed2.dart';
import 'scan_warnings.dart';

/// Traduce los avisos de la hoja de caja a la frase que se muestra.
///
/// Misma regla que en `scan_warnings`, en el cierre y en la cola de revisión: el
/// servidor manda **códigos** porque es el único que puede detectarlos, y la app
/// es la que habla español.
List<ScanWarning> cashSheetWarnings(List<String> codes) => [
  for (final code in codes) _translate(code),
];

ScanWarning _translate(String code) {
  final separator = code.indexOf(':');
  final name = separator < 0 ? code : code.substring(0, separator);
  final value = separator < 0 ? '' : code.substring(separator + 1);

  switch (name) {
    case 'no_blocks_read':
      return const ScanWarning(
        'De esta foto no se sacó ningún día. Que se vea la hoja entera, con los '
        'renglones derechos y sin sombra encima.',
        tone: ScanWarningTone.serious,
      );
    case 'already_applied':
      return ScanWarning(
        'Esta hoja ya se importó el $value. Importarla otra vez cobraría dos '
        'veces el mismo día.',
        tone: ScanWarningTone.serious,
      );
    case 'income_sum_mismatch':
      final parts = value.split(':');
      return ScanWarning(
        'La suma escrita de ingresos (${_money(parts.first)}) no cuadra con lo '
        'que suman las filas leídas (${_money(parts.length > 1 ? parts[1] : "")}). '
        'Suele faltar una fila o haber un dígito mal leído.',
        tone: ScanWarningTone.serious,
      );
    case 'expense_sum_mismatch':
      final parts = value.split(':');
      return ScanWarning(
        'La suma escrita de gastos (${_money(parts.first)}) no cuadra con las '
        'filas leídas (${_money(parts.length > 1 ? parts[1] : "")}).',
        tone: ScanWarningTone.serious,
      );
    case 'day_closed':
      return ScanWarning(
        'El día $value ya está cerrado. Nada de esta hoja va a entrar hasta que '
        'un administrador lo reabra.',
        tone: ScanWarningTone.serious,
      );
    case 'sheet_not_today':
      return ScanWarning(
        'Esta hoja es del $value, no de hoy. Los cobros se registran con la '
        'fecha de hoy, así que van a caer en el cierre de hoy.',
        tone: ScanWarningTone.serious,
      );
    case 'duplicate_serial':
      return ScanWarning(
        'Hay dos boletas con el número $value. Elegí cuál es antes de cobrar: el '
        'sistema no puede decidirlo.',
        tone: ScanWarningTone.serious,
      );
    case 'date_unreadable':
      return const ScanWarning(
        'La fecha del bloque no se leyó; se puso la de hoy. Cambiala arriba si '
        'la hoja es de otro día.',
      );
    default:
      return ScanWarning('El servidor marcó algo más para revisar ($code).');
  }
}

String _money(String amount) => 'Q${Fixed2.format(Fixed2.parse(amount) ?? 0)}';
