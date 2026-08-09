import 'package:dio/dio.dart';

import '../diagnostics/app_log.dart';

/// Deja en el log una línea por petición con **cuánto tardó**.
///
/// El tiempo es el dato que importa y el que no se puede deducir de otro lado.
/// Un fallo de red y un servidor alcanzable pero lento se ven igual desde la
/// pantalla —las dos veces sale un mensaje de error— y se distinguen aquí: la
/// primera muere en milisegundos, la segunda a los 30 segundos del
/// `receiveTimeout`. Sin este número, "no tengo señal" y "el túnel se colgó"
/// son indistinguibles, que es exactamente el lío que vino a resolver.
///
/// No registra cabeceras ni cuerpos a propósito: por aquí pasan el token y la
/// contraseña del login, y el log del teléfono lo lee cualquiera con el cable.
class LoggingInterceptor extends Interceptor {
  /// Clave en `extra` donde se guarda el arranque del intento.
  ///
  /// Va en `extra` y no en un campo porque un `Dio` atiende varias peticiones a
  /// la vez y un campo compartido mediría la de otro. Se reescribe en cada
  /// `onRequest`, así que el reintento tras un 401 se cronometra desde su
  /// propio arranque y no desde el del intento que lo provocó.
  static const String _startedAt = 'lv_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now();
    appLog('net', '→ ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    appLog(
      'net',
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path}  ${_elapsed(response.requestOptions)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // El `type` de Dio es lo que separa los tres diagnósticos: `connectionError`
    // es que no se alcanzó al servidor, `receiveTimeout` que se le alcanzó y se
    // quedó callado, y `badResponse` que contestó algo que no gustó.
    final what = err.response?.statusCode?.toString() ?? err.type.name;
    appLog(
      'net',
      '✗ $what ${err.requestOptions.method} ${err.requestOptions.path}  '
      '${_elapsed(err.requestOptions)}',
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final started = options.extra[_startedAt];
    if (started is! DateTime) return '';
    return '${DateTime.now().difference(started).inMilliseconds}ms';
  }
}
