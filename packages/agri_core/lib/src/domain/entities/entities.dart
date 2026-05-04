// Domain Entities — plain Dart objects, no Flutter or framework imports.

import 'package:equatable/equatable.dart';

// ─── Lahan Status ─────────────────────────────────────────────────────────────

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

// ─── Crop Icon Kind ───────────────────────────────────────────────────────────

enum CropIconKind { grain, leaf, flower }

// ─── Crop Alternative ─────────────────────────────────────────────────────────

class CropAlternative extends Equatable {
  const CropAlternative({required this.name, required this.icon});

  final String name;
  final CropIconKind icon;

  @override
  List<Object?> get props => [name, icon];
}

// ─── Seasonal Month Data ─────────────────────────────────────────────────────
// Per-month summary from the Open-Meteo ECMWF SEAS5 seasonal forecast.

class SeasonalMonthData extends Equatable {
  const SeasonalMonthData({
    required this.monthLabel,
    required this.tempMean,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.et0Sum,
  });

  /// Human-readable month label, e.g. "Mei 2026".
  final String monthLabel;

  /// Mean temperature (°C) for the month.
  final double tempMean;

  /// Maximum temperature (°C) for the month.
  final double tempMax;

  /// Minimum temperature (°C) for the month.
  final double tempMin;

  /// Total precipitation (mm) for the month.
  final double precipitationSum;

  /// Total ET₀ reference evapotranspiration (mm) for the month.
  final double et0Sum;

  @override
  List<Object?> get props =>
      [monthLabel, tempMean, tempMax, tempMin, precipitationSum, et0Sum];
}

// ─── Weather Data ─────────────────────────────────────────────────────────────
// 6-month seasonal forecast from Open-Meteo ECMWF SEAS5.

class WeatherData extends Equatable {
  const WeatherData({
    required this.tempMean,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationTotal,
    required this.et0Mean,
    required this.months,
  });

  /// 6-month average of monthly mean temperatures (°C).
  final double tempMean;

  /// Maximum of monthly max temperatures (°C) across 6 months.
  final double tempMax;

  /// Minimum of monthly min temperatures (°C) across 6 months.
  final double tempMin;

  /// Total accumulated precipitation (mm) over 6 months.
  final double precipitationTotal;

  /// Average daily ET₀ reference evapotranspiration (mm/day) over 6 months.
  final double et0Mean;

  /// Per-month breakdown for UI display (up to 6 entries).
  final List<SeasonalMonthData> months;

  @override
  List<Object?> get props =>
      [tempMean, tempMax, tempMin, precipitationTotal, et0Mean, months];
}

// ─── Crop Recommendation ──────────────────────────────────────────────────────

class CropRecommendation extends Equatable {
  const CropRecommendation({
    required this.main,
    required this.alternatives,
    required this.insight,
    required this.phLabel,
    required this.moistureLabel,
    this.weatherData,
    this.climateInsight,
  });

  final String main;
  final List<CropAlternative> alternatives;
  final String insight;
  final String phLabel;
  final String moistureLabel;

  /// Optional weather context used to enrich the recommendation.
  final WeatherData? weatherData;

  /// Optional climate-based insight summarising weather impact on the crop choice.
  final String? climateInsight;

  @override
  List<Object?> get props =>
      [main, alternatives, insight, phLabel, moistureLabel, weatherData, climateInsight];
}

// ─── Scan Record ──────────────────────────────────────────────────────────────

class ScanRecord extends Equatable {
  const ScanRecord({
    required this.id,
    required this.date,
    required this.ph,
    required this.moisture,
    required this.recommendation,
  });

  final int id;
  final String date;
  final double ph;
  final int moisture;
  final String recommendation;

  @override
  List<Object?> get props => [id, date, ph, moisture, recommendation];
}

// ─── Scan Data ────────────────────────────────────────────────────────────────

class ScanData extends Equatable {
  const ScanData({required this.ph, required this.moisture});

  final double ph;
  final int moisture;

  @override
  List<Object?> get props => [ph, moisture];
}

// ─── BLE Device ───────────────────────────────────────────────────────────────

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

// ─── Lahan ────────────────────────────────────────────────────────────────────

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

  ScanRecord? get latestScan =>
      scanHistory.isNotEmpty ? scanHistory.first : null;

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
