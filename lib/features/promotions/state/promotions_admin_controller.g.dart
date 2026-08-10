// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotions_admin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$promotionsAdminControllerHash() =>
    r'46d5b848331c17df46afab2a07cfe87870fff298';

/// La lista de promociones de la pantalla de administración (§10.3).
///
/// Va contra la API y no contra la BD local a propósito: aquí se **escribe**, y
/// una promoción editada tiene que verse tal como quedó en el servidor. Lo que
/// baja al espejo por el feed es para ofrecerla en la toma, no para editarla.
///
/// Copied from [PromotionsAdminController].
@ProviderFor(PromotionsAdminController)
final promotionsAdminControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      PromotionsAdminController,
      List<Promotion>
    >.internal(
      PromotionsAdminController.new,
      name: r'promotionsAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$promotionsAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PromotionsAdminController = AutoDisposeAsyncNotifier<List<Promotion>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
