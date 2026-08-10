/// Orden que el servidor puede darle a un dispositivo en cualquier respuesta.
class SyncDirective {
  /// El dispositivo fue revocado: debe borrar su BD local y sus llaves (D11).
  static const String wipe = 'wipe';
}

/// Un cambio del feed: el estado completo de una fila, no un delta.
class SyncChange {
  const SyncChange({
    required this.entity,
    required this.id,
    required this.version,
    required this.syncSeq,
    required this.deleted,
    required this.data,
  });

  factory SyncChange.fromJson(Map<String, dynamic> json) {
    return SyncChange(
      entity: json['entity'] as String,
      id: json['id'] as String,
      version: json['version'] as int,
      syncSeq: json['sync_seq'] as int,
      deleted: json['deleted'] as bool,
      data: (json['data'] as Map).cast<String, dynamic>(),
    );
  }

  final String entity;
  final String id;
  final int version;
  final int syncSeq;

  /// Tombstone: la fila existió y ya no (D8).
  final bool deleted;

  final Map<String, dynamic> data;
}

/// Una página del feed de cambios.
class SyncPullPage {
  const SyncPullPage({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
    required this.serverTime,
    this.deviceDirective,
  });

  factory SyncPullPage.fromJson(Map<String, dynamic> json) {
    return SyncPullPage(
      changes: (json['changes'] as List)
          .map((item) => SyncChange.fromJson((item as Map).cast<String, dynamic>()))
          .toList(),
      nextCursor: json['next_cursor'] as int,
      hasMore: json['has_more'] as bool,
      serverTime: DateTime.parse(json['server_time'] as String),
      deviceDirective: json['device_directive'] as String?,
    );
  }

  final List<SyncChange> changes;
  final int nextCursor;
  final bool hasMore;
  final DateTime serverTime;
  final String? deviceDirective;
}
