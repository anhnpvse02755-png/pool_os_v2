import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/datasources/local/local_storage_datasource.dart';

// ============================================================================
// Schema Versioning
// ============================================================================
// Bump [currentSchemaVersion] ONLY when the on-disk layout of any key in
// [LocalStorageDataSource] changes. On every cold start we read the
// persisted [_schemaVersionKey] (default = 0 = "never written"), and:
//
//   1. If equal to [currentSchemaVersion] → no migration needed.
//   2. If less → run [migrate] to upgrade the on-disk shape.
//   3. Reset (wipe) is NEVER automatic. It must be a deliberate developer
//      action via [forceResetAllLocalData].
//
// This file intentionally keeps migration logic tiny and traceable. Adding
// real migration steps should be done in named functions and gated by the
// persisted schema version.
//
// Day 1.2 (STAB-002): replaced the cold-start `clearAllData()` call that
// wiped returning users' state on every launch.
// ============================================================================

const int currentSchemaVersion = 1;
const String _schemaVersionKey = 'poolos_v2.schema_version';

Future<void> _migrate(SharedPreferences prefs, int fromVersion) async {
  // v0 → v1: initial schema. No data shape changes yet — schema-version key
  // itself is being introduced. Persist the new version.
  // Future migrations would go here as additional `if (fromVersion < N)` blocks.
  if (fromVersion < 1) {
    // No-op for v0 → v1; we only added the version stamp itself.
  }
  await prefs.setInt(_schemaVersionKey, currentSchemaVersion);
}

/// Explicit developer reset. NOT called from cold-start; safe to remove.
/// Lives in `main.dart` so it's discoverable but never auto-invoked.
@visibleForTesting
Future<void> forceResetAllLocalData() async {
  await LocalStorageDataSource.wipeAllLocalData();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Bring up local storage.
  await LocalStorageDataSource.init();

  // 2. Schema migration — never wipes automatically.
  final prefs = await SharedPreferences.getInstance();
  final persistedVersion = prefs.getInt(_schemaVersionKey) ?? 0;
  if (persistedVersion < currentSchemaVersion) {
    await _migrate(prefs, persistedVersion);
  }

  // 3. Optional: Supabase (no-op if env vars missing — app stays offline).
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: PoolOSApp()));
}

class PoolOSApp extends ConsumerWidget {
  const PoolOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PoolOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}