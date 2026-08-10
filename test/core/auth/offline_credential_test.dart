import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/auth/offline_credential.dart';

/// Las vueltas de PBKDF2 de verdad tardan casi un segundo cada derivación, así
/// que lo que se comprueba a mano usa pocas: lo que se prueba es la regla, no
/// el costo. El costo real vive en [OfflineCredential.kIterations] y se
/// verifica aparte, en `create`.
OfflineCredential _credential({
  String identifier = 'sebasm',
  String password = 'Morales1',
  String salt = 'sal-fija',
  int iterations = 64,
  DateTime? verifiedAt,
}) {
  return OfflineCredential(
    identifier: OfflineCredential.normalize(identifier),
    salt: salt,
    verifier: OfflineCredential.derive(
      password: password,
      salt: salt,
      iterations: iterations,
    ),
    iterations: iterations,
    verifiedAt: verifiedAt ?? DateTime(2026, 8, 8),
  );
}

void main() {
  group('derivación', () {
    test('la misma contraseña y sal dan el mismo verificador', () {
      final a = OfflineCredential.derive(password: 'abc12345', salt: 's', iterations: 32);
      final b = OfflineCredential.derive(password: 'abc12345', salt: 's', iterations: 32);
      expect(a, b);
    });

    test('la sal cambia el resultado', () {
      // Sin esto, dos teléfonos con la misma contraseña guardarían el mismo
      // verificador y romper uno sería romper los dos.
      final a = OfflineCredential.derive(password: 'abc12345', salt: 's1', iterations: 32);
      final b = OfflineCredential.derive(password: 'abc12345', salt: 's2', iterations: 32);
      expect(a, isNot(b));
    });

    test('el verificador no contiene la contraseña', () {
      final hash = OfflineCredential.derive(
        password: 'contrasena-larga',
        salt: 's',
        iterations: 32,
      );
      expect(hash.contains('contrasena'), isFalse);
      expect(hash.length, 64); // SHA-256 en hexadecimal
    });

    test('cada sal generada es distinta', () {
      final salts = List.generate(20, (_) => OfflineCredential.generateSalt());
      expect(salts.toSet().length, 20);
    });
  });

  group('verificación', () {
    test('acepta la contraseña correcta', () {
      expect(_credential().verify('Morales1'), isTrue);
    });

    test('rechaza la incorrecta', () {
      expect(_credential().verify('Morales2'), isFalse);
    });

    test('rechaza la vacía', () {
      expect(_credential().verify(''), isFalse);
    });
  });

  group('identificador', () {
    test('no distingue mayúsculas ni espacios de sobra', () {
      // Nadie teclea igual dos veces, y rebotar a alguien por un espacio sería
      // dejarlo fuera de su propio teléfono.
      final credential = _credential(identifier: 'SebasM');
      expect(credential.matches('  sebasm '), isTrue);
      expect(credential.matches('SEBASM'), isTrue);
    });

    test('otra persona no entra con la credencial guardada', () {
      expect(_credential(identifier: 'sebasm').matches('rosa'), isFalse);
    });
  });

  group('caducidad', () {
    test('sirve dentro del plazo', () {
      final credential = _credential(verifiedAt: DateTime(2026, 8, 1));
      expect(credential.isStale(DateTime(2026, 8, 20)), isFalse);
    });

    test('caduca pasado el mes', () {
      // Un teléfono robado que nunca se reconecta no puede quedar abierto para
      // siempre: la revocación de dispositivos solo alcanza a quien vuelve.
      final credential = _credential(verifiedAt: DateTime(2026, 8, 1));
      expect(credential.isStale(DateTime(2026, 9, 15)), isTrue);
    });
  });

  group('serialización', () {
    test('sobrevive la ida y vuelta a JSON', () {
      final original = _credential();
      final restored = OfflineCredential.fromJson(original.toJson());

      expect(restored.identifier, original.identifier);
      expect(restored.salt, original.salt);
      expect(restored.verifier, original.verifier);
      expect(restored.iterations, original.iterations);
      expect(restored.verifiedAt, original.verifiedAt);
      expect(restored.verify('Morales1'), isTrue);
    });
  });

  test('create usa el costo de producción', () {
    // Bajar las vueltas abarata probar contraseñas a ciegas contra un teléfono
    // perdido, así que el número se mira en una prueba y no solo en el código.
    final credential = OfflineCredential.create(
      identifier: 'sebasm',
      password: 'Morales1',
      now: DateTime(2026, 8, 8),
    );
    expect(credential.iterations, OfflineCredential.kIterations);
    expect(OfflineCredential.kIterations, greaterThanOrEqualTo(100000));
    expect(credential.verify('Morales1'), isTrue);
  });
}
