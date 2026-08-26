// ============================================================================
// COACH ENTRY SURVEY SCREEN - Phase 7B.5
// Initial assessment survey for Coach AI
// Redesigned with Minimalist Luxury Design System
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../knowledge/player_intelligence.dart';
import '../../providers/coach_survey_provider.dart';

/// Coach Entry Survey Screen
/// 3 questions to understand player's initial skill level
class CoachEntrySurveyScreen extends ConsumerStatefulWidget {
  const CoachEntrySurveyScreen({super.key});

  @override
  ConsumerState<CoachEntrySurveyScreen> createState() => _CoachEntrySurveyScreenState();
}

class _CoachEntrySurveyScreenState extends ConsumerState<CoachEntrySurveyScreen> {
  int? _missedShotType;
  int? _cueBallBehavior;
  int? _scratchFrequency;
  bool _isSubmitting = false;
  late Brightness _brightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightness = Theme.of(context).brightness;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(_brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(_brightness),
        elevation: 0,
        title: Text(
          'Khám phá điểm mạnh/yếu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(_brightness),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipSurvey,
            child: Text(
              'Bỏ qua',
              style: TextStyle(color: AppColors.textSecondary(_brightness)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestion(
                      number: 1,
                      title: 'Bạn thường miss ở loại cú đánh nào nhất?',
                      options: const [
                        'Đánh xa',
                        'Đánh góc',
                        'Draw/Follow',
                        'Bank/Kick',
                        'Không rõ',
                      ],
                      selectedIndex: _missedShotType,
                      onSelected: (index) => setState(() => _missedShotType = index),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _buildQuestion(
                      number: 2,
                      title: 'Bi cái thường đi như thế nào?',
                      options: const [
                        'Chạy quá xa',
                        'Chạy thiếu',
                        'Lệch hướng',
                        'Kiểm soát tốt',
                      ],
                      selectedIndex: _cueBallBehavior,
                      onSelected: (index) => setState(() => _cueBallBehavior = index),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _buildQuestion(
                      number: 3,
                      title: 'Bạn có hay scratch không?',
                      options: const [
                        'Thường xuyên',
                        'Đôi khi',
                        'Hiếm khi',
                        'Không bao giờ',
                      ],
                      selectedIndex: _scratchFrequency,
                      onSelected: (index) => setState(() => _scratchFrequency = index),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: _SurveyButton(
                onPressed: _canSubmit ? _submitSurvey : null,
                isLoading: _isSubmitting,
                label: 'Tiếp tục',
                brightness: _brightness,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _missedShotType != null && _cueBallBehavior != null && _scratchFrequency != null;

  Widget _buildProgressIndicator() {
    final answeredCount = [
      _missedShotType,
      _cueBallBehavior,
      _scratchFrequency,
    ].where((e) => e != null).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: answeredCount / 3,
                backgroundColor: AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor(_brightness)),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '$answeredCount/3',
            style: TextStyle(
              color: AppColors.textSecondary(_brightness),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion({
    required int number,
    required String title,
    required List<String> options,
    required int? selectedIndex,
    required Function(int) onSelected,
  }) {
    final accentColor = AppColors.accentColor(_brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(_brightness),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _OptionTile(
              title: options[index],
              isSelected: isSelected,
              onTap: () => onSelected(index),
              brightness: _brightness,
            ),
          );
        }),
      ],
    );
  }

  Future<void> _submitSurvey() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final answers = CoachSurveyAnswers(
        missedShotType: _missedShotType!,
        cueBallBehavior: _cueBallBehavior!,
        scratchFrequency: _scratchFrequency!,
        completedAt: DateTime.now(),
      );

      await _saveSurveyAnswers(answers);

      ref.read(coachSurveyProvider.notifier).setSurveyCompleted(true);
      ref.read(coachSurveyProvider.notifier).setSurveyAnswers(answers);

      if (mounted) {
        context.go('/coach');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _skipSurvey() async {
    ref.read(coachSurveyProvider.notifier).setSurveyCompleted(true);

    if (mounted) {
      context.go('/coach');
    }
  }

  Future<void> _saveSurveyAnswers(CoachSurveyAnswers answers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'coach_survey_answers',
      jsonEncode({
        'missedShotType': answers.missedShotType,
        'cueBallBehavior': answers.cueBallBehavior,
        'scratchFrequency': answers.scratchFrequency,
        'completedAt': answers.completedAt.toIso8601String(),
      }),
    );
  }
}

class _SurveyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final Brightness brightness;

  const _SurveyButton({
    required this.onPressed,
    required this.isLoading,
    required this.label,
    required this.brightness,
  });

  @override
  State<_SurveyButton> createState() => _SurveyButtonState();
}

class _SurveyButtonState extends State<_SurveyButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accentColor(widget.brightness) : AppColors.textTertiary(widget.brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [
              BoxShadow(color: AppColors.accentColor(widget.brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))
            ] : null,
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Brightness brightness;

  const _OptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(brightness);

    return Material(
      color: isSelected ? accentColor.withValues(alpha: 0.1) : AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? accentColor : AppColors.lightBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? accentColor : AppColors.textTertiary(brightness),
                    width: 2,
                  ),
                  color: isSelected ? accentColor : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? accentColor : AppColors.textPrimary(brightness),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Coach Survey Answers Model
class CoachSurveyAnswers {
  final int missedShotType;
  final int cueBallBehavior;
  final int scratchFrequency;
  final DateTime completedAt;

  const CoachSurveyAnswers({
    required this.missedShotType,
    required this.cueBallBehavior,
    required this.scratchFrequency,
    required this.completedAt,
  });

  Map<String, dynamic> toPlayerIntelligenceData() {
    final skillLevels = <String, int>{};

    if (cueBallBehavior <= 2) {
      skillLevels['cueball_control'] = 30;
    } else {
      skillLevels['cueball_control'] = 50;
    }

    if (cueBallBehavior == 0) {
      skillLevels['position_play'] = 25;
      skillLevels['spin_control'] = 35;
    } else if (cueBallBehavior == 1) {
      skillLevels['position_play'] = 30;
      skillLevels['spin_control'] = 40;
    } else if (cueBallBehavior == 2) {
      skillLevels['position_play'] = 35;
      skillLevels['aiming'] = 40;
    } else {
      skillLevels['position_play'] = 55;
      skillLevels['spin_control'] = 55;
    }

    if (scratchFrequency == 0) {
      skillLevels['safety_play'] = 25;
      skillLevels['shot_selection'] = 35;
    } else if (scratchFrequency == 1) {
      skillLevels['safety_play'] = 40;
      skillLevels['shot_selection'] = 45;
    } else {
      skillLevels['safety_play'] = 55;
      skillLevels['shot_selection'] = 60;
    }

    switch (missedShotType) {
      case 0:
        skillLevels['power_control'] = 30;
        skillLevels['long_shots'] = 25;
        break;
      case 1:
        skillLevels['aiming'] = 35;
        skillLevels['english_usage'] = 40;
        break;
      case 2:
        skillLevels['spin_control'] = 30;
        skillLevels['draw_shots'] = 25;
        skillLevels['follow_shots'] = 30;
        break;
      case 3:
        skillLevels['bank_shots'] = 25;
        skillLevels['kick_shots'] = 25;
        break;
      default:
        break;
    }

    final avgScore = skillLevels.values.isEmpty
        ? 0
        : skillLevels.values.reduce((a, b) => a + b) ~/ skillLevels.values.length;

    ExperienceLevel experienceLevel;
    if (avgScore >= 60) {
      experienceLevel = ExperienceLevel.intermediate;
    } else if (avgScore >= 40) {
      experienceLevel = ExperienceLevel.beginner;
    } else {
      experienceLevel = ExperienceLevel.beginner;
    }

    return {
      'skillLevels': skillLevels,
      'experienceLevel': experienceLevel,
      'initialAssessment': {
        'missedShotType': missedShotType,
        'cueBallBehavior': cueBallBehavior,
        'scratchFrequency': scratchFrequency,
      },
    };
  }
}
