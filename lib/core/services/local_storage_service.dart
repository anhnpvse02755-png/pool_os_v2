// ============================================================================
// LOCAL STORAGE SERVICE
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static const String _keyDrillSessions = 'drill_sessions';
  static const String _keyMatchRecords = 'match_records';
  static const String _keyUserProfile = 'user_profile';
  static const String _keySettings = 'settings';
  static const String _keyKnowledgeProgress = 'knowledge_progress';

  // Initialize
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==========================================================================
  // DRILL SESSIONS
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getDrillSessions() async {
    final data = prefs.getString(_keyDrillSessions);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.cast<Map<String, dynamic>>();
  }

  static Future<void> saveDrillSession(Map<String, dynamic> session) async {
    final sessions = await getDrillSessions();
    sessions.insert(0, session);
    await prefs.setString(_keyDrillSessions, jsonEncode(sessions));
  }

  static Future<void> updateDrillSession(String id, Map<String, dynamic> session) async {
    final sessions = await getDrillSessions();
    final index = sessions.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      sessions[index] = session;
      await prefs.setString(_keyDrillSessions, jsonEncode(sessions));
    }
  }

  static Future<void> deleteDrillSession(String id) async {
    final sessions = await getDrillSessions();
    sessions.removeWhere((s) => s['id'] == id);
    await prefs.setString(_keyDrillSessions, jsonEncode(sessions));
  }

  // ==========================================================================
  // MATCH RECORDS
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getMatchRecords() async {
    final data = prefs.getString(_keyMatchRecords);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.cast<Map<String, dynamic>>();
  }

  static Future<void> saveMatchRecord(Map<String, dynamic> match) async {
    final matches = await getMatchRecords();
    matches.insert(0, match);
    await prefs.setString(_keyMatchRecords, jsonEncode(matches));
  }

  static Future<void> updateMatchRecord(String id, Map<String, dynamic> match) async {
    final matches = await getMatchRecords();
    final index = matches.indexWhere((m) => m['id'] == id);
    if (index != -1) {
      matches[index] = match;
      await prefs.setString(_keyMatchRecords, jsonEncode(matches));
    }
  }

  static Future<void> deleteMatchRecord(String id) async {
    final matches = await getMatchRecords();
    matches.removeWhere((m) => m['id'] == id);
    await prefs.setString(_keyMatchRecords, jsonEncode(matches));
  }

  // ==========================================================================
  // USER PROFILE
  // ==========================================================================

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final data = prefs.getString(_keyUserProfile);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await prefs.setString(_keyUserProfile, jsonEncode(profile));
  }

  // ==========================================================================
  // SETTINGS
  // ==========================================================================

  static Future<Map<String, dynamic>> getSettings() async {
    final data = prefs.getString(_keySettings);
    if (data == null) {
      return {
        'notifications': true,
        'soundEffects': true,
        'hapticFeedback': true,
        'language': 'vi',
        'theme': 'light',
      };
    }
    return jsonDecode(data);
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await prefs.setString(_keySettings, jsonEncode(settings));
  }

  // ==========================================================================
  // KNOWLEDGE PROGRESS
  // ==========================================================================

  static Future<Map<String, dynamic>> getKnowledgeProgress() async {
    final data = prefs.getString(_keyKnowledgeProgress);
    if (data == null) return {};
    return jsonDecode(data);
  }

  static Future<void> saveKnowledgeProgress(String knowledgeId, Map<String, dynamic> progress) async {
    final allProgress = await getKnowledgeProgress();
    allProgress[knowledgeId] = progress;
    await prefs.setString(_keyKnowledgeProgress, jsonEncode(allProgress));
  }

  static Future<void> markKnowledgeAsRead(String knowledgeId) async {
    final progress = await getKnowledgeProgress();
    progress[knowledgeId] = {
      'read': true,
      'readAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_keyKnowledgeProgress, jsonEncode(progress));
  }

  // ==========================================================================
  // STATS
  // ==========================================================================

  static Future<Map<String, dynamic>> getStats() async {
    final sessions = await getDrillSessions();
    final matches = await getMatchRecords();

    // Calculate stats
    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + (s['duration'] as int? ?? 0));
    final totalShots = sessions.fold<int>(0, (sum, s) => sum + (s['shotsMade'] as int? ?? 0));

    final totalMatches = matches.length;
    final wins = matches.where((m) => m['result'] == 'win').length;
    final winRate = totalMatches > 0 ? (wins / totalMatches * 100).round() : 0;

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'totalShots': totalShots,
      'totalMatches': totalMatches,
      'wins': wins,
      'winRate': winRate,
    };
  }

  // Note: a `clearAllData()` method was removed on Day 1.2 (STAB-002).
  // Wiping local data is intentionally not exposed on the V2 storage layer.
  // See `LocalStorageDataSource.wipeAllLocalData` for the documented
  // developer-only entry point.
}
