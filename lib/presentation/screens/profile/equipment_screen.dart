import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  bool _selectionMode = false;
  final Set<String> _selected = {};

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      if (_selected.isEmpty) _selectionMode = false;
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selected.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _compare() {
    if (_selected.isEmpty) return;
    final ids = _selected.join(',');
    _exitSelectionMode();
    context.push('/profile/equipment/compare?ids=$ids');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final notifier = ref.read(equipmentNotifierProvider.notifier);
    final equipmentState = ref.watch(equipmentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: _selectionMode ? _selectionAppBar(brightness) : _normalAppBar(brightness),
      body: equipmentState.when(
        loading: () => Center(
          child: CircularProgressIndicator(
              color: AppColors.primary(brightness)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Lỗi: $e',
                  style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(brightness);
          }
          return _buildEquipmentList(
              context, brightness, items, notifier);
        },
      ),
      floatingActionButton: _selectionMode
          ? (_selected.length >= 2
              ? FloatingActionButton.extended(
                  onPressed: _compare,
                  backgroundColor: AppColors.primary(brightness),
                  icon: Icon(Icons.compare_arrows,
                      color: AppColors.onPrimary(brightness)),
                  label: Text(
                    'So sánh (${_selected.length})',
                    style: TextStyle(
                        color: AppColors.onPrimary(brightness),
                        fontWeight: FontWeight.w600),
                  ),
                )
              : null)
          : FloatingActionButton.extended(
              onPressed: () => context.push('/profile/equipment/add'),
              backgroundColor: AppColors.primary(brightness),
              icon: Icon(Icons.add, color: AppColors.onPrimary(brightness)),
              label: Text(
                'Thêm dụng cụ',
                style: TextStyle(
                    color: AppColors.onPrimary(brightness),
                    fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  // ── AppBar normal ──────────────────────────────────────────────────────────

  PreferredSizeWidget _normalAppBar(Brightness brightness) {
    return AppBar(
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
        icon: Icon(Icons.arrow_back_ios,
            color: AppColors.textPrimary(brightness)),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.compare_arrows,
              color: AppColors.primary(brightness)),
          tooltip: 'So sánh cơ',
          onPressed: _enterSelectionMode,
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline,
              color: AppColors.primary(brightness)),
          onPressed: () => context.push('/profile/equipment/add'),
        ),
      ],
    );
  }

  // ── AppBar selection ───────────────────────────────────────────────────────

  PreferredSizeWidget _selectionAppBar(Brightness brightness) {
    return AppBar(
      backgroundColor: AppColors.background(brightness),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.textPrimary(brightness)),
        onPressed: _exitSelectionMode,
      ),
      title: Text(
        '${_selected.length} đã chọn',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(brightness),
        ),
      ),
      centerTitle: true,
      actions: [
        if (_selected.length >= 2)
          TextButton.icon(
            onPressed: _compare,
            icon: Icon(Icons.compare_arrows,
                color: AppColors.primary(brightness)),
            label: Text('So sánh',
                style: TextStyle(color: AppColors.primary(brightness))),
          ),
      ],
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(Brightness brightness) {
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
              style: TextStyle(color: AppColors.textSecondary(brightness)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Equipment list ─────────────────────────────────────────────────────────

  Widget _buildEquipmentList(
    BuildContext context,
    Brightness brightness,
    List<Equipment> items,
    EquipmentNotifier notifier,
  ) {
    final grouped = <String, List<Equipment>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
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
                        color: _typeColor(entry.key, brightness)
                            .withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        _typeIcon(entry.key),
                        size: 16,
                        color: _typeColor(entry.key, brightness),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _typeName(entry.key),
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
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                            color: AppColors.border(brightness)),
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
                    selectionMode: _selectionMode,
                    isSelected: _selected.contains(item.id),
                    onTap: () {
                      if (_selectionMode) {
                        _toggleSelection(item.id);
                      } else {
                        _showDetail(context, brightness, item, notifier);
                      }
                    },
                    onCheckbox: () => _toggleSelection(item.id),
                  ).animate().fadeIn(
                        duration: 300.ms,
                        delay: (index * 100).ms,
                      ),
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

  // ── Detail bottom sheet ────────────────────────────────────────────────────

  void _showDetail(BuildContext context, Brightness brightness,
      Equipment eq, EquipmentNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(brightness),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => _EquipmentDetailSheet(
        equipment: eq,
        onDeleted: () {
          notifier.delete(eq.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  IconData _typeIcon(String type) {
    switch (type) {
      case 'cue':
        return Icons.straighten;
      case 'shaft':
        return Icons.linear_scale;
      case 'tip':
        return Icons.circle_outlined;
      case 'chalk':
        return Icons.brush;
      case 'glove':
        return Icons.pan_tool_outlined;
      case 'case':
        return Icons.luggage_outlined;
      case 'extension':
        return Icons.straighten;
      default:
        return Icons.handyman_outlined;
    }
  }

  String _typeName(String type) {
    switch (type) {
      case 'cue':
        return 'Cue';
      case 'shaft':
        return 'Shaft';
      case 'tip':
        return 'Tip';
      case 'chalk':
        return 'Phấn';
      case 'glove':
        return 'Găng';
      case 'case':
        return 'Túi cơ';
      case 'extension':
        return 'Gậy nối';
      default:
        return type;
    }
  }

  Color _typeColor(String type, Brightness brightness) {
    switch (type) {
      case 'cue':
        return AppColors.primary(brightness);
      case 'shaft':
        return AppColors.primary(brightness);
      case 'tip':
        return AppColors.warning;
      default:
        return AppColors.textSecondary(brightness);
    }
  }
}

// =============================================================================
// Equipment Card — hỗ trợ selection mode
// =============================================================================
class _EquipmentCard extends StatefulWidget {
  final Equipment equipment;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onCheckbox;

  const _EquipmentCard({
    required this.equipment,
    required this.selectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onCheckbox,
  });

  @override
  State<_EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<_EquipmentCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final eq = widget.equipment;

    return GestureDetector(
      onTapDown: widget.selectionMode ? null : (_) => setState(() => _scale = 0.98),
      onTapUp: widget.selectionMode ? null : (_) => setState(() => _scale = 1.0),
      onTapCancel:
          widget.selectionMode ? null : () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: AppShadows.soft(brightness),
          ),
          child: Row(
            children: [
              if (widget.selectionMode) ...[
                GestureDetector(
                  onTap: widget.onCheckbox,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.primary(brightness)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColors.primary(brightness)
                            : AppColors.border(brightness),
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? Icon(Icons.check,
                            size: 16,
                            color: AppColors.onPrimary(brightness))
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _catIcon(eq.category),
                  color: AppColors.primary(brightness),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            eq.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary(brightness),
                            ),
                          ),
                        ),
                        if (eq.isActive)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Đang dùng',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (eq.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        eq.brand!,
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (eq.condition != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tình trạng: ${eq.condition}',
                        style: TextStyle(
                          color: AppColors.textTertiary(brightness),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!widget.selectionMode)
                Icon(Icons.chevron_right,
                    color: AppColors.textTertiary(brightness)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _catIcon(String category) {
    switch (category) {
      case 'cue':
        return Icons.straighten;
      case 'shaft':
        return Icons.linear_scale;
      case 'tip':
        return Icons.circle_outlined;
      case 'chalk':
        return Icons.brush;
      case 'glove':
        return Icons.pan_tool_outlined;
      case 'case':
        return Icons.luggage_outlined;
      default:
        return Icons.handyman_outlined;
    }
  }
}

// =============================================================================
// Detail bottom sheet
// =============================================================================
class _EquipmentDetailSheet extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onDeleted;

  const _EquipmentDetailSheet({
    required this.equipment,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final eq = equipment;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
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

              // Header
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                eq.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: AppColors.textPrimary(brightness),
                                ),
                              ),
                            ),
                            if (eq.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Đang dùng',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (eq.brand != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            eq.brand!,
                            style: TextStyle(
                                color: AppColors.textSecondary(brightness)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Thông số kỹ thuật
              if (_hasSpecs(eq)) ...[
                _sectionTitle('Thông số kỹ thuật', brightness),
                const SizedBox(height: AppSpacing.md),
                ..._specRows(eq, brightness),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Thông tin sở hữu
              if (eq.purchaseDate != null ||
                  eq.purchasePrice != null ||
                  eq.currentValue != null ||
                  eq.condition != null) ...[
                _sectionTitle('Thông tin sở hữu', brightness),
                const SizedBox(height: AppSpacing.md),
                if (eq.purchaseDate != null)
                  _detailRow(Icons.calendar_today,
                      AppColors.primary(brightness), 'Ngày mua',
                      '${eq.purchaseDate!.day}/${eq.purchaseDate!.month}/${eq.purchaseDate!.year}'),
                if (eq.purchasePrice != null)
                  _detailRow(Icons.payments_outlined,
                      AppColors.success, 'Giá mua',
                      '${eq.purchasePrice!.toStringAsFixed(0)} VNĐ'),
                if (eq.currentValue != null)
                  _detailRow(Icons.account_balance_wallet_outlined,
                      AppColors.warning, 'Giá trị hiện tại',
                      '${eq.currentValue!.toStringAsFixed(0)} VNĐ'),
                if (eq.condition != null)
                  _detailRow(Icons.health_and_safety_outlined,
                      AppColors.primary(brightness), 'Tình trạng', eq.condition!),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Ghi chú
              if (eq.notes != null && eq.notes!.isNotEmpty) ...[
                _sectionTitle('Ghi chú', brightness),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background(brightness),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    eq.notes!,
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(
                            '/profile/equipment/compare?ids=${eq.id}');
                      },
                      icon: Icon(Icons.compare_arrows,
                          color: AppColors.primary(brightness)),
                      label: Text('So sánh',
                          style:
                              TextStyle(color: AppColors.primary(brightness))),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary(brightness)),
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context, eq.name, onDeleted);
                      },
                      icon:
                          const Icon(Icons.delete_outline, color: AppColors.error),
                      label: const Text('Xóa',
                          style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(brightness),
                    foregroundColor: AppColors.onPrimary(brightness),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasSpecs(Equipment eq) =>
      eq.weight != null ||
      eq.shaftMaterial != null ||
      eq.shaftDiameter != null ||
      eq.tipBrand != null ||
      eq.tipDiameter != null ||
      eq.tipHardness != null ||
      eq.balance != null ||
      eq.joint != null ||
      eq.wrap != null ||
      eq.ferrule != null;

  List<Widget> _specRows(Equipment eq, Brightness brightness) {
    final rows = <Widget>[];
    if (eq.weight != null)
      rows.add(_detailRow(Icons.fitness_center, AppColors.primary(brightness),
          'Trọng lượng', '${eq.weight!.toStringAsFixed(1)} oz'));
    if (eq.shaftMaterial != null)
      rows.add(_detailRow(Icons.layers, AppColors.primary(brightness),
          'Chất liệu thân', eq.shaftMaterial!));
    if (eq.shaftDiameter != null)
      rows.add(_detailRow(Icons.straighten, AppColors.primary(brightness),
          'Đường kính thân', '${eq.shaftDiameter!.toStringAsFixed(2)} mm'));
    if (eq.tipBrand != null)
      rows.add(_detailRow(Icons.circle_outlined, AppColors.warning,
          'Thương hiệu đầu', eq.tipBrand!));
    if (eq.tipDiameter != null)
      rows.add(_detailRow(Icons.circle_outlined, AppColors.warning,
          'Đường kính đầu', '${eq.tipDiameter!.toStringAsFixed(2)} mm'));
    if (eq.tipHardness != null)
      rows.add(_detailRow(Icons.circle_outlined, AppColors.warning,
          'Độ cứng đầu', eq.tipHardness!));
    if (eq.balance != null)
      rows.add(_detailRow(Icons.balance, AppColors.primary(brightness),
          'Cân bằng', eq.balance!));
    if (eq.joint != null)
      rows.add(_detailRow(Icons.link, AppColors.primary(brightness),
          'Joint', eq.joint!));
    if (eq.wrap != null)
      rows.add(_detailRow(Icons.gesture, AppColors.primary(brightness),
          'Wrap', eq.wrap!));
    if (eq.ferrule != null)
      rows.add(_detailRow(Icons.circle, AppColors.primary(brightness),
          'Ferrule', eq.ferrule!));
    return rows;
  }

  Widget _sectionTitle(String text, Brightness brightness) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textSecondary(brightness),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, Color iconColor, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String name, VoidCallback onDeleted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa dụng cụ?'),
        content: Text('Bạn có chắc muốn xóa "$name"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleted();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa "$name"'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Xóa',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
