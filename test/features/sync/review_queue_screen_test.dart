import 'dart:convert';

import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/app.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/core/time/business_date.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';
import 'package:la_valiente/features/sync/state/sync_engine.dart';

class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

/// El motor no arranca solo en las pruebas: lo que se está probando es la
/// pantalla, no el ciclo.
class _IdleSyncEngine extends SyncEngine {
  @override
  SyncEngineState build() => const SyncEngineState();
}

void main() {
  late AppDatabase database;
  late SyncRepository sync;
  var closed = false;

  /// Misma receta que en las otras pantallas con drift: desmontar y dejar
  /// correr el temporizador que agenda al cancelar un stream, antes de cerrar.
  void reviewTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await database.close();
      closed = true;
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    closed = false;
    database = AppDatabase(NativeDatabase.memory());
    sync = SyncRepository(
      local: SyncLocalDataSource(database),
      remote: _UnusedServer(),
      storage: _UnusedStorage(),
      mirrors: const {},
      device: const DeviceDescriptor(
        name: 'Tablet',
        platform: 'android',
        appVersion: '1.0.0',
      ),
    );
  });

  tearDown(() async {
    if (!closed) await database.close();
  });

  Future<void> seedReview({
    required String opId,
    required String entity,
    required String opType,
    required String entityId,
    String status = 'rejected',
    String? reason,
    Map<String, dynamic> payload = const {},
  }) {
    return database
        .into(database.reviewEntries)
        .insert(
          ReviewEntriesCompanion.insert(
            opId: opId,
            entity: entity,
            opType: opType,
            entityId: entityId,
            status: status,
            reason: Value(reason),
            localPayload: jsonEncode(payload),
            createdAt: DateTime.now(),
          ),
        );
  }

  /// Un pedido del servidor en el espejo local, con su cliente.
  Future<void> seedOrder({
    required String id,
    required int dailyNumber,
    String? bookletSerial,
    int version = 3,
    String syncStatus = 'synced',
  }) async {
    await database
        .into(database.customerEntries)
        .insert(
          CustomerEntriesCompanion.insert(
            id: 'cliente-1',
            fullName: 'Ana Pérez',
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await database
        .into(database.orderEntries)
        .insert(
          OrderEntriesCompanion.insert(
            id: id,
            version: Value(version),
            syncStatus: Value(syncStatus),
            orderDate: isoDate(businessDate()),
            dailyNumber: dailyNumber,
            bookletSerial: Value(bookletSerial),
            customerId: 'cliente-1',
            totalPieces: const Value(3),
            status: 'ready',
            subtotal: '90.00',
            discountTotal: '0.00',
            total: '90.00',
            receivedById: 'u1',
          ),
        );
  }

  /// Abre la app y entra a la cola por el banner de Inicio, que es el camino
  /// que el plan 0006 §4.1 pide y el que estaba roto hasta esta fase.
  Future<void> openQueue(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          syncRepositoryProvider.overrideWithValue(sync),
          syncEngineProvider.overrideWith(_IdleSyncEngine.new),
          authControllerProvider.overrideWith(
            () => _FakeAuthController(
              const AuthUser(
                id: 'u1',
                username: 'mostrador',
                fullName: 'Marta González',
                roles: ['admin'],
                permissions: [AppPermissions.all],
              ),
            ),
          ),
        ],
        child: const LaValienteApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('necesita'));
    await tester.pumpAndSettle();
  }

  reviewTest('el banner de Inicio abre la cola con lo que espera decisión', (tester) async {
    await seedReview(
      opId: 'op-1',
      entity: 'order',
      opType: 'create',
      entityId: 'o1',
      reason: 'Booklet A-4410 has already been registered.',
      payload: const {'booklet_serial': 'A-4410'},
    );
    await seedReview(
      opId: 'op-2',
      entity: 'order_payment',
      opType: 'create',
      entityId: 'p1',
      payload: const {'order_id': 'o9', 'amount': '50.00', 'method': 'cash'},
    );

    await openQueue(tester);

    expect(find.text('Revisión'), findsOneWidget);
    expect(find.text('2 capturas'), findsOneWidget);
    // Cada tarjeta dice qué se intentó, no solo que algo falló.
    expect(find.text('Boleta nueva'), findsOneWidget);
    expect(find.text('Boleta A-4410'), findsOneWidget);
    expect(find.text('Cobro'), findsOneWidget);
    expect(find.text('Q50.00'), findsOneWidget);
  });

  reviewTest('una corrección que chocó explica el choque y ofrece rehacerla', (tester) async {
    await seedOrder(id: 'o1', dailyNumber: 7, bookletSerial: 'A-4410');
    await seedReview(
      opId: 'op-1',
      entity: 'order',
      opType: 'update',
      entityId: 'o1',
      status: 'conflict',
      reason: 'This order changed since you last saw it (version 3).',
      payload: const {
        'booklet_serial': 'A-4410',
        'garments': [
          {'garment_type_id': 'gt-1', 'quantity': 4},
        ],
        'charges': [
          {'service_code': 'wash_tub'},
        ],
      },
    );

    await openQueue(tester);
    await tester.tap(find.text('Corrección de boleta'));
    await tester.pumpAndSettle();

    expect(find.textContaining('mientras este teléfono estaba sin señal'), findsOneWidget);
    // El motivo del servidor se muestra literal y aparte, como diagnóstico.
    expect(find.textContaining('This order changed since'), findsOneWidget);

    // Las dos versiones: lo capturado sale del payload, lo actual del espejo.
    expect(find.text('Lo que se capturó aquí'), findsOneWidget);
    expect(find.text('Lo que hay ahora'), findsOneWidget);
    expect(find.text('Pedido #7'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    // El saldo aparece porque el pedido no tiene pagos: 90 de total, 90 debiendo.
    expect(find.text('Saldo'), findsOneWidget);
    expect(find.text('Q90.00'), findsNWidgets(2));

    expect(find.text('Corregir de nuevo'), findsOneWidget);
    expect(find.text('Ver el pedido'), findsOneWidget);
    // Reintentar a ciegas pisaría la corrección del otro dispositivo (D6).
    expect(find.text('Volver a intentar'), findsNothing);
  });

  reviewTest('una boleta duplicada señala la que ya tiene esa serie', (tester) async {
    await seedOrder(id: 'o-bueno', dailyNumber: 7, bookletSerial: 'A-4410');
    await seedOrder(
      id: 'o-rechazado',
      dailyNumber: -1,
      bookletSerial: 'A-4410',
      version: 0,
      syncStatus: 'rejected',
    );
    await seedReview(
      opId: 'op-1',
      entity: 'order',
      opType: 'create',
      entityId: 'o-rechazado',
      reason: 'Booklet A-4410 has already been registered.',
      payload: const {'booklet_serial': 'A-4410', 'garments': [], 'charges': []},
    );

    await openQueue(tester);
    await tester.tap(find.text('Boleta nueva'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ya la tiene el pedido #7'), findsOneWidget);
    expect(find.text('La boleta que ya estaba'), findsOneWidget);
    expect(find.text('Pedido #7'), findsOneWidget);
    expect(find.text('Corregir la boleta'), findsOneWidget);
    expect(find.text('Descartar la boleta'), findsOneWidget);
  });

  reviewTest('descartar un alta la retira del teléfono tras confirmar', (tester) async {
    await seedReview(
      opId: 'op-1',
      entity: 'customer',
      opType: 'create',
      entityId: 'c1',
      payload: const {'full_name': 'Elena Ramírez'},
    );

    await openQueue(tester);
    await tester.tap(find.text('Cliente nuevo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Solo existe en este teléfono'), findsOneWidget);

    await tester.tap(find.text('Descartar el cliente'));
    await tester.pumpAndSettle();

    // Nada desaparece sin decir qué implica.
    expect(find.textContaining('El servidor nunca'), findsOneWidget);
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();

    expect(find.text('Nada que revisar'), findsOneWidget);
  });
}
