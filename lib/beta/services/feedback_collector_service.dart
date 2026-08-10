// ============================================================================
// Feedback Collector Service — Phase B.x
// Collects user feedback before export
// ============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Collects and stores user feedback for Black Box
class FeedbackCollectorService {
  static const String _storageKey = 'black_box_feedback';

  /// Current feedback being collected
  BlackBoxFeedback? _currentFeedback;

  /// Get current feedback
  BlackBoxFeedback? get currentFeedback => _currentFeedback;

  /// Start collecting feedback
  void startFeedbackCollection() {
    _currentFeedback = BlackBoxFeedback(
      collectedAt: DateTime.now(),
    );
  }

  /// Set overall rating (1-5)
  void setOverallRating(int rating) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(overall: rating);
  }

  /// Set Coach helpful rating (1-5)
  void setCoachHelpfulRating(int rating) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(coachHelpful: rating);
  }

  /// Set Coach understandable rating (1-5)
  void setCoachUnderstandableRating(int rating) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(coachUnderstandable: rating);
  }

  /// Set Coach accurate rating (1-5)
  void setCoachAccurateRating(int rating) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(coachAccurate: rating);
  }

  /// Set Coach remembering rating (1-5)
  void setCoachRememberingRating(int rating) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(coachRemembering: rating);
  }

  /// Set Coach natural rating (1-5)
  void setCoachNaturalRating(int rating) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(coachNatural: rating);
  }

  /// Set would use again
  void setWouldUseAgain(bool value) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(wouldUseAgain: value);
  }

  /// Set would recommend
  void setWouldRecommend(bool value) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(wouldRecommend: value);
  }

  /// Set most useful feature
  void setMostUseful(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(mostUseful: text);
  }

  /// Set least useful feature
  void setLeastUseful(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(leastUseful: text);
  }

  /// Set confusing screens
  void setConfusingScreens(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(mostConfusing: text);
  }

  /// Set missing features
  void setMissingFeatures(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(missingFeatures: text);
  }

  /// Set detailed feedback
  void setWhatWorkedWell(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(whatWorkedWell: text);
  }

  void setWhatCouldBeBetter(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(whatCouldBeBetter: text);
  }

  void setFrustrations(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(frustrations: text);
  }

  void setBugsEncountered(String? text) {
    if (_currentFeedback == null) return;
    _currentFeedback = _currentFeedback!.copyWith(bugsEncountered: text);
  }

  /// Get feedback as JSON
  Map<String, dynamic>? getFeedbackJson() {
    if (_currentFeedback == null) return null;
    return _currentFeedback!.toJson();
  }

  /// Save feedback to storage
  Future<void> saveFeedback() async {
    if (_currentFeedback == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_currentFeedback!.toJson());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      // Storage error - not critical
    }
  }

  /// Load last feedback from storage
  Future<BlackBoxFeedback?> loadLastFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        return BlackBoxFeedback.fromJson(jsonDecode(json));
      }
    } catch (e) {
      // Storage error
    }
    return null;
  }

  /// Clear current feedback
  void clear() {
    _currentFeedback = null;
  }

  /// Cancel feedback collection
  void cancel() {
    _currentFeedback = null;
  }
}

/// Feedback data model
class BlackBoxFeedback {
  final DateTime collectedAt;
  final int? overall;
  final int? coachHelpful;
  final int? coachUnderstandable;
  final int? coachAccurate;
  final int? coachRemembering;
  final int? coachNatural;
  final bool? wouldUseAgain;
  final bool? wouldRecommend;
  final String? mostUseful;
  final String? leastUseful;
  final String? mostConfusing;
  final String? missingFeatures;
  final String? whatWorkedWell;
  final String? whatCouldBeBetter;
  final String? frustrations;
  final String? bugsEncountered;

