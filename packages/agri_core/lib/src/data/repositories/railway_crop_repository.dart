
import 'package:dio/dio.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/repositories.dart';

class RailwayCropRepository implements CropRecommendationRepository {
  RailwayCropRepository({required String baseUrl, Dio? dio}) : _baseUrl = baseUrl {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ));
  }

  final String _baseUrl;
  late final Dio _dio;

  @override
  Future<Either<Failure, CropRecommendation>> getRecommendation({
    required double ph,
    required int moisture,
    double? latitude,
    double? longitude,
  }) async {
    if (_baseUrl.isEmpty) {
      return const Left(
        RecommendationFailure(
          'RAILWAY_API_URL belum dikonfigurasi. Tambahkan ke .env.json atau dart-define.',
        ),
      );
    }

    if (latitude == null || longitude == null) {
      return const Left(RecommendationFailure(
          'Lokasi GPS diperlukan untuk mendapatkan rekomendasi. Aktifkan GPS dan coba lagi.'));
    }

    try {
      final recommendationFuture = _dio.post<Map<String, dynamic>>(
        '/recommend-crop',
        data: {
          'pH_Value': ph,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final apiMoistureFuture = _fetchSoilMoisturePercent(
        latitude: latitude,
        longitude: longitude,
      );

      final response = await recommendationFuture;
      final apiMoisturePercent = await apiMoistureFuture;

      final data = response.data;
      if (data == null) {
        return const Left(RecommendationFailure('Respons API tidak valid.'));
      }

      return Right(
        _parseRecommendation(
          data,
          ph: ph,
          moisture: apiMoisturePercent ?? moisture,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(
            RecommendationFailure('Koneksi ke server rekomendasi habis waktu.'));
      }
      if (e.response?.statusCode != null) {
        return Left(RecommendationFailure(
            'Server rekomendasi mengembalikan error ${e.response!.statusCode}.'));
      }
      return const Left(RecommendationFailure(
          'Tidak dapat terhubung ke server rekomendasi.'));
    } catch (e) {
      return Left(RecommendationFailure('Gagal mengambil rekomendasi: $e'));
    }
  }

  Future<int?> _fetchSoilMoisturePercent({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://seasonal-api.open-meteo.com/v1/seasonal',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'monthly':
              'soil_moisture_0_to_7cm_mean,soil_moisture_7_to_28cm_mean',
        },
      );

      final body = response.data;
      if (body == null) return null;

      final monthly = body['monthly'] as Map<String, dynamic>?;
      if (monthly == null) return null;

      final topLayerRaw = monthly['soil_moisture_0_to_7cm_mean'] as List?;
      final rootLayerRaw = monthly['soil_moisture_7_to_28cm_mean'] as List?;
      if (topLayerRaw == null || rootLayerRaw == null) return null;

      final topLayer = topLayerRaw.whereType<num>().map((e) => e.toDouble()).toList();
      final rootLayer =
          rootLayerRaw.whereType<num>().map((e) => e.toDouble()).toList();
      if (topLayer.isEmpty || rootLayer.isEmpty) return null;

      final topMean = topLayer.reduce((a, b) => a + b) / topLayer.length;
      final rootMean = rootLayer.reduce((a, b) => a + b) / rootLayer.length;
      final volumeFraction = (topMean + rootMean) / 2;

      return (volumeFraction * 100).round().clamp(0, 100).toInt();
    } catch (_) {
      return null;
    }
  }

  static CropRecommendation _parseRecommendation(
    Map<String, dynamic> json, {
    required double ph,
    required int moisture,
  }) {
    final rawCrop = json['recommendation'] as String? ?? '';
    final main = _translateCrop(rawCrop);

    final phLabel = phLabelFor(ph);
    final moistureLabel = moistureLabelFor(moisture);

    final rawFeatures = json['fetched_features'] as Map<String, dynamic>?;
    WeatherData? weatherData;
    String? climateInsight;

    if (rawFeatures != null) {
      final temp = (rawFeatures['temperature'] as num?)?.toDouble() ?? 0.0;
      final humidity = (rawFeatures['humidity'] as num?)?.toDouble() ?? 0.0;
      final rainfall90d =
          (rawFeatures['total_rainfall_90d'] as num?)?.toDouble() ?? 0.0;
      weatherData = WeatherData(
        tempMean: temp,
        tempMax: temp,
        tempMin: temp,
        precipitationTotal: rainfall90d,
        et0Mean: 0.0,
        months: const [],
        humidityMean: humidity,
      );
      climateInsight = _buildClimateInsight(temp, rainfall90d);
    }

    return CropRecommendation(
      main: main,
      alternatives: _alternativesFor(main),
      insight: _insightFor(main, phLabel, moistureLabel),
      phLabel: phLabel,
      moistureLabel: moistureLabel,
      soilMoisturePercent: moisture,
      weatherData: weatherData,
      climateInsight: climateInsight,
    );
  }

  static const _cropTranslations = <String, String>{
    'rice': 'Padi',
    'maize': 'Jagung',
    'corn': 'Jagung',
    'cassava': 'Singkong',
    'soybean': 'Kedelai',
    'soybeans': 'Kedelai',
    'groundnut': 'Kacang Tanah',
    'peanut': 'Kacang Tanah',
    'sweet potato': 'Ubi Jalar',
    'sweetpotato': 'Ubi Jalar',
    'wheat': 'Gandum',
    'sorghum': 'Sorgum',
    'spinach': 'Bayam',
    'water spinach': 'Kangkung',
    'kangkung': 'Kangkung',
    'banana': 'Pisang',
    'mango': 'Mangga',
    'coffee': 'Kopi',
    'coconut': 'Kelapa',
    'sugarcane': 'Tebu',
    'cotton': 'Kapas',
    'chili': 'Cabai',
    'chilli': 'Cabai',
    'pepper': 'Lada',
    'watermelon': 'Semangka',
    'orange': 'Jeruk',
    'papaya': 'Pepaya',
    'pineapple': 'Nanas',
    'tomato': 'Tomat',
    'eggplant': 'Terong',
    'cabbage': 'Kubis',
    'cucumber': 'Mentimun',
    'garlic': 'Bawang Putih',
    'onion': 'Bawang Merah',
    'ginger': 'Jahe',
    'turmeric': 'Kunyit',
  };

  static String _translateCrop(String raw) {
    final key = raw.trim().toLowerCase();
    return _cropTranslations[key] ?? raw;
  }

  static List<CropAlternative> _alternativesFor(String main) {
    return switch (main) {
      'Padi' => const [
          CropAlternative(name: 'Kangkung', icon: CropIconKind.leaf),
          CropAlternative(name: 'Bayam', icon: CropIconKind.flower),
        ],
      'Jagung' => const [
          CropAlternative(name: 'Kacang Tanah', icon: CropIconKind.flower),
          CropAlternative(name: 'Singkong', icon: CropIconKind.leaf),
        ],
      'Singkong' => const [
          CropAlternative(name: 'Ubi Jalar', icon: CropIconKind.grain),
          CropAlternative(name: 'Sorgum', icon: CropIconKind.grain),
        ],
      'Kedelai' => const [
          CropAlternative(name: 'Kacang Tanah', icon: CropIconKind.flower),
          CropAlternative(name: 'Jagung', icon: CropIconKind.grain),
        ],
      'Kacang Tanah' => const [
          CropAlternative(name: 'Kedelai', icon: CropIconKind.flower),
          CropAlternative(name: 'Singkong', icon: CropIconKind.leaf),
        ],
      _ => const [
          CropAlternative(name: 'Jagung', icon: CropIconKind.grain),
          CropAlternative(name: 'Singkong', icon: CropIconKind.leaf),
        ],
    };
  }

  static String _insightFor(
      String main, String phLabel, String moistureLabel) {
    return 'Berdasarkan analisis pH ${phLabel.toLowerCase()} dan kelembapan '
        '${moistureLabel.toLowerCase()} serta kondisi cuaca setempat, '
        '$main direkomendasikan sebagai tanaman yang paling sesuai untuk lahan Anda.';
  }

  static String _buildClimateInsight(double temp, double rainfall90d) {
    final parts = <String>[];

    if (temp > 33) {
      parts.add(
          'Suhu udara ${temp.toStringAsFixed(1)} °C – waspadai stres panas, pastikan irigasi cukup.');
    } else if (temp < 20) {
      parts.add(
          'Suhu udara ${temp.toStringAsFixed(1)} °C di bawah optimal – pertimbangkan varietas adaptif suhu rendah.');
    } else {
      parts.add(
          'Suhu udara ${temp.toStringAsFixed(1)} °C berada dalam kisaran optimal.');
    }

    if (rainfall90d < 100) {
      parts.add(
          'Curah hujan 90 hari terakhir sangat rendah (${rainfall90d.toStringAsFixed(0)} mm) – irigasi penuh diperlukan.');
    } else if (rainfall90d > 600) {
      parts.add(
          'Curah hujan 90 hari tinggi (${rainfall90d.toStringAsFixed(0)} mm) – pastikan drainase lahan memadai.');
    } else {
      parts.add(
          'Total curah hujan 90 hari: ${rainfall90d.toStringAsFixed(0)} mm – kondisi cukup baik untuk pertanaman.');
    }

    return parts.join(' ');
  }
}
