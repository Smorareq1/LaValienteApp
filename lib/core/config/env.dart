/// Configuración de entorno de la app.
///
/// El backend se elige **en compilación**, no en tiempo de ejecución: no hay
/// pantalla de ajustes donde cambiar de servidor. Un APK sabe contra qué API
/// habla desde que se arma, y eso es lo que hace imposible que un dispositivo
/// del mostrador termine escribiendo en la base de desarrollo.
///
/// ```bash
/// flutter run   --dart-define-from-file=dev.json    # desarrollo
/// flutter build apk --release --dart-define-from-file=prod.json   # producción
/// ```
///
/// Los archivos `dev.json` y `prod.json` no se versionan (este repositorio es
/// público); las plantillas son `dev.json.example` y `prod.json.example`.
abstract final class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiV1Prefix = '/api/v1';

  static String get apiV1BaseUrl => '$apiBaseUrl$apiV1Prefix';

  /// Qué entorno se compiló: `dev` (por omisión) o `prod`.
  ///
  /// No decide a qué backend se habla —eso lo hace `API_BASE_URL`— sino que
  /// deja constancia de la intención con la que se armó el binario. Tener las
  /// dos cosas por separado es lo que permite la comprobación de
  /// [isMisconfiguredRelease]: la URL sola no distingue un descuido de una
  /// decisión.
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static bool get isProd => appEnv == 'prod';

  /// Versión que la app reporta al registrar el dispositivo (plan 0004 §6.2).
  /// Se inyecta en el build: `--dart-define=APP_VERSION=1.2.0`.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// Un APK de release que apunta a una dirección de desarrollo.
  ///
  /// Es el error caro y silencioso de este esquema: `flutter build apk
  /// --release` sin `--dart-define-from-file` compila **sin aviso** contra el
  /// `defaultValue` de arriba, `http://localhost:8000`. El APK se instala, abre
  /// y solo falla al primer intento de login, ya en manos de alguien del
  /// mostrador y lejos de quien lo armó.
  ///
  /// `localhost` y `10.0.2.2` en un release no tienen lectura inocente: el
  /// primero es el teléfono mismo y el segundo solo existe dentro del emulador
  /// de Android. Ninguno puede ser lo que se quiso.
  static bool get isMisconfiguredRelease {
    final uri = Uri.tryParse(apiBaseUrl);
    final host = uri?.host ?? '';
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }
}
