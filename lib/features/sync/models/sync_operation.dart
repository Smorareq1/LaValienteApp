/// Veredicto del servidor sobre una operación empujada (plan 0004 §7.1).
enum SyncOperationOutcome {
  /// Se aplicó ahora.
  applied,

  /// Ya se había aplicado en un intento anterior; el servidor re-sirvió el
  /// recibo guardado en vez de duplicarla (D4).
  alreadyApplied,

  /// Una regla de dominio o de permisos la rechazó.
  rejected,

  /// Otro dispositivo ya había modificado la fila (D6).
  conflict;

  static SyncOperationOutcome fromWire(String value) => switch (value) {
    'applied' => SyncOperationOutcome.applied,
    'already_applied' => SyncOperationOutcome.alreadyApplied,
    'rejected' => SyncOperationOutcome.rejected,
    'conflict' => SyncOperationOutcome.conflict,
    _ => throw FormatException('Estado de operación desconocido: $value'),
  };

  /// Si el servidor la tomó, la operación sale del outbox.
  bool get isSettled =>
      this == SyncOperationOutcome.applied || this == SyncOperationOutcome.alreadyApplied;

  /// Si no, va a la cola de revisión con su motivo.
  bool get needsReview => !isSettled;
}

/// Una operación capturada localmente, esperando su turno de subir.
class SyncOperation {
  const SyncOperation({
    required this.seq,
    required this.opId,
    required this.entity,
    required this.opType,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    this.baseVersion,
    this.attempts = 0,
    this.lastError,
  });

  final int seq;
  final String opId;
  final String entity;
  final String opType;
  final String entityId;
  final int? baseVersion;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  Map<String, dynamic> toWire() => {
    'op_id': opId,
    'seq': seq,
    'entity': entity,
    'op_type': opType,
    'entity_id': entityId,
    if (baseVersion != null) 'base_version': baseVersion,
    'payload': payload,
    // En UTC: `toIso8601String()` sobre una fecha local no lleva offset, y el
    // servidor no podría situarla en el tiempo para medir el desfase de reloj.
    'client_ts': createdAt.toUtc().toIso8601String(),
  };
}

/// Resultado que devuelve el servidor por cada operación del lote.
class SyncOperationResult {
  const SyncOperationResult({
    required this.opId,
    required this.outcome,
    required this.entityId,
    this.serverVersion,
    this.serverData,
    this.warnings = const [],
    this.reason,
  });

  factory SyncOperationResult.fromJson(Map<String, dynamic> json) {
    return SyncOperationResult(
      opId: json['op_id'] as String,
      outcome: SyncOperationOutcome.fromWire(json['status'] as String),
      entityId: json['entity_id'] as String,
      serverVersion: json['server_version'] as int?,
      serverData: (json['server_data'] as Map?)?.cast<String, dynamic>(),
      warnings: (json['warnings'] as List?)?.cast<String>() ?? const [],
      reason: json['reason'] as String?,
    );
  }

  final String opId;
  final SyncOperationOutcome outcome;
  final String entityId;
  final int? serverVersion;

  /// Lo que el servidor guardó de verdad, cuando difiere de lo enviado (D10):
  /// el total recalculado de un pedido, por ejemplo.
  final Map<String, dynamic>? serverData;

  final List<String> warnings;
  final String? reason;
}

/// Respuesta completa de un push.
class SyncPushResult {
  const SyncPushResult({
    required this.results,
    required this.serverTime,
    this.deviceDirective,
  });

  factory SyncPushResult.fromJson(Map<String, dynamic> json) {
    return SyncPushResult(
      results: (json['results'] as List)
          .map((item) => SyncOperationResult.fromJson((item as Map).cast<String, dynamic>()))
          .toList(),
      serverTime: DateTime.parse(json['server_time'] as String),
      deviceDirective: json['device_directive'] as String?,
    );
  }

  final List<SyncOperationResult> results;
  final DateTime serverTime;
  final String? deviceDirective;
}
