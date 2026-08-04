import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';

/// Side-by-side comparison of 2-4 cues.
///
/// V1 parity: FEATURE_012 v2 — Compare (N) → EquipmentComparisonScreen.
class EquipmentComparisonScreen extends ConsumerWidget {
  final List<String> equipmentIds;
  const EquipmentComparisonScreen({super.key, required this.equipmentIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentAsync = ref.watch(allEquipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare (${equipmentIds.length})'),
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          final selected =
              items.where((e) => equipmentIds.contains(e.id)).toList();
          if (selected.isEmpty) {
            return const Center(child: Text('Không có dụng cụ nào được chọn.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: selected
                  .map((c) => DataColumn(
                        label: Text(c.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ))
                  .toList(),
              rows: _rows(selected),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _rows(List<Equipment> cues) {
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
      return DataRow(cells: [
        DataCell(Text(entry.key,
            style: TextStyle(
                color: Colors.grey.shade700, fontWeight: FontWeight.w600))),
        ...cells.map((v) => DataCell(Text(v.isEmpty ? '—' : v))),
      ]);
    }).toList();
  }
}