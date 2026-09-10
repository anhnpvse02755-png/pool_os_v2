import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

/// Tông của một loại đề xuất.
///
/// BỘ ANH EM bốn phần tử — bốn thẻ này chỉ phân biệt nhau bằng màu, nên bảng
/// gốc (`warning`, `accent`, tím thô #8B5CF6, `success`) phải được kiểm lại
/// từng cặp sau khi `accent` -> `primary`: `primary` rơi vào hue 157 (sáng) /
/// 163 (tối) còn `success` ở 160, cách nhau 3-6° — hai thẻ "Điểm yếu" và
/// "Ôn tập" sẽ cùng một sắc xanh. Hệ chỉ có ĐÚNG bốn hue tách bạch:
/// `error` 0°, `warning` 38°, họ xanh rêu 157-163°, `difficultyExpert` 262°.
/// Nên "Điểm yếu" nhận `error` — vốn đọc đúng nghĩa một thiếu sót — và họ
/// xanh còn lại đúng một chỗ.
Color _toneFor(String type, Brightness brightness) {
  switch (type) {
    case 'personalized':
      return AppColors.warning;
    case 'weakness':
      return AppColors.error;
    case 'challenge':
      return AppColors.difficultyExpert(brightness);
    case 'maintenance':
      return AppColors.primary(brightness);
    default:
      return AppColors.textSecondary(brightness);
  }
}

