// ============================================================================
// COACH ENTRY SURVEY SCREEN - Phase 7B.5
// Initial assessment survey for Coach AI
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
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
  // Survey answers
  int? _missedShotType; // 0: far, 1: angle, 2: draw/follow, 3: bank/kick, 4: unclear
  int? _cueBallBehavior; // 0: over, 1: under, 2: off-angle, 3: controlled
  int? _scratchFrequency; // 0: often, 1: sometimes, 2: rarely, 3: never

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khám phá điểm mạnh/yếu'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skipSurvey,
            child: const Text('Bỏ qua'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Survey content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question 1
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
                    const SizedBox(height: 32),

                    // Question 2
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
                    const SizedBox(height: 32),

                    // Question 3
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

            // Submit button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submitSurvey : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: answeredCount / 3,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$answeredCount/3',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OptionTile(
              title: options[index],
              isSelected: isSelected,
              onTap: () => onSelected(index),
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
      // Create survey answers
      final answers = CoachSurveyAnswers(
        missedShotType: _missedShotType!,
        cueBallBehavior: _cueBallBehavior!,
        scratchFrequency: _scratchFrequency!,
        completedAt: DateTime.now(),
      );

      // Save to storage
      await _saveSurveyAnswers(answers);

      // Update provider with survey data
      ref.read(coachSurveyProvider.notifier).setSurveyCompleted(true);
      ref.read(coachSurveyProvider.notifier).setSurveyAnswers(answers);

      // Navigate to Coach Home
      if (mounted) {
        context.go('/coach');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
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
    // Just mark survey as skipped and go to Coach Home
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

class _OptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
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
                    color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryGreen : Colors.black87,
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
  final int missedShotType; // 0: far, 1: angle, 2: draw/follow, 3: bank/kick, 4: unclear
  final int cueBallBehavior; // 0: over, 1: under, 2: off-angle, 3: controlled
  final int scratchFrequency; // 0: often, 1: sometimes, 2: rarely, 3: never
  final DateTime completedAt;

  const CoachSurveyAnswers({
    required this.missedShotType,
    required this.cueBallBehavior,
    required this.scratchFrequency,
    required this.completedAt,
  });

  /// Convert to PlayerIntelligence initial data
  Map<String, dynamic> toPlayerIntelligenceData() {
    // Determine initial skill levels based on survey answers
    final skillLevels = <String, int>{};

    // Cue ball control assessment
    if (cueBallBehavior <= 2) {
      skillLevels['cueball_control'] = 30; // Lower if having issues
    } else {
      skillLevels['cueball_control'] = 50;
    }

    // Position play assessment based on cue ball behavior
    if (cueBallBehavior == 0) {
      // Over-running - needs position play work
      skillLevels['position_play'] = 25;
      skillLevels['spin_control'] = 35;
    } else if (cueBallBehavior == 1) {
      // Under-running
      skillLevels['position_play'] = 30;
      skillLevels['spin_control'] = 40;
    } else if (cueBallBehavior == 2) {
      // Off-angle
      skillLevels['position_play'] = 35;
      skillLevels['aiming'] = 40;
    } else {
      // Controlled
      skillLevels['position_play'] = 55;
      skillLevels['spin_control'] = 55;
    }

    // Scratch tendency
    if (scratchFrequency == 0) {
      // Often scratch
      skillLevels['safety_play'] = 25;
      skillLevels['shot_selection'] = 35;
    } else if (scratchFrequency == 1) {
      // Sometimes
      skillLevels['safety_play'] = 40;
      skillLevels['shot_selection'] = 45;
    } else {
      // Rarely/never
      skillLevels['safety_play'] = 55;
      skillLevels['shot_selection'] = 60;
    }

    // Shot type weaknesses
    switch (missedShotType) {
      case 0:
        // Far shots - power control issue
        skillLevels['power_control'] = 30;
        skillLevels['long_shots'] = 25;
        break;
      case 1:
        // Angle shots - aiming issue
        skillLevels['aiming'] = 35;
        skillLevels['english_usage'] = 40;
        break;
      case 2:
        // Draw/follow - spin control issue
        skillLevels['spin_control'] = 30;
        skillLevels['draw_shots'] = 25;
        skillLevels['follow_shots'] = 30;
        break;
      case 3:
        // Bank/kick - advanced skills
        skillLevels['bank_shots'] = 25;
        skillLevels['kick_shots'] = 25;
        break;
      default:
        // Unclear - general assessment needed
        break;
    }

    // Determine initial experience level
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
