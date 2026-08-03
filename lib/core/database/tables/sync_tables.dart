import 'package:drift/drift.dart';

/// Estado del motor de sincronización. Una sola fila, con `id = 0`.
///
/// Vive en la BD y no en `SharedPreferences` porque el cursor de pull tiene que
/// avanzar en la misma transacción que los datos que describe: si se guardara
/// aparte, un corte entre ambas escrituras dejaría al dispositivo saltándose
/// cambios para siempre.
@DataClassName('SyncStateEntry')
class SyncStateEntries extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// UUID que este dispositivo genera una vez y registra en el servidor (D3).
  TextColumn get deviceId => text().nullable()();

  BoolColumn get deviceRegistered => boolean().withDefault(const Constant(false))();

  /// Último `sync_seq` aplicado. `0` significa "todavía sin bootstrap".
  IntColumn get pullCursor => integer().withDefault(const Constant(0))();

  BoolColumn get bootstrapCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastPushAt => dateTime().nullable()();
  DateTimeColumn get lastPullAt => dateTime().nullable()();
  DateTimeColumn get lastCycleAt => dateTime().nullable()();

  TextColumn get lastError => text().nullable()();

  /// Diferencia observada contra `server_time` en el último ciclo (§9): si el
  /// reloj del equipo está corrido, la fecha de negocio de los pedidos también.
  IntColumn get clockSkewSeconds => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Operaciones capturadas localmente que aún no confirmó el servidor (§6.3).
///
/// Es una bitácora de **comandos**, no de filas: se empuja lo que la persona
/// hizo ("cobrar Q50"), no el estado resultante, para que el servidor pueda
/// aplicar sus propias reglas de dominio (D2).
@DataClassName('OutboxEntry')
class OutboxEntries extends Table {
  /// Orden local monotónico. El servidor aplica el lote siguiendo este número.
  IntColumn get seq => integer().autoIncrement()();

  /// Clave de idempotencia: reintentar la misma op nunca la duplica (D4).
  TextColumn get opId => text().unique()();

  TextColumn get entity => text().withLength(max: 40)();
  TextColumn get opType => text().withLength(max: 40)();
  TextColumn get entityId => text()();

  /// Versión conocida al capturar; el servidor la usa para detectar escrituras
  /// sobre datos viejos (D6). Nulo en creaciones.
  IntColumn get baseVersion => integer().nullable()();

  /// Payload JSON, con el mismo contrato que el endpoint REST equivalente.
  TextColumn get payload => text()();

  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Cola de revisión: lo que el servidor rechazó o marcó en conflicto (§8).
///
/// Nada se descarta solo. Cada entrada guarda lo que se capturó y lo que el
/// servidor respondió, para que una persona pueda decidir con las dos versiones
/// a la vista.
@DataClassName('ReviewEntry')
class ReviewEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get opId => text().unique()();
  TextColumn get entity => text().withLength(max: 40)();
  TextColumn get opType => text().withLength(max: 40)();
  TextColumn get entityId => text()();

  /// `rejected` o `conflict`.
  TextColumn get status => text().withLength(max: 20)();

  TextColumn get reason => text().nullable()();
  TextColumn get localPayload => text()();
  TextColumn get serverData => text().nullable()();
  IntColumn get serverVersion => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

/// Cambios del feed cuya entidad todavía no tiene tabla espejo local.
///
/// El feed es único y ordenado: no se puede avanzar el cursor saltándose una
/// entidad desconocida sin perderla para siempre, ni detenerlo sin bloquear el
/// resto. Se guardan aquí y el espejo los drena cuando se registre (PR S3+).
/// La clave por entidad e id hace que solo sobreviva la última versión.
@DataClassName('DeferredChange')
class DeferredChanges extends Table {
  TextColumn get entity => text().withLength(max: 40)();
  TextColumn get entityId => text()();
  IntColumn get version => integer()();
  IntColumn get syncSeq => integer()();
  BoolColumn get deleted => boolean()();
  TextColumn get data => text()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entity, entityId};
}
