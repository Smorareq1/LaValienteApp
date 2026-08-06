import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/customers/data/customer_mirror.dart';
import 'package:la_valiente/features/sync/data/entity_mirror.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/review_item.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';
import 'package:la_valiente/features/sync/models/sync_operation.dart';

/// Servidor que rechaza todo lo que le llega, con el motivo que se le pida.
class _RefusingServer implements SyncRemoteDataSource {
  _RefusingServer({this.outcome = SyncOperationOutcome.rejected, this.reason});

  final SyncOperationOutcome outcome;
  final String? reason;

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String name,
    required String platform,
    required String appVersion,
  }) async {}

  @override
  Future<SyncPushResult> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    return SyncPushResult(
      results: [
        for (final operation in operations)
          SyncOperationResult(
            opId: operation.opId,
            outcome: outcome,
            entityId: operation.entityId,
            reason: reason,
          ),
      ],
      serverTime: DateTime.now().toUtc(),
    );
  }

  @override
  Future<SyncPullPage> pull({
    required String deviceId,
    required int cursor,
    int pageSize = kSyncPullPageSize,
  }) async {
    return SyncPullPage(
      changes: const [],
      nextCursor: cursor,
      hasMore: false,
      serverTime: DateTime.now().toUtc(),
    );
  }
}

class _FakeStorage implements SecureStorageService {
  @override
  Future<String> databaseKey() async => 'llave';

  @override
  Future<String> rotateDatabaseKey() async => 'llave-2';

  @override
  Future<void> clearSession() async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<bool> hasSession() async => false;
}

void main() {
  late AppDatabase database;
  late SyncLocalDataSource local;
  late Map<String, SyncEntityMirror> mirrors;

  var uuidCounter = 0;

  SyncRepository buildRepository({
    SyncOperationOutcome outcome = SyncOperationOutcome.rejected,
    String? reason,
  }) {
    return SyncRepository(
      local: local,
      remote: _RefusingServer(outcome: outcome, reason: reason),
      storage: _FakeStorage(),
      mirrors: mirrors,
      device: const DeviceDescriptor(
        name: 'Tablet',
        platform: 'android',
        appVersion: '1.0.0',
      ),
      uuid: () => 'op-${++uuidCounter}',
    );
  }

  /// Deja un cliente capturado local, igual que lo dejaría la pantalla.
  Future<void> captureCustomer(String id, {String name = 'Ana'}) {
    return database
        .into(database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(
            id: id,
            fullName: name,
            searchIndex: Value(name.toLowerCase()),
            syncStatus: Value(RowSyncStatus.pending.name),
          ),
        );
  }

  Future<int> visibleCustomers() async {
    final rows = await (database.select(
      database.customerEntries,
    )..where((row) => row.deletedAt.isNull())).get();
    return rows.length;
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = SyncLocalDataSource(database);
    mirrors = {'customer': CustomerMirror(database)};
    uuidCounter = 0;
  });

  tearDown(() => database.close());

  test('lo que el servidor rechaza queda en la cola con lo que se capturó', () async {
    final repository = buildRepository(reason: 'A customer with that id already exists.');
    await captureCustomer('c1');
    await repository.enqueue(
      entity: 'customer',
      opType: 'create',
      entityId: 'c1',
      payload: {'full_name': 'Ana', 'phone': '5555-1111'},
    );

    await repository.runCycle().toList();

    final queue = await repository.watchReviewItems().first;
    expect(queue, hasLength(1));

    final item = queue.single;
    expect(item.kind, ReviewKind.customerCreate);
    expect(item.outcome, ReviewOutcome.rejected);
    expect(item.reason, 'A customer with that id already exists.');
    expect(item.localPayload['phone'], '5555-1111');
    // Sale del outbox: reintentarla sola devolvería el mismo rechazo guardado.
    expect(await repository.pendingCount(), 0);
  });

  test('un choque de versión se distingue de un rechazo', () async {
    final repository = buildRepository(
      outcome: SyncOperationOutcome.conflict,
      reason: 'The customer changed since version 3 (current version is 5).',
    );
    await captureCustomer('c1');
    await repository.enqueue(
      entity: 'customer',
      opType: 'update',
      entityId: 'c1',
      baseVersion: 3,
      payload: {'full_name': 'Ana María'},
    );

    await repository.runCycle().toList();

    final item = (await repository.watchReviewItems().first).single;
    expect(item.outcome, ReviewOutcome.conflict);
    expect(item.kind, ReviewKind.customerUpdate);
  });

  group('descartar', () {
    test('un alta descartada se retira también del dispositivo', () async {
      final repository = buildRepository();
      await captureCustomer('c1');
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );
      await repository.runCycle().toList();
      expect(await visibleCustomers(), 1);

      await repository.discardReview((await repository.watchReviewItems().first).single);

      // El servidor nunca tuvo este cliente: si la fila se quedara, sería un
      // fantasma que ningún feed puede corregir.
      expect(await visibleCustomers(), 0);
      expect(await repository.watchReviewItems().first, isEmpty);
      expect(await repository.watchReviewCount().first, 0);
    });

    test('descartar un cambio deja la fila que tiene el servidor', () async {
      final repository = buildRepository();
      await captureCustomer('c1');
      await repository.enqueue(
        entity: 'customer',
        opType: 'update',
        entityId: 'c1',
        baseVersion: 2,
        payload: {'full_name': 'Ana María'},
      );
      await repository.runCycle().toList();

      await repository.discardReview((await repository.watchReviewItems().first).single);

      // Lo que se descarta es el cambio, no el cliente: del otro lado sigue
      // existiendo y el feed manda.
      expect(await visibleCustomers(), 1);
      expect(await repository.watchReviewItems().first, isEmpty);
    });
  });

  group('reintentar', () {
    test('vuelve al outbox con un op_id nuevo y cierra la entrada', () async {
      final repository = buildRepository();
      await captureCustomer('c1');
      await repository.enqueue(
        entity: 'customer',
        opType: 'update',
        entityId: 'c1',
        baseVersion: 2,
        payload: {'full_name': 'Ana María'},
      );
      await repository.runCycle().toList();

      final item = (await repository.watchReviewItems().first).single;
      final newOpId = await repository.retryReview(item, baseVersion: 5);

      expect(newOpId, isNot(item.opId), reason: 'el viejo ya tiene recibo en el servidor');
      expect(await repository.watchReviewItems().first, isEmpty);

      final pending = await local.pendingOperations(limit: 10);
      expect(pending, hasLength(1));
      expect(pending.single.opId, newOpId);
      expect(pending.single.payload['full_name'], 'Ana María');
      // La versión que iba en la operación original es justo la que el servidor
      // declaró vieja; repetirla repetiría el choque.
      expect(pending.single.baseVersion, 5);
    });

    test('la fila local no se retira al reintentar', () async {
      final repository = buildRepository();
      await captureCustomer('c1');
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );
      await repository.runCycle().toList();

      await repository.retryReview((await repository.watchReviewItems().first).single);

      expect(await visibleCustomers(), 1);
    });
  });

  test('los pendientes se cuentan por tipo', () async {
    final repository = buildRepository();
    await repository.enqueue(
      entity: 'order',
      opType: 'create',
      entityId: 'o1',
      payload: const {},
    );
    await repository.enqueue(
      entity: 'order',
      opType: 'status',
      entityId: 'o1',
      payload: const {},
    );
    await repository.enqueue(
      entity: 'order_payment',
      opType: 'create',
      entityId: 'p1',
      payload: const {},
    );

    expect(await repository.watchPendingByEntity().first, {
      'order': 2,
      'order_payment': 1,
    });
  });
}
