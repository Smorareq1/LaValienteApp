// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accessRolesHash() => r'51f40cbffcffea3cf6b78883cb8e330b1b0c01a0';

/// El catálogo de roles que se pueden repartir. Vacío si el servidor niega
/// `authorization.roles.manage`, y la pantalla lo explica.
///
/// Copied from [accessRoles].
@ProviderFor(accessRoles)
final accessRolesProvider =
    AutoDisposeFutureProvider<List<AccessRole>>.internal(
      accessRoles,
      name: r'accessRolesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$accessRolesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccessRolesRef = AutoDisposeFutureProviderRef<List<AccessRole>>;
String _$usersAdminControllerHash() =>
    r'458bf4b3eb12f4d90d38021272f8bfa92f352c76';

/// Las cuentas de la pantalla de usuarios (§12).
///
/// Copied from [UsersAdminController].
@ProviderFor(UsersAdminController)
final usersAdminControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      UsersAdminController,
      List<SystemUser>
    >.internal(
      UsersAdminController.new,
      name: r'usersAdminControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$usersAdminControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UsersAdminController = AutoDisposeAsyncNotifier<List<SystemUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
