import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';

class DrillResultScreen extends StatelessWidget {
  final String drillCode;
  final int totalReps;
  final int successCount;

  const DrillResultScreen({
    super.key,
    required this.drillCode,
    required this.totalReps,
    required this.successCount,
  });

  double get successRate => totalReps > 0 ? (successCount / totalReps) * 100 : 0;

  String get rating {
    if (successRate >= 90) return 'Xuất sắc!';
    if (successRate >= 70) return 'Tốt lắm!';
    if (successRate >= 50) return 'Cần cố gắng hơn';
    return 'Cần luyện tập thêm';
  }

  Color get ratingColor {
    if (successRate >= 90) return Colors.green;
    if (successRate >= 70) return Colors.blue;
    if (successRate >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final drill = DrillLibrary.getDrill(drillCode);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Trophy icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  successRate >= 70 ? Icons.emoji_events : Icons.fitness_center,
                  size: 64,
                  color: ratingColor,
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              // Rating
              Text(
                rating,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ratingColor,
                    ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),

              if (drill != null)
                Text(
                  drill.nameVi,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Tổng lần',
                      value: '$totalReps',
                      icon: Icons.repeat,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Thành công',
                      value: '$successCount',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              // Success rate
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ratingColor,
                      ratingColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${successRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Tỷ lệ thành công',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: successRate / 100,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              // Coach feedback placeholder
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: AppTheme.accentGold),
                        const SizedBox(width: 8),
                        Text(
                          'AI Coach gợi ý',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      successRate < 70
                          ? 'Bạn cần tập trung vào độ chính xác hơn. Hãy chú ý đến tư thế và cách cầm cơ.'
                          : 'Kỹ thuật của bạn đã khá tốt! Hãy tiếp tục luyện tập để duy trì và cải thiện.',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/training'),
                  icon: const Icon(Icons.home),
                  label: const Text('Về Training Center'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Re-do the same drill
                    context.go('/training/session/new?drill=$drillCode');
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Tập lại'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
