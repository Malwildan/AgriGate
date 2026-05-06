import 'dart:convert';

enum SyncOperationType {
  upsertLahan,
  upsertScanRecord,
}

class PendingSyncOperation {
  const PendingSyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  factory PendingSyncOperation.fromEncoded(String value) {
    return PendingSyncOperation.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.byName(json['type'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  String encode() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'payload': payload,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}