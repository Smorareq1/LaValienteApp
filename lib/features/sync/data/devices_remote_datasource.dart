import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'devices_remote_datasource.g.dart';

/// Un dispositivo registrado para sincronizar (plan 0004 D11).
class SyncDevice {
  const SyncDevice({
    required this.id,
    required this.userId,
    required this.name,
    this.platform,
    this.appVersion,
    this.lastSeenAt,
    this.revokedAt,
  });

  factory SyncDevice.fromJson(Map<String, dynamic> json) => SyncDevice(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    platform: json['platform'] as String?,
    appVersion: json['app_version'] as String?,
    lastSeenAt: DateTime.tryParse(json['last_seen_at'] as String? ?? ''),
    revokedAt: DateTime.tryParse(json['revoked_at'] as String? ?? ''),
  );

  final String id;
  final String userId;
  final String name;
  final String? platform;
  final String? appVersion;

  /// Última vez que habló con el servidor. Nulo si nunca lo hizo.
  final DateTime? lastSeenAt;

  final DateTime? revokedAt;

  bool get isRevoked => revokedAt != null;
}

/// I/O contra `/sync/devices`.
///
/// Revocar es lo único que se hace desde aquí, y es **grave**: el dispositivo
/// borra su base local en el siguiente contacto (D11). Lo que todavía no haya
/// subido se pierde con ella.
class DevicesRemoteDataSource {
  const DevicesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<SyncDevice>> list() async {
    final response = await _dio.get<List<dynamic>>('/sync/devices');
    return [
      for (final item in response.data ?? const [])
        SyncDevice.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<SyncDevice> revoke(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync/devices/$id/revoke',
    );
    return SyncDevice.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
DevicesRemoteDataSource devicesRemoteDataSource(Ref ref) {
  return DevicesRemoteDataSource(ref.watch(apiClientProvider));
}
