import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Detail Screen — restored V1 parity with Minimalist Luxury design.
class EquipmentDetailScreen extends ConsumerWidget {
  final String id;
  const EquipmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'Chi tiết dụng cụ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
            tooltip: 'Chỉnh sửa',
            onPressed: () => context.push('/profile/equipment/edit/$id'),
          ),
        ],
      ),
      body: equipmentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, st) => Center(
          child: Text(
            'Lỗi: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (items) {
          final item = items.where((e) => e.id == id).firstOrNull;
          if (item == null) {
            return const Center(
              child: Text('Không tìm thấy dụng cụ.'),
            );
          }
          return _buildBody(context, ref, item);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Equipment item) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildIdentityCard(context, item),
        const SizedBox(height: AppSpacing.md),
        if (item.category == 'cue') ...[
          _buildSpecsCard(context, item),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildPricingCard(context, item),
        const SizedBox(height: AppSpacing.md),
        _buildMaintenanceCard(context, ref, item),
        const SizedBox(height: AppSpacing.md),
        _buildStatsCard(context, ref, item),
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildNotesCard(context, item),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  // ===========================================================================
  // Identity
  // ===========================================================================

  Widget _buildIdentityCard(BuildContext context, Equipment item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(_iconFor(item), color: AppColors.accent, size: 36),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${EquipmentConstants.categoryLabels[item.category] ?? item.category}'
                      '${item.cueType != null ? " · ${EquipmentConstants.cueTypeLabels[item.cueType]}" : ""}',
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (item.isActive)
                          const _RoleBadge('Active Cue', AppColors.success),
                        if (item.isBreakCue)
                          const _RoleBadge('Active Break', AppColors.warning),
                        if (item.isJumpCue)
                          const _RoleBadge('Active Jump', AppColors.accent),
                        if (item.isArchived)
                          const _RoleBadge('Archived', AppColors.lightTextTertiary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (item.imageUrls.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.network(
                    item.imageUrls[i],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: AppColors.lightBackground,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: AppColors.lightTextTertiary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Chưa có ảnh — thêm trong Edit',
                      style: TextStyle(
                        color: AppColors.lightTextTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ===========================================================================
  // Specs (cue)
  // ===========================================================================

  Widget _buildSpecsCard(BuildContext context, Equipment item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Specifications'),
          const SizedBox(height: AppSpacing.md),
          _row('Brand', item.brandLabel),
          _row('Model', item.modelLabel),
          _row('Shaft', item.shaftLabel),
          _row('Tip', item.tipLabel),
          _row('Tip Diameter', item.tipDiameter?.toStringAsFixed(2) ?? '—'),
          _row('Weight', item.weight != null ? '${item.weight!.toStringAsFixed(1)} oz' : '—'),
          _row('Balance', item.balance ?? '—'),
          _row('Joint', item.joint ?? '—'),
          _row('Wrap', item.wrap ?? '—'),
          _row('Ferrule', item.ferrule ?? '—'),
        ],
      ),
    );
  }

  // ===========================================================================
  // Pricing / purchase
  // ===========================================================================

  Widget _buildPricingCard(BuildContext context, Equipment item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Purchase & Condition'),
          const SizedBox(height: AppSpacing.md),
          _row('Purchase Date', _formatDate(item.purchaseDate)),
          _row('Purchase Price', item.purchasePrice != null ? '\$${item.purchasePrice!.toStringAsFixed(2)}' : '—'),
          _row('Current Value', item.currentValue != null ? '\$${item.currentValue!.toStringAsFixed(2)}' : '—'),
          _row('Condition', item.condition ?? '—'),
          _row('Usage Hours', item.usageHours != null ? '${item.usageHours!.toStringAsFixed(0)} h' : '—'),
          _row('Last Tip Change', _formatDate(item.lastTipChange)),
        ],
      ),
    );
  }

  // ===========================================================================
  // Maintenance log
  // ===========================================================================

  Widget _buildMaintenanceCard(BuildContext context, WidgetRef ref, Equipment item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionTitle('Maintenance Log'),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddMaintenanceDialog(context, ref, item),
                icon: const Icon(Icons.add, size: 16, color: AppColors.accent),
                label: const Text(
                  'Add',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (item.maintenanceHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Chưa có lịch sử bảo trì.',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
            )
          else
            ...item.maintenanceHistory.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(Icons.build, color: AppColors.warning, size: 18),
                    ),
                    title: Text(
                      entry.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatDate(entry.date)} · ${entry.type}'
                      '${entry.cost != null ? " · \$${entry.cost!.toStringAsFixed(2)}" : ""}',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                      onPressed: () async {
                        final repo = ref.read(equipmentRepositoryProvider);
                        await repo.removeMaintenanceEntry(item.id, entry.id);
                        ref.invalidate(allEquipmentProvider);
                      },
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  // ===========================================================================
  // Usage stats
  // ===========================================================================

  Widget _buildStatsCard(BuildContext context, WidgetRef ref, Equipment item) {
    final statsAsync = ref.watch(equipmentStatsProvider(item.id));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Usage Statistics'),
          const SizedBox(height: AppSpacing.md),
          statsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (e, _) => Text('Lỗi: $e', style: const TextStyle(color: AppColors.error)),
            data: (stats) => Row(
              children: [
                Expanded(child: _statBox('Matches', '${stats.matchCount}')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _statBox(
                    'Win rate',
                    stats.matchCount == 0 ? '—' : '${(stats.winRate * 100).toStringAsFixed(0)}%',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _statBox('Racks', '${stats.racks}')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Notes
  // ===========================================================================

  Widget _buildNotesCard(BuildContext context, Equipment item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Notes'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.notes!,
            style: const TextStyle(color: AppColors.lightTextPrimary),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSubtleLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(Equipment e) {
    switch (e.category) {
      case 'cue':
        return Icons.straighten;
      case 'shaft':
        return Icons.linear_scale;
      case 'tip':
        return Icons.circle_outlined;
      case 'chalk':
        return Icons.color_lens_outlined;
      case 'glove':
        return Icons.pan_tool;
      case 'extension':
        return Icons.power;
      case 'case':
        return Icons.work_outline;
      case 'accessory':
        return Icons.handyman_outlined;
    }
    return Icons.inventory_2;
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}';
  }

  void _showAddMaintenanceDialog(BuildContext context, WidgetRef ref, Equipment item) {
    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String type = 'tip_change';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: const Text(
            'Thêm bảo trì',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: 'Loại',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'tip_change', child: Text('Tip change')),
                    DropdownMenuItem(value: 'rewrap', child: Text('Re-wrap')),
                    DropdownMenuItem(value: 'shaft_replacement', child: Text('Shaft replacement')),
                    DropdownMenuItem(value: 'cleaning', child: Text('Cleaning')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setSt(() => type = v ?? 'other'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: costCtrl,
                  decoration: InputDecoration(
                    labelText: 'Chi phí (USD)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                final entry = MaintenanceEntry(
                  id: 'm_${DateTime.now().microsecondsSinceEpoch}',
                  date: DateTime.now(),
                  type: type,
                  description: descCtrl.text,
                  cost: double.tryParse(costCtrl.text),
                );
                final repo = ref.read(equipmentRepositoryProvider);
                await repo.addMaintenanceEntry(item.id, entry);
                ref.invalidate(allEquipmentProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}
