import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Empty State
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentGold.withValues(alpha: 0.1),
                    AppTheme.primaryGreen.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: 48,
                      color: AppTheme.accentGold,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    'Coach đang chờ dữ liệu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Để Coach AI đưa ra khuyến nghị chính xác,\nbạn cần ghi lại ít nhất 3-5 buổi chơi.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _DataProgress(
                          icon: Icons.pool,
                          label: 'Buổi chơi',
                          current: 0,
                          target: 5,
                        ),
                        const Divider(height: 24),
                        _DataProgress(
                          icon: Icons.sports,
                          label: 'Trận đấu',
                          current: 0,
                          target: 10,
                        ),
                        const Divider(height: 24),
                        _DataProgress(
                          icon: Icons.circle,
                          label: 'Cú đánh',
                          current: 0,
                          target: 50,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // What Coach Does
            Text(
              'Coach làm gì?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 12),
            _CoachFeatureCard(
              icon: Icons.analytics,
              title: 'Phân tích lối chơi',
              description: 'Tìm ra điểm mạnh, điểm yếu từ dữ liệu thực tế',
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            _CoachFeatureCard(
              icon: Icons.route,
              title: 'Lộ trình học cá nhân',
              description: 'Tạo kế hoạch luyện tập dựa trên trình độ của bạn',
            ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            _CoachFeatureCard(
              icon: Icons.lightbulb,
              title: 'Gợi ý thông minh',
              description: 'Đề xuất video, bài tập phù hợp với từng giai đoạn',
            ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 12),
            _CoachFeatureCard(
              icon: Icons.trending_up,
              title: 'Theo dõi tiến bộ',
              description: 'Đo lường sự tiến bộ qua thời gian với số liệu cụ thể',
            ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 32),

            // Getting Started Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Bắt đầu như thế nào?',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TipItem(number: '1', text: 'Bắt đầu một buổi chơi mới'),
                  _TipItem(number: '2', text: 'Ghi lại kết quả từng trận đấu'),
                  _TipItem(number: '3', text: 'Log các cú đánh quan trọng'),
                  _TipItem(number: '4', text: 'Xem Coach phân tích sau 3-5 buổi'),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _DataProgress extends StatelessWidget {
  final IconData icon;
  final String label;
  final int current;
  final int target;

  const _DataProgress({
    required this.icon,
    required this.label,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / target;

    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '$current / $target',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1 ? AppTheme.success : AppTheme.primaryGreen,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoachFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CoachFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String number;
  final String text;

  const _TipItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
