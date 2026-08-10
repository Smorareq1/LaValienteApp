import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../models/catalog.dart';

part 'catalog_repository.g.dart';

/// El catálogo cacheado del dispositivo (plan 0004 §9).
///
/// Solo lee: el catálogo es pull-only, lo edita un admin en línea y aquí llega
/// por el feed. No hay `create` ni `update` que ofrecer, y esa ausencia es la
/// regla del plan hecha código.
class CatalogRepository {
  const CatalogRepository(this._database);

  final AppDatabase _database;

  /// Servicios activos con sus opciones, en el orden en que se muestran.
  ///
  /// Un solo `join` en lugar de una consulta por servicio: así drift vigila las
  /// dos tablas con un stream y la pantalla se redibuja una vez, no N veces.
  Stream<List<ServiceType>> watchServices() => _servicesQuery().watch().map(_toServices);

  /// Los servicios en un solo tiro, para quien no necesita seguirlos en vivo.
  ///
  /// La toma de pedido los lee así: el catálogo lo edita un admin y no cambia a
  /// media captura, y redibujar la pantalla entera porque bajó un precio nuevo
  /// mientras alguien cuenta camisas sería peor que leerlo una vez al abrir.
  Future<List<ServiceType>> services() async => _toServices(await _servicesQuery().get());

  Stream<List<GarmentType>> watchGarmentTypes() =>
      _garmentTypesQuery().watch().map((rows) => rows.map(GarmentType.fromRow).toList());

  Future<List<GarmentType>> garmentTypes() async =>
      (await _garmentTypesQuery().get()).map(GarmentType.fromRow).toList();

  /// Todos los precios vivos, para armar el libro de precios de una fecha.
  ///
  /// Se traen completos y se filtra por vigencia en memoria: son unas decenas de
  /// filas, y hacerlo así deja el filtro de fechas en un solo lugar
  /// ([ServicePrice.covers]) en vez de repetirlo en SQL.
  Future<List<ServicePrice>> prices() async {
    final rows = await (_database.select(
      _database.servicePriceEntries,
    )..where((row) => row.deletedAt.isNull())).get();
    return rows.map(ServicePrice.fromRow).toList();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _servicesQuery() {
    final services = _database.serviceTypeEntries;
    final options = _database.serviceOptionEntries;

    return _database.select(services).join([
        leftOuterJoin(
          options,
          options.serviceTypeId.equalsExp(services.id) &
              options.deletedAt.isNull() &
              options.isActive.equals(true),
        ),
      ])
      ..where(services.deletedAt.isNull() & services.isActive.equals(true))
      ..orderBy([
        OrderingTerm.asc(services.sortOrder),
        OrderingTerm.asc(services.name),
        OrderingTerm.asc(options.sortOrder),
      ]);
  }

  List<ServiceType> _toServices(List<TypedResult> rows) {
    final services = _database.serviceTypeEntries;
    final options = _database.serviceOptionEntries;
    final byId = <String, ServiceTypeEntry>{};
    final optionsByService = <String, List<ServiceOption>>{};

    for (final row in rows) {
      final service = row.readTable(services);
      byId[service.id] = service;
      final option = row.readTableOrNull(options);
      if (option != null) {
        optionsByService.putIfAbsent(service.id, () => []).add(ServiceOption.fromRow(option));
      }
    }

    return byId.values
        .map(
          (service) => ServiceType(
            id: service.id,
            code: service.code,
            name: service.name,
            pricingMode: PricingMode.fromWire(service.pricingMode),
            unitLabel: service.unitLabel,
            sortOrder: service.sortOrder,
            options: optionsByService[service.id] ?? const [],
          ),
        )
        .toList();
  }

  SimpleSelectStatement<$GarmentTypeEntriesTable, GarmentTypeEntry> _garmentTypesQuery() {
    return _database.select(_database.garmentTypeEntries)
      ..where((row) => row.deletedAt.isNull() & row.isActive.equals(true))
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.name),
      ]);
  }

  /// El precio vigente en [onDate] (`YYYY-MM-DD`), o `null` si no hay ninguno.
  ///
  /// Es una **vista previa**: el total que vale es el que recalcula el servidor
  /// al aplicar la operación con el catálogo de esa fecha (D10). Si el precio
  /// cambió mientras el dispositivo estaba sin señal, manda el del servidor.
  Future<ServicePrice?> priceFor({
    required String serviceTypeId,
    required String onDate,
    String? serviceOptionId,
  }) async {
    final query = _database.select(_database.servicePriceEntries)
      ..where((row) {
        final matchesOption = serviceOptionId == null
            ? row.serviceOptionId.isNull()
            : row.serviceOptionId.equals(serviceOptionId);
        return row.deletedAt.isNull() &
            row.serviceTypeId.equals(serviceTypeId) &
            matchesOption;
      });

    final prices = (await query.get()).map(ServicePrice.fromRow).where(
      (price) => price.covers(onDate),
    );
    return prices.isEmpty ? null : prices.first;
  }
}

@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) {
  return CatalogRepository(ref.watch(appDatabaseProvider));
}
