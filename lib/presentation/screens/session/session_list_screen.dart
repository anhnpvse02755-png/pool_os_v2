import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buổi chơi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pool,
                  size: 48,
                  color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                ),
              ).animate().scale(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                'Chưa có buổi chơi nào',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Bắt đầu ghi lại buổi chơi đầu tiên\nđể theo dõi tiến bộ của bạn',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/session/create'),
                icon: const Icon(Icons.add),
                label: const Text('Tạo buổi chơi mới'),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/session/create'),
        icon: const Icon(Icons.add),
        label: const Text('Buổi mới'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
    );
  }
}
