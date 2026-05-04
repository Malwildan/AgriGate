// Open-Meteo Seasonal Weather Repository — fetches 180-day daily data from
// ECMWF SEAS5 / EC46 and aggregates it into monthly buckets for
// climate-resilient crop recommendations.

import 'package:dio/dio.dart';
import '../../domain/entities/entities.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/repositories.dart';

/// Daily variables fetched from the Open-Meteo Seasonal Forecast API.
const _kDailyVars = [
  'temperature_2m_max',
  'temperature_2m_min',
  'temperature_2m_mean',
  'precipitation_sum',
  'et0_fao_evapotranspiration',
];

class OpenMeteoWeatherRepository implements WeatherRepository {
  OpenMeteoWeatherRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://seasonal-api.open-meteo.com',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  final Dio _dio;

  @override
  Future<Either<Failure, WeatherData>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/seasonal',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily': _kDailyVars.join(','),
          'forecast_days': 180,
          'timezone': 'auto',
        },
      );

      final data = response.data;
      if (data == null || data['daily'] == null) {
        return const Left(
            WeatherFailure('Respons data prakiraan musiman tidak valid.'));
      }

      final daily = data['daily'] as Map<String, dynamic>;
      return Right(_buildWeatherData(daily));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(
            WeatherFailure('Koneksi ke server prakiraan musiman habis waktu.'));
      }
      if (e.response?.statusCode != null) {
        return Left(WeatherFailure(
            'Server cuaca mengembalikan error ${e.response!.statusCode}.'));
      }
      return const Left(
          WeatherFailure('Tidak dapat terhubung ke server prakiraan musiman.'));
    } catch (e) {
      return Left(WeatherFailure('Gagal mengambil prakiraan musiman: $e'));
    }
  }

  /// Groups 180 daily values by calendar month and builds [WeatherData].
  static WeatherData _buildWeatherData(Map<String, dynamic> daily) {
    final times = (daily['time'] as List?)?.cast<String>() ?? [];
    if (times.isEmpty) {
      return const WeatherData(
        tempMean: 0,
        tempMax: 0,
        tempMin: 0,
        precipitationTotal: 0,
        et0Mean: 0,
        months: [],
      );
    }

    List<double> safeList(String key) {
      final raw = daily[key];
      if (raw == null) return List.filled(times.length, 0.0);
      return (raw as List)
          .map((e) => (e as num?)?.toDouble() ?? 0.0)
          .toList();
    }

    final tempMaxes = safeList('temperature_2m_max');
    final tempMins = safeList('temperature_2m_min');
    final tempMeans = safeList('temperature_2m_mean');
    final precips = safeList('precipitation_sum');
    final et0s = safeList('et0_fao_evapotranspiration');

    // ── Group days into months ────────────────────────────────────────────────
    // Key: "YYYY-MM", value: list of per-day values for that month.
    final monthKeys = <String>[];
    final byMonth = <String, List<int>>{};

    for (var i = 0; i < times.length; i++) {
      final key = times[i].length >= 7 ? times[i].substring(0, 7) : '';
      if (key.isEmpty) continue;
      if (!byMonth.containsKey(key)) {
        monthKeys.add(key);
        byMonth[key] = [];
      }
      byMonth[key]!.add(i);
    }

    double avg(List<double> src, List<int> idx) {
      if (idx.isEmpty) return 0;
      return idx.map((i) => src[i]).reduce((a, b) => a + b) / idx.length;
    }

    double maxOf(List<double> src, List<int> idx) {
      if (idx.isEmpty) return 0;
      return idx.map((i) => src[i]).reduce((a, b) => a > b ? a : b);
    }

    double minOf(List<double> src, List<int> idx) {
      if (idx.isEmpty) return 0;
      return idx.map((i) => src[i]).reduce((a, b) => a < b ? a : b);
    }

    double sumOf(List<double> src, List<int> idx) {
      if (idx.isEmpty) return 0;
      return idx.map((i) => src[i]).reduce((a, b) => a + b);
    }

    final months = monthKeys.map((key) {
      final idx = byMonth[key]!;
      return SeasonalMonthData(
        monthLabel: _formatMonthLabel(key),
        tempMean: avg(tempMeans, idx),
        tempMax: maxOf(tempMaxes, idx),
        tempMin: minOf(tempMins, idx),
        precipitationSum: sumOf(precips, idx),
        et0Sum: sumOf(et0s, idx),
      );
    }).toList();

    // ── 6-month aggregate fields ──────────────────────────────────────────────
    final allIdx = List.generate(times.length, (i) => i);

    return WeatherData(
      tempMean: avg(tempMeans, allIdx),
      tempMax: maxOf(tempMaxes, allIdx),
      tempMin: minOf(tempMins, allIdx),
      precipitationTotal: sumOf(precips, allIdx),
      et0Mean: avg(et0s, allIdx),
      months: months,
    );
  }

  /// Converts a "YYYY-MM" string to an Indonesian month label, e.g. "Mei 2026".
  static String _formatMonthLabel(String yyyyMm) {
    if (yyyyMm.length < 7) return yyyyMm;
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final year = yyyyMm.substring(0, 4);
    final month = int.tryParse(yyyyMm.substring(5, 7)) ?? 0;
    if (month < 1 || month > 12) return yyyyMm;
    return '${bulan[month]} $year';
  }
}

