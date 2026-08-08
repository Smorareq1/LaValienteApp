// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncStateEntriesTable extends SyncStateEntries
    with TableInfo<$SyncStateEntriesTable, SyncStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceRegisteredMeta = const VerificationMeta(
    'deviceRegistered',
  );
  @override
  late final GeneratedColumn<bool> deviceRegistered = GeneratedColumn<bool>(
    'device_registered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("device_registered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pullCursorMeta = const VerificationMeta(
    'pullCursor',
  );
  @override
  late final GeneratedColumn<int> pullCursor = GeneratedColumn<int>(
    'pull_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bootstrapCompletedMeta =
      const VerificationMeta('bootstrapCompleted');
  @override
  late final GeneratedColumn<bool> bootstrapCompleted = GeneratedColumn<bool>(
    'bootstrap_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bootstrap_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPushAt = GeneratedColumn<DateTime>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCycleAtMeta = const VerificationMeta(
    'lastCycleAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCycleAt = GeneratedColumn<DateTime>(
    'last_cycle_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clockSkewSecondsMeta = const VerificationMeta(
    'clockSkewSeconds',
  );
  @override
  late final GeneratedColumn<int> clockSkewSeconds = GeneratedColumn<int>(
    'clock_skew_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    deviceRegistered,
    pullCursor,
    bootstrapCompleted,
    lastPushAt,
    lastPullAt,
    lastCycleAt,
    lastError,
    clockSkewSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('device_registered')) {
      context.handle(
        _deviceRegisteredMeta,
        deviceRegistered.isAcceptableOrUnknown(
          data['device_registered']!,
          _deviceRegisteredMeta,
        ),
      );
    }
    if (data.containsKey('pull_cursor')) {
      context.handle(
        _pullCursorMeta,
        pullCursor.isAcceptableOrUnknown(data['pull_cursor']!, _pullCursorMeta),
      );
    }
    if (data.containsKey('bootstrap_completed')) {
      context.handle(
        _bootstrapCompletedMeta,
        bootstrapCompleted.isAcceptableOrUnknown(
          data['bootstrap_completed']!,
          _bootstrapCompletedMeta,
        ),
      );
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    if (data.containsKey('last_cycle_at')) {
      context.handle(
        _lastCycleAtMeta,
        lastCycleAt.isAcceptableOrUnknown(
          data['last_cycle_at']!,
          _lastCycleAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('clock_skew_seconds')) {
      context.handle(
        _clockSkewSecondsMeta,
        clockSkewSeconds.isAcceptableOrUnknown(
          data['clock_skew_seconds']!,
          _clockSkewSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      deviceRegistered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}device_registered'],
      )!,
      pullCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pull_cursor'],
      )!,
      bootstrapCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bootstrap_completed'],
      )!,
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_push_at'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
      lastCycleAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_cycle_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      clockSkewSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_skew_seconds'],
      ),
    );
  }

  @override
  $SyncStateEntriesTable createAlias(String alias) {
    return $SyncStateEntriesTable(attachedDatabase, alias);
  }
}

class SyncStateEntry extends DataClass implements Insertable<SyncStateEntry> {
  final int id;

  /// UUID que este dispositivo genera una vez y registra en el servidor (D3).
  final String? deviceId;
  final bool deviceRegistered;

  /// Último `sync_seq` aplicado. `0` significa "todavía sin bootstrap".
  final int pullCursor;
  final bool bootstrapCompleted;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;
  final DateTime? lastCycleAt;
  final String? lastError;

  /// Diferencia observada contra `server_time` en el último ciclo (§9): si el
  /// reloj del equipo está corrido, la fecha de negocio de los pedidos también.
  final int? clockSkewSeconds;
  const SyncStateEntry({
    required this.id,
    this.deviceId,
    required this.deviceRegistered,
    required this.pullCursor,
    required this.bootstrapCompleted,
    this.lastPushAt,
    this.lastPullAt,
    this.lastCycleAt,
    this.lastError,
    this.clockSkewSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['device_registered'] = Variable<bool>(deviceRegistered);
    map['pull_cursor'] = Variable<int>(pullCursor);
    map['bootstrap_completed'] = Variable<bool>(bootstrapCompleted);
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    if (!nullToAbsent || lastCycleAt != null) {
      map['last_cycle_at'] = Variable<DateTime>(lastCycleAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || clockSkewSeconds != null) {
      map['clock_skew_seconds'] = Variable<int>(clockSkewSeconds);
    }
    return map;
  }

  SyncStateEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncStateEntriesCompanion(
      id: Value(id),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      deviceRegistered: Value(deviceRegistered),
      pullCursor: Value(pullCursor),
      bootstrapCompleted: Value(bootstrapCompleted),
      lastPushAt: lastPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushAt),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
      lastCycleAt: lastCycleAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCycleAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      clockSkewSeconds: clockSkewSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(clockSkewSeconds),
    );
  }

