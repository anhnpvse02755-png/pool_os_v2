import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/equipment.dart';
import '../../../data/models/market_cues.dart';

// ============================================================================
// Comparison entry — chung cho ca Equipment (so huu) va MarketCue (thi truong).
// ============================================================================
sealed class CompareItem {}

class OwnedItem extends CompareItem {
  final Equipment eq;
  OwnedItem(this.eq);
}

class MarketItem extends CompareItem {
  final MarketCue cue;
  MarketItem(this.cue);
}

// ============================================================================
// PROVIDER
// ============================================================================
final _selectedItemsProvider =
    StateNotifierProvider<_SelectedItemsNotifier, List<CompareItem>>((ref) {
  return _SelectedItemsNotifier();
});

class _SelectedItemsNotifier extends StateNotifier<List<CompareItem>> {
  _SelectedItemsNotifier() : super([]);

  void setItems(List<CompareItem> items) => state = items;

  void toggle(CompareItem item) {
    if (state.contains(item)) {
      state = state.where((i) => i != item).toList();
    } else {
      if (state.length >= 4) return; // toi da 4
      state = [...state, item];
    }
  }

  void clear() => state = [];
}

// ============================================================================
// SCREEN
// ============================================================================
class EquipmentComparisonScreen extends ConsumerStatefulWidget {
  /// Id cua Equipment (so huu) can chon san — tu router ?ids=eq1,eq2
  final List<String> equipmentIds;

  const EquipmentComparisonScreen({super.key, required this.equipmentIds});

  @override
  ConsumerState<EquipmentComparisonScreen> createState() =>
      _EquipmentComparisonScreenState();
}

