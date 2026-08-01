// Supabase Configuration
// Get these from: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api

class SupabaseConfig {
  // Replace with your actual Supabase project URL
  // Found in: Settings > API > Project URL
  static const String supabaseUrl = 'https://your-project-id.supabase.co';

  // Replace with your actual Supabase anon key
  // Found in: Settings > API > Project API keys > anon public
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

  // For local development, use these:
  // static const String supabaseUrl = 'http://localhost:54321';
  // static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
