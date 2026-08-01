import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding -> Home
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryGreen
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  WelcomePage(),
                  BenefitsPage(),
                  LevelSystemPage(),
                  AssessmentPage1(),
                  AssessmentPage2(),
                  ResultPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: const Text('Quay lại'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(_currentPage < 5 ? 'Tiếp tục' : 'Bắt đầu'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.waving_hand,
            size: 80,
            color: AppTheme.accentGold,
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 32),
          Text(
            'Chào mừng đến với PoolOS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Trước khi bắt đầu, hãy để PoolOS hiểu bạn.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Mất khoảng 2-3 phút',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class BenefitsPage extends StatelessWidget {
  const BenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      'Xác định trình độ hiện tại của bạn',
      'Tạo giáo trình học riêng phù hợp với bạn',
      'AI phân tích lối chơi và đưa ra gợi ý cải thiện',
      'Theo dõi tiến bộ qua từng trận đấu',
      'Đề xuất video và bài tập phù hợp trình độ',
      'Luyện tập mỗi ngày với kế hoạch rõ ràng',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Bạn sẽ nhận được gì?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: benefits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        benefits[index],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideX(begin: 0.2, end: 0, delay: (100 * index).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LevelSystemPage extends StatelessWidget {
  const LevelSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Hệ thống xếp hạng',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'PoolOS sử dụng hệ thống cấp bậc để đánh giá trình độ của bạn',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: AppConstants.playerLevels.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final level = AppConstants.playerLevels.keys.toList()[index];
                final label = AppConstants.playerLevels[level]!;
                final isCurrentLevel = index == 0; // Beginner is default

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentLevel
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade300,
                    child: Text(
                      level[0].toUpperCase(),
                      style: TextStyle(
                        color: isCurrentLevel ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    label,
                    style: TextStyle(
                      fontWeight:
                          isCurrentLevel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isCurrentLevel
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Bạn ở đây',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : const Icon(Icons.arrow_forward, size: 16),
                )
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideX(begin: 0.1, end: 0, delay: (100 * index).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AssessmentPage1 extends StatefulWidget {
  const AssessmentPage1({super.key});

  @override
  State<AssessmentPage1> createState() => _AssessmentPage1State();
}

class _AssessmentPage1State extends State<AssessmentPage1> {
  int? _selectedYears;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn chơi bi-a bao lâu rồi?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildOption(
                  'Chưa từng chơi',
                  'Tôi muốn bắt đầu từ đầu',
                  isSelected: _selectedYears == 0,
                  onTap: () => setState(() => _selectedYears = 0),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  'Dưới 1 năm',
                  'Mới tập chơi, đang học hỏi',
                  isSelected: _selectedYears == 1,
                  onTap: () => setState(() => _selectedYears = 1),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  '1-3 năm',
                  'Đã biết cách chơi cơ bản',
                  isSelected: _selectedYears == 2,
                  onTap: () => setState(() => _selectedYears = 2),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  'Hơn 3 năm',
                  'Chơi thường xuyên',
                  isSelected: _selectedYears == 3,
                  onTap: () => setState(() => _selectedYears = 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, String subtitle,
      {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0, delay: 200.ms);
  }
}

class AssessmentPage2 extends StatefulWidget {
  const AssessmentPage2({super.key});

  @override
  State<AssessmentPage2> createState() => _AssessmentPage2State();
}

class _AssessmentPage2State extends State<AssessmentPage2> {
  int? _selectedHours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn chơi bao nhiêu giờ mỗi tuần?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildOption(
                  'Ít hơn 1 giờ',
                  'Chơi thỉnh thoảng cho vui',
                  isSelected: _selectedHours == 0,
                  onTap: () => setState(() => _selectedHours = 0),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  '1-5 giờ',
                  'Chơi đều đặn mỗi tuần',
                  isSelected: _selectedHours == 1,
                  onTap: () => setState(() => _selectedHours = 1),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  '5-10 giờ',
                  'Chơi khá thường xuyên',
                  isSelected: _selectedHours == 2,
                  onTap: () => setState(() => _selectedHours = 2),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  'Hơn 10 giờ',
                  'Bi-a là đam mê lớn',
                  isSelected: _selectedHours == 3,
                  onTap: () => setState(() => _selectedHours = 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, String subtitle,
      {required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0, delay: 200.ms);
  }
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 56,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 32),
          Text(
            'Xác định xong!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Dựa trên câu trả lời của bạn, PoolOS xác định bạn đang ở cấp độ:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryGreen, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'K',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  'Người mới tập chơi',
                  style: TextStyle(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 400.ms),
          const SizedBox(height: 24),
          Text(
            'PoolOS sẽ tạo lộ trình học riêng cho bạn dựa trên trình độ này.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
