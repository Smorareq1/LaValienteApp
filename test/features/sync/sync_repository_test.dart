import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/errors/app_failure.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/sync/data/entity_mirror.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';
import 'package:la_valiente/features/sync/models/sync_operation.dart';
import 'package:la_valiente/features/sync/models/sync_progress.dart';

/// Servidor de mentira: guarda lo que recibe y devuelve lo que se le programe.
class _FakeServer implements SyncRemoteDataSource {
  /// Páginas que devolverá `pull`, en orden.
  List<SyncPullPage> pages = const [];

  final List<List<SyncOperation>> pushedBatches = [];
  final List<String> registeredDevices = [];

  /// Qué responder a cada operación empujada, por `op_id`.
  SyncOperationResult Function(SyncOperation) respond = _applied;

  Object? failNextPush;
  Object? failNextPull;
  String? pushDirective;

  /// Página que devolverá el próximo `pull`.
  int pullIndex = 0;

  static SyncOperationResult _applied(SyncOperation operation) {
    return SyncOperationResult(
      opId: operation.opId,
      outcome: SyncOperationOutcome.applied,
      entityId: operation.entityId,
      serverVersion: 1,
    );
  }

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String name,
    required String platform,
    required String appVersion,
  }) async {
    registeredDevices.add(deviceId);
  }

  @override
  Future<SyncPushResult> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    if (failNextPush != null) {
      final error = failNextPush;
      failNextPush = null;
      throw error!;
    }
    pushedBatches.add(operations);
    return SyncPushResult(
      results: operations.map(respond).toList(),
      serverTime: DateTime.now().toUtc(),
      deviceDirective: pushDirective,
    );
  }

  @override
  Future<SyncPullPage> pull({
    required String deviceId,
    required int cursor,
    int pageSize = kSyncPullPageSize,
  }) async {
    if (failNextPull != null) {
      final error = failNextPull;
      failNextPull = null;
      throw error!;
    }
    if (pullIndex >= pages.length) {
      return SyncPullPage(
        changes: const [],
        nextCursor: cursor,
        hasMore: false,
        serverTime: DateTime.now().toUtc(),
      );
    }
    return pages[pullIndex++];
  }
}

/// Almacenamiento seguro en memoria.
class _FakeStorage implements SecureStorageService {
  String key = 'llave-inicial';
  bool sessionCleared = false;

  @override
  Future<String> databaseKey() async => key;

  @override
  Future<String> rotateDatabaseKey() async => key = 'llave-${key.length + 1}';

  @override
  Future<void> clearSession() async => sessionCleared = true;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {}

  @override
  Future<bool> hasSession() async => false;
}

/// Espejo que apunta lo aplicado y puede fallar a mitad de página.
class _RecordingMirror implements SyncEntityMirror {
  _RecordingMirror({this.failOnId});

  final String? failOnId;
  final List<String> applied = [];
  final List<String> settled = [];
  final List<String> rejected = [];
  final List<String> discarded = [];

  @override
  String get entity => 'customer';

  @override
  Future<void> apply(SyncChange change) async {
    if (change.id == failOnId) throw StateError('espejo roto');
    applied.add(change.id);
  }

  @override
  Future<void> settle(String entityId, {required bool rejected}) async {
    settled.add(entityId);
    if (rejected) this.rejected.add(entityId);
  }

  @override
  Future<void> discard(String entityId) async => discarded.add(entityId);
}

SyncChange _change(String id, {int syncSeq = 1, String entity = 'customer'}) {
  return SyncChange(
    entity: entity,
    id: id,
    version: 1,
    syncSeq: syncSeq,
    deleted: false,
    data: {'full_name': 'Cliente $id'},
  );
}

SyncPullPage _page(List<SyncChange> changes, {required int nextCursor, bool hasMore = false}) {
  return SyncPullPage(
    changes: changes,
    nextCursor: nextCursor,
    hasMore: hasMore,
    serverTime: DateTime.now().toUtc(),
  );
}

