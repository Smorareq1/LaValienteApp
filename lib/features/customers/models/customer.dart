import '../../../core/database/app_database.dart';
import '../../../core/database/tables/synced_columns.dart';

/// Un cliente, tal como lo ve la app.
///
/// Sale siempre de la BD local (plan 0004 D1): la pantalla no distingue entre
/// un cliente que bajó del servidor y uno capturado hace diez segundos sin
/// señal. Lo único que los diferencia es [syncStatus], y es información para
/// mostrar, no para decidir si se puede usar.
class Customer {
  const Customer({
    required this.id,
    required this.fullName,
    required this.version,
    required this.syncStatus,
    this.phone,
    this.nit,
    this.email,
    this.address,
    this.notes,
    this.isActive = true,
  });

  factory Customer.fromRow(CustomerEntry row) => Customer(
        id: row.id,
        fullName: row.fullName,
        version: row.version,
        syncStatus: RowSyncStatus.values.byName(row.syncStatus),
        phone: row.phone,
        nit: row.nit,
        email: row.email,
        address: row.address,
        notes: row.notes,
        isActive: row.isActive,
      );

  final String id;
  final String fullName;
  final String? phone;
  final String? nit;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;

  /// Versión conocida del servidor. `0` mientras solo exista en el dispositivo.
  final int version;

  final RowSyncStatus syncStatus;

  /// Todavía no confirmado por el servidor: la UI lo marca, pero se puede usar.
  bool get isPending => syncStatus == RowSyncStatus.pending;

  /// Su captura cayó a la cola de revisión y necesita una decisión humana.
  bool get needsReview => syncStatus == RowSyncStatus.rejected;
}
