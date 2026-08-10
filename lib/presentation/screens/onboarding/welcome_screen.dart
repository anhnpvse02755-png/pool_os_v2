import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pool,
                  size: 64,
                  color: AppTheme.primaryGreen,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              // App Name
              Text(
                'PoolOS',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                      letterSpacing: 2,
                    ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'AI Pool Training Platform',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 48),
              // Tagline
              Text(
                'Trở thành cơ thủ chuyên nghiệp\ncùng AI Coach của riêng bạn',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.5,
                    ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const Spacer(),
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/onboarding'),
                  child: const Text('Bắt đầu ngay'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  final completed = await playerRepo.isOnboardingCompleted();
                  if (completed) {
                    context.go('/home');
                  } else {
                    context.push('/onboarding');
                  }
                },
                child: const Text('Tôi đã có tài khoản'),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
