import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/offline_credential.dart';

part 'secure_storage_service.g.dart';

/// Almacenamiento seguro para tokens de sesión y credenciales sensibles.
/// Único punto de la app autorizado para persistir datos sensibles.
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const String _kAccessToken = 'auth.access_token';
  static const String _kRefreshToken = 'auth.refresh_token';
  static const String _kUser = 'auth.user';
  static const String _kOfflineCredential = 'auth.offline_credential';
  static const String _kDatabaseKey = 'database.cipher_key';

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  /// Última ficha del usuario, para poder abrir la app sin señal.
  ///
  /// Lleva sus permisos, así que vive aquí y no en la base local: es lo que
  /// decide qué secciones se ven. Se refresca en cada login en línea, y el
  /// servidor manda de todos modos —la app puede enseñar un botón de más, pero
  /// la API devuelve 403 igual.
  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _kUser, value: jsonEncode(user));

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Verificador de contraseña para entrar sin señal en este aparato.
  Future<void> saveOfflineCredential(OfflineCredential credential) =>
      _storage.write(key: _kOfflineCredential, value: jsonEncode(credential.toJson()));

  Future<OfflineCredential?> readOfflineCredential() async {
    final raw = await _storage.read(key: _kOfflineCredential);
    if (raw == null) return null;
    return OfflineCredential.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Cerrar sesión se lleva también la ficha y el verificador: dejarlos sería
  /// dejar la puerta de atrás abierta después de cerrar la de adelante.
  Future<void> clearSession() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUser);
    await _storage.delete(key: _kOfflineCredential);
  }

  Future<bool> hasSession() async => await readRefreshToken() != null;

  /// Llave de cifrado de la base de datos local (plan 0004 D12).
  ///
  /// 256 bits en hexadecimal, generados una sola vez por instalación. Nunca
  /// sale del almacenamiento seguro del sistema operativo ni viaja al
  /// servidor: si el dispositivo se pierde, la BD es un archivo ilegible.
  Future<String> databaseKey() async {
    final existing = await _storage.read(key: _kDatabaseKey);
    if (existing != null) return existing;

    final key = _generateDatabaseKey();
    await _storage.write(key: _kDatabaseKey, value: key);
    return key;
  }

  /// Genera y guarda una llave nueva, devolviéndola.
  ///
  /// La usa el wipe por revocación (D11): re-cifrar la BD con una llave nueva
  /// deja ilegible cualquier resto de las páginas viejas del archivo.
  Future<String> rotateDatabaseKey() async {
    final key = _generateDatabaseKey();
    await _storage.write(key: _kDatabaseKey, value: key);
    return key;
  }

  static String _generateDatabaseKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) {
  return const SecureStorageService(FlutterSecureStorage());
}
