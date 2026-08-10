import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../../sync/data/sync_repository.dart';
import '../domain/supply_sale_pricing.dart';
import '../models/product.dart';
import 'inventory_local_datasource.dart';

part 'inventory_repository.g.dart';

/// Lo que se captura al vender insumos en el mostrador (plan 0006 §7.3).
class SupplySaleDraft {
  const SupplySaleDraft({
    required this.saleDate,
    required this.lines,
    this.method = PaymentMethod.cash,
    this.customerId,
    this.nit,
    this.reference,
  });

  /// `YYYY-MM-DD`.
  final String saleDate;

  final List<PricedSaleLine> lines;
  final PaymentMethod method;

  /// `null` = venta de mostrador, sin cliente.
  final String? customerId;

  final String? nit;
  final String? reference;
}

/// Lo que quedó guardado, para la confirmación.
class SavedSupplySale {
  const SavedSupplySale({required this.id, required this.total, required this.lineCount});

  final String id;

  /// La vista previa que calculó el dispositivo. El servidor la recalcula al
  /// aplicarla y el feed pisa la fila (D10), así que la confirmación dice
  /// "aproximado" cuando la venta todavía no subió.
  final int total;

  final int lineCount;
}

/// Insumos, contra la BD local siempre (plan 0004 D1).
class InventoryRepository {
  const InventoryRepository({
    required AppDatabase database,
    required InventoryLocalDataSource local,
    required SyncRepository sync,
    String Function() uuid = _defaultUuid,
    DateTime Function() clock = DateTime.now,
  }) : _database = database,
       _local = local,
       _sync = sync,
       _uuid = uuid,
       _clock = clock;

  final AppDatabase _database;
  final InventoryLocalDataSource _local;
  final SyncRepository _sync;
  final String Function() _uuid;
  final DateTime Function() _clock;

  static String _defaultUuid() => const Uuid().v4();

  Stream<List<ProductShelf>> watchShelf() => _local.watchShelf();

  Future<List<ProductShelf>> shelf() => _local.shelf();

  Stream<List<SupplySaleSummary>> watchSalesByDate(String date) =>
      _local.watchSalesByDate(date);

  /// Registra la venta. El id lo genera el dispositivo (D3): así reintentar el
  /// push no la cobra dos veces, y el ticket se puede dar antes de que el
  /// servidor conteste.
  Future<Either<AppFailure, SavedSupplySale>> createSale(
    SupplySaleDraft draft, {
    required String soldById,
  }) async {
    if (draft.lines.isEmpty) {
      return const Left(ValidationFailure('Agregá al menos un producto'));
    }
    if (draft.lines.any((line) => line.quantity <= 0)) {
      return const Left(ValidationFailure('Todas las líneas tienen que llevar cantidad'));
    }
    // El servidor reparte cada línea contra el stock de la base, así que el
    // mismo producto dos veces se rechaza allá. Se dice aquí, donde todavía se
    // puede juntar en una sola línea.
    final products = draft.lines.map((line) => line.productId).toSet();
    if (products.length != draft.lines.length) {
      return const Left(
        ValidationFailure('Un producto no puede ir en dos líneas: sumá la cantidad'),
      );
    }

    final saleId = _uuid();
    final lineIds = [for (final _ in draft.lines) _uuid()];
    final total = priceSale(draft.lines).total;
    final capturedAt = _clock();
    final nit = _clean(draft.nit);
    final reference = _clean(draft.reference);

    try {
      await _database.transaction(() async {
        await _local.insertSale(
          saleId: saleId,
          saleDate: draft.saleDate,
          lines: draft.lines,
          lineIds: lineIds,
          total: total,
          method: draft.method,
          soldById: soldById,
          capturedAt: capturedAt,
          customerId: draft.customerId,
          nit: nit,
          reference: reference,
        );
        await _sync.enqueue(
          entity: 'supply_sale',
          opType: 'create',
          entityId: saleId,
          payload: _payload(draft, nit: nit, reference: reference),
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    return Right(
      SavedSupplySale(id: saleId, total: total, lineCount: draft.lines.length),
    );
  }

  /// El cuerpo de `supply_sale/create`.
  ///
  /// Van productos y cantidades, **nunca lotes ni precios** (plan 0005 D5): lo
  /// que la pantalla mostró es una vista previa contra el inventario que este
  /// dispositivo alcanzó a bajar, y el servidor la vuelve a repartir contra el
  /// estante como está de verdad en el momento de aplicarla.
  static Map<String, dynamic> _payload(
    SupplySaleDraft draft, {
    String? nit,
    String? reference,
  }) {
    return <String, dynamic>{
      'sale_date': draft.saleDate,
      'customer_id': draft.customerId,
      'nit': nit,
      'method': draft.method.wire,
      'reference': reference,
      'lines': [
        for (final line in draft.lines)
          <String, dynamic>{
            'product_id': line.productId,
            'quantity': Fixed2.format(line.quantity),
          },
      ],
    };
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

@Riverpod(keepAlive: true)
InventoryRepository inventoryRepository(Ref ref) {
  return InventoryRepository(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(inventoryLocalDataSourceProvider),
    sync: ref.watch(syncRepositoryProvider),
  );
}
