import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Detail Screen — restored V1 parity with Minimalist Luxury design.
class EquipmentDetailScreen extends ConsumerWidget {
  final String id;
  const EquipmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;

    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Chi tiết dụng cụ',
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
            icon: Icon(Icons.edit_outlined, color: AppColors.primary(brightness)),
            tooltip: 'Chỉnh sửa',
            onPressed: () => context.push('/profile/equipment/edit/$id'),
          ),
        ],
      ),
      body: equipmentAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary(brightness)),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
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
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(_iconFor(item), color: AppColors.primary(brightness), size: 36),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${EquipmentConstants.categoryLabels[item.category] ?? item.category}'
                      '${item.cueType != null ? " · ${EquipmentConstants.cueTypeLabels[item.cueType]}" : ""}',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
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
                          _RoleBadge('Active Jump', AppColors.primary(brightness)),
                        if (item.isArchived)
                          _RoleBadge('Archived', AppColors.textTertiary(brightness)),
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
                      color: AppColors.background(brightness),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textTertiary(brightness),
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
                color: AppColors.background(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(brightness)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: AppColors.textTertiary(brightness),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Chưa có ảnh — thêm trong Edit',
                      style: TextStyle(
                        color: AppColors.textTertiary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Specifications'),
          const SizedBox(height: AppSpacing.md),
          _row('Brand', item.brandLabel, brightness),
          _row('Model', item.modelLabel, brightness),
          _row('Shaft', item.shaftLabel, brightness),
          _row('Tip', item.tipLabel, brightness),
          _row('Tip Diameter', item.tipDiameter?.toStringAsFixed(2) ?? '—', brightness),
          _row('Weight', item.weight != null ? '${item.weight!.toStringAsFixed(1)} oz' : '—', brightness),
          _row('Balance', item.balance ?? '—', brightness),
          _row('Joint', item.joint ?? '—', brightness),
          _row('Wrap', item.wrap ?? '—', brightness),
          _row('Ferrule', item.ferrule ?? '—', brightness),
        ],
      ),
    );
  }

  // ===========================================================================
  // Pricing / purchase
  // ===========================================================================

  Widget _buildPricingCard(BuildContext context, Equipment item) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Purchase & Condition'),
          const SizedBox(height: AppSpacing.md),
          _row('Purchase Date', _formatDate(item.purchaseDate), brightness),
          _row('Purchase Price', item.purchasePrice != null ? '\$${item.purchasePrice!.toStringAsFixed(2)}' : '—', brightness),
          _row('Current Value', item.currentValue != null ? '\$${item.currentValue!.toStringAsFixed(2)}' : '—', brightness),
          _row('Condition', item.condition ?? '—', brightness),
          _row('Usage Hours', item.usageHours != null ? '${item.usageHours!.toStringAsFixed(0)} h' : '—', brightness),
          _row('Last Tip Change', _formatDate(item.lastTipChange), brightness),
        ],
      ),
    );
  }

  // ===========================================================================
  // Maintenance log
  // ===========================================================================

  Widget _buildMaintenanceCard(BuildContext context, WidgetRef ref, Equipment item) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
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
                icon: Icon(Icons.add, size: 16, color: AppColors.primary(brightness)),
                label: Text(
                  'Add',
                  style: TextStyle(color: AppColors.primary(brightness)),
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
                style: TextStyle(color: AppColors.textSecondary(brightness)),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    subtitle: Text(
                      '${_formatDate(entry.date)} · ${entry.type}'
                      '${entry.cost != null ? " · \$${entry.cost!.toStringAsFixed(2)}" : ""}',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
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
    final brightness = Theme.of(context).brightness;

    final statsAsync = ref.watch(equipmentStatsProvider(item.id));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Usage Statistics'),
          const SizedBox(height: AppSpacing.md),
          statsAsync.when(
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.primary(brightness)),
              ),
            ),
            error: (e, _) => Text('Lỗi: $e', style: const TextStyle(color: AppColors.error)),
            data: (stats) => Row(
              children: [
                Expanded(child: _statBox('Matches', '${stats.matchCount}', brightness)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _statBox(
                    'Win rate',
                    stats.matchCount == 0 ? '—' : '${(stats.winRate * 100).toStringAsFixed(0)}%',
                    brightness,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _statBox('Racks', '${stats.racks}', brightness)),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Notes'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.notes!,
            style: TextStyle(color: AppColors.textPrimary(brightness)),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Widget _row(String label, String value, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.pastelFor(0, brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary(brightness),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
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
    final brightness = Theme.of(context).brightness;

    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String type = 'tip_change';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          backgroundColor: AppColors.surface(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            'Thêm bảo trì',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(brightness),
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
              child: Text(
                'Hủy',
                style: TextStyle(color: AppColors.textSecondary(brightness)),
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
              child: Text(
                'Lưu',
                style: TextStyle(
                  color: AppColors.primary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary(brightness),
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}