class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  String _selectedGoal = 'all';
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _recommendations = [
    {
      'type': 'personalized',
      'title': 'Cải thiện Draw Shot',
      'subtitle': 'Dựa trên phong cách chơi của bạn',
      'reason': 'Bạn có xu hướng đánh mạnh. Hãy tập trung vào kiểm soát lực.',
      'drills': [
        {'name': 'Draw Shot Lv1', 'duration': '15 phut', 'difficulty': 'Easy'},
        {'name': 'Draw Shot Lv2', 'duration': '20 phut', 'difficulty': 'Medium'},
      ],
      'progress': 0.4,
      'icon': Icons.trending_up,
    },
    {
      'type': 'weakness',
      'title': 'Position Play yếu',
      'subtitle': 'Điểm cần cải thiện',
      'reason': 'Tỷ lệ kiểm soát vị trí của bạn thấp hơn mức trung bình.',
      'drills': [
        {'name': 'Position Control Lv1', 'duration': '25 phut', 'difficulty': 'Medium'},
        {'name': 'Position Control Lv2', 'duration': '30 phut', 'difficulty': 'Hard'},
      ],
      'progress': 0.25,
      'icon': Icons.gps_fixed,
    },
    {
      'type': 'challenge',
      'title': 'Thử thách: Bank Shot',
      'subtitle': 'Nâng cao kỹ năng',
      'reason': 'Bạn chưa tập Bank Shot. Đây là kỹ năng quan trọng.',
      'drills': [
        {'name': 'Bank Shot Lv1', 'duration': '20 phut', 'difficulty': 'Medium'},
        {'name': 'Bank Shot Lv2', 'duration': '25 phut', 'difficulty': 'Hard'},
      ],
      'progress': 0.0,
      'icon': Icons.shield,
    },
    {
      'type': 'maintenance',
      'title': 'Ôn tập: Stop Shot',
      'subtitle': 'Duy trì kỹ năng',
      'reason': 'Đã 3 ngày không tập Stop Shot. Hãy ôn lại để duy trì.',
      'drills': [
        {'name': 'Stop Shot Lv1', 'duration': '10 phut', 'difficulty': 'Easy'},
        {'name': 'Stop Shot Lv2', 'duration': '15 phut', 'difficulty': 'Medium'},
      ],
      'progress': 0.75,
      'icon': Icons.refresh,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('AI đề xuất'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRecommendations,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SoftBackground(
        child: Column(
          children: [
            // Goal Filter
            _buildGoalFilter(),

            // PageView
            Expanded(
              child: PageView.builder(
                itemCount: _getFilteredRecommendations().length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final rec = _getFilteredRecommendations()[index];
                  return _RecommendationCard(
                    recommendation: rec,
                    onStartDrill: (drill) {
                      context.push('/training/session/new?drill=$drill');
                    },
                  ).animate().fadeIn();
                },
              ),
            ),

            // Page Indicator
            _buildPageIndicator(),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRecommendations() {
    if (_selectedGoal == 'all') return _recommendations;
    return _recommendations.where((r) => r['type'] == _selectedGoal).toList();
  }

  Widget _buildGoalFilter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _GoalChip(
              label: 'Tất cả',
              isSelected: _selectedGoal == 'all',
              onTap: () => setState(() => _selectedGoal = 'all'),
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Cá nhân hóa',
              isSelected: _selectedGoal == 'personalized',
              onTap: () => setState(() => _selectedGoal = 'personalized'),
              icon: Icons.person,
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Điểm yếu',
              isSelected: _selectedGoal == 'weakness',
              onTap: () => setState(() => _selectedGoal = 'weakness'),
              icon: Icons.trending_down,
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Thử thách',
              isSelected: _selectedGoal == 'challenge',
              onTap: () => setState(() => _selectedGoal = 'challenge'),
              icon: Icons.emoji_events,
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Ôn tập',
              isSelected: _selectedGoal == 'maintenance',
              onTap: () => setState(() => _selectedGoal = 'maintenance'),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final brightness = Theme.of(context).brightness;
    final filtered = _getFilteredRecommendations();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          filtered.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentIndex
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        // Thanh đáy hắt bóng LÊN TRÊN, nên phải lật dấu offset của shadow mềm.
        boxShadow: AppShadows.soft(brightness)
            .map((s) => BoxShadow(
                  color: s.color,
                  blurRadius: s.blurRadius,
                  offset: Offset(0, -s.offset.dy / 2),
                ))
            .toList(),
        border: Border(top: BorderSide(color: AppColors.border(brightness))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/training/assessment'),
                icon: const Icon(Icons.psychology),
                label: const Text('Đánh giá lại'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary(brightness)),
                  foregroundColor: AppColors.primary(brightness),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PrimaryButton(
                onPressed: () {
                  final filtered = _getFilteredRecommendations();
                  if (filtered.isNotEmpty) {
                    final rec = filtered[_currentIndex];
                    final drills = rec['drills'] as List;
                    if (drills.isNotEmpty) {
                      final drillCode = _getDrillCode(drills[0]['name'] as String);
                      context.push('/training/session/new?drill=$drillCode');
                    }
                  }
                },
                label: 'Bắt đầu',
                icon: Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDrillCode(String drillName) {
    final name = drillName.toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
    return name;
  }

  void _refreshRecommendations() {
    setState(() {
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã làm mới đề xuất'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Chip ĐƯỢC CHỌN nằm trên `selectedColor` = `primary(brightness)` — nền
    // đổi theo chế độ nên chữ/icon/dấu tick dùng `onPrimary(brightness)`.
    // Chip chưa chọn nằm trên nền mặc định của FilterChip (bề mặt theme) nên
    // dùng token chữ thường.
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 16,
                color: isSelected
                    ? AppColors.onPrimary(brightness)
                    : AppColors.textSecondary(brightness)),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary(brightness),
      checkmarkColor: AppColors.onPrimary(brightness),
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.onPrimary(brightness)
            : AppColors.textSecondary(brightness),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final Function(String) onStartDrill;

  const _RecommendationCard({
    required this.recommendation,
    required this.onStartDrill,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final drills = recommendation['drills'] as List;
    final tone = _toneFor(recommendation['type'] as String, brightness);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          //
          // LOANG, không phải tô đặc — cùng cái bẫy và cùng cách sửa như header
          // của `drill_detail_screen` và thẻ tỉ lệ của `drill_result_screen`.
          //
          // Tô đặc thì chữ trắng KHÔNG đọc được ở chế độ sáng, tức chế độ duy
          // nhất đang phát hành: `warning` 2.15:1, `error` 3.76:1. Đổi hue
          // không cứu được vì lỗi nằm ở ĐỘ ĐẬM của nền. Loang 0.18 -> 0.10 đưa
          // cả bốn tông lên trên 8.7:1 với `textPrimary`, và vì nền loang lên
          // `background(brightness)` nên nó hết bất biến — dark mode cũng lành.
          //
          // `withValues` trên nền Container là hợp lệ: luật cấm alpha chỉ áp
          // cho MÀU CHỮ.
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tone.withValues(alpha: 0.18),
                  tone.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(brightness),
                    shape: BoxShape.circle,
                  ),
                  // Nền loang cùng hue thì `tone` đặc đặt lên chính nó chỉ còn
                  // ~1.9:1 — dưới sàn 3:1 cho một đối tượng đồ hoạ. Ô tròn
                  // dùng `surface` và icon dùng token chữ.
                  child: Icon(
                    recommendation['icon'] as IconData,
                    color: AppColors.textPrimary(brightness),
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'] as String,
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // KHÔNG hạ nhãn phụ xuống `textSecondary`: tông
                      // `maintenance` là `primary(light)` #0F4032 rất thẫm nên
                      // ngay ở alpha 0.18 nền đã đủ tối để `textSecondary` tụt
                      // dưới 4.5:1. Thứ bậc đã do cỡ chữ 20 vs 14 lo.
                      Text(
                        recommendation['subtitle'] as String,
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: AppSpacing.xxl),

          // Reason
          //
          // Nền loang nhạt cùng tông với header, nên `tone` đặc KHÔNG dùng làm
          // chữ/icon ở đây được (cùng hue, ~1.9:1). Tông vẫn nhận ra qua nền và
          // viền; chữ và icon dùng token chữ.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: tone.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb,
                    color: AppColors.textPrimary(brightness), size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân tích AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(brightness),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        recommendation['reason'] as String,
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: AppSpacing.xxl),

          // Progress
          if (recommendation['progress'] > 0) ...[
            Text(
              'Tiến độ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(brightness),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Phần trăm tiến độ là một PHÉP ĐO, không phải một hạng mục — nó
            // không cần mang tông của thẻ. Tô nó bằng `tone` còn hỏng thêm:
            // `warning` trên rãnh `border` chỉ 1.67:1, dưới hẳn sàn 3:1 cho
            // phần đã chạy vốn mã hoá tỉ lệ. `primary` trên rãnh cho 9.2:1.
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: LinearProgressIndicator(
                      value: recommendation['progress'] as double,
                      minHeight: 8,
                      backgroundColor: AppColors.border(brightness),
                      valueColor: AlwaysStoppedAnimation(
                          AppColors.primary(brightness)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${((recommendation['progress'] as double) * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Drills
          Text(
            'Bài tập đề xuất',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(brightness),
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...drills.asMap().entries.map((entry) {
            final index = entry.key;
            final drill = entry.value as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _DrillCard(
                name: drill['name'] as String,
                duration: drill['duration'] as String,
                difficulty: drill['difficulty'] as String,
                tone: tone,
                onStart: () => onStartDrill(drill['name'] as String),
              ).animate().fadeIn(delay: (150 + index * 50).ms),
            );
          }),
        ],
      ),
    );
  }
}

class _DrillCard extends StatelessWidget {
  final String name;
  final String duration;
  final String difficulty;
  final Color tone;
  final VoidCallback onStart;

  const _DrillCard({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.tone,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(Icons.fitness_center,
                color: AppColors.primary(brightness)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary(brightness)),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Thời lượng là dữ kiện trung tính nên KHÔNG tô; ô độ khó là ô
                // duy nhất mang màu trong hàng này.
                Row(
                  children: [
                    Icon(Icons.timer,
                        size: 14, color: AppColors.textSecondary(brightness)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      duration,
                      style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 13),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty, brightness)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(difficulty, brightness),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_circle,
                color: AppColors.primary(brightness), size: 32),
            onPressed: onStart,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty, Brightness brightness) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.success;
      case 'Medium':
        return AppColors.warning;
      case 'Hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary(brightness);
    }
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
            // Cả hai nhánh nền đều đổi theo chế độ, nên chữ dùng
            // `onPrimary(brightness)`.
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
