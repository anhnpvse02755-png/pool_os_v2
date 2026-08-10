// ============================================================================
// Black Box Replay Event — 100% Replayability
// Version: 2.0
//
// PRINCIPLE: Never export state without exporting the cause chain.
// Every state change must be traceable to the events and decisions that created it.
// ============================================================================

import 'black_box_event.dart';

/// A single event in the replay timeline.
/// Includes cause chain for 100% replayability.
class BlackBoxReplayEvent {
  /// ISO 8601 timestamp
  final String timestamp;

  /// Elapsed time in seconds from session start
  final int elapsedSeconds;

  /// Event type (immutable name from schema)
  final BlackBoxEventType eventType;

  /// Optional event data payload
  final Map<String, dynamic>? data;

  /// WHY did this event happen? (cause chain)
  final EventCause? cause;

  /// State before this event (null if app start)
  final Map<String, dynamic>? stateBefore;

  /// State after this event (null if app end)
  final Map<String, dynamic>? stateAfter;

  BlackBoxReplayEvent({
    required this.timestamp,
    required this.elapsedSeconds,
    required this.eventType,
    this.data,
    this.cause,
    this.stateBefore,
    this.stateAfter,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': timestamp,
      'elapsed': elapsedSeconds,
      'event': eventType.value,
      if (data != null) 'data': data,
      if (cause != null) 'cause': cause!.toJson(),
      if (stateBefore != null) 'stateBefore': stateBefore,
      if (stateAfter != null) 'stateAfter': stateAfter,
    };
  }

  /// Create from JSON
  factory BlackBoxReplayEvent.fromJson(Map<String, dynamic> json) {
    final eventValue = json['event'] as String;
    final eventType = BlackBoxEventType.fromValue(eventValue);

    if (eventType == null) {
      throw FormatException('Unknown event type: $eventValue');
    }

    return BlackBoxReplayEvent(
      timestamp: json['time'] as String,
      elapsedSeconds: json['elapsed'] as int,
      eventType: eventType,
      data: json['data'] as Map<String, dynamic>?,
      cause: json['cause'] != null
          ? EventCause.fromJson(json['cause'] as Map<String, dynamic>)
          : null,
      stateBefore: json['stateBefore'] as Map<String, dynamic>?,
      stateAfter: json['stateAfter'] as Map<String, dynamic>?,
    );
  }

  /// Create an app_open event
  factory BlackBoxReplayEvent.appOpen(DateTime time) {
    return BlackBoxReplayEvent(
      timestamp: time.toIso8601String(),
      elapsedSeconds: 0,
      eventType: BlackBoxEventType.appOpen,
    );
  }

  /// Create an app_close event
  factory BlackBoxReplayEvent.appClose(DateTime time, int elapsed, Map<String, dynamic>? stateAfter) {
    return BlackBoxReplayEvent(
      timestamp: time.toIso8601String(),
      elapsedSeconds: elapsed,
      eventType: BlackBoxEventType.appClose,
      stateAfter: stateAfter,
    );
  }

  /// Create a recommendation_generated event
  factory BlackBoxReplayEvent.recommendationShown({
    required DateTime time,
    required int elapsed,
    required String recommendationId,
    required String drillCode,
    required String drillName,
    required int priority,
    required String reason,
    required Map<String, dynamic>? stateBefore,
    required Map<String, dynamic> stateAfter,
  }) {
    return BlackBoxReplayEvent(
      timestamp: time.toIso8601String(),
      elapsedSeconds: elapsed,
      eventType: BlackBoxEventType.coachRecommendationShown,
      data: {
        'recommendationId': recommendationId,
        'drill': drillName,
        'drillCode': drillCode,
        'priority': priority,
        'reason': reason,
      },
      cause: EventCause(
        type: EventCauseType.priorityEngine,
        observations: ['Player data analyzed'],
        reasoning: 'Priority calculated based on score, frequency, trend',
      ),
      stateBefore: stateBefore,
      stateAfter: stateAfter,
    );
  }

  /// Create a start_drill event
  factory BlackBoxReplayEvent.startDrill({
    required DateTime time,
    required int elapsed,
    required String drillCode,
    required String drillName,
    String? source,
    String? recommendationId,
    required Map<String, dynamic>? stateBefore,
    required Map<String, dynamic> stateAfter,
  }) {
    return BlackBoxReplayEvent(
      timestamp: time.toIso8601String(),
      elapsedSeconds: elapsed,
      eventType: BlackBoxEventType.startDrill,
      data: {
        'drill': drillName,
        'drillCode': drillCode,
        if (source != null) 'source': source,
        if (recommendationId != null) 'recommendationId': recommendationId,
      },
      cause: EventCause(
        type: EventCauseType.userAction,
        trigger: source == 'recommendation'
            ? 'recommendation_accepted'
            : 'user_selected',
      ),
      stateBefore: stateBefore,
      stateAfter: stateAfter,
    );
  }

  /// Create a drill_completed event
  factory BlackBoxReplayEvent.drillCompleted({
    required DateTime time,
    required int elapsed,
    required String drillCode,
    required String drillName,
    required int score,
    required int shotsAttempted,
    required int shotsMade,
    required int durationSeconds,
    String? recommendationId,
    required Map<String, dynamic>? stateBefore,
    required Map<String, dynamic> stateAfter,
  }) {
    return BlackBoxReplayEvent(
      timestamp: time.toIso8601String(),
      elapsedSeconds: elapsed,
      eventType: BlackBoxEventType.drillCompleted,
      data: {
        'drill': drillName,
        'drillCode': drillCode,
        'score': score,
        'shotsAttempted': shotsAttempted,
        'shotsMade': shotsMade,
        'duration': durationSeconds,
        if (recommendationId != null) 'recommendationId': recommendationId,
      },
      cause: recommendationId != null
          ? EventCause(
              type: EventCauseType.drillResult,
              recommendationId: recommendationId,
            )
          : null,
      stateBefore: stateBefore,
      stateAfter: stateAfter,
    );
  }
}

/// Cause of an event — WHY did this happen?
class EventCause {
  /// Type of cause
  final EventCauseType type;

  /// For type = priority_engine, coach_service
  final List<String>? observations;

  /// For type = priority_engine
  final String? reasoning;

  /// For type = user_action
  final String? trigger;

  /// For type = drill_result, coach_service
  final String? recommendationId;

  /// For type = coach_service
  final String? intent;

  EventCause({
    required this.type,
    this.observations,
    this.reasoning,
    this.trigger,
    this.recommendationId,
    this.intent,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      if (observations != null) 'observations': observations,
      if (reasoning != null) 'reasoning': reasoning,
      if (trigger != null) 'trigger': trigger,
      if (recommendationId != null) 'recommendationId': recommendationId,
      if (intent != null) 'intent': intent,
    };
  }

  factory EventCause.fromJson(Map<String, dynamic> json) {
    return EventCause(
      type: EventCauseType.fromValue(json['type'] as String),
      observations: (json['observations'] as List<dynamic>?)?.cast<String>(),
      reasoning: json['reasoning'] as String?,
      trigger: json['trigger'] as String?,
      recommendationId: json['recommendationId'] as String?,
      intent: json['intent'] as String?,
    );
  }
}

/// Types of event causes
enum EventCauseType {
  priorityEngine('priority_engine'),
  coachService('coach_service'),
  userAction('user_action'),
  drillResult('drill_result'),
  system('system');

  const EventCauseType(this.value);
  final String value;

  static EventCauseType fromValue(String value) {
    return EventCauseType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventCauseType.system,
    );
  }
}
