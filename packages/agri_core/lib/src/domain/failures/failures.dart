// Failure types — sealed class hierarchy for typed error handling.

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal membaca data lokal.']);
}

class BleFailure extends Failure {
  const BleFailure([super.message = 'Koneksi Bluetooth gagal.']);
}

class BlePermissionFailure extends Failure {
  const BlePermissionFailure([super.message = 'Izin Bluetooth ditolak.']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([super.message = 'Izin lokasi ditolak.']);
}

class LocationTimeoutFailure extends Failure {
  const LocationTimeoutFailure([super.message = 'Waktu habis saat mengambil lokasi.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Data tidak valid.']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Terjadi kesalahan tak terduga.']);
}

class WeatherFailure extends Failure {
  const WeatherFailure([super.message = 'Gagal mengambil data cuaca.']);
}
