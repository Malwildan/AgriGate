// Location service implementation using geolocator.

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agri_core/agri_core.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  @override
  Future<Either<Failure, String>> getCurrentLocationString() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationPermissionFailure('Layanan lokasi tidak aktif'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(LocationPermissionFailure('Izin lokasi ditolak'));
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return const Left(LocationPermissionFailure(
            'Izin lokasi ditolak permanen, silakan aktifkan di pengaturan'));
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final lat = position.latitude.toStringAsFixed(6);
      final lon = position.longitude.toStringAsFixed(6);
      return Right('$lat, $lon');
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => message;
}
