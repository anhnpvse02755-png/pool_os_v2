import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/services/learning_streak_service.dart';

class LearningStreakWidget extends StatefulWidget {
  const LearningStreakWidget({super.key});

  @override
  State<LearningStreakWidget> createState() => _LearningStreakWidgetState();
}

class _LearningStreakWidgetState extends State<LearningStreakWidget> {
  int _current = 0;
  int _longest = 0;

  @override
  void initState() {
    super.initState();
    final svc = ProviderScope.containerOf(context, listen: false)
        .read(learningStreakServiceProvider);
    _current = svc.currentStreak();
    _longest = svc.longestStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.school, color: AppTheme.primary, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Learning Streak',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Hiện tại: $_current ngày',
                      style: TextStyle(
                          color: _current > 0
                              ? AppTheme.primary
                              : Colors.grey,
                          fontWeight: FontWeight.w600)),
                  Text('Dài nhất: $_longest ngày',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}