  factory SyncStateEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateEntry(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      deviceRegistered: serializer.fromJson<bool>(json['deviceRegistered']),
      pullCursor: serializer.fromJson<int>(json['pullCursor']),
      bootstrapCompleted: serializer.fromJson<bool>(json['bootstrapCompleted']),
      lastPushAt: serializer.fromJson<DateTime?>(json['lastPushAt']),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
      lastCycleAt: serializer.fromJson<DateTime?>(json['lastCycleAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      clockSkewSeconds: serializer.fromJson<int?>(json['clockSkewSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String?>(deviceId),
      'deviceRegistered': serializer.toJson<bool>(deviceRegistered),
      'pullCursor': serializer.toJson<int>(pullCursor),
      'bootstrapCompleted': serializer.toJson<bool>(bootstrapCompleted),
      'lastPushAt': serializer.toJson<DateTime?>(lastPushAt),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
      'lastCycleAt': serializer.toJson<DateTime?>(lastCycleAt),
      'lastError': serializer.toJson<String?>(lastError),
      'clockSkewSeconds': serializer.toJson<int?>(clockSkewSeconds),
    };
  }

  SyncStateEntry copyWith({
    int? id,
    Value<String?> deviceId = const Value.absent(),
    bool? deviceRegistered,
    int? pullCursor,
    bool? bootstrapCompleted,
    Value<DateTime?> lastPushAt = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
    Value<DateTime?> lastCycleAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<int?> clockSkewSeconds = const Value.absent(),
  }) => SyncStateEntry(
    id: id ?? this.id,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    deviceRegistered: deviceRegistered ?? this.deviceRegistered,
    pullCursor: pullCursor ?? this.pullCursor,
    bootstrapCompleted: bootstrapCompleted ?? this.bootstrapCompleted,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    lastCycleAt: lastCycleAt.present ? lastCycleAt.value : this.lastCycleAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    clockSkewSeconds: clockSkewSeconds.present
        ? clockSkewSeconds.value
        : this.clockSkewSeconds,
  );
  SyncStateEntry copyWithCompanion(SyncStateEntriesCompanion data) {
    return SyncStateEntry(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceRegistered: data.deviceRegistered.present
          ? data.deviceRegistered.value
          : this.deviceRegistered,
      pullCursor: data.pullCursor.present
          ? data.pullCursor.value
          : this.pullCursor,
      bootstrapCompleted: data.bootstrapCompleted.present
          ? data.bootstrapCompleted.value
          : this.bootstrapCompleted,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
      lastCycleAt: data.lastCycleAt.present
          ? data.lastCycleAt.value
          : this.lastCycleAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      clockSkewSeconds: data.clockSkewSeconds.present
          ? data.clockSkewSeconds.value
          : this.clockSkewSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateEntry(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceRegistered: $deviceRegistered, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('bootstrapCompleted: $bootstrapCompleted, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastCycleAt: $lastCycleAt, ')
          ..write('lastError: $lastError, ')
          ..write('clockSkewSeconds: $clockSkewSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    deviceRegistered,
    pullCursor,
    bootstrapCompleted,
    lastPushAt,
    lastPullAt,
    lastCycleAt,
    lastError,
    clockSkewSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateEntry &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.deviceRegistered == this.deviceRegistered &&
          other.pullCursor == this.pullCursor &&
          other.bootstrapCompleted == this.bootstrapCompleted &&
          other.lastPushAt == this.lastPushAt &&
          other.lastPullAt == this.lastPullAt &&
          other.lastCycleAt == this.lastCycleAt &&
          other.lastError == this.lastError &&
          other.clockSkewSeconds == this.clockSkewSeconds);
}

class SyncStateEntriesCompanion extends UpdateCompanion<SyncStateEntry> {
  final Value<int> id;
  final Value<String?> deviceId;
  final Value<bool> deviceRegistered;
  final Value<int> pullCursor;
  final Value<bool> bootstrapCompleted;
  final Value<DateTime?> lastPushAt;
  final Value<DateTime?> lastPullAt;
  final Value<DateTime?> lastCycleAt;
  final Value<String?> lastError;
  final Value<int?> clockSkewSeconds;
  const SyncStateEntriesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceRegistered = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.bootstrapCompleted = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastCycleAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.clockSkewSeconds = const Value.absent(),
  });
  SyncStateEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceRegistered = const Value.absent(),
    this.pullCursor = const Value.absent(),
    this.bootstrapCompleted = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastCycleAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.clockSkewSeconds = const Value.absent(),
  });
  static Insertable<SyncStateEntry> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<bool>? deviceRegistered,
    Expression<int>? pullCursor,
    Expression<bool>? bootstrapCompleted,
    Expression<DateTime>? lastPushAt,
    Expression<DateTime>? lastPullAt,
    Expression<DateTime>? lastCycleAt,
    Expression<String>? lastError,
    Expression<int>? clockSkewSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceRegistered != null) 'device_registered': deviceRegistered,
      if (pullCursor != null) 'pull_cursor': pullCursor,
      if (bootstrapCompleted != null) 'bootstrap_completed': bootstrapCompleted,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (lastCycleAt != null) 'last_cycle_at': lastCycleAt,
      if (lastError != null) 'last_error': lastError,
      if (clockSkewSeconds != null) 'clock_skew_seconds': clockSkewSeconds,
    });
  }

  SyncStateEntriesCompanion copyWith({
    Value<int>? id,
    Value<String?>? deviceId,
    Value<bool>? deviceRegistered,
    Value<int>? pullCursor,
    Value<bool>? bootstrapCompleted,
    Value<DateTime?>? lastPushAt,
    Value<DateTime?>? lastPullAt,
    Value<DateTime?>? lastCycleAt,
    Value<String?>? lastError,
    Value<int?>? clockSkewSeconds,
  }) {
    return SyncStateEntriesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceRegistered: deviceRegistered ?? this.deviceRegistered,
      pullCursor: pullCursor ?? this.pullCursor,
      bootstrapCompleted: bootstrapCompleted ?? this.bootstrapCompleted,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      lastCycleAt: lastCycleAt ?? this.lastCycleAt,
      lastError: lastError ?? this.lastError,
      clockSkewSeconds: clockSkewSeconds ?? this.clockSkewSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceRegistered.present) {
      map['device_registered'] = Variable<bool>(deviceRegistered.value);
    }
    if (pullCursor.present) {
      map['pull_cursor'] = Variable<int>(pullCursor.value);
    }
    if (bootstrapCompleted.present) {
      map['bootstrap_completed'] = Variable<bool>(bootstrapCompleted.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (lastCycleAt.present) {
      map['last_cycle_at'] = Variable<DateTime>(lastCycleAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (clockSkewSeconds.present) {
      map['clock_skew_seconds'] = Variable<int>(clockSkewSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateEntriesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceRegistered: $deviceRegistered, ')
          ..write('pullCursor: $pullCursor, ')
          ..write('bootstrapCompleted: $bootstrapCompleted, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastCycleAt: $lastCycleAt, ')
          ..write('lastError: $lastError, ')
          ..write('clockSkewSeconds: $clockSkewSeconds')
          ..write(')'))
        .toString();
  }
}

class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    opId,
    entity,
    opType,
    entityId,
    baseVersion,
    payload,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  /// Orden local monotónico. El servidor aplica el lote siguiendo este número.
  final int seq;

  /// Clave de idempotencia: reintentar la misma op nunca la duplica (D4).
  final String opId;
  final String entity;
  final String opType;
  final String entityId;

  /// Versión conocida al capturar; el servidor la usa para detectar escrituras
  /// sobre datos viejos (D6). Nulo en creaciones.
  final int? baseVersion;

  /// Payload JSON, con el mismo contrato que el endpoint REST equivalente.
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const OutboxEntry({
    required this.seq,
    required this.opId,
    required this.entity,
    required this.opType,
    required this.entityId,
    this.baseVersion,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['op_id'] = Variable<String>(opId);
    map['entity'] = Variable<String>(entity);
    map['op_type'] = Variable<String>(opType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      seq: Value(seq),
      opId: Value(opId),
      entity: Value(entity),
      opType: Value(opType),
      entityId: Value(entityId),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      seq: serializer.fromJson<int>(json['seq']),
      opId: serializer.fromJson<String>(json['opId']),
      entity: serializer.fromJson<String>(json['entity']),
      opType: serializer.fromJson<String>(json['opType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'opId': serializer.toJson<String>(opId),
      'entity': serializer.toJson<String>(entity),
      'opType': serializer.toJson<String>(opType),
      'entityId': serializer.toJson<String>(entityId),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxEntry copyWith({
    int? seq,
    String? opId,
    String? entity,
    String? opType,
    String? entityId,
    Value<int?> baseVersion = const Value.absent(),
    String? payload,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxEntry(
    seq: seq ?? this.seq,
    opId: opId ?? this.opId,
    entity: entity ?? this.entity,
    opType: opType ?? this.opType,
    entityId: entityId ?? this.entityId,
    baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxEntry copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxEntry(
      seq: data.seq.present ? data.seq.value : this.seq,
      opId: data.opId.present ? data.opId.value : this.opId,
      entity: data.entity.present ? data.entity.value : this.entity,
      opType: data.opType.present ? data.opType.value : this.opType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('opType: $opType, ')
          ..write('entityId: $entityId, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    opId,
    entity,
    opType,
    entityId,
    baseVersion,
    payload,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.seq == this.seq &&
          other.opId == this.opId &&
          other.entity == this.entity &&
          other.opType == this.opType &&
          other.entityId == this.entityId &&
          other.baseVersion == this.baseVersion &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> seq;
  final Value<String> opId;
  final Value<String> entity;
  final Value<String> opType;
  final Value<String> entityId;
  final Value<int?> baseVersion;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const OutboxEntriesCompanion({
    this.seq = const Value.absent(),
    this.opId = const Value.absent(),
    this.entity = const Value.absent(),
    this.opType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    this.seq = const Value.absent(),
    required String opId,
    required String entity,
    required String opType,
    required String entityId,
    this.baseVersion = const Value.absent(),
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : opId = Value(opId),
       entity = Value(entity),
       opType = Value(opType),
       entityId = Value(entityId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<int>? seq,
    Expression<String>? opId,
    Expression<String>? entity,
    Expression<String>? opType,
    Expression<String>? entityId,
    Expression<int>? baseVersion,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (opId != null) 'op_id': opId,
      if (entity != null) 'entity': entity,
      if (opType != null) 'op_type': opType,
      if (entityId != null) 'entity_id': entityId,
      if (baseVersion != null) 'base_version': baseVersion,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxEntriesCompanion copyWith({
    Value<int>? seq,
    Value<String>? opId,
    Value<String>? entity,
    Value<String>? opType,
    Value<String>? entityId,
    Value<int?>? baseVersion,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
  }) {
    return OutboxEntriesCompanion(
      seq: seq ?? this.seq,
      opId: opId ?? this.opId,
      entity: entity ?? this.entity,
      opType: opType ?? this.opType,
      entityId: entityId ?? this.entityId,
      baseVersion: baseVersion ?? this.baseVersion,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('seq: $seq, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('opType: $opType, ')
          ..write('entityId: $entityId, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $ReviewEntriesTable extends ReviewEntries
    with TableInfo<$ReviewEntriesTable, ReviewEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPayloadMeta = const VerificationMeta(
    'localPayload',
  );
  @override
  late final GeneratedColumn<String> localPayload = GeneratedColumn<String>(
    'local_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverDataMeta = const VerificationMeta(
    'serverData',
  );
  @override
  late final GeneratedColumn<String> serverData = GeneratedColumn<String>(
    'server_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opId,
    entity,
    opType,
    entityId,
    status,
    reason,
    localPayload,
    serverData,
    serverVersion,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('local_payload')) {
      context.handle(
        _localPayloadMeta,
        localPayload.isAcceptableOrUnknown(
          data['local_payload']!,
          _localPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadMeta);
    }
    if (data.containsKey('server_data')) {
      context.handle(
        _serverDataMeta,
        serverData.isAcceptableOrUnknown(data['server_data']!, _serverDataMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      localPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload'],
      )!,
      serverData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_data'],
      ),
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $ReviewEntriesTable createAlias(String alias) {
    return $ReviewEntriesTable(attachedDatabase, alias);
  }
}

class ReviewEntry extends DataClass implements Insertable<ReviewEntry> {
  final int id;
  final String opId;
  final String entity;
  final String opType;
  final String entityId;

  /// `rejected` o `conflict`.
  final String status;
  final String? reason;
  final String localPayload;
  final String? serverData;
  final int? serverVersion;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const ReviewEntry({
    required this.id,
    required this.opId,
    required this.entity,
    required this.opType,
    required this.entityId,
    required this.status,
    this.reason,
    required this.localPayload,
    this.serverData,
    this.serverVersion,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['op_id'] = Variable<String>(opId);
    map['entity'] = Variable<String>(entity);
    map['op_type'] = Variable<String>(opType);
    map['entity_id'] = Variable<String>(entityId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['local_payload'] = Variable<String>(localPayload);
    if (!nullToAbsent || serverData != null) {
      map['server_data'] = Variable<String>(serverData);
    }
    if (!nullToAbsent || serverVersion != null) {
      map['server_version'] = Variable<int>(serverVersion);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  ReviewEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReviewEntriesCompanion(
      id: Value(id),
      opId: Value(opId),
      entity: Value(entity),
      opType: Value(opType),
      entityId: Value(entityId),
      status: Value(status),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      localPayload: Value(localPayload),
      serverData: serverData == null && nullToAbsent
          ? const Value.absent()
          : Value(serverData),
      serverVersion: serverVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(serverVersion),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory ReviewEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewEntry(
      id: serializer.fromJson<int>(json['id']),
      opId: serializer.fromJson<String>(json['opId']),
      entity: serializer.fromJson<String>(json['entity']),
      opType: serializer.fromJson<String>(json['opType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      status: serializer.fromJson<String>(json['status']),
      reason: serializer.fromJson<String?>(json['reason']),
      localPayload: serializer.fromJson<String>(json['localPayload']),
      serverData: serializer.fromJson<String?>(json['serverData']),
      serverVersion: serializer.fromJson<int?>(json['serverVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'opId': serializer.toJson<String>(opId),
      'entity': serializer.toJson<String>(entity),
      'opType': serializer.toJson<String>(opType),
      'entityId': serializer.toJson<String>(entityId),
      'status': serializer.toJson<String>(status),
      'reason': serializer.toJson<String?>(reason),
      'localPayload': serializer.toJson<String>(localPayload),
      'serverData': serializer.toJson<String?>(serverData),
      'serverVersion': serializer.toJson<int?>(serverVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  ReviewEntry copyWith({
    int? id,
    String? opId,
    String? entity,
    String? opType,
    String? entityId,
    String? status,
    Value<String?> reason = const Value.absent(),
    String? localPayload,
    Value<String?> serverData = const Value.absent(),
    Value<int?> serverVersion = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => ReviewEntry(
    id: id ?? this.id,
    opId: opId ?? this.opId,
    entity: entity ?? this.entity,
    opType: opType ?? this.opType,
    entityId: entityId ?? this.entityId,
    status: status ?? this.status,
    reason: reason.present ? reason.value : this.reason,
    localPayload: localPayload ?? this.localPayload,
    serverData: serverData.present ? serverData.value : this.serverData,
    serverVersion: serverVersion.present
        ? serverVersion.value
        : this.serverVersion,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  ReviewEntry copyWithCompanion(ReviewEntriesCompanion data) {
    return ReviewEntry(
      id: data.id.present ? data.id.value : this.id,
      opId: data.opId.present ? data.opId.value : this.opId,
      entity: data.entity.present ? data.entity.value : this.entity,
      opType: data.opType.present ? data.opType.value : this.opType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      status: data.status.present ? data.status.value : this.status,
      reason: data.reason.present ? data.reason.value : this.reason,
      localPayload: data.localPayload.present
          ? data.localPayload.value
          : this.localPayload,
      serverData: data.serverData.present
          ? data.serverData.value
          : this.serverData,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewEntry(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('opType: $opType, ')
          ..write('entityId: $entityId, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverData: $serverData, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opId,
    entity,
    opType,
    entityId,
    status,
    reason,
    localPayload,
    serverData,
    serverVersion,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewEntry &&
          other.id == this.id &&
          other.opId == this.opId &&
          other.entity == this.entity &&
          other.opType == this.opType &&
          other.entityId == this.entityId &&
          other.status == this.status &&
          other.reason == this.reason &&
          other.localPayload == this.localPayload &&
          other.serverData == this.serverData &&
          other.serverVersion == this.serverVersion &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class ReviewEntriesCompanion extends UpdateCompanion<ReviewEntry> {
  final Value<int> id;
  final Value<String> opId;
  final Value<String> entity;
  final Value<String> opType;
  final Value<String> entityId;
  final Value<String> status;
  final Value<String?> reason;
  final Value<String> localPayload;
  final Value<String?> serverData;
  final Value<int?> serverVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  const ReviewEntriesCompanion({
    this.id = const Value.absent(),
    this.opId = const Value.absent(),
    this.entity = const Value.absent(),
    this.opType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.status = const Value.absent(),
    this.reason = const Value.absent(),
    this.localPayload = const Value.absent(),
    this.serverData = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  ReviewEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String opId,
    required String entity,
    required String opType,
    required String entityId,
    required String status,
    this.reason = const Value.absent(),
    required String localPayload,
    this.serverData = const Value.absent(),
    this.serverVersion = const Value.absent(),
    required DateTime createdAt,
    this.resolvedAt = const Value.absent(),
  }) : opId = Value(opId),
       entity = Value(entity),
       opType = Value(opType),
       entityId = Value(entityId),
       status = Value(status),
       localPayload = Value(localPayload),
       createdAt = Value(createdAt);
  static Insertable<ReviewEntry> custom({
    Expression<int>? id,
    Expression<String>? opId,
    Expression<String>? entity,
    Expression<String>? opType,
    Expression<String>? entityId,
    Expression<String>? status,
    Expression<String>? reason,
    Expression<String>? localPayload,
    Expression<String>? serverData,
    Expression<int>? serverVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opId != null) 'op_id': opId,
      if (entity != null) 'entity': entity,
      if (opType != null) 'op_type': opType,
      if (entityId != null) 'entity_id': entityId,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (localPayload != null) 'local_payload': localPayload,
      if (serverData != null) 'server_data': serverData,
      if (serverVersion != null) 'server_version': serverVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  ReviewEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? opId,
    Value<String>? entity,
    Value<String>? opType,
    Value<String>? entityId,
    Value<String>? status,
    Value<String?>? reason,
    Value<String>? localPayload,
    Value<String?>? serverData,
    Value<int?>? serverVersion,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
  }) {
    return ReviewEntriesCompanion(
      id: id ?? this.id,
      opId: opId ?? this.opId,
      entity: entity ?? this.entity,
      opType: opType ?? this.opType,
      entityId: entityId ?? this.entityId,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      localPayload: localPayload ?? this.localPayload,
      serverData: serverData ?? this.serverData,
      serverVersion: serverVersion ?? this.serverVersion,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (localPayload.present) {
      map['local_payload'] = Variable<String>(localPayload.value);
    }
    if (serverData.present) {
      map['server_data'] = Variable<String>(serverData.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewEntriesCompanion(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('entity: $entity, ')
          ..write('opType: $opType, ')
          ..write('entityId: $entityId, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverData: $serverData, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $DeferredChangesTable extends DeferredChanges
    with TableInfo<$DeferredChangesTable, DeferredChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeferredChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncSeqMeta = const VerificationMeta(
    'syncSeq',
  );
  @override
  late final GeneratedColumn<int> syncSeq = GeneratedColumn<int>(
    'sync_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entity,
    entityId,
    version,
    syncSeq,
    deleted,
    data,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deferred_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeferredChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('sync_seq')) {
      context.handle(
        _syncSeqMeta,
        syncSeq.isAcceptableOrUnknown(data['sync_seq']!, _syncSeqMeta),
      );
    } else if (isInserting) {
      context.missing(_syncSeqMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, entityId};
  @override
  DeferredChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeferredChange(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_seq'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $DeferredChangesTable createAlias(String alias) {
    return $DeferredChangesTable(attachedDatabase, alias);
  }
}

class DeferredChange extends DataClass implements Insertable<DeferredChange> {
  final String entity;
  final String entityId;
  final int version;
  final int syncSeq;
  final bool deleted;
  final String data;
  final DateTime receivedAt;
  const DeferredChange({
    required this.entity,
    required this.entityId,
    required this.version,
    required this.syncSeq,
    required this.deleted,
    required this.data,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['version'] = Variable<int>(version);
    map['sync_seq'] = Variable<int>(syncSeq);
    map['deleted'] = Variable<bool>(deleted);
    map['data'] = Variable<String>(data);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  DeferredChangesCompanion toCompanion(bool nullToAbsent) {
    return DeferredChangesCompanion(
      entity: Value(entity),
      entityId: Value(entityId),
      version: Value(version),
      syncSeq: Value(syncSeq),
      deleted: Value(deleted),
      data: Value(data),
      receivedAt: Value(receivedAt),
    );
  }

  factory DeferredChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeferredChange(
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      version: serializer.fromJson<int>(json['version']),
      syncSeq: serializer.fromJson<int>(json['syncSeq']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      data: serializer.fromJson<String>(json['data']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'version': serializer.toJson<int>(version),
      'syncSeq': serializer.toJson<int>(syncSeq),
      'deleted': serializer.toJson<bool>(deleted),
      'data': serializer.toJson<String>(data),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  DeferredChange copyWith({
    String? entity,
    String? entityId,
    int? version,
    int? syncSeq,
    bool? deleted,
    String? data,
    DateTime? receivedAt,
  }) => DeferredChange(
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    version: version ?? this.version,
    syncSeq: syncSeq ?? this.syncSeq,
    deleted: deleted ?? this.deleted,
    data: data ?? this.data,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  DeferredChange copyWithCompanion(DeferredChangesCompanion data) {
    return DeferredChange(
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      version: data.version.present ? data.version.value : this.version,
      syncSeq: data.syncSeq.present ? data.syncSeq.value : this.syncSeq,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      data: data.data.present ? data.data.value : this.data,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeferredChange(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('version: $version, ')
          ..write('syncSeq: $syncSeq, ')
          ..write('deleted: $deleted, ')
          ..write('data: $data, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entity,
    entityId,
    version,
    syncSeq,
    deleted,
    data,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeferredChange &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.version == this.version &&
          other.syncSeq == this.syncSeq &&
          other.deleted == this.deleted &&
          other.data == this.data &&
          other.receivedAt == this.receivedAt);
}

class DeferredChangesCompanion extends UpdateCompanion<DeferredChange> {
  final Value<String> entity;
  final Value<String> entityId;
  final Value<int> version;
  final Value<int> syncSeq;
  final Value<bool> deleted;
  final Value<String> data;
  final Value<DateTime> receivedAt;
  final Value<int> rowid;
  const DeferredChangesCompanion({
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.version = const Value.absent(),
    this.syncSeq = const Value.absent(),
    this.deleted = const Value.absent(),
    this.data = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeferredChangesCompanion.insert({
    required String entity,
    required String entityId,
    required int version,
    required int syncSeq,
    required bool deleted,
    required String data,
    required DateTime receivedAt,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       entityId = Value(entityId),
       version = Value(version),
       syncSeq = Value(syncSeq),
       deleted = Value(deleted),
       data = Value(data),
       receivedAt = Value(receivedAt);
  static Insertable<DeferredChange> custom({
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<int>? version,
    Expression<int>? syncSeq,
    Expression<bool>? deleted,
    Expression<String>? data,
    Expression<DateTime>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (version != null) 'version': version,
      if (syncSeq != null) 'sync_seq': syncSeq,
      if (deleted != null) 'deleted': deleted,
      if (data != null) 'data': data,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeferredChangesCompanion copyWith({
    Value<String>? entity,
    Value<String>? entityId,
    Value<int>? version,
    Value<int>? syncSeq,
    Value<bool>? deleted,
    Value<String>? data,
    Value<DateTime>? receivedAt,
    Value<int>? rowid,
  }) {
    return DeferredChangesCompanion(
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      version: version ?? this.version,
      syncSeq: syncSeq ?? this.syncSeq,
      deleted: deleted ?? this.deleted,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncSeq.present) {
      map['sync_seq'] = Variable<int>(syncSeq.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeferredChangesCompanion(')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('version: $version, ')
          ..write('syncSeq: $syncSeq, ')
          ..write('deleted: $deleted, ')
          ..write('data: $data, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceTypeEntriesTable extends ServiceTypeEntries
    with TableInfo<$ServiceTypeEntriesTable, ServiceTypeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceTypeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricingModeMeta = const VerificationMeta(
    'pricingMode',
  );
  @override
  late final GeneratedColumn<String> pricingMode = GeneratedColumn<String>(
    'pricing_mode',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitLabelMeta = const VerificationMeta(
    'unitLabel',
  );
  @override
  late final GeneratedColumn<String> unitLabel = GeneratedColumn<String>(
    'unit_label',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 30),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    code,
    name,
    pricingMode,
    unitLabel,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_type_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceTypeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pricing_mode')) {
      context.handle(
        _pricingModeMeta,
        pricingMode.isAcceptableOrUnknown(
          data['pricing_mode']!,
          _pricingModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricingModeMeta);
    }
    if (data.containsKey('unit_label')) {
      context.handle(
        _unitLabelMeta,
        unitLabel.isAcceptableOrUnknown(data['unit_label']!, _unitLabelMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceTypeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceTypeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pricingMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pricing_mode'],
      )!,
      unitLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_label'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ServiceTypeEntriesTable createAlias(String alias) {
    return $ServiceTypeEntriesTable(attachedDatabase, alias);
  }
}

class ServiceTypeEntry extends DataClass
    implements Insertable<ServiceTypeEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String code;
  final String name;

  /// `per_unit`, `tiered` o `variable` (plan 0001 §5.2). Se guarda el string
  /// del servidor tal cual: un enum local obligaría a migrar la BD cada vez que
  /// el catálogo estrene una modalidad.
  final String pricingMode;
  final String? unitLabel;
  final bool isActive;
  final int sortOrder;
  const ServiceTypeEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.code,
    required this.name,
    required this.pricingMode,
    this.unitLabel,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['pricing_mode'] = Variable<String>(pricingMode);
    if (!nullToAbsent || unitLabel != null) {
      map['unit_label'] = Variable<String>(unitLabel);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ServiceTypeEntriesCompanion toCompanion(bool nullToAbsent) {
    return ServiceTypeEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      code: Value(code),
      name: Value(name),
      pricingMode: Value(pricingMode),
      unitLabel: unitLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(unitLabel),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory ServiceTypeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceTypeEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      pricingMode: serializer.fromJson<String>(json['pricingMode']),
      unitLabel: serializer.fromJson<String?>(json['unitLabel']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'pricingMode': serializer.toJson<String>(pricingMode),
      'unitLabel': serializer.toJson<String?>(unitLabel),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ServiceTypeEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? code,
    String? name,
    String? pricingMode,
    Value<String?> unitLabel = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => ServiceTypeEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    code: code ?? this.code,
    name: name ?? this.name,
    pricingMode: pricingMode ?? this.pricingMode,
    unitLabel: unitLabel.present ? unitLabel.value : this.unitLabel,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ServiceTypeEntry copyWithCompanion(ServiceTypeEntriesCompanion data) {
    return ServiceTypeEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      pricingMode: data.pricingMode.present
          ? data.pricingMode.value
          : this.pricingMode,
      unitLabel: data.unitLabel.present ? data.unitLabel.value : this.unitLabel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTypeEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('pricingMode: $pricingMode, ')
          ..write('unitLabel: $unitLabel, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    code,
    name,
    pricingMode,
    unitLabel,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceTypeEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.code == this.code &&
          other.name == this.name &&
          other.pricingMode == this.pricingMode &&
          other.unitLabel == this.unitLabel &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class ServiceTypeEntriesCompanion extends UpdateCompanion<ServiceTypeEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> code;
  final Value<String> name;
  final Value<String> pricingMode;
  final Value<String?> unitLabel;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ServiceTypeEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.pricingMode = const Value.absent(),
    this.unitLabel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceTypeEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String code,
    required String name,
    required String pricingMode,
    this.unitLabel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       pricingMode = Value(pricingMode);
  static Insertable<ServiceTypeEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? pricingMode,
    Expression<String>? unitLabel,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (pricingMode != null) 'pricing_mode': pricingMode,
      if (unitLabel != null) 'unit_label': unitLabel,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceTypeEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? code,
    Value<String>? name,
    Value<String>? pricingMode,
    Value<String?>? unitLabel,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ServiceTypeEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      code: code ?? this.code,
      name: name ?? this.name,
      pricingMode: pricingMode ?? this.pricingMode,
      unitLabel: unitLabel ?? this.unitLabel,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pricingMode.present) {
      map['pricing_mode'] = Variable<String>(pricingMode.value);
    }
    if (unitLabel.present) {
      map['unit_label'] = Variable<String>(unitLabel.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTypeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('pricingMode: $pricingMode, ')
          ..write('unitLabel: $unitLabel, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceOptionEntriesTable extends ServiceOptionEntries
    with TableInfo<$ServiceOptionEntriesTable, ServiceOptionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceOptionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceTypeIdMeta = const VerificationMeta(
    'serviceTypeId',
  );
  @override
  late final GeneratedColumn<String> serviceTypeId = GeneratedColumn<String>(
    'service_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minQuantityMeta = const VerificationMeta(
    'minQuantity',
  );
  @override
  late final GeneratedColumn<int> minQuantity = GeneratedColumn<int>(
    'min_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxQuantityMeta = const VerificationMeta(
    'maxQuantity',
  );
  @override
  late final GeneratedColumn<int> maxQuantity = GeneratedColumn<int>(
    'max_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    serviceTypeId,
    code,
    name,
    minQuantity,
    maxQuantity,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_option_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceOptionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('service_type_id')) {
      context.handle(
        _serviceTypeIdMeta,
        serviceTypeId.isAcceptableOrUnknown(
          data['service_type_id']!,
          _serviceTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('min_quantity')) {
      context.handle(
        _minQuantityMeta,
        minQuantity.isAcceptableOrUnknown(
          data['min_quantity']!,
          _minQuantityMeta,
        ),
      );
    }
    if (data.containsKey('max_quantity')) {
      context.handle(
        _maxQuantityMeta,
        maxQuantity.isAcceptableOrUnknown(
          data['max_quantity']!,
          _maxQuantityMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceOptionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceOptionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serviceTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      minQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_quantity'],
      ),
      maxQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_quantity'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ServiceOptionEntriesTable createAlias(String alias) {
    return $ServiceOptionEntriesTable(attachedDatabase, alias);
  }
}

class ServiceOptionEntry extends DataClass
    implements Insertable<ServiceOptionEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String serviceTypeId;
  final String code;
  final String name;

  /// Rango de piezas que selecciona la opción (lavado a mano N2 = 1 a 4).
  final int? minQuantity;
  final int? maxQuantity;
  final bool isActive;
  final int sortOrder;
  const ServiceOptionEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.serviceTypeId,
    required this.code,
    required this.name,
    this.minQuantity,
    this.maxQuantity,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['service_type_id'] = Variable<String>(serviceTypeId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || minQuantity != null) {
      map['min_quantity'] = Variable<int>(minQuantity);
    }
    if (!nullToAbsent || maxQuantity != null) {
      map['max_quantity'] = Variable<int>(maxQuantity);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ServiceOptionEntriesCompanion toCompanion(bool nullToAbsent) {
    return ServiceOptionEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serviceTypeId: Value(serviceTypeId),
      code: Value(code),
      name: Value(name),
      minQuantity: minQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(minQuantity),
      maxQuantity: maxQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(maxQuantity),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory ServiceOptionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceOptionEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serviceTypeId: serializer.fromJson<String>(json['serviceTypeId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      minQuantity: serializer.fromJson<int?>(json['minQuantity']),
      maxQuantity: serializer.fromJson<int?>(json['maxQuantity']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serviceTypeId': serializer.toJson<String>(serviceTypeId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'minQuantity': serializer.toJson<int?>(minQuantity),
      'maxQuantity': serializer.toJson<int?>(maxQuantity),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ServiceOptionEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? serviceTypeId,
    String? code,
    String? name,
    Value<int?> minQuantity = const Value.absent(),
    Value<int?> maxQuantity = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => ServiceOptionEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serviceTypeId: serviceTypeId ?? this.serviceTypeId,
    code: code ?? this.code,
    name: name ?? this.name,
    minQuantity: minQuantity.present ? minQuantity.value : this.minQuantity,
    maxQuantity: maxQuantity.present ? maxQuantity.value : this.maxQuantity,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ServiceOptionEntry copyWithCompanion(ServiceOptionEntriesCompanion data) {
    return ServiceOptionEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serviceTypeId: data.serviceTypeId.present
          ? data.serviceTypeId.value
          : this.serviceTypeId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      minQuantity: data.minQuantity.present
          ? data.minQuantity.value
          : this.minQuantity,
      maxQuantity: data.maxQuantity.present
          ? data.maxQuantity.value
          : this.maxQuantity,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceOptionEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serviceTypeId: $serviceTypeId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('maxQuantity: $maxQuantity, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    serviceTypeId,
    code,
    name,
    minQuantity,
    maxQuantity,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceOptionEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.serviceTypeId == this.serviceTypeId &&
          other.code == this.code &&
          other.name == this.name &&
          other.minQuantity == this.minQuantity &&
          other.maxQuantity == this.maxQuantity &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class ServiceOptionEntriesCompanion
    extends UpdateCompanion<ServiceOptionEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> serviceTypeId;
  final Value<String> code;
  final Value<String> name;
  final Value<int?> minQuantity;
  final Value<int?> maxQuantity;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ServiceOptionEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serviceTypeId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.minQuantity = const Value.absent(),
    this.maxQuantity = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceOptionEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String serviceTypeId,
    required String code,
    required String name,
    this.minQuantity = const Value.absent(),
    this.maxQuantity = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceTypeId = Value(serviceTypeId),
       code = Value(code),
       name = Value(name);
  static Insertable<ServiceOptionEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? serviceTypeId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? minQuantity,
    Expression<int>? maxQuantity,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serviceTypeId != null) 'service_type_id': serviceTypeId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (maxQuantity != null) 'max_quantity': maxQuantity,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceOptionEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? serviceTypeId,
    Value<String>? code,
    Value<String>? name,
    Value<int?>? minQuantity,
    Value<int?>? maxQuantity,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ServiceOptionEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      code: code ?? this.code,
      name: name ?? this.name,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serviceTypeId.present) {
      map['service_type_id'] = Variable<String>(serviceTypeId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (minQuantity.present) {
      map['min_quantity'] = Variable<int>(minQuantity.value);
    }
    if (maxQuantity.present) {
      map['max_quantity'] = Variable<int>(maxQuantity.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceOptionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serviceTypeId: $serviceTypeId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('minQuantity: $minQuantity, ')
          ..write('maxQuantity: $maxQuantity, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServicePriceEntriesTable extends ServicePriceEntries
    with TableInfo<$ServicePriceEntriesTable, ServicePriceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicePriceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceTypeIdMeta = const VerificationMeta(
    'serviceTypeId',
  );
  @override
  late final GeneratedColumn<String> serviceTypeId = GeneratedColumn<String>(
    'service_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceOptionIdMeta = const VerificationMeta(
    'serviceOptionId',
  );
  @override
  late final GeneratedColumn<String> serviceOptionId = GeneratedColumn<String>(
    'service_option_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
    'price',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<String> validFrom = GeneratedColumn<String>(
    'valid_from',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validToMeta = const VerificationMeta(
    'validTo',
  );
  @override
  late final GeneratedColumn<String> validTo = GeneratedColumn<String>(
    'valid_to',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    serviceTypeId,
    serviceOptionId,
    price,
    validFrom,
    validTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_price_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServicePriceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('service_type_id')) {
      context.handle(
        _serviceTypeIdMeta,
        serviceTypeId.isAcceptableOrUnknown(
          data['service_type_id']!,
          _serviceTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeIdMeta);
    }
    if (data.containsKey('service_option_id')) {
      context.handle(
        _serviceOptionIdMeta,
        serviceOptionId.isAcceptableOrUnknown(
          data['service_option_id']!,
          _serviceOptionIdMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    } else if (isInserting) {
      context.missing(_validFromMeta);
    }
    if (data.containsKey('valid_to')) {
      context.handle(
        _validToMeta,
        validTo.isAcceptableOrUnknown(data['valid_to']!, _validToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServicePriceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServicePriceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      serviceTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type_id'],
      )!,
      serviceOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_option_id'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price'],
      )!,
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_from'],
      )!,
      validTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_to'],
      ),
    );
  }

  @override
  $ServicePriceEntriesTable createAlias(String alias) {
    return $ServicePriceEntriesTable(attachedDatabase, alias);
  }
}

class ServicePriceEntry extends DataClass
    implements Insertable<ServicePriceEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String serviceTypeId;
  final String? serviceOptionId;

  /// Texto, no `real`: un double convierte Q2.50 en algo que no es Q2.50 y el
  /// error aparece meses después en un total. El servidor lo manda como string
  /// por la misma razón.
  final String price;

  /// Fechas de negocio en `YYYY-MM-DD`. No llevan hora ni zona: el día en que
  /// un precio entra en vigor es un dato del local, no un instante UTC.
  final String validFrom;
  final String? validTo;
  const ServicePriceEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.serviceTypeId,
    this.serviceOptionId,
    required this.price,
    required this.validFrom,
    this.validTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['service_type_id'] = Variable<String>(serviceTypeId);
    if (!nullToAbsent || serviceOptionId != null) {
      map['service_option_id'] = Variable<String>(serviceOptionId);
    }
    map['price'] = Variable<String>(price);
    map['valid_from'] = Variable<String>(validFrom);
    if (!nullToAbsent || validTo != null) {
      map['valid_to'] = Variable<String>(validTo);
    }
    return map;
  }

  ServicePriceEntriesCompanion toCompanion(bool nullToAbsent) {
    return ServicePriceEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serviceTypeId: Value(serviceTypeId),
      serviceOptionId: serviceOptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceOptionId),
      price: Value(price),
      validFrom: Value(validFrom),
      validTo: validTo == null && nullToAbsent
          ? const Value.absent()
          : Value(validTo),
    );
  }

  factory ServicePriceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServicePriceEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      serviceTypeId: serializer.fromJson<String>(json['serviceTypeId']),
      serviceOptionId: serializer.fromJson<String?>(json['serviceOptionId']),
      price: serializer.fromJson<String>(json['price']),
      validFrom: serializer.fromJson<String>(json['validFrom']),
      validTo: serializer.fromJson<String?>(json['validTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'serviceTypeId': serializer.toJson<String>(serviceTypeId),
      'serviceOptionId': serializer.toJson<String?>(serviceOptionId),
      'price': serializer.toJson<String>(price),
      'validFrom': serializer.toJson<String>(validFrom),
      'validTo': serializer.toJson<String?>(validTo),
    };
  }

  ServicePriceEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? serviceTypeId,
    Value<String?> serviceOptionId = const Value.absent(),
    String? price,
    String? validFrom,
    Value<String?> validTo = const Value.absent(),
  }) => ServicePriceEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serviceTypeId: serviceTypeId ?? this.serviceTypeId,
    serviceOptionId: serviceOptionId.present
        ? serviceOptionId.value
        : this.serviceOptionId,
    price: price ?? this.price,
    validFrom: validFrom ?? this.validFrom,
    validTo: validTo.present ? validTo.value : this.validTo,
  );
  ServicePriceEntry copyWithCompanion(ServicePriceEntriesCompanion data) {
    return ServicePriceEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serviceTypeId: data.serviceTypeId.present
          ? data.serviceTypeId.value
          : this.serviceTypeId,
      serviceOptionId: data.serviceOptionId.present
          ? data.serviceOptionId.value
          : this.serviceOptionId,
      price: data.price.present ? data.price.value : this.price,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      validTo: data.validTo.present ? data.validTo.value : this.validTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServicePriceEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serviceTypeId: $serviceTypeId, ')
          ..write('serviceOptionId: $serviceOptionId, ')
          ..write('price: $price, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    serviceTypeId,
    serviceOptionId,
    price,
    validFrom,
    validTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServicePriceEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.serviceTypeId == this.serviceTypeId &&
          other.serviceOptionId == this.serviceOptionId &&
          other.price == this.price &&
          other.validFrom == this.validFrom &&
          other.validTo == this.validTo);
}

class ServicePriceEntriesCompanion extends UpdateCompanion<ServicePriceEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> serviceTypeId;
  final Value<String?> serviceOptionId;
  final Value<String> price;
  final Value<String> validFrom;
  final Value<String?> validTo;
  final Value<int> rowid;
  const ServicePriceEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serviceTypeId = const Value.absent(),
    this.serviceOptionId = const Value.absent(),
    this.price = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServicePriceEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String serviceTypeId,
    this.serviceOptionId = const Value.absent(),
    required String price,
    required String validFrom,
    this.validTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceTypeId = Value(serviceTypeId),
       price = Value(price),
       validFrom = Value(validFrom);
  static Insertable<ServicePriceEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? serviceTypeId,
    Expression<String>? serviceOptionId,
    Expression<String>? price,
    Expression<String>? validFrom,
    Expression<String>? validTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serviceTypeId != null) 'service_type_id': serviceTypeId,
      if (serviceOptionId != null) 'service_option_id': serviceOptionId,
      if (price != null) 'price': price,
      if (validFrom != null) 'valid_from': validFrom,
      if (validTo != null) 'valid_to': validTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServicePriceEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? serviceTypeId,
    Value<String?>? serviceOptionId,
    Value<String>? price,
    Value<String>? validFrom,
    Value<String?>? validTo,
    Value<int>? rowid,
  }) {
    return ServicePriceEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceOptionId: serviceOptionId ?? this.serviceOptionId,
      price: price ?? this.price,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (serviceTypeId.present) {
      map['service_type_id'] = Variable<String>(serviceTypeId.value);
    }
    if (serviceOptionId.present) {
      map['service_option_id'] = Variable<String>(serviceOptionId.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<String>(validFrom.value);
    }
    if (validTo.present) {
      map['valid_to'] = Variable<String>(validTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicePriceEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serviceTypeId: $serviceTypeId, ')
          ..write('serviceOptionId: $serviceOptionId, ')
          ..write('price: $price, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GarmentTypeEntriesTable extends GarmentTypeEntries
    with TableInfo<$GarmentTypeEntriesTable, GarmentTypeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarmentTypeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    name,
    notes,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garment_type_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarmentTypeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GarmentTypeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarmentTypeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GarmentTypeEntriesTable createAlias(String alias) {
    return $GarmentTypeEntriesTable(attachedDatabase, alias);
  }
}

class GarmentTypeEntry extends DataClass
    implements Insertable<GarmentTypeEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String name;
  final String? notes;
  final bool isActive;
  final int sortOrder;
  const GarmentTypeEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.name,
    this.notes,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GarmentTypeEntriesCompanion toCompanion(bool nullToAbsent) {
    return GarmentTypeEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory GarmentTypeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarmentTypeEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  GarmentTypeEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => GarmentTypeEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  GarmentTypeEntry copyWithCompanion(GarmentTypeEntriesCompanion data) {
    return GarmentTypeEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarmentTypeEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    name,
    notes,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarmentTypeEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class GarmentTypeEntriesCompanion extends UpdateCompanion<GarmentTypeEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const GarmentTypeEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GarmentTypeEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<GarmentTypeEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GarmentTypeEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return GarmentTypeEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarmentTypeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerEntriesTable extends CustomerEntries
    with TableInfo<$CustomerEntriesTable, CustomerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nitMeta = const VerificationMeta('nit');
  @override
  late final GeneratedColumn<String> nit = GeneratedColumn<String>(
    'nit',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 320),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _searchIndexMeta = const VerificationMeta(
    'searchIndex',
  );
  @override
  late final GeneratedColumn<String> searchIndex = GeneratedColumn<String>(
    'search_index',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    fullName,
    phone,
    nit,
    email,
    address,
    notes,
    isActive,
    searchIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('nit')) {
      context.handle(
        _nitMeta,
        nit.isAcceptableOrUnknown(data['nit']!, _nitMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('search_index')) {
      context.handle(
        _searchIndexMeta,
        searchIndex.isAcceptableOrUnknown(
          data['search_index']!,
          _searchIndexMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      nit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nit'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      searchIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_index'],
      )!,
    );
  }

  @override
  $CustomerEntriesTable createAlias(String alias) {
    return $CustomerEntriesTable(attachedDatabase, alias);
  }
}

class CustomerEntry extends DataClass implements Insertable<CustomerEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String fullName;
  final String? phone;
  final String? nit;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;

  /// `full_name` y `phone` en minúsculas y sin acentos, para que la búsqueda del
  /// mostrador encuentre "Perez" escribiendo "pérez" y al revés. Se calcula al
  /// escribir porque SQLite no trae `unaccent` ni una collation que sirva.
  final String searchIndex;
  const CustomerEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.fullName,
    this.phone,
    this.nit,
    this.email,
    this.address,
    this.notes,
    required this.isActive,
    required this.searchIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || nit != null) {
      map['nit'] = Variable<String>(nit);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['search_index'] = Variable<String>(searchIndex);
    return map;
  }

  CustomerEntriesCompanion toCompanion(bool nullToAbsent) {
    return CustomerEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fullName: Value(fullName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      nit: nit == null && nullToAbsent ? const Value.absent() : Value(nit),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      searchIndex: Value(searchIndex),
    );
  }

  factory CustomerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      nit: serializer.fromJson<String?>(json['nit']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      searchIndex: serializer.fromJson<String>(json['searchIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'nit': serializer.toJson<String?>(nit),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'searchIndex': serializer.toJson<String>(searchIndex),
    };
  }

  CustomerEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? fullName,
    Value<String?> phone = const Value.absent(),
    Value<String?> nit = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    String? searchIndex,
  }) => CustomerEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fullName: fullName ?? this.fullName,
    phone: phone.present ? phone.value : this.phone,
    nit: nit.present ? nit.value : this.nit,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    searchIndex: searchIndex ?? this.searchIndex,
  );
  CustomerEntry copyWithCompanion(CustomerEntriesCompanion data) {
    return CustomerEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      nit: data.nit.present ? data.nit.value : this.nit,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      searchIndex: data.searchIndex.present
          ? data.searchIndex.value
          : this.searchIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('nit: $nit, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('searchIndex: $searchIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    fullName,
    phone,
    nit,
    email,
    address,
    notes,
    isActive,
    searchIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.nit == this.nit &&
          other.email == this.email &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.searchIndex == this.searchIndex);
}

class CustomerEntriesCompanion extends UpdateCompanion<CustomerEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<String?> nit;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<String> searchIndex;
  final Value<int> rowid;
  const CustomerEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.nit = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.searchIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String fullName,
    this.phone = const Value.absent(),
    this.nit = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.searchIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName);
  static Insertable<CustomerEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? nit,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<String>? searchIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (nit != null) 'nit': nit,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (searchIndex != null) 'search_index': searchIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? fullName,
    Value<String?>? phone,
    Value<String?>? nit,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<String>? searchIndex,
    Value<int>? rowid,
  }) {
    return CustomerEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nit: nit ?? this.nit,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      searchIndex: searchIndex ?? this.searchIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (nit.present) {
      map['nit'] = Variable<String>(nit.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (searchIndex.present) {
      map['search_index'] = Variable<String>(searchIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('nit: $nit, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('searchIndex: $searchIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderEntriesTable extends OrderEntries
    with TableInfo<$OrderEntriesTable, OrderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderDateMeta = const VerificationMeta(
    'orderDate',
  );
  @override
  late final GeneratedColumn<String> orderDate = GeneratedColumn<String>(
    'order_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyNumberMeta = const VerificationMeta(
    'dailyNumber',
  );
  @override
  late final GeneratedColumn<int> dailyNumber = GeneratedColumn<int>(
    'daily_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookletSerialMeta = const VerificationMeta(
    'bookletSerial',
  );
  @override
  late final GeneratedColumn<String> bookletSerial = GeneratedColumn<String>(
    'booklet_serial',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nitMeta = const VerificationMeta('nit');
  @override
  late final GeneratedColumn<String> nit = GeneratedColumn<String>(
    'nit',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightLbsMeta = const VerificationMeta(
    'weightLbs',
  );
  @override
  late final GeneratedColumn<String> weightLbs = GeneratedColumn<String>(
    'weight_lbs',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPiecesMeta = const VerificationMeta(
    'totalPieces',
  );
  @override
  late final GeneratedColumn<int> totalPieces = GeneratedColumn<int>(
    'total_pieces',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<String> subtotal = GeneratedColumn<String>(
    'subtotal',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountTotalMeta = const VerificationMeta(
    'discountTotal',
  );
  @override
  late final GeneratedColumn<String> discountTotal = GeneratedColumn<String>(
    'discount_total',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<String> total = GeneratedColumn<String>(
    'total',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedByIdMeta = const VerificationMeta(
    'receivedById',
  );
  @override
  late final GeneratedColumn<String> receivedById = GeneratedColumn<String>(
    'received_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredByIdMeta = const VerificationMeta(
    'deliveredById',
  );
  @override
  late final GeneratedColumn<String> deliveredById = GeneratedColumn<String>(
    'delivered_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledByIdMeta = const VerificationMeta(
    'cancelledById',
  );
  @override
  late final GeneratedColumn<String> cancelledById = GeneratedColumn<String>(
    'cancelled_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonMeta = const VerificationMeta(
    'cancelReason',
  );
  @override
  late final GeneratedColumn<String> cancelReason = GeneratedColumn<String>(
    'cancel_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    orderDate,
    dailyNumber,
    bookletSerial,
    customerId,
    nit,
    weightLbs,
    totalPieces,
    observations,
    status,
    subtotal,
    discountTotal,
    total,
    receivedById,
    deliveredAt,
    deliveredById,
    cancelledAt,
    cancelledById,
    cancelReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_date')) {
      context.handle(
        _orderDateMeta,
        orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta),
      );
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('daily_number')) {
      context.handle(
        _dailyNumberMeta,
        dailyNumber.isAcceptableOrUnknown(
          data['daily_number']!,
          _dailyNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyNumberMeta);
    }
    if (data.containsKey('booklet_serial')) {
      context.handle(
        _bookletSerialMeta,
        bookletSerial.isAcceptableOrUnknown(
          data['booklet_serial']!,
          _bookletSerialMeta,
        ),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('nit')) {
      context.handle(
        _nitMeta,
        nit.isAcceptableOrUnknown(data['nit']!, _nitMeta),
      );
    }
    if (data.containsKey('weight_lbs')) {
      context.handle(
        _weightLbsMeta,
        weightLbs.isAcceptableOrUnknown(data['weight_lbs']!, _weightLbsMeta),
      );
    }
    if (data.containsKey('total_pieces')) {
      context.handle(
        _totalPiecesMeta,
        totalPieces.isAcceptableOrUnknown(
          data['total_pieces']!,
          _totalPiecesMeta,
        ),
      );
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount_total')) {
      context.handle(
        _discountTotalMeta,
        discountTotal.isAcceptableOrUnknown(
          data['discount_total']!,
          _discountTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountTotalMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('received_by_id')) {
      context.handle(
        _receivedByIdMeta,
        receivedById.isAcceptableOrUnknown(
          data['received_by_id']!,
          _receivedByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedByIdMeta);
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('delivered_by_id')) {
      context.handle(
        _deliveredByIdMeta,
        deliveredById.isAcceptableOrUnknown(
          data['delivered_by_id']!,
          _deliveredByIdMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_by_id')) {
      context.handle(
        _cancelledByIdMeta,
        cancelledById.isAcceptableOrUnknown(
          data['cancelled_by_id']!,
          _cancelledByIdMeta,
        ),
      );
    }
    if (data.containsKey('cancel_reason')) {
      context.handle(
        _cancelReasonMeta,
        cancelReason.isAcceptableOrUnknown(
          data['cancel_reason']!,
          _cancelReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      orderDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_date'],
      )!,
      dailyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_number'],
      )!,
      bookletSerial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booklet_serial'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      nit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nit'],
      ),
      weightLbs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_lbs'],
      ),
      totalPieces: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pieces'],
      )!,
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtotal'],
      )!,
      discountTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_total'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total'],
      )!,
      receivedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_by_id'],
      )!,
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivered_at'],
      ),
      deliveredById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivered_by_id'],
      ),
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      cancelledById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancelled_by_id'],
      ),
      cancelReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $OrderEntriesTable createAlias(String alias) {
    return $OrderEntriesTable(attachedDatabase, alias);
  }
}

class OrderEntry extends DataClass implements Insertable<OrderEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;

  /// Fecha de negocio en `YYYY-MM-DD` (D8). Sin hora ni zona: el día al que
  /// pertenece un pedido es un dato del local, no un instante UTC.
  final String orderDate;

  /// Correlativo del día, el número que la gente dice en voz alta.
  final int dailyNumber;
  final String? bookletSerial;
  final String customerId;
  final String? nit;
  final String? weightLbs;
  final int totalPieces;
  final String? observations;

  /// `received`, `in_progress`, `ready`, `delivered` o `cancelled`. String y no
  /// enum local: el ciclo de vida lo define el servidor, y un enum obligaría a
  /// migrar la BD el día que estrene un estado.
  final String status;
  final String subtotal;
  final String discountTotal;
  final String total;
  final String receivedById;
  final DateTime? deliveredAt;
  final String? deliveredById;
  final DateTime? cancelledAt;
  final String? cancelledById;
  final String? cancelReason;

  /// Hora a la que se recibió la boleta. Anulable porque las filas que ya
  /// estaban en el dispositivo antes de que este campo viajara no la tienen, y
  /// porque no vale la pena inventarles una.
  final DateTime? createdAt;
  const OrderEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.orderDate,
    required this.dailyNumber,
    this.bookletSerial,
    required this.customerId,
    this.nit,
    this.weightLbs,
    required this.totalPieces,
    this.observations,
    required this.status,
    required this.subtotal,
    required this.discountTotal,
    required this.total,
    required this.receivedById,
    this.deliveredAt,
    this.deliveredById,
    this.cancelledAt,
    this.cancelledById,
    this.cancelReason,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order_date'] = Variable<String>(orderDate);
    map['daily_number'] = Variable<int>(dailyNumber);
    if (!nullToAbsent || bookletSerial != null) {
      map['booklet_serial'] = Variable<String>(bookletSerial);
    }
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || nit != null) {
      map['nit'] = Variable<String>(nit);
    }
    if (!nullToAbsent || weightLbs != null) {
      map['weight_lbs'] = Variable<String>(weightLbs);
    }
    map['total_pieces'] = Variable<int>(totalPieces);
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    map['status'] = Variable<String>(status);
    map['subtotal'] = Variable<String>(subtotal);
    map['discount_total'] = Variable<String>(discountTotal);
    map['total'] = Variable<String>(total);
    map['received_by_id'] = Variable<String>(receivedById);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    if (!nullToAbsent || deliveredById != null) {
      map['delivered_by_id'] = Variable<String>(deliveredById);
    }
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || cancelledById != null) {
      map['cancelled_by_id'] = Variable<String>(cancelledById);
    }
    if (!nullToAbsent || cancelReason != null) {
      map['cancel_reason'] = Variable<String>(cancelReason);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  OrderEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderDate: Value(orderDate),
      dailyNumber: Value(dailyNumber),
      bookletSerial: bookletSerial == null && nullToAbsent
          ? const Value.absent()
          : Value(bookletSerial),
      customerId: Value(customerId),
      nit: nit == null && nullToAbsent ? const Value.absent() : Value(nit),
      weightLbs: weightLbs == null && nullToAbsent
          ? const Value.absent()
          : Value(weightLbs),
      totalPieces: Value(totalPieces),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      status: Value(status),
      subtotal: Value(subtotal),
      discountTotal: Value(discountTotal),
      total: Value(total),
      receivedById: Value(receivedById),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      deliveredById: deliveredById == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredById),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      cancelledById: cancelledById == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledById),
      cancelReason: cancelReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReason),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory OrderEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      orderDate: serializer.fromJson<String>(json['orderDate']),
      dailyNumber: serializer.fromJson<int>(json['dailyNumber']),
      bookletSerial: serializer.fromJson<String?>(json['bookletSerial']),
      customerId: serializer.fromJson<String>(json['customerId']),
      nit: serializer.fromJson<String?>(json['nit']),
      weightLbs: serializer.fromJson<String?>(json['weightLbs']),
      totalPieces: serializer.fromJson<int>(json['totalPieces']),
      observations: serializer.fromJson<String?>(json['observations']),
      status: serializer.fromJson<String>(json['status']),
      subtotal: serializer.fromJson<String>(json['subtotal']),
      discountTotal: serializer.fromJson<String>(json['discountTotal']),
      total: serializer.fromJson<String>(json['total']),
      receivedById: serializer.fromJson<String>(json['receivedById']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
      deliveredById: serializer.fromJson<String?>(json['deliveredById']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      cancelledById: serializer.fromJson<String?>(json['cancelledById']),
      cancelReason: serializer.fromJson<String?>(json['cancelReason']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'orderDate': serializer.toJson<String>(orderDate),
      'dailyNumber': serializer.toJson<int>(dailyNumber),
      'bookletSerial': serializer.toJson<String?>(bookletSerial),
      'customerId': serializer.toJson<String>(customerId),
      'nit': serializer.toJson<String?>(nit),
      'weightLbs': serializer.toJson<String?>(weightLbs),
      'totalPieces': serializer.toJson<int>(totalPieces),
      'observations': serializer.toJson<String?>(observations),
      'status': serializer.toJson<String>(status),
      'subtotal': serializer.toJson<String>(subtotal),
      'discountTotal': serializer.toJson<String>(discountTotal),
      'total': serializer.toJson<String>(total),
      'receivedById': serializer.toJson<String>(receivedById),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
      'deliveredById': serializer.toJson<String?>(deliveredById),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'cancelledById': serializer.toJson<String?>(cancelledById),
      'cancelReason': serializer.toJson<String?>(cancelReason),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  OrderEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? orderDate,
    int? dailyNumber,
    Value<String?> bookletSerial = const Value.absent(),
    String? customerId,
    Value<String?> nit = const Value.absent(),
    Value<String?> weightLbs = const Value.absent(),
    int? totalPieces,
    Value<String?> observations = const Value.absent(),
    String? status,
    String? subtotal,
    String? discountTotal,
    String? total,
    String? receivedById,
    Value<DateTime?> deliveredAt = const Value.absent(),
    Value<String?> deliveredById = const Value.absent(),
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> cancelledById = const Value.absent(),
    Value<String?> cancelReason = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => OrderEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderDate: orderDate ?? this.orderDate,
    dailyNumber: dailyNumber ?? this.dailyNumber,
    bookletSerial: bookletSerial.present
        ? bookletSerial.value
        : this.bookletSerial,
    customerId: customerId ?? this.customerId,
    nit: nit.present ? nit.value : this.nit,
    weightLbs: weightLbs.present ? weightLbs.value : this.weightLbs,
    totalPieces: totalPieces ?? this.totalPieces,
    observations: observations.present ? observations.value : this.observations,
    status: status ?? this.status,
    subtotal: subtotal ?? this.subtotal,
    discountTotal: discountTotal ?? this.discountTotal,
    total: total ?? this.total,
    receivedById: receivedById ?? this.receivedById,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    deliveredById: deliveredById.present
        ? deliveredById.value
        : this.deliveredById,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    cancelledById: cancelledById.present
        ? cancelledById.value
        : this.cancelledById,
    cancelReason: cancelReason.present ? cancelReason.value : this.cancelReason,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  OrderEntry copyWithCompanion(OrderEntriesCompanion data) {
    return OrderEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      dailyNumber: data.dailyNumber.present
          ? data.dailyNumber.value
          : this.dailyNumber,
      bookletSerial: data.bookletSerial.present
          ? data.bookletSerial.value
          : this.bookletSerial,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      nit: data.nit.present ? data.nit.value : this.nit,
      weightLbs: data.weightLbs.present ? data.weightLbs.value : this.weightLbs,
      totalPieces: data.totalPieces.present
          ? data.totalPieces.value
          : this.totalPieces,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      status: data.status.present ? data.status.value : this.status,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountTotal: data.discountTotal.present
          ? data.discountTotal.value
          : this.discountTotal,
      total: data.total.present ? data.total.value : this.total,
      receivedById: data.receivedById.present
          ? data.receivedById.value
          : this.receivedById,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      deliveredById: data.deliveredById.present
          ? data.deliveredById.value
          : this.deliveredById,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      cancelledById: data.cancelledById.present
          ? data.cancelledById.value
          : this.cancelledById,
      cancelReason: data.cancelReason.present
          ? data.cancelReason.value
          : this.cancelReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderDate: $orderDate, ')
          ..write('dailyNumber: $dailyNumber, ')
          ..write('bookletSerial: $bookletSerial, ')
          ..write('customerId: $customerId, ')
          ..write('nit: $nit, ')
          ..write('weightLbs: $weightLbs, ')
          ..write('totalPieces: $totalPieces, ')
          ..write('observations: $observations, ')
          ..write('status: $status, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountTotal: $discountTotal, ')
          ..write('total: $total, ')
          ..write('receivedById: $receivedById, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('deliveredById: $deliveredById, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelledById: $cancelledById, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    version,
    syncStatus,
    deletedAt,
    orderDate,
    dailyNumber,
    bookletSerial,
    customerId,
    nit,
    weightLbs,
    totalPieces,
    observations,
    status,
    subtotal,
    discountTotal,
    total,
    receivedById,
    deliveredAt,
    deliveredById,
    cancelledAt,
    cancelledById,
    cancelReason,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.orderDate == this.orderDate &&
          other.dailyNumber == this.dailyNumber &&
          other.bookletSerial == this.bookletSerial &&
          other.customerId == this.customerId &&
          other.nit == this.nit &&
          other.weightLbs == this.weightLbs &&
          other.totalPieces == this.totalPieces &&
          other.observations == this.observations &&
          other.status == this.status &&
          other.subtotal == this.subtotal &&
          other.discountTotal == this.discountTotal &&
          other.total == this.total &&
          other.receivedById == this.receivedById &&
          other.deliveredAt == this.deliveredAt &&
          other.deliveredById == this.deliveredById &&
          other.cancelledAt == this.cancelledAt &&
          other.cancelledById == this.cancelledById &&
          other.cancelReason == this.cancelReason &&
          other.createdAt == this.createdAt);
}

class OrderEntriesCompanion extends UpdateCompanion<OrderEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> orderDate;
  final Value<int> dailyNumber;
  final Value<String?> bookletSerial;
  final Value<String> customerId;
  final Value<String?> nit;
  final Value<String?> weightLbs;
  final Value<int> totalPieces;
  final Value<String?> observations;
  final Value<String> status;
  final Value<String> subtotal;
  final Value<String> discountTotal;
  final Value<String> total;
  final Value<String> receivedById;
  final Value<DateTime?> deliveredAt;
  final Value<String?> deliveredById;
  final Value<DateTime?> cancelledAt;
  final Value<String?> cancelledById;
  final Value<String?> cancelReason;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const OrderEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.dailyNumber = const Value.absent(),
    this.bookletSerial = const Value.absent(),
    this.customerId = const Value.absent(),
    this.nit = const Value.absent(),
    this.weightLbs = const Value.absent(),
    this.totalPieces = const Value.absent(),
    this.observations = const Value.absent(),
    this.status = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountTotal = const Value.absent(),
    this.total = const Value.absent(),
    this.receivedById = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.deliveredById = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelledById = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String orderDate,
    required int dailyNumber,
    this.bookletSerial = const Value.absent(),
    required String customerId,
    this.nit = const Value.absent(),
    this.weightLbs = const Value.absent(),
    this.totalPieces = const Value.absent(),
    this.observations = const Value.absent(),
    required String status,
    required String subtotal,
    required String discountTotal,
    required String total,
    required String receivedById,
    this.deliveredAt = const Value.absent(),
    this.deliveredById = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelledById = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderDate = Value(orderDate),
       dailyNumber = Value(dailyNumber),
       customerId = Value(customerId),
       status = Value(status),
       subtotal = Value(subtotal),
       discountTotal = Value(discountTotal),
       total = Value(total),
       receivedById = Value(receivedById);
  static Insertable<OrderEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? orderDate,
    Expression<int>? dailyNumber,
    Expression<String>? bookletSerial,
    Expression<String>? customerId,
    Expression<String>? nit,
    Expression<String>? weightLbs,
    Expression<int>? totalPieces,
    Expression<String>? observations,
    Expression<String>? status,
    Expression<String>? subtotal,
    Expression<String>? discountTotal,
    Expression<String>? total,
    Expression<String>? receivedById,
    Expression<DateTime>? deliveredAt,
    Expression<String>? deliveredById,
    Expression<DateTime>? cancelledAt,
    Expression<String>? cancelledById,
    Expression<String>? cancelReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderDate != null) 'order_date': orderDate,
      if (dailyNumber != null) 'daily_number': dailyNumber,
      if (bookletSerial != null) 'booklet_serial': bookletSerial,
      if (customerId != null) 'customer_id': customerId,
      if (nit != null) 'nit': nit,
      if (weightLbs != null) 'weight_lbs': weightLbs,
      if (totalPieces != null) 'total_pieces': totalPieces,
      if (observations != null) 'observations': observations,
      if (status != null) 'status': status,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountTotal != null) 'discount_total': discountTotal,
      if (total != null) 'total': total,
      if (receivedById != null) 'received_by_id': receivedById,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (deliveredById != null) 'delivered_by_id': deliveredById,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cancelledById != null) 'cancelled_by_id': cancelledById,
      if (cancelReason != null) 'cancel_reason': cancelReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? orderDate,
    Value<int>? dailyNumber,
    Value<String?>? bookletSerial,
    Value<String>? customerId,
    Value<String?>? nit,
    Value<String?>? weightLbs,
    Value<int>? totalPieces,
    Value<String?>? observations,
    Value<String>? status,
    Value<String>? subtotal,
    Value<String>? discountTotal,
    Value<String>? total,
    Value<String>? receivedById,
    Value<DateTime?>? deliveredAt,
    Value<String?>? deliveredById,
    Value<DateTime?>? cancelledAt,
    Value<String?>? cancelledById,
    Value<String?>? cancelReason,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return OrderEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      orderDate: orderDate ?? this.orderDate,
      dailyNumber: dailyNumber ?? this.dailyNumber,
      bookletSerial: bookletSerial ?? this.bookletSerial,
      customerId: customerId ?? this.customerId,
      nit: nit ?? this.nit,
      weightLbs: weightLbs ?? this.weightLbs,
      totalPieces: totalPieces ?? this.totalPieces,
      observations: observations ?? this.observations,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      discountTotal: discountTotal ?? this.discountTotal,
      total: total ?? this.total,
      receivedById: receivedById ?? this.receivedById,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveredById: deliveredById ?? this.deliveredById,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledById: cancelledById ?? this.cancelledById,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<String>(orderDate.value);
    }
    if (dailyNumber.present) {
      map['daily_number'] = Variable<int>(dailyNumber.value);
    }
    if (bookletSerial.present) {
      map['booklet_serial'] = Variable<String>(bookletSerial.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (nit.present) {
      map['nit'] = Variable<String>(nit.value);
    }
    if (weightLbs.present) {
      map['weight_lbs'] = Variable<String>(weightLbs.value);
    }
    if (totalPieces.present) {
      map['total_pieces'] = Variable<int>(totalPieces.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<String>(subtotal.value);
    }
    if (discountTotal.present) {
      map['discount_total'] = Variable<String>(discountTotal.value);
    }
    if (total.present) {
      map['total'] = Variable<String>(total.value);
    }
    if (receivedById.present) {
      map['received_by_id'] = Variable<String>(receivedById.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (deliveredById.present) {
      map['delivered_by_id'] = Variable<String>(deliveredById.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (cancelledById.present) {
      map['cancelled_by_id'] = Variable<String>(cancelledById.value);
    }
    if (cancelReason.present) {
      map['cancel_reason'] = Variable<String>(cancelReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderDate: $orderDate, ')
          ..write('dailyNumber: $dailyNumber, ')
          ..write('bookletSerial: $bookletSerial, ')
          ..write('customerId: $customerId, ')
          ..write('nit: $nit, ')
          ..write('weightLbs: $weightLbs, ')
          ..write('totalPieces: $totalPieces, ')
          ..write('observations: $observations, ')
          ..write('status: $status, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountTotal: $discountTotal, ')
          ..write('total: $total, ')
          ..write('receivedById: $receivedById, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('deliveredById: $deliveredById, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelledById: $cancelledById, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderGarmentEntriesTable extends OrderGarmentEntries
    with TableInfo<$OrderGarmentEntriesTable, OrderGarmentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderGarmentEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _garmentTypeIdMeta = const VerificationMeta(
    'garmentTypeId',
  );
  @override
  late final GeneratedColumn<String> garmentTypeId = GeneratedColumn<String>(
    'garment_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityDeliveredMeta = const VerificationMeta(
    'quantityDelivered',
  );
  @override
  late final GeneratedColumn<int> quantityDelivered = GeneratedColumn<int>(
    'quantity_delivered',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    garmentTypeId,
    quantity,
    quantityDelivered,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_garment_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderGarmentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('garment_type_id')) {
      context.handle(
        _garmentTypeIdMeta,
        garmentTypeId.isAcceptableOrUnknown(
          data['garment_type_id']!,
          _garmentTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_garmentTypeIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('quantity_delivered')) {
      context.handle(
        _quantityDeliveredMeta,
        quantityDelivered.isAcceptableOrUnknown(
          data['quantity_delivered']!,
          _quantityDeliveredMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderGarmentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderGarmentEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      garmentTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}garment_type_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      quantityDelivered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_delivered'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $OrderGarmentEntriesTable createAlias(String alias) {
    return $OrderGarmentEntriesTable(attachedDatabase, alias);
  }
}

class OrderGarmentEntry extends DataClass
    implements Insertable<OrderGarmentEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String orderId;
  final String garmentTypeId;
  final int quantity;

  /// Se llena al entregar; el hueco contra `quantity` es la pérdida.
  final int? quantityDelivered;
  final String? notes;
  const OrderGarmentEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.orderId,
    required this.garmentTypeId,
    required this.quantity,
    this.quantityDelivered,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['garment_type_id'] = Variable<String>(garmentTypeId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || quantityDelivered != null) {
      map['quantity_delivered'] = Variable<int>(quantityDelivered);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  OrderGarmentEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderGarmentEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      garmentTypeId: Value(garmentTypeId),
      quantity: Value(quantity),
      quantityDelivered: quantityDelivered == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityDelivered),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory OrderGarmentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderGarmentEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      garmentTypeId: serializer.fromJson<String>(json['garmentTypeId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      quantityDelivered: serializer.fromJson<int?>(json['quantityDelivered']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'garmentTypeId': serializer.toJson<String>(garmentTypeId),
      'quantity': serializer.toJson<int>(quantity),
      'quantityDelivered': serializer.toJson<int?>(quantityDelivered),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  OrderGarmentEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? orderId,
    String? garmentTypeId,
    int? quantity,
    Value<int?> quantityDelivered = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => OrderGarmentEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    garmentTypeId: garmentTypeId ?? this.garmentTypeId,
    quantity: quantity ?? this.quantity,
    quantityDelivered: quantityDelivered.present
        ? quantityDelivered.value
        : this.quantityDelivered,
    notes: notes.present ? notes.value : this.notes,
  );
  OrderGarmentEntry copyWithCompanion(OrderGarmentEntriesCompanion data) {
    return OrderGarmentEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      garmentTypeId: data.garmentTypeId.present
          ? data.garmentTypeId.value
          : this.garmentTypeId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      quantityDelivered: data.quantityDelivered.present
          ? data.quantityDelivered.value
          : this.quantityDelivered,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderGarmentEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('garmentTypeId: $garmentTypeId, ')
          ..write('quantity: $quantity, ')
          ..write('quantityDelivered: $quantityDelivered, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    garmentTypeId,
    quantity,
    quantityDelivered,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderGarmentEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.garmentTypeId == this.garmentTypeId &&
          other.quantity == this.quantity &&
          other.quantityDelivered == this.quantityDelivered &&
          other.notes == this.notes);
}

class OrderGarmentEntriesCompanion extends UpdateCompanion<OrderGarmentEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> orderId;
  final Value<String> garmentTypeId;
  final Value<int> quantity;
  final Value<int?> quantityDelivered;
  final Value<String?> notes;
  final Value<int> rowid;
  const OrderGarmentEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.garmentTypeId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quantityDelivered = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderGarmentEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String orderId,
    required String garmentTypeId,
    required int quantity,
    this.quantityDelivered = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       garmentTypeId = Value(garmentTypeId),
       quantity = Value(quantity);
  static Insertable<OrderGarmentEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? garmentTypeId,
    Expression<int>? quantity,
    Expression<int>? quantityDelivered,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (garmentTypeId != null) 'garment_type_id': garmentTypeId,
      if (quantity != null) 'quantity': quantity,
      if (quantityDelivered != null) 'quantity_delivered': quantityDelivered,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderGarmentEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? orderId,
    Value<String>? garmentTypeId,
    Value<int>? quantity,
    Value<int?>? quantityDelivered,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return OrderGarmentEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      garmentTypeId: garmentTypeId ?? this.garmentTypeId,
      quantity: quantity ?? this.quantity,
      quantityDelivered: quantityDelivered ?? this.quantityDelivered,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (garmentTypeId.present) {
      map['garment_type_id'] = Variable<String>(garmentTypeId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (quantityDelivered.present) {
      map['quantity_delivered'] = Variable<int>(quantityDelivered.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderGarmentEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('garmentTypeId: $garmentTypeId, ')
          ..write('quantity: $quantity, ')
          ..write('quantityDelivered: $quantityDelivered, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderChargeEntriesTable extends OrderChargeEntries
    with TableInfo<$OrderChargeEntriesTable, OrderChargeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderChargeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceTypeIdMeta = const VerificationMeta(
    'serviceTypeId',
  );
  @override
  late final GeneratedColumn<String> serviceTypeId = GeneratedColumn<String>(
    'service_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceOptionIdMeta = const VerificationMeta(
    'serviceOptionId',
  );
  @override
  late final GeneratedColumn<String> serviceOptionId = GeneratedColumn<String>(
    'service_option_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
    'unit_price',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    serviceTypeId,
    serviceOptionId,
    description,
    quantity,
    unitPrice,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_charge_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderChargeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('service_type_id')) {
      context.handle(
        _serviceTypeIdMeta,
        serviceTypeId.isAcceptableOrUnknown(
          data['service_type_id']!,
          _serviceTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeIdMeta);
    }
    if (data.containsKey('service_option_id')) {
      context.handle(
        _serviceOptionIdMeta,
        serviceOptionId.isAcceptableOrUnknown(
          data['service_option_id']!,
          _serviceOptionIdMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderChargeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderChargeEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      serviceTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type_id'],
      )!,
      serviceOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_option_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_price'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $OrderChargeEntriesTable createAlias(String alias) {
    return $OrderChargeEntriesTable(attachedDatabase, alias);
  }
}

class OrderChargeEntry extends DataClass
    implements Insertable<OrderChargeEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String orderId;
  final String serviceTypeId;
  final String? serviceOptionId;

  /// Copia legible del catálogo al momento de capturar (D2): subir mañana el
  /// precio de la tina grande no puede reescribir lo que el pedido de hoy dice.
  final String description;
  final String quantity;
  final String unitPrice;
  final String amount;
  const OrderChargeEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.orderId,
    required this.serviceTypeId,
    this.serviceOptionId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['service_type_id'] = Variable<String>(serviceTypeId);
    if (!nullToAbsent || serviceOptionId != null) {
      map['service_option_id'] = Variable<String>(serviceOptionId);
    }
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<String>(quantity);
    map['unit_price'] = Variable<String>(unitPrice);
    map['amount'] = Variable<String>(amount);
    return map;
  }

  OrderChargeEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderChargeEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      serviceTypeId: Value(serviceTypeId),
      serviceOptionId: serviceOptionId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceOptionId),
      description: Value(description),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      amount: Value(amount),
    );
  }

  factory OrderChargeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderChargeEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      serviceTypeId: serializer.fromJson<String>(json['serviceTypeId']),
      serviceOptionId: serializer.fromJson<String?>(json['serviceOptionId']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unitPrice: serializer.fromJson<String>(json['unitPrice']),
      amount: serializer.fromJson<String>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'serviceTypeId': serializer.toJson<String>(serviceTypeId),
      'serviceOptionId': serializer.toJson<String?>(serviceOptionId),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<String>(quantity),
      'unitPrice': serializer.toJson<String>(unitPrice),
      'amount': serializer.toJson<String>(amount),
    };
  }

  OrderChargeEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? orderId,
    String? serviceTypeId,
    Value<String?> serviceOptionId = const Value.absent(),
    String? description,
    String? quantity,
    String? unitPrice,
    String? amount,
  }) => OrderChargeEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    serviceTypeId: serviceTypeId ?? this.serviceTypeId,
    serviceOptionId: serviceOptionId.present
        ? serviceOptionId.value
        : this.serviceOptionId,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    amount: amount ?? this.amount,
  );
  OrderChargeEntry copyWithCompanion(OrderChargeEntriesCompanion data) {
    return OrderChargeEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      serviceTypeId: data.serviceTypeId.present
          ? data.serviceTypeId.value
          : this.serviceTypeId,
      serviceOptionId: data.serviceOptionId.present
          ? data.serviceOptionId.value
          : this.serviceOptionId,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderChargeEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('serviceTypeId: $serviceTypeId, ')
          ..write('serviceOptionId: $serviceOptionId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    serviceTypeId,
    serviceOptionId,
    description,
    quantity,
    unitPrice,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderChargeEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.serviceTypeId == this.serviceTypeId &&
          other.serviceOptionId == this.serviceOptionId &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.amount == this.amount);
}

class OrderChargeEntriesCompanion extends UpdateCompanion<OrderChargeEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> orderId;
  final Value<String> serviceTypeId;
  final Value<String?> serviceOptionId;
  final Value<String> description;
  final Value<String> quantity;
  final Value<String> unitPrice;
  final Value<String> amount;
  final Value<int> rowid;
  const OrderChargeEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.serviceTypeId = const Value.absent(),
    this.serviceOptionId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderChargeEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String orderId,
    required String serviceTypeId,
    this.serviceOptionId = const Value.absent(),
    required String description,
    required String quantity,
    required String unitPrice,
    required String amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       serviceTypeId = Value(serviceTypeId),
       description = Value(description),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       amount = Value(amount);
  static Insertable<OrderChargeEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? serviceTypeId,
    Expression<String>? serviceOptionId,
    Expression<String>? description,
    Expression<String>? quantity,
    Expression<String>? unitPrice,
    Expression<String>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (serviceTypeId != null) 'service_type_id': serviceTypeId,
      if (serviceOptionId != null) 'service_option_id': serviceOptionId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderChargeEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? orderId,
    Value<String>? serviceTypeId,
    Value<String?>? serviceOptionId,
    Value<String>? description,
    Value<String>? quantity,
    Value<String>? unitPrice,
    Value<String>? amount,
    Value<int>? rowid,
  }) {
    return OrderChargeEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceOptionId: serviceOptionId ?? this.serviceOptionId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (serviceTypeId.present) {
      map['service_type_id'] = Variable<String>(serviceTypeId.value);
    }
    if (serviceOptionId.present) {
      map['service_option_id'] = Variable<String>(serviceOptionId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderChargeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('serviceTypeId: $serviceTypeId, ')
          ..write('serviceOptionId: $serviceOptionId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderDiscountEntriesTable extends OrderDiscountEntries
    with TableInfo<$OrderDiscountEntriesTable, OrderDiscountEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderDiscountEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promotionIdMeta = const VerificationMeta(
    'promotionId',
  );
  @override
  late final GeneratedColumn<String> promotionId = GeneratedColumn<String>(
    'promotion_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    promotionId,
    description,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_discount_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderDiscountEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('promotion_id')) {
      context.handle(
        _promotionIdMeta,
        promotionId.isAcceptableOrUnknown(
          data['promotion_id']!,
          _promotionIdMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderDiscountEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderDiscountEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      promotionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promotion_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $OrderDiscountEntriesTable createAlias(String alias) {
    return $OrderDiscountEntriesTable(attachedDatabase, alias);
  }
}

class OrderDiscountEntry extends DataClass
    implements Insertable<OrderDiscountEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String orderId;

  /// Nulo = descuento manual, que exige `orders.manual_discount`.
  final String? promotionId;
  final String description;
  final String amount;
  const OrderDiscountEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.orderId,
    this.promotionId,
    required this.description,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    if (!nullToAbsent || promotionId != null) {
      map['promotion_id'] = Variable<String>(promotionId);
    }
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<String>(amount);
    return map;
  }

  OrderDiscountEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderDiscountEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      promotionId: promotionId == null && nullToAbsent
          ? const Value.absent()
          : Value(promotionId),
      description: Value(description),
      amount: Value(amount),
    );
  }

  factory OrderDiscountEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderDiscountEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      promotionId: serializer.fromJson<String?>(json['promotionId']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<String>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'promotionId': serializer.toJson<String?>(promotionId),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<String>(amount),
    };
  }

  OrderDiscountEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? orderId,
    Value<String?> promotionId = const Value.absent(),
    String? description,
    String? amount,
  }) => OrderDiscountEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    promotionId: promotionId.present ? promotionId.value : this.promotionId,
    description: description ?? this.description,
    amount: amount ?? this.amount,
  );
  OrderDiscountEntry copyWithCompanion(OrderDiscountEntriesCompanion data) {
    return OrderDiscountEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      promotionId: data.promotionId.present
          ? data.promotionId.value
          : this.promotionId,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderDiscountEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('promotionId: $promotionId, ')
          ..write('description: $description, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    promotionId,
    description,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderDiscountEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.promotionId == this.promotionId &&
          other.description == this.description &&
          other.amount == this.amount);
}

class OrderDiscountEntriesCompanion
    extends UpdateCompanion<OrderDiscountEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> orderId;
  final Value<String?> promotionId;
  final Value<String> description;
  final Value<String> amount;
  final Value<int> rowid;
  const OrderDiscountEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.promotionId = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderDiscountEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String orderId,
    this.promotionId = const Value.absent(),
    required String description,
    required String amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       description = Value(description),
       amount = Value(amount);
  static Insertable<OrderDiscountEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? promotionId,
    Expression<String>? description,
    Expression<String>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (promotionId != null) 'promotion_id': promotionId,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderDiscountEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? orderId,
    Value<String?>? promotionId,
    Value<String>? description,
    Value<String>? amount,
    Value<int>? rowid,
  }) {
    return OrderDiscountEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      promotionId: promotionId ?? this.promotionId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (promotionId.present) {
      map['promotion_id'] = Variable<String>(promotionId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderDiscountEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('promotionId: $promotionId, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderPaymentEntriesTable extends OrderPaymentEntries
    with TableInfo<$OrderPaymentEntriesTable, OrderPaymentEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderPaymentEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAdvanceMeta = const VerificationMeta(
    'isAdvance',
  );
  @override
  late final GeneratedColumn<bool> isAdvance = GeneratedColumn<bool>(
    'is_advance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_advance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedByIdMeta = const VerificationMeta(
    'receivedById',
  );
  @override
  late final GeneratedColumn<String> receivedById = GeneratedColumn<String>(
    'received_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    amount,
    method,
    isAdvance,
    reference,
    receivedById,
    paidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_payment_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderPaymentEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('is_advance')) {
      context.handle(
        _isAdvanceMeta,
        isAdvance.isAcceptableOrUnknown(data['is_advance']!, _isAdvanceMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('received_by_id')) {
      context.handle(
        _receivedByIdMeta,
        receivedById.isAcceptableOrUnknown(
          data['received_by_id']!,
          _receivedByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_receivedByIdMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderPaymentEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderPaymentEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      isAdvance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_advance'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      receivedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_by_id'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $OrderPaymentEntriesTable createAlias(String alias) {
    return $OrderPaymentEntriesTable(attachedDatabase, alias);
  }
}

class OrderPaymentEntry extends DataClass
    implements Insertable<OrderPaymentEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String orderId;
  final String amount;

  /// `cash` o `transfer`.
  final String method;
  final bool isAdvance;
  final String? reference;
  final String receivedById;
  final DateTime paidAt;
  const OrderPaymentEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.isAdvance,
    this.reference,
    required this.receivedById,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['order_id'] = Variable<String>(orderId);
    map['amount'] = Variable<String>(amount);
    map['method'] = Variable<String>(method);
    map['is_advance'] = Variable<bool>(isAdvance);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['received_by_id'] = Variable<String>(receivedById);
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  OrderPaymentEntriesCompanion toCompanion(bool nullToAbsent) {
    return OrderPaymentEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      orderId: Value(orderId),
      amount: Value(amount),
      method: Value(method),
      isAdvance: Value(isAdvance),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      receivedById: Value(receivedById),
      paidAt: Value(paidAt),
    );
  }

  factory OrderPaymentEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderPaymentEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      orderId: serializer.fromJson<String>(json['orderId']),
      amount: serializer.fromJson<String>(json['amount']),
      method: serializer.fromJson<String>(json['method']),
      isAdvance: serializer.fromJson<bool>(json['isAdvance']),
      reference: serializer.fromJson<String?>(json['reference']),
      receivedById: serializer.fromJson<String>(json['receivedById']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'orderId': serializer.toJson<String>(orderId),
      'amount': serializer.toJson<String>(amount),
      'method': serializer.toJson<String>(method),
      'isAdvance': serializer.toJson<bool>(isAdvance),
      'reference': serializer.toJson<String?>(reference),
      'receivedById': serializer.toJson<String>(receivedById),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  OrderPaymentEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? orderId,
    String? amount,
    String? method,
    bool? isAdvance,
    Value<String?> reference = const Value.absent(),
    String? receivedById,
    DateTime? paidAt,
  }) => OrderPaymentEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    orderId: orderId ?? this.orderId,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    isAdvance: isAdvance ?? this.isAdvance,
    reference: reference.present ? reference.value : this.reference,
    receivedById: receivedById ?? this.receivedById,
    paidAt: paidAt ?? this.paidAt,
  );
  OrderPaymentEntry copyWithCompanion(OrderPaymentEntriesCompanion data) {
    return OrderPaymentEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      isAdvance: data.isAdvance.present ? data.isAdvance.value : this.isAdvance,
      reference: data.reference.present ? data.reference.value : this.reference,
      receivedById: data.receivedById.present
          ? data.receivedById.value
          : this.receivedById,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderPaymentEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('reference: $reference, ')
          ..write('receivedById: $receivedById, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    orderId,
    amount,
    method,
    isAdvance,
    reference,
    receivedById,
    paidAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderPaymentEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.orderId == this.orderId &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.isAdvance == this.isAdvance &&
          other.reference == this.reference &&
          other.receivedById == this.receivedById &&
          other.paidAt == this.paidAt);
}

class OrderPaymentEntriesCompanion extends UpdateCompanion<OrderPaymentEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> orderId;
  final Value<String> amount;
  final Value<String> method;
  final Value<bool> isAdvance;
  final Value<String?> reference;
  final Value<String> receivedById;
  final Value<DateTime> paidAt;
  final Value<int> rowid;
  const OrderPaymentEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.orderId = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.isAdvance = const Value.absent(),
    this.reference = const Value.absent(),
    this.receivedById = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderPaymentEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String orderId,
    required String amount,
    required String method,
    this.isAdvance = const Value.absent(),
    this.reference = const Value.absent(),
    required String receivedById,
    required DateTime paidAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       amount = Value(amount),
       method = Value(method),
       receivedById = Value(receivedById),
       paidAt = Value(paidAt);
  static Insertable<OrderPaymentEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? orderId,
    Expression<String>? amount,
    Expression<String>? method,
    Expression<bool>? isAdvance,
    Expression<String>? reference,
    Expression<String>? receivedById,
    Expression<DateTime>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (orderId != null) 'order_id': orderId,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (isAdvance != null) 'is_advance': isAdvance,
      if (reference != null) 'reference': reference,
      if (receivedById != null) 'received_by_id': receivedById,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderPaymentEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? orderId,
    Value<String>? amount,
    Value<String>? method,
    Value<bool>? isAdvance,
    Value<String?>? reference,
    Value<String>? receivedById,
    Value<DateTime>? paidAt,
    Value<int>? rowid,
  }) {
    return OrderPaymentEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      isAdvance: isAdvance ?? this.isAdvance,
      reference: reference ?? this.reference,
      receivedById: receivedById ?? this.receivedById,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (isAdvance.present) {
      map['is_advance'] = Variable<bool>(isAdvance.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (receivedById.present) {
      map['received_by_id'] = Variable<String>(receivedById.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderPaymentEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('orderId: $orderId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('reference: $reference, ')
          ..write('receivedById: $receivedById, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromotionEntriesTable extends PromotionEntries
    with TableInfo<$PromotionEntriesTable, PromotionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromotionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 50),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountTypeMeta = const VerificationMeta(
    'discountType',
  );
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
    'discount_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliesToServiceCodesMeta =
      const VerificationMeta('appliesToServiceCodes');
  @override
  late final GeneratedColumn<String> appliesToServiceCodes =
      GeneratedColumn<String>(
        'applies_to_service_codes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _validFromMeta = const VerificationMeta(
    'validFrom',
  );
  @override
  late final GeneratedColumn<String> validFrom = GeneratedColumn<String>(
    'valid_from',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validToMeta = const VerificationMeta(
    'validTo',
  );
  @override
  late final GeneratedColumn<String> validTo = GeneratedColumn<String>(
    'valid_to',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    code,
    name,
    description,
    discountType,
    value,
    appliesToServiceCodes,
    validFrom,
    validTo,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promotion_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromotionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('discount_type')) {
      context.handle(
        _discountTypeMeta,
        discountType.isAcceptableOrUnknown(
          data['discount_type']!,
          _discountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('applies_to_service_codes')) {
      context.handle(
        _appliesToServiceCodesMeta,
        appliesToServiceCodes.isAcceptableOrUnknown(
          data['applies_to_service_codes']!,
          _appliesToServiceCodesMeta,
        ),
      );
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    } else if (isInserting) {
      context.missing(_validFromMeta);
    }
    if (data.containsKey('valid_to')) {
      context.handle(
        _validToMeta,
        validTo.isAcceptableOrUnknown(data['valid_to']!, _validToMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromotionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromotionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      discountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      appliesToServiceCodes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}applies_to_service_codes'],
      ),
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_from'],
      )!,
      validTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_to'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $PromotionEntriesTable createAlias(String alias) {
    return $PromotionEntriesTable(attachedDatabase, alias);
  }
}

class PromotionEntry extends DataClass implements Insertable<PromotionEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;

  /// El código que viaja en el pedido. La app manda **esto** y nunca el monto
  /// (D5): cuánto rebaja lo resuelve el servidor al aplicar la operación.
  final String code;
  final String name;
  final String? description;

  /// `percentage`, `fixed_amount` o `special_price` (plan 0001 §5.4). String y
  /// no enum local, igual que el modo de cobro del catálogo: un tipo nuevo de
  /// descuento no puede obligar a migrar la BD del teléfono.
  final String discountType;

  /// Texto por la razón de siempre: `50` es un porcentaje y `35.00` un precio,
  /// y ninguno de los dos sobrevive intacto a un `double`.
  final String value;

  /// Lista JSON de códigos de servicio, o `null` = aplica a todo el pedido.
  /// Se guarda como llegó y se decodifica al leer: una tabla puente para tres
  /// promociones sería una junta más en cada cálculo del footer.
  final String? appliesToServiceCodes;

  /// Fechas de negocio en `YYYY-MM-DD`, sin hora ni zona.
  final String validFrom;
  final String? validTo;
  final bool isActive;
  const PromotionEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.value,
    this.appliesToServiceCodes,
    required this.validFrom,
    this.validTo,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['discount_type'] = Variable<String>(discountType);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || appliesToServiceCodes != null) {
      map['applies_to_service_codes'] = Variable<String>(appliesToServiceCodes);
    }
    map['valid_from'] = Variable<String>(validFrom);
    if (!nullToAbsent || validTo != null) {
      map['valid_to'] = Variable<String>(validTo);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  PromotionEntriesCompanion toCompanion(bool nullToAbsent) {
    return PromotionEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      code: Value(code),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      discountType: Value(discountType),
      value: Value(value),
      appliesToServiceCodes: appliesToServiceCodes == null && nullToAbsent
          ? const Value.absent()
          : Value(appliesToServiceCodes),
      validFrom: Value(validFrom),
      validTo: validTo == null && nullToAbsent
          ? const Value.absent()
          : Value(validTo),
      isActive: Value(isActive),
    );
  }

  factory PromotionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromotionEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      discountType: serializer.fromJson<String>(json['discountType']),
      value: serializer.fromJson<String>(json['value']),
      appliesToServiceCodes: serializer.fromJson<String?>(
        json['appliesToServiceCodes'],
      ),
      validFrom: serializer.fromJson<String>(json['validFrom']),
      validTo: serializer.fromJson<String?>(json['validTo']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'discountType': serializer.toJson<String>(discountType),
      'value': serializer.toJson<String>(value),
      'appliesToServiceCodes': serializer.toJson<String?>(
        appliesToServiceCodes,
      ),
      'validFrom': serializer.toJson<String>(validFrom),
      'validTo': serializer.toJson<String?>(validTo),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  PromotionEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? code,
    String? name,
    Value<String?> description = const Value.absent(),
    String? discountType,
    String? value,
    Value<String?> appliesToServiceCodes = const Value.absent(),
    String? validFrom,
    Value<String?> validTo = const Value.absent(),
    bool? isActive,
  }) => PromotionEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    code: code ?? this.code,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    discountType: discountType ?? this.discountType,
    value: value ?? this.value,
    appliesToServiceCodes: appliesToServiceCodes.present
        ? appliesToServiceCodes.value
        : this.appliesToServiceCodes,
    validFrom: validFrom ?? this.validFrom,
    validTo: validTo.present ? validTo.value : this.validTo,
    isActive: isActive ?? this.isActive,
  );
  PromotionEntry copyWithCompanion(PromotionEntriesCompanion data) {
    return PromotionEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      value: data.value.present ? data.value.value : this.value,
      appliesToServiceCodes: data.appliesToServiceCodes.present
          ? data.appliesToServiceCodes.value
          : this.appliesToServiceCodes,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      validTo: data.validTo.present ? data.validTo.value : this.validTo,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromotionEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('discountType: $discountType, ')
          ..write('value: $value, ')
          ..write('appliesToServiceCodes: $appliesToServiceCodes, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    code,
    name,
    description,
    discountType,
    value,
    appliesToServiceCodes,
    validFrom,
    validTo,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromotionEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.discountType == this.discountType &&
          other.value == this.value &&
          other.appliesToServiceCodes == this.appliesToServiceCodes &&
          other.validFrom == this.validFrom &&
          other.validTo == this.validTo &&
          other.isActive == this.isActive);
}

class PromotionEntriesCompanion extends UpdateCompanion<PromotionEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> discountType;
  final Value<String> value;
  final Value<String?> appliesToServiceCodes;
  final Value<String> validFrom;
  final Value<String?> validTo;
  final Value<bool> isActive;
  final Value<int> rowid;
  const PromotionEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.discountType = const Value.absent(),
    this.value = const Value.absent(),
    this.appliesToServiceCodes = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validTo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromotionEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String code,
    required String name,
    this.description = const Value.absent(),
    required String discountType,
    required String value,
    this.appliesToServiceCodes = const Value.absent(),
    required String validFrom,
    this.validTo = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       discountType = Value(discountType),
       value = Value(value),
       validFrom = Value(validFrom);
  static Insertable<PromotionEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? discountType,
    Expression<String>? value,
    Expression<String>? appliesToServiceCodes,
    Expression<String>? validFrom,
    Expression<String>? validTo,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (discountType != null) 'discount_type': discountType,
      if (value != null) 'value': value,
      if (appliesToServiceCodes != null)
        'applies_to_service_codes': appliesToServiceCodes,
      if (validFrom != null) 'valid_from': validFrom,
      if (validTo != null) 'valid_to': validTo,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromotionEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? discountType,
    Value<String>? value,
    Value<String?>? appliesToServiceCodes,
    Value<String>? validFrom,
    Value<String?>? validTo,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return PromotionEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      value: value ?? this.value,
      appliesToServiceCodes:
          appliesToServiceCodes ?? this.appliesToServiceCodes,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (appliesToServiceCodes.present) {
      map['applies_to_service_codes'] = Variable<String>(
        appliesToServiceCodes.value,
      );
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<String>(validFrom.value);
    }
    if (validTo.present) {
      map['valid_to'] = Variable<String>(validTo.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromotionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('discountType: $discountType, ')
          ..write('value: $value, ')
          ..write('appliesToServiceCodes: $appliesToServiceCodes, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoryEntriesTable extends ExpenseCategoryEntries
    with TableInfo<$ExpenseCategoryEntriesTable, ExpenseCategoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    name,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_category_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ExpenseCategoryEntriesTable createAlias(String alias) {
    return $ExpenseCategoryEntriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategoryEntry extends DataClass
    implements Insertable<ExpenseCategoryEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String name;
  final bool isActive;
  final int sortOrder;
  const ExpenseCategoryEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.name,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ExpenseCategoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoryEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory ExpenseCategoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategoryEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ExpenseCategoryEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    bool? isActive,
    int? sortOrder,
  }) => ExpenseCategoryEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ExpenseCategoryEntry copyWithCompanion(ExpenseCategoryEntriesCompanion data) {
    return ExpenseCategoryEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoryEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    name,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategoryEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class ExpenseCategoryEntriesCompanion
    extends UpdateCompanion<ExpenseCategoryEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ExpenseCategoryEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoryEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ExpenseCategoryEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ExpenseCategoryEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseEntriesTable extends ExpenseEntries
    with TableInfo<$ExpenseEntriesTable, ExpenseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<String> expenseDate = GeneratedColumn<String>(
    'expense_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attendanceRecordIdMeta =
      const VerificationMeta('attendanceRecordId');
  @override
  late final GeneratedColumn<String> attendanceRecordId =
      GeneratedColumn<String>(
        'attendance_record_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _productLotIdMeta = const VerificationMeta(
    'productLotId',
  );
  @override
  late final GeneratedColumn<String> productLotId = GeneratedColumn<String>(
    'product_lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  @override
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByIdMeta = const VerificationMeta(
    'createdById',
  );
  @override
  late final GeneratedColumn<String> createdById = GeneratedColumn<String>(
    'created_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    expenseDate,
    categoryId,
    concept,
    amount,
    method,
    status,
    employeeId,
    attendanceRecordId,
    productLotId,
    observations,
    createdById,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    }
    if (data.containsKey('attendance_record_id')) {
      context.handle(
        _attendanceRecordIdMeta,
        attendanceRecordId.isAcceptableOrUnknown(
          data['attendance_record_id']!,
          _attendanceRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('product_lot_id')) {
      context.handle(
        _productLotIdMeta,
        productLotId.isAcceptableOrUnknown(
          data['product_lot_id']!,
          _productLotIdMeta,
        ),
      );
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('created_by_id')) {
      context.handle(
        _createdByIdMeta,
        createdById.isAcceptableOrUnknown(
          data['created_by_id']!,
          _createdByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByIdMeta);
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      ),
      attendanceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_record_id'],
      ),
      productLotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_lot_id'],
      ),
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      createdById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_id'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $ExpenseEntriesTable createAlias(String alias) {
    return $ExpenseEntriesTable(attachedDatabase, alias);
  }
}

class ExpenseEntry extends DataClass implements Insertable<ExpenseEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;

  /// Fecha de negocio en `YYYY-MM-DD`: el día al que el gasto pertenece, que no
  /// es el instante en que alguien lo tecleó.
  final String expenseDate;

  /// Solo el id. El nombre se lee uniendo con [ExpenseCategoryEntries], que es
  /// la razón de espejarlas: copiarlo aquí congelaría el nombre viejo el día
  /// que se corrija una categoría.
  final String categoryId;
  final String concept;
  final String amount;

  /// `cash` o `transfer`. El arqueo del día se parte por esta columna.
  final String method;

  /// `paid` o `pending`. Un gasto pendiente cuenta contra el día pero todavía
  /// no salió del cajón, y esa diferencia es la que el cierre advierte.
  final String status;

  /// Los tres vínculos del §6.2 y §6.3: a quién se le pagó, qué jornada y qué
  /// lote. Ninguno se edita después (el servidor tampoco los deja): mover un
  /// gasto de una jornada a otra no es una corrección, es otro pago.
  final String? employeeId;
  final String? attendanceRecordId;
  final String? productLotId;
  final String? observations;
  final String createdById;

  /// Un gasto anulado baja como lápida y el motivo viaja con ella, para que el
  /// total del día se pueda explicar también en el dispositivo.
  final String? voidReason;
  const ExpenseEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.expenseDate,
    required this.categoryId,
    required this.concept,
    required this.amount,
    required this.method,
    required this.status,
    this.employeeId,
    this.attendanceRecordId,
    this.productLotId,
    this.observations,
    required this.createdById,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['expense_date'] = Variable<String>(expenseDate);
    map['category_id'] = Variable<String>(categoryId);
    map['concept'] = Variable<String>(concept);
    map['amount'] = Variable<String>(amount);
    map['method'] = Variable<String>(method);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || employeeId != null) {
      map['employee_id'] = Variable<String>(employeeId);
    }
    if (!nullToAbsent || attendanceRecordId != null) {
      map['attendance_record_id'] = Variable<String>(attendanceRecordId);
    }
    if (!nullToAbsent || productLotId != null) {
      map['product_lot_id'] = Variable<String>(productLotId);
    }
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    map['created_by_id'] = Variable<String>(createdById);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  ExpenseEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      expenseDate: Value(expenseDate),
      categoryId: Value(categoryId),
      concept: Value(concept),
      amount: Value(amount),
      method: Value(method),
      status: Value(status),
      employeeId: employeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeId),
      attendanceRecordId: attendanceRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(attendanceRecordId),
      productLotId: productLotId == null && nullToAbsent
          ? const Value.absent()
          : Value(productLotId),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      createdById: Value(createdById),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory ExpenseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      expenseDate: serializer.fromJson<String>(json['expenseDate']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      concept: serializer.fromJson<String>(json['concept']),
      amount: serializer.fromJson<String>(json['amount']),
      method: serializer.fromJson<String>(json['method']),
      status: serializer.fromJson<String>(json['status']),
      employeeId: serializer.fromJson<String?>(json['employeeId']),
      attendanceRecordId: serializer.fromJson<String?>(
        json['attendanceRecordId'],
      ),
      productLotId: serializer.fromJson<String?>(json['productLotId']),
      observations: serializer.fromJson<String?>(json['observations']),
      createdById: serializer.fromJson<String>(json['createdById']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'expenseDate': serializer.toJson<String>(expenseDate),
      'categoryId': serializer.toJson<String>(categoryId),
      'concept': serializer.toJson<String>(concept),
      'amount': serializer.toJson<String>(amount),
      'method': serializer.toJson<String>(method),
      'status': serializer.toJson<String>(status),
      'employeeId': serializer.toJson<String?>(employeeId),
      'attendanceRecordId': serializer.toJson<String?>(attendanceRecordId),
      'productLotId': serializer.toJson<String?>(productLotId),
      'observations': serializer.toJson<String?>(observations),
      'createdById': serializer.toJson<String>(createdById),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  ExpenseEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? expenseDate,
    String? categoryId,
    String? concept,
    String? amount,
    String? method,
    String? status,
    Value<String?> employeeId = const Value.absent(),
    Value<String?> attendanceRecordId = const Value.absent(),
    Value<String?> productLotId = const Value.absent(),
    Value<String?> observations = const Value.absent(),
    String? createdById,
    Value<String?> voidReason = const Value.absent(),
  }) => ExpenseEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    expenseDate: expenseDate ?? this.expenseDate,
    categoryId: categoryId ?? this.categoryId,
    concept: concept ?? this.concept,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    status: status ?? this.status,
    employeeId: employeeId.present ? employeeId.value : this.employeeId,
    attendanceRecordId: attendanceRecordId.present
        ? attendanceRecordId.value
        : this.attendanceRecordId,
    productLotId: productLotId.present ? productLotId.value : this.productLotId,
    observations: observations.present ? observations.value : this.observations,
    createdById: createdById ?? this.createdById,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  ExpenseEntry copyWithCompanion(ExpenseEntriesCompanion data) {
    return ExpenseEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      concept: data.concept.present ? data.concept.value : this.concept,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      status: data.status.present ? data.status.value : this.status,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      attendanceRecordId: data.attendanceRecordId.present
          ? data.attendanceRecordId.value
          : this.attendanceRecordId,
      productLotId: data.productLotId.present
          ? data.productLotId.value
          : this.productLotId,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      createdById: data.createdById.present
          ? data.createdById.value
          : this.createdById,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('concept: $concept, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('status: $status, ')
          ..write('employeeId: $employeeId, ')
          ..write('attendanceRecordId: $attendanceRecordId, ')
          ..write('productLotId: $productLotId, ')
          ..write('observations: $observations, ')
          ..write('createdById: $createdById, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    expenseDate,
    categoryId,
    concept,
    amount,
    method,
    status,
    employeeId,
    attendanceRecordId,
    productLotId,
    observations,
    createdById,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.expenseDate == this.expenseDate &&
          other.categoryId == this.categoryId &&
          other.concept == this.concept &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.status == this.status &&
          other.employeeId == this.employeeId &&
          other.attendanceRecordId == this.attendanceRecordId &&
          other.productLotId == this.productLotId &&
          other.observations == this.observations &&
          other.createdById == this.createdById &&
          other.voidReason == this.voidReason);
}

class ExpenseEntriesCompanion extends UpdateCompanion<ExpenseEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> expenseDate;
  final Value<String> categoryId;
  final Value<String> concept;
  final Value<String> amount;
  final Value<String> method;
  final Value<String> status;
  final Value<String?> employeeId;
  final Value<String?> attendanceRecordId;
  final Value<String?> productLotId;
  final Value<String?> observations;
  final Value<String> createdById;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const ExpenseEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.concept = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.status = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.attendanceRecordId = const Value.absent(),
    this.productLotId = const Value.absent(),
    this.observations = const Value.absent(),
    this.createdById = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String expenseDate,
    required String categoryId,
    required String concept,
    required String amount,
    required String method,
    required String status,
    this.employeeId = const Value.absent(),
    this.attendanceRecordId = const Value.absent(),
    this.productLotId = const Value.absent(),
    this.observations = const Value.absent(),
    required String createdById,
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       expenseDate = Value(expenseDate),
       categoryId = Value(categoryId),
       concept = Value(concept),
       amount = Value(amount),
       method = Value(method),
       status = Value(status),
       createdById = Value(createdById);
  static Insertable<ExpenseEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? expenseDate,
    Expression<String>? categoryId,
    Expression<String>? concept,
    Expression<String>? amount,
    Expression<String>? method,
    Expression<String>? status,
    Expression<String>? employeeId,
    Expression<String>? attendanceRecordId,
    Expression<String>? productLotId,
    Expression<String>? observations,
    Expression<String>? createdById,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (categoryId != null) 'category_id': categoryId,
      if (concept != null) 'concept': concept,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (status != null) 'status': status,
      if (employeeId != null) 'employee_id': employeeId,
      if (attendanceRecordId != null)
        'attendance_record_id': attendanceRecordId,
      if (productLotId != null) 'product_lot_id': productLotId,
      if (observations != null) 'observations': observations,
      if (createdById != null) 'created_by_id': createdById,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? expenseDate,
    Value<String>? categoryId,
    Value<String>? concept,
    Value<String>? amount,
    Value<String>? method,
    Value<String>? status,
    Value<String?>? employeeId,
    Value<String?>? attendanceRecordId,
    Value<String?>? productLotId,
    Value<String?>? observations,
    Value<String>? createdById,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return ExpenseEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      expenseDate: expenseDate ?? this.expenseDate,
      categoryId: categoryId ?? this.categoryId,
      concept: concept ?? this.concept,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      employeeId: employeeId ?? this.employeeId,
      attendanceRecordId: attendanceRecordId ?? this.attendanceRecordId,
      productLotId: productLotId ?? this.productLotId,
      observations: observations ?? this.observations,
      createdById: createdById ?? this.createdById,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<String>(expenseDate.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (attendanceRecordId.present) {
      map['attendance_record_id'] = Variable<String>(attendanceRecordId.value);
    }
    if (productLotId.present) {
      map['product_lot_id'] = Variable<String>(productLotId.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (createdById.present) {
      map['created_by_id'] = Variable<String>(createdById.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('concept: $concept, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('status: $status, ')
          ..write('employeeId: $employeeId, ')
          ..write('attendanceRecordId: $attendanceRecordId, ')
          ..write('productLotId: $productLotId, ')
          ..write('observations: $observations, ')
          ..write('createdById: $createdById, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductEntriesTable extends ProductEntries
    with TableInfo<$ProductEntriesTable, ProductEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 30),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    name,
    unit,
    description,
    imagePath,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ProductEntriesTable createAlias(String alias) {
    return $ProductEntriesTable(attachedDatabase, alias);
  }
}

class ProductEntry extends DataClass implements Insertable<ProductEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String name;

  /// Bote, bolsa, galón, saco… texto libre porque lo decide el proveedor.
  final String unit;
  final String? description;

  /// Ruta bajo `MEDIA_DIR` del servidor. Cambia cada vez que se reemplaza la
  /// foto, y ese cambio es lo que le dice a la app que la que tiene en caché ya
  /// no sirve.
  final String? imagePath;
  final bool isActive;
  final int sortOrder;
  const ProductEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.name,
    required this.unit,
    this.description,
    this.imagePath,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProductEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProductEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      unit: Value(unit),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory ProductEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      description: serializer.fromJson<String?>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'description': serializer.toJson<String?>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ProductEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    String? unit,
    Value<String?> description = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => ProductEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    description: description.present ? description.value : this.description,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ProductEntry copyWithCompanion(ProductEntriesCompanion data) {
    return ProductEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    name,
    unit,
    description,
    imagePath,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class ProductEntriesCompanion extends UpdateCompanion<ProductEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> unit;
  final Value<String?> description;
  final Value<String?> imagePath;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ProductEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    required String unit,
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       unit = Value(unit);
  static Insertable<ProductEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String>? unit,
    Value<String?>? description,
    Value<String?>? imagePath,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ProductEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductLotEntriesTable extends ProductLotEntries
    with TableInfo<$ProductLotEntriesTable, ProductLotEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductLotEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotNumberMeta = const VerificationMeta(
    'lotNumber',
  );
  @override
  late final GeneratedColumn<int> lotNumber = GeneratedColumn<int>(
    'lot_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReceivedMeta = const VerificationMeta(
    'quantityReceived',
  );
  @override
  late final GeneratedColumn<String> quantityReceived = GeneratedColumn<String>(
    'quantity_received',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityAvailableMeta = const VerificationMeta(
    'quantityAvailable',
  );
  @override
  late final GeneratedColumn<String> quantityAvailable =
      GeneratedColumn<String>(
        'quantity_available',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<String> salePrice = GeneratedColumn<String>(
    'sale_price',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<String> receivedAt = GeneratedColumn<String>(
    'received_at',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    productId,
    lotNumber,
    quantityReceived,
    quantityAvailable,
    salePrice,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_lot_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductLotEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('lot_number')) {
      context.handle(
        _lotNumberMeta,
        lotNumber.isAcceptableOrUnknown(data['lot_number']!, _lotNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_lotNumberMeta);
    }
    if (data.containsKey('quantity_received')) {
      context.handle(
        _quantityReceivedMeta,
        quantityReceived.isAcceptableOrUnknown(
          data['quantity_received']!,
          _quantityReceivedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityReceivedMeta);
    }
    if (data.containsKey('quantity_available')) {
      context.handle(
        _quantityAvailableMeta,
        quantityAvailable.isAcceptableOrUnknown(
          data['quantity_available']!,
          _quantityAvailableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityAvailableMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductLotEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductLotEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      lotNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_number'],
      )!,
      quantityReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_received'],
      )!,
      quantityAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_available'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_price'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $ProductLotEntriesTable createAlias(String alias) {
    return $ProductLotEntriesTable(attachedDatabase, alias);
  }
}

class ProductLotEntry extends DataClass implements Insertable<ProductLotEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String productId;

  /// Correlativo por producto, el número con el que se habla del lote.
  final int lotNumber;
  final String quantityReceived;
  final String quantityAvailable;

  /// Nulo = el lote es consumo interno de la lavandería y el FIFO de venta lo
  /// salta. **No hay `unitCost`**: el feed no lo manda a propósito (el margen de
  /// compra no se lee en el mostrador) y por eso aquí tampoco existe.
  final String? salePrice;

  /// Fecha de recepción en `YYYY-MM-DD`. Es la que ordena el FIFO.
  final String receivedAt;
  const ProductLotEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.productId,
    required this.lotNumber,
    required this.quantityReceived,
    required this.quantityAvailable,
    this.salePrice,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['product_id'] = Variable<String>(productId);
    map['lot_number'] = Variable<int>(lotNumber);
    map['quantity_received'] = Variable<String>(quantityReceived);
    map['quantity_available'] = Variable<String>(quantityAvailable);
    if (!nullToAbsent || salePrice != null) {
      map['sale_price'] = Variable<String>(salePrice);
    }
    map['received_at'] = Variable<String>(receivedAt);
    return map;
  }

  ProductLotEntriesCompanion toCompanion(bool nullToAbsent) {
    return ProductLotEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      productId: Value(productId),
      lotNumber: Value(lotNumber),
      quantityReceived: Value(quantityReceived),
      quantityAvailable: Value(quantityAvailable),
      salePrice: salePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(salePrice),
      receivedAt: Value(receivedAt),
    );
  }

  factory ProductLotEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductLotEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      productId: serializer.fromJson<String>(json['productId']),
      lotNumber: serializer.fromJson<int>(json['lotNumber']),
      quantityReceived: serializer.fromJson<String>(json['quantityReceived']),
      quantityAvailable: serializer.fromJson<String>(json['quantityAvailable']),
      salePrice: serializer.fromJson<String?>(json['salePrice']),
      receivedAt: serializer.fromJson<String>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'productId': serializer.toJson<String>(productId),
      'lotNumber': serializer.toJson<int>(lotNumber),
      'quantityReceived': serializer.toJson<String>(quantityReceived),
      'quantityAvailable': serializer.toJson<String>(quantityAvailable),
      'salePrice': serializer.toJson<String?>(salePrice),
      'receivedAt': serializer.toJson<String>(receivedAt),
    };
  }

  ProductLotEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? productId,
    int? lotNumber,
    String? quantityReceived,
    String? quantityAvailable,
    Value<String?> salePrice = const Value.absent(),
    String? receivedAt,
  }) => ProductLotEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    productId: productId ?? this.productId,
    lotNumber: lotNumber ?? this.lotNumber,
    quantityReceived: quantityReceived ?? this.quantityReceived,
    quantityAvailable: quantityAvailable ?? this.quantityAvailable,
    salePrice: salePrice.present ? salePrice.value : this.salePrice,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  ProductLotEntry copyWithCompanion(ProductLotEntriesCompanion data) {
    return ProductLotEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      productId: data.productId.present ? data.productId.value : this.productId,
      lotNumber: data.lotNumber.present ? data.lotNumber.value : this.lotNumber,
      quantityReceived: data.quantityReceived.present
          ? data.quantityReceived.value
          : this.quantityReceived,
      quantityAvailable: data.quantityAvailable.present
          ? data.quantityAvailable.value
          : this.quantityAvailable,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductLotEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productId: $productId, ')
          ..write('lotNumber: $lotNumber, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('quantityAvailable: $quantityAvailable, ')
          ..write('salePrice: $salePrice, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    productId,
    lotNumber,
    quantityReceived,
    quantityAvailable,
    salePrice,
    receivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductLotEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.productId == this.productId &&
          other.lotNumber == this.lotNumber &&
          other.quantityReceived == this.quantityReceived &&
          other.quantityAvailable == this.quantityAvailable &&
          other.salePrice == this.salePrice &&
          other.receivedAt == this.receivedAt);
}

class ProductLotEntriesCompanion extends UpdateCompanion<ProductLotEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> productId;
  final Value<int> lotNumber;
  final Value<String> quantityReceived;
  final Value<String> quantityAvailable;
  final Value<String?> salePrice;
  final Value<String> receivedAt;
  final Value<int> rowid;
  const ProductLotEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.productId = const Value.absent(),
    this.lotNumber = const Value.absent(),
    this.quantityReceived = const Value.absent(),
    this.quantityAvailable = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductLotEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String productId,
    required int lotNumber,
    required String quantityReceived,
    required String quantityAvailable,
    this.salePrice = const Value.absent(),
    required String receivedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       lotNumber = Value(lotNumber),
       quantityReceived = Value(quantityReceived),
       quantityAvailable = Value(quantityAvailable),
       receivedAt = Value(receivedAt);
  static Insertable<ProductLotEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? productId,
    Expression<int>? lotNumber,
    Expression<String>? quantityReceived,
    Expression<String>? quantityAvailable,
    Expression<String>? salePrice,
    Expression<String>? receivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (productId != null) 'product_id': productId,
      if (lotNumber != null) 'lot_number': lotNumber,
      if (quantityReceived != null) 'quantity_received': quantityReceived,
      if (quantityAvailable != null) 'quantity_available': quantityAvailable,
      if (salePrice != null) 'sale_price': salePrice,
      if (receivedAt != null) 'received_at': receivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductLotEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? productId,
    Value<int>? lotNumber,
    Value<String>? quantityReceived,
    Value<String>? quantityAvailable,
    Value<String?>? salePrice,
    Value<String>? receivedAt,
    Value<int>? rowid,
  }) {
    return ProductLotEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      productId: productId ?? this.productId,
      lotNumber: lotNumber ?? this.lotNumber,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      salePrice: salePrice ?? this.salePrice,
      receivedAt: receivedAt ?? this.receivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (lotNumber.present) {
      map['lot_number'] = Variable<int>(lotNumber.value);
    }
    if (quantityReceived.present) {
      map['quantity_received'] = Variable<String>(quantityReceived.value);
    }
    if (quantityAvailable.present) {
      map['quantity_available'] = Variable<String>(quantityAvailable.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<String>(salePrice.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<String>(receivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductLotEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('productId: $productId, ')
          ..write('lotNumber: $lotNumber, ')
          ..write('quantityReceived: $quantityReceived, ')
          ..write('quantityAvailable: $quantityAvailable, ')
          ..write('salePrice: $salePrice, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplySaleEntriesTable extends SupplySaleEntries
    with TableInfo<$SupplySaleEntriesTable, SupplySaleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplySaleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saleDateMeta = const VerificationMeta(
    'saleDate',
  );
  @override
  late final GeneratedColumn<String> saleDate = GeneratedColumn<String>(
    'sale_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nitMeta = const VerificationMeta('nit');
  @override
  late final GeneratedColumn<String> nit = GeneratedColumn<String>(
    'nit',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<String> total = GeneratedColumn<String>(
    'total',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soldByIdMeta = const VerificationMeta(
    'soldById',
  );
  @override
  late final GeneratedColumn<String> soldById = GeneratedColumn<String>(
    'sold_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cancelledAtMeta = const VerificationMeta(
    'cancelledAt',
  );
  @override
  late final GeneratedColumn<DateTime> cancelledAt = GeneratedColumn<DateTime>(
    'cancelled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelledByIdMeta = const VerificationMeta(
    'cancelledById',
  );
  @override
  late final GeneratedColumn<String> cancelledById = GeneratedColumn<String>(
    'cancelled_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cancelReasonMeta = const VerificationMeta(
    'cancelReason',
  );
  @override
  late final GeneratedColumn<String> cancelReason = GeneratedColumn<String>(
    'cancel_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    saleDate,
    customerId,
    nit,
    method,
    reference,
    total,
    soldById,
    cancelledAt,
    cancelledById,
    cancelReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supply_sale_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplySaleEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sale_date')) {
      context.handle(
        _saleDateMeta,
        saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta),
      );
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('nit')) {
      context.handle(
        _nitMeta,
        nit.isAcceptableOrUnknown(data['nit']!, _nitMeta),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('sold_by_id')) {
      context.handle(
        _soldByIdMeta,
        soldById.isAcceptableOrUnknown(data['sold_by_id']!, _soldByIdMeta),
      );
    } else if (isInserting) {
      context.missing(_soldByIdMeta);
    }
    if (data.containsKey('cancelled_at')) {
      context.handle(
        _cancelledAtMeta,
        cancelledAt.isAcceptableOrUnknown(
          data['cancelled_at']!,
          _cancelledAtMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_by_id')) {
      context.handle(
        _cancelledByIdMeta,
        cancelledById.isAcceptableOrUnknown(
          data['cancelled_by_id']!,
          _cancelledByIdMeta,
        ),
      );
    }
    if (data.containsKey('cancel_reason')) {
      context.handle(
        _cancelReasonMeta,
        cancelReason.isAcceptableOrUnknown(
          data['cancel_reason']!,
          _cancelReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplySaleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplySaleEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      saleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_date'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      nit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nit'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}total'],
      )!,
      soldById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sold_by_id'],
      )!,
      cancelledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cancelled_at'],
      ),
      cancelledById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancelled_by_id'],
      ),
      cancelReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cancel_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $SupplySaleEntriesTable createAlias(String alias) {
    return $SupplySaleEntriesTable(attachedDatabase, alias);
  }
}

class SupplySaleEntry extends DataClass implements Insertable<SupplySaleEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String saleDate;
  final String? customerId;
  final String? nit;
  final String method;
  final String? reference;

  /// Lo que la venta suma al día. Mientras está `pending` es la vista previa que
  /// calculó el dispositivo; al aplicarse, el servidor la vuelve a valuar contra
  /// los lotes de ese momento y el feed pisa esta columna (D10).
  final String total;
  final String soldById;
  final DateTime? cancelledAt;
  final String? cancelledById;
  final String? cancelReason;

  /// Hora de la venta, que es lo que la lista de ingresos del día muestra.
  final DateTime? createdAt;
  const SupplySaleEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.saleDate,
    this.customerId,
    this.nit,
    required this.method,
    this.reference,
    required this.total,
    required this.soldById,
    this.cancelledAt,
    this.cancelledById,
    this.cancelReason,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sale_date'] = Variable<String>(saleDate);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || nit != null) {
      map['nit'] = Variable<String>(nit);
    }
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['total'] = Variable<String>(total);
    map['sold_by_id'] = Variable<String>(soldById);
    if (!nullToAbsent || cancelledAt != null) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt);
    }
    if (!nullToAbsent || cancelledById != null) {
      map['cancelled_by_id'] = Variable<String>(cancelledById);
    }
    if (!nullToAbsent || cancelReason != null) {
      map['cancel_reason'] = Variable<String>(cancelReason);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  SupplySaleEntriesCompanion toCompanion(bool nullToAbsent) {
    return SupplySaleEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      saleDate: Value(saleDate),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      nit: nit == null && nullToAbsent ? const Value.absent() : Value(nit),
      method: Value(method),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      total: Value(total),
      soldById: Value(soldById),
      cancelledAt: cancelledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledAt),
      cancelledById: cancelledById == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelledById),
      cancelReason: cancelReason == null && nullToAbsent
          ? const Value.absent()
          : Value(cancelReason),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory SupplySaleEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplySaleEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      saleDate: serializer.fromJson<String>(json['saleDate']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      nit: serializer.fromJson<String?>(json['nit']),
      method: serializer.fromJson<String>(json['method']),
      reference: serializer.fromJson<String?>(json['reference']),
      total: serializer.fromJson<String>(json['total']),
      soldById: serializer.fromJson<String>(json['soldById']),
      cancelledAt: serializer.fromJson<DateTime?>(json['cancelledAt']),
      cancelledById: serializer.fromJson<String?>(json['cancelledById']),
      cancelReason: serializer.fromJson<String?>(json['cancelReason']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'saleDate': serializer.toJson<String>(saleDate),
      'customerId': serializer.toJson<String?>(customerId),
      'nit': serializer.toJson<String?>(nit),
      'method': serializer.toJson<String>(method),
      'reference': serializer.toJson<String?>(reference),
      'total': serializer.toJson<String>(total),
      'soldById': serializer.toJson<String>(soldById),
      'cancelledAt': serializer.toJson<DateTime?>(cancelledAt),
      'cancelledById': serializer.toJson<String?>(cancelledById),
      'cancelReason': serializer.toJson<String?>(cancelReason),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  SupplySaleEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? saleDate,
    Value<String?> customerId = const Value.absent(),
    Value<String?> nit = const Value.absent(),
    String? method,
    Value<String?> reference = const Value.absent(),
    String? total,
    String? soldById,
    Value<DateTime?> cancelledAt = const Value.absent(),
    Value<String?> cancelledById = const Value.absent(),
    Value<String?> cancelReason = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => SupplySaleEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    saleDate: saleDate ?? this.saleDate,
    customerId: customerId.present ? customerId.value : this.customerId,
    nit: nit.present ? nit.value : this.nit,
    method: method ?? this.method,
    reference: reference.present ? reference.value : this.reference,
    total: total ?? this.total,
    soldById: soldById ?? this.soldById,
    cancelledAt: cancelledAt.present ? cancelledAt.value : this.cancelledAt,
    cancelledById: cancelledById.present
        ? cancelledById.value
        : this.cancelledById,
    cancelReason: cancelReason.present ? cancelReason.value : this.cancelReason,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  SupplySaleEntry copyWithCompanion(SupplySaleEntriesCompanion data) {
    return SupplySaleEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      nit: data.nit.present ? data.nit.value : this.nit,
      method: data.method.present ? data.method.value : this.method,
      reference: data.reference.present ? data.reference.value : this.reference,
      total: data.total.present ? data.total.value : this.total,
      soldById: data.soldById.present ? data.soldById.value : this.soldById,
      cancelledAt: data.cancelledAt.present
          ? data.cancelledAt.value
          : this.cancelledAt,
      cancelledById: data.cancelledById.present
          ? data.cancelledById.value
          : this.cancelledById,
      cancelReason: data.cancelReason.present
          ? data.cancelReason.value
          : this.cancelReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplySaleEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleDate: $saleDate, ')
          ..write('customerId: $customerId, ')
          ..write('nit: $nit, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('total: $total, ')
          ..write('soldById: $soldById, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelledById: $cancelledById, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    saleDate,
    customerId,
    nit,
    method,
    reference,
    total,
    soldById,
    cancelledAt,
    cancelledById,
    cancelReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplySaleEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.saleDate == this.saleDate &&
          other.customerId == this.customerId &&
          other.nit == this.nit &&
          other.method == this.method &&
          other.reference == this.reference &&
          other.total == this.total &&
          other.soldById == this.soldById &&
          other.cancelledAt == this.cancelledAt &&
          other.cancelledById == this.cancelledById &&
          other.cancelReason == this.cancelReason &&
          other.createdAt == this.createdAt);
}

class SupplySaleEntriesCompanion extends UpdateCompanion<SupplySaleEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> saleDate;
  final Value<String?> customerId;
  final Value<String?> nit;
  final Value<String> method;
  final Value<String?> reference;
  final Value<String> total;
  final Value<String> soldById;
  final Value<DateTime?> cancelledAt;
  final Value<String?> cancelledById;
  final Value<String?> cancelReason;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const SupplySaleEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.customerId = const Value.absent(),
    this.nit = const Value.absent(),
    this.method = const Value.absent(),
    this.reference = const Value.absent(),
    this.total = const Value.absent(),
    this.soldById = const Value.absent(),
    this.cancelledAt = const Value.absent(),
    this.cancelledById = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplySaleEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String saleDate,
    this.customerId = const Value.absent(),
    this.nit = const Value.absent(),
    required String method,
    this.reference = const Value.absent(),
    required String total,
    required String soldById,
    this.cancelledAt = const Value.absent(),
    this.cancelledById = const Value.absent(),
    this.cancelReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleDate = Value(saleDate),
       method = Value(method),
       total = Value(total),
       soldById = Value(soldById);
  static Insertable<SupplySaleEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? saleDate,
    Expression<String>? customerId,
    Expression<String>? nit,
    Expression<String>? method,
    Expression<String>? reference,
    Expression<String>? total,
    Expression<String>? soldById,
    Expression<DateTime>? cancelledAt,
    Expression<String>? cancelledById,
    Expression<String>? cancelReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (saleDate != null) 'sale_date': saleDate,
      if (customerId != null) 'customer_id': customerId,
      if (nit != null) 'nit': nit,
      if (method != null) 'method': method,
      if (reference != null) 'reference': reference,
      if (total != null) 'total': total,
      if (soldById != null) 'sold_by_id': soldById,
      if (cancelledAt != null) 'cancelled_at': cancelledAt,
      if (cancelledById != null) 'cancelled_by_id': cancelledById,
      if (cancelReason != null) 'cancel_reason': cancelReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplySaleEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? saleDate,
    Value<String?>? customerId,
    Value<String?>? nit,
    Value<String>? method,
    Value<String?>? reference,
    Value<String>? total,
    Value<String>? soldById,
    Value<DateTime?>? cancelledAt,
    Value<String?>? cancelledById,
    Value<String?>? cancelReason,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return SupplySaleEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      saleDate: saleDate ?? this.saleDate,
      customerId: customerId ?? this.customerId,
      nit: nit ?? this.nit,
      method: method ?? this.method,
      reference: reference ?? this.reference,
      total: total ?? this.total,
      soldById: soldById ?? this.soldById,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledById: cancelledById ?? this.cancelledById,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<String>(saleDate.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (nit.present) {
      map['nit'] = Variable<String>(nit.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (total.present) {
      map['total'] = Variable<String>(total.value);
    }
    if (soldById.present) {
      map['sold_by_id'] = Variable<String>(soldById.value);
    }
    if (cancelledAt.present) {
      map['cancelled_at'] = Variable<DateTime>(cancelledAt.value);
    }
    if (cancelledById.present) {
      map['cancelled_by_id'] = Variable<String>(cancelledById.value);
    }
    if (cancelReason.present) {
      map['cancel_reason'] = Variable<String>(cancelReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplySaleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleDate: $saleDate, ')
          ..write('customerId: $customerId, ')
          ..write('nit: $nit, ')
          ..write('method: $method, ')
          ..write('reference: $reference, ')
          ..write('total: $total, ')
          ..write('soldById: $soldById, ')
          ..write('cancelledAt: $cancelledAt, ')
          ..write('cancelledById: $cancelledById, ')
          ..write('cancelReason: $cancelReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplySaleItemEntriesTable extends SupplySaleItemEntries
    with TableInfo<$SupplySaleItemEntriesTable, SupplySaleItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplySaleItemEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 160),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
    'unit_price',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    saleId,
    lotId,
    productId,
    description,
    quantity,
    unitPrice,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supply_sale_item_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplySaleItemEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplySaleItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplySaleItemEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_id'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_price'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $SupplySaleItemEntriesTable createAlias(String alias) {
    return $SupplySaleItemEntriesTable(attachedDatabase, alias);
  }
}

class SupplySaleItemEntry extends DataClass
    implements Insertable<SupplySaleItemEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String saleId;

  /// El lote que cubrió la línea. **Nulo mientras la venta no ha subido**: qué
  /// lote sale es la respuesta del FIFO del servidor (D5), y el mostrador elige
  /// un producto, nunca un lote.
  final String? lotId;

  /// El producto que se eligió. Columna local, no del feed: es lo único que el
  /// dispositivo sabe de una línea capturada, y es lo que deja descontar el
  /// stock en pantalla antes de que el servidor conteste. En las filas que baja
  /// el feed va nulo y el producto se resuelve por el lote.
  final String? productId;
  final String description;
  final String quantity;
  final String unitPrice;
  final String amount;
  const SupplySaleItemEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.saleId,
    this.lotId,
    this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sale_id'] = Variable<String>(saleId);
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<String>(lotId);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<String>(quantity);
    map['unit_price'] = Variable<String>(unitPrice);
    map['amount'] = Variable<String>(amount);
    return map;
  }

  SupplySaleItemEntriesCompanion toCompanion(bool nullToAbsent) {
    return SupplySaleItemEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      saleId: Value(saleId),
      lotId: lotId == null && nullToAbsent
          ? const Value.absent()
          : Value(lotId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      description: Value(description),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      amount: Value(amount),
    );
  }

  factory SupplySaleItemEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplySaleItemEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      saleId: serializer.fromJson<String>(json['saleId']),
      lotId: serializer.fromJson<String?>(json['lotId']),
      productId: serializer.fromJson<String?>(json['productId']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unitPrice: serializer.fromJson<String>(json['unitPrice']),
      amount: serializer.fromJson<String>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'saleId': serializer.toJson<String>(saleId),
      'lotId': serializer.toJson<String?>(lotId),
      'productId': serializer.toJson<String?>(productId),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<String>(quantity),
      'unitPrice': serializer.toJson<String>(unitPrice),
      'amount': serializer.toJson<String>(amount),
    };
  }

  SupplySaleItemEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? saleId,
    Value<String?> lotId = const Value.absent(),
    Value<String?> productId = const Value.absent(),
    String? description,
    String? quantity,
    String? unitPrice,
    String? amount,
  }) => SupplySaleItemEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    saleId: saleId ?? this.saleId,
    lotId: lotId.present ? lotId.value : this.lotId,
    productId: productId.present ? productId.value : this.productId,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    amount: amount ?? this.amount,
  );
  SupplySaleItemEntry copyWithCompanion(SupplySaleItemEntriesCompanion data) {
    return SupplySaleItemEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      productId: data.productId.present ? data.productId.value : this.productId,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplySaleItemEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleId: $saleId, ')
          ..write('lotId: $lotId, ')
          ..write('productId: $productId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    saleId,
    lotId,
    productId,
    description,
    quantity,
    unitPrice,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplySaleItemEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.saleId == this.saleId &&
          other.lotId == this.lotId &&
          other.productId == this.productId &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.amount == this.amount);
}

class SupplySaleItemEntriesCompanion
    extends UpdateCompanion<SupplySaleItemEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> saleId;
  final Value<String?> lotId;
  final Value<String?> productId;
  final Value<String> description;
  final Value<String> quantity;
  final Value<String> unitPrice;
  final Value<String> amount;
  final Value<int> rowid;
  const SupplySaleItemEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.saleId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.productId = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplySaleItemEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String saleId,
    this.lotId = const Value.absent(),
    this.productId = const Value.absent(),
    required String description,
    required String quantity,
    required String unitPrice,
    required String amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       description = Value(description),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       amount = Value(amount);
  static Insertable<SupplySaleItemEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? saleId,
    Expression<String>? lotId,
    Expression<String>? productId,
    Expression<String>? description,
    Expression<String>? quantity,
    Expression<String>? unitPrice,
    Expression<String>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (saleId != null) 'sale_id': saleId,
      if (lotId != null) 'lot_id': lotId,
      if (productId != null) 'product_id': productId,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplySaleItemEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? saleId,
    Value<String?>? lotId,
    Value<String?>? productId,
    Value<String>? description,
    Value<String>? quantity,
    Value<String>? unitPrice,
    Value<String>? amount,
    Value<int>? rowid,
  }) {
    return SupplySaleItemEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      saleId: saleId ?? this.saleId,
      lotId: lotId ?? this.lotId,
      productId: productId ?? this.productId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplySaleItemEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('saleId: $saleId, ')
          ..write('lotId: $lotId, ')
          ..write('productId: $productId, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyClosureEntriesTable extends DailyClosureEntries
    with TableInfo<$DailyClosureEntriesTable, DailyClosureEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyClosureEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RowSyncStatus.synced.name),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closeDateMeta = const VerificationMeta(
    'closeDate',
  );
  @override
  late final GeneratedColumn<String> closeDate = GeneratedColumn<String>(
    'close_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordersIncomeMeta = const VerificationMeta(
    'ordersIncome',
  );
  @override
  late final GeneratedColumn<String> ordersIncome = GeneratedColumn<String>(
    'orders_income',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suppliesIncomeMeta = const VerificationMeta(
    'suppliesIncome',
  );
  @override
  late final GeneratedColumn<String> suppliesIncome = GeneratedColumn<String>(
    'supplies_income',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expensesTotalMeta = const VerificationMeta(
    'expensesTotal',
  );
  @override
  late final GeneratedColumn<String> expensesTotal = GeneratedColumn<String>(
    'expenses_total',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netTotalMeta = const VerificationMeta(
    'netTotal',
  );
  @override
  late final GeneratedColumn<String> netTotal = GeneratedColumn<String>(
    'net_total',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashIncomeMeta = const VerificationMeta(
    'cashIncome',
  );
  @override
  late final GeneratedColumn<String> cashIncome = GeneratedColumn<String>(
    'cash_income',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferIncomeMeta = const VerificationMeta(
    'transferIncome',
  );
  @override
  late final GeneratedColumn<String> transferIncome = GeneratedColumn<String>(
    'transfer_income',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashExpensesMeta = const VerificationMeta(
    'cashExpenses',
  );
  @override
  late final GeneratedColumn<String> cashExpenses = GeneratedColumn<String>(
    'cash_expenses',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferExpensesMeta = const VerificationMeta(
    'transferExpenses',
  );
  @override
  late final GeneratedColumn<String> transferExpenses = GeneratedColumn<String>(
    'transfer_expenses',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 20),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordersDeliveredMeta = const VerificationMeta(
    'ordersDelivered',
  );
  @override
  late final GeneratedColumn<int> ordersDelivered = GeneratedColumn<int>(
    'orders_delivered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedByIdMeta = const VerificationMeta(
    'closedById',
  );
  @override
  late final GeneratedColumn<String> closedById = GeneratedColumn<String>(
    'closed_by_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reopenedByIdMeta = const VerificationMeta(
    'reopenedById',
  );
  @override
  late final GeneratedColumn<String> reopenedById = GeneratedColumn<String>(
    'reopened_by_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reopenReasonMeta = const VerificationMeta(
    'reopenReason',
  );
  @override
  late final GeneratedColumn<String> reopenReason = GeneratedColumn<String>(
    'reopen_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    syncStatus,
    deletedAt,
    closeDate,
    ordersIncome,
    suppliesIncome,
    expensesTotal,
    netTotal,
    cashIncome,
    transferIncome,
    cashExpenses,
    transferExpenses,
    ordersDelivered,
    notes,
    closedById,
    closedAt,
    reopenedById,
    reopenReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_closure_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyClosureEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('close_date')) {
      context.handle(
        _closeDateMeta,
        closeDate.isAcceptableOrUnknown(data['close_date']!, _closeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_closeDateMeta);
    }
    if (data.containsKey('orders_income')) {
      context.handle(
        _ordersIncomeMeta,
        ordersIncome.isAcceptableOrUnknown(
          data['orders_income']!,
          _ordersIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordersIncomeMeta);
    }
    if (data.containsKey('supplies_income')) {
      context.handle(
        _suppliesIncomeMeta,
        suppliesIncome.isAcceptableOrUnknown(
          data['supplies_income']!,
          _suppliesIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_suppliesIncomeMeta);
    }
    if (data.containsKey('expenses_total')) {
      context.handle(
        _expensesTotalMeta,
        expensesTotal.isAcceptableOrUnknown(
          data['expenses_total']!,
          _expensesTotalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expensesTotalMeta);
    }
    if (data.containsKey('net_total')) {
      context.handle(
        _netTotalMeta,
        netTotal.isAcceptableOrUnknown(data['net_total']!, _netTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_netTotalMeta);
    }
    if (data.containsKey('cash_income')) {
      context.handle(
        _cashIncomeMeta,
        cashIncome.isAcceptableOrUnknown(data['cash_income']!, _cashIncomeMeta),
      );
    } else if (isInserting) {
      context.missing(_cashIncomeMeta);
    }
    if (data.containsKey('transfer_income')) {
      context.handle(
        _transferIncomeMeta,
        transferIncome.isAcceptableOrUnknown(
          data['transfer_income']!,
          _transferIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferIncomeMeta);
    }
    if (data.containsKey('cash_expenses')) {
      context.handle(
        _cashExpensesMeta,
        cashExpenses.isAcceptableOrUnknown(
          data['cash_expenses']!,
          _cashExpensesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cashExpensesMeta);
    }
    if (data.containsKey('transfer_expenses')) {
      context.handle(
        _transferExpensesMeta,
        transferExpenses.isAcceptableOrUnknown(
          data['transfer_expenses']!,
          _transferExpensesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transferExpensesMeta);
    }
    if (data.containsKey('orders_delivered')) {
      context.handle(
        _ordersDeliveredMeta,
        ordersDelivered.isAcceptableOrUnknown(
          data['orders_delivered']!,
          _ordersDeliveredMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('closed_by_id')) {
      context.handle(
        _closedByIdMeta,
        closedById.isAcceptableOrUnknown(
          data['closed_by_id']!,
          _closedByIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_closedByIdMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_closedAtMeta);
    }
    if (data.containsKey('reopened_by_id')) {
      context.handle(
        _reopenedByIdMeta,
        reopenedById.isAcceptableOrUnknown(
          data['reopened_by_id']!,
          _reopenedByIdMeta,
        ),
      );
    }
    if (data.containsKey('reopen_reason')) {
      context.handle(
        _reopenReasonMeta,
        reopenReason.isAcceptableOrUnknown(
          data['reopen_reason']!,
          _reopenReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyClosureEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyClosureEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      closeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}close_date'],
      )!,
      ordersIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orders_income'],
      )!,
      suppliesIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplies_income'],
      )!,
      expensesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expenses_total'],
      )!,
      netTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}net_total'],
      )!,
      cashIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_income'],
      )!,
      transferIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_income'],
      )!,
      cashExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cash_expenses'],
      )!,
      transferExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_expenses'],
      )!,
      ordersDelivered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orders_delivered'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      closedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_id'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      )!,
      reopenedById: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reopened_by_id'],
      ),
      reopenReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reopen_reason'],
      ),
    );
  }

  @override
  $DailyClosureEntriesTable createAlias(String alias) {
    return $DailyClosureEntriesTable(attachedDatabase, alias);
  }
}

class DailyClosureEntry extends DataClass
    implements Insertable<DailyClosureEntry> {
  /// UUID generado por quien creó la fila, dispositivo o servidor (D3).
  final String id;

  /// Versión conocida del servidor. `0` mientras la fila solo existe local.
  final int version;
  final String syncStatus;

  /// Tombstone: la fila se conserva para que el borrado se propague, pero no
  /// se muestra (D8).
  final DateTime? deletedAt;
  final String closeDate;
  final String ordersIncome;
  final String suppliesIncome;
  final String expensesTotal;
  final String netTotal;
  final String cashIncome;
  final String transferIncome;

  /// Solo lo que de verdad salió del cajón: un gasto `pending` cuenta contra el
  /// día pero no contra el arqueo.
  final String cashExpenses;
  final String transferExpenses;
  final int ordersDelivered;
  final String? notes;
  final String closedById;
  final DateTime closedAt;

  /// Quién reabrió el día y por qué. Reabrir es **la lápida misma** (D9): el
  /// servidor pone `deleted_at` y estas dos columnas le ponen nombre. De ahí que
  /// «la fecha está cerrada» se lea aquí como «hay una fila viva con esa fecha»
  /// y no como «existe un acta»: el acta reabierta se conserva, y tiene que
  /// conservarse, porque un día cerrado en Q764 y luego reabierto es un hecho.
  final String? reopenedById;
  final String? reopenReason;
  const DailyClosureEntry({
    required this.id,
    required this.version,
    required this.syncStatus,
    this.deletedAt,
    required this.closeDate,
    required this.ordersIncome,
    required this.suppliesIncome,
    required this.expensesTotal,
    required this.netTotal,
    required this.cashIncome,
    required this.transferIncome,
    required this.cashExpenses,
    required this.transferExpenses,
    required this.ordersDelivered,
    this.notes,
    required this.closedById,
    required this.closedAt,
    this.reopenedById,
    this.reopenReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['close_date'] = Variable<String>(closeDate);
    map['orders_income'] = Variable<String>(ordersIncome);
    map['supplies_income'] = Variable<String>(suppliesIncome);
    map['expenses_total'] = Variable<String>(expensesTotal);
    map['net_total'] = Variable<String>(netTotal);
    map['cash_income'] = Variable<String>(cashIncome);
    map['transfer_income'] = Variable<String>(transferIncome);
    map['cash_expenses'] = Variable<String>(cashExpenses);
    map['transfer_expenses'] = Variable<String>(transferExpenses);
    map['orders_delivered'] = Variable<int>(ordersDelivered);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['closed_by_id'] = Variable<String>(closedById);
    map['closed_at'] = Variable<DateTime>(closedAt);
    if (!nullToAbsent || reopenedById != null) {
      map['reopened_by_id'] = Variable<String>(reopenedById);
    }
    if (!nullToAbsent || reopenReason != null) {
      map['reopen_reason'] = Variable<String>(reopenReason);
    }
    return map;
  }

  DailyClosureEntriesCompanion toCompanion(bool nullToAbsent) {
    return DailyClosureEntriesCompanion(
      id: Value(id),
      version: Value(version),
      syncStatus: Value(syncStatus),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      closeDate: Value(closeDate),
      ordersIncome: Value(ordersIncome),
      suppliesIncome: Value(suppliesIncome),
      expensesTotal: Value(expensesTotal),
      netTotal: Value(netTotal),
      cashIncome: Value(cashIncome),
      transferIncome: Value(transferIncome),
      cashExpenses: Value(cashExpenses),
      transferExpenses: Value(transferExpenses),
      ordersDelivered: Value(ordersDelivered),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      closedById: Value(closedById),
      closedAt: Value(closedAt),
      reopenedById: reopenedById == null && nullToAbsent
          ? const Value.absent()
          : Value(reopenedById),
      reopenReason: reopenReason == null && nullToAbsent
          ? const Value.absent()
          : Value(reopenReason),
    );
  }

  factory DailyClosureEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyClosureEntry(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      closeDate: serializer.fromJson<String>(json['closeDate']),
      ordersIncome: serializer.fromJson<String>(json['ordersIncome']),
      suppliesIncome: serializer.fromJson<String>(json['suppliesIncome']),
      expensesTotal: serializer.fromJson<String>(json['expensesTotal']),
      netTotal: serializer.fromJson<String>(json['netTotal']),
      cashIncome: serializer.fromJson<String>(json['cashIncome']),
      transferIncome: serializer.fromJson<String>(json['transferIncome']),
      cashExpenses: serializer.fromJson<String>(json['cashExpenses']),
      transferExpenses: serializer.fromJson<String>(json['transferExpenses']),
      ordersDelivered: serializer.fromJson<int>(json['ordersDelivered']),
      notes: serializer.fromJson<String?>(json['notes']),
      closedById: serializer.fromJson<String>(json['closedById']),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
      reopenedById: serializer.fromJson<String?>(json['reopenedById']),
      reopenReason: serializer.fromJson<String?>(json['reopenReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'closeDate': serializer.toJson<String>(closeDate),
      'ordersIncome': serializer.toJson<String>(ordersIncome),
      'suppliesIncome': serializer.toJson<String>(suppliesIncome),
      'expensesTotal': serializer.toJson<String>(expensesTotal),
      'netTotal': serializer.toJson<String>(netTotal),
      'cashIncome': serializer.toJson<String>(cashIncome),
      'transferIncome': serializer.toJson<String>(transferIncome),
      'cashExpenses': serializer.toJson<String>(cashExpenses),
      'transferExpenses': serializer.toJson<String>(transferExpenses),
      'ordersDelivered': serializer.toJson<int>(ordersDelivered),
      'notes': serializer.toJson<String?>(notes),
      'closedById': serializer.toJson<String>(closedById),
      'closedAt': serializer.toJson<DateTime>(closedAt),
      'reopenedById': serializer.toJson<String?>(reopenedById),
      'reopenReason': serializer.toJson<String?>(reopenReason),
    };
  }

  DailyClosureEntry copyWith({
    String? id,
    int? version,
    String? syncStatus,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? closeDate,
    String? ordersIncome,
    String? suppliesIncome,
    String? expensesTotal,
    String? netTotal,
    String? cashIncome,
    String? transferIncome,
    String? cashExpenses,
    String? transferExpenses,
    int? ordersDelivered,
    Value<String?> notes = const Value.absent(),
    String? closedById,
    DateTime? closedAt,
    Value<String?> reopenedById = const Value.absent(),
    Value<String?> reopenReason = const Value.absent(),
  }) => DailyClosureEntry(
    id: id ?? this.id,
    version: version ?? this.version,
    syncStatus: syncStatus ?? this.syncStatus,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    closeDate: closeDate ?? this.closeDate,
    ordersIncome: ordersIncome ?? this.ordersIncome,
    suppliesIncome: suppliesIncome ?? this.suppliesIncome,
    expensesTotal: expensesTotal ?? this.expensesTotal,
    netTotal: netTotal ?? this.netTotal,
    cashIncome: cashIncome ?? this.cashIncome,
    transferIncome: transferIncome ?? this.transferIncome,
    cashExpenses: cashExpenses ?? this.cashExpenses,
    transferExpenses: transferExpenses ?? this.transferExpenses,
    ordersDelivered: ordersDelivered ?? this.ordersDelivered,
    notes: notes.present ? notes.value : this.notes,
    closedById: closedById ?? this.closedById,
    closedAt: closedAt ?? this.closedAt,
    reopenedById: reopenedById.present ? reopenedById.value : this.reopenedById,
    reopenReason: reopenReason.present ? reopenReason.value : this.reopenReason,
  );
  DailyClosureEntry copyWithCompanion(DailyClosureEntriesCompanion data) {
    return DailyClosureEntry(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      closeDate: data.closeDate.present ? data.closeDate.value : this.closeDate,
      ordersIncome: data.ordersIncome.present
          ? data.ordersIncome.value
          : this.ordersIncome,
      suppliesIncome: data.suppliesIncome.present
          ? data.suppliesIncome.value
          : this.suppliesIncome,
      expensesTotal: data.expensesTotal.present
          ? data.expensesTotal.value
          : this.expensesTotal,
      netTotal: data.netTotal.present ? data.netTotal.value : this.netTotal,
      cashIncome: data.cashIncome.present
          ? data.cashIncome.value
          : this.cashIncome,
      transferIncome: data.transferIncome.present
          ? data.transferIncome.value
          : this.transferIncome,
      cashExpenses: data.cashExpenses.present
          ? data.cashExpenses.value
          : this.cashExpenses,
      transferExpenses: data.transferExpenses.present
          ? data.transferExpenses.value
          : this.transferExpenses,
      ordersDelivered: data.ordersDelivered.present
          ? data.ordersDelivered.value
          : this.ordersDelivered,
      notes: data.notes.present ? data.notes.value : this.notes,
      closedById: data.closedById.present
          ? data.closedById.value
          : this.closedById,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      reopenedById: data.reopenedById.present
          ? data.reopenedById.value
          : this.reopenedById,
      reopenReason: data.reopenReason.present
          ? data.reopenReason.value
          : this.reopenReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosureEntry(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('closeDate: $closeDate, ')
          ..write('ordersIncome: $ordersIncome, ')
          ..write('suppliesIncome: $suppliesIncome, ')
          ..write('expensesTotal: $expensesTotal, ')
          ..write('netTotal: $netTotal, ')
          ..write('cashIncome: $cashIncome, ')
          ..write('transferIncome: $transferIncome, ')
          ..write('cashExpenses: $cashExpenses, ')
          ..write('transferExpenses: $transferExpenses, ')
          ..write('ordersDelivered: $ordersDelivered, ')
          ..write('notes: $notes, ')
          ..write('closedById: $closedById, ')
          ..write('closedAt: $closedAt, ')
          ..write('reopenedById: $reopenedById, ')
          ..write('reopenReason: $reopenReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    syncStatus,
    deletedAt,
    closeDate,
    ordersIncome,
    suppliesIncome,
    expensesTotal,
    netTotal,
    cashIncome,
    transferIncome,
    cashExpenses,
    transferExpenses,
    ordersDelivered,
    notes,
    closedById,
    closedAt,
    reopenedById,
    reopenReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyClosureEntry &&
          other.id == this.id &&
          other.version == this.version &&
          other.syncStatus == this.syncStatus &&
          other.deletedAt == this.deletedAt &&
          other.closeDate == this.closeDate &&
          other.ordersIncome == this.ordersIncome &&
          other.suppliesIncome == this.suppliesIncome &&
          other.expensesTotal == this.expensesTotal &&
          other.netTotal == this.netTotal &&
          other.cashIncome == this.cashIncome &&
          other.transferIncome == this.transferIncome &&
          other.cashExpenses == this.cashExpenses &&
          other.transferExpenses == this.transferExpenses &&
          other.ordersDelivered == this.ordersDelivered &&
          other.notes == this.notes &&
          other.closedById == this.closedById &&
          other.closedAt == this.closedAt &&
          other.reopenedById == this.reopenedById &&
          other.reopenReason == this.reopenReason);
}

class DailyClosureEntriesCompanion extends UpdateCompanion<DailyClosureEntry> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> syncStatus;
  final Value<DateTime?> deletedAt;
  final Value<String> closeDate;
  final Value<String> ordersIncome;
  final Value<String> suppliesIncome;
  final Value<String> expensesTotal;
  final Value<String> netTotal;
  final Value<String> cashIncome;
  final Value<String> transferIncome;
  final Value<String> cashExpenses;
  final Value<String> transferExpenses;
  final Value<int> ordersDelivered;
  final Value<String?> notes;
  final Value<String> closedById;
  final Value<DateTime> closedAt;
  final Value<String?> reopenedById;
  final Value<String?> reopenReason;
  final Value<int> rowid;
  const DailyClosureEntriesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.ordersIncome = const Value.absent(),
    this.suppliesIncome = const Value.absent(),
    this.expensesTotal = const Value.absent(),
    this.netTotal = const Value.absent(),
    this.cashIncome = const Value.absent(),
    this.transferIncome = const Value.absent(),
    this.cashExpenses = const Value.absent(),
    this.transferExpenses = const Value.absent(),
    this.ordersDelivered = const Value.absent(),
    this.notes = const Value.absent(),
    this.closedById = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.reopenedById = const Value.absent(),
    this.reopenReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyClosureEntriesCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String closeDate,
    required String ordersIncome,
    required String suppliesIncome,
    required String expensesTotal,
    required String netTotal,
    required String cashIncome,
    required String transferIncome,
    required String cashExpenses,
    required String transferExpenses,
    this.ordersDelivered = const Value.absent(),
    this.notes = const Value.absent(),
    required String closedById,
    required DateTime closedAt,
    this.reopenedById = const Value.absent(),
    this.reopenReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       closeDate = Value(closeDate),
       ordersIncome = Value(ordersIncome),
       suppliesIncome = Value(suppliesIncome),
       expensesTotal = Value(expensesTotal),
       netTotal = Value(netTotal),
       cashIncome = Value(cashIncome),
       transferIncome = Value(transferIncome),
       cashExpenses = Value(cashExpenses),
       transferExpenses = Value(transferExpenses),
       closedById = Value(closedById),
       closedAt = Value(closedAt);
  static Insertable<DailyClosureEntry> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? syncStatus,
    Expression<DateTime>? deletedAt,
    Expression<String>? closeDate,
    Expression<String>? ordersIncome,
    Expression<String>? suppliesIncome,
    Expression<String>? expensesTotal,
    Expression<String>? netTotal,
    Expression<String>? cashIncome,
    Expression<String>? transferIncome,
    Expression<String>? cashExpenses,
    Expression<String>? transferExpenses,
    Expression<int>? ordersDelivered,
    Expression<String>? notes,
    Expression<String>? closedById,
    Expression<DateTime>? closedAt,
    Expression<String>? reopenedById,
    Expression<String>? reopenReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (closeDate != null) 'close_date': closeDate,
      if (ordersIncome != null) 'orders_income': ordersIncome,
      if (suppliesIncome != null) 'supplies_income': suppliesIncome,
      if (expensesTotal != null) 'expenses_total': expensesTotal,
      if (netTotal != null) 'net_total': netTotal,
      if (cashIncome != null) 'cash_income': cashIncome,
      if (transferIncome != null) 'transfer_income': transferIncome,
      if (cashExpenses != null) 'cash_expenses': cashExpenses,
      if (transferExpenses != null) 'transfer_expenses': transferExpenses,
      if (ordersDelivered != null) 'orders_delivered': ordersDelivered,
      if (notes != null) 'notes': notes,
      if (closedById != null) 'closed_by_id': closedById,
      if (closedAt != null) 'closed_at': closedAt,
      if (reopenedById != null) 'reopened_by_id': reopenedById,
      if (reopenReason != null) 'reopen_reason': reopenReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyClosureEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? syncStatus,
    Value<DateTime?>? deletedAt,
    Value<String>? closeDate,
    Value<String>? ordersIncome,
    Value<String>? suppliesIncome,
    Value<String>? expensesTotal,
    Value<String>? netTotal,
    Value<String>? cashIncome,
    Value<String>? transferIncome,
    Value<String>? cashExpenses,
    Value<String>? transferExpenses,
    Value<int>? ordersDelivered,
    Value<String?>? notes,
    Value<String>? closedById,
    Value<DateTime>? closedAt,
    Value<String?>? reopenedById,
    Value<String?>? reopenReason,
    Value<int>? rowid,
  }) {
    return DailyClosureEntriesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      syncStatus: syncStatus ?? this.syncStatus,
      deletedAt: deletedAt ?? this.deletedAt,
      closeDate: closeDate ?? this.closeDate,
      ordersIncome: ordersIncome ?? this.ordersIncome,
      suppliesIncome: suppliesIncome ?? this.suppliesIncome,
      expensesTotal: expensesTotal ?? this.expensesTotal,
      netTotal: netTotal ?? this.netTotal,
      cashIncome: cashIncome ?? this.cashIncome,
      transferIncome: transferIncome ?? this.transferIncome,
      cashExpenses: cashExpenses ?? this.cashExpenses,
      transferExpenses: transferExpenses ?? this.transferExpenses,
      ordersDelivered: ordersDelivered ?? this.ordersDelivered,
      notes: notes ?? this.notes,
      closedById: closedById ?? this.closedById,
      closedAt: closedAt ?? this.closedAt,
      reopenedById: reopenedById ?? this.reopenedById,
      reopenReason: reopenReason ?? this.reopenReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (closeDate.present) {
      map['close_date'] = Variable<String>(closeDate.value);
    }
    if (ordersIncome.present) {
      map['orders_income'] = Variable<String>(ordersIncome.value);
    }
    if (suppliesIncome.present) {
      map['supplies_income'] = Variable<String>(suppliesIncome.value);
    }
    if (expensesTotal.present) {
      map['expenses_total'] = Variable<String>(expensesTotal.value);
    }
    if (netTotal.present) {
      map['net_total'] = Variable<String>(netTotal.value);
    }
    if (cashIncome.present) {
      map['cash_income'] = Variable<String>(cashIncome.value);
    }
    if (transferIncome.present) {
      map['transfer_income'] = Variable<String>(transferIncome.value);
    }
    if (cashExpenses.present) {
      map['cash_expenses'] = Variable<String>(cashExpenses.value);
    }
    if (transferExpenses.present) {
      map['transfer_expenses'] = Variable<String>(transferExpenses.value);
    }
    if (ordersDelivered.present) {
      map['orders_delivered'] = Variable<int>(ordersDelivered.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (closedById.present) {
      map['closed_by_id'] = Variable<String>(closedById.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (reopenedById.present) {
      map['reopened_by_id'] = Variable<String>(reopenedById.value);
    }
    if (reopenReason.present) {
      map['reopen_reason'] = Variable<String>(reopenReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosureEntriesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('closeDate: $closeDate, ')
          ..write('ordersIncome: $ordersIncome, ')
          ..write('suppliesIncome: $suppliesIncome, ')
          ..write('expensesTotal: $expensesTotal, ')
          ..write('netTotal: $netTotal, ')
          ..write('cashIncome: $cashIncome, ')
          ..write('transferIncome: $transferIncome, ')
          ..write('cashExpenses: $cashExpenses, ')
          ..write('transferExpenses: $transferExpenses, ')
          ..write('ordersDelivered: $ordersDelivered, ')
          ..write('notes: $notes, ')
          ..write('closedById: $closedById, ')
          ..write('closedAt: $closedAt, ')
          ..write('reopenedById: $reopenedById, ')
          ..write('reopenReason: $reopenReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncStateEntriesTable syncStateEntries = $SyncStateEntriesTable(
    this,
  );
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $ReviewEntriesTable reviewEntries = $ReviewEntriesTable(this);
  late final $DeferredChangesTable deferredChanges = $DeferredChangesTable(
    this,
  );
  late final $ServiceTypeEntriesTable serviceTypeEntries =
      $ServiceTypeEntriesTable(this);
  late final $ServiceOptionEntriesTable serviceOptionEntries =
      $ServiceOptionEntriesTable(this);
  late final $ServicePriceEntriesTable servicePriceEntries =
      $ServicePriceEntriesTable(this);
  late final $GarmentTypeEntriesTable garmentTypeEntries =
      $GarmentTypeEntriesTable(this);
  late final $CustomerEntriesTable customerEntries = $CustomerEntriesTable(
    this,
  );
  late final $OrderEntriesTable orderEntries = $OrderEntriesTable(this);
  late final $OrderGarmentEntriesTable orderGarmentEntries =
      $OrderGarmentEntriesTable(this);
  late final $OrderChargeEntriesTable orderChargeEntries =
      $OrderChargeEntriesTable(this);
  late final $OrderDiscountEntriesTable orderDiscountEntries =
      $OrderDiscountEntriesTable(this);
  late final $OrderPaymentEntriesTable orderPaymentEntries =
      $OrderPaymentEntriesTable(this);
  late final $PromotionEntriesTable promotionEntries = $PromotionEntriesTable(
    this,
  );
  late final $ExpenseCategoryEntriesTable expenseCategoryEntries =
      $ExpenseCategoryEntriesTable(this);
  late final $ExpenseEntriesTable expenseEntries = $ExpenseEntriesTable(this);
  late final $ProductEntriesTable productEntries = $ProductEntriesTable(this);
  late final $ProductLotEntriesTable productLotEntries =
      $ProductLotEntriesTable(this);
  late final $SupplySaleEntriesTable supplySaleEntries =
      $SupplySaleEntriesTable(this);
  late final $SupplySaleItemEntriesTable supplySaleItemEntries =
      $SupplySaleItemEntriesTable(this);
  late final $DailyClosureEntriesTable dailyClosureEntries =
      $DailyClosureEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncStateEntries,
    outboxEntries,
    reviewEntries,
    deferredChanges,
    serviceTypeEntries,
    serviceOptionEntries,
    servicePriceEntries,
    garmentTypeEntries,
    customerEntries,
    orderEntries,
    orderGarmentEntries,
    orderChargeEntries,
    orderDiscountEntries,
    orderPaymentEntries,
    promotionEntries,
    expenseCategoryEntries,
    expenseEntries,
    productEntries,
    productLotEntries,
    supplySaleEntries,
    supplySaleItemEntries,
    dailyClosureEntries,
  ];
}

typedef $$SyncStateEntriesTableCreateCompanionBuilder =
    SyncStateEntriesCompanion Function({
      Value<int> id,
      Value<String?> deviceId,
      Value<bool> deviceRegistered,
      Value<int> pullCursor,
      Value<bool> bootstrapCompleted,
      Value<DateTime?> lastPushAt,
      Value<DateTime?> lastPullAt,
      Value<DateTime?> lastCycleAt,
      Value<String?> lastError,
      Value<int?> clockSkewSeconds,
    });
typedef $$SyncStateEntriesTableUpdateCompanionBuilder =
    SyncStateEntriesCompanion Function({
      Value<int> id,
      Value<String?> deviceId,
      Value<bool> deviceRegistered,
      Value<int> pullCursor,
      Value<bool> bootstrapCompleted,
      Value<DateTime?> lastPushAt,
      Value<DateTime?> lastPullAt,
      Value<DateTime?> lastCycleAt,
      Value<String?> lastError,
      Value<int?> clockSkewSeconds,
    });

class $$SyncStateEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateEntriesTable> {
  $$SyncStateEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deviceRegistered => $composableBuilder(
    column: $table.deviceRegistered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bootstrapCompleted => $composableBuilder(
    column: $table.bootstrapCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCycleAt => $composableBuilder(
    column: $table.lastCycleAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockSkewSeconds => $composableBuilder(
    column: $table.clockSkewSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateEntriesTable> {
  $$SyncStateEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deviceRegistered => $composableBuilder(
    column: $table.deviceRegistered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bootstrapCompleted => $composableBuilder(
    column: $table.bootstrapCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCycleAt => $composableBuilder(
    column: $table.lastCycleAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockSkewSeconds => $composableBuilder(
    column: $table.clockSkewSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateEntriesTable> {
  $$SyncStateEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get deviceRegistered => $composableBuilder(
    column: $table.deviceRegistered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pullCursor => $composableBuilder(
    column: $table.pullCursor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bootstrapCompleted => $composableBuilder(
    column: $table.bootstrapCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCycleAt => $composableBuilder(
    column: $table.lastCycleAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get clockSkewSeconds => $composableBuilder(
    column: $table.clockSkewSeconds,
    builder: (column) => column,
  );
}

class $$SyncStateEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateEntriesTable,
          SyncStateEntry,
          $$SyncStateEntriesTableFilterComposer,
          $$SyncStateEntriesTableOrderingComposer,
          $$SyncStateEntriesTableAnnotationComposer,
          $$SyncStateEntriesTableCreateCompanionBuilder,
          $$SyncStateEntriesTableUpdateCompanionBuilder,
          (
            SyncStateEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncStateEntriesTable,
              SyncStateEntry
            >,
          ),
          SyncStateEntry,
          PrefetchHooks Function()
        > {
  $$SyncStateEntriesTableTableManager(
    _$AppDatabase db,
    $SyncStateEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<bool> deviceRegistered = const Value.absent(),
                Value<int> pullCursor = const Value.absent(),
                Value<bool> bootstrapCompleted = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<DateTime?> lastCycleAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int?> clockSkewSeconds = const Value.absent(),
              }) => SyncStateEntriesCompanion(
                id: id,
                deviceId: deviceId,
                deviceRegistered: deviceRegistered,
                pullCursor: pullCursor,
                bootstrapCompleted: bootstrapCompleted,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                lastCycleAt: lastCycleAt,
                lastError: lastError,
                clockSkewSeconds: clockSkewSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<bool> deviceRegistered = const Value.absent(),
                Value<int> pullCursor = const Value.absent(),
                Value<bool> bootstrapCompleted = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<DateTime?> lastCycleAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int?> clockSkewSeconds = const Value.absent(),
              }) => SyncStateEntriesCompanion.insert(
                id: id,
                deviceId: deviceId,
                deviceRegistered: deviceRegistered,
                pullCursor: pullCursor,
                bootstrapCompleted: bootstrapCompleted,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                lastCycleAt: lastCycleAt,
                lastError: lastError,
                clockSkewSeconds: clockSkewSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateEntriesTable,
      SyncStateEntry,
      $$SyncStateEntriesTableFilterComposer,
      $$SyncStateEntriesTableOrderingComposer,
      $$SyncStateEntriesTableAnnotationComposer,
      $$SyncStateEntriesTableCreateCompanionBuilder,
      $$SyncStateEntriesTableUpdateCompanionBuilder,
      (
        SyncStateEntry,
        BaseReferences<_$AppDatabase, $SyncStateEntriesTable, SyncStateEntry>,
      ),
      SyncStateEntry,
      PrefetchHooks Function()
    >;
typedef $$OutboxEntriesTableCreateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> seq,
      required String opId,
      required String entity,
      required String opType,
      required String entityId,
      Value<int?> baseVersion,
      required String payload,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String?> lastError,
    });
typedef $$OutboxEntriesTableUpdateCompanionBuilder =
    OutboxEntriesCompanion Function({
      Value<int> seq,
      Value<String> opId,
      Value<String> entity,
      Value<String> opType,
      Value<String> entityId,
      Value<int?> baseVersion,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
    });

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEntriesTable,
          OutboxEntry,
          $$OutboxEntriesTableFilterComposer,
          $$OutboxEntriesTableOrderingComposer,
          $$OutboxEntriesTableAnnotationComposer,
          $$OutboxEntriesTableCreateCompanionBuilder,
          $$OutboxEntriesTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int?> baseVersion = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion(
                seq: seq,
                opId: opId,
                entity: entity,
                opType: opType,
                entityId: entityId,
                baseVersion: baseVersion,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String opId,
                required String entity,
                required String opType,
                required String entityId,
                Value<int?> baseVersion = const Value.absent(),
                required String payload,
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxEntriesCompanion.insert(
                seq: seq,
                opId: opId,
                entity: entity,
                opType: opType,
                entityId: entityId,
                baseVersion: baseVersion,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEntriesTable,
      OutboxEntry,
      $$OutboxEntriesTableFilterComposer,
      $$OutboxEntriesTableOrderingComposer,
      $$OutboxEntriesTableAnnotationComposer,
      $$OutboxEntriesTableCreateCompanionBuilder,
      $$OutboxEntriesTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$ReviewEntriesTableCreateCompanionBuilder =
    ReviewEntriesCompanion Function({
      Value<int> id,
      required String opId,
      required String entity,
      required String opType,
      required String entityId,
      required String status,
      Value<String?> reason,
      required String localPayload,
      Value<String?> serverData,
      Value<int?> serverVersion,
      required DateTime createdAt,
      Value<DateTime?> resolvedAt,
    });
typedef $$ReviewEntriesTableUpdateCompanionBuilder =
    ReviewEntriesCompanion Function({
      Value<int> id,
      Value<String> opId,
      Value<String> entity,
      Value<String> opType,
      Value<String> entityId,
      Value<String> status,
      Value<String?> reason,
      Value<String> localPayload,
      Value<String?> serverData,
      Value<int?> serverVersion,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
    });

class $$ReviewEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewEntriesTable> {
  $$ReviewEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverData => $composableBuilder(
    column: $table.serverData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewEntriesTable> {
  $$ReviewEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverData => $composableBuilder(
    column: $table.serverData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewEntriesTable> {
  $$ReviewEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverData => $composableBuilder(
    column: $table.serverData,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$ReviewEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewEntriesTable,
          ReviewEntry,
          $$ReviewEntriesTableFilterComposer,
          $$ReviewEntriesTableOrderingComposer,
          $$ReviewEntriesTableAnnotationComposer,
          $$ReviewEntriesTableCreateCompanionBuilder,
          $$ReviewEntriesTableUpdateCompanionBuilder,
          (
            ReviewEntry,
            BaseReferences<_$AppDatabase, $ReviewEntriesTable, ReviewEntry>,
          ),
          ReviewEntry,
          PrefetchHooks Function()
        > {
  $$ReviewEntriesTableTableManager(_$AppDatabase db, $ReviewEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> localPayload = const Value.absent(),
                Value<String?> serverData = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => ReviewEntriesCompanion(
                id: id,
                opId: opId,
                entity: entity,
                opType: opType,
                entityId: entityId,
                status: status,
                reason: reason,
                localPayload: localPayload,
                serverData: serverData,
                serverVersion: serverVersion,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String opId,
                required String entity,
                required String opType,
                required String entityId,
                required String status,
                Value<String?> reason = const Value.absent(),
                required String localPayload,
                Value<String?> serverData = const Value.absent(),
                Value<int?> serverVersion = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => ReviewEntriesCompanion.insert(
                id: id,
                opId: opId,
                entity: entity,
                opType: opType,
                entityId: entityId,
                status: status,
                reason: reason,
                localPayload: localPayload,
                serverData: serverData,
                serverVersion: serverVersion,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewEntriesTable,
      ReviewEntry,
      $$ReviewEntriesTableFilterComposer,
      $$ReviewEntriesTableOrderingComposer,
      $$ReviewEntriesTableAnnotationComposer,
      $$ReviewEntriesTableCreateCompanionBuilder,
      $$ReviewEntriesTableUpdateCompanionBuilder,
      (
        ReviewEntry,
        BaseReferences<_$AppDatabase, $ReviewEntriesTable, ReviewEntry>,
      ),
      ReviewEntry,
      PrefetchHooks Function()
    >;
typedef $$DeferredChangesTableCreateCompanionBuilder =
    DeferredChangesCompanion Function({
      required String entity,
      required String entityId,
      required int version,
      required int syncSeq,
      required bool deleted,
      required String data,
      required DateTime receivedAt,
      Value<int> rowid,
    });
typedef $$DeferredChangesTableUpdateCompanionBuilder =
    DeferredChangesCompanion Function({
      Value<String> entity,
      Value<String> entityId,
      Value<int> version,
      Value<int> syncSeq,
      Value<bool> deleted,
      Value<String> data,
      Value<DateTime> receivedAt,
      Value<int> rowid,
    });

class $$DeferredChangesTableFilterComposer
    extends Composer<_$AppDatabase, $DeferredChangesTable> {
  $$DeferredChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncSeq => $composableBuilder(
    column: $table.syncSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeferredChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeferredChangesTable> {
  $$DeferredChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncSeq => $composableBuilder(
    column: $table.syncSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeferredChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeferredChangesTable> {
  $$DeferredChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get syncSeq =>
      $composableBuilder(column: $table.syncSeq, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$DeferredChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeferredChangesTable,
          DeferredChange,
          $$DeferredChangesTableFilterComposer,
          $$DeferredChangesTableOrderingComposer,
          $$DeferredChangesTableAnnotationComposer,
          $$DeferredChangesTableCreateCompanionBuilder,
          $$DeferredChangesTableUpdateCompanionBuilder,
          (
            DeferredChange,
            BaseReferences<
              _$AppDatabase,
              $DeferredChangesTable,
              DeferredChange
            >,
          ),
          DeferredChange,
          PrefetchHooks Function()
        > {
  $$DeferredChangesTableTableManager(
    _$AppDatabase db,
    $DeferredChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeferredChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeferredChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeferredChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> syncSeq = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeferredChangesCompanion(
                entity: entity,
                entityId: entityId,
                version: version,
                syncSeq: syncSeq,
                deleted: deleted,
                data: data,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String entityId,
                required int version,
                required int syncSeq,
                required bool deleted,
                required String data,
                required DateTime receivedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeferredChangesCompanion.insert(
                entity: entity,
                entityId: entityId,
                version: version,
                syncSeq: syncSeq,
                deleted: deleted,
                data: data,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeferredChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeferredChangesTable,
      DeferredChange,
      $$DeferredChangesTableFilterComposer,
      $$DeferredChangesTableOrderingComposer,
      $$DeferredChangesTableAnnotationComposer,
      $$DeferredChangesTableCreateCompanionBuilder,
      $$DeferredChangesTableUpdateCompanionBuilder,
      (
        DeferredChange,
        BaseReferences<_$AppDatabase, $DeferredChangesTable, DeferredChange>,
      ),
      DeferredChange,
      PrefetchHooks Function()
    >;
typedef $$ServiceTypeEntriesTableCreateCompanionBuilder =
    ServiceTypeEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String code,
      required String name,
      required String pricingMode,
      Value<String?> unitLabel,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ServiceTypeEntriesTableUpdateCompanionBuilder =
    ServiceTypeEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> code,
      Value<String> name,
      Value<String> pricingMode,
      Value<String?> unitLabel,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ServiceTypeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceTypeEntriesTable> {
  $$ServiceTypeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricingMode => $composableBuilder(
    column: $table.pricingMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitLabel => $composableBuilder(
    column: $table.unitLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceTypeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceTypeEntriesTable> {
  $$ServiceTypeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricingMode => $composableBuilder(
    column: $table.pricingMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitLabel => $composableBuilder(
    column: $table.unitLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceTypeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceTypeEntriesTable> {
  $$ServiceTypeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get pricingMode => $composableBuilder(
    column: $table.pricingMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitLabel =>
      $composableBuilder(column: $table.unitLabel, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ServiceTypeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceTypeEntriesTable,
          ServiceTypeEntry,
          $$ServiceTypeEntriesTableFilterComposer,
          $$ServiceTypeEntriesTableOrderingComposer,
          $$ServiceTypeEntriesTableAnnotationComposer,
          $$ServiceTypeEntriesTableCreateCompanionBuilder,
          $$ServiceTypeEntriesTableUpdateCompanionBuilder,
          (
            ServiceTypeEntry,
            BaseReferences<
              _$AppDatabase,
              $ServiceTypeEntriesTable,
              ServiceTypeEntry
            >,
          ),
          ServiceTypeEntry,
          PrefetchHooks Function()
        > {
  $$ServiceTypeEntriesTableTableManager(
    _$AppDatabase db,
    $ServiceTypeEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceTypeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceTypeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceTypeEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> pricingMode = const Value.absent(),
                Value<String?> unitLabel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceTypeEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                code: code,
                name: name,
                pricingMode: pricingMode,
                unitLabel: unitLabel,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String code,
                required String name,
                required String pricingMode,
                Value<String?> unitLabel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceTypeEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                code: code,
                name: name,
                pricingMode: pricingMode,
                unitLabel: unitLabel,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceTypeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceTypeEntriesTable,
      ServiceTypeEntry,
      $$ServiceTypeEntriesTableFilterComposer,
      $$ServiceTypeEntriesTableOrderingComposer,
      $$ServiceTypeEntriesTableAnnotationComposer,
      $$ServiceTypeEntriesTableCreateCompanionBuilder,
      $$ServiceTypeEntriesTableUpdateCompanionBuilder,
      (
        ServiceTypeEntry,
        BaseReferences<
          _$AppDatabase,
          $ServiceTypeEntriesTable,
          ServiceTypeEntry
        >,
      ),
      ServiceTypeEntry,
      PrefetchHooks Function()
    >;
typedef $$ServiceOptionEntriesTableCreateCompanionBuilder =
    ServiceOptionEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String serviceTypeId,
      required String code,
      required String name,
      Value<int?> minQuantity,
      Value<int?> maxQuantity,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ServiceOptionEntriesTableUpdateCompanionBuilder =
    ServiceOptionEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> serviceTypeId,
      Value<String> code,
      Value<String> name,
      Value<int?> minQuantity,
      Value<int?> maxQuantity,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ServiceOptionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceOptionEntriesTable> {
  $$ServiceOptionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minQuantity => $composableBuilder(
    column: $table.minQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxQuantity => $composableBuilder(
    column: $table.maxQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceOptionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceOptionEntriesTable> {
  $$ServiceOptionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minQuantity => $composableBuilder(
    column: $table.minQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxQuantity => $composableBuilder(
    column: $table.maxQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceOptionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceOptionEntriesTable> {
  $$ServiceOptionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get minQuantity => $composableBuilder(
    column: $table.minQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxQuantity => $composableBuilder(
    column: $table.maxQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ServiceOptionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceOptionEntriesTable,
          ServiceOptionEntry,
          $$ServiceOptionEntriesTableFilterComposer,
          $$ServiceOptionEntriesTableOrderingComposer,
          $$ServiceOptionEntriesTableAnnotationComposer,
          $$ServiceOptionEntriesTableCreateCompanionBuilder,
          $$ServiceOptionEntriesTableUpdateCompanionBuilder,
          (
            ServiceOptionEntry,
            BaseReferences<
              _$AppDatabase,
              $ServiceOptionEntriesTable,
              ServiceOptionEntry
            >,
          ),
          ServiceOptionEntry,
          PrefetchHooks Function()
        > {
  $$ServiceOptionEntriesTableTableManager(
    _$AppDatabase db,
    $ServiceOptionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceOptionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceOptionEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ServiceOptionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> serviceTypeId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> minQuantity = const Value.absent(),
                Value<int?> maxQuantity = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceOptionEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                serviceTypeId: serviceTypeId,
                code: code,
                name: name,
                minQuantity: minQuantity,
                maxQuantity: maxQuantity,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String serviceTypeId,
                required String code,
                required String name,
                Value<int?> minQuantity = const Value.absent(),
                Value<int?> maxQuantity = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceOptionEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                serviceTypeId: serviceTypeId,
                code: code,
                name: name,
                minQuantity: minQuantity,
                maxQuantity: maxQuantity,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceOptionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceOptionEntriesTable,
      ServiceOptionEntry,
      $$ServiceOptionEntriesTableFilterComposer,
      $$ServiceOptionEntriesTableOrderingComposer,
      $$ServiceOptionEntriesTableAnnotationComposer,
      $$ServiceOptionEntriesTableCreateCompanionBuilder,
      $$ServiceOptionEntriesTableUpdateCompanionBuilder,
      (
        ServiceOptionEntry,
        BaseReferences<
          _$AppDatabase,
          $ServiceOptionEntriesTable,
          ServiceOptionEntry
        >,
      ),
      ServiceOptionEntry,
      PrefetchHooks Function()
    >;
typedef $$ServicePriceEntriesTableCreateCompanionBuilder =
    ServicePriceEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String serviceTypeId,
      Value<String?> serviceOptionId,
      required String price,
      required String validFrom,
      Value<String?> validTo,
      Value<int> rowid,
    });
typedef $$ServicePriceEntriesTableUpdateCompanionBuilder =
    ServicePriceEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> serviceTypeId,
      Value<String?> serviceOptionId,
      Value<String> price,
      Value<String> validFrom,
      Value<String?> validTo,
      Value<int> rowid,
    });

class $$ServicePriceEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ServicePriceEntriesTable> {
  $$ServicePriceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceOptionId => $composableBuilder(
    column: $table.serviceOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validTo => $composableBuilder(
    column: $table.validTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServicePriceEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicePriceEntriesTable> {
  $$ServicePriceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceOptionId => $composableBuilder(
    column: $table.serviceOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validTo => $composableBuilder(
    column: $table.validTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServicePriceEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicePriceEntriesTable> {
  $$ServicePriceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceOptionId => $composableBuilder(
    column: $table.serviceOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<String> get validTo =>
      $composableBuilder(column: $table.validTo, builder: (column) => column);
}

class $$ServicePriceEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServicePriceEntriesTable,
          ServicePriceEntry,
          $$ServicePriceEntriesTableFilterComposer,
          $$ServicePriceEntriesTableOrderingComposer,
          $$ServicePriceEntriesTableAnnotationComposer,
          $$ServicePriceEntriesTableCreateCompanionBuilder,
          $$ServicePriceEntriesTableUpdateCompanionBuilder,
          (
            ServicePriceEntry,
            BaseReferences<
              _$AppDatabase,
              $ServicePriceEntriesTable,
              ServicePriceEntry
            >,
          ),
          ServicePriceEntry,
          PrefetchHooks Function()
        > {
  $$ServicePriceEntriesTableTableManager(
    _$AppDatabase db,
    $ServicePriceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicePriceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicePriceEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ServicePriceEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> serviceTypeId = const Value.absent(),
                Value<String?> serviceOptionId = const Value.absent(),
                Value<String> price = const Value.absent(),
                Value<String> validFrom = const Value.absent(),
                Value<String?> validTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServicePriceEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                serviceTypeId: serviceTypeId,
                serviceOptionId: serviceOptionId,
                price: price,
                validFrom: validFrom,
                validTo: validTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String serviceTypeId,
                Value<String?> serviceOptionId = const Value.absent(),
                required String price,
                required String validFrom,
                Value<String?> validTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServicePriceEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                serviceTypeId: serviceTypeId,
                serviceOptionId: serviceOptionId,
                price: price,
                validFrom: validFrom,
                validTo: validTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServicePriceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServicePriceEntriesTable,
      ServicePriceEntry,
      $$ServicePriceEntriesTableFilterComposer,
      $$ServicePriceEntriesTableOrderingComposer,
      $$ServicePriceEntriesTableAnnotationComposer,
      $$ServicePriceEntriesTableCreateCompanionBuilder,
      $$ServicePriceEntriesTableUpdateCompanionBuilder,
      (
        ServicePriceEntry,
        BaseReferences<
          _$AppDatabase,
          $ServicePriceEntriesTable,
          ServicePriceEntry
        >,
      ),
      ServicePriceEntry,
      PrefetchHooks Function()
    >;
typedef $$GarmentTypeEntriesTableCreateCompanionBuilder =
    GarmentTypeEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String name,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$GarmentTypeEntriesTableUpdateCompanionBuilder =
    GarmentTypeEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String?> notes,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$GarmentTypeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $GarmentTypeEntriesTable> {
  $$GarmentTypeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GarmentTypeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $GarmentTypeEntriesTable> {
  $$GarmentTypeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GarmentTypeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarmentTypeEntriesTable> {
  $$GarmentTypeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$GarmentTypeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarmentTypeEntriesTable,
          GarmentTypeEntry,
          $$GarmentTypeEntriesTableFilterComposer,
          $$GarmentTypeEntriesTableOrderingComposer,
          $$GarmentTypeEntriesTableAnnotationComposer,
          $$GarmentTypeEntriesTableCreateCompanionBuilder,
          $$GarmentTypeEntriesTableUpdateCompanionBuilder,
          (
            GarmentTypeEntry,
            BaseReferences<
              _$AppDatabase,
              $GarmentTypeEntriesTable,
              GarmentTypeEntry
            >,
          ),
          GarmentTypeEntry,
          PrefetchHooks Function()
        > {
  $$GarmentTypeEntriesTableTableManager(
    _$AppDatabase db,
    $GarmentTypeEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarmentTypeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarmentTypeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarmentTypeEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GarmentTypeEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                name: name,
                notes: notes,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GarmentTypeEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                name: name,
                notes: notes,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GarmentTypeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarmentTypeEntriesTable,
      GarmentTypeEntry,
      $$GarmentTypeEntriesTableFilterComposer,
      $$GarmentTypeEntriesTableOrderingComposer,
      $$GarmentTypeEntriesTableAnnotationComposer,
      $$GarmentTypeEntriesTableCreateCompanionBuilder,
      $$GarmentTypeEntriesTableUpdateCompanionBuilder,
      (
        GarmentTypeEntry,
        BaseReferences<
          _$AppDatabase,
          $GarmentTypeEntriesTable,
          GarmentTypeEntry
        >,
      ),
      GarmentTypeEntry,
      PrefetchHooks Function()
    >;
typedef $$CustomerEntriesTableCreateCompanionBuilder =
    CustomerEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String fullName,
      Value<String?> phone,
      Value<String?> nit,
      Value<String?> email,
      Value<String?> address,
      Value<String?> notes,
      Value<bool> isActive,
      Value<String> searchIndex,
      Value<int> rowid,
    });
typedef $$CustomerEntriesTableUpdateCompanionBuilder =
    CustomerEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> fullName,
      Value<String?> phone,
      Value<String?> nit,
      Value<String?> email,
      Value<String?> address,
      Value<String?> notes,
      Value<bool> isActive,
      Value<String> searchIndex,
      Value<int> rowid,
    });

class $$CustomerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerEntriesTable> {
  $$CustomerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nit => $composableBuilder(
    column: $table.nit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchIndex => $composableBuilder(
    column: $table.searchIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerEntriesTable> {
  $$CustomerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nit => $composableBuilder(
    column: $table.nit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchIndex => $composableBuilder(
    column: $table.searchIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerEntriesTable> {
  $$CustomerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nit =>
      $composableBuilder(column: $table.nit, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get searchIndex => $composableBuilder(
    column: $table.searchIndex,
    builder: (column) => column,
  );
}

class $$CustomerEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerEntriesTable,
          CustomerEntry,
          $$CustomerEntriesTableFilterComposer,
          $$CustomerEntriesTableOrderingComposer,
          $$CustomerEntriesTableAnnotationComposer,
          $$CustomerEntriesTableCreateCompanionBuilder,
          $$CustomerEntriesTableUpdateCompanionBuilder,
          (
            CustomerEntry,
            BaseReferences<_$AppDatabase, $CustomerEntriesTable, CustomerEntry>,
          ),
          CustomerEntry,
          PrefetchHooks Function()
        > {
  $$CustomerEntriesTableTableManager(
    _$AppDatabase db,
    $CustomerEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> nit = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> searchIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                fullName: fullName,
                phone: phone,
                nit: nit,
                email: email,
                address: address,
                notes: notes,
                isActive: isActive,
                searchIndex: searchIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String fullName,
                Value<String?> phone = const Value.absent(),
                Value<String?> nit = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> searchIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                fullName: fullName,
                phone: phone,
                nit: nit,
                email: email,
                address: address,
                notes: notes,
                isActive: isActive,
                searchIndex: searchIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomerEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerEntriesTable,
      CustomerEntry,
      $$CustomerEntriesTableFilterComposer,
      $$CustomerEntriesTableOrderingComposer,
      $$CustomerEntriesTableAnnotationComposer,
      $$CustomerEntriesTableCreateCompanionBuilder,
      $$CustomerEntriesTableUpdateCompanionBuilder,
      (
        CustomerEntry,
        BaseReferences<_$AppDatabase, $CustomerEntriesTable, CustomerEntry>,
      ),
      CustomerEntry,
      PrefetchHooks Function()
    >;
typedef $$OrderEntriesTableCreateCompanionBuilder =
    OrderEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String orderDate,
      required int dailyNumber,
      Value<String?> bookletSerial,
      required String customerId,
      Value<String?> nit,
      Value<String?> weightLbs,
      Value<int> totalPieces,
      Value<String?> observations,
      required String status,
      required String subtotal,
      required String discountTotal,
      required String total,
      required String receivedById,
      Value<DateTime?> deliveredAt,
      Value<String?> deliveredById,
      Value<DateTime?> cancelledAt,
      Value<String?> cancelledById,
      Value<String?> cancelReason,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$OrderEntriesTableUpdateCompanionBuilder =
    OrderEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> orderDate,
      Value<int> dailyNumber,
      Value<String?> bookletSerial,
      Value<String> customerId,
      Value<String?> nit,
      Value<String?> weightLbs,
      Value<int> totalPieces,
      Value<String?> observations,
      Value<String> status,
      Value<String> subtotal,
      Value<String> discountTotal,
      Value<String> total,
      Value<String> receivedById,
      Value<DateTime?> deliveredAt,
      Value<String?> deliveredById,
      Value<DateTime?> cancelledAt,
      Value<String?> cancelledById,
      Value<String?> cancelReason,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$OrderEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderEntriesTable> {
  $$OrderEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderDate => $composableBuilder(
    column: $table.orderDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyNumber => $composableBuilder(
    column: $table.dailyNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookletSerial => $composableBuilder(
    column: $table.bookletSerial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nit => $composableBuilder(
    column: $table.nit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightLbs => $composableBuilder(
    column: $table.weightLbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPieces => $composableBuilder(
    column: $table.totalPieces,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountTotal => $composableBuilder(
    column: $table.discountTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedById => $composableBuilder(
    column: $table.receivedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveredById => $composableBuilder(
    column: $table.deliveredById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelledById => $composableBuilder(
    column: $table.cancelledById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderEntriesTable> {
  $$OrderEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderDate => $composableBuilder(
    column: $table.orderDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyNumber => $composableBuilder(
    column: $table.dailyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookletSerial => $composableBuilder(
    column: $table.bookletSerial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nit => $composableBuilder(
    column: $table.nit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightLbs => $composableBuilder(
    column: $table.weightLbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPieces => $composableBuilder(
    column: $table.totalPieces,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountTotal => $composableBuilder(
    column: $table.discountTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedById => $composableBuilder(
    column: $table.receivedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveredById => $composableBuilder(
    column: $table.deliveredById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelledById => $composableBuilder(
    column: $table.cancelledById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderEntriesTable> {
  $$OrderEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<int> get dailyNumber => $composableBuilder(
    column: $table.dailyNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookletSerial => $composableBuilder(
    column: $table.bookletSerial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nit =>
      $composableBuilder(column: $table.nit, builder: (column) => column);

  GeneratedColumn<String> get weightLbs =>
      $composableBuilder(column: $table.weightLbs, builder: (column) => column);

  GeneratedColumn<int> get totalPieces => $composableBuilder(
    column: $table.totalPieces,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get discountTotal => $composableBuilder(
    column: $table.discountTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get receivedById => $composableBuilder(
    column: $table.receivedById,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveredById => $composableBuilder(
    column: $table.deliveredById,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelledById => $composableBuilder(
    column: $table.cancelledById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OrderEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderEntriesTable,
          OrderEntry,
          $$OrderEntriesTableFilterComposer,
          $$OrderEntriesTableOrderingComposer,
          $$OrderEntriesTableAnnotationComposer,
          $$OrderEntriesTableCreateCompanionBuilder,
          $$OrderEntriesTableUpdateCompanionBuilder,
          (
            OrderEntry,
            BaseReferences<_$AppDatabase, $OrderEntriesTable, OrderEntry>,
          ),
          OrderEntry,
          PrefetchHooks Function()
        > {
  $$OrderEntriesTableTableManager(_$AppDatabase db, $OrderEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> orderDate = const Value.absent(),
                Value<int> dailyNumber = const Value.absent(),
                Value<String?> bookletSerial = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> nit = const Value.absent(),
                Value<String?> weightLbs = const Value.absent(),
                Value<int> totalPieces = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> subtotal = const Value.absent(),
                Value<String> discountTotal = const Value.absent(),
                Value<String> total = const Value.absent(),
                Value<String> receivedById = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<String?> deliveredById = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancelledById = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderDate: orderDate,
                dailyNumber: dailyNumber,
                bookletSerial: bookletSerial,
                customerId: customerId,
                nit: nit,
                weightLbs: weightLbs,
                totalPieces: totalPieces,
                observations: observations,
                status: status,
                subtotal: subtotal,
                discountTotal: discountTotal,
                total: total,
                receivedById: receivedById,
                deliveredAt: deliveredAt,
                deliveredById: deliveredById,
                cancelledAt: cancelledAt,
                cancelledById: cancelledById,
                cancelReason: cancelReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String orderDate,
                required int dailyNumber,
                Value<String?> bookletSerial = const Value.absent(),
                required String customerId,
                Value<String?> nit = const Value.absent(),
                Value<String?> weightLbs = const Value.absent(),
                Value<int> totalPieces = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                required String status,
                required String subtotal,
                required String discountTotal,
                required String total,
                required String receivedById,
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<String?> deliveredById = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancelledById = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderDate: orderDate,
                dailyNumber: dailyNumber,
                bookletSerial: bookletSerial,
                customerId: customerId,
                nit: nit,
                weightLbs: weightLbs,
                totalPieces: totalPieces,
                observations: observations,
                status: status,
                subtotal: subtotal,
                discountTotal: discountTotal,
                total: total,
                receivedById: receivedById,
                deliveredAt: deliveredAt,
                deliveredById: deliveredById,
                cancelledAt: cancelledAt,
                cancelledById: cancelledById,
                cancelReason: cancelReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderEntriesTable,
      OrderEntry,
      $$OrderEntriesTableFilterComposer,
      $$OrderEntriesTableOrderingComposer,
      $$OrderEntriesTableAnnotationComposer,
      $$OrderEntriesTableCreateCompanionBuilder,
      $$OrderEntriesTableUpdateCompanionBuilder,
      (
        OrderEntry,
        BaseReferences<_$AppDatabase, $OrderEntriesTable, OrderEntry>,
      ),
      OrderEntry,
      PrefetchHooks Function()
    >;
typedef $$OrderGarmentEntriesTableCreateCompanionBuilder =
    OrderGarmentEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String orderId,
      required String garmentTypeId,
      required int quantity,
      Value<int?> quantityDelivered,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$OrderGarmentEntriesTableUpdateCompanionBuilder =
    OrderGarmentEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> orderId,
      Value<String> garmentTypeId,
      Value<int> quantity,
      Value<int?> quantityDelivered,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$OrderGarmentEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderGarmentEntriesTable> {
  $$OrderGarmentEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get garmentTypeId => $composableBuilder(
    column: $table.garmentTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityDelivered => $composableBuilder(
    column: $table.quantityDelivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderGarmentEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderGarmentEntriesTable> {
  $$OrderGarmentEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get garmentTypeId => $composableBuilder(
    column: $table.garmentTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityDelivered => $composableBuilder(
    column: $table.quantityDelivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderGarmentEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderGarmentEntriesTable> {
  $$OrderGarmentEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get garmentTypeId => $composableBuilder(
    column: $table.garmentTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get quantityDelivered => $composableBuilder(
    column: $table.quantityDelivered,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$OrderGarmentEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderGarmentEntriesTable,
          OrderGarmentEntry,
          $$OrderGarmentEntriesTableFilterComposer,
          $$OrderGarmentEntriesTableOrderingComposer,
          $$OrderGarmentEntriesTableAnnotationComposer,
          $$OrderGarmentEntriesTableCreateCompanionBuilder,
          $$OrderGarmentEntriesTableUpdateCompanionBuilder,
          (
            OrderGarmentEntry,
            BaseReferences<
              _$AppDatabase,
              $OrderGarmentEntriesTable,
              OrderGarmentEntry
            >,
          ),
          OrderGarmentEntry,
          PrefetchHooks Function()
        > {
  $$OrderGarmentEntriesTableTableManager(
    _$AppDatabase db,
    $OrderGarmentEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderGarmentEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderGarmentEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OrderGarmentEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> garmentTypeId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int?> quantityDelivered = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderGarmentEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                garmentTypeId: garmentTypeId,
                quantity: quantity,
                quantityDelivered: quantityDelivered,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String orderId,
                required String garmentTypeId,
                required int quantity,
                Value<int?> quantityDelivered = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderGarmentEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                garmentTypeId: garmentTypeId,
                quantity: quantity,
                quantityDelivered: quantityDelivered,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderGarmentEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderGarmentEntriesTable,
      OrderGarmentEntry,
      $$OrderGarmentEntriesTableFilterComposer,
      $$OrderGarmentEntriesTableOrderingComposer,
      $$OrderGarmentEntriesTableAnnotationComposer,
      $$OrderGarmentEntriesTableCreateCompanionBuilder,
      $$OrderGarmentEntriesTableUpdateCompanionBuilder,
      (
        OrderGarmentEntry,
        BaseReferences<
          _$AppDatabase,
          $OrderGarmentEntriesTable,
          OrderGarmentEntry
        >,
      ),
      OrderGarmentEntry,
      PrefetchHooks Function()
    >;
typedef $$OrderChargeEntriesTableCreateCompanionBuilder =
    OrderChargeEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String orderId,
      required String serviceTypeId,
      Value<String?> serviceOptionId,
      required String description,
      required String quantity,
      required String unitPrice,
      required String amount,
      Value<int> rowid,
    });
typedef $$OrderChargeEntriesTableUpdateCompanionBuilder =
    OrderChargeEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> orderId,
      Value<String> serviceTypeId,
      Value<String?> serviceOptionId,
      Value<String> description,
      Value<String> quantity,
      Value<String> unitPrice,
      Value<String> amount,
      Value<int> rowid,
    });

class $$OrderChargeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderChargeEntriesTable> {
  $$OrderChargeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceOptionId => $composableBuilder(
    column: $table.serviceOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderChargeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderChargeEntriesTable> {
  $$OrderChargeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceOptionId => $composableBuilder(
    column: $table.serviceOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderChargeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderChargeEntriesTable> {
  $$OrderChargeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get serviceTypeId => $composableBuilder(
    column: $table.serviceTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceOptionId => $composableBuilder(
    column: $table.serviceOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$OrderChargeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderChargeEntriesTable,
          OrderChargeEntry,
          $$OrderChargeEntriesTableFilterComposer,
          $$OrderChargeEntriesTableOrderingComposer,
          $$OrderChargeEntriesTableAnnotationComposer,
          $$OrderChargeEntriesTableCreateCompanionBuilder,
          $$OrderChargeEntriesTableUpdateCompanionBuilder,
          (
            OrderChargeEntry,
            BaseReferences<
              _$AppDatabase,
              $OrderChargeEntriesTable,
              OrderChargeEntry
            >,
          ),
          OrderChargeEntry,
          PrefetchHooks Function()
        > {
  $$OrderChargeEntriesTableTableManager(
    _$AppDatabase db,
    $OrderChargeEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderChargeEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderChargeEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderChargeEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> serviceTypeId = const Value.absent(),
                Value<String?> serviceOptionId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unitPrice = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderChargeEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                serviceTypeId: serviceTypeId,
                serviceOptionId: serviceOptionId,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String orderId,
                required String serviceTypeId,
                Value<String?> serviceOptionId = const Value.absent(),
                required String description,
                required String quantity,
                required String unitPrice,
                required String amount,
                Value<int> rowid = const Value.absent(),
              }) => OrderChargeEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                serviceTypeId: serviceTypeId,
                serviceOptionId: serviceOptionId,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderChargeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderChargeEntriesTable,
      OrderChargeEntry,
      $$OrderChargeEntriesTableFilterComposer,
      $$OrderChargeEntriesTableOrderingComposer,
      $$OrderChargeEntriesTableAnnotationComposer,
      $$OrderChargeEntriesTableCreateCompanionBuilder,
      $$OrderChargeEntriesTableUpdateCompanionBuilder,
      (
        OrderChargeEntry,
        BaseReferences<
          _$AppDatabase,
          $OrderChargeEntriesTable,
          OrderChargeEntry
        >,
      ),
      OrderChargeEntry,
      PrefetchHooks Function()
    >;
typedef $$OrderDiscountEntriesTableCreateCompanionBuilder =
    OrderDiscountEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String orderId,
      Value<String?> promotionId,
      required String description,
      required String amount,
      Value<int> rowid,
    });
typedef $$OrderDiscountEntriesTableUpdateCompanionBuilder =
    OrderDiscountEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> orderId,
      Value<String?> promotionId,
      Value<String> description,
      Value<String> amount,
      Value<int> rowid,
    });

class $$OrderDiscountEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderDiscountEntriesTable> {
  $$OrderDiscountEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promotionId => $composableBuilder(
    column: $table.promotionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderDiscountEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderDiscountEntriesTable> {
  $$OrderDiscountEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promotionId => $composableBuilder(
    column: $table.promotionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderDiscountEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderDiscountEntriesTable> {
  $$OrderDiscountEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get promotionId => $composableBuilder(
    column: $table.promotionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$OrderDiscountEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderDiscountEntriesTable,
          OrderDiscountEntry,
          $$OrderDiscountEntriesTableFilterComposer,
          $$OrderDiscountEntriesTableOrderingComposer,
          $$OrderDiscountEntriesTableAnnotationComposer,
          $$OrderDiscountEntriesTableCreateCompanionBuilder,
          $$OrderDiscountEntriesTableUpdateCompanionBuilder,
          (
            OrderDiscountEntry,
            BaseReferences<
              _$AppDatabase,
              $OrderDiscountEntriesTable,
              OrderDiscountEntry
            >,
          ),
          OrderDiscountEntry,
          PrefetchHooks Function()
        > {
  $$OrderDiscountEntriesTableTableManager(
    _$AppDatabase db,
    $OrderDiscountEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderDiscountEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderDiscountEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OrderDiscountEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String?> promotionId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderDiscountEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                promotionId: promotionId,
                description: description,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String orderId,
                Value<String?> promotionId = const Value.absent(),
                required String description,
                required String amount,
                Value<int> rowid = const Value.absent(),
              }) => OrderDiscountEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                promotionId: promotionId,
                description: description,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderDiscountEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderDiscountEntriesTable,
      OrderDiscountEntry,
      $$OrderDiscountEntriesTableFilterComposer,
      $$OrderDiscountEntriesTableOrderingComposer,
      $$OrderDiscountEntriesTableAnnotationComposer,
      $$OrderDiscountEntriesTableCreateCompanionBuilder,
      $$OrderDiscountEntriesTableUpdateCompanionBuilder,
      (
        OrderDiscountEntry,
        BaseReferences<
          _$AppDatabase,
          $OrderDiscountEntriesTable,
          OrderDiscountEntry
        >,
      ),
      OrderDiscountEntry,
      PrefetchHooks Function()
    >;
typedef $$OrderPaymentEntriesTableCreateCompanionBuilder =
    OrderPaymentEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String orderId,
      required String amount,
      required String method,
      Value<bool> isAdvance,
      Value<String?> reference,
      required String receivedById,
      required DateTime paidAt,
      Value<int> rowid,
    });
typedef $$OrderPaymentEntriesTableUpdateCompanionBuilder =
    OrderPaymentEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> orderId,
      Value<String> amount,
      Value<String> method,
      Value<bool> isAdvance,
      Value<String?> reference,
      Value<String> receivedById,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });

class $$OrderPaymentEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderPaymentEntriesTable> {
  $$OrderPaymentEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAdvance => $composableBuilder(
    column: $table.isAdvance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedById => $composableBuilder(
    column: $table.receivedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrderPaymentEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderPaymentEntriesTable> {
  $$OrderPaymentEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAdvance => $composableBuilder(
    column: $table.isAdvance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedById => $composableBuilder(
    column: $table.receivedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrderPaymentEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderPaymentEntriesTable> {
  $$OrderPaymentEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<bool> get isAdvance =>
      $composableBuilder(column: $table.isAdvance, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get receivedById => $composableBuilder(
    column: $table.receivedById,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);
}

class $$OrderPaymentEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderPaymentEntriesTable,
          OrderPaymentEntry,
          $$OrderPaymentEntriesTableFilterComposer,
          $$OrderPaymentEntriesTableOrderingComposer,
          $$OrderPaymentEntriesTableAnnotationComposer,
          $$OrderPaymentEntriesTableCreateCompanionBuilder,
          $$OrderPaymentEntriesTableUpdateCompanionBuilder,
          (
            OrderPaymentEntry,
            BaseReferences<
              _$AppDatabase,
              $OrderPaymentEntriesTable,
              OrderPaymentEntry
            >,
          ),
          OrderPaymentEntry,
          PrefetchHooks Function()
        > {
  $$OrderPaymentEntriesTableTableManager(
    _$AppDatabase db,
    $OrderPaymentEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderPaymentEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderPaymentEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OrderPaymentEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<bool> isAdvance = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String> receivedById = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderPaymentEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                amount: amount,
                method: method,
                isAdvance: isAdvance,
                reference: reference,
                receivedById: receivedById,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String orderId,
                required String amount,
                required String method,
                Value<bool> isAdvance = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                required String receivedById,
                required DateTime paidAt,
                Value<int> rowid = const Value.absent(),
              }) => OrderPaymentEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                orderId: orderId,
                amount: amount,
                method: method,
                isAdvance: isAdvance,
                reference: reference,
                receivedById: receivedById,
                paidAt: paidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrderPaymentEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderPaymentEntriesTable,
      OrderPaymentEntry,
      $$OrderPaymentEntriesTableFilterComposer,
      $$OrderPaymentEntriesTableOrderingComposer,
      $$OrderPaymentEntriesTableAnnotationComposer,
      $$OrderPaymentEntriesTableCreateCompanionBuilder,
      $$OrderPaymentEntriesTableUpdateCompanionBuilder,
      (
        OrderPaymentEntry,
        BaseReferences<
          _$AppDatabase,
          $OrderPaymentEntriesTable,
          OrderPaymentEntry
        >,
      ),
      OrderPaymentEntry,
      PrefetchHooks Function()
    >;
typedef $$PromotionEntriesTableCreateCompanionBuilder =
    PromotionEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String code,
      required String name,
      Value<String?> description,
      required String discountType,
      required String value,
      Value<String?> appliesToServiceCodes,
      required String validFrom,
      Value<String?> validTo,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$PromotionEntriesTableUpdateCompanionBuilder =
    PromotionEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> code,
      Value<String> name,
      Value<String?> description,
      Value<String> discountType,
      Value<String> value,
      Value<String?> appliesToServiceCodes,
      Value<String> validFrom,
      Value<String?> validTo,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$PromotionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PromotionEntriesTable> {
  $$PromotionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appliesToServiceCodes => $composableBuilder(
    column: $table.appliesToServiceCodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validTo => $composableBuilder(
    column: $table.validTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromotionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PromotionEntriesTable> {
  $$PromotionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appliesToServiceCodes => $composableBuilder(
    column: $table.appliesToServiceCodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validFrom => $composableBuilder(
    column: $table.validFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validTo => $composableBuilder(
    column: $table.validTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromotionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromotionEntriesTable> {
  $$PromotionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountType => $composableBuilder(
    column: $table.discountType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get appliesToServiceCodes => $composableBuilder(
    column: $table.appliesToServiceCodes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<String> get validTo =>
      $composableBuilder(column: $table.validTo, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$PromotionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromotionEntriesTable,
          PromotionEntry,
          $$PromotionEntriesTableFilterComposer,
          $$PromotionEntriesTableOrderingComposer,
          $$PromotionEntriesTableAnnotationComposer,
          $$PromotionEntriesTableCreateCompanionBuilder,
          $$PromotionEntriesTableUpdateCompanionBuilder,
          (
            PromotionEntry,
            BaseReferences<
              _$AppDatabase,
              $PromotionEntriesTable,
              PromotionEntry
            >,
          ),
          PromotionEntry,
          PrefetchHooks Function()
        > {
  $$PromotionEntriesTableTableManager(
    _$AppDatabase db,
    $PromotionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromotionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromotionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromotionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> discountType = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> appliesToServiceCodes = const Value.absent(),
                Value<String> validFrom = const Value.absent(),
                Value<String?> validTo = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromotionEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                code: code,
                name: name,
                description: description,
                discountType: discountType,
                value: value,
                appliesToServiceCodes: appliesToServiceCodes,
                validFrom: validFrom,
                validTo: validTo,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String code,
                required String name,
                Value<String?> description = const Value.absent(),
                required String discountType,
                required String value,
                Value<String?> appliesToServiceCodes = const Value.absent(),
                required String validFrom,
                Value<String?> validTo = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromotionEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                code: code,
                name: name,
                description: description,
                discountType: discountType,
                value: value,
                appliesToServiceCodes: appliesToServiceCodes,
                validFrom: validFrom,
                validTo: validTo,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromotionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromotionEntriesTable,
      PromotionEntry,
      $$PromotionEntriesTableFilterComposer,
      $$PromotionEntriesTableOrderingComposer,
      $$PromotionEntriesTableAnnotationComposer,
      $$PromotionEntriesTableCreateCompanionBuilder,
      $$PromotionEntriesTableUpdateCompanionBuilder,
      (
        PromotionEntry,
        BaseReferences<_$AppDatabase, $PromotionEntriesTable, PromotionEntry>,
      ),
      PromotionEntry,
      PrefetchHooks Function()
    >;
typedef $$ExpenseCategoryEntriesTableCreateCompanionBuilder =
    ExpenseCategoryEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String name,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ExpenseCategoryEntriesTableUpdateCompanionBuilder =
    ExpenseCategoryEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ExpenseCategoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoryEntriesTable> {
  $$ExpenseCategoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseCategoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoryEntriesTable> {
  $$ExpenseCategoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoryEntriesTable> {
  $$ExpenseCategoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ExpenseCategoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoryEntriesTable,
          ExpenseCategoryEntry,
          $$ExpenseCategoryEntriesTableFilterComposer,
          $$ExpenseCategoryEntriesTableOrderingComposer,
          $$ExpenseCategoryEntriesTableAnnotationComposer,
          $$ExpenseCategoryEntriesTableCreateCompanionBuilder,
          $$ExpenseCategoryEntriesTableUpdateCompanionBuilder,
          (
            ExpenseCategoryEntry,
            BaseReferences<
              _$AppDatabase,
              $ExpenseCategoryEntriesTable,
              ExpenseCategoryEntry
            >,
          ),
          ExpenseCategoryEntry,
          PrefetchHooks Function()
        > {
  $$ExpenseCategoryEntriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExpenseCategoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExpenseCategoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoryEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                name: name,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoryEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                name: name,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseCategoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoryEntriesTable,
      ExpenseCategoryEntry,
      $$ExpenseCategoryEntriesTableFilterComposer,
      $$ExpenseCategoryEntriesTableOrderingComposer,
      $$ExpenseCategoryEntriesTableAnnotationComposer,
      $$ExpenseCategoryEntriesTableCreateCompanionBuilder,
      $$ExpenseCategoryEntriesTableUpdateCompanionBuilder,
      (
        ExpenseCategoryEntry,
        BaseReferences<
          _$AppDatabase,
          $ExpenseCategoryEntriesTable,
          ExpenseCategoryEntry
        >,
      ),
      ExpenseCategoryEntry,
      PrefetchHooks Function()
    >;
typedef $$ExpenseEntriesTableCreateCompanionBuilder =
    ExpenseEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String expenseDate,
      required String categoryId,
      required String concept,
      required String amount,
      required String method,
      required String status,
      Value<String?> employeeId,
      Value<String?> attendanceRecordId,
      Value<String?> productLotId,
      Value<String?> observations,
      required String createdById,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$ExpenseEntriesTableUpdateCompanionBuilder =
    ExpenseEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> expenseDate,
      Value<String> categoryId,
      Value<String> concept,
      Value<String> amount,
      Value<String> method,
      Value<String> status,
      Value<String?> employeeId,
      Value<String?> attendanceRecordId,
      Value<String?> productLotId,
      Value<String?> observations,
      Value<String> createdById,
      Value<String?> voidReason,
      Value<int> rowid,
    });

class $$ExpenseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseEntriesTable> {
  $$ExpenseEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productLotId => $composableBuilder(
    column: $table.productLotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseEntriesTable> {
  $$ExpenseEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productLotId => $composableBuilder(
    column: $table.productLotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseEntriesTable> {
  $$ExpenseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concept =>
      $composableBuilder(column: $table.concept, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get employeeId => $composableBuilder(
    column: $table.employeeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attendanceRecordId => $composableBuilder(
    column: $table.attendanceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productLotId => $composableBuilder(
    column: $table.productLotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdById => $composableBuilder(
    column: $table.createdById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );
}

class $$ExpenseEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseEntriesTable,
          ExpenseEntry,
          $$ExpenseEntriesTableFilterComposer,
          $$ExpenseEntriesTableOrderingComposer,
          $$ExpenseEntriesTableAnnotationComposer,
          $$ExpenseEntriesTableCreateCompanionBuilder,
          $$ExpenseEntriesTableUpdateCompanionBuilder,
          (
            ExpenseEntry,
            BaseReferences<_$AppDatabase, $ExpenseEntriesTable, ExpenseEntry>,
          ),
          ExpenseEntry,
          PrefetchHooks Function()
        > {
  $$ExpenseEntriesTableTableManager(
    _$AppDatabase db,
    $ExpenseEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> expenseDate = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> concept = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> employeeId = const Value.absent(),
                Value<String?> attendanceRecordId = const Value.absent(),
                Value<String?> productLotId = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String> createdById = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                expenseDate: expenseDate,
                categoryId: categoryId,
                concept: concept,
                amount: amount,
                method: method,
                status: status,
                employeeId: employeeId,
                attendanceRecordId: attendanceRecordId,
                productLotId: productLotId,
                observations: observations,
                createdById: createdById,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String expenseDate,
                required String categoryId,
                required String concept,
                required String amount,
                required String method,
                required String status,
                Value<String?> employeeId = const Value.absent(),
                Value<String?> attendanceRecordId = const Value.absent(),
                Value<String?> productLotId = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                required String createdById,
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                expenseDate: expenseDate,
                categoryId: categoryId,
                concept: concept,
                amount: amount,
                method: method,
                status: status,
                employeeId: employeeId,
                attendanceRecordId: attendanceRecordId,
                productLotId: productLotId,
                observations: observations,
                createdById: createdById,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseEntriesTable,
      ExpenseEntry,
      $$ExpenseEntriesTableFilterComposer,
      $$ExpenseEntriesTableOrderingComposer,
      $$ExpenseEntriesTableAnnotationComposer,
      $$ExpenseEntriesTableCreateCompanionBuilder,
      $$ExpenseEntriesTableUpdateCompanionBuilder,
      (
        ExpenseEntry,
        BaseReferences<_$AppDatabase, $ExpenseEntriesTable, ExpenseEntry>,
      ),
      ExpenseEntry,
      PrefetchHooks Function()
    >;
typedef $$ProductEntriesTableCreateCompanionBuilder =
    ProductEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String name,
      required String unit,
      Value<String?> description,
      Value<String?> imagePath,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ProductEntriesTableUpdateCompanionBuilder =
    ProductEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String> unit,
      Value<String?> description,
      Value<String?> imagePath,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ProductEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductEntriesTable> {
  $$ProductEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductEntriesTable> {
  $$ProductEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductEntriesTable> {
  $$ProductEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ProductEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductEntriesTable,
          ProductEntry,
          $$ProductEntriesTableFilterComposer,
          $$ProductEntriesTableOrderingComposer,
          $$ProductEntriesTableAnnotationComposer,
          $$ProductEntriesTableCreateCompanionBuilder,
          $$ProductEntriesTableUpdateCompanionBuilder,
          (
            ProductEntry,
            BaseReferences<_$AppDatabase, $ProductEntriesTable, ProductEntry>,
          ),
          ProductEntry,
          PrefetchHooks Function()
        > {
  $$ProductEntriesTableTableManager(
    _$AppDatabase db,
    $ProductEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                name: name,
                unit: unit,
                description: description,
                imagePath: imagePath,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required String unit,
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                name: name,
                unit: unit,
                description: description,
                imagePath: imagePath,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductEntriesTable,
      ProductEntry,
      $$ProductEntriesTableFilterComposer,
      $$ProductEntriesTableOrderingComposer,
      $$ProductEntriesTableAnnotationComposer,
      $$ProductEntriesTableCreateCompanionBuilder,
      $$ProductEntriesTableUpdateCompanionBuilder,
      (
        ProductEntry,
        BaseReferences<_$AppDatabase, $ProductEntriesTable, ProductEntry>,
      ),
      ProductEntry,
      PrefetchHooks Function()
    >;
typedef $$ProductLotEntriesTableCreateCompanionBuilder =
    ProductLotEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String productId,
      required int lotNumber,
      required String quantityReceived,
      required String quantityAvailable,
      Value<String?> salePrice,
      required String receivedAt,
      Value<int> rowid,
    });
typedef $$ProductLotEntriesTableUpdateCompanionBuilder =
    ProductLotEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> productId,
      Value<int> lotNumber,
      Value<String> quantityReceived,
      Value<String> quantityAvailable,
      Value<String?> salePrice,
      Value<String> receivedAt,
      Value<int> rowid,
    });

class $$ProductLotEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductLotEntriesTable> {
  $$ProductLotEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lotNumber => $composableBuilder(
    column: $table.lotNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityAvailable => $composableBuilder(
    column: $table.quantityAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductLotEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductLotEntriesTable> {
  $$ProductLotEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lotNumber => $composableBuilder(
    column: $table.lotNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityAvailable => $composableBuilder(
    column: $table.quantityAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductLotEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductLotEntriesTable> {
  $$ProductLotEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get lotNumber =>
      $composableBuilder(column: $table.lotNumber, builder: (column) => column);

  GeneratedColumn<String> get quantityReceived => $composableBuilder(
    column: $table.quantityReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityAvailable => $composableBuilder(
    column: $table.quantityAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$ProductLotEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductLotEntriesTable,
          ProductLotEntry,
          $$ProductLotEntriesTableFilterComposer,
          $$ProductLotEntriesTableOrderingComposer,
          $$ProductLotEntriesTableAnnotationComposer,
          $$ProductLotEntriesTableCreateCompanionBuilder,
          $$ProductLotEntriesTableUpdateCompanionBuilder,
          (
            ProductLotEntry,
            BaseReferences<
              _$AppDatabase,
              $ProductLotEntriesTable,
              ProductLotEntry
            >,
          ),
          ProductLotEntry,
          PrefetchHooks Function()
        > {
  $$ProductLotEntriesTableTableManager(
    _$AppDatabase db,
    $ProductLotEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductLotEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductLotEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductLotEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> lotNumber = const Value.absent(),
                Value<String> quantityReceived = const Value.absent(),
                Value<String> quantityAvailable = const Value.absent(),
                Value<String?> salePrice = const Value.absent(),
                Value<String> receivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductLotEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                productId: productId,
                lotNumber: lotNumber,
                quantityReceived: quantityReceived,
                quantityAvailable: quantityAvailable,
                salePrice: salePrice,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String productId,
                required int lotNumber,
                required String quantityReceived,
                required String quantityAvailable,
                Value<String?> salePrice = const Value.absent(),
                required String receivedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductLotEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                productId: productId,
                lotNumber: lotNumber,
                quantityReceived: quantityReceived,
                quantityAvailable: quantityAvailable,
                salePrice: salePrice,
                receivedAt: receivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductLotEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductLotEntriesTable,
      ProductLotEntry,
      $$ProductLotEntriesTableFilterComposer,
      $$ProductLotEntriesTableOrderingComposer,
      $$ProductLotEntriesTableAnnotationComposer,
      $$ProductLotEntriesTableCreateCompanionBuilder,
      $$ProductLotEntriesTableUpdateCompanionBuilder,
      (
        ProductLotEntry,
        BaseReferences<_$AppDatabase, $ProductLotEntriesTable, ProductLotEntry>,
      ),
      ProductLotEntry,
      PrefetchHooks Function()
    >;
typedef $$SupplySaleEntriesTableCreateCompanionBuilder =
    SupplySaleEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String saleDate,
      Value<String?> customerId,
      Value<String?> nit,
      required String method,
      Value<String?> reference,
      required String total,
      required String soldById,
      Value<DateTime?> cancelledAt,
      Value<String?> cancelledById,
      Value<String?> cancelReason,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });
typedef $$SupplySaleEntriesTableUpdateCompanionBuilder =
    SupplySaleEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> saleDate,
      Value<String?> customerId,
      Value<String?> nit,
      Value<String> method,
      Value<String?> reference,
      Value<String> total,
      Value<String> soldById,
      Value<DateTime?> cancelledAt,
      Value<String?> cancelledById,
      Value<String?> cancelReason,
      Value<DateTime?> createdAt,
      Value<int> rowid,
    });

class $$SupplySaleEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SupplySaleEntriesTable> {
  $$SupplySaleEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nit => $composableBuilder(
    column: $table.nit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soldById => $composableBuilder(
    column: $table.soldById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelledById => $composableBuilder(
    column: $table.cancelledById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupplySaleEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplySaleEntriesTable> {
  $$SupplySaleEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nit => $composableBuilder(
    column: $table.nit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soldById => $composableBuilder(
    column: $table.soldById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelledById => $composableBuilder(
    column: $table.cancelledById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupplySaleEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplySaleEntriesTable> {
  $$SupplySaleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nit =>
      $composableBuilder(column: $table.nit, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get soldById =>
      $composableBuilder(column: $table.soldById, builder: (column) => column);

  GeneratedColumn<DateTime> get cancelledAt => $composableBuilder(
    column: $table.cancelledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelledById => $composableBuilder(
    column: $table.cancelledById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cancelReason => $composableBuilder(
    column: $table.cancelReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SupplySaleEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplySaleEntriesTable,
          SupplySaleEntry,
          $$SupplySaleEntriesTableFilterComposer,
          $$SupplySaleEntriesTableOrderingComposer,
          $$SupplySaleEntriesTableAnnotationComposer,
          $$SupplySaleEntriesTableCreateCompanionBuilder,
          $$SupplySaleEntriesTableUpdateCompanionBuilder,
          (
            SupplySaleEntry,
            BaseReferences<
              _$AppDatabase,
              $SupplySaleEntriesTable,
              SupplySaleEntry
            >,
          ),
          SupplySaleEntry,
          PrefetchHooks Function()
        > {
  $$SupplySaleEntriesTableTableManager(
    _$AppDatabase db,
    $SupplySaleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplySaleEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplySaleEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplySaleEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> saleDate = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> nit = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String> total = const Value.absent(),
                Value<String> soldById = const Value.absent(),
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancelledById = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplySaleEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                saleDate: saleDate,
                customerId: customerId,
                nit: nit,
                method: method,
                reference: reference,
                total: total,
                soldById: soldById,
                cancelledAt: cancelledAt,
                cancelledById: cancelledById,
                cancelReason: cancelReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String saleDate,
                Value<String?> customerId = const Value.absent(),
                Value<String?> nit = const Value.absent(),
                required String method,
                Value<String?> reference = const Value.absent(),
                required String total,
                required String soldById,
                Value<DateTime?> cancelledAt = const Value.absent(),
                Value<String?> cancelledById = const Value.absent(),
                Value<String?> cancelReason = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplySaleEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                saleDate: saleDate,
                customerId: customerId,
                nit: nit,
                method: method,
                reference: reference,
                total: total,
                soldById: soldById,
                cancelledAt: cancelledAt,
                cancelledById: cancelledById,
                cancelReason: cancelReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupplySaleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplySaleEntriesTable,
      SupplySaleEntry,
      $$SupplySaleEntriesTableFilterComposer,
      $$SupplySaleEntriesTableOrderingComposer,
      $$SupplySaleEntriesTableAnnotationComposer,
      $$SupplySaleEntriesTableCreateCompanionBuilder,
      $$SupplySaleEntriesTableUpdateCompanionBuilder,
      (
        SupplySaleEntry,
        BaseReferences<_$AppDatabase, $SupplySaleEntriesTable, SupplySaleEntry>,
      ),
      SupplySaleEntry,
      PrefetchHooks Function()
    >;
typedef $$SupplySaleItemEntriesTableCreateCompanionBuilder =
    SupplySaleItemEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String saleId,
      Value<String?> lotId,
      Value<String?> productId,
      required String description,
      required String quantity,
      required String unitPrice,
      required String amount,
      Value<int> rowid,
    });
typedef $$SupplySaleItemEntriesTableUpdateCompanionBuilder =
    SupplySaleItemEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> saleId,
      Value<String?> lotId,
      Value<String?> productId,
      Value<String> description,
      Value<String> quantity,
      Value<String> unitPrice,
      Value<String> amount,
      Value<int> rowid,
    });

class $$SupplySaleItemEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SupplySaleItemEntriesTable> {
  $$SupplySaleItemEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupplySaleItemEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplySaleItemEntriesTable> {
  $$SupplySaleItemEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleId => $composableBuilder(
    column: $table.saleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupplySaleItemEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplySaleItemEntriesTable> {
  $$SupplySaleItemEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$SupplySaleItemEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplySaleItemEntriesTable,
          SupplySaleItemEntry,
          $$SupplySaleItemEntriesTableFilterComposer,
          $$SupplySaleItemEntriesTableOrderingComposer,
          $$SupplySaleItemEntriesTableAnnotationComposer,
          $$SupplySaleItemEntriesTableCreateCompanionBuilder,
          $$SupplySaleItemEntriesTableUpdateCompanionBuilder,
          (
            SupplySaleItemEntry,
            BaseReferences<
              _$AppDatabase,
              $SupplySaleItemEntriesTable,
              SupplySaleItemEntry
            >,
          ),
          SupplySaleItemEntry,
          PrefetchHooks Function()
        > {
  $$SupplySaleItemEntriesTableTableManager(
    _$AppDatabase db,
    $SupplySaleItemEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplySaleItemEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupplySaleItemEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplySaleItemEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String?> lotId = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unitPrice = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplySaleItemEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                saleId: saleId,
                lotId: lotId,
                productId: productId,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String saleId,
                Value<String?> lotId = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                required String description,
                required String quantity,
                required String unitPrice,
                required String amount,
                Value<int> rowid = const Value.absent(),
              }) => SupplySaleItemEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                saleId: saleId,
                lotId: lotId,
                productId: productId,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupplySaleItemEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplySaleItemEntriesTable,
      SupplySaleItemEntry,
      $$SupplySaleItemEntriesTableFilterComposer,
      $$SupplySaleItemEntriesTableOrderingComposer,
      $$SupplySaleItemEntriesTableAnnotationComposer,
      $$SupplySaleItemEntriesTableCreateCompanionBuilder,
      $$SupplySaleItemEntriesTableUpdateCompanionBuilder,
      (
        SupplySaleItemEntry,
        BaseReferences<
          _$AppDatabase,
          $SupplySaleItemEntriesTable,
          SupplySaleItemEntry
        >,
      ),
      SupplySaleItemEntry,
      PrefetchHooks Function()
    >;
typedef $$DailyClosureEntriesTableCreateCompanionBuilder =
    DailyClosureEntriesCompanion Function({
      required String id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      required String closeDate,
      required String ordersIncome,
      required String suppliesIncome,
      required String expensesTotal,
      required String netTotal,
      required String cashIncome,
      required String transferIncome,
      required String cashExpenses,
      required String transferExpenses,
      Value<int> ordersDelivered,
      Value<String?> notes,
      required String closedById,
      required DateTime closedAt,
      Value<String?> reopenedById,
      Value<String?> reopenReason,
      Value<int> rowid,
    });
typedef $$DailyClosureEntriesTableUpdateCompanionBuilder =
    DailyClosureEntriesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> syncStatus,
      Value<DateTime?> deletedAt,
      Value<String> closeDate,
      Value<String> ordersIncome,
      Value<String> suppliesIncome,
      Value<String> expensesTotal,
      Value<String> netTotal,
      Value<String> cashIncome,
      Value<String> transferIncome,
      Value<String> cashExpenses,
      Value<String> transferExpenses,
      Value<int> ordersDelivered,
      Value<String?> notes,
      Value<String> closedById,
      Value<DateTime> closedAt,
      Value<String?> reopenedById,
      Value<String?> reopenReason,
      Value<int> rowid,
    });

class $$DailyClosureEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyClosureEntriesTable> {
  $$DailyClosureEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ordersIncome => $composableBuilder(
    column: $table.ordersIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suppliesIncome => $composableBuilder(
    column: $table.suppliesIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expensesTotal => $composableBuilder(
    column: $table.expensesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get netTotal => $composableBuilder(
    column: $table.netTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashIncome => $composableBuilder(
    column: $table.cashIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferIncome => $composableBuilder(
    column: $table.transferIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cashExpenses => $composableBuilder(
    column: $table.cashExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferExpenses => $composableBuilder(
    column: $table.transferExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordersDelivered => $composableBuilder(
    column: $table.ordersDelivered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reopenedById => $composableBuilder(
    column: $table.reopenedById,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyClosureEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyClosureEntriesTable> {
  $$DailyClosureEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closeDate => $composableBuilder(
    column: $table.closeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ordersIncome => $composableBuilder(
    column: $table.ordersIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suppliesIncome => $composableBuilder(
    column: $table.suppliesIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expensesTotal => $composableBuilder(
    column: $table.expensesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get netTotal => $composableBuilder(
    column: $table.netTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashIncome => $composableBuilder(
    column: $table.cashIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferIncome => $composableBuilder(
    column: $table.transferIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cashExpenses => $composableBuilder(
    column: $table.cashExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferExpenses => $composableBuilder(
    column: $table.transferExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordersDelivered => $composableBuilder(
    column: $table.ordersDelivered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reopenedById => $composableBuilder(
    column: $table.reopenedById,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyClosureEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyClosureEntriesTable> {
  $$DailyClosureEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get closeDate =>
      $composableBuilder(column: $table.closeDate, builder: (column) => column);

  GeneratedColumn<String> get ordersIncome => $composableBuilder(
    column: $table.ordersIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suppliesIncome => $composableBuilder(
    column: $table.suppliesIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expensesTotal => $composableBuilder(
    column: $table.expensesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get netTotal =>
      $composableBuilder(column: $table.netTotal, builder: (column) => column);

  GeneratedColumn<String> get cashIncome => $composableBuilder(
    column: $table.cashIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferIncome => $composableBuilder(
    column: $table.transferIncome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cashExpenses => $composableBuilder(
    column: $table.cashExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferExpenses => $composableBuilder(
    column: $table.transferExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordersDelivered => $composableBuilder(
    column: $table.ordersDelivered,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get closedById => $composableBuilder(
    column: $table.closedById,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get reopenedById => $composableBuilder(
    column: $table.reopenedById,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reopenReason => $composableBuilder(
    column: $table.reopenReason,
    builder: (column) => column,
  );
}

class $$DailyClosureEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyClosureEntriesTable,
          DailyClosureEntry,
          $$DailyClosureEntriesTableFilterComposer,
          $$DailyClosureEntriesTableOrderingComposer,
          $$DailyClosureEntriesTableAnnotationComposer,
          $$DailyClosureEntriesTableCreateCompanionBuilder,
          $$DailyClosureEntriesTableUpdateCompanionBuilder,
          (
            DailyClosureEntry,
            BaseReferences<
              _$AppDatabase,
              $DailyClosureEntriesTable,
              DailyClosureEntry
            >,
          ),
          DailyClosureEntry,
          PrefetchHooks Function()
        > {
  $$DailyClosureEntriesTableTableManager(
    _$AppDatabase db,
    $DailyClosureEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyClosureEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyClosureEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyClosureEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> closeDate = const Value.absent(),
                Value<String> ordersIncome = const Value.absent(),
                Value<String> suppliesIncome = const Value.absent(),
                Value<String> expensesTotal = const Value.absent(),
                Value<String> netTotal = const Value.absent(),
                Value<String> cashIncome = const Value.absent(),
                Value<String> transferIncome = const Value.absent(),
                Value<String> cashExpenses = const Value.absent(),
                Value<String> transferExpenses = const Value.absent(),
                Value<int> ordersDelivered = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> closedById = const Value.absent(),
                Value<DateTime> closedAt = const Value.absent(),
                Value<String?> reopenedById = const Value.absent(),
                Value<String?> reopenReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyClosureEntriesCompanion(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                closeDate: closeDate,
                ordersIncome: ordersIncome,
                suppliesIncome: suppliesIncome,
                expensesTotal: expensesTotal,
                netTotal: netTotal,
                cashIncome: cashIncome,
                transferIncome: transferIncome,
                cashExpenses: cashExpenses,
                transferExpenses: transferExpenses,
                ordersDelivered: ordersDelivered,
                notes: notes,
                closedById: closedById,
                closedAt: closedAt,
                reopenedById: reopenedById,
                reopenReason: reopenReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String closeDate,
                required String ordersIncome,
                required String suppliesIncome,
                required String expensesTotal,
                required String netTotal,
                required String cashIncome,
                required String transferIncome,
                required String cashExpenses,
                required String transferExpenses,
                Value<int> ordersDelivered = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String closedById,
                required DateTime closedAt,
                Value<String?> reopenedById = const Value.absent(),
                Value<String?> reopenReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyClosureEntriesCompanion.insert(
                id: id,
                version: version,
                syncStatus: syncStatus,
                deletedAt: deletedAt,
                closeDate: closeDate,
                ordersIncome: ordersIncome,
                suppliesIncome: suppliesIncome,
                expensesTotal: expensesTotal,
                netTotal: netTotal,
                cashIncome: cashIncome,
                transferIncome: transferIncome,
                cashExpenses: cashExpenses,
                transferExpenses: transferExpenses,
                ordersDelivered: ordersDelivered,
                notes: notes,
                closedById: closedById,
                closedAt: closedAt,
                reopenedById: reopenedById,
                reopenReason: reopenReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyClosureEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyClosureEntriesTable,
      DailyClosureEntry,
      $$DailyClosureEntriesTableFilterComposer,
      $$DailyClosureEntriesTableOrderingComposer,
      $$DailyClosureEntriesTableAnnotationComposer,
      $$DailyClosureEntriesTableCreateCompanionBuilder,
      $$DailyClosureEntriesTableUpdateCompanionBuilder,
      (
        DailyClosureEntry,
        BaseReferences<
          _$AppDatabase,
          $DailyClosureEntriesTable,
          DailyClosureEntry
        >,
      ),
      DailyClosureEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncStateEntriesTableTableManager get syncStateEntries =>
      $$SyncStateEntriesTableTableManager(_db, _db.syncStateEntries);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$ReviewEntriesTableTableManager get reviewEntries =>
      $$ReviewEntriesTableTableManager(_db, _db.reviewEntries);
  $$DeferredChangesTableTableManager get deferredChanges =>
      $$DeferredChangesTableTableManager(_db, _db.deferredChanges);
  $$ServiceTypeEntriesTableTableManager get serviceTypeEntries =>
      $$ServiceTypeEntriesTableTableManager(_db, _db.serviceTypeEntries);
  $$ServiceOptionEntriesTableTableManager get serviceOptionEntries =>
      $$ServiceOptionEntriesTableTableManager(_db, _db.serviceOptionEntries);
  $$ServicePriceEntriesTableTableManager get servicePriceEntries =>
      $$ServicePriceEntriesTableTableManager(_db, _db.servicePriceEntries);
  $$GarmentTypeEntriesTableTableManager get garmentTypeEntries =>
      $$GarmentTypeEntriesTableTableManager(_db, _db.garmentTypeEntries);
  $$CustomerEntriesTableTableManager get customerEntries =>
      $$CustomerEntriesTableTableManager(_db, _db.customerEntries);
  $$OrderEntriesTableTableManager get orderEntries =>
      $$OrderEntriesTableTableManager(_db, _db.orderEntries);
  $$OrderGarmentEntriesTableTableManager get orderGarmentEntries =>
      $$OrderGarmentEntriesTableTableManager(_db, _db.orderGarmentEntries);
  $$OrderChargeEntriesTableTableManager get orderChargeEntries =>
      $$OrderChargeEntriesTableTableManager(_db, _db.orderChargeEntries);
  $$OrderDiscountEntriesTableTableManager get orderDiscountEntries =>
      $$OrderDiscountEntriesTableTableManager(_db, _db.orderDiscountEntries);
  $$OrderPaymentEntriesTableTableManager get orderPaymentEntries =>
      $$OrderPaymentEntriesTableTableManager(_db, _db.orderPaymentEntries);
  $$PromotionEntriesTableTableManager get promotionEntries =>
      $$PromotionEntriesTableTableManager(_db, _db.promotionEntries);
  $$ExpenseCategoryEntriesTableTableManager get expenseCategoryEntries =>
      $$ExpenseCategoryEntriesTableTableManager(
        _db,
        _db.expenseCategoryEntries,
      );
  $$ExpenseEntriesTableTableManager get expenseEntries =>
      $$ExpenseEntriesTableTableManager(_db, _db.expenseEntries);
  $$ProductEntriesTableTableManager get productEntries =>
      $$ProductEntriesTableTableManager(_db, _db.productEntries);
  $$ProductLotEntriesTableTableManager get productLotEntries =>
      $$ProductLotEntriesTableTableManager(_db, _db.productLotEntries);
  $$SupplySaleEntriesTableTableManager get supplySaleEntries =>
      $$SupplySaleEntriesTableTableManager(_db, _db.supplySaleEntries);
  $$SupplySaleItemEntriesTableTableManager get supplySaleItemEntries =>
      $$SupplySaleItemEntriesTableTableManager(_db, _db.supplySaleItemEntries);
  $$DailyClosureEntriesTableTableManager get dailyClosureEntries =>
      $$DailyClosureEntriesTableTableManager(_db, _db.dailyClosureEntries);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'b5ab70b9d49ea0d6d868f371e9f21050ffe8201e';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
