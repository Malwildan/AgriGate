// Dependency injection — wires all repositories, use cases, services, and BLoCs.

import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../core/core.dart';
import '../../services/ble/ble_service_impl.dart';
import '../../services/location/location_service_impl.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required SupabaseConfig supabaseConfig,
}) async {
  // ── Repositories (singletons, opened asynchronously) ──────────────────────
  final supabaseClient =
      supabaseConfig.isConfigured ? Supabase.instance.client : null;
  final sessionService = supabaseClient == null
      ? null
      : SupabaseSessionService(supabaseClient);
  final remoteDataSource = supabaseClient == null
      ? null
      : SupabaseLahanRemoteDataSource(supabaseClient);
  final lahanRepo = await OfflineFirstLahanRepository.open(
    enableDemoSeed: !supabaseConfig.isConfigured,
    remoteDataSource: remoteDataSource,
    sessionService: sessionService,
  );
  final bleService = BleServiceImpl();

  if (supabaseClient != null) {
    getIt.registerSingleton<SupabaseClient>(supabaseClient);
  }
  if (sessionService != null) {
    getIt.registerSingleton<SupabaseSessionService>(sessionService);
  }
  if (remoteDataSource != null) {
    getIt.registerSingleton<SupabaseLahanRemoteDataSource>(remoteDataSource);
  }

  getIt
    ..registerSingleton<SupabaseConfig>(supabaseConfig)
    ..registerSingleton<LahanRepository>(lahanRepo)
    ..registerSingleton<ScanRepository>(lahanRepo)
    ..registerSingleton<SyncRepository>(lahanRepo)
    ..registerSingleton<WeatherRepository>(OpenMeteoWeatherRepository())

    // ── Services ──────────────────────────────────────────────────────────────
    ..registerSingleton<BleService>(bleService)
    ..registerSingleton<LocationService>(LocationServiceImpl())

    // ── Use cases ─────────────────────────────────────────────────────────────
    ..registerFactory(() => GetAllLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => SyncLahanDataUseCase(getIt<SyncRepository>()))
    ..registerFactory(() => GetLahanByIdUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => AddLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => UpdateLahanStatusUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => SaveScanResultUseCase(
          getIt<ScanRepository>(),
          getIt<LahanRepository>(),
        ))
    ..registerFactory(() => GetWeatherUseCase(getIt<WeatherRepository>()));

  unawaited(bleService.initialize());
}
