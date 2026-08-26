import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

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
      'title': 'Cai thien Draw Shot',
      'subtitle': 'Dua tren phong cach choi cua ban',
      'reason': 'Ban co xu huong danh manh. Hay tap trung vao kiem soat luc.',
      'drills': [
        {'name': 'Draw Shot Lv1', 'duration': '15 phut', 'difficulty': 'Easy'},
        {'name': 'Draw Shot Lv2', 'duration': '20 phut', 'difficulty': 'Medium'},
      ],
      'progress': 0.4,
      'icon': Icons.trending_up,
      'color': AppColors.warning,
    },
    {
      'type': 'weakness',
      'title': 'Position Play yeu',
      'subtitle': 'Diem can cai thien',
      'reason': 'Ty le kiem soat vi tri cua ban thap hon muc trung binh.',
      'drills': [
        {'name': 'Position Control Lv1', 'duration': '25 phut', 'difficulty': 'Medium'},
        {'name': 'Position Control Lv2', 'duration': '30 phut', 'difficulty': 'Hard'},
      ],
      'progress': 0.25,
      'icon': Icons.gps_fixed,
      'color': AppColors.accent,
    },
    {
      'type': 'challenge',
      'title': 'Thu thach: Bank Shot',
      'subtitle': 'Nang cao ky nang',
      'reason': 'Ban chua tap Bank Shot. Day la ky nang quan trong.',
      'drills': [
        {'name': 'Bank Shot Lv1', 'duration': '20 phut', 'difficulty': 'Medium'},
        {'name': 'Bank Shot Lv2', 'duration': '25 phut', 'difficulty': 'Hard'},
      ],
      'progress': 0.0,
      'icon': Icons.shield,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'type': 'maintenance',
      'title': 'On tap: Stop Shot',
      'subtitle': 'Duy tri ky nang',
      'reason': 'Da 3 ngay khong tap Stop Shot. Hay on lai de duy tri.',
      'drills': [
        {'name': 'Stop Shot Lv1', 'duration': '10 phut', 'difficulty': 'Easy'},
        {'name': 'Stop Shot Lv2', 'duration': '15 phut', 'difficulty': 'Medium'},
      ],
      'progress': 0.75,
      'icon': Icons.refresh,
      'color': AppColors.success,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('AI de xuat'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRecommendations,
            tooltip: 'Lam moi',
          ),
        ],
      ),
      body: Column(
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
              label: 'Tat ca',
              isSelected: _selectedGoal == 'all',
              onTap: () => setState(() => _selectedGoal = 'all'),
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Ca nhan hoa',
              isSelected: _selectedGoal == 'personalized',
              onTap: () => setState(() => _selectedGoal = 'personalized'),
              icon: Icons.person,
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Diem yeu',
              isSelected: _selectedGoal == 'weakness',
              onTap: () => setState(() => _selectedGoal = 'weakness'),
              icon: Icons.trending_down,
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'Thu thach',
              isSelected: _selectedGoal == 'challenge',
              onTap: () => setState(() => _selectedGoal = 'challenge'),
              icon: Icons.emoji_events,
            ),
            const SizedBox(width: AppSpacing.sm),
            _GoalChip(
              label: 'On tap',
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
                  ? AppColors.accent
                  : AppColors.lightBorder,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/training/assessment'),
                icon: const Icon(Icons.psychology),
                label: const Text('Danh gia lai'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accent),
                  foregroundColor: AppColors.accent,
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
                label: 'Bat dau',
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
        content: Text('Da lam moi de xuat'),
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
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.lightTextSecondary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.accent,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.lightTextSecondary,
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
    final drills = recommendation['drills'] as List;
    final color = recommendation['color'] as Color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    recommendation['icon'] as IconData,
                    color: Colors.white,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        recommendation['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: color, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phan tich AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        recommendation['reason'] as String,
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
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
              'Tien do',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: LinearProgressIndicator(
                      value: recommendation['progress'] as double,
                      minHeight: 8,
                      backgroundColor: AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${((recommendation['progress'] as double) * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Drills
          Text(
            'Bai tap de xuat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
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
                color: color,
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
  final Color color;
  final VoidCallback onStart;

  const _DrillCard({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.color,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(Icons.fitness_center, color: color),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.lightTextPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: AppColors.lightTextSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      duration,
                      style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(difficulty),
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
            icon: Icon(Icons.play_circle, color: color, size: 32),
            onPressed: onStart,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.success;
      case 'Medium':
        return AppColors.warning;
      case 'Hard':
        return AppColors.error;
      default:
        return AppColors.lightTextSecondary;
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
