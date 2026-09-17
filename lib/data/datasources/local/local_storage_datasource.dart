import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/training_session.dart';

/// LocalStorage Data Source
/// Implements data persistence using SharedPreferences
class LocalStorageDataSource {
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyPlayer = 'player_data';
  static const String _keyPlayerInterests = 'player_interests';
  static const String _keyDrills = 'drills_data';
  static const String _keyDrillProgress = 'drill_progress';
  static const String _keyTrainingHistory = 'training_history';
  static const String _keyKnowledgeProgress = 'knowledge_progress';
  static const String _keyMatches = 'matches_data';
  static const String _keyTournaments = 'tournaments_data';
  static const String _keyNotifications = 'notifications_data';
  static const String _keyCommunityPosts = 'community_posts';
  static const String _keySettings = 'app_settings';
  static const String _keyEquipment = 'equipment_data';
  static const String _keyRecommendations = 'ai_recommendations';
  static const String _keyCoachingHistory = 'coaching_history';
  static const String _keyStreakInfo = 'streak_info';
  static const String _keyWarmupLog = 'warmup_log';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyFirstLaunch = 'first_launch_complete';
  static const String _keyDrillSessions = 'drill_sessions';

  /// Key for the one-time migration flag (drill_sessions -> training_history).
  static const String _keyMigratedDrillSessions =
      'poolos_v2.migrated_drill_sessions';

  /// Resets the migration flag. Only for test use.
  static Future<void> resetMigrationFlag() async {
    _migrated = false;
    if (_prefs != null) {
      await _prefs!.remove(_keyMigratedDrillSessions);
    }
  }

  static bool _migrated = false;

  /// Initialize the data source
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateDrillSessionsToTrainingHistory();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageDataSource not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==========================================================================
  // Generic Methods
  // ==========================================================================

