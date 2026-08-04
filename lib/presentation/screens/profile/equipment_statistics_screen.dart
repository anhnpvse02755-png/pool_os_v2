import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Statistics Screen — V1 capability parity.
///
/// Renders:
///   - Total value + per-category breakdown
///   - Top 3 most-used cues (favorite cue)
///   - Maintenance reminders (tips > 6 months)
///   - Cost summary
class EquipmentStatisticsScreen extends ConsumerWidget {
  const EquipmentStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Statistics'),
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          final cues =
              items.where((e) => e.category == 'cue' && !e.isArchived).toList();
          final valueByCategory = _valueByCategory(items);
          final totalValue = items.fold<double>(
              0, (s, e) => s + (e.currentValue ?? 0));
          final reminders = _maintenanceReminders(items);
          final favorite = cues.isEmpty
              ? null
              : (cues..sort((a, b) =>
                      (b.usageHours ?? 0).compareTo(a.usageHours ?? 0)))
                  .first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summaryCard(totalValue, items.length, reminders.length),
              const SizedBox(height: 16),
              _favoriteCard(favorite),
              const SizedBox(height: 16),
              _valueBreakdown(valueByCategory),
              const SizedBox(height: 16),
              _reminderCard(reminders),
            ],
          );
        },
      ),
    );
  }

  Map<String, double> _valueByCategory(List<Equipment> items) {
    final out = <String, double>{};
    for (final e in items) {
      out[e.category] = (out[e.category] ?? 0) + (e.currentValue ?? 0);
    }
    return out;
  }

  List<Equipment> _maintenanceReminders(List<Equipment> items) {
    return items.where((e) {
      if (e.category != 'cue' || e.lastTipChange == null) return false;
      return DateTime.now()
              .difference(e.lastTipChange!)
              .inDays >
          EquipmentConstants.tipReplacementDays;
    }).toList();
  }

  Widget _summaryCard(double totalValue, int total, int reminders) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _metricBox('Total items', '$total'),
            const SizedBox(width: 8),
            _metricBox('Total value', '\$${totalValue.toStringAsFixed(0)}'),
            const SizedBox(width: 8),
            _metricBox('Reminders', '$reminders'),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _favoriteCard(Equipment? favorite) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favorite Cue',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            if (favorite == null)
              const Text('Chưa có cue nào.')
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star, color: Colors.amber, size: 32),
                title: Text(favorite.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${favorite.usageHours?.toStringAsFixed(0) ?? 0} h used · '
                    '${favorite.weight?.toStringAsFixed(1) ?? "—"} oz'),
                trailing: Builder(builder: (innerCtx) {
                  return TextButton(
                    onPressed: () =>
                        innerCtx.push('/profile/equipment/${favorite.id}'),
                    child: const Text('View'),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _valueBreakdown(Map<String, double> valueByCategory) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cost Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            if (valueByCategory.isEmpty)
              const Text('Chưa có dữ liệu giá trị.')
            else
              ...valueByCategory.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(_iconFor(e.key),
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(EquipmentConstants
                                  .categoryLabels[e.key] ??
                              e.key),
                        ),
                        Text('\$${e.value.toStringAsFixed(0)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _reminderCard(List<Equipment> reminders) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: reminders.isEmpty
          ? null
          : Colors.amber.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Maintenance Reminders',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                if (reminders.isNotEmpty)
                  Icon(Icons.warning_amber, color: Colors.amber.shade700),
              ],
            ),
            const SizedBox(height: 12),
            if (reminders.isEmpty)
              const Text('Không có reminder nào.')
            else
              ...reminders.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.build, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.name)),
                        Builder(builder: (innerCtx) {
                        return TextButton(
                          onPressed: () =>
                              innerCtx.push('/profile/equipment/${e.id}'),
                          child: const Text('Update'),
                        );
                      }),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String c) {
    switch (c) {
      case 'cue':
        return Icons.straighten;
      case 'shaft':
        return Icons.linear_scale;
      case 'tip':
        return Icons.circle_outlined;
      case 'case':
        return Icons.work_outline;
      case 'glove':
        return Icons.pan_tool;
      case 'extension':
        return Icons.power;
      case 'chalk':
        return Icons.color_lens_outlined;
    }
    return Icons.handyman_outlined;
  }
}