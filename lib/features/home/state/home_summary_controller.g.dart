// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeSummaryControllerHash() =>
    r'3072ec1be79298114137c396d4cdd573958336de';

/// Resumen del día que consume la pantalla Inicio.
///
/// La fuente real es `GET /daily-close/preview` más la BD local para los
/// contadores de pedidos (Plan 0006 §4.1), y ninguna de las dos existe todavía:
/// el backend solo tiene el módulo `identity` y la BD local llega con el Plan
/// 0004. Hasta entonces se devuelve el día en cero, que es lo que la UI debe
/// mostrar de todas formas al abrir la app antes del primer movimiento.
///
/// Copied from [HomeSummaryController].
@ProviderFor(HomeSummaryController)
final homeSummaryControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      HomeSummaryController,
      HomeSummary
    >.internal(
      HomeSummaryController.new,
      name: r'homeSummaryControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeSummaryControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeSummaryController = AutoDisposeAsyncNotifier<HomeSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
