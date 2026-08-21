import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/player_repository.dart' as player_repo;
import '../../data/repositories/drill_repository.dart' as drill_repo;
import '../../data/repositories/knowledge_repository.dart' as knowledge_repo;
import '../../data/repositories/match_repository.dart' as match_repo;
import '../../data/repositories/notification_repository.dart' as notification_repo;
import '../../data/repositories/community_repository.dart' as community_repo;
import '../../data/repositories/settings_repository.dart' as settings_repo;
import '../../data/repositories/cache_repository.dart' as cache_repo;
import '../../data/repositories/drill_session_repository.dart';
import '../../domain/services/drill_library_service.dart' as drill_lib;
import '../../domain/services/knowledge_graph_service.dart' as kg_svc;
import '../../domain/services/learning_streak_service.dart' as ls_svc;
import '../../domain/services/quiz_service.dart' as quiz_svc;
import '../../domain/services/spaced_repetition_service.dart' as sr_svc;
import '../../data/repositories/ai_coach_repository.dart' as ai_repo;
import '../../data/repositories/equipment_repository.dart' as equipment_repo;
import '../services/daily_notification_service.dart';
import '../../data/models/player.dart';
import '../../data/models/player_interests.dart';
import '../../data/models/drill_progress.dart';
import '../../data/models/training_session.dart';
import '../../data/models/match.dart';
import '../../data/models/match_aggregates.dart'; // Sprint-11: Typed MatchStats
import '../../data/models/equipment.dart';
import '../../data/impl/local_player_repository.dart';
import '../../data/impl/local_drill_repository.dart';
import '../../data/impl/local_knowledge_repository.dart';
import '../../data/impl/local_notification_repository.dart';
import '../../data/impl/local_community_repository.dart';
import '../../data/impl/local_settings_repository.dart';
import '../../data/impl/local_ai_coach_repository.dart';
import '../../data/impl/local_equipment_repository.dart';

// ============================================================================
// Repository Providers
// ============================================================================

final playerRepositoryProvider = Provider<player_repo.PlayerRepository>((ref) {
  return LocalPlayerRepository();
});

final drillRepositoryProvider = Provider<drill_repo.DrillRepository>((ref) {
  return LocalDrillRepository();
});

final drillSessionRepositoryProvider = Provider<IDrillSessionRepository>((ref) {
  return LocalDrillSessionRepository();
});

final knowledgeRepositoryProvider = Provider<knowledge_repo.KnowledgeRepository>((ref) {
  return LocalKnowledgeRepository();
});

final matchRepositoryProvider = Provider<match_repo.IMatchRepository>((ref) {
  return match_repo.LocalMatchRepository();
});

final notificationRepositoryProvider = Provider<notification_repo.NotificationRepository>((ref) {
  return LocalNotificationRepository();
});

final communityRepositoryProvider = Provider<community_repo.CommunityRepository>((ref) {
  return LocalCommunityRepository();
});

final settingsRepositoryProvider = Provider<settings_repo.SettingsRepository>((ref) {
  return LocalSettingsRepository();
});

final aiCoachRepositoryProvider = Provider<ai_repo.AICoachRepository>((ref) {
  return LocalAICoachRepository();
});

final equipmentRepositoryProvider = Provider<equipment_repo.EquipmentRepository>((ref) {
  return LocalEquipmentRepository();
});

// ============================================================================
// Player Providers (using repository)
// ============================================================================

final currentPlayerProvider = FutureProvider<Player?>((ref) async {
  final repository = ref.watch(playerRepositoryProvider);
  return repository.getCurrentPlayer();
});

final playerInterestsProvider = FutureProvider<PlayerInterests?>((ref) async {
  final player = await ref.watch(currentPlayerProvider.future);
  if (player == null) return null;
  final repository = ref.watch(playerRepositoryProvider);
  return repository.getPlayerInterests(player.id);
});

final isOnboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(playerRepositoryProvider);
  return repository.isOnboardingCompleted();
});

// ============================================================================
// Drill Providers (using repository)
// ============================================================================

