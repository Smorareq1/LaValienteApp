import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../sync/data/table_mirror.dart';
import '../../sync/models/sync_change.dart';

/// Espejo de promociones. Pull-only, como el catálogo: el feed las trae y aquí
/// no se origina ninguna operación — administrarlas es en línea (§10.3).
class PromotionMirror extends TableMirror<PromotionEntry> {
  const PromotionMirror(super.database);

  @override
  String get entity => 'promotion';

  @override
  TableInfo<Table, PromotionEntry> get table => database.promotionEntries;

  @override
  PromotionEntriesCompanion toCompanion(SyncChange change) {
    final data = change.data;
    final codes = data['applies_to_service_codes'];
    return PromotionEntriesCompanion(
      code: Value(data['code'] as String),
      name: Value(data['name'] as String),
      description: Value(data['description'] as String?),
      discountType: Value(data['discount_type'] as String),
      // Llega como string y se guarda como string, igual que los precios: el
      // `50` de un porcentaje y el `35.00` de un precio especial son el mismo
      // tipo de dato y ninguno sobrevive intacto a un double.
      value: Value(data['value'] as String),
      // La lista se vuelve a serializar tal cual en vez de guardarse aparte:
      // son tres o cuatro códigos por promoción y el motor los lee de un tirón.
      appliesToServiceCodes: Value(codes == null ? null : jsonEncode(codes)),
      validFrom: Value(data['valid_from'] as String),
      validTo: Value(data['valid_to'] as String?),
      isActive: Value(data['is_active'] as bool),
    );
  }
}
