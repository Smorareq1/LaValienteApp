import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/core/errors/app_failure.dart';
import 'package:la_valiente/core/money/payment_method.dart';
import 'package:la_valiente/core/storage/secure_storage_service.dart';
import 'package:la_valiente/features/cash/data/expenses_local_datasource.dart';
import 'package:la_valiente/features/cash/data/expenses_repository.dart';
import 'package:la_valiente/features/cash/models/expense.dart';
import 'package:la_valiente/features/sync/data/sync_local_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_remote_datasource.dart';
import 'package:la_valiente/features/sync/data/sync_repository.dart';
import 'package:la_valiente/features/sync/models/device_descriptor.dart';

/// Anotar un gasto tiene que funcionar sin red, que es justo lo que se
/// comprueba: si alguna ruta tocara el servidor, el `UnimplementedError` lo
/// delataría.
class _UnusedServer implements SyncRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late AppDatabase database;
  late ExpensesRepository repository;
  late SyncLocalDataSource syncLocal;

  var ids = 0;

  ExpenseDraft draft({
    String date = '2026-07-18',
    String category = 'cat-insumos',
    String concept = 'Gas — 2 sacos',
    int amount = 16100,
    PaymentMethod method = PaymentMethod.cash,
    ExpenseStatus status = ExpenseStatus.paid,
    String? observations,
  }) {
    return ExpenseDraft(
      expenseDate: date,
      categoryId: category,
      concept: concept,
      amount: amount,
      method: method,
      status: status,
      observations: observations,
    );
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    syncLocal = SyncLocalDataSource(database);
    ids = 0;
    repository = ExpensesRepository(
      database: database,
      local: ExpensesLocalDataSource(database),
      sync: SyncRepository(
        local: syncLocal,
        remote: _UnusedServer(),
        storage: _UnusedStorage(),
        mirrors: const {},
        device: const DeviceDescriptor(
          name: 'Tablet',
          platform: 'android',
          appVersion: '1.0.0',
        ),
        uuid: () => 'op-${++ids}',
      ),
      uuid: () => 'gasto-${++ids}',
    );

    await database
        .into(database.expenseCategoryEntries)
        .insert(
          ExpenseCategoryEntriesCompanion.insert(
            id: 'cat-insumos',
            name: 'Compra de insumos',
            sortOrder: const Value(1),
          ),
        );
  });

  tearDown(() => database.close());

  group('alta', () {
    test('el gasto queda en el día de inmediato y con su operación encolada', () async {
      final result = await repository.create(draft(), createdById: 'sebas');

      final expense = result.getRight().toNullable()!;
      expect(expense.concept, 'Gas — 2 sacos');
      expect(expense.amount, 16100);
      expect(expense.pendingSync, isTrue);
      expect(expense.version, 0);
      // El nombre sale de unir con la categoría, no de una copia en la fila.
      expect(expense.categoryName, 'Compra de insumos');

      final pending = await syncLocal.pendingOperations(limit: 10);
      expect(pending.single.entity, 'expense');
      expect(pending.single.opType, 'create');
      expect(pending.single.entityId, expense.id);
      // Un alta no lleva `base_version`: no hay versión anterior contra la cual
      // chocar.
      expect(pending.single.baseVersion, isNull);
    });

    test('el cuerpo usa los nombres del backend y el monto viaja como texto', () async {
      await repository.create(
        draft(method: PaymentMethod.transfer, status: ExpenseStatus.pending),
        createdById: 'sebas',
      );

      final payload = (await syncLocal.pendingOperations(limit: 1)).single.payload;
      expect(payload['expense_date'], '2026-07-18');
      expect(payload['category_id'], 'cat-insumos');
      expect(payload['amount'], '161.00');
      // Se llama `method` y no `payment_method`, para leerse igual que el de un
      // pago de pedido.
      expect(payload['method'], 'transfer');
      expect(payload['status'], 'pending');
    });

    test('las observaciones vacías viajan como null, no como cadena vacía', () async {
      await repository.create(draft(observations: '   '), createdById: 'sebas');

      final payload = (await syncLocal.pendingOperations(limit: 1)).single.payload;
      expect(payload['observations'], isNull);
    });

    test('un monto en cero se rechaza sin tocar la base', () async {
      final result = await repository.create(draft(amount: 0), createdById: 'sebas');

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      expect(await syncLocal.pendingCount(), 0);
      expect(await database.select(database.expenseEntries).get(), isEmpty);
    });

    test('un concepto en blanco se rechaza', () async {
      final result = await repository.create(draft(concept: '  '), createdById: 'sebas');

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      expect(await syncLocal.pendingCount(), 0);
    });
  });

  group('corrección', () {
    test('viaja con base_version: pisar lo de otro dispositivo es un conflicto', () async {
      final created = (await repository.create(draft(), createdById: 'sebas'))
          .getRight()
          .toNullable()!;

      // El feed bajó la versión del servidor.
      await (database.update(database.expenseEntries)
            ..where((row) => row.id.equals(created.id)))
          .write(
            ExpenseEntriesCompanion(
              version: const Value(4),
              syncStatus: Value(RowSyncStatus.synced.name),
            ),
          );
      final synced = await repository.byId(created.id);

      await repository.update(synced!, draft(amount: 15000));

      final operations = await syncLocal.pendingOperations(limit: 10);
      final correction = operations.last;
      expect(correction.opType, 'update');
      expect(correction.baseVersion, 4);
      expect(correction.payload['amount'], '150.00');

      final saved = await repository.byId(created.id);
      expect(saved!.amount, 15000);
      expect(saved.pendingSync, isTrue);
    });

    test('un gasto atado a una jornada no se corrige desde la Caja', () async {
      // Mover un pago de hora extra de una jornada a otra no es una corrección:
      // es otro pago. El servidor tampoco deja mover el vínculo.
      await database
          .into(database.expenseEntries)
          .insert(
            ExpenseEntriesCompanion.insert(
              id: 'gasto-hora-extra',
              expenseDate: '2026-07-18',
              categoryId: 'cat-insumos',
              concept: 'Hora extra de Marta',
              amount: '20.00',
              method: 'cash',
              status: 'paid',
              createdById: 'sebas',
              employeeId: const Value('marta'),
              attendanceRecordId: const Value('jornada-1'),
            ),
          );

      final linked = await repository.byId('gasto-hora-extra');
      final result = await repository.update(linked!, draft(amount: 9900));

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      expect((await repository.byId('gasto-hora-extra'))!.amount, 2000);
      expect(await syncLocal.pendingCount(), 0);
    });
  });

  group('el día', () {
    test('lista solo los gastos de la fecha y deja fuera las lápidas', () async {
      await repository.create(draft(), createdById: 'sebas');
      await repository.create(draft(date: '2026-07-19'), createdById: 'sebas');

      final anulado = (await repository.create(
        draft(concept: 'Anulado'),
        createdById: 'sebas',
      )).getRight().toNullable()!;
      await (database.update(database.expenseEntries)
            ..where((row) => row.id.equals(anulado.id)))
          .write(ExpenseEntriesCompanion(deletedAt: Value(DateTime.now())));

      final day = await repository.watchByDate('2026-07-18').first;
      expect(day.map((expense) => expense.concept), ['Gas — 2 sacos']);
    });
  });
}
