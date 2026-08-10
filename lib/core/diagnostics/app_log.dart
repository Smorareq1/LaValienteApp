import 'package:flutter/foundation.dart';

/// Etiqueta con la que arranca toda línea que escribe la app.
///
/// Existe para poder filtrar: en el teléfono, el `logcat` del proceso mezcla lo
/// nuestro con el ruido de Skia, EGL y los plugins, y sin una marca propia no
/// hay forma de quedarse solo con lo de uno.
///
///     flutter run --dart-define-from-file=dev.json
///     adb logcat -s flutter:V | Select-String '\[LV\]'
const String kLogTag = 'LV';

/// Escribe una línea de diagnóstico. **Solo en debug**: en release no compila
/// ni la llamada, porque `kDebugMode` es constante y el árbol se poda.
///
/// [scope] es de dónde viene (`net`, `sync`, …) y sirve para afinar el filtro.
///
/// Nunca hay que pasar por aquí contraseñas, tokens ni cuerpos de petición: el
/// log del dispositivo lo lee cualquiera con el cable puesto, y en esta app el
/// cuerpo de `POST /auth/login` lleva la contraseña en claro. Por eso el
/// interceptor de red registra método, ruta, estado y tiempo, y nada más.
void appLog(String scope, String message) {
  if (!kDebugMode) return;
  final now = DateTime.now();
  final stamp =
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}:'
      '${now.second.toString().padLeft(2, '0')}';
  debugPrint('[$kLogTag] $stamp $scope · $message');
}
