import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../../data/models/quiz.dart';

/// Phase B: Quiz scoring + persistence.
class QuizService {
  QuizService();
  static const _kQuizKey = 'poolos_v2.quizzes';
  static const _kAttemptKey = 'poolos_v2.quiz_attempts';

  Future<List<Quiz>> all() async {
    final raw = LocalStorageService.prefs.getString(_kQuizKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(Quiz.fromJson)
        .toList();
  }

  Future<Quiz?> byArticle(String articleSlug) async {
    final all = await this.all();
    try {
      return all.firstWhere((q) => q.articleSlug == articleSlug);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveQuiz(Quiz q) async {
    final all = await this.all();
    final idx = all.indexWhere((x) => x.id == q.id);
    if (idx >= 0) {
      all[idx] = q;
    } else {
      all.add(q);
    }
    await LocalStorageService.prefs.setString(
        _kQuizKey, jsonEncode(all.map((x) => x.toJson()).toList()));
  }

  /// Score a quiz attempt. Returns score 0..100.
  int score(Quiz quiz, Map<String, int> answers) {
    if (quiz.questions.isEmpty) return 0;
    int correct = 0;
    for (final q in quiz.questions) {
      if (answers[q.id] == q.correctIndex) correct++;
    }
    return (correct / quiz.questions.length * 100).round();
  }

  Future<QuizAttempt> recordAttempt(
      Quiz quiz, Map<String, int> answers) async {
    final computedScore = score(quiz, answers);
    final attempt = QuizAttempt(
      quizId: quiz.id,
      answers: answers,
      takenAt: DateTime.now(),
      score: computedScore,
    );
    final raw = LocalStorageService.prefs.getString(_kAttemptKey);
    final list = (raw == null || raw.isEmpty)
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(attempt.toJson());
    await LocalStorageService.prefs.setString(_kAttemptKey, jsonEncode(list));
    return attempt;
  }

  Future<List<QuizAttempt>> attemptsFor(String quizId) async {
    final raw = LocalStorageService.prefs.getString(_kAttemptKey);
    if (raw == null || raw.isEmpty) return [];
    final all = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(QuizAttempt.fromJson)
        .toList();
    return all.where((a) => a.quizId == quizId).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }
}