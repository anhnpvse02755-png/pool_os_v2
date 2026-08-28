import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/pool_rating_calculator.dart';
import '../../../core/providers/repository_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, int> _answers = {};
  bool _isCreatingPlayer = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboardingAndNavigate() async {
    if (_isCreatingPlayer) return;

    setState(() {
      _isCreatingPlayer = true;
    });

    try {
      // Step 1: Calculate rating from assessment answers
      final rating = PoolRatingCalculator.calculateFromAssessment(_answers);
      final level = PoolRatingCalculator.getLevelFromRating(rating);

      // Step 2: Get years playing from Q1 answer
      final yearsAnswer = _answers[1] ?? 0;
      int yearsPlaying;
      if (yearsAnswer == 0) {
        yearsPlaying = 0;
      } else if (yearsAnswer == 1 || yearsAnswer == 2) {
        yearsPlaying = 0;
      } else if (yearsAnswer == 3 || yearsAnswer == 4) {
        yearsPlaying = 1;
      } else if (yearsAnswer == 5) {
        yearsPlaying = 3;
      } else {
        yearsPlaying = 6;
      }

      // Step 3: Get hours per week from Q2 answer
      final hoursAnswer = _answers[2] ?? 1;
      double hoursPerWeek;
      switch (hoursAnswer) {
        case 1:
          hoursPerWeek = 1.0;
          break;
        case 2:
          hoursPerWeek = 3.5;
          break;
        case 3:
          hoursPerWeek = 7.5;
          break;
        case 4:
          hoursPerWeek = 15.0;
          break;
        default:
          hoursPerWeek = 25.0;
      }

      // Step 4: Create player with onboarding data
      final playerRepo = ref.read(playerRepositoryProvider);
      await playerRepo.createPlayer(
        name: 'Player ${DateTime.now().millisecondsSinceEpoch % 10000}',
        currentLevel: level,
        yearsPlaying: yearsPlaying,
        hoursPerWeek: hoursPerWeek,
      );

      // Step 5: Mark onboarding as completed
      await playerRepo.completeOnboarding();

      // Step 6: Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isCreatingPlayer = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboardingAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: List.generate(10, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.accent
                            : AppColors.lightBorder,
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
                  const _WelcomePage(),
                  const _LevelSystemIntroPage(),
                  const _AssessmentIntroPage(),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[0],
                    onAnswer: (v) => _answers[1] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[1],
                    onAnswer: (v) => _answers[2] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[2],
                    onAnswer: (v) => _answers[3] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[3],
                    onAnswer: (v) => _answers[4] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[4],
                    onAnswer: (v) => _answers[5] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[5],
                    onAnswer: (v) => _answers[6] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[6],
                    onAnswer: (v) => _answers[7] = v,
                  ),
                  _AssessmentQuestionPage(
                    question: AppConstants.assessmentQuestions[7],
                    onAnswer: (v) => _answers[8] = v,
                  ),
                  _ResultPage(answers: _answers),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.lightTextPrimary,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          side: BorderSide(color: AppColors.lightBorder),
                        ),
                        child: const Text('Quay lại'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: _currentPage > 0 ? 1 : 2,
                    child: _PrimaryButton(
                      onPressed: _isCreatingPlayer ? null : _nextPage,
                      label: _currentPage < 9 ? 'Tiếp tục' : 'Bắt đầu',
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

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentSubtleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.waving_hand, size: 40, color: AppColors.gold),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Chào mừng đến với PoolOS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Trước khi bắt đầu, hãy để PoolOS hiểu về kỹ năng của bạn.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSubtleLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: AppColors.accent, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Mất khoảng 2-3 phút',
                  style: TextStyle(
                    color: AppColors.accent,
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

class _LevelSystemIntroPage extends StatelessWidget {
  const _LevelSystemIntroPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hệ thống xếp hạng PoolOS',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(),
          const SizedBox(height: AppSpacing.md),

          // Intro card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.gold),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Về hệ thống xếp hạng',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Hệ thống xếp hạng trong PoolOS được xây dựng dựa trên cách phân hạng phổ biến của cộng đồng Pool Hà Nội.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: AppSpacing.lg),

          // Amateur section
          _LevelCategory(
            title: 'Người chơi phong trào',
            levels: ['K', 'I', 'H', 'G'],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: AppSpacing.md),

          // Competitive section
          _LevelCategory(
            title: 'Người chơi thi đấu',
            levels: ['F', 'E', 'D', 'C', 'B', 'A'],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.md),

          // Professional
          _LevelCategory(
            title: 'Chuyên nghiệp',
            levels: ['pro'],
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: AppSpacing.lg),

          // Auto suggestion note
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentSubtleLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'PoolOS sẽ tự động đề xuất hạng dựa trên bài đánh giá.',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
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
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            children: List.generate(levels.length, (index) {
              final level = AppConstants.playerLevels[levels[index]]!;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: index.isEven ? AppColors.lightSurface : AppColors.lightBackground,
                  borderRadius: index == levels.length - 1
                      ? BorderRadius.only(
                          bottomLeft: Radius.circular(AppSpacing.radiusMd),
                          bottomRight: Radius.circular(AppSpacing.radiusMd),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.accentSubtleLight,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Center(
                        child: Text(
                          level.code == 'pro' ? 'PRO' : level.code,
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: level.code == 'pro' ? 10 : 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        level.description,
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
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

class _AssessmentIntroPage extends StatelessWidget {
  const _AssessmentIntroPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accentSubtleLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, size: 56, color: AppColors.accent),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Bài đánh giá kỹ năng',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '8 câu hỏi để hiểu về trình độ của bạn',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Triết lý của PoolOS',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'PoolOS không hỏi bạn "hạng gì?" một cách chủ quan. Thay vào đó, PoolOS thu thập năng lực thực tế của bạn và tính Pool Rating một cách khách quan.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Hãy trả lời dựa trên khả năng thực tế của bạn nhé!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accent,
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Text(
                  'Câu ${widget.question.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (widget.question.isImportant) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
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
          const SizedBox(height: AppSpacing.lg),

          // Question title
          Text(
            widget.question.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.xs),

          // Subtitle
          Text(
            widget.question.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: AppSpacing.lg),

          // Options
          ...List.generate(widget.question.options.length, (index) {
            final option = widget.question.options[index];
            final isSelected = _selectedValue == option.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionCard(
                label: option.label,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedValue = option.value);
                  widget.onAnswer(option.value);
                },
              ).animate().fadeIn(delay: (200 + index * 50).ms),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.lightBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: isSelected ? AppColors.accentSubtleLight : AppColors.lightSurface,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.lightTextTertiary,
                  width: 2,
                ),
                color: isSelected ? AppColors.accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: isSelected ? AppColors.accent : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPage extends StatelessWidget {
  final Map<int, int> answers;

  const _ResultPage({required this.answers});

  @override
  Widget build(BuildContext context) {
    final rating = PoolRatingCalculator.calculateFromAssessment(answers);
    final level = PoolRatingCalculator.getLevelFromRating(rating);
    final levelInfo = PoolRatingCalculator.getLevelInfo(level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 48, color: Colors.white),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fadeIn(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Đánh giá hoàn tất!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Dựa trên câu trả lời của bạn, PoolOS xác định hạng khởi tạo của bạn đang ở cấp độ:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.lg),

          // Level display
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSubtleLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                if (levelInfo != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    levelInfo.description,
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'Pool Rating: $rating',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: AppSpacing.lg),

          // Info box
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.gold),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Hạng khởi tạo là gì?',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Hạng khởi tạo là hạng đánh giá sơ bộ dựa trên câu trả lời của bạn. Sau khi PoolOS ghi nhận đủ dữ liệu, hệ thống sẽ tự động đánh giá chính xác lại hạng của bạn.',
                  style: TextStyle(color: AppColors.lightTextPrimary, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'PoolOS sẽ tạo lộ trình học riêng phù hợp với bạn.',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
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
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _PrimaryButton({
    required this.onPressed,
    required this.label,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
