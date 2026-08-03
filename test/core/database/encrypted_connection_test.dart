import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/encrypted_connection.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('abrir con un SQLite sin SQLCipher falla en vez de escribir en claro', () {
    // El sqlite3 del sistema, que corre estos tests, no trae SQLCipher: es
    // exactamente el escenario que la comprobación tiene que atrapar. Sin ella
    // el `PRAGMA key` se ignoraría en silencio y la BD del mostrador quedaría
    // legible para cualquiera con el archivo.
    final database = sqlite3.openInMemory();
    addTearDown(database.dispose);

    expect(
      () => unlockDatabase(database, 'a' * 64),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('SQLCipher'),
        ),
      ),
    );
  });
}
