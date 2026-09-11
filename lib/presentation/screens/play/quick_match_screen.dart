import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';

class QuickMatchScreen extends StatefulWidget {
  const QuickMatchScreen({super.key});

  @override
  State<QuickMatchScreen> createState() => _QuickMatchScreenState();
}

class _QuickMatchScreenState extends State<QuickMatchScreen> {
  String _selectedGameType = '8-ball';
  String _selectedRaceTo = 'first-to-5';
  String _selectedTable = 'any';

  final List<Map<String, dynamic>> _gameTypes = [
    {'id': '8-ball', 'name': '8-Ball', 'icon': Icons.sports_cricket},
    {'id': '9-ball', 'name': '9-Ball', 'icon': Icons.circle_outlined},
    {'id': 'straight', 'name': 'Straight Pool', 'icon': Icons.linear_scale},
  ];

  final List<Map<String, dynamic>> _raceOptions = [
    {'id': 'first-to-3', 'name': 'FT 3', 'value': 3},
    {'id': 'first-to-5', 'name': 'FT 5', 'value': 5},
    {'id': 'first-to-7', 'name': 'FT 7', 'value': 7},
    {'id': 'unlimited', 'name': 'Unlimited', 'value': -1},
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surface(brightness),
        elevation: 0,
        title: Text(
          'Đấu nhanh',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(brightness)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Type Selection
            Text(
              'Loại game',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
            ).animate().fadeIn(),
            SizedBox(height: AppSpacing.md),
            Row(
              children: _gameTypes.map((type) {
                final isSelected = _selectedGameType == type['id'];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: _GameTypeCard(
                      icon: type['icon'] as IconData,
                      name: type['name'] as String,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedGameType = type['id'] as String),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: AppSpacing.xxl),

            // Race Selection
            Text(
              'Đấu đến',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _raceOptions.map((option) {
                final isSelected = _selectedRaceTo == option['id'];
                return _RaceChip(
                  label: option['name'] as String,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedRaceTo = option['id'] as String),
                );
              }).toList(),
            ).animate().fadeIn(delay: 250.ms),

            SizedBox(height: AppSpacing.xxl),

            // Table Selection
            Text(
              'Bàn chơi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TableOptionCard(
                    title: 'Bất kỳ',
                    subtitle: 'Ghép nhanh',
                    icon: Icons.shuffle,
                    isSelected: _selectedTable == 'any',
                    onTap: () => setState(() => _selectedTable = 'any'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TableOptionCard(
                    title: 'Chỉ định',
                    subtitle: 'Chọn bàn',
                    icon: Icons.table_restaurant,
                    isSelected: _selectedTable == 'specific',
                    onTap: () => setState(() => _selectedTable = 'specific'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms),

            SizedBox(height: AppSpacing.xxl),

            // Rules Summary
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(brightness)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rule, color: AppColors.textSecondary(brightness), size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Luật thi đấu',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(brightness),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  _RuleItem(text: 'Đánh bi cái trước'),
                  _RuleItem(text: 'Không đánh bi đối thủ trước'),
                  _RuleItem(text: 'Không đánh bi vào lỗ sai'),
                  _RuleItem(text: 'Không đánh bi cái ra khỏi bàn'),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          boxShadow: AppShadows.soft(brightness),
        ),
        child: SafeArea(
          child: _PrimaryButton(
            onPressed: _startMatch,
            label: 'BẮT ĐẦU TRẬN ĐẤU',
            icon: Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  void _startMatch() {
    final brightness = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Row(
          children: [
            Icon(Icons.construction, color: AppColors.warning),
            SizedBox(width: AppSpacing.sm),
            const Text('Đang phát triển'),
          ],
        ),
        content: Text(
          'Tính năng đấu nhanh online đang được phát triển.\n\n'
          'Hiện tại bạn có thể sử dụng "Ghi nhận trận đấu" để ghi lại kết quả thi đấu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: AppColors.primary(brightness))),
          ),
        ],
      ),
    );
  }
}

class _GameTypeCard extends StatefulWidget {
  final IconData icon;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameTypeCard({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GameTypeCard> createState() => _GameTypeCardState();
}

class _GameTypeCardState extends State<_GameTypeCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary(brightness) : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary(brightness) : AppColors.border(brightness),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary(brightness).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? AppColors.onPrimary(brightness) : AppColors.textSecondary(brightness),
                size: 32,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                widget.name,
                style: TextStyle(
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? AppColors.onPrimary(brightness) : AppColors.textSecondary(brightness),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RaceChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RaceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RaceChip> createState() => _RaceChipState();
}

class _RaceChipState extends State<_RaceChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary(brightness) : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary(brightness) : AppColors.border(brightness),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? AppColors.onPrimary(brightness) : AppColors.textPrimary(brightness),
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _TableOptionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TableOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TableOptionCard> createState() => _TableOptionCardState();
}

class _TableOptionCardState extends State<_TableOptionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.primary(brightness).withValues(alpha: 0.08) : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary(brightness) : AppColors.border(brightness),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary(brightness).withValues(alpha: 0.15)
                      : AppColors.surfaceElevated(brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? AppColors.primary(brightness) : AppColors.textSecondary(brightness),
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: widget.isSelected ? AppColors.primary(brightness) : AppColors.textPrimary(brightness),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String text;

  const _RuleItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 13,
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
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.onPrimary(brightness), size: 20),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(
                widget.label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
