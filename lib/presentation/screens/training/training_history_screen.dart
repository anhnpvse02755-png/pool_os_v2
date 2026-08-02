import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/training_provider.dart';

class TrainingHistoryScreen extends ConsumerWidget {
  const TrainingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(recentTrainingSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử luyện tập'),
      ),
      body: sessionsAsync.when(
        data: (sessions) => _buildContent(context, sessions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> sessions) {
    if (sessions.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group sessions by date
    final groupedSessions = <String, List<dynamic>>{};
    for (final session in sessions) {
      final date = _formatDate(session.startedAt);
      groupedSessions.putIfAbsent(date, () => []).add(session);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedSessions.length,
      itemBuilder: (context, index) {
        final date = groupedSessions.keys.elementAt(index);
        final daySessions = groupedSessions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...daySessions.asMap().entries.map((entry) {
              final session = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SessionCard(
                  session: session,
                  onTap: () {
                    // TODO: Navigate to session detail
                  },
                ).animate().fadeIn(delay: (index * 50).ms),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử luyện tập',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu luyện tập để xem tiến độ của bạn',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/training/drills'),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Đi đến Drill Library'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hôm nay';
    } else if (dateOnly == yesterday) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _SessionCard extends StatelessWidget {
  final dynamic session;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = session.durationMinutes ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buổi tập #${session.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '$duration phút',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      if (session.drillRuns != null && session.drillRuns.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.format_list_numbered, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${session.drillRuns.length} drills',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
