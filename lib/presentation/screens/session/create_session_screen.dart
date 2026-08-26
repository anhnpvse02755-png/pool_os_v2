import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  String _selectedType = 'practice';
  int _energyLevel = 3;
  int _focusLevel = 3;
  int _confidenceLevel = 3;
  bool _isLoading = false;

  void _startSession() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/training/drills');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo buổi chơi!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Buổi chơi mới',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Type
            Text(
              'Loại buổi chơi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
            ).animate().fadeIn(),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    icon: Icons.fitness_center,
                    label: 'Luyện tập',
                    isSelected: _selectedType == 'practice',
                    onTap: () => setState(() => _selectedType = 'practice'),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TypeCard(
                    icon: Icons.emoji_events,
                    label: 'Giải đấu',
                    isSelected: _selectedType == 'tournament',
                    onTap: () => setState(() => _selectedType = 'tournament'),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TypeCard(
                    icon: Icons.people,
                    label: 'Chơi vui',
                    isSelected: _selectedType == 'casual',
                    onTap: () => setState(() => _selectedType = 'casual'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            SizedBox(height: AppSpacing.xxl),

            // Readiness Section
            Text(
              'Tình trạng hiện tại',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Đánh giá tình trạng của bạn trước khi bắt đầu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.lg),

            // Energy Level
            _ReadinessSlider(
              icon: Icons.bolt,
              label: 'Năng lượng',
              value: _energyLevel,
              labels: ['Thấp', 'Trung bình', 'Cao'],
              onChanged: (v) => setState(() => _energyLevel = v),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: AppSpacing.lg),

            // Focus Level
            _ReadinessSlider(
              icon: Icons.center_focus_strong,
              label: 'Tập trung',
              value: _focusLevel,
              labels: ['Mất tập trung', 'Bình thường', 'Rất tập trung'],
              onChanged: (v) => setState(() => _focusLevel = v),
            ).animate().fadeIn(delay: 400.ms),
            SizedBox(height: AppSpacing.lg),

            // Confidence Level
            _ReadinessSlider(
              icon: Icons.psychology,
              label: 'Sự tự tin',
              value: _confidenceLevel,
              labels: ['Không chắc', 'Bình thường', 'Rất tự tin'],
              onChanged: (v) => setState(() => _confidenceLevel = v),
            ).animate().fadeIn(delay: 500.ms),
            SizedBox(height: AppSpacing.xxl),

            // Coach Insight Preview
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 20),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mẹo từ Coach',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Năng lượng thấp? Có thể ảnh hưởng đến độ chính xác của cú đánh. Cân nhắc khởi động kỹ hơn.',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
            SizedBox(height: AppSpacing.xl),

            // Start Button
            _PrimaryButton(
              onPressed: _isLoading ? null : _startSession,
              label: _isLoading ? '' : 'Bắt đầu buổi chơi',
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.lightBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
              size: 28,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _ReadinessSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextPrimary,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                labels[value - 1],
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: List.generate(5, (index) {
            final isSelected = index < value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index + 1),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 8,
                  margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? child;

  const _PrimaryButton({required this.onPressed, required this.label, this.child});

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
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: widget.child ??
              Text(
                widget.label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                textAlign: TextAlign.center,
              ),
        ),
      ),
    );
  }
}
