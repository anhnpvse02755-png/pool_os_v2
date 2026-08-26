// ============================================================================
// COACH ONBOARDING SCREEN - Phase 7B.4
// 3 screens introducing Coach AI
// Redesigned with Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../training/drill_detail_screen.dart';

/// Coach Onboarding Screen - 3 screens
class CoachOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CoachOnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<CoachOnboardingScreen> createState() => _CoachOnboardingScreenState();
}

class _CoachOnboardingScreenState extends State<CoachOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  late Brightness _brightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightness = Theme.of(context).brightness;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final _pages = [
    _OnboardingPage(
      icon: Icons.psychology,
      title: 'Chào bạn!',
      subtitle: 'Mình là Coach của Pool OS',
      description:
          'Mình sẽ giúp bạn cải thiện kỹ năng billiard thông qua '
          'dữ liệu thực tế từ mỗi buổi tập.',
    ),
    _OnboardingPage(
      icon: Icons.tips_and_updates,
      title: 'Mình thông minh',
      subtitle: 'Biết bạn đang ở đâu',
      description:
          'Mình phân tích cách bạn chơi và đưa ra kế hoạch '
          'phù hợp với trình độ hiện tại.',
    ),
    _OnboardingPage(
      icon: Icons.trending_up,
      title: 'Mình nhớ bạn',
      subtitle: 'Theo dõi tiến bộ',
      description:
          'Mình ghi nhớ từng buổi tập, từng trận đấu. '
          'Bạn sẽ thấy mình luôn đồng hành.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(_brightness),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'Bỏ qua',
                  style: TextStyle(color: AppColors.textSecondary(_brightness)),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),

            _buildPageIndicator(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: _buildButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.accentColor(_brightness)
                : AppColors.textTertiary(_brightness),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    final accentColor = AppColors.accentColor(_brightness);

    if (_currentPage == _pages.length - 1) {
      return _OnboardingButton(
        onPressed: widget.onComplete,
        label: 'BẮT ĐẦU',
        icon: Icons.arrow_forward,
        brightness: _brightness,
      );
    }

    return _OnboardingButton(
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      label: 'TIẾP TỤC',
      icon: Icons.arrow_forward,
      brightness: _brightness,
    );
  }
}

class _OnboardingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Brightness brightness;

  const _OnboardingButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.brightness,
  });

  @override
  State<_OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<_OnboardingButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(widget.brightness);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(widget.icon, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accentColor = AppColors.accentColor(brightness);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: accentColor,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 40),

          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(brightness),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary(brightness),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
