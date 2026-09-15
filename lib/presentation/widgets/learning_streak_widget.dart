import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
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
    final brightness = Theme.of(context).brightness;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.school, color: AppColors.primary(brightness), size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chuỗi ngày học',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Hiện tại: $_current ngày',
                      style: TextStyle(
                          color: _current > 0
                              ? AppColors.primary(brightness)
                              : AppColors.textTertiary(brightness),
                          fontWeight: FontWeight.w600)),
                  Text('Dài nhất: $_longest ngày',
                      style: TextStyle(color: AppColors.textTertiary(brightness))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}