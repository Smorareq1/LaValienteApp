import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../models/sync_change.dart';
import '../models/sync_operation.dart';

part 'sync_remote_datasource.g.dart';

/// Lote máximo que acepta `POST /sync/push` (plan 0004 §11).
const int kSyncPushMaxOperations = 200;

/// Página máxima de `GET /sync/pull`.
const int kSyncPullPageSize = 500;

/// Llamadas al módulo `sync` del backend. I/O puro: no interpreta resultados.
class SyncRemoteDataSource {
  const SyncRemoteDataSource(this._dio);

  final Dio _dio;

  /// Da de alta esta instalación. El id lo genera el dispositivo (D3), así que
  /// repetir el registro tras reinstalar la app es idempotente por id.
  Future<void> registerDevice({
    required String deviceId,
    required String name,
    required String platform,
    required String appVersion,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/sync/devices',
      data: {'id': deviceId, 'name': name, 'platform': platform, 'app_version': appVersion},
    );
  }

  Future<SyncPushResult> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync/push',
      data: {
        'device_id': deviceId,
        'operations': operations.map((operation) => operation.toWire()).toList(),
      },
    );
    return SyncPushResult.fromJson(response.data!);
  }

  Future<SyncPullPage> pull({
    required String deviceId,
    required int cursor,
    int pageSize = kSyncPullPageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/sync/pull',
      queryParameters: {'device_id': deviceId, 'cursor': cursor, 'page_size': pageSize},
    );
    return SyncPullPage.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
SyncRemoteDataSource syncRemoteDataSource(Ref ref) {
  return SyncRemoteDataSource(ref.watch(apiClientProvider));
}
