/// Configuración de entorno de la app.
///
/// El base URL del backend se inyecta en compilación:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
/// (en emulador Android `localhost` del host es `10.0.2.2`).
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiV1Prefix = '/api/v1';

  static String get apiV1BaseUrl => '$apiBaseUrl$apiV1Prefix';

  /// Versión que la app reporta al registrar el dispositivo (plan 0004 §6.2).
  /// Se inyecta en el build: `--dart-define=APP_VERSION=1.2.0`.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
}
