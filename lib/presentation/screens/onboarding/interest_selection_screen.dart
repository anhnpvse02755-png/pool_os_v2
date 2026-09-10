import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

class InterestSelectionScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const InterestSelectionScreen({super.key, this.onComplete});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final Set<String> _selectedInterests = {};

  /// `toneIndex` gán CỐ ĐỊNH theo danh mục, không theo vị trí trong lưới —
  /// người dùng học được màu nên một danh mục phải luôn cùng tông, kể cả khi
  /// sau này thêm/bớt mục khác hoặc sắp xếp lại.
  final List<_InterestOption> _interests = const [
    _InterestOption(
      id: 'draw',
      name: 'Draw Shot',
      nameVi: 'Draw Shot',
      icon: Icons.arrow_back,
      toneIndex: 2,
    ),
    _InterestOption(
      id: 'position',
      name: 'Position Control',
      nameVi: 'Kiểm soát vị trí',
      icon: Icons.gps_fixed,
      toneIndex: 1,
    ),
    _InterestOption(
      id: 'bank',
      name: 'Bank Shot',
      nameVi: 'Bank',
      icon: Icons.change_history,
      toneIndex: 3,
    ),
    _InterestOption(
      id: 'kick',
      name: 'Kick Shot',
      nameVi: 'Kick',
      icon: Icons.turn_right,
      toneIndex: 0,
    ),
    _InterestOption(
      id: 'jump',
      name: 'Jump Shot',
      nameVi: 'Jump',
      icon: Icons.arrow_upward,
      toneIndex: 2,
    ),
    _InterestOption(
      id: 'masse',
      name: 'Masse',
      nameVi: 'Masse',
      icon: Icons.rotate_right,
      toneIndex: 3,
    ),
    _InterestOption(
      id: 'safety',
      name: 'Safety Play',
      nameVi: 'An toàn',
      icon: Icons.shield,
      toneIndex: 0,
    ),
    _InterestOption(
      id: '3cushion',
      name: '3 Cushion',
      nameVi: '3 Băng',
      icon: Icons.view_in_ar,
      toneIndex: 1,
    ),
    _InterestOption(
      id: 'trickshot',
      name: 'Trickshot',
      nameVi: 'Trickshot',
      icon: Icons.auto_awesome,
      toneIndex: 4,
    ),
    _InterestOption(
      id: 'break',
      name: 'Break Shot',
      nameVi: 'Khai cuộc',
      icon: Icons.flash_on,
      toneIndex: 4,
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
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SoftBackground(
        child: SafeArea(
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
                          color: AppColors.textPrimary(brightness),
                        ),
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Chọn những gì bạn muốn cải thiện. Điều này giúp AI đề xuất bài tập phù hợp với bạn.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.md),
                  // Hộp gợi ý: nền pastel butter thay cho gold@10% — gold trên
                  // nền kem chỉ đạt ~2:1, chữ 13px đọc không ra.
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.pastelFor(4, brightness),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18,
                            color: AppColors.accentLabel(brightness)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Bạn có thể chọn nhiều hoặc bỏ trống. Tất cả bài tập đều mở cho bạn.',
                            style: TextStyle(
                              color: AppColors.textPrimary(brightness),
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
                color: AppColors.surface(brightness),
                border: Border(
                  top: BorderSide(color: AppColors.border(brightness)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Text(
                      '${_selectedInterests.length} sở thích đã chọn',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
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
      ),
    );
  }
}

class _InterestOption {
  final String id;
  final String name;
  final String nameVi;
  final IconData icon;

  /// Tông pastel của danh mục — xem `AppColors.pastelFor`.
  final int toneIndex;

  const _InterestOption({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.toneIndex,
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
    final brightness = Theme.of(context).brightness;

    // Trạng thái chọn thể hiện bằng bề mặt nổi / chìm — đúng ngôn ngữ của
    // thiết kế tham chiếu, thay cho viền màu đậm của bản cũ.
    return PoolCard(
      selected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTile(icon: interest.icon, toneIndex: interest.toneIndex, size: 48),
          const SizedBox(height: AppSpacing.sm),
          Text(
            interest.nameVi,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.textPrimary(brightness)
                  : AppColors.textSecondary(brightness),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            size: 20,
          ),
        ],
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
    final brightness = Theme.of(context).brightness;
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTap: widget.onPressed,
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
            color: enabled
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary(brightness)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
