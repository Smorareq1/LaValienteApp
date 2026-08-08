import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/time/business_date.dart';
import '../../sync/state/sync_engine.dart';
import '../../sync/state/sync_status_controller.dart';
import '../data/daily_close_remote_datasource.dart';
import '../domain/close_warnings.dart';
import '../models/day_close.dart';

part 'day_close_controller.g.dart';

/// Cuántos días atrás llega el histórico si nadie pide un rango (igual que el
/// `DEFAULT_HISTORY_DAYS` del backend).
const int kCloseHistoryDays = 30;

/// El acta de una fecha, tal como la pantalla del cierre la necesita.
class DayCloseSheet {
  const DayCloseSheet({required this.preview, required this.warnings, this.closure});

  /// Las cifras del servidor, que son las oficiales (plan 0004 D10).
  final DayClosePreview preview;

  /// Ya en español y listas para pintar.
  final List<CloseWarning> warnings;

  /// El acta archivada, presente solo si la fecha está cerrada. Trae lo que el
  /// preview no puede traer: quién cerró, cuándo y con qué notas.
  final DayClosureRecord? closure;

  bool get isClosed => preview.isClosed;
}

/// El cierre de una fecha: lo que se lee y las dos cosas que se pueden hacer.
///
/// Va contra la API y no contra la BD local a propósito. Es la única pantalla de
/// dinero que **no** se puede resolver con el espejo: el acta declara cuánto
/// valió un día entero, y este dispositivo solo conoce lo que pasó por sus
/// manos. La Caja y el Inicio muestran la vista previa local todo el día; aquí,
/// al firmar, mandan las cifras del servidor.
@riverpod
class DayCloseController extends _$DayCloseController {
  @override
  Future<DayCloseSheet> build(String date) async {
    // El outbox se espera antes de pedir nada: leerlo a medio cargar daría cero
    // en la primera pasada y obligaría a un segundo viaje al servidor en cuanto
    // llegara el número de verdad.
    final unsynced = await ref.watch(pendingOperationsCountProvider.future);

    final remote = ref.watch(dailyCloseRemoteDataSourceProvider);
    final preview = await remote.preview(date);

    // El acta solo se pide cuando hay una: es el único dato que el preview no
    // trae y no tiene sentido gastar un viaje en un día todavía abierto.
    final closure = preview.isClosed
        ? (await remote.history(from: date, to: date))
              .where((record) => !record.isReopened)
              .firstOrNull
        : null;

    return DayCloseSheet(
      preview: preview,
      closure: closure,
      warnings: closeWarnings(codes: preview.warnings, unsyncedCaptures: unsynced),
    );
  }

  /// Archiva el día. La fecha queda bloqueada y el candado baja por el feed.
  Future<Either<AppFailure, DayClosureRecord>> close({String? notes}) {
    return _write(
      () => ref
          .read(dailyCloseRemoteDataSourceProvider)
          .close(date: date, notes: _clean(notes)),
    );
  }

  /// Levanta el candado, con nombre y motivo encima (plan 0005 D9).
  Future<Either<AppFailure, DayClosureRecord>> reopen({required String reason}) {
    final closureId = state.valueOrNull?.closure?.id ?? state.valueOrNull?.preview.closureId;
    if (closureId == null) {
      return Future.value(
        const Left(ValidationFailure('Este día no tiene un acta que reabrir')),
      );
    }
    return _write(
      () => ref
          .read(dailyCloseRemoteDataSourceProvider)
          .reopen(id: closureId, reason: reason.trim()),
    );
  }

  /// Escribe y deja la pantalla contando lo que el servidor acaba de decir.
  ///
  /// Después de escribir se pide un ciclo de sincronización, no por las cifras
  /// —esas ya se releen aquí— sino por el **candado**: la fecha bloqueada vive
  /// en el espejo `daily_closure`, y hasta que el feed la baje, la Caja seguiría
  /// ofreciendo el botón de gasto sobre un día ya firmado. No se espera a que
  /// termine: el ciclo empuja además todo el outbox y puede tardar.
  Future<Either<AppFailure, DayClosureRecord>> _write(
    Future<DayClosureRecord> Function() body,
  ) async {
    try {
      final saved = await body();
      // El ciclo se pide antes de invalidarse a sí mismo: después, este notifier
      // está marcado para morir y `ref` ya no es un sitio del que leer nada.
      unawaited(ref.read(syncEngineProvider.notifier).sync());
      ref.invalidate(closeHistoryProvider);
      ref.invalidateSelf();
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

/// El histórico de cierres (§7.5), lo más reciente primero.
///
/// Trae también las actas reabiertas: un día cerrado en Q764 y luego reabierto
/// es un hecho, y esconderlo dejaría el rastro contando solo la mitad.
@riverpod
Future<List<DayClosureRecord>> closeHistory(Ref ref) async {
  final today = businessDate();
  final since = today.subtract(const Duration(days: kCloseHistoryDays));

  final records = await ref
      .watch(dailyCloseRemoteDataSourceProvider)
      .history(from: isoDate(since), to: isoDate(today));

  return records..sort((a, b) {
    final byDate = b.closeDate.compareTo(a.closeDate);
    // Una fecha puede tener varias actas si se reabrió: la última que se firmó
    // encabeza el grupo y las anteriores quedan debajo, como el rastro que son.
    return byDate != 0 ? byDate : b.closedAt.compareTo(a.closedAt);
  });
}
