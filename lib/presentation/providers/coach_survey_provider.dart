// ============================================================================
// COACH SURVEY PROVIDER - Phase 7B.5
// Manages Coach Entry Survey state
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/coach/coach_entry_survey_screen.dart';

// ============================================================================
// SURVEY STATE
// ============================================================================

class CoachSurveyState {
  final bool isCompleted;
  final CoachSurveyAnswers? answers;

  const CoachSurveyState({
    this.isCompleted = false,
    this.answers,
  });

  CoachSurveyState copyWith({
    bool? isCompleted,
    CoachSurveyAnswers? answers,
  }) {
    return CoachSurveyState(
      isCompleted: isCompleted ?? this.isCompleted,
      answers: answers ?? this.answers,
    );
  }
}

// ============================================================================
// SURVEY NOTIFIER
// ============================================================================

class CoachSurveyNotifier extends StateNotifier<CoachSurveyState> {
  CoachSurveyNotifier() : super(const CoachSurveyState()) {
    _loadSurveyState();
  }

  Future<void> _loadSurveyState() async {
    // Check if survey was already completed
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('coach_survey_completed') ?? false;

    state = state.copyWith(isCompleted: isCompleted);
  }

  void setSurveyCompleted(bool completed) {
    state = state.copyWith(isCompleted: completed);
    _saveSurveyCompleted(completed);
  }

  void setSurveyAnswers(CoachSurveyAnswers answers) {
    state = state.copyWith(answers: answers);
  }

  Future<void> _saveSurveyCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('coach_survey_completed', completed);
  }

  /// Check if user needs to take the survey
  bool get needsSurvey => !state.isCompleted;
}

// ============================================================================
// PROVIDER
// ============================================================================

final coachSurveyProvider = StateNotifierProvider<CoachSurveyNotifier, CoachSurveyState>((ref) {
  return CoachSurveyNotifier();
});

/// Convenience provider to check if survey is needed
final needsCoachSurveyProvider = Provider<bool>((ref) {
  return ref.watch(coachSurveyProvider).isCompleted == false;
});
