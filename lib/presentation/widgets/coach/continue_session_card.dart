// ============================================================================
// CONTINUE SESSION CARD - Phase 7B.1
// Interrupted Journey - Coach remembers and asks to continue
//
// Principle: Coach Must Be Consistent
// - Coach remembers what was recommended
// - Asks to continue instead of changing recommendation
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/coach_voice_service.dart';

/// Continue Session Card - When user has an interrupted session
class ContinueSessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final CoachVoiceService coachVoice;
  final VoidCallback onContinue;
  final VoidCallback onStartNew;

  const ContinueSessionCard({
    super.key,
    required this.session,
    required this.coachVoice,
    required this.onContinue,
    required this.onStartNew,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final drillName = session['drillName'] ?? 'bài tập';
    final progress = session['progress'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Continue Session Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.15),
                AppColors.primary(brightness).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TIẾP TỤC $drillName?',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bạn đang tập dở ($progress%)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary(brightness),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Coach Voice Message
              Text(
                'Còn dở $drillName đấy.\nTiếp tục nhé?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.onGold(brightness),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TIẾP TỤC',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.onGold(brightness),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.play_arrow, color: AppColors.onGold(brightness)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        // Or Start New
        Center(
          child: TextButton(
            onPressed: onStartNew,
            child: Text(
              'Hoặc bắt đầu bài mới',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(brightness),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
