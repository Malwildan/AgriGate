import '../../domain/entities/entities.dart';

class SupabaseScanRecordDto {
  const SupabaseScanRecordDto({
    required this.id,
    required this.lahanId,
    required this.userId,
    required this.recordedAt,
    required this.ph,
    required this.moisture,
    required this.recommendation,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SupabaseScanRecordDto.fromJson(Map<String, dynamic> json) {
    return SupabaseScanRecordDto(
      id: (json['id'] as num).toInt(),
      lahanId: (json['lahan_id'] as num).toInt(),
      userId: json['user_id'] as String,
      recordedAt: DateTime.parse(json['recorded_at'] as String).toUtc(),
      ph: (json['ph'] as num).toDouble(),
      moisture: (json['moisture'] as num).toInt(),
      recommendation: json['recommendation'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String).toUtc(),
    );
  }

  factory SupabaseScanRecordDto.fromDomain({
    required int lahanId,
    required String userId,
    required ScanRecord record,
    DateTime? syncedAt,
  }) {
    final timestamp = syncedAt ?? record.recordedAt;
    return SupabaseScanRecordDto(
      id: record.id,
      lahanId: lahanId,
      userId: userId,
      recordedAt: record.recordedAt.toUtc(),
      ph: record.ph,
      moisture: record.moisture,
      recommendation: record.recommendation,
      createdAt: timestamp.toUtc(),
      updatedAt: timestamp.toUtc(),
    );
  }

  factory SupabaseScanRecordDto.fromSyncPayload(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    return SupabaseScanRecordDto(
      id: (json['id'] as num).toInt(),
      lahanId: (json['lahan_id'] as num).toInt(),
      userId: userId,
      recordedAt: DateTime.parse(json['recorded_at'] as String).toUtc(),
      ph: (json['ph'] as num).toDouble(),
      moisture: (json['moisture'] as num).toInt(),
      recommendation: json['recommendation'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String).toUtc(),
    );
  }

  final int id;
  final int lahanId;
  final String userId;
  final DateTime recordedAt;
  final double ph;
  final int moisture;
  final String recommendation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ScanRecord toDomain() {
    return ScanRecord(
      id: id,
      recordedAt: recordedAt,
      ph: ph,
      moisture: moisture,
      recommendation: recommendation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lahan_id': lahanId,
      'user_id': userId,
      'recorded_at': recordedAt.toIso8601String(),
      'ph': ph,
      'moisture': moisture,
      'recommendation': recommendation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'id': id,
      'lahan_id': lahanId,
      'recorded_at': recordedAt.toIso8601String(),
      'ph': ph,
      'moisture': moisture,
      'recommendation': recommendation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}