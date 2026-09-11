import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/training_session.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

/// Tông pastel của mỗi ô chỉ số, gán theo TÊN CHỈ SỐ chứ không theo vị trí
/// trong hàng — thêm hay bớt một ô thì ba ô kia vẫn giữ nguyên màu cũ.
///
/// BỘ MÀU ANH EM: bốn ô này trước đây là accent (217°) / warning (38°) /
/// gold (38°) / success (160°). Hai ô giữa đã trùng hue tuyệt đối từ trước
/// (`gold` và `warning` cùng là #F59E0B), và ánh xạ `accent` sang `primary`
/// còn kéo ô đầu về 158°, sát `success` 160°. Bốn ô đều là SỰ KIỆN TRUNG
/// TÍNH — một số đếm, một khoảng thời gian, một điểm trung bình, một số bi —
/// không ô nào mang phán quyết tốt/xấu, nên cả bộ chuyển sang bảng pastel
/// 5 tông: bốn tông khác hẳn nhau, chữ số về `textPrimary`, và không còn
/// tông ngữ nghĩa nào bị dùng sai chỗ.
int _toneFor(String metric) => switch (metric) {
      'sessions' => 0, // mint
      'minutes' => 1, // blue
      'avgScore' => 4, // butter
      'shots' => 2, // peach
      _ => 0,
    };

