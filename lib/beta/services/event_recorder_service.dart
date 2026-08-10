// ============================================================================
// Event Recorder Service — Phase B.1
// Records all events for Black Box with 100% replayability
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/black_box_event.dart';
import '../models/black_box_replay_event.dart';

/// Records events with cause chain for 100% replayability
class EventRecorderService {
  static const String _storageKey = 'black_box_events';
  static const int _maxEvents = 10000;
  static const int _maxStorageBytes = 2 * 1024 * 1024; // 2 MB

  final List<BlackBoxReplayEvent> _events = [];
  DateTime? _sessionStart;
  bool _isRecording = false;

  /// Start a new recording session
  void startSession() {
    _events.clear();
    _sessionStart = DateTime.now();
    _isRecording = true;

    // Log app open
    if (_sessionStart != null) {
      _addEvent(BlackBoxReplayEvent.appOpen(_sessionStart!));
    }
  }

  /// End the current session
  void endSession() {
    if (!_isRecording || _sessionStart == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_sessionStart!).inSeconds;

    _addEvent(BlackBoxReplayEvent.appClose(now, elapsed, {
      'totalDuration': elapsed,
    }));

    _isRecording = false;
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Get elapsed time since session start
  int get elapsedSeconds {
    if (_sessionStart == null) return 0;
    return DateTime.now().difference(_sessionStart!).inSeconds;
  }

  /// Record a recommendation shown event
  void recordRecommendationShown({
    required String recommendationId,
    required String drillCode,
    required String drillName,
    required int priority,
    required String reason,
    Map<String, dynamic>? previousPriority,
  }) {
    final stateBefore = previousPriority != null
        ? {'current_priority': previousPriority}
        : {'current_priority': null};

    final stateAfter = {
      'current_priority': {
        'drill': drillName,
        'score': priority,
        'recommendationId': recommendationId,
      }
    };

    _addEvent(BlackBoxReplayEvent.recommendationShown(
      time: DateTime.now(),
      elapsed: elapsedSeconds,
      recommendationId: recommendationId,
      drillCode: drillCode,
      drillName: drillName,
      priority: priority,
      reason: reason,
      stateBefore: stateBefore,
      stateAfter: stateAfter,
    ));
  }

  /// Record user starting a drill
  void recordDrillStart({
    required String drillCode,
    required String drillName,
    String? source,
    String? recommendationId,
  }) {
    final stateBefore = {
      'session_active': false,
      'recommendation_status': recommendationId != null ? 'shown' : null,
    };

    final stateAfter = {
      'session_active': true,
      'current_drill': drillCode,
      'recommendation_status': recommendationId != null ? 'accepted' : null,
      if (recommendationId != null) 'recommendationId': recommendationId,
    };

    _addEvent(BlackBoxReplayEvent.startDrill(
      time: DateTime.now(),
      elapsed: elapsedSeconds,
      drillCode: drillCode,
      drillName: drillName,
      source: source,
      recommendationId: recommendationId,
      stateBefore: stateBefore,
      stateAfter: stateAfter,
    ));
  }

  /// Record drill completion
  void recordDrillCompleted({
    required String drillCode,
    required String drillName,
    required int score,
    required int shotsAttempted,
    required int shotsMade,
    required int durationSeconds,
    String? recommendationId,
    int? previousSkillScore,
    int? newSkillScore,
  }) {
    final stateBefore = {
      'session_active': true,
      'drill_score': null,
      if (previousSkillScore != null) 'skill_score': previousSkillScore,
    };

    final stateAfter = {
      'session_active': false,
      'drill_score': score,
      if (newSkillScore != null) 'skill_score': newSkillScore,
      if (previousSkillScore != null && newSkillScore != null)
        'improvement': '${newSkillScore - previousSkillScore}%',
      if (recommendationId != null) 'recommendation_status': 'completed',
      if (recommendationId != null) 'recommendationId': recommendationId,
    };

    _addEvent(BlackBoxReplayEvent.drillCompleted(
      time: DateTime.now(),
      elapsed: elapsedSeconds,
      drillCode: drillCode,
      drillName: drillName,
      score: score,
      shotsAttempted: shotsAttempted,
      shotsMade: shotsMade,
      durationSeconds: durationSeconds,
      recommendationId: recommendationId,
      stateBefore: stateBefore,
      stateAfter: stateAfter,
    ));
  }

  /// Record drill abandonment
  void recordDrillAbandoned({
    required String drillCode,
    required String drillName,
    required int progress,
    String? recommendationId,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.drillAbandoned,
      data: {
        'drill': drillName,
        'drillCode': drillCode,
        'progress': progress,
        if (recommendationId != null) 'recommendationId': recommendationId,
      },
      cause: EventCause(
        type: EventCauseType.userAction,
        trigger: 'user_exit',
      ),
      stateBefore: {
        'session_active': true,
        'current_drill': drillCode,
      },
      stateAfter: {
        'session_active': false,
        'interrupted_drill': drillCode,
        'interrupted_progress': progress,
      },
    ));
  }

