import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../data/models/flashcard.dart';
import '../../../domain/services/spaced_repetition_service.dart';

/// Flashcard review screen - Redesigned with Minimalist Luxury
/// Flip front/back, grade 0..5
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key, required this.articleSlug});
  final String articleSlug;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> _due = [];
  int _index = 0;
  bool _revealed = false;
  bool _loading = true;
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
    final svc = ProviderScope.containerOf(context, listen: false).read(spacedRepetitionServiceProvider);
    final due = await svc.dueFor(widget.articleSlug);
    if (!mounted) return;
    setState(() {
      _due = due;
      _loading = false;
    });
  }

  Future<void> _grade(int grade) async {
    final svc = ProviderScope.containerOf(context, listen: false).read(spacedRepetitionServiceProvider);
    await svc.review(cardId: _due[_index].id, grade: grade);
    if (!mounted) return;
    if (_index + 1 >= _due.length) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _index++;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background(_brightness),
        appBar: AppBar(
          backgroundColor: AppColors.background(_brightness),
          elevation: 0,
          title: Text(
            'Flashcards',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(_brightness),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: AppColors.accentColor(_brightness))),
      );
    }
    if (_due.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background(_brightness),
        appBar: AppBar(
          backgroundColor: AppColors.background(_brightness),
          elevation: 0,
          title: Text(
            'Flashcards',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(_brightness),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Không có thẻ nào cần ôn tập hôm nay.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary(_brightness),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final card = _due[_index];
    return Scaffold(
      backgroundColor: AppColors.background(_brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(_brightness),
        elevation: 0,
        title: Text(
          'Flashcard ${_index + 1}/${_due.length}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(_brightness),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _revealed = !_revealed),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: AppColors.surface(_brightness),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: AppShadows.md(_brightness),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        _revealed ? card.back : card.front,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _revealed
                              ? AppColors.accentColor(_brightness)
                              : AppColors.textPrimary(_brightness),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Độ khó (0 = sai, 5 = dễ):',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(_brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) {
                return _GradeButton(
                  grade: i,
                  onPressed: () => _grade(i),
                  brightness: _brightness,
                );
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _GradeButton extends StatefulWidget {
  final int grade;
  final VoidCallback onPressed;
  final Brightness brightness;

  const _GradeButton({
    required this.grade,
    required this.onPressed,
    required this.brightness,
  });

  @override
  State<_GradeButton> createState() => _GradeButtonState();
}

class _GradeButtonState extends State<_GradeButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final color = widget.grade <= 2 ? AppColors.error : AppColors.success;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.grade}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
