import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../models/cash_sheet.dart';
import '../models/scan.dart';
import '../models/ticket_lookup.dart';

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

  /// Manda la foto de una boleta **que ya existe** y devuelve cuál es
  /// (plan 0006 §7.1.1).
  ///
  /// Misma foto, mismo modelo y mismo prompt que `scan`; lo que cambia es la
  /// pregunta. Acá no se captura nada: la respuesta son los identificadores del
  /// papel y el pedido al que apuntan, para que el mostrador lo marque sin
  /// teclear. Entregarlo sigue siendo cosa de la entrega, con su permiso.
  Future<TicketLookupResult> lookup(
    Uint8List image, {
    String filename = 'boleta.jpg',
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(image, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/scans/lookup',
      data: form,
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return TicketLookupResult.fromJson(response.data!);
  }

  Future<ScanResult> get(String scanId) async {
    final response = await _dio.get<Map<String, dynamic>>('/scans/$scanId');
    return ScanResult.fromJson(response.data!);
  }

  /// Manda la foto de la hoja «Registro Diario» y devuelve lo que propone
  /// hacerse con ella (plan 0005 §1).
  ///
  /// Tarda más que una boleta —es una página con hasta tres días y cuarenta y
  /// cinco filas— así que se le da más margen. Sigue sin escribir nada: la
  /// respuesta es una propuesta, y aplicarla es [applyCashSheet].
  Future<CashSheetResult> scanCashSheet(
    Uint8List image, {
    String filename = 'cierre.jpg',
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(image, filename: filename),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/scans/cash-close',
      data: form,
      options: Options(receiveTimeout: const Duration(seconds: 90)),
    );
    return CashSheetResult.fromJson(response.data!);
  }

  /// Archiva lo que una persona confirmó de un día de la hoja.
  ///
  /// **En línea y sin outbox**, y aquí la razón es más fuerte que en el escaneo:
  /// lo que se manda son cobros y entregas calculados contra saldos que el
  /// servidor tenía hace un minuto. Encolarlos para aplicarlos mañana sería
  /// cobrar contra saldos que ya no existen.
  Future<CashSheetApplyResult> applyCashSheet(
    String scanId,
    CashSheetApply data,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/scans/cash-close/$scanId/apply',
      data: data.toJson(),
      options: Options(receiveTimeout: const Duration(seconds: 90)),
    );
    return CashSheetApplyResult.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
ScanRemoteDataSource scanRemoteDataSource(Ref ref) {
  return ScanRemoteDataSource(ref.watch(apiClientProvider));
}
