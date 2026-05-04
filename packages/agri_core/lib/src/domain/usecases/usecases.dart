// Use cases — each encapsulates a single business operation.

import '../entities/entities.dart';
import '../failures/failures.dart';
import '../repositories/repositories.dart';

// ─── Use Case base ────────────────────────────────────────────────────────────

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}

// ─── GetAllLahan ──────────────────────────────────────────────────────────────

class GetAllLahanUseCase implements UseCase<List<Lahan>, NoParams> {
  const GetAllLahanUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, List<Lahan>>> call(NoParams params) =>
      _repository.getAllLahan();
}

// ─── GetLahanById ─────────────────────────────────────────────────────────────

class GetLahanByIdUseCase implements UseCase<Lahan, int> {
  const GetLahanByIdUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, Lahan>> call(int id) => _repository.getLahanById(id);
}

// ─── AddLahan ─────────────────────────────────────────────────────────────────

class AddLahanParams {
  const AddLahanParams({
    required this.owner,
    required this.area,
    required this.location,
  });

  final String owner;
  final String area;
  final String location;
}

class AddLahanUseCase implements UseCase<Lahan, AddLahanParams> {
  const AddLahanUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, Lahan>> call(AddLahanParams params) {
    final lahan = Lahan(
      id: DateTime.now().millisecondsSinceEpoch,
      owner: params.owner.trim().isEmpty ? 'Pemilik Baru' : params.owner.trim(),
      area: params.area.trim().isEmpty ? 'Lahan Baru' : params.area.trim(),
      location: params.location.trim(),
      status: LahanStatus.aktif,
      scanHistory: const [],
    );
    return _repository.addLahan(lahan);
  }
}

// ─── UpdateLahanStatus ────────────────────────────────────────────────────────

class UpdateLahanStatusParams {
  const UpdateLahanStatusParams({required this.lahanId, required this.status});

  final int lahanId;
  final LahanStatus status;
}

class UpdateLahanStatusUseCase implements UseCase<Lahan, UpdateLahanStatusParams> {
  const UpdateLahanStatusUseCase(this._repository);

  final LahanRepository _repository;

  @override
  Future<Either<Failure, Lahan>> call(UpdateLahanStatusParams params) async {
    final result = await _repository.getLahanById(params.lahanId);
    if (result.isLeft) return result;
    final updated = result.right.copyWith(status: params.status);
    return _repository.updateLahan(updated);
  }
}

// ─── SaveScanResult ───────────────────────────────────────────────────────────

class SaveScanResultParams {
  const SaveScanResultParams({
    required this.lahanId,
    required this.ph,
    required this.moisture,
  });

  final int lahanId;
  final double ph;
  final int moisture;
}

class SaveScanResultUseCase implements UseCase<Lahan, SaveScanResultParams> {
  const SaveScanResultUseCase(this._scanRepository);

  final ScanRepository _scanRepository;

