import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Detail Screen — restored V1 parity.
///
/// Displays every V1 field plus V2 extensions, broken into sections:
///   1. Identity / photos
///   2. Specs (shaft / tip / body)
///   3. Pricing & condition
///   4. Maintenance log (add / remove)
///   5. Usage statistics
///   6. Notes
class EquipmentDetailScreen extends ConsumerWidget {
  final String id;
  const EquipmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết dụng cụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Chỉnh sửa',
            onPressed: () => context.push('/profile/equipment/edit/$id'),
          ),
        ],
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          final item = items.where((e) => e.id == id).firstOrNull;
          if (item == null) {
            return const Center(child: Text('Không tìm thấy dụng cụ.'));
          }
          return _buildBody(context, ref, item);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Equipment item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildIdentityCard(context, item),
        const SizedBox(height: 16),
        if (item.category == 'cue') ...[
          _buildSpecsCard(context, item),
          const SizedBox(height: 16),
        ],
        _buildPricingCard(context, item),
        const SizedBox(height: 16),
        _buildMaintenanceCard(context, ref, item),
        const SizedBox(height: 16),
        _buildStatsCard(context, ref, item),
        if (item.notes != null && item.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_iconFor(item),
                      color: AppTheme.primaryGreen, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        '${EquipmentConstants.categoryLabels[item.category] ?? item.category}'
                        '${item.cueType != null ? " · ${EquipmentConstants.cueTypeLabels[item.cueType]}" : ""}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (item.isActive)
                            const _RoleBadge('Active Cue', Colors.green),
                          if (item.isBreakCue)
                            const _RoleBadge('Active Break', Colors.orange),
                          if (item.isJumpCue)
                            const _RoleBadge('Active Jump', Colors.blue),
                          if (item.isArchived)
                            const _RoleBadge('Archived', Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (item.imageUrls.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrls[i],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade400),
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, color: Colors.grey.shade400),
                      const SizedBox(height: 4),
                      Text(
                        'Chưa có ảnh — thêm trong Edit',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ===========================================================================
  // Specs (cue)
  // ===========================================================================

  Widget _buildSpecsCard(BuildContext context, Equipment item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Specifications'),
            const SizedBox(height: 12),
            _row('Brand', item.brandLabel),
            _row('Model', item.modelLabel),
            _row('Shaft', item.shaftLabel),
            _row('Tip', item.tipLabel),
            _row('Tip Diameter',
                item.tipDiameter?.toStringAsFixed(2) ?? '—'),
            _row('Weight',
                item.weight != null ? '${item.weight!.toStringAsFixed(1)} oz' : '—'),
            _row('Balance', item.balance ?? '—'),
            _row('Joint', item.joint ?? '—'),
            _row('Wrap', item.wrap ?? '—'),
            _row('Ferrule', item.ferrule ?? '—'),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Pricing / purchase
  // ===========================================================================

  Widget _buildPricingCard(BuildContext context, Equipment item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Purchase & Condition'),
            const SizedBox(height: 12),
            _row('Purchase Date',
                _formatDate(item.purchaseDate)),
            _row('Purchase Price',
                item.purchasePrice != null ? '\$${item.purchasePrice!.toStringAsFixed(2)}' : '—'),
            _row('Current Value',
                item.currentValue != null ? '\$${item.currentValue!.toStringAsFixed(2)}' : '—'),
            _row('Condition', item.condition ?? '—'),
            _row('Usage Hours',
                item.usageHours != null ? '${item.usageHours!.toStringAsFixed(0)} h' : '—'),
            _row('Last Tip Change',
                _formatDate(item.lastTipChange)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Maintenance log
  // ===========================================================================

  Widget _buildMaintenanceCard(
      BuildContext context, WidgetRef ref, Equipment item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _SectionTitle('Maintenance Log'),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddMaintenanceDialog(context, ref, item),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (item.maintenanceHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Chưa có lịch sử bảo trì.',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              )
            else
              ...item.maintenanceHistory.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.build, color: Colors.orange),
                      title: Text(entry.description),
                      subtitle: Text(
                        '${_formatDate(entry.date)} · ${entry.type}'
                        '${entry.cost != null ? " · \$${entry.cost!.toStringAsFixed(2)}" : ""}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
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
      ),
    );
  }

  // ===========================================================================
  // Usage stats
  // ===========================================================================

  Widget _buildStatsCard(
      BuildContext context, WidgetRef ref, Equipment item) {
    final statsAsync = ref.watch(equipmentStatsProvider(item.id));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Usage Statistics'),
            const SizedBox(height: 12),
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Lỗi: $e'),
              data: (stats) => Row(
                children: [
                  Expanded(child: _statBox('Matches', '${stats.matchCount}')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _statBox(
                          'Win rate',
                          stats.matchCount == 0
                              ? '—'
                              : '${(stats.winRate * 100).toStringAsFixed(0)}%')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _statBox(
                          'Racks', '${stats.racks}')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Notes
  // ===========================================================================

  Widget _buildNotesCard(BuildContext context, Equipment item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Notes'),
            const SizedBox(height: 8),
            Text(item.notes!),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
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

  void _showAddMaintenanceDialog(
      BuildContext context, WidgetRef ref, Equipment item) {
    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String type = 'tip_change';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: const Text('Thêm bảo trì'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Loại'),
                  items: const [
                    DropdownMenuItem(value: 'tip_change', child: Text('Tip change')),
                    DropdownMenuItem(value: 'rewrap', child: Text('Re-wrap')),
                    DropdownMenuItem(value: 'shaft_replacement', child: Text('Shaft replacement')),
                    DropdownMenuItem(value: 'cleaning', child: Text('Cleaning')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setSt(() => type = v ?? 'other'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: costCtrl,
                  decoration: const InputDecoration(labelText: 'Chi phí (USD)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy')),
            FilledButton(
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
              child: const Text('Lưu'),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
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
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }
}
