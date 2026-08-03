import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/sync/models/sync_details.dart';
import 'package:la_valiente/features/sync/models/sync_progress.dart';
import 'package:la_valiente/features/sync/models/sync_status.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';
import 'package:la_valiente/features/sync/state/sync_status_controller.dart';
import 'package:la_valiente/features/sync/ui/sync_screen.dart';

class _FixedEngine extends SyncEngine {
  _FixedEngine(this._state);

  final SyncEngineState _state;

  @override
  SyncEngineState build() => _state;
}

class _FixedStatus extends SyncStatusController {
  _FixedStatus(this._status);

  final SyncStatus _status;

  @override
  SyncStatus build() => _status;
}

Future<void> _pump(
  WidgetTester tester, {
  required SyncStatus status,
  SyncEngineState engine = const SyncEngineState(),
  SyncDetails? details,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncStatusControllerProvider.overrideWith(() => _FixedStatus(status)),
        syncEngineProvider.overrideWith(() => _FixedEngine(engine)),
        syncDetailsProvider.overrideWith((ref) => Stream.value(details ?? const SyncDetails())),
      ],
      child: const MaterialApp(home: SyncScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  testWidgets('sin nada pendiente informa que todo está sincronizado', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(tester, status: const SyncStatus.synced());

    expect(find.text('Todo sincronizado'), findsOneWidget);
    expect(find.text('Sincronizar ahora'), findsOneWidget);
  });

  testWidgets('con capturas esperando muestra cuántas son y que no se pierden', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      status: const SyncStatus(state: SyncState.pending, pendingCount: 7),
    );

    expect(find.text('7 esperando subir'), findsOneWidget);
    expect(find.textContaining('Nada se pierde'), findsOneWidget);
  });

  testWidgets('lo que necesita revisión tapa a lo que solo espera', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      status: const SyncStatus(state: SyncState.needsReview, pendingCount: 3, reviewCount: 2),
    );

    expect(find.text('2 necesitan revisión'), findsOneWidget);
    expect(find.text('Revisar'), findsOneWidget);
  });

  testWidgets('un reloj desfasado se señala en el diagnóstico', (tester) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      status: const SyncStatus.synced(),
      details: SyncDetails(
        deviceId: 'a1b2c3d4-0000-0000-0000-000000000000',
        pullCursor: 4210,
        bootstrapCompleted: true,
        lastCycleAt: DateTime.now().subtract(const Duration(minutes: 3)),
        clockSkew: const Duration(minutes: 12),
      ),
    );

    expect(find.textContaining('Desfasado 12 min'), findsOneWidget);
    expect(find.text('a1b2c3d4…'), findsOneWidget);
    expect(find.text('4210'), findsOneWidget);
    expect(find.text('hace 3 min'), findsWidgets);
  });

  testWidgets('tras un fallo se anuncia cuándo será el siguiente intento', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      status: const SyncStatus(state: SyncState.pending, pendingCount: 1),
      engine: SyncEngineState(
        progress: const SyncProgress(phase: SyncPhase.failed),
        nextAttemptAt: DateTime.now().add(const Duration(seconds: 40)),
        consecutiveFailures: 3,
      ),
    );

    expect(find.textContaining('Siguiente intento en'), findsOneWidget);
    expect(find.textContaining('3 intentos fallidos'), findsOneWidget);
  });
}
