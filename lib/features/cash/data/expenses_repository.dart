import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../../sync/data/sync_repository.dart';
import '../models/expense.dart';
import 'expenses_local_datasource.dart';

part 'expenses_repository.g.dart';

/// Lo que se captura al anotar un gasto (plan 0006 §7.2).
class ExpenseDraft {
  const ExpenseDraft({
    required this.expenseDate,
    required this.categoryId,
    required this.concept,
    required this.amount,
    this.method = PaymentMethod.cash,
    this.status = ExpenseStatus.paid,
    this.observations,
    this.employeeId,
    this.attendanceRecordId,
  });

  /// `YYYY-MM-DD`.
  final String expenseDate;

  final String categoryId;
  final String concept;

  /// En centavos.
  final int amount;

  final PaymentMethod method;
  final ExpenseStatus status;
  final String? observations;

  /// A quién se le paga (§6.2). Va solo en el alta: el servidor no deja mover un
  /// gasto de una persona a otra, porque eso no es una corrección sino otro pago.
  final String? employeeId;

  /// La jornada que se está pagando. El servidor exige que venga con su
  /// empleado: un pago a nadie en particular es justo la fila que aparece sin
  /// explicación a fin de mes.
  final String? attendanceRecordId;

  bool get isOvertimePayment => attendanceRecordId != null;
}

/// Gastos, contra la BD local siempre (plan 0004 D1).
///
/// La fila espejo y la operación del outbox van en una transacción: separarlas
/// dejaría o un gasto que la pantalla cuenta y nadie sube, o una operación sobre
/// un gasto que en el dispositivo no existe.
class ExpensesRepository {
  const ExpensesRepository({
    required AppDatabase database,
    required ExpensesLocalDataSource local,
    required SyncRepository sync,
    String Function() uuid = _defaultUuid,
  }) : _database = database,
       _local = local,
       _sync = sync,
       _uuid = uuid;

  final AppDatabase _database;
  final ExpensesLocalDataSource _local;
  final SyncRepository _sync;
  final String Function() _uuid;

  static String _defaultUuid() => const Uuid().v4();

  Stream<List<ExpenseCategory>> watchCategories() => _local.watchCategories();

  Stream<List<Expense>> watchByDate(String date) => _local.watchByDate(date);

  Future<Expense?> byId(String id) => _local.byId(id);

  /// Anota el gasto. El id lo genera el dispositivo (D3) para que la fila que
  /// queda en pantalla y la que guarde el servidor sean la misma, y para que
  /// reintentar el push no lo anote dos veces.
  Future<Either<AppFailure, Expense>> create(
    ExpenseDraft draft, {
    required String createdById,
  }) async {
    final invalid = _validate(draft);
    if (invalid != null) return Left(invalid);

    final id = _uuid();
    final concept = draft.concept.trim();
    final observations = _clean(draft.observations);

    try {
      await _database.transaction(() async {
        await _local.insertLocal(
          id: id,
          expenseDate: draft.expenseDate,
          categoryId: draft.categoryId,
          concept: concept,
          amount: draft.amount,
          method: draft.method,
          status: draft.status,
          createdById: createdById,
          observations: observations,
          employeeId: draft.employeeId,
          attendanceRecordId: draft.attendanceRecordId,
        );
        await _sync.enqueue(
          entity: 'expense',
          opType: 'create',
          entityId: id,
          payload: _payload(
            draft,
            concept: concept,
            observations: observations,
            withLinks: true,
          ),
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    final saved = await _local.byId(id);
    return saved == null
        ? const Left(CacheFailure('No se pudo guardar el gasto'))
        : Right(saved);
  }

  /// Corrige lo que el gasto dice. Exige `expenses.update`, que el colaborador
  /// no tiene (plan 0006 §13): quien anotó de más llama a un admin.
  ///
  /// Viaja con `base_version` porque corregir es escribir sobre campos, y
  /// hacerlo encima de la corrección de otro dispositivo es un conflicto que
  /// nadie puede resolver adivinando (plan 0004 D6).
  Future<Either<AppFailure, Expense>> update(
    Expense current,
    ExpenseDraft draft,
  ) async {
    if (current.isLinked) {
      return const Left(
        ValidationFailure(
          'Este gasto está atado a una jornada o a un lote: para cambiarlo hay que '
          'anularlo y volver a registrarlo',
        ),
      );
    }
    final invalid = _validate(draft);
    if (invalid != null) return Left(invalid);

    final concept = draft.concept.trim();
    final observations = _clean(draft.observations);

    try {
      await _database.transaction(() async {
        await _local.updateLocal(
          id: current.id,
          expenseDate: draft.expenseDate,
          categoryId: draft.categoryId,
          concept: concept,
          amount: draft.amount,
          method: draft.method,
          status: draft.status,
          observations: observations,
        );
        await _sync.enqueue(
          entity: 'expense',
          opType: 'update',
          entityId: current.id,
          baseVersion: current.version,
          payload: _payload(draft, concept: concept, observations: observations),
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    final saved = await _local.byId(current.id);
    return saved == null
        ? const Left(CacheFailure('No se pudo guardar el gasto'))
        : Right(saved);
  }

  /// Lo que el servidor también comprobaría, dicho antes de encolarlo: un gasto
  /// que se rechaza sin señal no se descubre hasta la cola de revisión, con el
  /// día ya avanzado.
  static AppFailure? _validate(ExpenseDraft draft) {
    if (draft.categoryId.isEmpty) {
      return const ValidationFailure('Elegí la categoría del gasto');
    }
    if (draft.concept.trim().isEmpty) {
      return const ValidationFailure('Escribí en qué se gastó');
    }
    if (draft.amount <= 0) {
      return const ValidationFailure('El monto tiene que ser mayor que cero');
    }
    return null;
  }

  /// El cuerpo de `expense/create` y `expense/update`, con los nombres del
  /// backend. `method` se llama así y no `payment_method`, para leerse igual que
  /// el de un pago de pedido.
  ///
  /// Los vínculos viajan **solo en el alta** ([withLinks]): el `ExpenseUpdate`
  /// del servidor no los admite, y mandarlos en una corrección sería pedir algo
  /// que va a rebotar.
  static Map<String, dynamic> _payload(
    ExpenseDraft draft, {
    required String concept,
    String? observations,
    bool withLinks = false,
  }) {
    return <String, dynamic>{
      'expense_date': draft.expenseDate,
      'category_id': draft.categoryId,
      'concept': concept,
      'amount': Fixed2.format(draft.amount),
      'method': draft.method.wire,
      'status': draft.status.wire,
      'observations': observations,
      if (withLinks) ...{
        'employee_id': draft.employeeId,
        // El servidor exige que una jornada venga con su empleado, así que la
        // pantalla no deja elegirla sin él y aquí viajan juntos o no viajan.
        'attendance_record_id': draft.attendanceRecordId,
      },
    };
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

@Riverpod(keepAlive: true)
ExpensesRepository expensesRepository(Ref ref) {
  return ExpensesRepository(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(expensesLocalDataSourceProvider),
    sync: ref.watch(syncRepositoryProvider),
  );
}
