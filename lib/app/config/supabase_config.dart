class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  factory SupabaseConfig.fromEnvironment() {
    return const SupabaseConfig(
      url: String.fromEnvironment('SUPABASE_URL'),
      anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  final String url;
  final String anonKey;

  bool get isConfigured {
    final normalizedUrl = url.trim();
    final normalizedAnonKey = anonKey.trim();
    return normalizedUrl.isNotEmpty &&
        normalizedAnonKey.isNotEmpty &&
        !normalizedUrl.contains('your-project') &&
        !normalizedAnonKey.contains('your-anon-key');
  }
}