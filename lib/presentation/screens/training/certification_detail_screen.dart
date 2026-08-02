import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/certification.dart';

class CertificationDetailScreen extends StatelessWidget {
  final String certificationId;

  const CertificationDetailScreen({super.key, required this.certificationId});

  @override
  Widget build(BuildContext context) {
    final certification = CertificationLibrary.getCertification(certificationId);

    if (certification == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy certification')),
      );
    }

    final color = _getCategoryColor(certification.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(certification.nameVi),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certification.nameVi,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    certification.description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.quiz, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '${certification.tests.length} bài kiểm tra',
                        style: TextStyle(color: color, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Tests list
            Text(
              'Các bài kiểm tra',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            ...certification.tests.asMap().entries.map((entry) {
              final index = entry.key;
              final test = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TestCard(
                  test: test,
                  index: index + 1,
                  onStart: () {
                    context.push(
                      '/training/test/${certification.id}/${test.id}',
                    );
                  },
                ).animate().fadeIn(delay: (index * 100).ms),
              );
            }),

            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Certification chỉ dùng để đo kỹ năng và theo dõi tiến bộ. '
                      'Không dùng để mở khóa Drill hay xác nhận hoàn thành Level.',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'cueball':
        return Colors.blue;
      case 'potting':
        return Colors.orange;
      case 'position':
        return Colors.purple;
      case 'safety':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _TestCard extends StatelessWidget {
  final CertificationTest test;
  final int index;
  final VoidCallback onStart;

  const _TestCard({
    required this.test,
    required this.index,
    required this.onStart,
  });

  Color _getDifficultyColor() {
    switch (test.difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.titleVi,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            test.difficulty.toUpperCase(),
                            style: TextStyle(
                              color: _getDifficultyColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${test.requiredSuccesses}/${test.totalAttempts} để pass',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            test.instructions,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Bắt đầu kiểm tra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
