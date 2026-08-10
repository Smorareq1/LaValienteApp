import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// Nombre del archivo de la BD cifrada.
///
/// Deliberadamente distinto del `la_valiente.sqlite` que usaba `drift_flutter`:
/// SQLCipher no puede abrir un archivo en claro, así que un archivo viejo de
/// desarrollo tumbaría el arranque en vez de ser ignorado.
const String kDatabaseFileName = 'la_valiente.db';

/// Abre la base de datos local cifrada con SQLCipher (plan 0004 D12).
///
/// Se abandonó `drift_flutter` por dos razones: su opener no expone
/// `isolateSetup`, y la biblioteca de SQLCipher tiene que cargarse **dentro**
/// del isolate que abre la conexión (un `open.overrideFor` hecho en el isolate
/// principal no se ve desde el de la BD, y sqlite3 caería en la implementación
/// del sistema — es decir, escribiría todo en claro). Además arrastra
/// `sqlite3_flutter_libs`, que declara la misma clase de plugin Android que
/// `sqlcipher_flutter_libs` y hace fallar el dex merge. No lo vuelvas a
/// agregar.
///
/// [readKey] se resuelve al abrir, no al construir, para que la BD siga siendo
/// un objeto sincrónico pese a que la llave viva en almacenamiento seguro.
QueryExecutor openEncryptedDatabase({required Future<String> Function() readKey}) {
  return LazyDatabase(() async {
    // Esto usa un MethodChannel, así que corre aquí y no en el isolate.
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

    final hexKey = await readKey();
    final documents = await getApplicationDocumentsDirectory();
    final temporary = await getTemporaryDirectory();
    final file = File(p.join(documents.path, kDatabaseFileName));
    final temporaryPath = temporary.path;

    return NativeDatabase.createInBackground(
      file,
      // Ambos callbacks cruzan al isolate de la BD: solo pueden capturar
      // valores enviables (aquí, dos Strings).
      isolateSetup: () => _loadSqlCipher(temporaryPath),
      setup: (database) => unlockDatabase(database, hexKey),
    );
  });
}

void _loadSqlCipher(String temporaryDirectory) {
  if (Platform.isAndroid) {
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }

  // sqlite3 guarda resultados intermedios en `/tmp`, inaccesible para una app
  // Android en sandbox.
  sqlite3.tempDirectory = temporaryDirectory;
}

/// Descifra la conexión y comprueba que de verdad estemos sobre SQLCipher.
///
/// Público para que los tests puedan ejercitar la verificación sin montar un
/// isolate.
void unlockDatabase(Database database, String hexKey) {
  // Llave cruda de 256 bits: el formato `x'…'` se la pasa tal cual a
  // SQLCipher, sin derivarla con PBKDF2. Tiene que ser la primera sentencia.
  database.execute("PRAGMA key = \"x'$hexKey'\";");

  if (database.select('PRAGMA cipher_version;').isEmpty) {
    throw StateError(
      'La BD local se abrió con un SQLite sin SQLCipher: los datos quedarían '
      'en claro. Revisa que sqlcipher_flutter_libs esté enlazado en esta '
      'plataforma.',
    );
  }

  // Primera lectura real del archivo: si la llave no corresponde, falla aquí
  // y no a mitad de una consulta de negocio.
  database.execute('SELECT count(*) FROM sqlite_master;');
}
