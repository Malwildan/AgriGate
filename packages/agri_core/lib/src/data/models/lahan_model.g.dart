// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lahan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanRecordModelAdapter extends TypeAdapter<ScanRecordModel> {
  @override
  final int typeId = 0;

  @override
  ScanRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanRecordModel()
      ..id = fields[0] as int
      ..date = fields[1] as String
      ..ph = fields[2] as double
      ..moisture = fields[3] as int
      ..recommendation = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, ScanRecordModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.ph)
      ..writeByte(3)
      ..write(obj.moisture)
      ..writeByte(4)
      ..write(obj.recommendation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LahanModelAdapter extends TypeAdapter<LahanModel> {
  @override
  final int typeId = 1;

  @override
  LahanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LahanModel()
      ..id = fields[0] as int
      ..owner = fields[1] as String
      ..area = fields[2] as String
      ..location = fields[3] as String
      ..status = fields[4] as String
      ..scanHistory = (fields[5] as List).cast<ScanRecordModel>();
  }

  @override
  void write(BinaryWriter writer, LahanModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.owner)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.scanHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LahanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
