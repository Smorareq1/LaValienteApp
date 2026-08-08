import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../models/scan.dart';

part 'scan_remote_datasource.g.dart';

/// I/O contra `/scans` (Plan 0003 §8).
///
/// **En línea y sin outbox**, que es la única parte de la captura que lo es
/// (D8, y plan 0004 §7.3). No es una limitación que se pueda esquivar: la foto
/// la lee un modelo que vive del otro lado, y encolarla para escanearla después
/// convertiría el atajo en una espera. Sin señal el botón se deshabilita y la
/// captura a mano —que funciona entera sin este módulo— sigue intacta.
class ScanRemoteDataSource {
  const ScanRemoteDataSource(this._dio);

  final Dio _dio;

  /// Manda la foto y devuelve el borrador.
  ///
  /// Síncrono a propósito: quien escanea está de pie con la boleta en la mano, y
  /// un trabajo que hubiera que consultar después sería peor experiencia que los
  /// segundos que esto tarda.
  Future<ScanResult> scan(Uint8List image, {String filename = 'boleta.jpg'}) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(image, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/scans',
      data: form,
      // El servidor se da 30 s (`SCAN_TIMEOUT_S`) más lo que tarde la foto en
      // subir. Un timeout de cliente más corto que el del servidor dejaría el
      // escaneo cobrado y perdido.
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return ScanResult.fromJson(response.data!);
  }

  Future<ScanResult> get(String scanId) async {
    final response = await _dio.get<Map<String, dynamic>>('/scans/$scanId');
    return ScanResult.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
ScanRemoteDataSource scanRemoteDataSource(Ref ref) {
  return ScanRemoteDataSource(ref.watch(apiClientProvider));
}
