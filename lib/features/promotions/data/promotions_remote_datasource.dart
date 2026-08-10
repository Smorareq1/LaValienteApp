import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/network/api_client.dart';
import '../models/promotion.dart';

part 'promotions_remote_datasource.g.dart';

/// I/O contra `/promotions`. **En línea**, a diferencia de todo lo operativo.
///
/// Administrar promociones no se hace en el mostrador ni sin señal: se decide
/// una vez, con calma, y de ahí baja al dispositivo por el feed. Por eso aquí
/// no hay outbox ni escritura optimista — si no hay red, no se guarda y se
/// dice (plan 0006 §14).
class PromotionsRemoteDataSource {
  const PromotionsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Todas, incluidas las apagadas: esta es la pantalla que las administra y
  /// esconder una apagada la volvería imposible de reactivar.
  Future<List<Promotion>> list() async {
    final response = await _dio.get<List<dynamic>>(
      '/promotions',
      queryParameters: {'include_inactive': true},
    );
    return [
      for (final item in response.data ?? const [])
        Promotion.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Promotion> create(PromotionInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/promotions',
      data: input.toJson(withCode: true),
    );
    return Promotion.fromJson(response.data!);
  }

  /// El código no viaja: es a lo que apuntan los pedidos ya tomados.
  Future<Promotion> update(String id, PromotionInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/promotions/$id',
      data: input.toJson(withCode: false),
    );
    return Promotion.fromJson(response.data!);
  }

  /// Prender o apagar, que es lo que se hace desde la lista.
  Future<Promotion> setActive(String id, {required bool isActive}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/promotions/$id',
      data: {'is_active': isActive},
    );
    return Promotion.fromJson(response.data!);
  }
}

/// Lo que el formulario manda. Separado de [Promotion] porque no es lo mismo:
/// una promoción tiene id y versión, y esto es solo lo que alguien escribió.
class PromotionInput {
  const PromotionInput({
    required this.code,
    required this.name,
    required this.discountType,
    required this.value,
    required this.validFrom,
    this.description,
    this.appliesToServiceCodes,
    this.validTo,
    this.isActive = true,
  });

  final String code;
  final String name;
  final String? description;
  final DiscountType discountType;

  /// Centésimas, como en [Promotion].
  final int value;

  final List<String>? appliesToServiceCodes;
  final String validFrom;
  final String? validTo;
  final bool isActive;

  Map<String, dynamic> toJson({required bool withCode}) => <String, dynamic>{
    if (withCode) 'code': code,
    'name': name,
    'description': description,
    'discount_type': discountType.wire,
    // Texto con dos decimales, igual que los precios: `50` y `50.00` son el
    // mismo porcentaje y ninguno de los dos debe pasar por un double.
    'value': Fixed2.format(value),
    'applies_to_service_codes': appliesToServiceCodes,
    'valid_from': validFrom,
    'valid_to': validTo,
    if (!withCode) 'is_active': isActive,
  };
}

@Riverpod(keepAlive: true)
PromotionsRemoteDataSource promotionsRemoteDataSource(Ref ref) {
  return PromotionsRemoteDataSource(ref.watch(apiClientProvider));
}
