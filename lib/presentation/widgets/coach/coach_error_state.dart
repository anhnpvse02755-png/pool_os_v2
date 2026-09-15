// ============================================================================
// COACH ERROR STATE - Phase 7B.1
// Graceful degradation when Coach is unavailable
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';


/// Coach Error State - When Coach is unavailable
class CoachErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? error;

  const CoachErrorState({
    super.key,
    required this.onRetry,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.errorSubtle(brightness),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: AppColors.errorOnTint(brightness),
                ),
              ).animate().scale(duration: 400.ms),

              const SizedBox(height: 24),

              // Error message
              Text(
                'Coach đang bận',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              Text(
                'Xin lỗi nhé. Có chút vấn đề kết nối.\n'
                'Thử lại sau được không?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(brightness),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              // Retry button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(brightness),
                    foregroundColor: AppColors.onPrimary(brightness),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh),
                      const SizedBox(width: 8),
                      Text(
                        'THỬ LẠI',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.onPrimary(brightness),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              // Alternative action
              TextButton(
                onPressed: () {
                  // Navigate to training center
                },
                child: Text(
                  'Hoặc bắt đầu tập ngay',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(brightness),
                      ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
