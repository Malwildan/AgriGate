// Repository contracts — abstract interfaces that the domain depends on.
// Implementations live in data layer or device packages.

import '../entities/entities.dart';
import '../failures/failures.dart';

// ─── Result type ──────────────────────────────────────────────────────────────

typedef Either<F, S> = _Either<F, S>;

sealed class _Either<F, S> {
  const _Either();
}

class Left<F, S> extends _Either<F, S> {
  const Left(this.value);
  final F value;
}

class Right<F, S> extends _Either<F, S> {
  const Right(this.value);
  final S value;
}

// Helper extensions
extension EitherExtension<F, S> on Either<F, S> {
  bool get isRight => this is Right<F, S>;
  bool get isLeft => this is Left<F, S>;
  S get right => (this as Right<F, S>).value;
  F get left => (this as Left<F, S>).value;

  T fold<T>(T Function(F failure) onLeft, T Function(S value) onRight) {
    if (this is Left<F, S>) return onLeft((this as Left<F, S>).value);
    return onRight((this as Right<F, S>).value);
  }
}

// ─── Lahan Repository ─────────────────────────────────────────────────────────

abstract interface class LahanRepository {
  Future<Either<Failure, List<Lahan>>> getAllLahan();
  Future<Either<Failure, Lahan>> getLahanById(int id);
  Future<Either<Failure, Lahan>> addLahan(Lahan lahan);
  Future<Either<Failure, Lahan>> updateLahan(Lahan lahan);
  Future<Either<Failure, void>> deleteLahan(int id);
}

// ─── Scan Repository ──────────────────────────────────────────────────────────

abstract interface class ScanRepository {
  Future<Either<Failure, Lahan>> saveScanResult({
    required int lahanId,
    required ScanRecord record,
  });
}

// ─── BLE Service ──────────────────────────────────────────────────────────────

abstract interface class BleService {
  Stream<BleConnectionState> get connectionState;
  Stream<List<BleDevice>> get scanResults;
  Future<void> startScan();
  Future<void> stopScan();
  Future<Either<BleFailure, void>> connectToDevice(String deviceId);
  Future<void> disconnect();
  Future<Either<BleFailure, ScanData>> readSensorData();
}

enum BleConnectionState { disconnected, connecting, connected, disconnecting }

// ─── Location Service ─────────────────────────────────────────────────────────

abstract interface class LocationService {
  Future<Either<Failure, String>> getCurrentLocationString();
  Future<bool> requestPermission();
}

// ─── Weather Repository ───────────────────────────────────────────────────────

abstract interface class WeatherRepository {
  /// Fetches a 7-day aggregated weather forecast for [latitude]/[longitude].
  Future<Either<Failure, WeatherData>> getWeather({
    required double latitude,
    required double longitude,
  });
}