  @override
  Future<Either<Failure, Lahan>> call(SaveScanResultParams params) async {
    final rec = GetRecommendationUseCase.compute(
      ph: params.ph,
      moisture: params.moisture,
    );
    final record = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch,
      date: _formatDate(DateTime.now()),
      ph: params.ph,
      moisture: params.moisture,
      recommendation: rec.main,
    );
    return _scanRepository.saveScanResult(
      lahanId: params.lahanId,
      record: record,
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

// ─── GetWeather ───────────────────────────────────────────────────────────────

class GetWeatherParams {
  const GetWeatherParams({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class GetWeatherUseCase implements UseCase<WeatherData, GetWeatherParams> {
  const GetWeatherUseCase(this._repository);

  final WeatherRepository _repository;

  @override
  Future<Either<Failure, WeatherData>> call(GetWeatherParams params) =>
      _repository.getWeather(
        latitude: params.latitude,
        longitude: params.longitude,
      );
}

// ─── GetRecommendation ────────────────────────────────────────────────────────
// Pure computation — no repository needed.

class GetRecommendationUseCase {
  const GetRecommendationUseCase();

  CropRecommendation call({
    required double ph,
    required int moisture,
    WeatherData? weather,
  }) =>
      compute(ph: ph, moisture: moisture, weather: weather);

  static CropRecommendation compute({
    required double ph,
    required int moisture,
    WeatherData? weather,
  }) {
    final phLabel = _phLabel(ph);
    final moistureLabel = _moistureLabel(moisture);

    // ── Climate signal flags ──────────────────────────────────────────────────
    // High rain: 6-month total > 900 mm (≈150 mm/month) → very wet conditions.
    final highRain = weather != null && weather.precipitationTotal > 900;

    // Drought: very low 6-month total + elevated daily evapotranspiration.
    final drought = weather != null &&
        weather.precipitationTotal < 250 &&
        weather.et0Mean > 3.5;

    // Extreme heat: max monthly temperature exceeds 35 °C.
    final heatStress = weather != null && weather.tempMax > 35;

    // Cool / sub-optimal: 6-month mean temp below 20 °C (bad for tropical staples).
    final coolStress = weather != null && weather.tempMean < 20;

    // ── Soil-based primary recommendation ─────────────────────────────────────
    String main;
    List<CropAlternative> alternatives;
    String soilInsight;

    if (ph >= 6.0 && ph <= 7.5 && moisture >= 40 && moisture <= 70) {
      main = 'Jagung';
      alternatives = const [
        CropAlternative(name: 'Kacang Tanah', icon: CropIconKind.flower),
        CropAlternative(name: 'Singkong', icon: CropIconKind.leaf),
      ];
      soilInsight =
          'Tanah dalam kondisi ${phLabel.toLowerCase()} dengan kelembapan '
          '${moistureLabel.toLowerCase()}, cocok untuk tanaman dengan kebutuhan air moderat.';
    } else if (ph < 6.0 && moisture < 60) {
      main = 'Singkong';
      alternatives = const [
        CropAlternative(name: 'Ubi Jalar', icon: CropIconKind.grain),
        CropAlternative(name: 'Kacang Tanah', icon: CropIconKind.flower),
      ];
      soilInsight =
          'Tanah cenderung ${phLabel.toLowerCase()} dengan kelembapan '
          '${moistureLabel.toLowerCase()}. Pilih tanaman toleran pH rendah untuk hasil optimal.';
    } else if (moisture > 70 || ph > 7.5) {
      final condition = moisture > 70
          ? 'kelembapan ${moistureLabel.toLowerCase()}'
          : 'pH ${phLabel.toLowerCase()}';
      main = 'Padi';
      alternatives = const [
        CropAlternative(name: 'Kangkung', icon: CropIconKind.leaf),
        CropAlternative(name: 'Bayam', icon: CropIconKind.flower),
      ];
      soilInsight =
          'Kondisi tanah dengan $condition ideal untuk tanaman yang menyukai banyak air.';
    } else {
      main = 'Kedelai';
      alternatives = const [
        CropAlternative(name: 'Sorgum', icon: CropIconKind.grain),
        CropAlternative(name: 'Gandum', icon: CropIconKind.flower),
      ];
      soilInsight =
          'Tanah dengan kelembapan ${moistureLabel.toLowerCase()} membutuhkan '
          'manajemen irigasi yang baik untuk pertumbuhan optimal.';
    }

    // ── Climate override — strong weather signals can shift the recommendation ─
    if (weather != null) {
      if (highRain && main != 'Padi') {
        // High forecasted rain strongly favours wet-tolerant crops.
        main = 'Padi';
        alternatives = const [
          CropAlternative(name: 'Kangkung', icon: CropIconKind.leaf),
          CropAlternative(name: 'Bayam', icon: CropIconKind.flower),
        ];
        soilInsight =
            'Prakiraan curah hujan 6 bulan sangat tinggi '
            '(${weather.precipitationTotal.toStringAsFixed(0)} mm) '
            'mendukung kuat tanaman toleran air meskipun kondisi tanah '
            '${phLabel.toLowerCase()}.';
      } else if (drought && main != 'Singkong') {
        // Very dry forecast with high ET₀ — shift to drought-tolerant crops.
        main = 'Singkong';
        alternatives = const [
          CropAlternative(name: 'Sorgum', icon: CropIconKind.grain),
          CropAlternative(name: 'Kacang Tanah', icon: CropIconKind.flower),
        ];
        soilInsight =
            'Prakiraan musiman kering (total 6 bulan: '
            '${weather.precipitationTotal.toStringAsFixed(0)} mm, '
            'ET₀ harian: ${weather.et0Mean.toStringAsFixed(1)} mm/hari) '
            'menyarankan tanaman tahan kekeringan.';
      }
    }

    // ── Build climate insight string ───────────────────────────────────────────
    String? climateInsight;
    if (weather != null) {
      final parts = <String>[];

      if (heatStress) {
        parts.add(
            'Suhu maks. ${weather.tempMax.toStringAsFixed(1)} °C – waspadai stres panas, '
            'pastikan irigasi cukup dan gunakan mulsa.');
      }
      if (coolStress) {
        parts.add(
            'Suhu rata-rata ${weather.tempMean.toStringAsFixed(1)} °C di bawah optimal – '
            'pertimbangkan varietas adaptif suhu rendah.');
      }
      if (drought) {
        parts.add(
            'Risiko kekeringan musiman: total curah hujan 6 bulan hanya '
            '${weather.precipitationTotal.toStringAsFixed(0)} mm – '
            'irigasi penuh sangat disarankan.');
      } else if (highRain) {
        parts.add(
            'Curah hujan musiman sangat tinggi '
            '(${weather.precipitationTotal.toStringAsFixed(0)} mm / 6 bulan) – '
            'pastikan drainase lahan memadai.');
      } else {
        parts.add(
            'Total curah hujan 6 bulan: '
            '${weather.precipitationTotal.toStringAsFixed(0)} mm, '
            'ET₀ harian rata-rata: ${weather.et0Mean.toStringAsFixed(1)} mm/hari.');
      }

      climateInsight = parts.join(' ');
    }

    return CropRecommendation(
      main: main,
      alternatives: alternatives,
      insight: soilInsight,
      phLabel: phLabel,
      moistureLabel: moistureLabel,
      weatherData: weather,
      climateInsight: climateInsight,
    );
  }

  static String _phLabel(double ph) {
    if (ph < 5.5) return 'Sangat Asam';
    if (ph < 6.0) return 'Asam';
    if (ph < 7.0) return 'Netral';
    if (ph < 7.5) return 'Basa Ringan';
    return 'Basa';
  }

  static String _moistureLabel(int moisture) {
    if (moisture < 40) return 'Rendah';
    if (moisture < 60) return 'Sedang';
    if (moisture < 75) return 'Cukup';
    return 'Tinggi';
  }
}
