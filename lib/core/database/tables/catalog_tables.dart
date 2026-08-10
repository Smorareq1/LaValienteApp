import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Tablas espejo del catálogo (plan 0004 §7.3: servidor → app, sin ops locales).
///
/// Las columnas son exactamente las que declara `FEED_ENTITIES` del backend. Si
/// allá se agrega una, aquí no aparece sola: el espejo la ignora hasta que se
/// declare, que es lo que se quiere — el feed nunca escribe columnas sorpresa.

@DataClassName('ServiceTypeEntry')
class ServiceTypeEntries extends Table with SyncedColumns {
  TextColumn get code => text().withLength(max: 50)();
  TextColumn get name => text().withLength(max: 120)();

  /// `per_unit`, `tiered` o `variable` (plan 0001 §5.2). Se guarda el string
  /// del servidor tal cual: un enum local obligaría a migrar la BD cada vez que
  /// el catálogo estrene una modalidad.
  TextColumn get pricingMode => text().withLength(max: 20)();

  TextColumn get unitLabel => text().withLength(max: 30).nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ServiceOptionEntry')
class ServiceOptionEntries extends Table with SyncedColumns {
  TextColumn get serviceTypeId => text()();
  TextColumn get code => text().withLength(max: 20)();
  TextColumn get name => text().withLength(max: 120)();

  /// Rango de piezas que selecciona la opción (lavado a mano N2 = 1 a 4).
  IntColumn get minQuantity => integer().nullable()();
  IntColumn get maxQuantity => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ServicePriceEntry')
class ServicePriceEntries extends Table with SyncedColumns {
  TextColumn get serviceTypeId => text()();
  TextColumn get serviceOptionId => text().nullable()();

  /// Texto, no `real`: un double convierte Q2.50 en algo que no es Q2.50 y el
  /// error aparece meses después en un total. El servidor lo manda como string
  /// por la misma razón.
  TextColumn get price => text().withLength(max: 20)();

  /// Fechas de negocio en `YYYY-MM-DD`. No llevan hora ni zona: el día en que
  /// un precio entra en vigor es un dato del local, no un instante UTC.
  TextColumn get validFrom => text().withLength(max: 10)();
  TextColumn get validTo => text().withLength(max: 10).nullable()();
}

@DataClassName('GarmentTypeEntry')
class GarmentTypeEntries extends Table with SyncedColumns {
  TextColumn get name => text().withLength(max: 80)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