  /// Record Coach Chat opened
  void recordCoachChatOpen({String? conversationId}) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.coachChatOpen,
      data: {
        if (conversationId != null) 'conversationId': conversationId,
      },
      stateBefore: {'screen': 'coach_home'},
      stateAfter: {
        'screen': 'coach_chat',
        if (conversationId != null) 'conversationId': conversationId,
      },
    ));
  }

  /// Record Coach Chat closed
  void recordCoachChatClose({
    required String conversationId,
    required int messagesCount,
    required int durationSeconds,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.coachChatClose,
      data: {
        'conversationId': conversationId,
        'messagesCount': messagesCount,
        'duration': durationSeconds,
      },
      stateBefore: {'screen': 'coach_chat'},
      stateAfter: {'screen': 'coach_home'},
    ));
  }

  /// Record user message sent
  void recordCoachMessageSent({
    required String conversationId,
    required String message,
    required String intent,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.coachMessageSent,
      data: {
        'conversationId': conversationId,
        'message': message,
        'intent': intent,
      },
    ));
  }

  /// Record Coach response received
  void recordCoachResponseReceived({
    required String conversationId,
    required String response,
    required String intent,
    String? recommendationId,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.coachResponseReceived,
      data: {
        'conversationId': conversationId,
        'message': response,
        'intent': intent,
        if (recommendationId != null) 'recommendationId': recommendationId,
      },
      cause: EventCause(
        type: EventCauseType.coachService,
        intent: intent,
        recommendationId: recommendationId,
      ),
    ));
  }

  /// Record recommendation accepted
  void recordRecommendationAccepted({
    required String recommendationId,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.recommendationAccepted,
      data: {
        'recommendationId': recommendationId,
      },
      cause: EventCause(
        type: EventCauseType.userAction,
        trigger: 'recommendation_accepted',
      ),
    ));
  }

  /// Record recommendation ignored
  void recordRecommendationIgnored({
    required String recommendationId,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.recommendationIgnored,
      data: {
        'recommendationId': recommendationId,
      },
      cause: EventCause(
        type: EventCauseType.userAction,
        trigger: 'recommendation_ignored',
      ),
    ));
  }

  /// Record match started
  void recordMatchStarted({
    required String matchId,
    required String opponentType,
    String? rackType,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.matchStarted,
      data: {
        'matchId': matchId,
        'opponent': opponentType,
        if (rackType != null) 'rackType': rackType,
      },
      stateBefore: {'match_active': false},
      stateAfter: {
        'match_active': true,
        'matchId': matchId,
      },
    ));
  }

  /// Record match completed
  void recordMatchCompleted({
    required String matchId,
    required String result,
    required int playerScore,
    required int opponentScore,
    required int durationSeconds,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.matchCompleted,
      data: {
        'matchId': matchId,
        'result': result,
        'playerScore': playerScore,
        'opponentScore': opponentScore,
        'duration': durationSeconds,
      },
      stateBefore: {'match_active': true},
      stateAfter: {
        'match_active': false,
        'match_result': result,
        'player_score': playerScore,
        'opponent_score': opponentScore,
      },
    ));
  }

  /// Record an error
  void recordError({
    required String errorType,
    required String message,
    String? screen,
    String? stackTrace,
  }) {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.errorOccurred,
      data: {
        'errorType': errorType,
        'message': message,
        if (screen != null) 'screen': screen,
        if (stackTrace != null) 'stackTrace': stackTrace,
      },
    ));
  }

  /// Record Coach Home loaded
  void recordCoachHomeLoaded() {
    _addEvent(BlackBoxReplayEvent(
      timestamp: DateTime.now().toIso8601String(),
      elapsedSeconds: elapsedSeconds,
      eventType: BlackBoxEventType.coachHomeLoaded,
      stateBefore: null,
      stateAfter: {
        'screen': 'coach_home',
      },
    ));
  }

  /// Get all recorded events
  List<BlackBoxReplayEvent> getEvents() => List.unmodifiable(_events);

  /// Get event count
  int get eventCount => _events.length;

  /// Get session start time
  DateTime? get sessionStart => _sessionStart;

  /// Add an event with rotation
  void _addEvent(BlackBoxReplayEvent event) {
    _events.add(event);

    // Rotate if over limit
    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }

    // Check storage size and rotate if needed
    _checkStorageSize();
  }

  /// Check if storage exceeds limit and rotate
  void _checkStorageSize() {
    try {
      final json = jsonEncode(_events.map((e) => e.toJson()).toList());
      if (json.length > _maxStorageBytes) {
        // Remove oldest events until under limit
        while (_events.isNotEmpty) {
          _events.removeAt(0);
          final newJson = jsonEncode(_events.map((e) => e.toJson()).toList());
          if (newJson.length <= _maxStorageBytes) break;
        }
      }
    } catch (e) {
      debugPrint('BlackBox: Error checking storage size: $e');
    }
  }

  /// Save events to persistent storage
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_events.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, json);
      debugPrint('BlackBox: Saved ${_events.length} events');
    } catch (e) {
      debugPrint('BlackBox: Error saving to storage: $e');
    }
  }

  /// Load events from persistent storage
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        final list = jsonDecode(json) as List;
        _events.clear();
        for (final item in list) {
          try {
            _events.add(BlackBoxReplayEvent.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            debugPrint('BlackBox: Error parsing event: $e');
          }
        }
        debugPrint('BlackBox: Loaded ${_events.length} events');
      }
    } catch (e) {
      debugPrint('BlackBox: Error loading from storage: $e');
    }
  }

  /// Clear all events
  void clear() {
    _events.clear();
    _sessionStart = null;
    _isRecording = false;
  }

  /// Export events as JSON
  String exportAsJson() {
    return jsonEncode({
      'schemaVersion': '2.0',
      'packageId': 'session_${DateTime.now().millisecondsSinceEpoch}',
      'sessionStart': _sessionStart?.toIso8601String(),
      'sessionEnd': DateTime.now().toIso8601String(),
      'totalEvents': _events.length,
      'replay': _events.map((e) => e.toJson()).toList(),
    });
  }
}
