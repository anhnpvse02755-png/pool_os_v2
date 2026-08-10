// ============================================================================
// SESSION MEMORY SERVICE - Phase 7B.3 / 7.x
// Coach remembers sessions and recommends continuation
//
// Coach remembers:
// - What drill was being practiced
// - Progress reached
// - Last session date
// - Recommended drill
//
// Persistence: Uses SharedPreferences for local storage
// ============================================================================

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sessionMemoryKey = 'coach_session_memory';

/// Session Memory - Stores interrupted session info
class SessionMemory {
  final String? activeDrillCode;
  final String? activeDrillName;
  final int? progress;
  final int? lastScore;
  final DateTime? lastSessionDate;
  final String? recommendedDrillCode;
  final String? recommendedDrillName;
  final DateTime? recommendedDate;

  SessionMemory({
    this.activeDrillCode,
    this.activeDrillName,
    this.progress,
    this.lastScore,
    this.lastSessionDate,
    this.recommendedDrillCode,
    this.recommendedDrillName,
    this.recommendedDate,
  });

  bool get hasInterruptedSession =>
      activeDrillCode != null &&
      progress != null &&
      progress! < 100 &&
      _daysSinceLastSession() <= 7;

  bool get hasRecommendation =>
      recommendedDrillCode != null &&
      recommendedDrillName != null &&
      recommendedDate != null &&
      _daysSinceRecommendation() <= 3;

  int _daysSinceLastSession() {
    if (lastSessionDate == null) return 100;
    return DateTime.now().difference(lastSessionDate!).inDays;
  }

  int _daysSinceRecommendation() {
    if (recommendedDate == null) return 100;
    return DateTime.now().difference(recommendedDate!).inDays;
  }

  Map<String, dynamic> toJson() => {
        'activeDrillCode': activeDrillCode,
        'activeDrillName': activeDrillName,
        'progress': progress,
        'lastScore': lastScore,
        'lastSessionDate': lastSessionDate?.toIso8601String(),
        'recommendedDrillCode': recommendedDrillCode,
        'recommendedDrillName': recommendedDrillName,
        'recommendedDate': recommendedDate?.toIso8601String(),
      };

  factory SessionMemory.fromJson(Map<String, dynamic> json) => SessionMemory(
        activeDrillCode: json['activeDrillCode'],
        activeDrillName: json['activeDrillName'],
        progress: json['progress'],
        lastScore: json['lastScore'],
        lastSessionDate: json['lastSessionDate'] != null
            ? DateTime.parse(json['lastSessionDate'])
            : null,
        recommendedDrillCode: json['recommendedDrillCode'],
        recommendedDrillName: json['recommendedDrillName'],
        recommendedDate: json['recommendedDate'] != null
            ? DateTime.parse(json['recommendedDate'])
            : null,
      );
}

/// Session Memory Service
class SessionMemoryService {
  SessionMemory? _memory;

  SessionMemory get memory => _memory ?? SessionMemory();

  /// Load session memory from SharedPreferences
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_sessionMemoryKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _memory = SessionMemory.fromJson(json);
      } else {
        _memory = SessionMemory();
      }
    } catch (e) {
      _memory = SessionMemory();
    }
  }

  /// Save session memory to SharedPreferences
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_memory?.toJson() ?? {});
      await prefs.setString(_sessionMemoryKey, jsonString);
    } catch (e) {
      // Silently fail - session memory is not critical
    }
  }

  /// Start a new session
  void startSession({
    required String drillCode,
    required String drillName,
  }) {
    _memory = SessionMemory(
      activeDrillCode: drillCode,
      activeDrillName: drillName,
      progress: 0,
      lastSessionDate: DateTime.now(),
    );
    save();
  }

  /// Update session progress
  void updateProgress(int progress, int? score) {
    if (_memory == null) return;
    _memory = SessionMemory(
      activeDrillCode: _memory!.activeDrillCode,
      activeDrillName: _memory!.activeDrillName,
      progress: progress,
      lastScore: score ?? _memory!.lastScore,
      lastSessionDate: DateTime.now(),
      recommendedDrillCode: _memory!.recommendedDrillCode,
      recommendedDrillName: _memory!.recommendedDrillName,
      recommendedDate: _memory!.recommendedDate,
    );
    save();
  }

  /// Complete session
  void completeSession(int score) {
    if (_memory == null) return;
    _memory = SessionMemory(
      activeDrillCode: null,
      activeDrillName: null,
      progress: 100,
      lastScore: score,
      lastSessionDate: DateTime.now(),
      recommendedDrillCode: _memory!.recommendedDrillCode,
      recommendedDrillName: _memory!.recommendedDrillName,
      recommendedDate: _memory!.recommendedDate,
    );
    save();
  }

  /// Clear active session (without completing)
  void pauseSession(int progress, int? score) {
    if (_memory == null) return;
    _memory = SessionMemory(
      activeDrillCode: _memory!.activeDrillCode,
      activeDrillName: _memory!.activeDrillName,
      progress: progress,
      lastScore: score ?? _memory!.lastScore,
      lastSessionDate: DateTime.now(),
      recommendedDrillCode: _memory!.recommendedDrillCode,
      recommendedDrillName: _memory!.recommendedDrillName,
      recommendedDate: _memory!.recommendedDate,
    );
    save();
  }

  /// Set recommendation
  void setRecommendation({
    required String drillCode,
    required String drillName,
  }) {
    _memory = SessionMemory(
      activeDrillCode: _memory?.activeDrillCode,
      activeDrillName: _memory?.activeDrillName,
      progress: _memory?.progress,
      lastScore: _memory?.lastScore,
      lastSessionDate: _memory?.lastSessionDate,
      recommendedDrillCode: drillCode,
      recommendedDrillName: drillName,
      recommendedDate: DateTime.now(),
    );
    save();
  }

  /// Check if user should be asked to continue session
  bool shouldAskContinue() {
    return memory.hasInterruptedSession;
  }

  /// Check if user should see recommendation
  bool shouldShowRecommendation() {
    return memory.hasRecommendation;
  }

  /// Get continue session message
  String getContinueSessionMessage() {
    final mem = memory;
    if (!mem.hasInterruptedSession) return '';

    final days = mem.lastSessionDate != null
        ? DateTime.now().difference(mem.lastSessionDate!).inDays
        : 0;

    String timeAgo;
    if (days == 0) {
      timeAgo = 'hôm nay';
    } else if (days == 1) {
      timeAgo = 'hôm qua';
    } else {
      timeAgo = '$days ngày trước';
    }

    return 'Còn dở ${mem.activeDrillName} đấy ($timeAgo). '
        'Tiếp tục nhé?';
  }

  /// Get recommendation message
  String getRecommendationMessage() {
    final mem = memory;
    if (!mem.hasRecommendation) return '';

    return 'Mình đã khuyên ${mem.recommendedDrillName} '
        '${_formatDaysAgo(mem.recommendedDate)}.';
  }

  String _formatDaysAgo(DateTime? date) {
    if (date == null) return '';
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'hôm nay';
    if (days == 1) return 'hôm qua';
    return '$days ngày trước';
  }
}

// Provider
final sessionMemoryProvider = Provider<SessionMemoryService>((ref) {
  return SessionMemoryService();
});
