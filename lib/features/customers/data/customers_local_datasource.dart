import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/search_text.dart';
import '../../../core/database/tables/synced_columns.dart';
import '../models/customer.dart';

part 'customers_local_datasource.g.dart';

/// Lectura y escritura de clientes en la BD local. I/O puro sobre Drift.
class CustomersLocalDataSource {
  const CustomersLocalDataSource(this._database);

  final AppDatabase _database;

  /// Clientes activos, filtrados por [query] sobre el índice de búsqueda.
  ///
  /// Los tombstones y los archivados se excluyen aquí y no en la UI: una fila
  /// borrada en otro dispositivo no debe poder llegar a un pedido nuevo.
  Stream<List<Customer>> watch({String query = '', int limit = 50}) {
    final needle = normalizeForSearch(query);
    final select = _database.select(_database.customerEntries)
      ..where((row) => row.deletedAt.isNull() & row.isActive.equals(true))
      ..orderBy([(row) => OrderingTerm.asc(row.searchIndex)])
      ..limit(limit);
    if (needle.isNotEmpty) {
      select.where((row) => row.searchIndex.like('%$needle%'));
    }
    return select.watch().map((rows) => rows.map(Customer.fromRow).toList());
  }

  /// Cuántos clientes activos hay, sin el tope de [watch].
  ///
  /// Se cuenta aparte porque la lista trae una página y la cabecera dice el
  /// total: mostrar "50 registrados" cuando hay 312 sería mentir.
  Stream<int> watchCount() {
    final total = _database.customerEntries.id.count();
    final query = _database.selectOnly(_database.customerEntries)
      ..addColumns([total])
      ..where(
        _database.customerEntries.deletedAt.isNull() &
            _database.customerEntries.isActive.equals(true),
      );
    return query.watchSingle().map((row) => row.read(total) ?? 0);
  }

  /// El cliente [id] en vivo, o `null` si no existe o ya se archivó.
  ///
  /// El detalle mira este stream y no una lectura suelta para que al guardar
  /// una edición la pantalla se actualice sola, y para que archivar la vacíe
  /// sin que nadie tenga que acordarse de refrescarla.
  Stream<Customer?> watchById(String id) {
    return (_database.select(_database.customerEntries)..where(
              (entry) =>
                  entry.id.equals(id) &
                  entry.deletedAt.isNull() &
                  entry.isActive.equals(true),
            ))
        .watchSingleOrNull()
        .map((row) => row == null ? null : Customer.fromRow(row));
  }

  Future<Customer?> byId(String id) async {
    final row = await (_database.select(
      _database.customerEntries,
    )..where((entry) => entry.id.equals(id))).getSingleOrNull();
    return row == null ? null : Customer.fromRow(row);
  }

  /// Escribe la fila con los valores capturados y la deja `pending`.
  ///
  /// [version] es la que se conocía al capturar: se conserva para que el
  /// servidor pueda detectar una escritura sobre datos viejos (D6).
  Future<void> upsertLocal({
    required String id,
    required String fullName,
    required int version,
    String? phone,
    String? nit,
    String? email,
    String? address,
    String? notes,
    bool isActive = true,
  }) {
    return _database
        .into(_database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(
            id: id,
            fullName: fullName,
            version: Value(version),
            syncStatus: Value(RowSyncStatus.pending.name),
            phone: Value(phone),
            nit: Value(nit),
            email: Value(email),
            address: Value(address),
            notes: Value(notes),
            isActive: Value(isActive),
            searchIndex: Value(customerSearchIndex(fullName: fullName, phone: phone)),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}

@Riverpod(keepAlive: true)
CustomersLocalDataSource customersLocalDataSource(Ref ref) {
  return CustomersLocalDataSource(ref.watch(appDatabaseProvider));
}
