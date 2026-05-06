import '../../domain/entities/entities.dart';
import 'lahan_model.dart';
import 'supabase_scan_record_dto.dart';

class SupabaseLahanDto {
  const SupabaseLahanDto({
    required this.id,
    required this.owner,
    required this.area,
    required this.location,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SupabaseLahanDto.fromJson(Map<String, dynamic> json) {
    return SupabaseLahanDto(
      id: (json['id'] as num).toInt(),
      owner: json['owner'] as String,
      area: json['area'] as String,
      location: json['location'] as String? ?? '',
      status: json['status'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String).toUtc(),
    );
  }

  factory SupabaseLahanDto.fromLocalModel(
    LahanModel model, {
    required String userId,
  }) {
    return SupabaseLahanDto(
      id: model.id,
      owner: model.owner,
      area: model.area,
      location: model.location,
      status: model.status,
      userId: userId,
      createdAt: model.effectiveCreatedAt.toUtc(),
      updatedAt: model.effectiveUpdatedAt.toUtc(),
      deletedAt: model.deletedAt?.toUtc(),
    );
  }

  factory SupabaseLahanDto.fromSyncPayload(
    Map<String, dynamic> json, {
    required String userId,
  }) {
    return SupabaseLahanDto(
      id: (json['id'] as num).toInt(),
      owner: json['owner'] as String,
      area: json['area'] as String,
      location: json['location'] as String? ?? '',
      status: json['status'] as String,
      userId: userId,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String).toUtc(),
    );
  }

  final int id;
  final String owner;
  final String area;
  final String location;
  final String status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  LahanModel toLocalModel({
    required List<SupabaseScanRecordDto> scanRecords,
  }) {
    final domain = Lahan(
      id: id,
      owner: owner,
      area: area,
      location: location,
      status: LahanStatus.fromString(status),
      scanHistory: scanRecords
          .where((record) => record.deletedAt == null)
          .map((record) => record.toDomain())
          .toList(),
    );

    return LahanModel.fromDomain(
      domain,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'area': area,
      'location': location,
      'status': status,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'id': id,
      'owner': owner,
      'area': area,
      'location': location,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}