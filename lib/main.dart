import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/di/injection.dart';
import 'app/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final appConfig = AppConfig.fromEnvironment();
  if (appConfig.supabase.isConfigured) {
    await Supabase.initialize(
      url: appConfig.supabase.url,
      anonKey: appConfig.supabase.anonKey,
    );
  }
  await configureDependencies(appConfig: appConfig);
  appRouter = createAppRouter();
  runApp(const AgriGateApp());
}