class _EquipmentComparisonScreenState
    extends ConsumerState<EquipmentComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Tab hien tai doc thang tu _tabController; chi can ve lai.
        setState(() {});
      }
    });
    // Dua id tu router vao state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(_selectedItemsProvider.notifier);
      // O day chua co data, nen chi set rong — se load lai sau
      notifier.clear();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final selected = ref.watch(_selectedItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'So sánh',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (selected.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(_selectedItemsProvider.notifier).clear(),
              child: Text(
                'Xoá chọn',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary(brightness),
          unselectedLabelColor: AppColors.textSecondary(brightness),
          indicatorColor: AppColors.primary(brightness),
          tabs: const [
            Tab(text: 'Cơ của tôi'),
            Tab(text: 'Cơ thị trường'),
            Tab(text: 'So sánh hỗn hợp'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab content — cho chon items
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OwnedPickerTab(
                  preSelectedIds: widget.equipmentIds,
                  selected: selected,
                ),
                _MarketPickerTab(selected: selected),
                _MixedPickerTab(selected: selected),
              ],
            ),
          ),

          // Bang so sanh
          if (selected.isNotEmpty)
            _ComparisonTable(items: selected, brightness: brightness),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: CHO CHON TU CO SO HUU
// ============================================================================
class _OwnedPickerTab extends ConsumerWidget {
  final List<String> preSelectedIds;
  final List<CompareItem> selected;

  const _OwnedPickerTab({required this.preSelectedIds, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final equipmentAsync = ref.watch(allEquipmentProvider);
    final notifier = ref.read(_selectedItemsProvider.notifier);

    return equipmentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (items) {
        // Auto chon cac id tu router
        if (preSelectedIds.isNotEmpty &&
            items.any((e) => preSelectedIds.contains(e.id))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final toSelect = items
                .where((e) => preSelectedIds.contains(e.id))
                .map((e) => OwnedItem(e) as CompareItem)
                .toList();
            notifier.setItems(toSelect);
          });
        }

        final cues = items
            .where((e) => e.category == 'cue' && !e.isArchived)
            .toList();

        if (cues.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.extension,
                    size: 48, color: AppColors.textTertiary(brightness)),
                const SizedBox(height: 12),
                Text(
                  'Chưa có cơ nào trong kho',
                  style: TextStyle(color: AppColors.textSecondary(brightness)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: cues.length,
          itemBuilder: (context, i) {
            final eq = cues[i];
            final item = OwnedItem(eq);
            final isSelected = selected.contains(item);

            return _SelectableCueCard(
              title: eq.name,
              subtitle: '${eq.brandLabel}${eq.modelLabel != '—' ? ' · ${eq.modelLabel}' : ''}',
              trailing: eq.isActive
                  ? Container(
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
                    )
                  : null,
              isSelected: isSelected,
              onTap: () {
                notifier.toggle(item);
                // chuyen sang tab hỗn hợp khi chọn
              },
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// TAB 2: CHO CHON TU CO THI TRUONG
// ============================================================================
class _MarketPickerTab extends ConsumerWidget {
  final List<CompareItem> selected;
  const _MarketPickerTab({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final notifier = ref.read(_selectedItemsProvider.notifier);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: MarketCueDatabase.cues.length,
      itemBuilder: (context, i) {
        final cue = MarketCueDatabase.cues[i];
        final item = MarketItem(cue);
        final isSelected = selected.contains(item);

        return _SelectableCueCard(
          title: '${cue.brand} ${cue.model}',
          subtitle:
              '${cue.origin} · ${cue.category} · ${cue.priceRange}',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 12, color: AppColors.gold),
              const SizedBox(width: 2),
              Text(
                cue.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              if (cue.shaftDiameter != null)
                Text(
                  '⌀${cue.shaftDiameter!.toStringAsFixed(1)}mm',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary(brightness),
                  ),
                ),
            ],
          ),
          isSelected: isSelected,
          onTap: () => notifier.toggle(item),
        );
      },
    );
  }
}

// ============================================================================
// TAB 3: HỖN HỢP — CHỌN TỪ CẢ HAI NGUỒN
// ============================================================================
class _MixedPickerTab extends ConsumerWidget {
  final List<CompareItem> selected;
  const _MixedPickerTab({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final equipmentAsync = ref.watch(allEquipmentProvider);
    final notifier = ref.read(_selectedItemsProvider.notifier);

    return equipmentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Lỗi: $e')),
      data: (items) {
        final cues = items
            .where((e) => e.category == 'cue' && !e.isArchived)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (cues.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('CƠ CỦA BẠN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary(brightness),
                    )),
              ),
              ...cues.map((eq) {
                final item = OwnedItem(eq);
                return _SelectableCueCard(
                  title: eq.name,
                  subtitle:
                      '${eq.brandLabel}${eq.modelLabel != '—' ? ' · ${eq.modelLabel}' : ''}',
                  trailing: eq.isActive
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Đang dùng',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600)),
                        )
                      : null,
                  isSelected: selected.contains(item),
                  onTap: () => notifier.toggle(item),
                );
              }),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('CƠ TRÊN THỊ TRƯỜNG',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary(brightness),
                  )),
            ),
            ...MarketCueDatabase.cues.map((cue) {
              final item = MarketItem(cue);
              return _SelectableCueCard(
                title: '${cue.brand} ${cue.model}',
                subtitle: '${cue.origin} · ${cue.priceRange}',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: AppColors.gold),
                    const SizedBox(width: 2),
                    Text(
                      cue.rating.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                isSelected: selected.contains(item),
                onTap: () => notifier.toggle(item),
              );
            }),
          ],
        );
      },
    );
  }
}

// ============================================================================
// CARD CHON ITEM
// ============================================================================
class _SelectableCueCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCueCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary(brightness).withValues(alpha: 0.1)
                : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.primary(brightness)
                    : AppColors.border(brightness),
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BANG SO SANH
// ============================================================================
class _ComparisonTable extends StatelessWidget {
  final List<CompareItem> items;
  final Brightness brightness;

  const _ComparisonTable({required this.items, required this.brightness});

  // Lay gia tri cua mot thuoc tinh, tra null neu item khong co gia tri
  String? _val(CompareItem item, String field) {
    return switch (item) {
      OwnedItem(:final eq) => _eqVal(eq, field),
      MarketItem(:final cue) => _cueVal(cue, field),
    };
  }

