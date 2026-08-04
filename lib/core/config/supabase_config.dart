// ============================================================================
// Supabase Configuration — Single Source of Truth
// ============================================================================
//
// All Supabase credentials MUST be supplied via `--dart-define` at build /
// run time. No fallback values, no placeholders, no hardcoded secrets.
//
// Usage:
//   flutter run --dart-define=SUPABASE_URL=https://x.supabase.co \
//               --dart-define=SUPABASE_ANON_KEY=eyJ...
//
// In CI / release builds, missing env vars will cause
// [isConfigured] to return `false`. The app then runs in **offline mode**
// (see [initialize]) — no network calls, no Supabase auth, no remote sync.
// A red "offline-only" banner is shown on the home screen so users know.
//
// History:
//   Day 1.2 — replaced 3 duplicate config files (lib/supabase.dart,
//   lib/core/constants/supabase_config.dart) with this single source.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// Read at compile time from --dart-define=SUPABASE_URL=...
  /// Empty string by default so the build never embeds a real URL.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Read at compile time from --dart-define=SUPABASE_ANON_KEY=...
  /// Empty string by default so the build never embeds a real key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// True iff both URL and anon key were supplied at build time.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// True iff [initialize] succeeded. Distinct from [isConfigured] because
  /// initialization can also fail at runtime (network, schema mismatch).
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initializes Supabase if env vars are present. Otherwise no-op —
  /// the app falls back to fully offline mode.
  ///
  /// Idempotent: safe to call from `main()` even if called elsewhere.
  static Future<void> initialize() async {
    if (_initialized) return;
    if (!isConfigured) {
      // Don't throw — keep the app usable offline.
      // In debug builds, surface a single loud warning so devs notice.
      if (kDebugMode) {
        debugPrint(
          '[SupabaseConfig] SUPABASE_URL or SUPABASE_ANON_KEY not set; '
          'running in offline mode. Pass via --dart-define=SUPABASE_URL=... '
          '--dart-define=SUPABASE_ANON_KEY=...',
        );
      }
      return;
    }
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _initialized = true;
    } catch (e, st) {
      // Don't crash the app on transient init failure. Log + stay offline.
      if (kDebugMode) {
        debugPrint('[SupabaseConfig] init failed: $e\n$st');
      }
    }
  }

  /// Access the client. Throws if Supabase was never initialized
  /// (i.e. running in offline mode without env vars). Callers MUST check
  /// [isInitialized] first; otherwise fall back to local repositories.
  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase not initialized. '
        'Pass --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... '
        'at build time, or guard with SupabaseConfig.isInitialized.',
      );
    }
    return Supabase.instance.client;
  }
}