class TrainingHistoryScreen extends ConsumerStatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  ConsumerState<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends ConsumerState<TrainingHistoryScreen> {
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  List<TrainingSession> _applyFilters(List<TrainingSession> history) {
    var result = history;

    if (_selectedFilter != 'all') {
      result = result.where((h) => h.drillCode.startsWith(_selectedFilter)).toList();
    }

    if (_dateRange != null) {
      result = result.where((h) {
        return h.completedAt.isAfter(_dateRange!.start) &&
               h.completedAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return result;
  }

  Map<String, dynamic> _computeStats(List<TrainingSession> history) {
    if (history.isEmpty) {
      return {'sessions': 0, 'minutes': 0, 'avgScore': 0, 'shots': 0};
    }
    final totalSessions = history.length;
    final totalMinutes = history.fold<int>(0, (sum, h) => sum + h.duration);
    final avgScore = history.fold<int>(0, (sum, h) => sum + h.score) ~/ totalSessions;
    final totalShots = history.fold<int>(0, (sum, h) => sum + h.shotsMade);

    return {
      'sessions': totalSessions,
      'minutes': totalMinutes,
      'avgScore': avgScore,
      'shots': totalShots,
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final historyAsync = ref.watch(trainingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Lịch sử tập luyện'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: SoftBackground(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.lg),
                Text('Lỗi: $error', textAlign: TextAlign.center),
              ],
            ),
          ),
          data: (history) {
            final filtered = _applyFilters(history);
            final stats = _computeStats(history);

            return Column(
              children: [
                // Summary Stats
                _buildSummaryStats(stats),

                // Filter chips
                _buildFilterChips(),

                // History List
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final session = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _HistoryCard(
                                session: session,
                                onTap: () => context.push('/training/session/${session.id}'),
                              ).animate().fadeIn(delay: (index * 50).ms),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryStats(Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: PoolCard(
        radius: AppSpacing.radiusLg,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              metric: 'sessions',
              icon: Icons.fitness_center,
              value: '${stats['sessions']}',
              label: 'Buổi tập',
            ),
            _SummaryItem(
              metric: 'minutes',
              icon: Icons.timer,
              value: '${stats['minutes']}m',
              label: 'Tổng thời gian',
            ),
            _SummaryItem(
              metric: 'avgScore',
              icon: Icons.star,
              value: '${stats['avgScore']}%',
              label: 'Điểm TB',
            ),
            _SummaryItem(
              metric: 'shots',
              icon: Icons.sports_cricket,
              value: '${stats['shots']}',
              label: 'Bi đánh',
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      width: double.infinity,
      // Wrap chu KHONG phai vung cuon ngang: chip nam trong vung rong VO HAN
      // se do hut be rong nhan va cat mat ky tu cuoi.
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: _selectedFilter == 'all',
            onSelected: (_) => setState(() => _selectedFilter = 'all'),
          ),
          ChoiceChip(
            label: const Text('Stop'),
            selected: _selectedFilter == 'STOP',
            onSelected: (_) => setState(() => _selectedFilter = 'STOP'),
          ),
          ChoiceChip(
            label: const Text('Draw'),
            selected: _selectedFilter == 'DRAW',
            onSelected: (_) => setState(() => _selectedFilter = 'DRAW'),
          ),
          ChoiceChip(
            label: const Text('Follow'),
            selected: _selectedFilter == 'FOLLOW',
            onSelected: (_) => setState(() => _selectedFilter = 'FOLLOW'),
          ),
          ChoiceChip(
            label: const Text('Position'),
            selected: _selectedFilter == 'POSITION',
            onSelected: (_) => setState(() => _selectedFilter = 'POSITION'),
          ),
          ChoiceChip(
            label: const Text('Bank'),
            selected: _selectedFilter == 'BANK',
            onSelected: (_) => setState(() => _selectedFilter = 'BANK'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textTertiary(brightness)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chưa có lịch sử tập luyện',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bắt đầu một bài tập để xem lịch sử',
            style: TextStyle(
              color: AppColors.textTertiary(brightness),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _PrimaryButton(
            onPressed: () => context.push('/training/session/new'),
            label: 'Bắt đầu tập',
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bộ lọc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sắp xếp theo ngày'),
              subtitle: const Text('Mới nhất trước'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Sắp xếp theo điểm'),
              subtitle: const Text('Cao nhất trước'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Sắp xếp theo cải thiện'),
              subtitle: const Text('Tiến bộ nhiều nhất'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String metric;
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.metric,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        IconTile(icon: icon, toneIndex: _toneFor(metric), size: 40),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TrainingSession session;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.session,
    required this.onTap,
  });

  // Ba bậc ngữ nghĩa: success 160° / warning 38° / error 0°. Không bậc nào
  // rơi vào họ xanh của `primary`, nên bộ này giữ nguyên.
  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h truoc';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngay truoc';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final accuracy = session.shotsMade + session.shotsMissed > 0
        ? (session.shotsMade * 100 / (session.shotsMade + session.shotsMissed)).round()
        : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border(brightness)),
          boxShadow: AppShadows.soft(brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tông 0 (mint) gắn cố định với "buổi tập", giống ô tương ứng
                // ở màn Tiến độ.
                const IconTile(
                  icon: Icons.fitness_center,
                  toneIndex: 0,
                  size: 40,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.drillName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary(brightness)),
                      ),
                      Text(
                        _formatDate(session.completedAt),
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${session.duration}m',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: _getScoreColor(session.score).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '${session.score}%',
                        style: TextStyle(
                          color: _getScoreColor(session.score),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // BỘ MÀU ANH EM: ba chip cạnh nhau. Bản cũ là accent (217°) /
            // teal #14B8A6 (173°) / tím #8B5CF6 (258°). `accent` phải về
            // `primary` (158°) và teal KHÔNG có token nào — mọi token xanh
            // còn lại (`primary` 158°, `success` 160°, `accentLabel` 158°)
            // đều nằm trong 15° của chip đầu, nên gán bất kỳ cái nào cũng
            // làm hai chip trùng màu. 'Shots' là một SỐ ĐẾM thuần, không
            // mang phán quyết, nên nó là chip bị hạ màu về trung tính.
            // Ba hue sau khi đổi: 158° / trung tính / 262°.
            Row(
              children: [
                _StatChip(
                  label: 'Tỷ lệ',
                  value: '$accuracy%',
                  color: AppColors.primary(brightness),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Shots',
                  value: '${session.shotsMade}/${session.shotsMade + session.shotsMissed}',
                  color: AppColors.textSecondary(brightness),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Level',
                  value: '${session.level}',
                  color: AppColors.difficultyExpert(brightness),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nền là `primary` (hoặc `textTertiary` khi tắt) — cả hai đều
              // lật theo chế độ, nên mực dùng `onPrimary(brightness)`, nguyên
              // độ đục.
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.onPrimary(brightness), size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness))),
            ],
          ),
        ),
      ),
    );
  }
}
