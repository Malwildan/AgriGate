import 'package:flutter/foundation.dart';

import 'supabase_config.dart';

/// Runtime configuration loaded from `--dart-define-from-file` / build flags.
class AppConfig {
  const AppConfig({
    required this.supabase,
    required this.railwayApiUrl,
    required this.enableDemoSeed,
  });

  factory AppConfig.fromEnvironment() {
    final supabase = SupabaseConfig.fromEnvironment();
    const railwayApiUrl = String.fromEnvironment('RAILWAY_API_URL');
    const demoSeedFlag = String.fromEnvironment('ENABLE_DEMO_SEED');

    final enableDemoSeed = !kReleaseMode &&
        demoSeedFlag == 'true' &&
        !supabase.isConfigured;

    return AppConfig(
      supabase: supabase,
      railwayApiUrl: railwayApiUrl.trim(),
      enableDemoSeed: enableDemoSeed,
    );
  }

  final SupabaseConfig supabase;
  final String railwayApiUrl;
  final bool enableDemoSeed;

  bool get isRailwayConfigured => railwayApiUrl.isNotEmpty;
}
