import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/match_repository.dart';
import '../../domain/services/streak_calculator.dart';

/// Streak widget — current + longest consecutive daily streaks.
class StreakWidget extends ConsumerStatefulWidget {
  const StreakWidget({super.key, this.playerId = ''});
  final String playerId;

  @override
  ConsumerState<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends ConsumerState<StreakWidget> {
  int _current = 0;
  int _longest = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final calc = StreakCalculator(ref.read(matchRepositoryProvider));
    final current = await calc.currentStreak(playerId: widget.playerId);
    final longest = await calc.longestStreak(playerId: widget.playerId);
    if (!mounted) return;
    setState(() {
      _current = current;
      _longest = longest;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_fire_department,
                color: Colors.deepOrange, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Streak',
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
