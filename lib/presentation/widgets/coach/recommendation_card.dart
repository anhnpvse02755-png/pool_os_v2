// ============================================================================
// RECOMMENDATION CARD - Phase 7B.1
// ONE Priority Card with Coach Voice
//
// Coach Voice:
// - Short (2-3 sentences)
// - Natural (no "dựa trên", "AI")
// - Positive (towards action)
// - Specific (situation, not numbers)
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/coach_voice_service.dart';
import '../logo/pool_cue_mark.dart';

/// Coach Recommendation - ONE Priority Card
/// This is the UI layer representation
class CoachRecommendation {
  final String drillCode;
  final String drillName;
  final String reason;
  final List<String> outcomes;  // Expected outcomes
  final int estimatedMinutes;
  final int confidence;
  final int priority; // 1 = highest priority

  CoachRecommendation({
    required this.drillCode,
    required this.drillName,
    required this.reason,
    required this.outcomes,
    required this.estimatedMinutes,
    required this.confidence,
    this.priority = 1,
  });

  /// Create from Brain layer CoachRecommendation
  factory CoachRecommendation.fromBrain({
    required String drillCode,
    required String drillName,
    required String reason,
    String? expectedOutcome,
    List<String>? outcomes,
    int estimatedMinutes = 10,
    int confidence = 50,
    int priority = 1,
  }) {
    return CoachRecommendation(
      drillCode: drillCode,
      drillName: drillName,
      reason: reason,
      outcomes: outcomes ?? (expectedOutcome != null ? [expectedOutcome] : ['Cải thiện kỹ năng']),
      estimatedMinutes: estimatedMinutes,
      confidence: confidence,
      priority: priority,
    );
  }

  /// Get priority label
  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'Ưu tiên #1';
      case 2:
        return 'Ưu tiên #2';
      case 3:
        return 'Ưu tiên #3';
      default:
        return 'Ưu tiên #$priority';
    }
  }

  /// Get confidence label
  String get confidenceLabel {
    if (confidence >= 80) return 'Rất chắc chắn';
    if (confidence >= 60) return 'Khá chắc chắn';
    if (confidence >= 40) return 'Bình thường';
    return 'Ít dữ liệu';
  }

  /// Get confidence color
  /// Nhận [brightness] thay vì là getter: `textTertiary` đổi theo chế độ,
  /// mà getter không có `BuildContext` để hỏi.
  Color confidenceColor(Brightness brightness) {
    if (confidence >= 80) return AppColors.success;
    if (confidence >= 60) return AppColors.primary(brightness);
    if (confidence >= 40) return AppColors.warning;
    return AppColors.textTertiary(brightness);
  }
}

/// Recommendation Card Widget
class RecommendationCard extends StatelessWidget {
  final CoachRecommendation recommendation;
  final CoachVoiceService coachVoice;
  final VoidCallback onStart;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.coachVoice,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card Header
        _buildHeader(context),
        const SizedBox(height: 16),

        // Coach Voice Reason
        _buildReason(context),
        const SizedBox(height: 16),

        // Expected Outcomes
        _buildOutcomes(context),
        const SizedBox(height: 20),

        // CTA - ONE Button
        _buildCTA(context),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary(brightness).withValues(alpha: 0.1),
            AppColors.gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary(brightness).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary(brightness).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: PoolCueMark(
              size: 28,
              color: AppColors.primary(brightness),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(brightness).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recommendation.priorityLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPriorityColor(brightness),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.drillName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${recommendation.estimatedMinutes} phút',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary(brightness),
                          ),
                    ),
                    const SizedBox(width: 12),
                    // Confidence indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: recommendation.confidenceColor(brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: recommendation.confidenceColor(brightness),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recommendation.confidence}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: recommendation.confidenceColor(brightness),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(Brightness brightness) {
    switch (recommendation.priority) {
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.primary(brightness);
      case 3:
        return AppColors.primaryDeep(brightness);
      default:
        return AppColors.textTertiary(brightness);
    }
  }

  Widget _buildReason(BuildContext context) {
    return Text(
      recommendation.reason,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildOutcomes(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nếu hoàn thành hôm nay:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary(brightness),
                ),
          ),
          const SizedBox(height: 12),
          ...recommendation.outcomes.map((outcome) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        outcome,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildCTA(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary(brightness),
          foregroundColor: AppColors.onPrimary(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BẮT ĐẦU',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary(brightness),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: AppColors.onPrimary(brightness)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}
