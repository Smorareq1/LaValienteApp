import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../sync/data/sync_repository.dart';
import '../models/customer.dart';
import 'customers_local_datasource.dart';

part 'customers_repository.g.dart';

/// Clientes, contra la BD local siempre (plan 0004 D1).
///
/// Capturar un cliente son dos escrituras que tienen que ir juntas: la fila
/// espejo, para que la persona lo vea de inmediato, y la operación en el outbox,
/// para que el servidor se entere. Van en una transacción porque un corte entre
/// ambas dejaría o un cliente fantasma que nadie sube, o una operación sobre un
/// cliente que en la pantalla no existe.
class CustomersRepository {
  const CustomersRepository({
    required AppDatabase database,
    required CustomersLocalDataSource local,
    required SyncRepository sync,
    String Function() uuid = _defaultUuid,
  }) : _database = database,
       _local = local,
       _sync = sync,
       _uuid = uuid;

  final AppDatabase _database;
  final CustomersLocalDataSource _local;
  final SyncRepository _sync;
  final String Function() _uuid;

  static String _defaultUuid() => const Uuid().v4();

  Stream<List<Customer>> watch({String query = '', int limit = 50}) =>
      _local.watch(query: query, limit: limit);

  Stream<int> watchCount() => _local.watchCount();

  Stream<Customer?> watchById(String id) => _local.watchById(id);

  Future<Customer?> byId(String id) => _local.byId(id);

  /// Registra un cliente nuevo. El id lo genera el dispositivo (D3) para que un
  /// pedido pueda referenciarlo antes de que ninguno de los dos llegue al
  /// servidor.
  Future<Either<AppFailure, Customer>> create({
    required String fullName,
    String? phone,
    String? nit,
    String? email,
    String? address,
    String? notes,
  }) async {
    final name = fullName.trim();
    if (name.length < 2) {
      return const Left(ValidationFailure('El nombre del cliente es obligatorio'));
    }

    final id = _uuid();
    final fields = _fields(
      fullName: name,
      phone: phone,
      nit: nit,
      email: email,
      address: address,
      notes: notes,
    );

    try {
      await _database.transaction(() async {
        await _local.upsertLocal(
          id: id,
          fullName: name,
          version: 0,
          phone: fields['phone'] as String?,
          nit: fields['nit'] as String?,
          email: fields['email'] as String?,
          address: fields['address'] as String?,
          notes: fields['notes'] as String?,
        );
        await _sync.enqueue(
          entity: 'customer',
          opType: 'create',
          entityId: id,
          payload: fields,
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    final saved = await _local.byId(id);
    return saved == null
        ? const Left(CacheFailure('No se pudo guardar el cliente'))
        : Right(saved);
  }

  /// Edita un cliente. [current] aporta la versión conocida del servidor, que
  /// viaja como `base_version` para que una edición sobre datos viejos se
  /// detecte en vez de pisar lo que otro dispositivo ya escribió (D6).
  Future<Either<AppFailure, Customer>> update(
    Customer current, {
    required String fullName,
    String? phone,
    String? nit,
    String? email,
    String? address,
    String? notes,
    bool? isActive,
  }) async {
    final name = fullName.trim();
    if (name.length < 2) {
      return const Left(ValidationFailure('El nombre del cliente es obligatorio'));
    }

    final fields = _fields(
      fullName: name,
      phone: phone,
      nit: nit,
      email: email,
      address: address,
      notes: notes,
    );
    if (isActive != null) fields['is_active'] = isActive;

    try {
      await _database.transaction(() async {
        await _local.upsertLocal(
          id: current.id,
          fullName: name,
          version: current.version,
          phone: fields['phone'] as String?,
          nit: fields['nit'] as String?,
          email: fields['email'] as String?,
          address: fields['address'] as String?,
          notes: fields['notes'] as String?,
          isActive: isActive ?? current.isActive,
        );
        await _sync.enqueue(
          entity: 'customer',
          opType: 'update',
          entityId: current.id,
          payload: fields,
          baseVersion: current.version,
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }

    final saved = await _local.byId(current.id);
    return saved == null
        ? const Left(CacheFailure('No se pudo guardar el cliente'))
        : Right(saved);
  }

  /// Retira un cliente de la circulación.
  ///
  /// Viaja como operación propia y no como una edición con `is_active: false`
  /// porque el servidor le exige otro permiso: un colaborador puede corregir
  /// el teléfono de alguien, pero no darlo de baja (plan 0006 §13).
  ///
  /// No lleva `base_version`: archivar es un cambio de estado, no una escritura
  /// sobre campos, y hacerlo encima del cambio de nombre de otro dispositivo no
  /// es un conflicto — el cliente queda archivado igual.
  Future<Either<AppFailure, void>> archive(Customer customer) async {
    try {
      await _database.transaction(() async {
        await _local.upsertLocal(
          id: customer.id,
          fullName: customer.fullName,
          version: customer.version,
          phone: customer.phone,
          nit: customer.nit,
          email: customer.email,
          address: customer.address,
          notes: customer.notes,
          isActive: false,
        );
        await _sync.enqueue(
          entity: 'customer',
          opType: 'archive',
          entityId: customer.id,
          payload: const {},
        );
      });
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
    return const Right(null);
  }

  /// Payload con los nombres de campo del backend.
  ///
  /// Los vacíos viajan como `null`, no como `""`: el servidor valida el
  /// teléfono y el NIT contra un patrón, y una cadena vacía sería un rechazo
  /// que la persona tendría que ir a resolver a la cola de revisión por no
  /// haber escrito algo opcional.
  static Map<String, dynamic> _fields({
    required String fullName,
    String? phone,
    String? nit,
    String? email,
    String? address,
    String? notes,
  }) {
    String? clean(String? value) {
      final trimmed = value?.trim();
      return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    }

    return <String, dynamic>{
      'full_name': fullName,
      'phone': clean(phone),
      'nit': clean(nit),
      'email': clean(email),
      'address': clean(address),
      'notes': clean(notes),
    };
  }
}

@Riverpod(keepAlive: true)
CustomersRepository customersRepository(Ref ref) {
  return CustomersRepository(
    database: ref.watch(appDatabaseProvider),
    local: ref.watch(customersLocalDataSourceProvider),
    sync: ref.watch(syncRepositoryProvider),
  );
}
