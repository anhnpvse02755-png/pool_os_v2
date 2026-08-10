// ============================================================================
// Replay Builder Service — Phase B.2
// Builds the replay.json with 100% replayability
// ============================================================================

import 'dart:convert';
import '../models/black_box_event.dart';
import '../models/black_box_replay_event.dart';
import 'event_recorder_service.dart';

/// Builds the replay.json timeline with complete cause chains
class ReplayBuilderService {
  final EventRecorderService _eventRecorder;

  ReplayBuilderService(this._eventRecorder);

  /// Build complete replay.json
  Map<String, dynamic> buildReplayJson({
    required String testerId,
    String? packageId,
  }) {
    final events = _eventRecorder.getEvents();
    final sessionStart = _eventRecorder.sessionStart ?? DateTime.now();
    final sessionEnd = DateTime.now();
    final totalDuration = sessionEnd.difference(sessionStart).inSeconds;

    // Calculate stats by event type
    final eventStats = _calculateEventStats(events);

    return {
      'schemaVersion': '2.0',
      'packageId': packageId ?? 'pkg_${DateTime.now().millisecondsSinceEpoch}',
      'testerId': testerId,
      'sessionStart': sessionStart.toIso8601String(),
      'sessionEnd': sessionEnd.toIso8601String(),
      'totalDuration': totalDuration,
      'totalEvents': events.length,
      'replay': events.map((e) => e.toJson()).toList(),
      'eventSummary': eventStats,
    };
  }

  /// Calculate statistics by event type
  Map<String, int> _calculateEventStats(List<BlackBoxReplayEvent> events) {
    final stats = <String, int>{};
    for (final event in events) {
      final eventName = event.eventType.value;
      stats[eventName] = (stats[eventName] ?? 0) + 1;
    }
    return stats;
  }

  /// Get replay as pretty-printed JSON string
  String buildReplayJsonString({
    required String testerId,
    String? packageId,
  }) {
    final replay = buildReplayJson(
      testerId: testerId,
      packageId: packageId,
    );
    return const JsonEncoder.withIndent('  ').convert(replay);
  }

  /// Get replay as compact JSON string
  String buildReplayJsonCompact({
    required String testerId,
    String? packageId,
  }) {
    final replay = buildReplayJson(
      testerId: testerId,
      packageId: packageId,
    );
    return jsonEncode(replay);
  }

  /// Get summary of the replay
  ReplaySummary getSummary() {
    final events = _eventRecorder.getEvents();
    final sessionStart = _eventRecorder.sessionStart;

    return ReplaySummary(
      totalEvents: events.length,
      sessionStart: sessionStart,
      sessionEnd: DateTime.now(),
      drillStarts: events.where((e) => e.eventType == BlackBoxEventType.startDrill).length,
      drillCompletions: events.where((e) => e.eventType == BlackBoxEventType.drillCompleted).length,
      drillAbandons: events.where((e) => e.eventType == BlackBoxEventType.drillAbandoned).length,
      matchesStarted: events.where((e) => e.eventType == BlackBoxEventType.matchStarted).length,
      matchesCompleted: events.where((e) => e.eventType == BlackBoxEventType.matchCompleted).length,
      coachChats: events.where((e) => e.eventType == BlackBoxEventType.coachChatOpen).length,
      recommendations: events.where((e) => e.eventType == BlackBoxEventType.coachRecommendationShown).length,
      errors: events.where((e) => e.eventType == BlackBoxEventType.errorOccurred).length,
    );
  }

  /// Validate replay for completeness
  ReplayValidation validate() {
    final events = _eventRecorder.getEvents();
    final issues = <String>[];

    // Check for app_open
    final hasAppOpen = events.any((e) => e.eventType == BlackBoxEventType.appOpen);
    if (!hasAppOpen) {
      issues.add('Missing app_open event');
    }

    // Check for app_close
    final hasAppClose = events.any((e) => e.eventType == BlackBoxEventType.appClose);
    if (!hasAppClose) {
      issues.add('Missing app_close event');
    }

    // Check that state changes have before/after
    for (final event in events) {
      if (event.stateAfter != null && event.stateBefore == null && event.eventType != BlackBoxEventType.appOpen) {
        // Warning: State changed but no before state
      }
    }

    // Check for missing cause chains
    final stateChangingEvents = events.where((e) => e.stateAfter != null || e.stateBefore != null);
    for (final event in stateChangingEvents) {
      if (event.cause == null && event.eventType != BlackBoxEventType.appOpen && event.eventType != BlackBoxEventType.appClose) {
        issues.add('Event ${event.eventType.value} has state change but no cause chain');
      }
    }

    return ReplayValidation(
      isValid: issues.isEmpty,
      issues: issues,
      totalEvents: events.length,
      firstEvent: events.isNotEmpty ? events.first.eventType.value : null,
      lastEvent: events.isNotEmpty ? events.last.eventType.value : null,
    );
  }
}

/// Summary of replay
class ReplaySummary {
  final int totalEvents;
  final DateTime? sessionStart;
  final DateTime sessionEnd;
  final int drillStarts;
  final int drillCompletions;
  final int drillAbandons;
  final int matchesStarted;
  final int matchesCompleted;
  final int coachChats;
  final int recommendations;
  final int errors;

  ReplaySummary({
    required this.totalEvents,
    this.sessionStart,
    required this.sessionEnd,
    required this.drillStarts,
    required this.drillCompletions,
    required this.drillAbandons,
    required this.matchesStarted,
    required this.matchesCompleted,
    required this.coachChats,
    required this.recommendations,
    required this.errors,
  });

  int get totalDurationSeconds => sessionStart != null
      ? sessionEnd.difference(sessionStart!).inSeconds
      : 0;

  String get totalDurationFormatted {
    final seconds = totalDurationSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  double get drillCompletionRate => drillStarts > 0
      ? drillCompletions / drillStarts
      : 0;
}

/// Validation result
class ReplayValidation {
  final bool isValid;
  final List<String> issues;
  final int totalEvents;
  final String? firstEvent;
  final String? lastEvent;

  ReplayValidation({
    required this.isValid,
    required this.issues,
    required this.totalEvents,
    this.firstEvent,
    this.lastEvent,
  });
}
