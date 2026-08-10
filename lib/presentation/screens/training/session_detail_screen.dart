import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/training_session.dart';

/// Sprint 4A Task 11 — Session Detail Screen.
///
/// Shows detailed view of a completed training session.
/// Accessed from TrainingHistoryScreen.
class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(trainingHistoryProvider);

    return historyAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text('Lỗi: $error')),
      ),
      data: (sessions) {
        final session = sessions.where((s) => s.id == sessionId).firstOrNull;
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Không tìm thấy')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Không tìm thấy buổi tập này'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/training/history'),
                    child: const Text('Quay lại lịch sử'),
                  ),
                ],
              ),
            ),
          );
        }
        return _SessionDetailView(session: session);
      },
    );
  }
}

class _SessionDetailView extends StatelessWidget {
  final TrainingSession session;

  const _SessionDetailView({required this.session});

  @override
  Widget build(BuildContext context) {
    final accuracy = session.shotsMade + session.shotsMissed > 0
        ? (session.shotsMade * 100 / (session.shotsMade + session.shotsMissed)).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.drillName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/training/history'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreen.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '${session.score}%',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session.drillName,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.timer,
                label: 'Thời gian',
                value: '${session.duration}m',
                color: Colors.orange,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.sports_cricket,
                label: 'Accuracy',
                value: '$accuracy%',
                color: Colors.blue,
              )),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.check_circle,
                label: 'Thành công',
                value: '${session.shotsMade}',
                color: Colors.green,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.cancel,
                label: 'Trượt',
                value: '${session.shotsMissed}',
                color: Colors.red,
              )),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.leaderboard,
                label: 'Level',
                value: '${session.level}',
                color: Colors.purple,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.calendar_today,
                label: 'Ngày',
                value: _formatDate(session.completedAt),
                color: Colors.teal,
              )),
            ],
          ),

          const SizedBox(height: 32),

          // Actions
          FilledButton.icon(
            onPressed: () => context.push('/training/drill/${session.drillCode}'),
            icon: const Icon(Icons.replay),
            label: const Text('Tập lại'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => context.go('/training/history'),
            icon: const Icon(Icons.list),
            label: const Text('Xem lịch sử'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
