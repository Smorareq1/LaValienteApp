import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Credencial que deja volver a entrar **en este teléfono** sin señal.
///
/// No es una copia de la cuenta: es un *verificador* derivado de la contraseña
/// que alguien ya usó para entrar en línea desde este aparato. Sirve para
/// comprobar una contraseña, no para reconstruirla, y solo existe para la
/// persona que de verdad entró aquí. Un teléfono perdido compromete a quien lo
/// usaba, no a todo el personal — que es la razón de no bajar las cuentas
/// enteras al dispositivo.
///
/// La derivación es **PBKDF2-HMAC-SHA256** y es lenta a propósito: es lo único
/// que separa a quien se lleve el teléfono de probar contraseñas a ciegas
/// contra el archivo. La base ya va cifrada con SQLCipher; esto es la segunda
/// cerradura, no la primera.
class OfflineCredential {
  const OfflineCredential({
    required this.identifier,
    required this.salt,
    required this.verifier,
    required this.iterations,
    required this.verifiedAt,
  });

  factory OfflineCredential.fromJson(Map<String, dynamic> json) {
    return OfflineCredential(
      identifier: json['identifier'] as String,
      salt: json['salt'] as String,
      verifier: json['verifier'] as String,
      iterations: json['iterations'] as int,
      verifiedAt: DateTime.parse(json['verified_at'] as String),
    );
  }

  /// Cuántas vueltas de PBKDF2. Sube el costo de probar una contraseña a
  /// ciegas; bajarlo abarata el ataque, así que solo se sube.
  static const int kIterations = 100000;

  /// Cuánto puede vivir sin volver a verse con el servidor.
  ///
  /// Sin esto, un teléfono robado que nunca se reconecta sigue abriendo para
  /// siempre, y la revocación de dispositivos (plan 0004 D11) no lo alcanza
  /// nunca porque esa solo actúa cuando el aparato vuelve a hablar. Un mes es
  /// largo para un corte de red y corto para un robo.
  static const Duration kMaxOfflineAge = Duration(days: 30);

  /// Con qué se escribió: usuario o correo, normalizado.
  final String identifier;

  final String salt;
  final String verifier;
  final int iterations;

  /// Última vez que el servidor dio el visto bueno a esta contraseña.
  final DateTime verifiedAt;

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'salt': salt,
        'verifier': verifier,
        'iterations': iterations,
        'verified_at': verifiedAt.toIso8601String(),
      };

  /// El identificador se compara normalizado porque nadie teclea igual dos
  /// veces: `SebasM ` y `sebasm` son la misma persona.
  bool matches(String candidate) => normalize(candidate) == identifier;

  bool isStale(DateTime now) => now.difference(verifiedAt) > kMaxOfflineAge;

  static String normalize(String identifier) => identifier.trim().toLowerCase();

  /// Deriva la credencial de una contraseña recién aceptada por el servidor.
  ///
  /// [now] entra por parámetro para que las pruebas no dependan del reloj.
  static OfflineCredential create({
    required String identifier,
    required String password,
    required DateTime now,
    String? salt,
  }) {
    final actualSalt = salt ?? generateSalt();
    return OfflineCredential(
      identifier: normalize(identifier),
      salt: actualSalt,
      verifier: derive(password: password, salt: actualSalt, iterations: kIterations),
      iterations: kIterations,
      verifiedAt: now,
    );
  }

  /// ¿Es esta la contraseña? Nunca dice cuál es.
  bool verify(String password) {
    final candidate = derive(password: password, salt: salt, iterations: iterations);
    return _constantTimeEquals(candidate, verifier);
  }

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return _hex(bytes);
  }

  /// PBKDF2-HMAC-SHA256. Función pura: se puede correr en otro isolate para no
  /// congelar la pantalla mientras da las cien mil vueltas.
  static String derive({
    required String password,
    required String salt,
    required int iterations,
  }) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = utf8.encode(salt);

    // Un solo bloque: SHA-256 ya devuelve los 32 bytes que queremos.
    final block = Uint8List(4)..buffer.asByteData().setUint32(0, 1);
    var previous = hmac.convert([...saltBytes, ...block]).bytes;
    final accumulated = List<int>.from(previous);

    for (var round = 1; round < iterations; round++) {
      previous = hmac.convert(previous).bytes;
      for (var i = 0; i < accumulated.length; i++) {
        accumulated[i] ^= previous[i];
      }
    }

    return _hex(accumulated);
  }

  /// Comparación en tiempo constante: salir antes en la primera diferencia
  /// filtra, por lo que tarda, cuánto se acertó del verificador.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return difference == 0;
  }

  static String _hex(List<int> bytes) =>
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
