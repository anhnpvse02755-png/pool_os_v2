// ============================================================================
// CONTINUE SESSION CARD - Phase 7B.1
// Interrupted Journey - Coach remembers and asks to continue
//
// Principle: Coach Must Be Consistent
// - Coach remembers what was recommended
// - Asks to continue instead of changing recommendation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
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
                AppTheme.accentGold.withValues(alpha: 0.15),
                AppTheme.primaryGreen.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.4),
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
                      color: AppTheme.accentGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: AppTheme.accentGold,
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
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bạn đang tập dở ($progress%)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
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
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.white,
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.play_arrow, color: Colors.white),
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
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