final allDrillsProvider = FutureProvider<List<drill_repo.DrillInfo>>((ref) async {
  final repository = ref.watch(drillRepositoryProvider);
  return repository.getAllDrills();
});

final drillCategoriesProvider = FutureProvider<List<drill_repo.DrillCategory>>((ref) async {
  final repository = ref.watch(drillRepositoryProvider);
  return repository.getCategories();
});

final drillProgressProvider = FutureProvider<List<DrillProgress>>((ref) async {
  final repository = ref.watch(drillRepositoryProvider);
  return repository.getUserProgress();
});

final trainingHistoryProvider = FutureProvider<List<TrainingSession>>((ref) async {
  final repository = ref.watch(drillRepositoryProvider);
  return repository.getTrainingHistory(limit: 20);
});

final recommendedDrillsProvider = FutureProvider<List<drill_repo.DrillInfo>>((ref) async {
  final repository = ref.watch(drillRepositoryProvider);
  return repository.getRecommendedDrills();
});

// ============================================================================
// Knowledge Providers (using repository)
// ============================================================================

final knowledgeArticlesProvider = FutureProvider<List<knowledge_repo.KnowledgeArticle>>((ref) async {
  final repository = ref.watch(knowledgeRepositoryProvider);
  return repository.getAllArticles();
});

final knowledgeCategoriesProvider = FutureProvider<List<knowledge_repo.KnowledgeCategory>>((ref) async {
  final repository = ref.watch(knowledgeRepositoryProvider);
  return repository.getCategories();
});

final knowledgeProgressProvider = FutureProvider<Map<String, knowledge_repo.ReadingProgress>>((ref) async {
  final repository = ref.watch(knowledgeRepositoryProvider);
  return repository.getReadingProgress();
});

// ============================================================================
// Match Providers (using repository)
// ============================================================================

final matchHistoryProvider = FutureProvider<List<Match>>((ref) async {
  // TODO(phase-D): implement getRecentMatches(limit) on IMatchRepository;
  // for now fall back to getAllMatches() and let the screen sort/limit.
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getAllMatches();
});

// Aggregates return raw map from repository; screen decodes keys.
// Sprint-11: Typed MatchStats model created
final matchStatsProvider = FutureProvider<MatchStats>((ref) async {
  final repository = ref.watch(matchRepositoryProvider);
  final map = await repository.getPlayerAggregates('current');
  return MatchStats.fromMap(map);
});

// ============================================================================
// ⚠️ TEMPORARY COMPATIBILITY STUB (added Day 1.1)
// ============================================================================
// TournamentRepository was removed during the V1→V2 refactor but
// `tournamentsProvider` and `upcomingTournamentsProvider` are still
// consumed by TournamentListScreen / TournamentDetailScreen.
//
// We do NOT have a tournament repository yet in V2 — the V1 schema had
// tournaments as a Match field. Returning an empty list lets screens render
// their empty-state branch and unblocks `flutter analyze`.
//
// AUDIT REQUIRED in a follow-up sprint:
//   1. Re-introduce TournamentRepository (interface + local impl).
//   2. Wire Supabase impl once Phase D storage is ready.
//   3. Decide whether tournaments are a first-class entity or a Match
//      sub-resource in V2 (currently neither).
//
// Tracked as: STAB-029 (post-Sprint audit), Phase D backlog item.
// ============================================================================
final tournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  return <Tournament>[];
});

final upcomingTournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  return <Tournament>[];
});

// ============================================================================
// Cache Repository (Day 2A — Repository Dependency Enforcement)
// ============================================================================
//
// Domain services that need to cache parsed assets (drills, knowledge, etc.)
// MUST go through this provider, not import LocalStorageService directly.
//
// Tracked as: STAB-031 (P0 arch bypass closure).
// ============================================================================
final cacheRepositoryProvider = Provider<cache_repo.ICacheRepository>((ref) {
  return cache_repo.LocalCacheRepository();
});

