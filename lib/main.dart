import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/config/supabase_config.dart';
import 'app/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final supabaseConfig = SupabaseConfig.fromEnvironment();
  if (supabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: supabaseConfig.url,
      anonKey: supabaseConfig.anonKey,
    );
  }
  await configureDependencies(supabaseConfig: supabaseConfig);
  runApp(const AgriGateApp());
}
