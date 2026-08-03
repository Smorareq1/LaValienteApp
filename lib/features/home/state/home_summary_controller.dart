import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/home_summary.dart';

part 'home_summary_controller.g.dart';

/// Resumen del día que consume la pantalla Inicio.
///
/// La fuente real es `GET /daily-close/preview` más la BD local para los
/// contadores de pedidos (Plan 0006 §4.1), y ninguna de las dos existe todavía:
/// el backend solo tiene el módulo `identity` y la BD local llega con el Plan
/// 0004. Hasta entonces se devuelve el día en cero, que es lo que la UI debe
/// mostrar de todas formas al abrir la app antes del primer movimiento.
@riverpod
class HomeSummaryController extends _$HomeSummaryController {
  @override
  Future<HomeSummary> build() async => const HomeSummary.empty();

  /// Vuelve a pedir el resumen (pull-to-refresh de Inicio).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => const HomeSummary.empty());
  }
}
