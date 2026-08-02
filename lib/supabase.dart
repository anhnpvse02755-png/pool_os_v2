import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Client Configuration
class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
