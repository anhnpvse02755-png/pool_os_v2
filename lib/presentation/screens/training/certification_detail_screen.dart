import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/models/certification.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

/// Ô pastel của một danh mục certification.
///
/// Giữ ĐỒNG BỘ với `_toneForCategory` trong `certification_list_screen.dart`:
/// cùng một danh mục phải ra cùng một tông ở cả màn danh sách lẫn màn chi tiết,
/// nếu không người dùng vừa học được màu ở màn trước thì màn sau đã đổi.
///
/// Khoá theo ID danh mục chứ KHÔNG theo vị trí trong danh sách.
int _toneForCategory(String category) {
  switch (category) {
    case 'cueball':
      return 1; // xanh dương
    case 'potting':
      return 2; // đào
    case 'position':
      return 3; // tử đinh hương
    case 'safety':
      return 0; // bạc hà
    default:
      return 4; // bơ
  }
}

class CertificationDetailScreen extends StatelessWidget {
  final String certificationId;

  const CertificationDetailScreen({super.key, required this.certificationId});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final certification = CertificationLibrary.getCertification(certificationId);

    if (certification == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy certification')),
      );
    }

    final tone = _toneForCategory(certification.category);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: Text(certification.nameVi),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
      ),
      body: SoftBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              //
              // Nền là ô pastel ĐẶC của danh mục chứ không còn `color@0.1` của
              // một hằng Material: năm danh mục vượt quá bốn hue tách bạch của
              // hệ nên cả bộ đã chuyển sang bảng pastel. Chữ dùng token CHỮ chứ
              // không dùng tông danh mục — đúng hợp đồng mà `IconTile` đang
              // theo, và `design_tokens_test.dart` đã khoá sẵn `textPrimary`
              // >= 4.5:1 trên cả năm ô ở cả hai chế độ.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(tone, brightness),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border(brightness)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certification.nameVi,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      certification.description,
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Số bài kiểm tra là một PHÉP ĐẾM, không phải kết quả — nó
                    // không mang nghĩa màu, nên để token chữ thay vì tô theo
                    // tông danh mục.
                    Row(
                      children: [
                        Icon(Icons.quiz,
                            size: 16,
                            color: AppColors.textSecondary(brightness)),
                        const SizedBox(width: 4),
                        Text(
                          '${certification.tests.length} bài kiểm tra',
                          style: TextStyle(
                            color: AppColors.textSecondary(brightness),
                            fontWeight: FontWeight.w500,
                          ),
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
                      color: AppColors.textPrimary(brightness),
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
              //
              // Hộp hổ phách cũ (`amber.shade50` / `200` / `700` / `900`) về
              // đúng họ `warning` của hệ. Chữ 12px đổi sang `textPrimary` —
              // 12.90:1 ở chế độ sáng, 7.94:1 ở chế độ tối; bản `amber.shade900`
              // trên `amber.shade50` cũ không đạt sàn 4.5:1.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtle(brightness),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Certification chỉ dùng để đo kỹ năng và theo dõi tiến bộ. '
                        'Không dùng để mở khóa Drill hay xác nhận hoàn thành Level.',
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
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
      ),
    );
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

  /// Thang độ khó của bài kiểm tra.
  ///
  /// Dùng ĐÚNG thang mà `drill_detail_screen._getDifficultyColor` đã dùng
  /// (easy=success, medium=warning, hard=error, còn lại = token chữ) để một
  /// mức độ khó không đổi màu giữa hai màn. Ba hue cách nhau 38° / 160°, không
  /// có cặp nào rơi vào cùng dải.
  Color _getDifficultyColor(Brightness brightness) {
    switch (test.difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary(brightness);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final difficultyTone = _getDifficultyColor(brightness);

    return PoolCard(
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRecessed(brightness),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary(brightness),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary(brightness),
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
                            color:
                                difficultyTone.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            test.difficulty.toUpperCase(),
                            style: TextStyle(
                              color: difficultyTone,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tỉ lệ để pass là một phép ĐẾM — token chữ, không tô
                        // theo tông độ khó.
                        Text(
                          '${test.requiredSuccesses}/${test.totalAttempts} để pass',
                          style: TextStyle(
                            color: AppColors.textSecondary(brightness),
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
              color: AppColors.textSecondary(brightness),
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
                backgroundColor: AppColors.primary(brightness),
                foregroundColor: AppColors.onPrimary(brightness),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