// Service providers — Day 2A.
// Each service is constructed via the cache provider, so that no
// consumer ever instantiates the service directly with `new XxxService()`.
final drillLibraryServiceProvider = Provider<drill_lib.DrillLibraryService>((ref) {
  return drill_lib.DrillLibraryService(ref.watch(cacheRepositoryProvider));
});
final knowledgeGraphServiceProvider = Provider<kg_svc.KnowledgeGraphService>((ref) {
  return kg_svc.KnowledgeGraphService(ref.watch(cacheRepositoryProvider));
});
final learningStreakServiceProvider = Provider<ls_svc.LearningStreakService>((ref) {
  return ls_svc.LearningStreakService(ref.watch(cacheRepositoryProvider));
});

final dailyNotificationServiceProvider = Provider<DailyNotificationService>((ref) {
  final service = DailyNotificationService(ref.watch(cacheRepositoryProvider));
  // Use platform scheduler in production
  service.scheduler = PlatformNotificationScheduler();
  return service;
});

final quizServiceProvider = Provider<quiz_svc.QuizService>((ref) {
  return quiz_svc.QuizService(ref.watch(cacheRepositoryProvider));
});
final spacedRepetitionServiceProvider = Provider<sr_svc.SpacedRepetitionService>((ref) {
  return sr_svc.SpacedRepetitionService(ref.watch(cacheRepositoryProvider));
});

// ============================================================================
// Notification Providers (using repository)
// ============================================================================

final notificationsProvider = FutureProvider<List<notification_repo.AppNotification>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getAllNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});

// ============================================================================
// Community Providers (using repository)
// ============================================================================

final communityPostsProvider = FutureProvider<List<community_repo.CommunityPost>>((ref) async {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getAllPosts(limit: 20);
});

// ============================================================================
// Settings Providers (using repository)
// ============================================================================

final settingsProvider = FutureProvider<settings_repo.AppSettings>((ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettings();
});

// ============================================================================
// AI Coach Providers (using repository)
// ============================================================================

final aiRecommendationsProvider = FutureProvider<List<ai_repo.AIRecommendation>>((ref) async {
  final repository = ref.watch(aiCoachRepositoryProvider);
  return repository.getRecommendations();
});

final streakInfoProvider = FutureProvider<ai_repo.StreakInfo>((ref) async {
  final repository = ref.watch(aiCoachRepositoryProvider);
  return repository.getStreakInfo();
});

final weeklyAnalysisProvider = FutureProvider<ai_repo.WeeklyAnalysis?>((ref) async {
  final repository = ref.watch(aiCoachRepositoryProvider);
  return repository.getWeeklyAnalysis();
});

// ============================================================================
// Equipment Providers (using repository)
// ============================================================================

final allEquipmentProvider = FutureProvider<List<Equipment>>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getAllEquipment();
});

final activeCueProvider = FutureProvider<Equipment?>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getActiveCueByType('playing');
});

final activeBreakCueProvider = FutureProvider<Equipment?>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getActiveCueByType('break');
});

final activeJumpCueProvider = FutureProvider<Equipment?>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getActiveCueByType('jump');
});

final recommendedCuesProvider = FutureProvider<List<Equipment>>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getRecommendedEquipment();
});

final totalEquipmentValueProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getTotalEquipmentValue();
});

final equipmentStatsProvider =
    FutureProvider.family<EquipmentStats, String>((ref, cueId) async {
  final repository = ref.watch(equipmentRepositoryProvider);
  return repository.getStatsForCue(cueId);
});

// ============================================================================
// Theme Provider (localization + theme)
// ============================================================================

/// Theme mode notifier - persists to SharedPreferences
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'poolos_v2.theme';
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _prefs.getString(_key);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.light,
      );
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

/// Locale notifier - persists language preference
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _key = 'poolos_v2.locale';
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(const Locale('vi')) {
    _loadLocale();
  }

  void _loadLocale() {
    final saved = _prefs.getString(_key);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_key, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'vi'
        ? const Locale('en')
        : const Locale('vi');
    await setLocale(newLocale);
  }

  bool get isVietnamese => state.languageCode == 'vi';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});
