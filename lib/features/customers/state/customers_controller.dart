import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/customers_repository.dart';
import '../models/customer.dart';

part 'customers_controller.g.dart';

/// Lo que hay escrito en el buscador de la lista de clientes.
///
/// Vive fuera de la pantalla para que volver de un detalle no borre lo que la
/// persona buscó: la rama del shell conserva la pantalla, pero el estado del
/// filtro es de la sesión de trabajo, no del widget.
@riverpod
class CustomerSearchQuery extends _$CustomerSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Tope de la lista. Una lavandería de barrio no llega a este número, pero el
/// día que llegue vale más cortar y decirlo que construir una lista infinita
/// que nadie va a recorrer hasta el final: para eso está el buscador.
const int customerListLimit = 200;

/// Clientes que coinciden con la búsqueda actual, en vivo desde la BD local.
@riverpod
Stream<List<Customer>> customerSearchResults(Ref ref) {
  final query = ref.watch(customerSearchQueryProvider);
  return ref
      .watch(customersRepositoryProvider)
      .watch(query: query, limit: customerListLimit);
}

/// Total de clientes activos, para la cabecera.
@riverpod
Stream<int> customerCount(Ref ref) {
  return ref.watch(customersRepositoryProvider).watchCount();
}

/// Un cliente concreto, en vivo. Emite `null` cuando se archiva.
@riverpod
Stream<Customer?> customerById(Ref ref, String id) {
  return ref.watch(customersRepositoryProvider).watchById(id);
}
