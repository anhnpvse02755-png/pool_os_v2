import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/equipment_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Equipment Statistics Screen with Minimalist Luxury design.
class EquipmentStatisticsScreen extends ConsumerWidget {
  const EquipmentStatisticsScreen({super.key});

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
          'Equipment Statistics',
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
              _summaryCard(totalValue, items.length, reminders.length, brightness),
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

  Widget _summaryCard(double totalValue, int total, int reminders, Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(brightness),
            AppColors.primary(brightness).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(brightness).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: _metricBox('Total items', '$total', AppColors.onPrimary(brightness))),
          Container(width: 1, height: 40, color: AppColors.onPrimary(brightness).withValues(alpha: 0.3)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _metricBox('Total value', '\$${totalValue.toStringAsFixed(0)}', AppColors.onPrimary(brightness))),
          Container(width: 1, height: 40, color: AppColors.onPrimary(brightness).withValues(alpha: 0.3)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _metricBox('Reminders', '$reminders', AppColors.onPrimary(brightness))),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
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
              Text(
                'Favorite Cue',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (favorite == null)
            Text(
              'Chưa có cue nào.',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
              subtitle: Text(
                '${favorite.usageHours?.toStringAsFixed(0) ?? 0} h used · '
                '${favorite.weight?.toStringAsFixed(1) ?? "—"} oz',
                style: TextStyle(
                  color: AppColors.textSecondary(brightness),
                  fontSize: 12,
                ),
              ),
              trailing: TextButton(
                onPressed: () =>
                    context.push('/profile/equipment/${favorite.id}'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary(brightness),
                ),
                child: const Text('View'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _valueBreakdown(BuildContext context, Map<String, double> valueByCategory) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: _cardDecoration(brightness),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary(brightness), size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cost Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (valueByCategory.isEmpty)
            Text(
              'Chưa có dữ liệu giá trị.',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            )
          else
            ...valueByCategory.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.pastelFor(0, brightness),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(_iconFor(e.key), size: 14, color: AppColors.primary(brightness)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          EquipmentConstants.categoryLabels[e.key] ?? e.key,
                          style: TextStyle(color: AppColors.textPrimary(brightness)),
                        ),
                      ),
                      Text(
                        '\$${e.value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(brightness),
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
    final brightness = Theme.of(context).brightness;

    final hasReminders = reminders.isNotEmpty;
    return Container(
      decoration: _cardDecoration(
        brightness,
        bgColor: hasReminders ? AppColors.pastelFor(4, brightness) : null,
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
                      : AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  hasReminders ? Icons.warning_amber : Icons.build_outlined,
                  color: hasReminders ? AppColors.warning : AppColors.primary(brightness),
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Maintenance Reminders',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (reminders.isEmpty)
            Text(
              'Không có reminder nào.',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
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
                          style: TextStyle(
                            color: AppColors.textPrimary(brightness),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Builder(builder: (innerCtx) {
                        return TextButton(
                          onPressed: () =>
                              innerCtx.push('/profile/equipment/${e.id}'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary(brightness),
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

  BoxDecoration _cardDecoration(Brightness brightness, {Color? bgColor}) {
    return BoxDecoration(
      color: bgColor ?? AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      border: Border.all(color: AppColors.border(brightness)),
      boxShadow: AppShadows.soft(brightness),
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
