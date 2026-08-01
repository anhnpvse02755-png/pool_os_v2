import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pool_rating_calculator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, int> _answers = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
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
                children: List.generate(10, (index) {
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
                children: [
                  const WelcomePage(),
                  const LevelSystemIntroPage(),
                  const AssessmentIntroPage(),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[0], onAnswer: (v) => _answers[1] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[1], onAnswer: (v) => _answers[2] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[2], onAnswer: (v) => _answers[3] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[3], onAnswer: (v) => _answers[4] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[4], onAnswer: (v) => _answers[5] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[5], onAnswer: (v) => _answers[6] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[6], onAnswer: (v) => _answers[7] = v),
                  _AssessmentQuestionPage(question: AppConstants.assessmentQuestions[7], onAnswer: (v) => _answers[8] = v),
                  ResultPage(answers: _answers),
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
                      child: Text(_currentPage < 9 ? 'Tiếp tục' : 'Bắt đầu'),
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
            'Trước khi bắt đầu, hãy để PoolOS hiểu về kỹ năng của bạn.',
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

class LevelSystemIntroPage extends StatelessWidget {
  const LevelSystemIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hệ thống xếp hạng PoolOS',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: 16),

          // Intro text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppTheme.accentGold),
                    const SizedBox(width: 8),
                    Text(
                      'Về hệ thống xếp hạng',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hệ thống xếp hạng trong PoolOS được xây dựng dựa trên cách phân hạng phổ biến của cộng đồng Pool Hà Nội.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Do mỗi địa phương hoặc câu lạc bộ có thể sử dụng cách gọi khác nhau, PoolOS sử dụng hệ thống dưới đây để giúp người chơi dễ trao đổi và thống nhất khi tham gia các hoạt động trong ứng dụng.',
                  style: TextStyle(height: 1.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Amateur section
          _LevelCategory(
            title: 'Người chơi phong trào',
            levels: ['K', 'I', 'H', 'G'],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Competitive section
          _LevelCategory(
            title: 'Người chơi thi đấu',
            levels: ['F', 'E', 'D', 'C', 'B', 'A'],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // Professional
          _LevelCategory(
            title: 'Chuyên nghiệp',
            levels: ['pro'],
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),

          // Auto suggestion note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PoolOS sẽ tự động đề xuất hạng dựa trên bài đánh giá và kết quả thi đấu thực tế.',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 24),

          // New player note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chưa từng chơi? PoolOS sẽ bắt đầu đánh giá từ mức K và tự động điều chỉnh khi bạn sử dụng ứng dụng.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _LevelCategory extends StatelessWidget {
  final String title;
  final List<String> levels;

  const _LevelCategory({
    required this.title,
    required this.levels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(levels.length, (index) {
              final level = AppConstants.playerLevels[levels[index]]!;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : Colors.grey.shade50,
                  borderRadius: index == 0 && index == levels.length - 1
                      ? BorderRadius.circular(12)
                      : index == 0
                          ? const BorderRadius.vertical(top: Radius.circular(12))
                          : index == levels.length - 1
                              ? const BorderRadius.vertical(bottom: Radius.circular(12))
                              : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          level.code == 'pro' ? 'PRO' : level.code,
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: level.code == 'pro' ? 10 : 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        level.description,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class AssessmentIntroPage extends StatelessWidget {
  const AssessmentIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 32),
          Text(
            'Bài đánh giá kỹ năng',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            '8 câu hỏi để hiểu về trình độ của bạn',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.accentGold),
                    const SizedBox(width: 8),
                    Text(
                      'Triết lý của PoolOS',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'PoolOS không hỏi bạn "hạng gì?" một cách chủ quan. Thay vào đó, PoolOS thu thập năng lực thực tế của bạn và tính Pool Rating một cách khách quan.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hạng của bạn sẽ được điều chỉnh tự động khi có đủ dữ liệu từ các buổi chơi thực tế.',
                  style: TextStyle(
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          Text(
            'Hãy trả lời dựa trên khả năng thực tế của bạn nhé!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _AssessmentQuestionPage extends StatefulWidget {
  final AssessmentQuestion question;
  final ValueChanged<int> onAnswer;

  const _AssessmentQuestionPage({
    required this.question,
    required this.onAnswer,
  });

  @override
  State<_AssessmentQuestionPage> createState() => _AssessmentQuestionPageState();
}

class _AssessmentQuestionPageState extends State<_AssessmentQuestionPage> {
  int? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Câu ${widget.question.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.question.isImportant) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'Quan trọng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 20),

          // Question title
          Text(
            widget.question.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            widget.question.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 24),

          // Options
          ...List.generate(widget.question.options.length, (index) {
            final option = widget.question.options[index];
            final isSelected = _selectedValue == option.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedValue = option.value);
                  widget.onAnswer(option.value);
                },
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
                        child: Text(
                          option.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (200 + index * 50).ms)
                  .slideX(begin: 0.05, end: 0, delay: (200 + index * 50).ms),
            );
          }),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final Map<int, int> answers;

  const ResultPage({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    // Calculate initial rating
    final rating = PoolRatingCalculator.calculateFromAssessment(answers);
    final level = PoolRatingCalculator.getLevelFromRating(rating);
    final levelInfo = PoolRatingCalculator.getLevelInfo(level);

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
              Icons.check_circle,
              size: 48,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 24),
          Text(
            'Đánh giá hoàn tất!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Main text with highlighted "hạng khởi tạo"
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

          // Level display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryGreen, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                if (levelInfo != null)
                  Text(
                    levelInfo.description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pool Rating: $rating',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0, delay: 400.ms),

          const SizedBox(height: 24),

          // Info box
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
                  'Hạng khởi tạo là hạng đánh giá sơ bộ dựa trên câu trả lời của bạn, không hoàn toàn chính xác với trình độ thực tế.',
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 18, color: AppTheme.primaryGreen),
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
