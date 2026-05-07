
import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';

part 'lahan_model.g.dart';

@HiveType(typeId: 0)
class ScanRecordModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  String? legacyDateLabel;

  @HiveField(2)
  late double ph;

  @HiveField(3)
  late int moisture;

  @HiveField(4)
  late String recommendation;

  @HiveField(5)
  DateTime? recordedAt;

  ScanRecord toDomain() => ScanRecord(
        id: id,
        recordedAt: recordedAt ??
            _parseLegacyDateLabel(legacyDateLabel) ??
            DateTime.fromMillisecondsSinceEpoch(id, isUtc: true),
        ph: ph,
        moisture: moisture,
        recommendation: recommendation,
      );

  static ScanRecordModel fromDomain(ScanRecord record) {
    return ScanRecordModel()
      ..id = record.id
      ..legacyDateLabel = null
      ..ph = record.ph
      ..moisture = record.moisture
      ..recommendation = record.recommendation
      ..recordedAt = record.recordedAt.toUtc();
  }

  static DateTime? _parseLegacyDateLabel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = _monthFromLabel(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime.utc(year, month, day);
  }

  static int? _monthFromLabel(String value) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'mei': 5,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'ags': 8,
      'agu': 8,
      'aug': 8,
      'sep': 9,
      'okt': 10,
      'oct': 10,
      'nov': 11,
      'des': 12,
      'dec': 12,
    };
    return months[value.trim().toLowerCase()];
  }
}

@HiveType(typeId: 1)
class LahanModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String owner;

  @HiveField(2)
  late String area;

  @HiveField(3)
  late String location;

  @HiveField(4)
  late String status;

  @HiveField(5)
  late List<ScanRecordModel> scanHistory;

  @HiveField(6)
  DateTime? createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  DateTime? deletedAt;

  DateTime get effectiveCreatedAt =>
      createdAt ?? DateTime.fromMillisecondsSinceEpoch(id, isUtc: true);

  DateTime get effectiveUpdatedAt {
    if (updatedAt != null) {
      return updatedAt!;
    }
    if (scanHistory.isEmpty) {
      return effectiveCreatedAt;
    }
    final latestScan = scanHistory
        .map((record) => record.toDomain().recordedAt)
        .reduce((latest, current) => current.isAfter(latest) ? current : latest);
    return latestScan;
  }

  Lahan toDomain() {
    final orderedScanHistory = scanHistory.map((m) => m.toDomain()).toList()
      ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));

    return Lahan(
      id: id,
      owner: owner,
      area: area,
      location: location,
      status: LahanStatus.fromString(status),
      scanHistory: orderedScanHistory,
    );
  }

  static LahanModel fromDomain(
    Lahan lahan, {
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final created = createdAt ?? DateTime.now().toUtc();
    final updated = updatedAt ?? created;
    return LahanModel()
      ..id = lahan.id
      ..owner = lahan.owner
      ..area = lahan.area
      ..location = lahan.location
      ..status = lahan.status.label
      ..scanHistory =
          lahan.scanHistory.map(ScanRecordModel.fromDomain).toList()
      ..createdAt = created.toUtc()
      ..updatedAt = updated.toUtc()
      ..deletedAt = deletedAt?.toUtc();
  }
}
