import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Almacenamiento seguro para tokens de sesión y credenciales sensibles.
/// Único punto de la app autorizado para persistir datos sensibles.
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const String _kAccessToken = 'auth.access_token';
  static const String _kRefreshToken = 'auth.refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }

  Future<bool> hasSession() async => await readRefreshToken() != null;
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) {
  return const SecureStorageService(FlutterSecureStorage());
}
