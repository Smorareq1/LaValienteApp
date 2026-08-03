import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:la_valiente/core/database/encrypted_connection.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Cabecera de un archivo SQLite sin cifrar.
const String _plainSqliteHeader = 'SQLite format 3';

/// Lo único que no se puede probar en un widget test: que sobre un dispositivo
/// real la BD local abra **y** quede ilegible en disco.
///
/// Corre con `flutter test integration_test/encrypted_database_test.dart` con
/// un emulador o teléfono conectado.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la BD local abre con SQLCipher y escribe cifrado', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final local = container.read(syncLocalDataSourceProvider);

    // Abrir ya es media prueba: si el sqlite3 cargado no fuera SQLCipher, el
    // opener habría lanzado en vez de escribir en claro.
    final state = await local.loadState();
    expect(state.pullCursor, 0);

    await local.enqueue(
      opId: 'prueba-de-integracion',
      entity: 'customer',
      opType: 'create',
      entityId: 'c1',
      payload: const {'full_name': 'Ana Pérez'},
      createdAt: DateTime.now(),
    );
    expect(await local.pendingCount(), 1);

    final documents = await getApplicationDocumentsDirectory();
    final file = File(p.join(documents.path, kDatabaseFileName));
    expect(await file.exists(), isTrue, reason: 'la BD debería existir en disco');

    final bytes = await file.openRead(0, 512).expand((chunk) => chunk).toList();
    final header = String.fromCharCodes(bytes.take(_plainSqliteHeader.length));
    expect(
      header,
      isNot(_plainSqliteHeader),
      reason: 'el archivo se abriría con cualquier visor de SQLite',
    );

    // Y el contenido tampoco puede leerse a ojo.
    final text = String.fromCharCodes(bytes);
    expect(text, isNot(contains('Ana Pérez')));
    expect(text, isNot(contains('outbox_entries')));
  });
}
