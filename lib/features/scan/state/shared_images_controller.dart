import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_images_controller.g.dart';

/// Las fotos que llegaron compartidas desde otra app, en cola.
///
/// El caso real: alguien fotografía las boletas del día, las manda al grupo de
/// WhatsApp, y de ahí hay que meterlas al sistema. Sin esto el camino es guardar
/// cada imagen, abrir la app, entrar al escaneo y buscarla en la galería —
/// cuatro pasos por boleta, catorce veces. Con esto es «Compartir → La Valiente»
/// una sola vez, y la app las va pidiendo de una en una.
///
/// **Una cola y no una foto**, que es la decisión de fondo: Android manda las
/// catorce juntas en un solo intent, y quedarse con la primera sería tirar
/// trece. Se guardan todas y se van consumiendo; volver a WhatsApp entre boleta
/// y boleta es justo el viaje que esto evita.
class SharedImages {
  const SharedImages({this.pending = const [], this.kind});

  /// Lo que queda por procesar, en el orden en que se compartió.
  final List<Uint8List> pending;

  /// Qué documento dijo la persona que es **la que se está leyendo ahora**.
  /// `null` mientras no lo haya dicho: una boleta y la hoja del día se ven
  /// parecidas en una miniatura, y adivinar mandaría el papel al lector
  /// equivocado.
  ///
  /// Se pregunta por foto y no por lote, aunque el lote casi siempre sea de un
  /// solo tipo. Es un toque de más cada catorce, y a cambio la pregunta vuelve
  /// sola cuando se termina con una: es lo que hace que la cola avance sin que
  /// nadie tenga que acordarse de que quedaban trece.
  final SharedKind? kind;

  bool get isEmpty => pending.isEmpty;
  int get count => pending.length;

  /// La siguiente, sin sacarla de la cola.
  Uint8List? get next => pending.isEmpty ? null : pending.first;
}

/// Para qué lectura se compartieron las fotos.
enum SharedKind { ticket, cashSheet }

/// Recibe lo compartido y lo mantiene hasta que se consume.
///
/// `keepAlive` a propósito: el intent llega **antes** de que exista ninguna
/// pantalla de escaneo —de hecho es lo que abre la app— y un provider que se
/// desechara al cambiar de ruta perdería las fotos entre la elección del
/// documento y la pantalla que las lee.
@Riverpod(keepAlive: true)
class SharedImagesController extends _$SharedImagesController {
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  @override
  SharedImages build() {
    // En un escritorio o en la web no hay hoja de compartir que escuchar, y el
    // canal del plugin no existe: suscribirse ahí sería un error en el arranque.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _listen();
      ref.onDispose(() => _subscription?.cancel());
    }
    return const SharedImages();
  }

  void _listen() {
    // Con la app ya abierta: el intent llega por el stream.
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      _accept,
      // Un fallo del canal no puede tumbar la app: lo que se pierde es un atajo,
      // y la galería sigue estando donde siempre.
      onError: (Object _) {},
    );
    // Con la app cerrada: el intent es lo que la abrió, y no pasa por el stream.
    unawaited(
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then(_accept)
          .catchError((Object _) {}),
    );
  }

  Future<void> _accept(List<SharedMediaFile> files) async {
    final images = <Uint8List>[];
    for (final file in files) {
      if (file.type != SharedMediaType.image) continue;
      try {
        images.add(await File(file.path).readAsBytes());
      } on FileSystemException {
        // Un archivo que ya no está —el permiso temporal del intent caducó— se
        // salta en silencio. Las demás fotos del lote siguen siendo válidas.
        continue;
      }
    }
    if (images.isEmpty) return;

    // Se acumulan: compartir un segundo lote mientras el primero se procesa es
    // raro, pero descartar el que llegó antes sería perder trabajo hecho.
    state = SharedImages(
      pending: [...state.pending, ...images],
      kind: state.kind,
    );

    // El plugin retiene el último intent y lo volvería a entregar en el próximo
    // arranque. Ya está copiado en memoria: dejarlo puesto duplicaría el lote.
    await ReceiveSharingIntent.instance.reset();
  }

  /// Qué es la foto que se va a leer, y sácala de la cola.
  ///
  /// Las dos cosas juntas a propósito: elegir el tipo **es** empezar a
  /// procesarla, y dejarla en la cola haría que la pregunta se repitiera sobre
  /// la misma foto en cuanto alguien volviera a Inicio.
  Uint8List? takeNext(SharedKind kind) {
    if (state.pending.isEmpty) return null;
    final image = state.pending.first;
    // El tipo se guarda mientras esta foto se lee: es lo que apaga la pregunta.
    // Al terminar la lectura, [done] lo suelta y la cola vuelve a preguntar por
    // la siguiente.
    state = SharedImages(pending: state.pending, kind: kind);
    return image;
  }

  /// Terminó la foto en curso: sale de la cola y vuelve a preguntarse.
  void done() {
    if (state.pending.isEmpty) {
      state = const SharedImages();
      return;
    }
    state = SharedImages(pending: state.pending.sublist(1));
  }

  void clear() => state = const SharedImages();

  /// Solo para las pruebas: mete un lote sin pasar por el canal nativo.
  @visibleForTesting
  void receive(List<Uint8List> images, {SharedKind? kind}) {
    state = SharedImages(pending: [...state.pending, ...images], kind: kind);
  }
}

/// Cuántas fotos compartidas quedan por leer, para el aviso de las pantallas de
/// escaneo. Un `int` y no el estado entero: quien lo mira solo necesita saber si
/// vale la pena ofrecer «la siguiente».
@Riverpod(keepAlive: true)
int sharedImagesPending(Ref ref) {
  return ref.watch(sharedImagesControllerProvider).count;
}
