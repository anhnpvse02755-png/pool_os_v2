import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if onboarding is already completed
    final playerRepo = ref.read(playerRepositoryProvider);
    final isOnboardingCompleted = playerRepo.isOnboardingCompleted();

    // If already completed onboarding, redirect to home
    isOnboardingCompleted.then((completed) {
      if (completed) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),

              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pool,
                  size: 56,
                  color: AppColors.accent,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // App Name
              Text(
                'PoolOS',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'AI Pool Training Platform',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Tagline
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Trở thành cơ thủ chuyên nghiệp\ncùng AI Coach của riêng bạn',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const Spacer(),

              // CTA Button
              _PrimaryButton(
                onPressed: () => context.push('/onboarding'),
                label: 'Bắt đầu ngay',
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.md),

              TextButton(
                onPressed: () async {
                  final completed = await playerRepo.isOnboardingCompleted();
                  if (completed) {
                    context.go('/home');
                  } else {
                    context.push('/onboarding');
                  }
                },
                child: Text(
                  'Tôi đã có tài khoản',
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
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
          width: double.infinity,
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
