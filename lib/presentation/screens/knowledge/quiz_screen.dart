import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../data/models/quiz.dart';
import '../../../domain/services/quiz_service.dart';

/// Quiz screen - Redesigned with Minimalist Luxury
/// Multiple choice per article
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
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightness = Theme.of(context).brightness;
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
      backgroundColor: AppColors.background(_brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(_brightness),
        elevation: 0,
        title: Text(
          _quiz?.title ?? 'Quiz',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(_brightness),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.accentColor(_brightness)))
          : _quiz == null
              ? Center(
                  child: Text(
                    'Chưa có quiz cho bài viết này.',
                    style: TextStyle(color: AppColors.textSecondary(_brightness)),
                  ),
                )
              : _done
                  ? _result()
                  : _question(),
    );
  }

  Widget _question() {
    final q = _quiz!.questions[_index];
    final accentColor = AppColors.accentColor(_brightness);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu ${_index + 1}/${_quiz!.questions.length}',
            style: TextStyle(
              color: AppColors.textSecondary(_brightness),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (_index + 1) / _quiz!.questions.length,
            backgroundColor: AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            q.prompt,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(_brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(q.options.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _OptionButton(
                text: q.options[i],
                index: i,
                onPressed: () => _next(i),
                brightness: _brightness,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _result() {
    final accentColor = AppColors.accentColor(_brightness);
    IconData icon;
    Color iconColor;
    String message;

    if (_score >= 80) {
      icon = Icons.celebration;
      iconColor = AppColors.success;
      message = 'Xuất sắc!';
    } else if (_score >= 60) {
      icon = Icons.thumb_up;
      iconColor = accentColor;
      message = 'Tốt, tiếp tục luyện tập!';
    } else {
      icon = Icons.refresh;
      iconColor = AppColors.warning;
      message = 'Cần ôn lại';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              '$_score/100',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(_brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary(_brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ResultButton(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Đóng',
              brightness: _brightness,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatefulWidget {
  final String text;
  final int index;
  final VoidCallback onPressed;
  final Brightness brightness;

  const _OptionButton({
    required this.text,
    required this.index,
    required this.onPressed,
    required this.brightness,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Material(
          color: AppColors.surface(widget.brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.lightBorder),
                boxShadow: AppShadows.sm(widget.brightness),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor(widget.brightness).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + widget.index),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentColor(widget.brightness),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary(widget.brightness),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Brightness brightness;

  const _ResultButton({
    required this.onPressed,
    required this.label,
    required this.brightness,
  });

  @override
  State<_ResultButton> createState() => _ResultButtonState();
}

class _ResultButtonState extends State<_ResultButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accentColor(widget.brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentColor(widget.brightness).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
