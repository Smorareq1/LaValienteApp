import 'package:drift/drift.dart';

import 'synced_columns.dart';

/// Espejo de promociones (plan 0004 §7.3: servidor → app, sin ops locales).
///
/// Pull-only como el catálogo, y por la misma razón: quién decide que hay 50%
/// en domicilio es la dueña, no el mostrador. Lo que el mostrador necesita es
/// que la lista esté en el dispositivo antes de que se caiga la señal, para
/// poder ofrecer el descuento igual.
@DataClassName('PromotionEntry')
class PromotionEntries extends Table with SyncedColumns {
  /// El código que viaja en el pedido. La app manda **esto** y nunca el monto
  /// (D5): cuánto rebaja lo resuelve el servidor al aplicar la operación.
  TextColumn get code => text().withLength(max: 50)();

  TextColumn get name => text().withLength(max: 120)();
  TextColumn get description => text().nullable()();

  /// `percentage`, `fixed_amount` o `special_price` (plan 0001 §5.4). String y
  /// no enum local, igual que el modo de cobro del catálogo: un tipo nuevo de
  /// descuento no puede obligar a migrar la BD del teléfono.
  TextColumn get discountType => text().withLength(max: 20)();

  /// Texto por la razón de siempre: `50` es un porcentaje y `35.00` un precio,
  /// y ninguno de los dos sobrevive intacto a un `double`.
  TextColumn get value => text().withLength(max: 20)();

  /// Lista JSON de códigos de servicio, o `null` = aplica a todo el pedido.
  /// Se guarda como llegó y se decodifica al leer: una tabla puente para tres
  /// promociones sería una junta más en cada cálculo del footer.
  TextColumn get appliesToServiceCodes => text().nullable()();

  /// Fechas de negocio en `YYYY-MM-DD`, sin hora ni zona.
  TextColumn get validFrom => text().withLength(max: 10)();
  TextColumn get validTo => text().withLength(max: 10).nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
