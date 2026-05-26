
import 'dart:async';

import 'package:agri_core/agri_core.dart';
import 'package:device_ble/device_ble.dart';
import 'package:device_location/device_location.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required AppConfig appConfig,
}) async {
  final supabaseClient =
      appConfig.supabase.isConfigured ? Supabase.instance.client : null;
  final authService =
      supabaseClient == null ? null : SupabaseAuthService(supabaseClient);
  final remoteDataSource = supabaseClient == null
      ? null
      : SupabaseLahanRemoteDataSource(supabaseClient);
  final lahanRepo = await OfflineFirstLahanRepository.open(
    enableDemoSeed: appConfig.enableDemoSeed,
    remoteDataSource: remoteDataSource,
    authService: authService,
  );
  final bleService = BleServiceImpl();

  if (supabaseClient != null) {
    getIt.registerSingleton<SupabaseClient>(supabaseClient);
  }
  if (authService != null) {
    getIt.registerSingleton<SupabaseAuthService>(authService);
  }
  if (remoteDataSource != null) {
    getIt.registerSingleton<SupabaseLahanRemoteDataSource>(remoteDataSource);
  }

  getIt
    ..registerSingleton<AppConfig>(appConfig)
    ..registerSingleton<LahanRepository>(lahanRepo)
    ..registerSingleton<ScanRepository>(lahanRepo)
    ..registerSingleton<SyncRepository>(lahanRepo)
    ..registerSingleton<CropRecommendationRepository>(
      RailwayCropRepository(baseUrl: appConfig.railwayApiUrl),
    )
    ..registerSingleton<BleService>(bleService)
    ..registerSingleton<LocationService>(LocationServiceImpl())
    ..registerFactory(() => GetAllLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => SyncLahanDataUseCase(getIt<SyncRepository>()))
    ..registerFactory(() => GetLahanByIdUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => AddLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => UpdateLahanStatusUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => DeleteLahanUseCase(getIt<LahanRepository>()))
    ..registerFactory(() => SaveScanResultUseCase(
          getIt<ScanRepository>(),
          getIt<LahanRepository>(),
        ))
    ..registerFactory(() =>
        GetCropRecommendationUseCase(getIt<CropRecommendationRepository>()));

  unawaited(bleService.initialize());
}
