import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Side-by-side comparison of 2-4 cues with Minimalist Luxury design.
class EquipmentComparisonScreen extends ConsumerWidget {
  final List<String> equipmentIds;
  const EquipmentComparisonScreen({super.key, required this.equipmentIds});

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
          'Compare (${equipmentIds.length})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary(brightness)),
          onPressed: () => Navigator.of(context).pop(),
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
          final selected =
              items.where((e) => equipmentIds.contains(e.id)).toList();
          if (selected.isEmpty) {
            return const Center(
              child: Text('Không có dụng cụ nào được chọn.'),
            );
          }
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: AppSpacing.xl,
                headingRowColor: WidgetStateProperty.all(AppColors.pastelFor(0, brightness)),
                columns: selected
                    .map((c) => DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary(brightness),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              c.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.onPrimary(brightness),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                rows: _rows(selected, brightness),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _rows(List<Equipment> cues, Brightness brightness) {
    final rows = <String, String>{
      'Brand': '',
      'Model': '',
      'Cue Type': '',
      'Shaft': '',
      'Tip': '',
      'Tip Diameter': '',
      'Weight': '',
      'Balance': '',
      'Joint': '',
      'Wrap': '',
      'Usage Hours': '',
      'Condition': '',
      'Current Value': '',
    };

    for (final c in cues) {
      rows['Brand'] = '${rows['Brand']}|${c.brandLabel}';
      rows['Model'] = '${rows['Model']}|${c.modelLabel}';
      rows['Cue Type'] =
          '${rows['Cue Type']}|${c.cueType == null ? "—" : (c.cueType)}';
      rows['Shaft'] = '${rows['Shaft']}|${c.shaftLabel}';
      rows['Tip'] = '${rows['Tip']}|${c.tipLabel}';
      rows['Tip Diameter'] =
          '${rows['Tip Diameter']}|${c.tipDiameter?.toStringAsFixed(2) ?? "—"}';
      rows['Weight'] =
          '${rows['Weight']}|${c.weight != null ? "${c.weight!.toStringAsFixed(1)} oz" : "—"}';
      rows['Balance'] = '${rows['Balance']}|${c.balance ?? "—"}';
      rows['Joint'] = '${rows['Joint']}|${c.joint ?? "—"}';
      rows['Wrap'] = '${rows['Wrap']}|${c.wrap ?? "—"}';
      rows['Usage Hours'] =
          '${rows['Usage Hours']}|${c.usageHours != null ? "${c.usageHours!.toStringAsFixed(0)} h" : "—"}';
      rows['Condition'] = '${rows['Condition']}|${c.condition ?? "—"}';
      rows['Current Value'] =
          '${rows['Current Value']}|${c.currentValue != null ? "\$${c.currentValue!.toStringAsFixed(0)}" : "—"}';
    }

    return rows.entries.map((entry) {
      final cells = entry.value.split('|').skip(1).toList();
      return DataRow(
        color: WidgetStateProperty.all(
          entry.key.contains('Tổng') ? AppColors.pastelFor(0, brightness) : Colors.transparent,
        ),
        cells: [
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  color: AppColors.textSecondary(brightness),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          ...cells.map((v) => DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.sm,
                  ),
                  child: Text(
                    v.isEmpty ? '—' : v,
                    style: TextStyle(
                      color: AppColors.textPrimary(brightness),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              )),
        ],
      );
    }).toList();
  }
}
