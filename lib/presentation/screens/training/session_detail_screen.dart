import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/training_session.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

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
    final brightness = Theme.of(context).brightness;
    final historyAsync = ref.watch(trainingHistoryProvider);

    return historyAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background(brightness),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          title: const Text('Lỗi'),
          backgroundColor: AppColors.surface(brightness),
          foregroundColor: AppColors.textPrimary(brightness),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            'Lỗi: $error',
            style: TextStyle(color: AppColors.textPrimary(brightness)),
          ),
        ),
      ),
      data: (sessions) {
        final session = sessions.where((s) => s.id == sessionId).firstOrNull;
        if (session == null) {
          return Scaffold(
            backgroundColor: AppColors.background(brightness),
            appBar: AppBar(
              title: const Text('Không tìm thấy'),
              backgroundColor: AppColors.surface(brightness),
              foregroundColor: AppColors.textPrimary(brightness),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            body: SoftBackground(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: AppColors.textTertiary(brightness)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Không tìm thấy buổi tập này',
                      style:
                          TextStyle(color: AppColors.textPrimary(brightness)),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _PrimaryButton(
                      onPressed: () => context.go('/training/history'),
                      label: 'Quay lại lịch sử',
                    ),
                  ],
                ),
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
    final brightness = Theme.of(context).brightness;
    final accuracy = session.shotsMade + session.shotsMissed > 0
        ? (session.shotsMade * 100 / (session.shotsMade + session.shotsMissed)).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: Text(session.drillName),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/training/history'),
        ),
      ),
      body: SoftBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Score card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary(brightness),
                    AppColors.primary(brightness).withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              // Nền là dải `primary(brightness)` — đổi theo chế độ, nên chữ
              // dùng `onPrimary(brightness)`.
              child: Column(
                children: [
                  Text(
                    '${session.score}%',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    session.drillName,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.onPrimary(brightness),
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
                  label: 'Thời gian',
                  value: '${session.duration}m',
                  color: AppColors.warning,
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(
                  icon: Icons.gps_fixed,
                  label: 'Tỷ lệ',
                  value: '$accuracy%',
                  color: AppColors.primary(brightness),
                )),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(child: _StatCard(
                  icon: Icons.check_circle,
                  label: 'Thành công',
                  value: '${session.shotsMade}',
                  color: AppColors.success,
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(
                  icon: Icons.cancel,
                  label: 'Trượt',
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
                  // #8B5CF6 là đúng hằng tím mà `difficultyExpert` sinh ra để
                  // thay — nay có bản tối đi kèm.
                  value: '${session.level}',
                  color: AppColors.difficultyExpert(brightness),
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(
                  icon: Icons.calendar_today,
                  label: 'Ngày',
                  // #14B8A6 (teal) không có token tương ứng; `accentLabel` là
                  // tông moss sáng nhất, gần nó nhất và có sẵn bản tối.
                  value: _formatDate(session.completedAt),
                  color: AppColors.accentLabel(brightness),
                )),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Actions
            _PrimaryButton(
              onPressed: () => context.push('/training/drill/${session.drillCode}'),
              label: 'Tập lại',
              icon: Icons.replay,
            ),

            const SizedBox(height: AppSpacing.md),

            OutlinedButton.icon(
              onPressed: () => context.go('/training/history'),
              icon: const Icon(Icons.list),
              label: const Text('Xem lịch sử'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary(brightness),
                side: BorderSide(color: AppColors.primary(brightness)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
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
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              color: AppColors.textSecondary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            // Cả hai nhánh nền đều đổi theo chế độ -> `onPrimary(brightness)`.
            color: widget.onPressed != null
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: AppColors.onPrimary(brightness), size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary(brightness))),
            ],
          ),
        ),
      ),
    );
  }
}
