// Dependency injection — wires all repositories, use cases, services, and BLoCs.

import 'dart:async';

import 'package:get_it/get_it.dart';
import '../../core/core.dart';
import '../../services/ble/ble_service_impl.dart';
import '../../services/location/location_service_impl.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Repositories (singletons, opened asynchronously) ──────────────────────
  final lahanRepo = await HiveLahanRepository.open();
  final scanRepo = HiveScanRepository(lahanRepo);
  final bleService = BleServiceImpl();

  getIt
    ..registerSingleton<LahanRepository>(lahanRepo)
    ..registerSingleton<ScanRepository>(scanRepo)
    ..registerSingleton<WeatherRepository>(OpenMeteoWeatherRepository())

    // ── Services ──────────────────────────────────────────────────────────────
    ..registerSingleton<BleService>(bleService)
    ..registerSingleton<LocationService>(LocationServiceImpl())

    // ── Use cases ─────────────────────────────────────────────────────────────
    ..registerFactory(() => GetAllLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => GetLahanByIdUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => AddLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => UpdateLahanStatusUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => SaveScanResultUseCase(getIt<ScanRepository>()))
    ..registerFactory(() => GetWeatherUseCase(getIt<WeatherRepository>()));

  unawaited(bleService.initialize());
}
