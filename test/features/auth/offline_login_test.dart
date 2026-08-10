import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/auth/offline_credential.dart';
import 'package:la_valiente/core/errors/app_failure.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/auth/data/auth_remote_datasource.dart';
import 'package:la_valiente/features/auth/data/auth_repository.dart';
import 'package:la_valiente/features/auth/models/auth_tokens.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';

final _user = AuthUser(
  id: 'u1',
  username: 'sebasm',
  fullName: 'Sebastián Morales',
  roles: const ['admin'],
  permissions: const ['orders.create', 'orders.read'],
);

DioException _offline() => DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      type: DioExceptionType.connectionError,
    );

DioException _slow() => DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      type: DioExceptionType.connectionTimeout,
    );

DioException _wrongPassword() => DioException(
      requestOptions: RequestOptions(path: '/auth/login'),
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/auth/login'),
        statusCode: 401,
      ),
    );

class _FakeRemote implements AuthRemoteDataSource {
  /// Qué revienta al hablar con el servidor. `null` es que hay señal; cada
  /// prueba lo cambia a mitad de camino para simular que la señal se cae
  /// después de haber entrado una vez.
  DioException? error;

  int loginCalls = 0;

  @override
  Future<AuthTokens> login({required String identifier, required String password}) async {
    loginCalls++;
    if (error != null) throw error!;
    return const AuthTokens(accessToken: 'access', refreshToken: 'refresh');
  }

  @override
  Future<AuthUser> me() async {
    if (error != null) throw error!;
    return _user;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> forgotPassword({required String identifier}) async {}

  @override
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {}
}

/// Almacenamiento seguro en memoria.
class _FakeStorage implements SecureStorageService {
  String? accessToken;
  String? refreshToken;
  Map<String, dynamic>? user;
  OfflineCredential? credential;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> saveUser(Map<String, dynamic> user) async => this.user = user;

  @override
  Future<Map<String, dynamic>?> readUser() async => user;

  @override
  Future<void> saveOfflineCredential(OfflineCredential credential) async =>
      this.credential = credential;

  @override
  Future<OfflineCredential?> readOfflineCredential() async => credential;

  @override
  Future<bool> hasSession() async => refreshToken != null;

  @override
  Future<void> clearSession() async {
    accessToken = null;
    refreshToken = null;
    user = null;
    credential = null;
  }

  @override
  Future<String> databaseKey() async => 'llave';

  @override
  Future<String> rotateDatabaseKey() async => 'llave-2';
}

void main() {
  late _FakeRemote remote;
  late _FakeStorage storage;
  late AuthRepository repository;

  setUp(() {
    remote = _FakeRemote();
    storage = _FakeStorage();
    repository = AuthRepository(remote, storage);
  });

  /// Entrar una vez con señal es lo que deja el teléfono preparado.
  Future<void> primeraEntradaEnLinea() async {
    final result = await repository.login(identifier: 'sebasm', password: 'Morales1');
    expect(result.isRight(), isTrue);
  }

  group('entrar con señal', () {
    test('guarda la ficha y el verificador para la próxima vez', () async {
      await primeraEntradaEnLinea();

      expect(storage.user?['username'], 'sebasm');
      expect(storage.credential, isNotNull);
      expect(storage.credential!.verify('Morales1'), isTrue);
    });

    test('una contraseña equivocada no deja nada guardado', () async {
      // Si el 401 dejara credencial, se podría sembrar el teléfono con una
      // contraseña que el servidor nunca aceptó.
      remote.error = _wrongPassword();
      final result = await repository.login(identifier: 'sebasm', password: 'mala');

      expect(result.isLeft(), isTrue);
      expect(storage.credential, isNull);
      expect(storage.user, isNull);
    });
  });

  group('entrar sin señal', () {
    test('quien ya entró aquí entra con su contraseña', () async {
      await primeraEntradaEnLinea();
      remote.error = _offline();

      final result = await repository.login(identifier: 'sebasm', password: 'Morales1');

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable()!.username, 'sebasm');
    });

    test('conserva los permisos que tenía', () async {
      // Sin ellos la app abriría vacía, que para el caso es no abrir.
      await primeraEntradaEnLinea();
      remote.error = _offline();

      final result = await repository.login(identifier: 'sebasm', password: 'Morales1');

      expect(result.getRight().toNullable()!.permissions, ['orders.create', 'orders.read']);
    });

    test('un servidor que tarda demasiado también cae a la entrada local', () async {
      await primeraEntradaEnLinea();
      remote.error = _slow();

      final result = await repository.login(identifier: 'sebasm', password: 'Morales1');

      expect(result.isRight(), isTrue);
    });

    test('la contraseña equivocada se rechaza igual que en línea', () async {
      await primeraEntradaEnLinea();
      remote.error = _offline();

      final result = await repository.login(identifier: 'sebasm', password: 'otra');

      expect(result.getLeft().toNullable(), isA<AuthFailure>());
    });

    test('otra persona no entra en este teléfono', () async {
      await primeraEntradaEnLinea();
      remote.error = _offline();

      final result = await repository.login(identifier: 'rosa', password: 'Morales1');
      final failure = result.getLeft().toNullable();

      expect(failure, isA<OfflineLoginFailure>());
      expect(failure!.message, contains('ya entró antes'));
    });

    test('en un teléfono nuevo dice que la primera vez pide internet', () async {
      remote.error = _offline();

      final result = await repository.login(identifier: 'sebasm', password: 'Morales1');
      final failure = result.getLeft().toNullable();

      expect(failure, isA<NetworkFailure>());
      expect(failure!.message, contains('primera vez'));
    });

    test('cerrar sesión se lleva el verificador', () async {
      // Cerrar sesión y que la puerta de atrás siguiera abierta sería peor que
      // no cerrarla.
      await primeraEntradaEnLinea();
      await repository.logout();
      remote.error = _offline();

      final result = await repository.login(identifier: 'sebasm', password: 'Morales1');

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });
  });

  group('reabrir la app', () {
    test('sin sesión guardada no hay usuario', () async {
      final result = await repository.restoreSession();
      expect(result.getRight().toNullable(), isNull);
    });

    test('sin señal devuelve la última ficha en vez de rebotar al login', () async {
      await primeraEntradaEnLinea();
      remote.error = _offline();

      final result = await repository.restoreSession();

      expect(result.getRight().toNullable()?.username, 'sebasm');
    });

    test('sin señal y sin ficha guardada sí falla', () async {
      storage.refreshToken = 'refresh';
      remote.error = _offline();

      final result = await repository.restoreSession();

      expect(result.isLeft(), isTrue);
    });

    test('una sesión rechazada por el servidor se limpia', () async {
      // Aquí el servidor sí habló, y dijo que no: eso no se guarda "por si
      // acaso", se borra.
      await primeraEntradaEnLinea();
      remote.error = _wrongPassword();

      final result = await repository.restoreSession();

      expect(result.getRight().toNullable(), isNull);
      expect(storage.credential, isNull);
      expect(storage.user, isNull);
    });
  });
}
