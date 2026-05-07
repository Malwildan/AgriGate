
import 'package:equatable/equatable.dart';

enum LahanStatus {
  aktif('Aktif'),
  perencanaan('Perencanaan'),
  tidakAktif('Tidak Aktif');

  const LahanStatus(this.label);
  final String label;

  static LahanStatus fromString(String value) {
    return LahanStatus.values.firstWhere(
      (s) => s.label == value,
      orElse: () => LahanStatus.aktif,
    );
  }
}

enum CropIconKind { grain, leaf, flower }

String phLabelFor(double ph) {
  if (ph < 5.5) return 'Sangat Asam';
  if (ph < 6.0) return 'Asam';
  if (ph < 7.0) return 'Netral';
  if (ph < 7.5) return 'Basa Ringan';
  return 'Basa';
}

String moistureLabelFor(int moisture) {
  if (moisture < 40) return 'Rendah';
  if (moisture < 60) return 'Sedang';
  if (moisture < 75) return 'Cukup';
  return 'Tinggi';
}

class CropAlternative extends Equatable {
  const CropAlternative({required this.name, required this.icon});

  final String name;
  final CropIconKind icon;

  @override
  List<Object?> get props => [name, icon];
}

class SeasonalMonthData extends Equatable {
  const SeasonalMonthData({
    required this.monthLabel,
    required this.tempMean,
    required this.tempMax,
    required this.tempMin,
    required this.humidityMean,
    required this.precipitationSum,
    required this.et0Sum,
  });
  final String monthLabel;
  final double tempMean;
  final double tempMax;
  final double tempMin;
  final double humidityMean;
  final double precipitationSum;
  final double et0Sum;

  @override
  List<Object?> get props =>
      [monthLabel, tempMean, tempMax, tempMin, humidityMean, precipitationSum, et0Sum];
}

class WeatherData extends Equatable {
  const WeatherData({
    required this.tempMean,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationTotal,
    required this.et0Mean,
    required this.months,
    this.humidityMean = 0.0,
  });
  final double tempMean;
  final double tempMax;
  final double tempMin;
  final double precipitationTotal;
  final double et0Mean;
  final List<SeasonalMonthData> months;
  final double humidityMean;

  @override
  List<Object?> get props =>
      [tempMean, tempMax, tempMin, precipitationTotal, et0Mean, months, humidityMean];
}

class CropRecommendation extends Equatable {
  const CropRecommendation({
    required this.main,
    required this.alternatives,
    required this.insight,
    required this.phLabel,
    required this.moistureLabel,
    this.soilMoisturePercent,
    this.weatherData,
    this.climateInsight,
  });

  final String main;
  final List<CropAlternative> alternatives;
  final String insight;
  final String phLabel;
  final String moistureLabel;
  final int? soilMoisturePercent;
  final WeatherData? weatherData;
  final String? climateInsight;

  @override
  List<Object?> get props =>
      [
        main,
        alternatives,
        insight,
        phLabel,
        moistureLabel,
        soilMoisturePercent,
        weatherData,
        climateInsight,
      ];
}

class ScanRecord extends Equatable {
  const ScanRecord({
    required this.id,
    required this.recordedAt,
    required this.ph,
    required this.moisture,
    required this.recommendation,
  });

  final int id;
  final DateTime recordedAt;
  final double ph;
  final int moisture;
  final String recommendation;

  @override
  List<Object?> get props => [id, recordedAt, ph, moisture, recommendation];
}

class ScanData extends Equatable {
  const ScanData({required this.ph, required this.moisture});

  final double ph;
  final int moisture;

  @override
  List<Object?> get props => [ph, moisture];
}

class BleDevice extends Equatable {
  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });

  final String id;
  final String name;
  final int rssi;

  String get displayName {
    final trimmedName = name.trim();
    return trimmedName.isNotEmpty ? trimmedName : id;
  }

  @override
  List<Object?> get props => [id, name, rssi];
}

class Lahan extends Equatable {
  const Lahan({
    required this.id,
    required this.owner,
    required this.area,
    required this.location,
    required this.status,
    required this.scanHistory,
  });

  final int id;
  final String owner;
  final String area;
  final String location;
  final LahanStatus status;
  final List<ScanRecord> scanHistory;

  ScanRecord? get latestScan {
    if (scanHistory.isEmpty) {
      return null;
    }
    return scanHistory.reduce(
      (latest, current) => current.recordedAt.isAfter(latest.recordedAt)
          ? current
          : latest,
    );
  }

  Lahan copyWith({
    int? id,
    String? owner,
    String? area,
    String? location,
    LahanStatus? status,
    List<ScanRecord>? scanHistory,
  }) {
    return Lahan(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      area: area ?? this.area,
      location: location ?? this.location,
      status: status ?? this.status,
      scanHistory: scanHistory ?? this.scanHistory,
    );
  }

  @override
  List<Object?> get props => [id, owner, area, location, status, scanHistory];
}
