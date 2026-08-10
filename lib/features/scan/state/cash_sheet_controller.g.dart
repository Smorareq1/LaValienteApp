// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_sheet_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cashSheetControllerHash() =>
    r'ef781499ce33508a3d96bcfb7424d4eceae6fc4f';

/// El escaneo de la hoja «Registro Diario» (plan 0005 §1).
///
/// La diferencia de fondo con [ScanController] está en la última línea de este
/// archivo: aquel entrega un borrador y se acabó, y este **aplica**. De ahí que
/// todo lo de arriba exista — las filas editables, lo que está marcado, el total
/// que se va a cobrar — porque entre leer y cobrar tiene que haber una persona
/// mirando, y esto es lo que esa persona está mirando.
///
/// Qué llega marcado por omisión, que es la decisión con más consecuencias:
///
/// * los cobros, **solo** los que el servidor emparejó con una boleta que debe
///   justo lo que dice el papel. Un desajuste de monto, una boleta que no
///   aparece o una que ya está cobrada llegan desmarcadas: son las que hay que
///   mirar, y marcarlas sería esconderlas.
/// * los gastos, solo los que tienen categoría y monto. Sin categoría no se
///   puede archivar y la elige una persona.
/// * las horas, solo cuando el empleado se identificó sin ambigüedad.
///
/// Copied from [CashSheetController].
@ProviderFor(CashSheetController)
final cashSheetControllerProvider =
    AutoDisposeNotifierProvider<CashSheetController, CashSheetState>.internal(
      CashSheetController.new,
      name: r'cashSheetControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashSheetControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CashSheetController = AutoDisposeNotifier<CashSheetState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
