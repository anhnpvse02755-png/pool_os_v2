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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hệ thống xếp hạng',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tham khảo theo chuẩn xếp hạng của Hà Nội. Mỗi nơi có thể có định nghĩa khác nhau.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),

          // Amateur Section
          _LevelCategoryHeader(
            title: 'Nghiệp dư',
            subtitle: 'Người mới đến người chơi phong trào',
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 8),
          _LevelItem(
            level: AppConstants.playerLevels['beginner']!,
            showBadge: false,
          ).animate().fadeIn(delay: 200.ms),
          _LevelItem(
            level: AppConstants.playerLevels['K']!,
            showBadge: true,
          ).animate().fadeIn(delay: 250.ms),
          _LevelItem(
            level: AppConstants.playerLevels['I']!,
            showBadge: false,
          ).animate().fadeIn(delay: 300.ms),
          _LevelItem(
            level: AppConstants.playerLevels['H']!,
            showBadge: false,
          ).animate().fadeIn(delay: 350.ms),
          _LevelItem(
            level: AppConstants.playerLevels['G']!,
            showBadge: false,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Competitive Section
          _LevelCategoryHeader(
            title: 'Phong trào → Chuyên nghiệp',
            subtitle: 'Bước vào sân chơi chuyên nghiệp',
          ).animate().fadeIn(delay: 450.ms),
          const SizedBox(height: 8),
          _LevelItem(
            level: AppConstants.playerLevels['F']!,
            showBadge: false,
          ).animate().fadeIn(delay: 500.ms),
          _LevelItem(
            level: AppConstants.playerLevels['E']!,
            showBadge: false,
          ).animate().fadeIn(delay: 550.ms),
          _LevelItem(
            level: AppConstants.playerLevels['D']!,
            showBadge: false,
          ).animate().fadeIn(delay: 600.ms),
          _LevelItem(
            level: AppConstants.playerLevels['C']!,
            showBadge: false,
          ).animate().fadeIn(delay: 650.ms),
          _LevelItem(
            level: AppConstants.playerLevels['B']!,
            showBadge: false,
          ).animate().fadeIn(delay: 700.ms),
          _LevelItem(
            level: AppConstants.playerLevels['A']!,
            showBadge: false,
          ).animate().fadeIn(delay: 750.ms),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Professional
          _LevelCategoryHeader(
            title: 'Chuyên nghiệp',
            subtitle: 'Cao thủ, thi đấu quốc tế',
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 8),
          _LevelItem(
            level: AppConstants.playerLevels['pro']!,
            showBadge: false,
          ).animate().fadeIn(delay: 850.ms),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Khi bạn đạt G, hệ thống sẽ gợi ý bạn đánh giá lại để xác định F hoặc cao hơn.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 900.ms),
        ],
      ),
    );
  }
}

class _LevelCategoryHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LevelCategoryHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelItem extends StatelessWidget {
  final PlayerLevel level;
  final bool showBadge;

  const _LevelItem({
    required this.level,
    required this.showBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                level.code == 'beginner' ? '?' : level.code,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: level.code == 'pro' ? 10 : 16,
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
                  level.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  level.description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Mặc định',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 40,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 24),
          Text(
            'Xác định xong!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
              children: [
                const TextSpan(text: 'Dựa trên câu trả lời của bạn, PoolOS xác định '),
                TextSpan(
                  text: 'hạng khởi tạo',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryGreen,
                  ),
                ),
                const TextSpan(text: ' của bạn đang ở cấp độ:'),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppTheme.accentGold),
                    const SizedBox(width: 8),
                    Text(
                      'Hạng khởi tạo là gì?',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hạng khởi tạo là hạng đánh giá sơ bộ, không hoàn toàn chính xác với trình độ thực tế của bạn.',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sau khi PoolOS ghi nhận đủ dữ liệu (số lượng rack đấu hoặc kết quả bài tập), hệ thống sẽ tự động đánh giá chính xác lại hạng của bạn.',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.checklist, size: 18, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PoolOS sẽ tạo lộ trình học riêng phù hợp với bạn.',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.1, end: 0, delay: 500.ms),
        ],
      ),
    );
  }
}
