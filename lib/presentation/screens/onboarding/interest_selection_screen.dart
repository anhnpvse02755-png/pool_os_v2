import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

class InterestSelectionScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const InterestSelectionScreen({super.key, this.onComplete});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final Set<String> _selectedInterests = {};

  final List<_InterestOption> _interests = [
    _InterestOption(
      id: 'draw',
      name: 'Draw Shot',
      nameVi: 'Draw Shot',
      icon: Icons.arrow_back,
      color: Colors.orange,
    ),
    _InterestOption(
      id: 'position',
      name: 'Position Control',
      nameVi: 'Kiểm soát vị trí',
      icon: Icons.gps_fixed,
      color: Colors.blue,
    ),
    _InterestOption(
      id: 'bank',
      name: 'Bank Shot',
      nameVi: 'Bank',
      icon: Icons.change_history,
      color: Colors.purple,
    ),
    _InterestOption(
      id: 'kick',
      name: 'Kick Shot',
      nameVi: 'Kick',
      icon: Icons.turn_right,
      color: Colors.teal,
    ),
    _InterestOption(
      id: 'jump',
      name: 'Jump Shot',
      nameVi: 'Jump',
      icon: Icons.arrow_upward,
      color: Colors.red,
    ),
    _InterestOption(
      id: 'masse',
      name: 'Masse',
      nameVi: 'Masse',
      icon: Icons.rotate_right,
      color: Colors.pink,
    ),
    _InterestOption(
      id: 'safety',
      name: 'Safety Play',
      nameVi: 'An toàn',
      icon: Icons.shield,
      color: Colors.green,
    ),
    _InterestOption(
      id: '3cushion',
      name: '3 Cushion',
      nameVi: '3 Băng',
      icon: Icons.view_in_ar,
      color: Colors.indigo,
    ),
    _InterestOption(
      id: 'trickshot',
      name: 'Trickshot',
      nameVi: 'Trickshot',
      icon: Icons.auto_awesome,
      color: Colors.amber,
    ),
    _InterestOption(
      id: 'break',
      name: 'Break Shot',
      nameVi: 'Khai cuộc',
      icon: Icons.flash_on,
      color: Colors.deepOrange,
    ),
  ];

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

  void _continue() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn thích học gì?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Chọn những gì bạn muốn cải thiện. Điều này giúp AI đề xuất bài tập phù hợp với bạn.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.gold),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Bạn có thể chọn nhiều hoặc bỏ trống. Tất cả bài tập đều mở cho bạn.',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),

            // Interest Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest.id);

                  return _InterestCard(
                    interest: interest,
                    isSelected: isSelected,
                    onTap: () => _toggleInterest(interest.id),
                  ).animate().fadeIn(delay: (300 + index * 50).ms);
                },
              ),
            ),

            // Bottom bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                border: Border(
                  top: BorderSide(color: AppColors.lightBorder),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Text(
                      '${_selectedInterests.length} sở thích đã chọn',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PrimaryButton(
                      onPressed: _selectedInterests.isNotEmpty ? _continue : null,
                      label: 'Tiếp tục',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestOption {
  final String id;
  final String name;
  final String nameVi;
  final IconData icon;
  final Color color;

  const _InterestOption({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.color,
  });
}

class _InterestCard extends StatelessWidget {
  final _InterestOption interest;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestCard({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? interest.color.withValues(alpha: 0.1)
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? interest.color : AppColors.lightBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: interest.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? interest.color.withValues(alpha: 0.2)
                    : AppColors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                interest.icon,
                color: isSelected ? interest.color : AppColors.lightTextTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              interest.nameVi,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? interest.color : AppColors.lightTextPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? interest.color : AppColors.lightTextTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _PrimaryButton({
    required this.onPressed,
    required this.label,
  });

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
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