  BlackBoxFeedback({
    required this.collectedAt,
    this.overall,
    this.coachHelpful,
    this.coachUnderstandable,
    this.coachAccurate,
    this.coachRemembering,
    this.coachNatural,
    this.wouldUseAgain,
    this.wouldRecommend,
    this.mostUseful,
    this.leastUseful,
    this.mostConfusing,
    this.missingFeatures,
    this.whatWorkedWell,
    this.whatCouldBeBetter,
    this.frustrations,
    this.bugsEncountered,
  });

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': '2.0',
      'collectedAt': collectedAt.toIso8601String(),
      'rating': {
        'overall': overall,
        'coachHelpful': coachHelpful,
        'coachUnderstandable': coachUnderstandable,
        'coachAccurate': coachAccurate,
        'coachRemembering': coachRemembering,
        'coachNatural': coachNatural,
        'wouldUseAgain': wouldUseAgain,
        'wouldRecommend': wouldRecommend,
      },
      'qualitative': {
        'mostUseful': mostUseful,
        'leastUseful': leastUseful,
        'mostConfusing': mostConfusing,
        'missingFeatures': missingFeatures,
      },
      'detailedFeedback': {
        'whatWorkedWell': whatWorkedWell,
        'whatCouldBeBetter': whatCouldBeBetter,
        'frustrations': frustrations,
        'bugsEncountered': bugsEncountered,
      },
    };
  }

  factory BlackBoxFeedback.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map<String, dynamic>? ?? {};
    final qualitative = json['qualitative'] as Map<String, dynamic>? ?? {};
    final detailed = json['detailedFeedback'] as Map<String, dynamic>? ?? {};

    return BlackBoxFeedback(
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      overall: rating['overall'] as int?,
      coachHelpful: rating['coachHelpful'] as int?,
      coachUnderstandable: rating['coachUnderstandable'] as int?,
      coachAccurate: rating['coachAccurate'] as int?,
      coachRemembering: rating['coachRemembering'] as int?,
      coachNatural: rating['coachNatural'] as int?,
      wouldUseAgain: rating['wouldUseAgain'] as bool?,
      wouldRecommend: rating['wouldRecommend'] as bool?,
      mostUseful: qualitative['mostUseful'] as String?,
      leastUseful: qualitative['leastUseful'] as String?,
      mostConfusing: qualitative['mostConfusing'] as String?,
      missingFeatures: qualitative['missingFeatures'] as String?,
      whatWorkedWell: detailed['whatWorkedWell'] as String?,
      whatCouldBeBetter: detailed['whatCouldBeBetter'] as String?,
      frustrations: detailed['frustrations'] as String?,
      bugsEncountered: detailed['bugsEncountered'] as String?,
    );
  }

  BlackBoxFeedback copyWith({
    int? overall,
    int? coachHelpful,
    int? coachUnderstandable,
    int? coachAccurate,
    int? coachRemembering,
    int? coachNatural,
    bool? wouldUseAgain,
    bool? wouldRecommend,
    String? mostUseful,
    String? leastUseful,
    String? mostConfusing,
    String? missingFeatures,
    String? whatWorkedWell,
    String? whatCouldBeBetter,
    String? frustrations,
    String? bugsEncountered,
  }) {
    return BlackBoxFeedback(
      collectedAt: collectedAt,
      overall: overall ?? this.overall,
      coachHelpful: coachHelpful ?? this.coachHelpful,
      coachUnderstandable: coachUnderstandable ?? this.coachUnderstandable,
      coachAccurate: coachAccurate ?? this.coachAccurate,
      coachRemembering: coachRemembering ?? this.coachRemembering,
      coachNatural: coachNatural ?? this.coachNatural,
      wouldUseAgain: wouldUseAgain ?? this.wouldUseAgain,
      wouldRecommend: wouldRecommend ?? this.wouldRecommend,
      mostUseful: mostUseful ?? this.mostUseful,
      leastUseful: leastUseful ?? this.leastUseful,
      mostConfusing: mostConfusing ?? this.mostConfusing,
      missingFeatures: missingFeatures ?? this.missingFeatures,
      whatWorkedWell: whatWorkedWell ?? this.whatWorkedWell,
      whatCouldBeBetter: whatCouldBeBetter ?? this.whatCouldBeBetter,
      frustrations: frustrations ?? this.frustrations,
      bugsEncountered: bugsEncountered ?? this.bugsEncountered,
    );
  }
}