void main() {
  late AppDatabase database;
  late SyncLocalDataSource local;
  late _FakeServer server;
  late _FakeStorage storage;

  var uuidCounter = 0;

  SyncRepository buildRepository({Map<String, SyncEntityMirror> mirrors = const {}}) {
    return SyncRepository(
      local: local,
      remote: server,
      storage: storage,
      mirrors: mirrors,
      device: const DeviceDescriptor(name: 'Tablet', platform: 'android', appVersion: '1.0.0'),
      uuid: () => 'op-${++uuidCounter}',
    );
  }

  Future<SyncProgress> runCycle(SyncRepository repository) async {
    return (await repository.runCycle().toList()).last;
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = SyncLocalDataSource(database);
    server = _FakeServer();
    storage = _FakeStorage();
    uuidCounter = 0;
  });

  tearDown(() => database.close());

  group('registro del dispositivo', () {
    test('el primer ciclo genera un id, lo registra y lo reutiliza', () async {
      final repository = buildRepository();

      await runCycle(repository);
      final deviceId = await repository.deviceId();

      expect(deviceId, isNotNull);
      expect(server.registeredDevices, [deviceId]);

      await runCycle(repository);
      expect(await repository.deviceId(), deviceId);
      // Registrarse es de una sola vez: el segundo ciclo ya no lo repite.
      expect(server.registeredDevices, hasLength(1));
    });
  });

  group('push', () {
    test('una operación aplicada sale del outbox', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );

      final last = await runCycle(repository);

      expect(last.phase, SyncPhase.done);
      expect(last.pushed, 1);
      expect(await repository.pendingCount(), 0);
    });

    test('un reintento tras caerse antes del ack no duplica nada', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );

      // Primer intento: el servidor la aplicó pero la respuesta se perdió.
      server.failNextPush = Exception('conexión cortada al recibir la respuesta');
      final failed = await runCycle(repository);
      expect(failed.phase, SyncPhase.failed);
      expect(await repository.pendingCount(), 1, reason: 'la op sigue esperando');

      // Segundo intento: el servidor reconoce el op_id y re-sirve el recibo.
      server.respond = (operation) => SyncOperationResult(
        opId: operation.opId,
        outcome: SyncOperationOutcome.alreadyApplied,
        entityId: operation.entityId,
        serverVersion: 1,
      );

      final retried = await runCycle(repository);
      expect(retried.phase, SyncPhase.done);
      expect(await repository.pendingCount(), 0);
      expect(server.pushedBatches, hasLength(1), reason: 'solo el reintento llegó a enviarse');
      expect(server.pushedBatches.single.single.opId, 'op-1');
    });

    test('la fila espejo deja de estar protegida cuando el servidor responde', () async {
      final mirror = _RecordingMirror();
      final repository = buildRepository(mirrors: {mirror.entity: mirror});
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );

      await runCycle(repository);

      // Sin este aviso la fila se quedaría `pending` para siempre y el pull
      // nunca podría corregirla: la regla que la protege no se apagaría nunca.
      expect(mirror.settled, ['c1']);
      expect(mirror.rejected, isEmpty);
    });

    test('un rechazo marca la fila espejo para revisión', () async {
      final mirror = _RecordingMirror();
      final repository = buildRepository(mirrors: {mirror.entity: mirror});
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );

      server.respond = (operation) => SyncOperationResult(
        opId: operation.opId,
        outcome: SyncOperationOutcome.rejected,
        entityId: operation.entityId,
        reason: 'Sin permiso customers.create',
      );

      await runCycle(repository);

      expect(mirror.rejected, ['c1']);
    });

    test('un rechazo va a la cola de revisión con su motivo', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: {'full_name': 'Ana'},
      );

      server.respond = (operation) => SyncOperationResult(
        opId: operation.opId,
        outcome: SyncOperationOutcome.rejected,
        entityId: operation.entityId,
        reason: 'Sin permiso customers.create',
        serverData: {'estado': 'sin cambios'},
      );

      await runCycle(repository);

      expect(await repository.pendingCount(), 0, reason: 'ya no se reintenta sola');
      expect(await repository.watchReviewCount().first, 1);

      final review = await database.select(database.reviewEntries).getSingle();
      expect(review.status, 'rejected');
      expect(review.reason, 'Sin permiso customers.create');
      expect(review.serverData, contains('sin cambios'));
    });

    test('un conflicto de versión también queda a revisión', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'update',
        entityId: 'c1',
        payload: {'full_name': 'Ana María'},
        baseVersion: 3,
      );

      server.respond = (operation) => SyncOperationResult(
        opId: operation.opId,
        outcome: SyncOperationOutcome.conflict,
        entityId: operation.entityId,
        serverVersion: 5,
        reason: 'Otro dispositivo modificó este cliente',
      );

      await runCycle(repository);

      final review = await database.select(database.reviewEntries).getSingle();
      expect(review.status, 'conflict');
      expect(review.serverVersion, 5);
      expect(await repository.watchReviewCount().first, 1);
    });

    test('un outbox grande se drena en lotes del tamaño máximo', () async {
      final repository = buildRepository();
      for (var i = 0; i < 500; i++) {
        await repository.enqueue(
          entity: 'customer',
          opType: 'create',
          entityId: 'c$i',
          payload: {'full_name': 'Cliente $i'},
        );
      }

      final last = await runCycle(repository);

      expect(last.pushed, 500);
      expect(server.pushedBatches.map((batch) => batch.length), [200, 200, 100]);
      // El servidor las aplica en el orden en que se capturaron.
      expect(server.pushedBatches.first.first.entityId, 'c0');
      expect(server.pushedBatches.last.last.entityId, 'c499');
    });

    test('un lote sin respuesta corta el ciclo en vez de reintentar en bucle', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: const {},
      );

      server.respond = (operation) => SyncOperationResult(
        opId: 'otro-op-id',
        outcome: SyncOperationOutcome.applied,
        entityId: operation.entityId,
      );

      final last = await runCycle(repository);

      expect(last.phase, SyncPhase.failed);
      expect(server.pushedBatches, hasLength(1));
      expect(await repository.pendingCount(), 1);

      final entry = await database.select(database.outboxEntries).getSingle();
      expect(entry.attempts, 1);
      expect(entry.lastError, isNotNull);
    });
  });

  group('pull', () {
    test('aplica las páginas en orden y guarda el cursor', () async {
      final mirror = _RecordingMirror();
      server.pages = [
        _page([_change('c1', syncSeq: 10), _change('c2', syncSeq: 20)],
            nextCursor: 20, hasMore: true),
        _page([_change('c3', syncSeq: 30)], nextCursor: 30),
      ];

      final repository = buildRepository(mirrors: {mirror.entity: mirror});
      final last = await runCycle(repository);

      expect(last.phase, SyncPhase.done);
      expect(last.pulled, 3);
      expect(mirror.applied, ['c1', 'c2', 'c3']);

      final state = await local.loadState();
      expect(state.pullCursor, 30);
      expect(state.bootstrapCompleted, isTrue);
    });

    test('un corte a media página no mueve el cursor y la página se re-aplica', () async {
      final roto = _RecordingMirror(failOnId: 'c2');
      server.pages = [
        _page([_change('c1', syncSeq: 10), _change('c2', syncSeq: 20)], nextCursor: 20),
      ];

      final failed = await runCycle(buildRepository(mirrors: {roto.entity: roto}));

      expect(failed.phase, SyncPhase.failed);
      expect(
        (await local.loadState()).pullCursor,
        0,
        reason: 'la transacción de la página se deshizo entera',
      );

      // Al reintentar con el espejo sano, la página vuelve completa.
      final sano = _RecordingMirror();
      server
        ..pullIndex = 0
        ..pages = [
          _page([_change('c1', syncSeq: 10), _change('c2', syncSeq: 20)], nextCursor: 20),
        ];

      final retried = await runCycle(buildRepository(mirrors: {sano.entity: sano}));

      expect(retried.phase, SyncPhase.done);
      expect(sano.applied, ['c1', 'c2']);
      expect((await local.loadState()).pullCursor, 20);
    });

    test('los cambios sin espejo se guardan en vez de perderse', () async {
      server.pages = [
        _page([
          _change('s1', syncSeq: 10, entity: 'service_type'),
          _change('c1', syncSeq: 20),
        ], nextCursor: 20),
      ];

      final mirror = _RecordingMirror();
      await runCycle(buildRepository(mirrors: {mirror.entity: mirror}));

      expect(mirror.applied, ['c1']);
      expect(await local.deferredCount(), 1);

      final deferred = await local.deferredChanges(entity: 'service_type');
      expect(deferred.single.id, 's1');
      expect(deferred.single.data['full_name'], 'Cliente s1');
      expect((await local.loadState()).pullCursor, 20, reason: 'el feed sigue avanzando');
    });

    test('al registrarse su espejo, lo aparcado entra en el siguiente ciclo', () async {
      // Primer ciclo sin espejo para `service_type`: sus cambios se aparcan.
      server.pages = [
        _page([_change('s1', syncSeq: 10, entity: 'service_type')], nextCursor: 10),
      ];
      await runCycle(buildRepository());
      expect(await local.deferredCount(), 1);

      // El PR que registra el espejo no rebobina el cursor ni le pide nada
      // extra al servidor: lo aparcado ya estaba en el dispositivo.
      final espejo = _RecordingMirror();
      server.pages = [_page(const [], nextCursor: 10)];
      server.pullIndex = 0;
      await runCycle(buildRepository(mirrors: {'service_type': espejo}));

      expect(espejo.applied, ['s1']);
      expect(await local.deferredCount(), 0);
    });

    test('lo aparcado de una entidad que sigue sin espejo se queda esperando', () async {
      server.pages = [
        _page([_change('o1', syncSeq: 10, entity: 'order')], nextCursor: 10),
      ];
      await runCycle(buildRepository());

      final espejo = _RecordingMirror();
      server.pages = [_page(const [], nextCursor: 10)];
      server.pullIndex = 0;
      await runCycle(buildRepository(mirrors: {espejo.entity: espejo}));

      expect(espejo.applied, isEmpty);
      expect(await local.deferredCount(), 1, reason: 'los pedidos llegan con el PR S4');
    });

    test('un cursor que no avanza corta el ciclo en vez de pedir lo mismo sin fin', () async {
      server.pages = [
        _page(const [], nextCursor: 0, hasMore: true),
        _page(const [], nextCursor: 0, hasMore: true),
      ];

      final last = await runCycle(buildRepository());

      expect(last.phase, SyncPhase.done);
      expect(server.pullIndex, 1, reason: 'no volvió a pedir la misma página');
    });
  });

  group('revocación', () {
    test('la orden de wipe borra lo local, rota la llave y cierra la sesión', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: const {},
      );
      server.pushDirective = 'wipe';

      final last = await runCycle(repository);

      expect(last.phase, SyncPhase.wiped);
      expect(await repository.pendingCount(), 0);
      expect(storage.sessionCleared, isTrue);
      expect(storage.key, isNot('llave-inicial'));
    });
  });

  group('fallos de red', () {
    test('sin conexión el ciclo falla pero el outbox queda intacto', () async {
      final repository = buildRepository();
      await repository.enqueue(
        entity: 'customer',
        opType: 'create',
        entityId: 'c1',
        payload: const {},
      );
      server.failNextPush = Exception('sin red');

      final last = await runCycle(repository);

      expect(last.phase, SyncPhase.failed);
      expect(last.failure, isA<AppFailure>());
      expect(await repository.pendingCount(), 1);
      expect((await local.loadState()).lastError, isNotNull);
    });
  });

  group('reloj', () {
    test('se registra el desfase contra la hora del servidor', () async {
      final serverTime = DateTime.utc(2026, 7, 31, 12);
      server.pages = [
        SyncPullPage(
          changes: const [],
          nextCursor: 5,
          hasMore: false,
          serverTime: serverTime,
        ),
      ];

      final repository = SyncRepository(
        local: local,
        remote: server,
        storage: storage,
        mirrors: const {},
        device: const DeviceDescriptor(name: 'Tablet', platform: 'android', appVersion: '1.0.0'),
        clock: () => serverTime.add(const Duration(minutes: 9)),
        uuid: () => 'op-${++uuidCounter}',
      );

      await runCycle(repository);

      expect((await local.loadState()).clockSkewSeconds, const Duration(minutes: 9).inSeconds);
    });
  });

  group('cola local', () {
    test('encolar asigna seq crecientes y op_id únicos', () async {
      final repository = buildRepository();
      await repository.enqueue(entity: 'customer', opType: 'create', entityId: 'a', payload: const {});
      await repository.enqueue(entity: 'customer', opType: 'create', entityId: 'b', payload: const {});

      final pending = await local.pendingOperations(limit: 10);
      expect(pending.map((operation) => operation.entityId), ['a', 'b']);
      expect(pending.map((operation) => operation.seq), [1, 2]);
      expect(pending.map((operation) => operation.opId).toSet(), hasLength(2));
    });

    test('el conteo pendiente se emite en vivo', () async {
      final repository = buildRepository();
      expect(await repository.watchPendingCount().first, 0);

      await repository.enqueue(entity: 'customer', opType: 'create', entityId: 'a', payload: const {});
      expect(await repository.watchPendingCount().first, 1);
    });
  });
}
