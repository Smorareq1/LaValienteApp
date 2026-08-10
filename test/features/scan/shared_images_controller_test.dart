import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/scan/state/shared_images_controller.dart';

/// La cola de fotos compartidas desde WhatsApp.
///
/// Lo que importa es que **no se pierda ninguna** y que la pregunta de qué es
/// cada una vuelva sola: catorce boletas compartidas de golpe son catorce
/// boletas que capturar, y una cola que se queda callada después de la primera
/// es una cola que hizo perder trece.

Uint8List photo(int seed) => Uint8List.fromList([seed, seed, seed]);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  SharedImagesController notifier() =>
      container.read(sharedImagesControllerProvider.notifier);

  SharedImages state() => container.read(sharedImagesControllerProvider);

  test('arranca vacía y sin tipo elegido', () {
    expect(state().isEmpty, isTrue);
    expect(state().kind, isNull);
  });

  test('un lote entero se guarda, no solo la primera', () {
    notifier().receive([photo(1), photo(2), photo(3)]);

    expect(state().count, 3);
    expect(state().next, photo(1));
  });

  test('elegir el tipo devuelve la foto y apaga la pregunta', () {
    notifier().receive([photo(1), photo(2)]);

    final image = notifier().takeNext(SharedKind.ticket);

    expect(image, photo(1));
    expect(state().kind, SharedKind.ticket);
    // Sigue en la cola: se saca al terminar, no al empezar, para que un fallo
    // a mitad de la lectura no la desaparezca.
    expect(state().count, 2);
  });

  test('terminar una saca la foto y vuelve a preguntar por la siguiente', () {
    notifier().receive([photo(1), photo(2)]);
    notifier().takeNext(SharedKind.ticket);

    notifier().done();

    expect(state().count, 1);
    expect(state().next, photo(2));
    expect(state().kind, isNull);
  });

  test('terminar la última deja la cola vacía', () {
    notifier().receive([photo(1)]);
    notifier().takeNext(SharedKind.cashSheet);

    notifier().done();

    expect(state().isEmpty, isTrue);
    expect(state().kind, isNull);
  });

  test('terminar con la cola vacía no rompe nada', () {
    notifier().done();

    expect(state().isEmpty, isTrue);
  });

  test('un segundo lote se suma al que estaba esperando', () {
    notifier().receive([photo(1)]);
    notifier().receive([photo(2), photo(3)]);

    expect(state().count, 3);
  });

  test('descartar limpia la cola entera', () {
    notifier().receive([photo(1), photo(2)]);

    notifier().clear();

    expect(state().isEmpty, isTrue);
  });

  test('el contador que miran las pantallas sigue a la cola', () {
    expect(container.read(sharedImagesPendingProvider), 0);

    notifier().receive([photo(1), photo(2)]);

    expect(container.read(sharedImagesPendingProvider), 2);
  });
}
