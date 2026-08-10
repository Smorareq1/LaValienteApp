import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

/// Emite `true` cuando el dispositivo vuelve a tener una interfaz de red.
///
/// Es una señal de *oportunidad*, no una garantía: tener wifi no significa que
/// el backend responda. Quien la escuche debe seguir tolerando el fallo.
/// Aislado en un provider para que las pruebas puedan sustituirlo sin tocar
/// canales de plataforma.
@Riverpod(keepAlive: true)
Stream<bool> connectivityChanges(Ref ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => results.any((result) => result != ConnectivityResult.none),
  );
}
