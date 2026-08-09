// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_lookup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ticketLookupControllerHash() =>
    r'f7fe16a560cd0d8769bca054d934f536335a92cb';

/// Escanear una boleta para entregarla.
///
/// Es el acelerador del buscador, no otro camino (plan 0006 §7.1.1): termina
/// exactamente donde termina teclear el número —con la boleta marcada en la
/// lista— y cuando no puede, deja lo que leyó escrito en el buscador para que
/// la persona siga a mano. El camino manual nunca depende de esto (plan 0003
/// D8).
///
/// Copied from [TicketLookupController].
@ProviderFor(TicketLookupController)
final ticketLookupControllerProvider =
    AutoDisposeNotifierProvider<TicketLookupController, bool>.internal(
      TicketLookupController.new,
      name: r'ticketLookupControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ticketLookupControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TicketLookupController = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
