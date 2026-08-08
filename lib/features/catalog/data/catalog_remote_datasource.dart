import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/network/api_client.dart';
import '../models/catalog_admin.dart';

part 'catalog_remote_datasource.g.dart';

/// I/O contra `/catalog` para la administración (§10.1 y §10.2).
///
/// **En línea**, como toda la gestión. Lo que el mostrador necesita para cobrar
/// baja por el feed al espejo local; esto es lo otro, lo que **cambia** el
/// catálogo, y no tiene sentido hacerlo a ciegas.
class CatalogRemoteDataSource {
  const CatalogRemoteDataSource(this._dio);

  final Dio _dio;

  /// Todos, incluidos los apagados: esta es la pantalla que los administra.
  Future<List<AdminService>> services() async {
    final response = await _dio.get<List<dynamic>>(
      '/catalog/service-types',
      queryParameters: {'include_inactive': true},
    );
    return [
      for (final item in response.data ?? const [])
        AdminService.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<AdminService> service(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/catalog/service-types/$id',
    );
    return AdminService.fromJson(response.data!);
  }

  /// Crea el servicio con sus opciones, si es por tramos.
  ///
  /// **Sin precios**: el endpoint no los acepta y no es un descuido, es el
  /// modelo — un precio es una ventana con fecha (plan 0001 D1) y se registra
  /// aparte. Por eso el asistente del §10.1 sigue con [registerPrice] y no
  /// termina hasta haberlos puesto: un servicio sin precio no se puede cobrar.
  Future<AdminService> createService(NewService input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/catalog/service-types',
      data: input.toJson(),
    );
    return AdminService.fromJson(response.data!);
  }

  /// Editar un servicio no toca ni el código ni la modalidad: son a lo que
  /// apuntan los pedidos ya tomados y de lo que depende cómo se cobra.
  Future<AdminService> updateService(
    String id, {
    required String name,
    String? unitLabel,
    required bool isActive,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/catalog/service-types/$id',
      data: {'name': name, 'unit_label': unitLabel, 'is_active': isActive},
    );
    return AdminService.fromJson(response.data!);
  }

  /// El historial completo, con las ventanas cerradas incluidas.
  Future<List<AdminPrice>> prices(String serviceId) async {
    final response = await _dio.get<List<dynamic>>(
      '/catalog/service-types/$serviceId/prices',
    );
    return [
      for (final item in response.data ?? const [])
        AdminPrice.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Abre una ventana nueva; el servidor cierra la anterior el día anterior.
  /// Los pedidos ya tomados **no cambian**: cada uno guardó su propio precio.
  Future<AdminPrice> registerPrice(
    String serviceId, {
    required int amount,
    required String validFrom,
    String? optionId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/catalog/service-types/$serviceId/prices',
      data: {
        'price': Fixed2.format(amount),
        'valid_from': validFrom,
        'service_option_id': optionId,
      },
    );
    return AdminPrice.fromJson(response.data!);
  }

  Future<List<AdminGarment>> garments() async {
    final response = await _dio.get<List<dynamic>>(
      '/catalog/garment-types',
      queryParameters: {'include_inactive': true},
    );
    return [
      for (final item in response.data ?? const [])
        AdminGarment.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<AdminGarment> createGarment({
    required String name,
    String? notes,
    int sortOrder = 0,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/catalog/garment-types',
      data: {'name': name, 'notes': notes, 'sort_order': sortOrder},
    );
    return AdminGarment.fromJson(response.data!);
  }

  Future<AdminGarment> updateGarment(
    String id, {
    required String name,
    String? notes,
    int? sortOrder,
    required bool isActive,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/catalog/garment-types/$id',
      data: {
        'name': name,
        'notes': notes,
        'sort_order': sortOrder,
        'is_active': isActive,
      },
    );
    return AdminGarment.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
CatalogRemoteDataSource catalogRemoteDataSource(Ref ref) {
  return CatalogRemoteDataSource(ref.watch(apiClientProvider));
}
