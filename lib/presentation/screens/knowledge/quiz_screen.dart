import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/quiz.dart';
import '../../../domain/services/quiz_service.dart';

/// Quiz screen — multiple choice per article.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.articleSlug});
  final String articleSlug;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Quiz? _quiz;
  bool _loading = true;
  final Map<String, int> _answers = {};
  int _index = 0;
  bool _done = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = ProviderScope.containerOf(context, listen: false).read(quizServiceProvider);
    final quiz = await svc.byArticle(widget.articleSlug);
    if (!mounted) return;
    setState(() {
      _quiz = quiz;
      _loading = false;
    });
  }

  Future<void> _next(int selected) async {
    final q = _quiz!.questions[_index];
    _answers[q.id] = selected;
    if (_index + 1 >= _quiz!.questions.length) {
      final svc = ProviderScope.containerOf(context, listen: false).read(quizServiceProvider);
      final attempt = await svc.recordAttempt(_quiz!, _answers);
      if (!mounted) return;
      setState(() {
        _score = attempt.score;
        _done = true;
      });
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_quiz?.title ?? 'Quiz')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quiz == null
              ? const Center(child: Text('Chưa có quiz cho bài viết này.'))
              : _done
                  ? _result()
                  : _question(),
    );
  }

  Widget _question() {
    final q = _quiz!.questions[_index];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Câu ${_index + 1}/${_quiz!.questions.length}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(q.prompt,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...List.generate(q.options.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ElevatedButton(
                onPressed: () => _next(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.05),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.all(16),
                ),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(q.options[i])),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _result() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _score >= 80
                ? Icons.celebration
                : (_score >= 60 ? Icons.thumb_up : Icons.refresh),
            size: 80,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          Text('$_score/100',
              style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _score >= 80
                ? 'Xuất sắc!'
                : (_score >= 60 ? 'Tốt, tiếp tục luyện tập!' : 'Cần ôn lại'),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}