import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../sync/state/sync_engine.dart';
import '../data/inventory_remote_datasource.dart';
import '../data/product_image_cache.dart';
import '../models/product.dart';
import 'shelf_controller.dart';

part 'inventory_admin_controller.g.dart';

/// Las escrituras de administración de inventario (§8.3–§8.5).
///
/// No guarda lista: la que se ve sale del espejo local, que es lo que sigue
/// funcionando sin señal. Lo que hace este controlador es **escribir arriba** y
/// después invalidar lo que quedó viejo, para que la pantalla no siga enseñando
/// un stock que ya cambió mientras el feed baja.
@riverpod
class InventoryAdminController extends _$InventoryAdminController {
  @override
  void build() {}

  Future<Either<AppFailure, ProductSummary>> createProduct(
    ProductInput input, {
    Uint8List? image,
  }) async {
    return _guard(() async {
      final created = await ref
          .read(inventoryRemoteDataSourceProvider)
          .createProduct(input);
      // La foto va en una segunda llamada porque el endpoint la cuelga de un
      // producto que ya existe. Si falla, el producto queda creado sin foto:
      // se dice y se vuelve a intentar, que es mejor que perder lo tecleado.
      if (image == null) return created;
      return ref.read(inventoryRemoteDataSourceProvider).setImage(created.id, image);
    });
  }

  Future<Either<AppFailure, ProductSummary>> editProduct(
    String id,
    ProductInput input, {
    Uint8List? image,
  }) async {
    return _guard(() async {
      final saved = await ref
          .read(inventoryRemoteDataSourceProvider)
          .updateProduct(id, input);
      if (image == null) return saved;
      final withImage = await ref
          .read(inventoryRemoteDataSourceProvider)
          .setImage(id, image);
      // La copia en disco apunta al `image_path` viejo, así que se tira: la
      // siguiente lectura baja la nueva (D10).
      await ref.read(productImageCacheProvider).evict(id);
      return withImage;
    });
  }

  Future<Either<AppFailure, ProductLot>> registerLot(
    String productId,
    LotInput input,
  ) => _guard(
    () => ref.read(inventoryRemoteDataSourceProvider).registerLot(productId, input),
  );

  Future<Either<AppFailure, void>> recordMovement(MovementInput input) =>
      _guard(() => ref.read(inventoryRemoteDataSourceProvider).recordMovement(input));

  /// Escribe arriba y **espera al feed** antes de dar la escritura por hecha.
  ///
  /// Estas pantallas leen del espejo local, así que lo que se acaba de guardar
  /// no existe para ellas hasta que baja por el feed. Sin este ciclo el producto
  /// recién dado de alta no aparecía: había que ir a Sincronizar y volver, y la
  /// pantalla mientras tanto decía que no había nada — que es exactamente lo que
  /// dice cuando algo falló.
  ///
  /// El ciclo se espera en vez de lanzarse al aire para que la sheet siga
  /// mostrando su spinner hasta que la fila esté en disco; al cerrarse, la lista
  /// de atrás ya la tiene. `sync` no lanza: un corte de red deja el producto
  /// guardado arriba y la pantalla al día en el siguiente ciclo.
  Future<Either<AppFailure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      final result = await body();
      await ref.read(syncEngineProvider.notifier).sync(reason: 'alta de inventario');
      ref.invalidate(inventoryProductsProvider);
      ref.invalidate(productDetailProvider);
      return Right(result);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }
}

/// Abre la cámara o la galería y devuelve los bytes.
///
/// Se le pide una imagen ya reducida —1440 px de lado mayor, calidad 82— porque
/// la foto de un bote de jabón no necesita más y el servidor tiene un tope de
/// 5 MB. Reducir aquí evita subir 12 MB por una miniatura de 46 px.
@riverpod
ProductImagePicker productImagePicker(Ref ref) => const ProductImagePicker();

class ProductImagePicker {
  const ProductImagePicker();

  Future<Uint8List?> pick(AppImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source == AppImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1440,
      maxHeight: 1440,
      imageQuality: 82,
    );
    if (picked == null) return null;
    return picked.readAsBytes();
  }
}
