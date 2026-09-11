import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';

/// Equipment Model
class Equipment {
  final String id;
  final String name;
  final String type; // cue, shaft, tip, accessory
  final String? brand;
  final String? imageUrl;
  final DateTime? purchaseDate;
  final String? notes;

  Equipment({
    required this.id,
    required this.name,
    required this.type,
    this.brand,
    this.imageUrl,
    this.purchaseDate,
    this.notes,
  });
}

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Demo data
    final equipment = [
      Equipment(
        id: '1',
        name: 'My Main Cue',
        type: 'cue',
        brand: 'Predator',
        purchaseDate: DateTime(2024, 1, 15),
        notes: 'Cue chính dùng để thi đấu',
      ),
      Equipment(
        id: '2',
        name: 'Jump Cue',
        type: 'cue',
        brand: 'Predator',
        purchaseDate: DateTime(2024, 3, 20),
      ),
      Equipment(
        id: '3',
        name: 'Kamui Clear',
        type: 'tip',
        brand: 'Kamui',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Dụng cụ của tôi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary(brightness)),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary(brightness)),
            onPressed: () => _showAddEquipmentDialog(context),
          ),
        ],
      ),
      body: equipment.isEmpty
          ? _buildEmptyState(context)
          : _buildEquipmentList(context, equipment),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary(brightness).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEquipmentDialog(context),
          backgroundColor: AppColors.primary(brightness),
          icon: Icon(Icons.add, color: AppColors.onPrimary(brightness)),
          label: Text(
            'Thêm dụng cụ',
            style: TextStyle(color: AppColors.onPrimary(brightness), fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.pastelFor(0, brightness),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.primary(brightness).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Chưa có dụng cụ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thêm dụng cụ billiards của bạn để theo dõi',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentList(BuildContext context, List<Equipment> equipment) {
    final brightness = Theme.of(context).brightness;

    // Group by type
    final grouped = <String, List<Equipment>>{};
    for (final item in equipment) {
      grouped.putIfAbsent(item.type, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _getTypeColor(entry.key, brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        _getTypeIcon(entry.key),
                        size: 16,
                        color: _getTypeColor(entry.key, brightness),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _getTypeName(entry.key),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background(brightness),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.border(brightness)),
                      ),
                      child: Text(
                        '${entry.value.length}',
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.asMap().entries.map((e) {
                final index = e.key;
                final item = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _EquipmentCard(
                    equipment: item,
                    onTap: () => _showEquipmentDetail(context, item),
                  ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
            ],
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'cue':
        return Icons.straighten;
      case 'shaft':
        return Icons.linear_scale;
      case 'tip':
        return Icons.circle_outlined;
      case 'accessory':
        return Icons.handyman_outlined;
      default:
        return Icons.inventory_2;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'cue':
        return 'Cue';
      case 'shaft':
        return 'Shaft';
      case 'tip':
        return 'Tip';
      case 'accessory':
        return 'Phụ kiện';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type, Brightness brightness) {
    switch (type) {
      case 'cue':
        return AppColors.primary(brightness);
      case 'shaft':
        return AppColors.primary(brightness);
      case 'tip':
        return AppColors.warning;
      case 'accessory':
        return AppColors.difficultyExpert(brightness);
      default:
        return AppColors.textSecondary(brightness);
    }
  }

  void _showAddEquipmentDialog(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => const _AddEquipmentSheet(),
    );
  }

  void _showEquipmentDetail(BuildContext context, Equipment equipment) {
    final brightness = Theme.of(context).brightness;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => _EquipmentDetailSheet(equipment: equipment),
    );
  }
}

class _EquipmentCard extends StatefulWidget {
  final Equipment equipment;
  final VoidCallback onTap;

  const _EquipmentCard({
    required this.equipment,
    required this.onTap,
  });

  @override
  State<_EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<_EquipmentCard> {
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
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border(brightness)),
            boxShadow: AppShadows.soft(brightness),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.straighten,
                  color: AppColors.primary(brightness),
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.equipment.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    if (widget.equipment.brand != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.equipment.brand!,
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (widget.equipment.purchaseDate != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Mua ${_formatDate(widget.equipment.purchaseDate!)}',
                        style: TextStyle(
                          color: AppColors.textTertiary(brightness),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textTertiary(brightness)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddEquipmentSheet extends StatefulWidget {
  const _AddEquipmentSheet();

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  String _selectedType = 'cue';
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(brightness),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.add_circle_outline, color: AppColors.primary(brightness), size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Thêm dụng cụ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.textSecondary(brightness)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Type selector
          Text(
            'Loại dụng cụ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _TypeChip(label: 'Cue', value: 'cue', selected: _selectedType == 'cue', onTap: () => setState(() => _selectedType = 'cue')),
              _TypeChip(label: 'Shaft', value: 'shaft', selected: _selectedType == 'shaft', onTap: () => setState(() => _selectedType = 'shaft')),
              _TypeChip(label: 'Tip', value: 'tip', selected: _selectedType == 'tip', onTap: () => setState(() => _selectedType = 'tip')),
              _TypeChip(label: 'Phụ kiện', value: 'accessory', selected: _selectedType == 'accessory', onTap: () => setState(() => _selectedType = 'accessory')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          TextField(
            controller: _nameController,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: InputDecoration(
              labelText: 'Tên dụng cụ',
              labelStyle: TextStyle(color: AppColors.textSecondary(brightness)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.primary(brightness), width: 2),
              ),
              filled: true,
              fillColor: AppColors.background(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _brandController,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
            decoration: InputDecoration(
              labelText: 'Thương hiệu',
              labelStyle: TextStyle(color: AppColors.textSecondary(brightness)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border(brightness)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.primary(brightness), width: 2),
              ),
              filled: true,
              fillColor: AppColors.background(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          _PrimaryButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã thêm dụng cụ!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
            label: 'Thêm',
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _PrimaryButton({required this.onPressed, required this.label});

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
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.primary(brightness).withValues(alpha: 0.3),
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

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary(brightness) : AppColors.background(brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: selected ? AppColors.primary(brightness) : AppColors.border(brightness),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onPrimary(brightness) : AppColors.textSecondary(brightness),
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _EquipmentDetailSheet extends StatelessWidget {
  final Equipment equipment;

  const _EquipmentDetailSheet({required this.equipment});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(brightness),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.straighten,
                  color: AppColors.primary(brightness),
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    if (equipment.brand != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        equipment.brand!,
                        style: TextStyle(color: AppColors.textSecondary(brightness)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          if (equipment.purchaseDate != null)
            _DetailRow(
              icon: Icons.calendar_today,
              iconColor: AppColors.primary(brightness),
              label: 'Ngày mua',
              value: '${equipment.purchaseDate!.day}/${equipment.purchaseDate!.month}/${equipment.purchaseDate!.year}',
            ),

          if (equipment.notes != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              icon: Icons.note,
              iconColor: AppColors.warning,
              label: 'Ghi chú',
              value: equipment.notes!,
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Đã xóa dụng cụ'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  label: const Text('Xóa', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PrimaryButton(
                  onPressed: () => Navigator.pop(context),
                  label: 'Đóng',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary(brightness),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
