import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../catalog/data/catalog_mirrors.dart';
import '../../customers/data/customer_mirror.dart';
import '../../orders/data/order_mirrors.dart';
import 'entity_mirror.dart';

part 'sync_mirrors.g.dart';

/// Espejos registrados, por nombre de entidad en el feed.
///
/// Sumar un módulo al espejo local es agregar una línea aquí; el motor no se
/// toca. Lo que llegue de una entidad ausente de este mapa se guarda en
/// `deferred_changes` y se aplica sola cuando su espejo aparezca.
///
/// Vive aparte del contrato ([SyncEntityMirror]) a propósito: si el registro
/// estuviera en el mismo archivo, cada módulo importaría el registro de todos
/// los demás para poder implementar la interfaz.
@Riverpod(keepAlive: true)
Map<String, SyncEntityMirror> syncMirrors(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final mirrors = <SyncEntityMirror>[
    ...catalogMirrors(database),
    CustomerMirror(database),
    ...orderMirrors(database),
  ];
  return {for (final mirror in mirrors) mirror.entity: mirror};
}
