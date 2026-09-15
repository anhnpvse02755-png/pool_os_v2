// ============================================================================
// COACH EMPTY STATE - Phase 7B.1
// Silence when no data - Coach guides new user
//
// Coach Voice:
// - Coach leads, never asks
// - Short and clear
// - Actionable
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';


/// Coach Empty State - When user has no data
class CoachEmptyState extends StatelessWidget {
  final VoidCallback onStartDrill;
  final String? drillName;

  const CoachEmptyState({
    super.key,
    required this.onStartDrill,
    this.drillName = 'Straight Shot',
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Coach Empty State Card
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            children: [
              // Coach Avatar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology,
                  size: 48,
                  color: AppColors.primary(brightness),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 20),

              // Coach Voice Message
              Text(
                'Chào bạn mới!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              Text(
                'Mình chưa biết nhiều về bạn.\n'
                'Bắt đầu tập $drillName đi!\n'
                'Đây là bài tập cơ bản nhất.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary(brightness),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 8),

              Text(
                'Mình sẽ học về bạn từ đây.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary(brightness),
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onStartDrill,
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
                        'BẮT ĐẦU $drillName',
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
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // What will happen
        Container(
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
                'Sau vài buổi tập, bạn sẽ thấy:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary(brightness),
                    ),
              ),
              const SizedBox(height: 12),
              _buildWhatItem(
                context,
                Icons.route,
                'Lộ trình phù hợp với bạn',
              ),
              _buildWhatItem(
                context,
                Icons.trending_up,
                'Xu hướng tiến bộ',
              ),
              _buildWhatItem(
                context,
                Icons.lightbulb,
                'Gợi ý cá nhân hóa',
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildWhatItem(BuildContext context, IconData icon, String text) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary(brightness), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
