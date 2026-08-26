import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Statistics Screen with Minimalist Luxury design.
class EquipmentStatisticsScreen extends ConsumerWidget {
  const EquipmentStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'Equipment Statistics',
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _summaryCard(totalValue, items.length, reminders.length),
              const SizedBox(height: AppSpacing.md),
              _favoriteCard(context, favorite),
              const SizedBox(height: AppSpacing.md),
              _valueBreakdown(context, valueByCategory),
              const SizedBox(height: AppSpacing.md),
              _reminderCard(context, reminders),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: _metricBox('Total items', '$total', Colors.white)),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _metricBox('Total value', '\$${totalValue.toStringAsFixed(0)}', Colors.white)),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _metricBox('Reminders', '$reminders', Colors.white)),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _favoriteCard(BuildContext context, Equipment? favorite) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.star, color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Favorite Cue',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (favorite == null)
            const Text(
              'Chưa có cue nào.',
              style: TextStyle(color: AppColors.lightTextSecondary),
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.straighten, color: AppColors.warning, size: 24),
              ),
              title: Text(
                favorite.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              subtitle: Text(
                '${favorite.usageHours?.toStringAsFixed(0) ?? 0} h used · '
                '${favorite.weight?.toStringAsFixed(1) ?? "—"} oz',
                style: const TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: TextButton(
                onPressed: () =>
                    context.push('/profile/equipment/${favorite.id}'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
                child: const Text('View'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _valueBreakdown(BuildContext context, Map<String, double> valueByCategory) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Cost Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (valueByCategory.isEmpty)
            const Text(
              'Chưa có dữ liệu giá trị.',
              style: TextStyle(color: AppColors.lightTextSecondary),
            )
          else
            ...valueByCategory.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtleLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(_iconFor(e.key), size: 14, color: AppColors.accent),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          EquipmentConstants.categoryLabels[e.key] ?? e.key,
                          style: const TextStyle(color: AppColors.lightTextPrimary),
                        ),
                      ),
                      Text(
                        '\$${e.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _reminderCard(BuildContext context, List<Equipment> reminders) {
    final hasReminders = reminders.isNotEmpty;
    return Container(
      decoration: _cardDecoration(
        bgColor: hasReminders ? const Color(0xFFFEF3C7) : null,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: hasReminders
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  hasReminders ? Icons.warning_amber : Icons.build_outlined,
                  color: hasReminders ? AppColors.warning : AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Maintenance Reminders',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (reminders.isEmpty)
            const Text(
              'Không có reminder nào.',
              style: TextStyle(color: AppColors.lightTextSecondary),
            )
          else
            ...reminders.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(Icons.build, color: AppColors.warning, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          e.name,
                          style: const TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Builder(builder: (innerCtx) {
                        return TextButton(
                          onPressed: () =>
                              innerCtx.push('/profile/equipment/${e.id}'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                          ),
                          child: const Text('Update'),
                        );
                      }),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({Color? bgColor}) {
    return BoxDecoration(
      color: bgColor ?? AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(color: AppColors.lightBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
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
