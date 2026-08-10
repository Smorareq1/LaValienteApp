import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/scan_remote_datasource.dart';
import '../models/scan.dart';

part 'scan_controller.g.dart';

/// En qué va el escaneo.
sealed class ScanState {
  const ScanState();
}

/// Todavía no hay foto: la pantalla enseña la guía de encuadre.
class ScanIdle extends ScanState {
  const ScanIdle();
}

/// Hay foto y se está mandando. Los bytes se guardan para poder enseñarla
/// mientras se espera, y después al lado del formulario (§4).
class ScanSending extends ScanState {
  const ScanSending(this.image);

  final Uint8List image;
}

class ScanDone extends ScanState {
  const ScanDone(this.image, this.result);

  final Uint8List image;
  final ScanResult result;
}

class ScanFailed extends ScanState {
  const ScanFailed(this.image, this.failure);

  final Uint8List image;
  final AppFailure failure;
}

/// El escaneo de una boleta (Plan 0003 §4).
///
/// No guarda nada. Produce un borrador y lo entrega a la toma de pedido, que es
/// la única pantalla que escribe — el principio inviolable del plan.
@riverpod
class ScanController extends _$ScanController {
  @override
  ScanState build() => const ScanIdle();

  Future<Either<AppFailure, ScanResult>> send(Uint8List image) async {
    state = ScanSending(image);
    try {
      final result = await ref.read(scanRemoteDataSourceProvider).scan(image);
      state = ScanDone(image, result);
      return Right(result);
    } catch (error) {
      final failure = AppFailure.fromException(error);
      // La foto se conserva: quien acaba de encuadrar una boleta con las manos
      // ocupadas no debería tener que volver a tomarla porque se cayó la red.
      state = ScanFailed(image, failure);
      return Left(failure);
    }
  }

  /// Vuelve a mandar la misma foto, que es lo que casi siempre hace falta tras
  /// un fallo de red.
  Future<Either<AppFailure, ScanResult>> retry() async {
    final image = switch (state) {
      ScanFailed(:final image) => image,
      ScanDone(:final image) => image,
      ScanSending(:final image) => image,
      ScanIdle() => null,
    };
    if (image == null) {
      return const Left(ValidationFailure('No hay ninguna foto que reintentar'));
    }
    return send(image);
  }

  void reset() => state = const ScanIdle();
}
