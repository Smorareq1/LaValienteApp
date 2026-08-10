import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/promotions_remote_datasource.dart';
import '../models/promotion.dart';

part 'promotions_admin_controller.g.dart';

/// La lista de promociones de la pantalla de administración (§10.3).
///
/// Va contra la API y no contra la BD local a propósito: aquí se **escribe**, y
/// una promoción editada tiene que verse tal como quedó en el servidor. Lo que
/// baja al espejo por el feed es para ofrecerla en la toma, no para editarla.
@riverpod
class PromotionsAdminController extends _$PromotionsAdminController {
  @override
  Future<List<Promotion>> build() =>
      ref.watch(promotionsRemoteDataSourceProvider).list();

  Future<Either<AppFailure, Promotion>> create(PromotionInput input) =>
      _write(() => ref.read(promotionsRemoteDataSourceProvider).create(input));

  /// Se llama `edit` y no `update` porque `AsyncNotifier` ya usa ese nombre
  /// para su propio `update(state)`.
  Future<Either<AppFailure, Promotion>> edit(String id, PromotionInput input) =>
      _write(() => ref.read(promotionsRemoteDataSourceProvider).update(id, input));

  Future<Either<AppFailure, Promotion>> setActive(
    String id, {
    required bool isActive,
  }) => _write(
    () => ref
        .read(promotionsRemoteDataSourceProvider)
        .setActive(id, isActive: isActive),
  );

  /// Escribe y deja la lista como quedó.
  ///
  /// Se sustituye la fila en memoria en vez de volver a pedir todo: la
  /// respuesta del servidor **es** el estado nuevo, y recargar solo agregaría
  /// un parpadeo y otro viaje.
  Future<Either<AppFailure, Promotion>> _write(
    Future<Promotion> Function() body,
  ) async {
    try {
      final saved = await body();
      final current = state.valueOrNull;
      if (current != null) state = AsyncData(_replacing(current, saved));
      return Right(saved);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }

  static List<Promotion> _replacing(List<Promotion> current, Promotion saved) {
    final updated = [
      for (final promotion in current)
        if (promotion.id == saved.id) saved else promotion,
    ];
    if (!current.any((promotion) => promotion.id == saved.id)) {
      updated.add(saved);
    }
    updated.sort((a, b) => a.name.compareTo(b.name));
    return updated;
  }
}

/// En qué punto de su vigencia está una promoción, que es lo que el plan pide
/// mostrar como badge.
enum PromotionStanding {
  /// Vigente hoy.
  live('Activa'),

  /// Todavía no empieza.
  scheduled('Programada'),

  /// Su ventana ya cerró.
  expired('Vencida'),

  /// Apagada a mano, sin importar las fechas.
  off('Apagada');

  const PromotionStanding(this.label);

  final String label;

  static PromotionStanding of(Promotion promotion, String today) {
    if (!promotion.isActive) return PromotionStanding.off;
    if (promotion.validFrom.compareTo(today) > 0) return PromotionStanding.scheduled;
    final until = promotion.validTo;
    if (until != null && today.compareTo(until) > 0) return PromotionStanding.expired;
    return PromotionStanding.live;
  }
}
