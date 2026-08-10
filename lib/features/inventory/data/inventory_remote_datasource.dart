import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/money/fixed2.dart';
import '../../../core/network/api_client.dart';
import '../models/product.dart';

part 'inventory_remote_datasource.g.dart';

/// I/O contra `/inventory` para las pantallas de administración (§8.3–§8.5).
///
/// **En línea.** Vender un insumo aguanta sin señal porque es captura de
/// mostrador; dar de alta un producto o registrar una compra no (plan 0005
/// D11). Un lote además **mueve dinero**: entra al kardex y puede abrir un
/// gasto del día, y eso no se resuelve a ciegas contra un espejo local.
class InventoryRemoteDataSource {
  const InventoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ProductSummary> createProduct(ProductInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/inventory/products',
      data: input.toJson(withActive: false),
    );
    return ProductSummary.fromJson(response.data!);
  }

  Future<ProductSummary> updateProduct(String id, ProductInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/inventory/products/$id',
      data: input.toJson(withActive: true),
    );
    return ProductSummary.fromJson(response.data!);
  }

  /// Sube la foto. El `image_path` que vuelve cambia en cada subida, que es
  /// justo lo que deja saber que la copia en disco ya no es la buena (D10).
  Future<ProductSummary> setImage(String id, Uint8List bytes) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: 'product.jpg'),
    });
    final response = await _dio.put<Map<String, dynamic>>(
      '/inventory/products/$id/image',
      data: form,
    );
    return ProductSummary.fromJson(response.data!);
  }

  /// Registra una compra. El **número de lote lo asigna el sistema** (D3) y
  /// vuelve en la respuesta, que es lo que la confirmación enseña.
  Future<ProductLot> registerLot(String productId, LotInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/inventory/products/$productId/lots',
      data: input.toJson(),
    );
    return ProductLot.fromJson(response.data!);
  }

  Future<void> recordMovement(MovementInput input) async {
    await _dio.post<Map<String, dynamic>>(
      '/inventory/movements',
      data: input.toJson(),
    );
  }
}

/// Lo que el formulario de producto manda (§8.3).
class ProductInput {
  const ProductInput({
    required this.name,
    required this.unit,
    this.description,
    this.isActive = true,
  });

  final String name;

  /// bote, bolsa, galón, saco… texto libre porque lo decide el proveedor.
  final String unit;

  final String? description;
  final bool isActive;

  Map<String, dynamic> toJson({required bool withActive}) => <String, dynamic>{
    'name': name,
    'unit': unit,
    'description': description,
    if (withActive) 'is_active': isActive,
  };
}

/// Lo que el formulario de lote manda (§8.4).
class LotInput {
  const LotInput({
    required this.quantityReceived,
    required this.receivedAt,
    this.unitCost,
    this.salePrice,
    this.notes,
    this.expense,
  });

  /// Centésimas, como todas las cantidades.
  final int quantityReceived;

  /// `YYYY-MM-DD`.
  final String receivedAt;

  /// Centavos. Sin él no se puede saber la ganancia (D3), pero se deja pasar:
  /// un lote se registra desde la estantería y no siempre con la factura en la
  /// mano.
  final int? unitCost;

  /// Centavos. Vacío significa que la casa se lo queda: nunca se vende.
  final int? salePrice;

  final String? notes;

  /// Cuando va, la compra se asienta como gasto del mismo día (plan 0005 §6.3).
  final LotExpenseInput? expense;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'quantity_received': Fixed2.format(quantityReceived),
    'unit_cost': unitCost == null ? null : Fixed2.format(unitCost!),
    'sale_price': salePrice == null ? null : Fixed2.format(salePrice!),
    'received_at': receivedAt,
    'notes': notes,
    if (expense != null) 'expense': expense!.toJson(),
  };
}

/// El lado del dinero de una compra que llega.
///
/// Va **junto** con el lote y no como un gasto aparte: la estantería y los
/// gastos del día dejan de cuadrar en el momento en que uno se puede escribir
/// sin el otro.
class LotExpenseInput {
  const LotExpenseInput({
    required this.total,
    this.method = 'cash',
    this.pending = false,
    this.observations,
  });

  /// Centavos.
  final int total;

  final String method;

  /// El «pago atrasado» de la hoja: el proveedor entregó, el dinero no ha
  /// salido, y el día lo sigue debiendo.
  final bool pending;

  final String? observations;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total': Fixed2.format(total),
    'method': method,
    'pending': pending,
    'observations': observations,
  };
}

/// Lo que el formulario de movimiento manda (§8.5).
class MovementInput {
  const MovementInput({
    required this.lotId,
    required this.type,
    required this.quantity,
    this.notes,
  });

  final String lotId;
  final MovementType type;

  /// Centésimas. Negativa solo en un ajuste, que es un conteo que salió corto.
  final int quantity;

  final String? notes;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'lot_id': lotId,
    'movement_type': type.wire,
    'quantity': Fixed2.format(quantity),
    'notes': notes,
  };
}

@Riverpod(keepAlive: true)
InventoryRemoteDataSource inventoryRemoteDataSource(Ref ref) {
  return InventoryRemoteDataSource(ref.watch(apiClientProvider));
}
