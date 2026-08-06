import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../models/promotion.dart';

part 'promotions_repository.g.dart';

/// Las promociones cacheadas del dispositivo.
///
/// Solo lee, como el catálogo: son pull-only y administrarlas es en línea
/// (§10.3). Que aquí no haya `create` ni `update` es la regla del plan hecha
/// código.
class PromotionsRepository {
  const PromotionsRepository(this._database);

  final AppDatabase _database;

  /// Todas las que bajaron, **vigentes o no**.
  ///
  /// Las vencidas también hacen falta: un pedido de la semana pasada se captura
  /// con lo que regía ese día, y sin ellas la pantalla diría "no existe" de una
  /// promoción que sí corrió (plan 0004 §8).
  Future<List<Promotion>> all() async =>
      (await _query().get()).map(Promotion.fromRow).toList();

  Stream<List<Promotion>> watchAll() =>
      _query().watch().map((rows) => rows.map(Promotion.fromRow).toList());

  SimpleSelectStatement<$PromotionEntriesTable, PromotionEntry> _query() {
    return _database.select(_database.promotionEntries)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
  }
}

@Riverpod(keepAlive: true)
PromotionsRepository promotionsRepository(Ref ref) {
  return PromotionsRepository(ref.watch(appDatabaseProvider));
}
