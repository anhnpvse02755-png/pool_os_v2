import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/training_session.dart';

/// Sprint 4A Task 11 - Session Detail Screen.
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
      loading: () => Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Loi'),
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        body: Center(child: Text('Loi: $error')),
      ),
      data: (sessions) {
        final session = sessions.where((s) => s.id == sessionId).firstOrNull;
        if (session == null) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              title: const Text('Khong tim thay'),
              backgroundColor: AppColors.lightSurface,
              foregroundColor: AppColors.lightTextPrimary,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: AppColors.lightTextTertiary),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Khong tim thay buoi tap nay'),
                  const SizedBox(height: AppSpacing.xxl),
                  _PrimaryButton(
                    onPressed: () => context.go('/training/history'),
                    label: 'Quay lai lich su',
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
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(session.drillName),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/training/history'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Score card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  session.drillName,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: AppSpacing.xxl),

          // Stats
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.timer,
                label: 'Thoi gian',
                value: '${session.duration}m',
                color: AppColors.warning,
              )),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _StatCard(
                icon: Icons.gps_fixed,
                label: 'Accuracy',
                value: '$accuracy%',
                color: AppColors.accent,
              )),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.check_circle,
                label: 'Thanh cong',
                value: '${session.shotsMade}',
                color: AppColors.success,
              )),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _StatCard(
                icon: Icons.cancel,
                label: 'Truot',
                value: '${session.shotsMissed}',
                color: AppColors.error,
              )),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.leaderboard,
                label: 'Level',
                value: '${session.level}',
                color: const Color(0xFF8B5CF6),
              )),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _StatCard(
                icon: Icons.calendar_today,
                label: 'Ngay',
                value: _formatDate(session.completedAt),
                color: const Color(0xFF14B8A6),
              )),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Actions
          _PrimaryButton(
            onPressed: () => context.push('/training/drill/${session.drillCode}'),
            label: 'Tap lai',
            icon: Icons.replay,
          ),

          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () => context.go('/training/history'),
            icon: const Icon(Icons.list),
            label: const Text('Xem lich su'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  const _PrimaryButton({required this.onPressed, required this.label, this.icon});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}
class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
