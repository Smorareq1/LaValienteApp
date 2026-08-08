import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/catalog_remote_datasource.dart';
import '../models/catalog.dart';
import '../models/catalog_admin.dart';

part 'catalog_admin_controller.g.dart';

/// Los servicios de la pantalla de administración (§10.1).
@riverpod
class ServicesAdminController extends _$ServicesAdminController {
  @override
  Future<List<AdminService>> build() =>
      ref.watch(catalogRemoteDataSourceProvider).services();

  Future<Either<AppFailure, AdminService>> edit(
    String id, {
    required String name,
    String? unitLabel,
    required bool isActive,
  }) async {
    try {
      final saved = await ref
          .read(catalogRemoteDataSourceProvider)
          .updateService(id, name: name, unitLabel: unitLabel, isActive: isActive);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData([
          for (final service in current)
            if (service.id == saved.id) saved else service,
        ]);
      }
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }
}

/// Cómo quedó un alta de servicio.
///
/// Lleva [unpriced] porque crear un servicio con precios son **varias llamadas**
/// —el `POST` del servicio y un `POST` por cada precio— y la mitad puede fallar
/// con el servicio ya creado. Reintentar el alta entera chocaría contra el
/// código, que es único, así que lo honesto es decir qué quedó sin precio y
/// dejar a quien lo creó en el detalle, donde están los botones para terminarlo.
class ServiceCreation {
  const ServiceCreation({required this.service, this.unpriced = const []});

  final AdminService service;

  /// Lo que se quedó sin precio: el nombre del servicio, o el de cada opción.
  final List<String> unpriced;

  bool get isComplete => unpriced.isEmpty;
}

/// El alta de un servicio del §10.1.
///
/// Un servicio sin precio no se puede cobrar —el motor lo cuenta como faltante y
/// el servidor rechaza el pedido—, así que el asistente no termina hasta
/// haberlos registrado. Los de precio variable son la excepción: ahí el monto lo
/// teclea quien captura, y no hay ventana que abrir.
@riverpod
class ServiceCreator extends _$ServiceCreator {
  @override
  void build() {}

  /// [prices] va en centavos, con el **código de la opción** por llave y `null`
  /// para el precio del propio servicio. Por código y no por posición porque los
  /// ids los pone el servidor y solo se conocen después del `POST`.
  Future<Either<AppFailure, ServiceCreation>> create(
    NewService input, {
    Map<String?, int> prices = const {},
    required String validFrom,
  }) async {
    final remote = ref.read(catalogRemoteDataSourceProvider);

    final AdminService created;
    try {
      created = await remote.createService(input);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    // A partir de aquí el servicio ya existe: lo que falle se reporta, no se
    // deshace. El catálogo no tiene borrado y fingir una transacción que la API
    // no ofrece sería peor que decir qué falta.
    final unpriced = <String>[];

    Future<void> put(String? optionCode, String label, String? optionId) async {
      final amount = prices[optionCode];
      if (amount == null) {
        unpriced.add(label);
        return;
      }
      try {
        await remote.registerPrice(
          created.id,
          amount: amount,
          validFrom: validFrom,
          optionId: optionId,
        );
      } catch (_) {
        unpriced.add(label);
      }
    }

    switch (input.pricingMode) {
      case PricingMode.perUnit:
        await put(null, created.name, null);
      case PricingMode.tiered:
        for (final option in created.options) {
          await put(option.code, option.name, option.id);
        }
      case PricingMode.variable:
        break;
    }

    ref.invalidate(servicesAdminControllerProvider);
    return Right(ServiceCreation(service: created, unpriced: unpriced));
  }
}

/// Un servicio con su historial de precios (§10.1).
@riverpod
Future<AdminService> adminService(Ref ref, String id) =>
    ref.watch(catalogRemoteDataSourceProvider).service(id);

@riverpod
Future<List<AdminPrice>> servicePrices(Ref ref, String serviceId) =>
    ref.watch(catalogRemoteDataSourceProvider).prices(serviceId);

/// Registra un precio nuevo.
///
/// Recarga en vez de insertar porque este POST **cambia otra fila**: la ventana
/// vigente queda cerrada el día anterior, y esa fecha la pone el servidor.
@riverpod
class PriceRegistrar extends _$PriceRegistrar {
  @override
  void build() {}

  Future<Either<AppFailure, AdminPrice>> register(
    String serviceId, {
    required int amount,
    required String validFrom,
    String? optionId,
  }) async {
    try {
      final saved = await ref
          .read(catalogRemoteDataSourceProvider)
          .registerPrice(
            serviceId,
            amount: amount,
            validFrom: validFrom,
            optionId: optionId,
          );
      ref.invalidate(servicePricesProvider);
      ref.invalidate(adminServiceProvider);
      ref.invalidate(servicesAdminControllerProvider);
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }
}

/// Los tipos de prenda (§10.2).
@riverpod
class GarmentsAdminController extends _$GarmentsAdminController {
  @override
  Future<List<AdminGarment>> build() =>
      ref.watch(catalogRemoteDataSourceProvider).garments();

  Future<Either<AppFailure, AdminGarment>> create({
    required String name,
    String? notes,
  }) => _write(() async {
    // Al final de la lista: los 21 de la boleta ya tienen su orden y una prenda
    // nueva no se cuela entre ellos.
    final last = state.valueOrNull?.fold<int>(
      0,
      (max, garment) => garment.sortOrder > max ? garment.sortOrder : max,
    );
    return ref
        .read(catalogRemoteDataSourceProvider)
        .createGarment(name: name, notes: notes, sortOrder: (last ?? 0) + 1);
  });

  Future<Either<AppFailure, AdminGarment>> edit(
    String id, {
    required String name,
    String? notes,
    int? sortOrder,
    required bool isActive,
  }) => _write(
    () => ref
        .read(catalogRemoteDataSourceProvider)
        .updateGarment(
          id,
          name: name,
          notes: notes,
          sortOrder: sortOrder,
          isActive: isActive,
        ),
  );

  Future<Either<AppFailure, AdminGarment>> _write(
    Future<AdminGarment> Function() body,
  ) async {
    try {
      final saved = await body();
      final current = state.valueOrNull;
      if (current != null) state = AsyncData(_replacing(current, saved));
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }

  static List<AdminGarment> _replacing(
    List<AdminGarment> current,
    AdminGarment saved,
  ) {
    final updated = [
      for (final garment in current)
        if (garment.id == saved.id) saved else garment,
    ];
    if (!current.any((garment) => garment.id == saved.id)) updated.add(saved);
    updated.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return updated;
  }
}
