// ============================================================================
// Black Box Event Types — Immutable Schema
// Version: 2.0
//
// COMPATIBILITY POLICY:
// - Event names are IMMUTABLE once released
// - Only ADD new events in future versions
// - Never rename or change meaning of existing events
// ============================================================================

/// All events in the Black Box. This enum is immutable.
enum BlackBoxEventType {
  // App Lifecycle
  appOpen('app_open', 'App started'),
  appClose('app_close', 'App closed'),

  // Coach
  coachHomeLoaded('coach_home_loaded', 'Coach Home screen loaded'),
  coachRecommendationShown('coach_recommendation_shown', 'Recommendation displayed'),
  recommendationAccepted('recommendation_accepted', 'User accepted recommendation'),
  recommendationIgnored('recommendation_ignored', 'User ignored recommendation'),
  coachChatOpen('coach_chat_open', 'Coach chat opened'),
  coachChatClose('coach_chat_close', 'Coach chat closed'),
  coachExplainShown('coach_explain_shown', 'Explain sheet shown'),

  // Drill
  startDrill('start_drill', 'User started drill'),
  drillCompleted('drill_completed', 'Drill finished successfully'),
  drillAbandoned('drill_abandoned', 'Drill abandoned'),
  drillPaused('drill_paused', 'Drill paused'),
  drillResumed('drill_resumed', 'Drill resumed'),

  // Match
  matchStarted('match_started', 'Match started'),
  matchCompleted('match_completed', 'Match finished'),

  // Session
  sessionStarted('session_started', 'Practice session started'),
  sessionEnded('session_ended', 'Practice session ended'),

  // Settings
  settingsOpen('settings_open', 'Settings opened'),
  settingsChanged('settings_changed', 'Setting changed'),

  // Export
  exportInitiated('export_initiated', 'Export started'),
  exportCompleted('export_completed', 'Export finished'),

  // Errors
  errorOccurred('error_occurred', 'Error or warning occurred'),

  // Chat
  coachMessageSent('coach_message_sent', 'User sent message to Coach'),
  coachResponseReceived('coach_response_received', 'Coach responded');

  const BlackBoxEventType(this.value, this.description);

  /// The immutable event name (matches schema)
  final String value;

  /// Human-readable description
  final String description;

  /// Get event type from value
  static BlackBoxEventType? fromValue(String value) {
    for (final type in BlackBoxEventType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// Category of events for grouping
enum BlackBoxEventCategory {
  app('App Lifecycle'),
  coach('Coach'),
  drill('Drill'),
  match('Match'),
  session('Session'),
  settings('Settings'),
  export('Export'),
  error('Error');

  const BlackBoxEventCategory(this.label);

  final String label;
}

extension BlackBoxEventTypeExtension on BlackBoxEventType {
  BlackBoxEventCategory get category {
    switch (this) {
      case BlackBoxEventType.appOpen:
      case BlackBoxEventType.appClose:
        return BlackBoxEventCategory.app;
      case BlackBoxEventType.coachHomeLoaded:
      case BlackBoxEventType.coachRecommendationShown:
      case BlackBoxEventType.recommendationAccepted:
      case BlackBoxEventType.recommendationIgnored:
      case BlackBoxEventType.coachChatOpen:
      case BlackBoxEventType.coachChatClose:
      case BlackBoxEventType.coachExplainShown:
        return BlackBoxEventCategory.coach;
      case BlackBoxEventType.startDrill:
      case BlackBoxEventType.drillCompleted:
      case BlackBoxEventType.drillAbandoned:
      case BlackBoxEventType.drillPaused:
      case BlackBoxEventType.drillResumed:
        return BlackBoxEventCategory.drill;
      case BlackBoxEventType.matchStarted:
      case BlackBoxEventType.matchCompleted:
        return BlackBoxEventCategory.match;
      case BlackBoxEventType.sessionStarted:
      case BlackBoxEventType.sessionEnded:
        return BlackBoxEventCategory.session;
      case BlackBoxEventType.settingsOpen:
      case BlackBoxEventType.settingsChanged:
        return BlackBoxEventCategory.settings;
      case BlackBoxEventType.exportInitiated:
      case BlackBoxEventType.exportCompleted:
        return BlackBoxEventCategory.export;
      case BlackBoxEventType.coachMessageSent:
      case BlackBoxEventType.coachResponseReceived:
        return BlackBoxEventCategory.coach;
      case BlackBoxEventType.errorOccurred:
        return BlackBoxEventCategory.error;
    }
  }
}
