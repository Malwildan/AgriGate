// Hive-backed data models with type adapters.

import 'package:hive/hive.dart';
import '../../domain/entities/entities.dart';

part 'lahan_model.g.dart';

@HiveType(typeId: 0)
class ScanRecordModel extends HiveObject {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String date;

  @HiveField(2)
  late double ph;

  @HiveField(3)
  late int moisture;

  @HiveField(4)
  late String recommendation;

  ScanRecord toDomain() => ScanRecord(
        id: id,
        date: date,
        ph: ph,
        moisture: moisture,
        recommendation: recommendation,
      );

  static ScanRecordModel fromDomain(ScanRecord record) {
    return ScanRecordModel()
      ..id = record.id
      ..date = record.date
      ..ph = record.ph
      ..moisture = record.moisture
      ..recommendation = record.recommendation;
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

  Lahan toDomain() => Lahan(
        id: id,
        owner: owner,
        area: area,
        location: location,
        status: LahanStatus.fromString(status),
        scanHistory: scanHistory.map((m) => m.toDomain()).toList(),
      );

  static LahanModel fromDomain(Lahan lahan) {
    return LahanModel()
      ..id = lahan.id
      ..owner = lahan.owner
      ..area = lahan.area
      ..location = lahan.location
      ..status = lahan.status.label
      ..scanHistory =
          lahan.scanHistory.map(ScanRecordModel.fromDomain).toList();
  }
}
