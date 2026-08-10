import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/search_text.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejo de clientes: la primera entidad bidireccional del sistema.
///
/// Hereda de [TableMirror] las dos reglas del feed; lo suyo es traducir el JSON
/// y recalcular el índice de búsqueda, que es local y no viaja en el cable.
class CustomerMirror extends TableMirror<CustomerEntry> {
  const CustomerMirror(super.database);

  @override
  String get entity => 'customer';

  @override
  TableInfo<Table, CustomerEntry> get table => database.customerEntries;

  @override
  CustomerEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    final fullName = data['full_name'] as String;
    final phone = data['phone'] as String?;
    return CustomerEntriesCompanion(
      fullName: Value(fullName),
      phone: Value(phone),
      nit: Value(data['nit'] as String?),
      email: Value(data['email'] as String?),
      address: Value(data['address'] as String?),
      notes: Value(data['notes'] as String?),
      isActive: Value(data['is_active'] as bool),
      searchIndex: Value(customerSearchIndex(fullName: fullName, phone: phone)),
    );
  }
}
