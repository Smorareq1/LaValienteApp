import '../models/sync_change.dart';

/// Contrato que implementa cada módulo para espejar su entidad del feed.
///
/// El motor no sabe qué es un cliente ni un pedido: solo sabe entregar cambios
/// ordenados a quien los reclame. Sumar un módulo al espejo local es registrar
/// un espejo, no tocar el motor.
abstract class SyncEntityMirror {
  /// Nombre de la entidad tal como viaja en el feed (`customer`, `order`…).
  String get entity;

  /// Aplica el cambio a la tabla espejo.
  ///
  /// Corre dentro de la transacción de la página, así que debe limitarse a
  /// escribir. Dos reglas que cada implementación tiene que respetar:
  ///
  /// - `change.deleted` es un tombstone: se marca la fila, no se borra (D8).
  /// - una fila con cambios locales sin confirmar **no se pisa** (§7.2); se
  ///   resolverá cuando su operación se confirme o caiga a revisión.
  Future<void> apply(SyncChange change);

  /// El servidor resolvió la operación que protegía a esta fila.
  ///
  /// Sin esto una fila quedaría `pending` para siempre: el pull la respeta por
  /// la regla de arriba, y nada más la sacaría de ese estado. [rejected] marca
  /// las que cayeron a la cola de revisión.
  Future<void> settle(String entityId, {required bool rejected});
}
