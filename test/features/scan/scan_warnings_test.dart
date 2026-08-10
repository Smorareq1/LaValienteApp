import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/scan/domain/scan_warnings.dart';

/// Los avisos del escaneo llegan **codificados** y la app los escribe en
/// español, igual que los del cierre y los del motor de sincronización.
void main() {
  test('la discrepancia de total enseña los dos lados', () {
    // Es el aviso que más importa del §7.4: casi siempre delata una cantidad
    // mal leída, y para eso hay que poder comparar.
    final warnings = scanWarnings(['total_mismatch:108.75:98.75']);

    expect(warnings, hasLength(1));
    expect(warnings.single.message, contains('Q108.75'));
    expect(warnings.single.message, contains('Q98.75'));
    expect(warnings.single.tone, ScanWarningTone.serious);
  });

  test('una prenda sin equivalente se nombra', () {
    // Se descartó en el servidor; decir cuál es lo que permite ponerla a mano.
    final warnings = scanWarnings(['garment_unmatched:Sombrero']);

    expect(warnings.single.message, contains('Sombrero'));
    expect(warnings.single.tone, ScanWarningTone.notable);
  });

  test('sin servicios leídos se avisa fuerte', () {
    // El cliente y las prendas sirven igual, pero sin cargos no hay cobro.
    final warnings = scanWarnings(['no_services_read']);

    expect(warnings.single.tone, ScanWarningTone.serious);
    expect(warnings.single.message, contains('a mano'));
  });

  test('el teléfono a medias explica por qué quedó vacío', () {
    final warnings = scanWarnings(['phone_unreadable:551']);

    expect(warnings.single.message, contains('551'));
  });

  test('un código desconocido no desaparece en silencio', () {
    // Misma regla que el cierre: algo que valía la pena leer no se pierde
    // porque el teléfono tenga una app vieja.
    final warnings = scanWarnings(['algo_que_no_existe_todavia:7']);

    expect(warnings, hasLength(1));
    expect(warnings.single.message, contains('algo_que_no_existe_todavia:7'));
  });

  test('sin códigos no hay avisos', () {
    expect(scanWarnings(const []), isEmpty);
  });
}
