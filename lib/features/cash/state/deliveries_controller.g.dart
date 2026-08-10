// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliveries_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$openOrdersHash() => r'08bf0e7e50cb0ce64b38a17bec4f48d97d32dbac';

/// Las boletas que la lavandería todavía no devolvió (plan 0006 §7.1.1).
///
/// Va sin fecha aposta: la de Caja dice de qué día es el dinero, no cuáles
/// boletas están abiertas. Una que entró el lunes se entrega el miércoles, y
/// filtrarla por el día escondería justo la que lleva más tiempo esperando.
///
/// Copied from [openOrders].
@ProviderFor(openOrders)
final openOrdersProvider =
    AutoDisposeStreamProvider<List<OrderListItem>>.internal(
      openOrders,
      name: r'openOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenOrdersRef = AutoDisposeStreamProviderRef<List<OrderListItem>>;
String _$deliverableOrdersHash() => r'47dec36de71e3be4e999104778753d7c2ec4fb27';

/// Las boletas abiertas que casan con lo escrito.
///
/// El número de boleta es lo primero que se busca porque es lo que la persona
/// tiene en la mano; el nombre del cliente entra por si la boleta se perdió.
///
/// Copied from [deliverableOrders].
@ProviderFor(deliverableOrders)
final deliverableOrdersProvider =
    AutoDisposeProvider<List<OrderListItem>>.internal(
      deliverableOrders,
      name: r'deliverableOrdersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliverableOrdersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliverableOrdersRef = AutoDisposeProviderRef<List<OrderListItem>>;
String _$deliveryBatchHash() => r'9ddfe0f0ee712d4b4588884fbec9651daf8ec37a';

/// Lo marcado, en el orden en que aparece la lista y ya sumado.
///
/// Copied from [deliveryBatch].
@ProviderFor(deliveryBatch)
final deliveryBatchProvider = AutoDisposeProvider<DeliveryBatch>.internal(
  deliveryBatch,
  name: r'deliveryBatchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deliveryBatchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliveryBatchRef = AutoDisposeProviderRef<DeliveryBatch>;
String _$deliverySearchQueryHash() =>
    r'd437ded4b7f435bbec2b1222433eaa1855aa8183';

/// Lo que se escribió en el buscador de entregas.
///
/// Copied from [DeliverySearchQuery].
@ProviderFor(DeliverySearchQuery)
final deliverySearchQueryProvider =
    AutoDisposeNotifierProvider<DeliverySearchQuery, String>.internal(
      DeliverySearchQuery.new,
      name: r'deliverySearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliverySearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeliverySearchQuery = AutoDisposeNotifier<String>;
String _$deliverySelectionHash() => r'9a403bcbb1c43bc6ade0c3655fd7577d3e6032cb';

/// Las boletas marcadas para entregar, por id de pedido.
///
/// El repaso del final del día es de varias boletas a la vez —"de las que
/// tenía, entregué estas"— así que la selección vive fuera de la pantalla y
/// sobrevive a que alguien busque otra cosa en el medio.
///
/// Copied from [DeliverySelection].
@ProviderFor(DeliverySelection)
final deliverySelectionProvider =
    AutoDisposeNotifierProvider<
      DeliverySelection,
      Map<String, DeliveryLine>
    >.internal(
      DeliverySelection.new,
      name: r'deliverySelectionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliverySelectionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeliverySelection = AutoDisposeNotifier<Map<String, DeliveryLine>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
