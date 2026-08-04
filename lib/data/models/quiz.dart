class QuizQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        id: j['id'] as String,
        prompt: j['prompt'] as String,
        options: (j['options'] as List).cast<String>(),
        correctIndex: j['correctIndex'] as int,
        explanation: j['explanation'] as String?,
      );
}

class Quiz {
  final String id;
  final String articleSlug;
  final String title;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.id,
    required this.articleSlug,
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'articleSlug': articleSlug,
        'title': title,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  factory Quiz.fromJson(Map<String, dynamic> j) => Quiz(
        id: j['id'] as String,
        articleSlug: j['articleSlug'] as String,
        title: j['title'] as String,
        questions: (j['questions'] as List)
            .cast<Map<String, dynamic>>()
            .map(QuizQuestion.fromJson)
            .toList(),
      );
}

/// Per-quiz attempt result.
class QuizAttempt {
  final String quizId;
  final Map<String, int> answers; // questionId -> chosenIndex
  final DateTime takenAt;
  final int score; // 0..100
  const QuizAttempt({
    required this.quizId,
    required this.answers,
    required this.takenAt,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'answers': answers,
        'takenAt': takenAt.toIso8601String(),
        'score': score,
      };

  factory QuizAttempt.fromJson(Map<String, dynamic> j) => QuizAttempt(
        quizId: j['quizId'] as String,
        answers: (j['answers'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v as int),
        ),
        takenAt: DateTime.parse(j['takenAt'] as String),
        score: j['score'] as int,
      );
}