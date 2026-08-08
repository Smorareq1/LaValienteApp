import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'product_image_cache.g.dart';

/// La foto de un producto, guardada en disco para que exista sin señal.
///
/// La imagen **no** es una URL pública: se sirve autenticada desde
/// `GET /inventory/products/{id}/image` (plan 0005 D10), así que un
/// `Image.network` no la podría pedir —no lleva el token— y además la perdería
/// en cuanto el teléfono se quedara sin datos. Por eso se descarga una vez y se
/// guarda.
///
/// La invalidación sale gratis del propio modelo: `image_path` cambia cada vez
/// que se reemplaza la foto y viaja en el feed, así que forma parte del nombre
/// del archivo en caché. Una foto nueva es un archivo nuevo, y la vieja se borra
/// al escribir la nueva.
class ProductImageCache {
  ProductImageCache(this._dio, {Directory? directory}) : _directory = directory;

  final Dio _dio;
  Directory? _directory;

  /// Descargas en vuelo, por producto. Sin esto, una cuadrícula de doce tarjetas
  /// que aparecen a la vez pediría la misma imagen doce veces.
  final Map<String, Future<File?>> _inFlight = {};

  Future<Directory> _cacheDirectory() async {
    final existing = _directory;
    if (existing != null) return existing;
    final support = await getApplicationSupportDirectory();
    final directory = Directory(p.join(support.path, 'product_images'));
    if (!directory.existsSync()) await directory.create(recursive: true);
    return _directory = directory;
  }

  /// El archivo de la foto, bajándola si hace falta.
  ///
  /// `null` cuando el producto no tiene foto o cuando no se pudo traer. Que
  /// falle no es excepcional: pasa cada vez que alguien abre Insumos sin señal
  /// con un producto que nunca se había visto, y la tarjeta enseña su inicial
  /// como cualquier otro día.
  Future<File?> fileFor({required String productId, required String? imagePath}) {
    if (imagePath == null || imagePath.isEmpty) return Future.value(null);
    return _inFlight.putIfAbsent(
      '$productId|$imagePath',
      () => _resolve(productId: productId, imagePath: imagePath),
    );
  }

  Future<File?> _resolve({
    required String productId,
    required String imagePath,
  }) async {
    try {
      final directory = await _cacheDirectory();
      final file = File(p.join(directory.path, _nameFor(productId, imagePath)));
      if (file.existsSync() && file.lengthSync() > 0) return file;

      final response = await _dio.get<List<int>>(
        '/inventory/products/$productId/image',
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      await file.writeAsBytes(bytes, flush: true);
      await _removeStale(directory, productId, keep: file.path);
      return file;
    } catch (_) {
      // Sin señal, sin permiso o con la imagen borrada del servidor. La pantalla
      // ya sabe dibujar un producto sin foto.
      return null;
    } finally {
      _inFlight.remove('$productId|$imagePath');
    }
  }

  /// Las fotos anteriores de este producto. Se van al escribir la nueva, que es
  /// el único momento en que se sabe con certeza cuál sobra.
  Future<void> _removeStale(
    Directory directory,
    String productId, {
    required String keep,
  }) async {
    final prefix = '$productId--';
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      if (entity.path == keep) continue;
      if (p.basename(entity.path).startsWith(prefix)) {
        try {
          await entity.delete();
        } catch (_) {
          // Que no se pueda borrar una foto vieja no rompe nada: ocupa espacio.
        }
      }
    }
  }

  /// `<id>--<ruta saneada>`. Lleva la ruta del servidor dentro para que cambiar
  /// la foto cambie el archivo.
  static String _nameFor(String productId, String imagePath) {
    final safe = imagePath.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return '$productId--$safe';
  }

  /// Olvida lo descargado de un producto. Se llama al subir una foto nueva,
  /// cuando todavía no ha bajado el `image_path` que la nombra.
  Future<void> evict(String productId) async {
    _inFlight.removeWhere((key, _) => key.startsWith('$productId|'));
    try {
      final directory = await _cacheDirectory();
      await _removeStale(directory, productId, keep: '');
    } catch (_) {
      // Idem: no poder limpiar la caché no impide seguir.
    }
  }
}

@Riverpod(keepAlive: true)
ProductImageCache productImageCache(Ref ref) {
  return ProductImageCache(ref.watch(apiClientProvider));
}
