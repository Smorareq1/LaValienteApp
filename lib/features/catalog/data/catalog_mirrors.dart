import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejos del catálogo. Los cuatro son pull-only (plan 0004 §7.3): el admin
/// edita en línea y el mostrador solo consume lo último que bajó.
List<TableMirror<DataClass>> catalogMirrors(AppDatabase database) => [
  ServiceTypeMirror(database),
  ServiceOptionMirror(database),
  ServicePriceMirror(database),
  GarmentTypeMirror(database),
];

class ServiceTypeMirror extends TableMirror<ServiceTypeEntry> {
  const ServiceTypeMirror(super.database);

  @override
  String get entity => 'service_type';

  @override
  TableInfo<Table, ServiceTypeEntry> get table => database.serviceTypeEntries;

  @override
  ServiceTypeEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ServiceTypeEntriesCompanion(
      code: Value(data['code'] as String),
      name: Value(data['name'] as String),
      pricingMode: Value(data['pricing_mode'] as String),
      unitLabel: Value(data['unit_label'] as String?),
      isActive: Value(data['is_active'] as bool),
      sortOrder: Value(data['sort_order'] as int),
    );
  }
}

class ServiceOptionMirror extends TableMirror<ServiceOptionEntry> {
  const ServiceOptionMirror(super.database);

  @override
  String get entity => 'service_option';

  @override
  TableInfo<Table, ServiceOptionEntry> get table => database.serviceOptionEntries;

  @override
  ServiceOptionEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ServiceOptionEntriesCompanion(
      serviceTypeId: Value(data['service_type_id'] as String),
      code: Value(data['code'] as String),
      name: Value(data['name'] as String),
      minQuantity: Value(data['min_quantity'] as int?),
      maxQuantity: Value(data['max_quantity'] as int?),
      isActive: Value(data['is_active'] as bool),
      sortOrder: Value(data['sort_order'] as int),
    );
  }
}

class ServicePriceMirror extends TableMirror<ServicePriceEntry> {
  const ServicePriceMirror(super.database);

  @override
  String get entity => 'service_price';

  @override
  TableInfo<Table, ServicePriceEntry> get table => database.servicePriceEntries;

  @override
  ServicePriceEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return ServicePriceEntriesCompanion(
      serviceTypeId: Value(data['service_type_id'] as String),
      serviceOptionId: Value(data['service_option_id'] as String?),
      // Llega como string y se guarda como string: convertirlo a double aquí
      // sería introducir el error de redondeo justo en la frontera.
      price: Value(data['price'] as String),
      validFrom: Value(data['valid_from'] as String),
      validTo: Value(data['valid_to'] as String?),
    );
  }
}

class GarmentTypeMirror extends TableMirror<GarmentTypeEntry> {
  const GarmentTypeMirror(super.database);

  @override
  String get entity => 'garment_type';

  @override
  TableInfo<Table, GarmentTypeEntry> get table => database.garmentTypeEntries;

  @override
  GarmentTypeEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    return GarmentTypeEntriesCompanion(
      name: Value(data['name'] as String),
      notes: Value(data['notes'] as String?),
      isActive: Value(data['is_active'] as bool),
      sortOrder: Value(data['sort_order'] as int),
    );
  }
}
