import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Đấu nhanh',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
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
                    color: AppColors.lightTextPrimary,
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
                    color: AppColors.lightTextPrimary,
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
                    color: AppColors.lightTextPrimary,
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
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rule, color: AppColors.lightTextSecondary, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Luật thi đấu',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextPrimary,
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
          color: AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.orange),
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
            child: Text('Đóng', style: TextStyle(color: AppColors.accent)),
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
            color: widget.isSelected ? AppColors.accent : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected ? AppColors.accent : AppColors.lightBorder,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
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
                widget.icon,
                color: widget.isSelected ? Colors.white : AppColors.lightTextSecondary,
                size: 32,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                widget.name,
                style: TextStyle(
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? Colors.white : AppColors.lightTextSecondary,
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
            color: widget.isSelected ? AppColors.accent : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected ? AppColors.accent : AppColors.lightBorder,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : AppColors.lightTextPrimary,
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
            color: widget.isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected ? AppColors.accent : AppColors.lightBorder,
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
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected ? AppColors.accent : AppColors.lightTextSecondary,
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
                        color: widget.isSelected ? AppColors.accent : AppColors.lightTextPrimary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.lightTextSecondary,
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
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              color: AppColors.lightTextSecondary,
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
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(
                widget.label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
