import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/catalog_remote_datasource.dart';
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
