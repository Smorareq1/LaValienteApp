// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeDateHash() => r'baba80fb29bb4bbc1c1f245552a8a8a342539a62';

/// El día del que habla Inicio: el de negocio, siempre hoy.
///
/// Tiene provider propio para no leer `businessDate()` en tres sitios del
/// resumen y que dos de ellos pudieran caer a lados distintos de la medianoche.
///
/// Copied from [homeDate].
@ProviderFor(homeDate)
final homeDateProvider = AutoDisposeProvider<String>.internal(
  homeDate,
  name: r'homeDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeDateRef = AutoDisposeProviderRef<String>;
String _$homeSummaryHash() => r'bd833e1159b0eb18d003c538afa4441f6f6af910';

/// El resumen del día que consume la pantalla Inicio (Plan 0006 §4.1).
///
/// Se arma **contra la BD local** y no contra `GET /daily-close/preview`: el
/// plan da esa ruta como fuente y el cálculo local como respaldo sin señal, pero
/// aquí el respaldo es lo único que hace falta. Inicio se abre al llegar en la
/// mañana, muchas veces antes de que el primer pull termine, y las cifras que
/// pediría al servidor son exactamente las que la Caja ya suma de las mismas
/// tablas espejo. Pedirlas de nuevo por red solo agregaría una pantalla que se
/// queda en cero cuando no hay señal, que es justo lo que esto viene a arreglar.
///
/// La cifra oficial sigue siendo la del servidor y se ve donde importa: en el
/// acta del cierre (§7.4), que sí es online-only.
///
/// Copied from [homeSummary].
@ProviderFor(homeSummary)
final homeSummaryProvider = AutoDisposeProvider<HomeSummary>.internal(
  homeSummary,
  name: r'homeSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeSummaryRef = AutoDisposeProviderRef<HomeSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