  String? _eqVal(Equipment eq, String f) {
    return switch (f) {
      'brand' => eq.brandLabel,
      'model' => eq.modelLabel,
      'cueType' => eq.cueType ?? '—',
      'shaft' => eq.shaftLabel,
      'tip' => eq.tipLabel,
      'tipDiameter' => eq.tipDiameter?.toStringAsFixed(2),
      'tipHardness' => eq.tipHardness ?? '—',
      'weight' => eq.weight?.toStringAsFixed(1),
      'balance' => eq.balance ?? '—',
      'joint' => eq.joint ?? '—',
      'wrap' => eq.wrap ?? '—',
      'shaftDiameter' => eq.shaftDiameter?.toStringAsFixed(2),
      'condition' => eq.condition ?? '—',
      'usageHours' => eq.usageHours?.toStringAsFixed(0),
      'currentValue' => eq.currentValue?.toStringAsFixed(0),
      'priceRange' => null, // owned khong co gia
      'origin' => null,
      _ => null,
    };
  }

  String? _cueVal(MarketCue cue, String f) {
    return switch (f) {
      'brand' => cue.brand,
      'model' => cue.model,
      'cueType' => cue.cueType,
      'shaft' => cue.shaft,
      'tip' => cue.tip,
      'tipDiameter' => null, // tip string, khong tach dc
      'tipHardness' => cue.tipHardness ?? '—',
      'weight' => cue.weight.toStringAsFixed(1),
      'balance' => '—', // market cue khong co balance
      'joint' => cue.joint,
      'wrap' => cue.wrap,
      'shaftDiameter' => cue.shaftDiameter?.toStringAsFixed(2),
      'condition' => null,
      'usageHours' => null,
      'currentValue' => null,
      'priceRange' => cue.priceRange,
      'origin' => cue.origin,
      _ => null,
    };
  }

  bool _hasAnyValue(String field) =>
      items.any((item) => _val(item, field) != null);

  @override
  Widget build(BuildContext context) {
    // Chi hien cac dong co gia tri trong it nhat 1 item
    final fields = [
      'brand',
      'model',
      'cueType',
      'shaft',
      'tip',
      'tipDiameter',
      'tipHardness',
      'shaftDiameter',
      'weight',
      'balance',
      'joint',
      'wrap',
      'condition',
      'usageHours',
      'currentValue',
      'priceRange',
      'origin',
    ].where((f) => _hasAnyValue(f)).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(
          top: BorderSide(color: AppColors.border(brightness)),
        ),
      ),
      child: Column(
        children: [
          // Header — ten cac item
          Container(
            color: AppColors.background(brightness),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text('Thông số',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.textSecondary(brightness),
                      )),
                ),
                ...items.map((item) {
                  final name = switch (item) {
                    OwnedItem(:final eq) => eq.name,
                    MarketItem(:final cue) => '${cue.brand} ${cue.model}',
                  };
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary(brightness),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary(brightness),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Cac dong
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: fields.map((field) {
                  final label = switch (field) {
                    'brand' => 'Hãng',
                    'model' => 'Model',
                    'cueType' => 'Loại',
                    'shaft' => 'Thân cơ',
                    'tip' => 'Đầu cơ',
                    'tipDiameter' => 'ĐK đầu (mm)',
                    'tipHardness' => 'Độ cứng',
                    'shaftDiameter' => 'ĐK thân (mm)',
                    'weight' => 'Trọng lượng',
                    'balance' => 'Cân bằng',
                    'joint' => 'Joint',
                    'wrap' => 'Wrap',
                    'condition' => 'Tình trạng',
                    'usageHours' => 'Giờ sử dụng',
                    'currentValue' => 'Giá trị',
                    'priceRange' => 'Giá thị trường',
                    'origin' => 'Xuất xứ',
                    _ => field,
                  };

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color:
                                AppColors.border(brightness).withValues(alpha: 0.5)),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(brightness),
                            ),
                          ),
                        ),
                        ...items.map((item) {
                          final v = _val(item, field);
                          final isHighlight = field == 'brand' ||
                              field == 'priceRange' ||
                              field == 'currentValue';
                          return Expanded(
                            child: Text(
                              v ?? '—',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isHighlight
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: v != null
                                    ? AppColors.textPrimary(brightness)
                                    : AppColors.textTertiary(brightness),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
