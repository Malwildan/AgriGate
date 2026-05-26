import 'package:agri_core/agri_core.dart';

/// Parses BLE sensor payloads. Supports legacy `PH:6.5` and `PH:6.5;MOISTURE:45`.
class SensorPayloadParser {
  const SensorPayloadParser._();

  static Either<BleFailure, ScanData> parse(String rawPayload) {
    final payload = rawPayload.trim();
    if (payload.isEmpty) {
      return const Left(BleFailure('Payload sensor kosong.'));
    }

    final segments = payload.split(RegExp(r'[;,]'));
    double? ph;
    int? moisture;

    for (final segment in segments) {
      final trimmed = segment.trim();
      if (trimmed.isEmpty) continue;

      final upper = trimmed.toUpperCase();
      if (upper.startsWith('PH:')) {
        ph = double.tryParse(trimmed.substring(3).trim());
        continue;
      }
      if (upper.startsWith('MOISTURE:') || upper.startsWith('MOIST:')) {
        final value = trimmed.contains(':')
            ? trimmed.split(':').last.trim()
            : trimmed;
        moisture = int.tryParse(value);
      }
    }

    if (ph == null || ph < 0 || ph > 14) {
      return Left(BleFailure('Nilai pH tidak valid: $payload'));
    }

    final resolvedMoisture = moisture ?? 0;
    if (resolvedMoisture < 0 || resolvedMoisture > 100) {
      return Left(BleFailure('Nilai kelembapan tidak valid: $payload'));
    }

    return Right(ScanData(ph: ph, moisture: resolvedMoisture));
  }
}
