import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/network/connectivity.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';
import 'package:la_valiente/features/sync/models/sync_operation.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';

/// Servidor que apunta cada push y puede negarse a responder el pull.
class _CountingServer implements SyncRemoteDataSource {
  final List<List<SyncOperation>> pushedBatches = [];

  /// Mientras esté puesto, todo pull falla: es el corte de red del mostrador.
  Object? pullFailure;

  /// Prueba de que el motor llegó a arrancar: es lo primero que hace un ciclo.
  bool registered = false;

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String name,
    required String platform,
    required String appVersion,
  }) async {
    registered = true;
  }

  @override
  Future<SyncPushResult> push({
    required String deviceId,
    required List<SyncOperation> operations,
  }) async {
    pushedBatches.add(operations);
    return SyncPushResult(
      results: [
        for (final operation in operations)
          SyncOperationResult(
            opId: operation.opId,
            outcome: SyncOperationOutcome.applied,
            entityId: operation.entityId,
            serverVersion: 1,
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
    if (pullFailure != null) throw pullFailure!;
    return SyncPullPage(
      changes: const [],
      nextCursor: cursor,
      hasMore: false,
      serverTime: DateTime.now().toUtc(),
    );
  }
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAuthController extends AuthController {
  @override
  Future<AuthUser?> build() async => const AuthUser(
    id: 'u1',
    username: 'mostrador',
    fullName: 'Marta González',
    roles: ['admin'],
    permissions: [],
  );
}

void main() {
  late AppDatabase database;
  late SyncLocalDataSource local;
  late SyncRepository repository;
  late _CountingServer server;
  late ProviderContainer container;

  var uuidCounter = 0;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    database = AppDatabase(NativeDatabase.memory());
    local = SyncLocalDataSource(database);
    server = _CountingServer();
    uuidCounter = 0;

    repository = SyncRepository(
      local: local,
      remote: server,
      storage: _UnusedStorage(),
      mirrors: const {},
      device: const DeviceDescriptor(
        name: 'Tablet',
        platform: 'android',
        appVersion: '1.0.0',
      ),
      uuid: () => 'op-${++uuidCounter}',
    );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        syncRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_FakeAuthController.new),
        // Sin canal de plataforma: la conectividad es otro disparador y aquí
        // estorbaría al que se está midiendo.
        connectivityChangesProvider.overrideWith((ref) => const Stream<bool>.empty()),
      ],
    );
  });

  /// Arranca el motor y deja que termine su ciclo de arranque.
  ///
  /// La sesión resuelve en un microtask, así que el motor se construye dos
  /// veces: la primera sin usuario —y ahí no enciende nada— y la segunda ya con
  /// él. El `listen` es lo que hace que la segunda ocurra.
  Future<void> boot(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.listen(syncEngineProvider, (_, _) {});
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(server.registered, isTrue, reason: 'el motor no llegó a arrancar');
  }

  /// Desmonta el motor antes de cerrar la BD: si no, el periódico de dos
  /// minutos queda vivo y la prueba termina con un `Timer` pendiente.
  void engineTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      container.dispose();
      await tester.pump(const Duration(milliseconds: 50));
      await database.close();
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  Future<void> capture(String entityId) {
    return repository.enqueue(
      entity: 'customer',
      opType: 'create',
      entityId: entityId,
      payload: const {'full_name': 'Ana Pérez'},
    );
  }

  group('el disparador de mutación local', () {
    engineTest('sube la captura sin esperar el periódico de dos minutos', (
      tester,
    ) async {
      await boot(tester);
      expect(server.pushedBatches, isEmpty, reason: 'el arranque no tenía nada que subir');

      await capture('cliente-1');
      await tester.pump();
      // Todavía no: la ráfaga se agrupa antes de salir.
      expect(server.pushedBatches, isEmpty);

      await tester.pump(kSyncMutationDebounce);
      await tester.pump();

      expect(server.pushedBatches, hasLength(1));
      expect(server.pushedBatches.single.single.entityId, 'cliente-1');
    });

    engineTest('agrupa una ráfaga de capturas en un solo ciclo', (tester) async {
      await boot(tester);

      await capture('cliente-1');
      await tester.pump(const Duration(seconds: 1));
      await capture('cliente-2');
      await tester.pump(const Duration(seconds: 1));
      await capture('cliente-3');

      await tester.pump(kSyncMutationDebounce);
      await tester.pump();

      expect(server.pushedBatches, hasLength(1));
      expect(server.pushedBatches.single, hasLength(3));
    });

    engineTest('vaciar el outbox no pide otro ciclo', (tester) async {
      await boot(tester);

      await capture('cliente-1');
      await tester.pump(kSyncMutationDebounce);
      await tester.pump();
      expect(server.pushedBatches, hasLength(1));

      // El push acaba de sacar la operación de la cola: la cuenta baja de 1 a 0
      // y eso no es una captura. Sin la comprobación, cada ciclo dispararía el
      // siguiente para siempre.
      await tester.pump(kSyncMutationDebounce * 2);
      await tester.pump();

      expect(server.pushedBatches, hasLength(1));
    });

    engineTest('durante un corte respeta el backoff y no golpea al servidor', (
      tester,
    ) async {
      server.pullFailure = StateError('sin red');
      await boot(tester);

      // El ciclo de arranque falló, así que hay un reintento agendado.
      expect(container.read(syncEngineProvider).nextAttemptAt, isNotNull);

      await capture('cliente-1');
      await tester.pump(kSyncMutationDebounce);
      await tester.pump();

      // La captura está guardada y saldrá en el reintento; lo que no hace es
      // adelantarlo. El backoff mínimo son 3,75 s y el debounce son 2 s.
      expect(server.pushedBatches, isEmpty);
      expect(await local.pendingCount(), 1);
    });
  });
}