  static Future<String?> getString(String key) async {
    return prefs.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    return prefs.getStringList(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  static Future<bool?> getBool(String key) async {
    return prefs.getBool(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static Future<int?> getInt(String key) async {
    return prefs.getInt(key);
  }

  static Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    final data = prefs.getString(key);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<List<Map<String, dynamic>>> getJsonList(String key) async {
    final data = prefs.getString(key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.cast<Map<String, dynamic>>();
  }

  static Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    await prefs.clear();
  }

  static Future<bool> containsKey(String key) async {
    return prefs.containsKey(key);
  }

  // ==========================================================================
  // App State
  // ==========================================================================

  static Future<bool> isFirstLaunch() async {
    return !(prefs.getBool(_keyFirstLaunch) ?? false);
  }

  static Future<void> markFirstLaunchComplete() async {
    await prefs.setBool(_keyFirstLaunch, true);
  }

  static Future<bool> isOnboardingCompleted() async {
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await prefs.setBool(_keyOnboardingCompleted, value);
  }

  // ==========================================================================
  // Player
  // ==========================================================================

  static Future<Map<String, dynamic>?> getPlayer() async {
    return getJson(_keyPlayer);
  }

  static Future<void> savePlayer(Map<String, dynamic> player) async {
    await setJson(_keyPlayer, player);
  }

  static Future<Map<String, dynamic>?> getPlayerInterests() async {
    return getJson(_keyPlayerInterests);
  }

  static Future<void> savePlayerInterests(Map<String, dynamic> interests) async {
    await setJson(_keyPlayerInterests, interests);
  }

  // ==========================================================================
  // Drills
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getDrills() async {
    return getJsonList(_keyDrills);
  }

  static Future<void> saveDrills(List<Map<String, dynamic>> drills) async {
    await setJsonList(_keyDrills, drills);
  }

  static Future<List<Map<String, dynamic>>> getDrillProgress() async {
    return getJsonList(_keyDrillProgress);
  }

  static Future<void> saveDrillProgress(List<Map<String, dynamic>> progress) async {
    await setJsonList(_keyDrillProgress, progress);
  }

  // ==========================================================================
  // Training History
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getTrainingHistory() async {
    return getJsonList(_keyTrainingHistory);
  }

  static Future<void> saveTrainingHistory(List<Map<String, dynamic>> history) async {
    await setJsonList(_keyTrainingHistory, history);
  }

  // ==========================================================================
  // Knowledge
  // ==========================================================================

  static Future<Map<String, dynamic>> getKnowledgeProgress() async {
    final data = await getJson(_keyKnowledgeProgress);
    return data ?? {};
  }

  static Future<void> saveKnowledgeProgress(Map<String, dynamic> progress) async {
    await setJson(_keyKnowledgeProgress, progress);
  }

  // ==========================================================================
  // Matches
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getMatches() async {
    return getJsonList(_keyMatches);
  }

  static Future<void> saveMatches(List<Map<String, dynamic>> matches) async {
    await setJsonList(_keyMatches, matches);
  }

  static Future<List<Map<String, dynamic>>> getTournaments() async {
    return getJsonList(_keyTournaments);
  }

  static Future<void> saveTournaments(List<Map<String, dynamic>> tournaments) async {
    await setJsonList(_keyTournaments, tournaments);
  }

  // ==========================================================================
  // Notifications
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    return getJsonList(_keyNotifications);
  }

  static Future<void> saveNotifications(List<Map<String, dynamic>> notifications) async {
    await setJsonList(_keyNotifications, notifications);
  }

  // ==========================================================================
  // Community
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getCommunityPosts() async {
    return getJsonList(_keyCommunityPosts);
  }

  static Future<void> saveCommunityPosts(List<Map<String, dynamic>> posts) async {
    await setJsonList(_keyCommunityPosts, posts);
  }

  // ==========================================================================
  // Settings
  // ==========================================================================

  static Future<Map<String, dynamic>> getSettings() async {
    final data = await getJson(_keySettings);
    return data ?? {
      'notificationsEnabled': true,
      'soundEnabled': true,
      'hapticEnabled': true,
      'language': 'vi',
      'theme': 'light',
      'showStreakReminder': true,
      'dailyGoalDrills': 2,
    };
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await setJson(_keySettings, settings);
  }

  // ==========================================================================
  // Equipment
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getEquipment() async {
    return getJsonList(_keyEquipment);
  }

  static Future<void> saveEquipment(List<Map<String, dynamic>> equipment) async {
    await setJsonList(_keyEquipment, equipment);
  }

  // ==========================================================================
  // AI Coach
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getRecommendations() async {
    return getJsonList(_keyRecommendations);
  }

  static Future<void> saveRecommendations(List<Map<String, dynamic>> recommendations) async {
    await setJsonList(_keyRecommendations, recommendations);
  }

  static Future<List<Map<String, dynamic>>> getCoachingHistory() async {
    return getJsonList(_keyCoachingHistory);
  }

  static Future<void> saveCoachingHistory(List<Map<String, dynamic>> history) async {
    await setJsonList(_keyCoachingHistory, history);
  }

  static Future<Map<String, dynamic>> getStreakInfo() async {
    final data = await getJson(_keyStreakInfo);
    return data ?? {
      'currentStreak': 0,
      'longestStreak': 0,
      'lastActivityDate': null,
    };
  }

  static Future<void> saveStreakInfo(Map<String, dynamic> info) async {
    await setJson(_keyStreakInfo, info);
  }

  // ==========================================================================
  // Warmup Log — Dac-Ta-Che-Do-Khoi-Dong.md
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getWarmupLogs() async {
    return getJsonList(_keyWarmupLog);
  }

  static Future<void> saveWarmupLogs(List<Map<String, dynamic>> logs) async {
    await setJsonList(_keyWarmupLog, logs);
  }

  // ==========================================================================
  // One-time Migration: drill_sessions -> training_history
  // ==========================================================================
  // Before this change, TrainingNotifier wrote to key 'drill_sessions' (via
  // LocalStorageService.saveDrillSession) while LocalDrillRepository.read
  // from 'training_history'.  saveTrainingSession had ZERO callers, so
  // training_history was always empty.
  //
  // This one-time migration reads existing 'drill_sessions' records (which
  // contain the OLD keys: shotsAttempted, date) and converts them to the
  // new format (shotsMissed, completedAt) using TrainingSession.fromJson
  // (which is already tolerant of old keys from Task 1).
  // Migration only runs once — guarded by a flag in SharedPreferences.
  // ==========================================================================

  /// Runs once: copies drill_sessions data into training_history if the latter
  /// is empty.  Safe to call on every init(); exits early if already done.
  static Future<void> _migrateDrillSessionsToTrainingHistory() async {
    if (_migrated) return;

    // Check flag (persisted so it survives app restarts within the same build).
    final already = prefs.getBool(_keyMigratedDrillSessions);
    if (already == true) {
      _migrated = true;
      return;
    }

    // Read old-format drill_sessions (written by old TrainingNotifier).
    final drillSessionsJson = prefs.getString(_keyDrillSessions);
    if (drillSessionsJson == null || drillSessionsJson.isEmpty) {
      // Nothing to migrate; mark done and exit.
      await prefs.setBool(_keyMigratedDrillSessions, true);
      _migrated = true;
      return;
    }

    // If training_history already has data, the user already has new-format
    // records — do NOT overwrite them.
    final existingHistory = await getTrainingHistory();
    if (existingHistory.isNotEmpty) {
      await prefs.setBool(_keyMigratedDrillSessions, true);
      _migrated = true;
      return;
    }

    // Decode old-format sessions and convert to new format.
    final List<dynamic> oldList = jsonDecode(drillSessionsJson);
    final migrated = <Map<String, dynamic>>[];
    for (final raw in oldList) {
      // TrainingSession.fromJson handles both old keys (shotsAttempted, date)
      // and new keys (shotsMissed, completedAt).
      final session = TrainingSession.fromJson(raw as Map<String, dynamic>);
      migrated.add(session.toJson());
    }

    await saveTrainingHistory(migrated);
    await prefs.setBool(_keyMigratedDrillSessions, true);
    _migrated = true;
  }

  // ==========================================================================
  // ==========================================================================
  // Wipe All Local Data — DEVELOPER RESET ONLY
  // ==========================================================================
  //
  // Renamed from `clearAllData` on Day 1.2 (STAB-002) so the destructive
  // intent is unmistakable. NEVER call this from cold start. Call sites
  // are restricted to:
  //   * Developer-only entry points (long-press reset, debug menu).
  //   * `main.dart::forceResetAllLocalData` (visibleForTesting only).
  //   * Schema migrations that *explicitly* decide to discard (must be
  //     commented with reason + ticket).
  //
  // Wiping is intentionally not exported via any Riverpod provider.
  // ==========================================================================

  static Future<void> wipeAllLocalData() async {
    await prefs.remove(_keyPlayer);
    await prefs.remove(_keyPlayerInterests);
    await prefs.remove(_keyDrillProgress);
    await prefs.remove(_keyTrainingHistory);
    await prefs.remove(_keyKnowledgeProgress);
    await prefs.remove(_keyMatches);
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyCommunityPosts);
    await prefs.remove(_keyEquipment);
    await prefs.remove(_keyRecommendations);
    await prefs.remove(_keyCoachingHistory);
    await prefs.remove(_keyStreakInfo);
    await prefs.remove(_keyOnboardingCompleted);
  }
}
