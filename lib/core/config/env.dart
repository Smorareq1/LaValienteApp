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
}
