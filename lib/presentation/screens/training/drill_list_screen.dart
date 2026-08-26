import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';

class DrillListScreen extends StatefulWidget {
  final String categoryId;

  const DrillListScreen({super.key, required this.categoryId});

  @override
  State<DrillListScreen> createState() => _DrillListScreenState();
}

class _DrillListScreenState extends State<DrillListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Drill> get _categoryDrills {
    return DrillLibrary.getDrillsByCategory(widget.categoryId);
  }

  List<Drill> get _filteredDrills {
    List<Drill> drills = _tabController.index == 0
        ? DrillLibrary.getRecommendedDrills()
        : _categoryDrills;

    if (_selectedDifficulty != null) {
      drills = drills.where((d) => d.difficulty == _selectedDifficulty).toList();
    }

    if (_searchQuery.isNotEmpty) {
      drills = DrillLibrary.searchDrills(_searchQuery);
    }

    return drills;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_getCategoryName()),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.lightTextSecondary,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Recommended'),
                    Tab(text: 'All Drills'),
                  ],
                ),
              ),
              // Filters Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: const TextStyle(fontSize: 14, color: AppColors.lightTextPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search drills...',
                            hintStyle: TextStyle(color: AppColors.lightTextTertiary, fontSize: 14),
                            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.lightTextSecondary),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Difficulty Filter
                    PopupMenuButton<String?>(
                      initialValue: _selectedDifficulty,
                      onSelected: (value) =>
                          setState(() => _selectedDifficulty = value),
                      offset: const Offset(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: null,
                          child: Text('All', style: TextStyle(
                            color: _selectedDifficulty == null ? AppColors.accent : AppColors.lightTextPrimary,
                            fontWeight: _selectedDifficulty == null ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'easy',
                          child: Text('Easy', style: TextStyle(
                            color: _selectedDifficulty == 'easy' ? AppColors.accent : AppColors.lightTextPrimary,
                            fontWeight: _selectedDifficulty == 'easy' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'medium',
                          child: Text('Medium', style: TextStyle(
                            color: _selectedDifficulty == 'medium' ? AppColors.accent : AppColors.lightTextPrimary,
                            fontWeight: _selectedDifficulty == 'medium' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'hard',
                          child: Text('Hard', style: TextStyle(
                            color: _selectedDifficulty == 'hard' ? AppColors.accent : AppColors.lightTextPrimary,
                            fontWeight: _selectedDifficulty == 'hard' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'expert',
                          child: Text('Expert', style: TextStyle(
                            color: _selectedDifficulty == 'expert' ? AppColors.accent : AppColors.lightTextPrimary,
                            fontWeight: _selectedDifficulty == 'expert' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          border: Border.all(color: _selectedDifficulty != null ? AppColors.accent : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 18,
                              color: _selectedDifficulty != null
                                  ? AppColors.accent
                                  : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _selectedDifficulty != null
                                  ? _selectedDifficulty!.toUpperCase()
                                  : 'Filter',
                              style: TextStyle(
                                color: _selectedDifficulty != null
                                    ? AppColors.accent
                                    : AppColors.lightTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Recommended Tab
          _buildDrillList(
            _categoryDrills.take(5).toList(),
            showReason: false,
          ),
          // All Drills Tab
          _buildDrillList(_categoryDrills),
        ],
      ),
    );
  }

  String _getCategoryName() {
    for (final cat in DrillLibrary.categories) {
      if (cat.id == widget.categoryId) {
        return cat.nameVi;
      }
    }
    return 'Drill Library';
  }

  Widget _buildDrillList(List<Drill> drills, {bool showReason = false}) {
    if (drills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 40, color: AppColors.lightTextTertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No drills found',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Apply filters
    var filteredDrills = drills;
    if (_selectedDifficulty != null) {
      filteredDrills = filteredDrills
          .where((d) => d.difficulty == _selectedDifficulty)
          .toList();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: filteredDrills.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final drill = filteredDrills[index];
        return _DrillCard(
          drill: drill,
          showReason: showReason,
          onTap: () => context.push('/training/drill/${drill.code}'),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }
}

class _DrillCard extends StatelessWidget {
  final Drill drill;
  final bool showReason;
  final VoidCallback onTap;

  const _DrillCard({
    required this.drill,
    this.showReason = false,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (drill.difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      case 'expert':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.lightTextSecondary;
    }
  }

  String _getDifficultyLabel() {
    switch (drill.difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'expert':
        return 'Expert';
      default:
        return drill.difficulty;
    }
  }

  String _getLevelProgress() {
    final current = drill.currentLevel;
    final total = drill.levels.length;
    return 'Lv.$current/$total';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Level indicator
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          drill.nameVi.substring(0, 1),
                          style: TextStyle(
                            color: _getDifficultyColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _getLevelProgress(),
                          style: TextStyle(
                            color: _getDifficultyColor(),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
                              drill.nameVi,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              _getDifficultyLabel(),
                              style: TextStyle(
                                color: _getDifficultyColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        drill.description,
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: AppColors.lightTextTertiary, size: 24),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Level progress
            Row(
              children: List.generate(drill.levels.length, (index) {
                final level = index + 1;
                final isUnlocked = drill.isLevelUnlocked(level);
                final isCompleted = level <= drill.currentLevel - 1;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < drill.levels.length - 1 ? AppSpacing.xs : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: !isUnlocked
                          ? AppColors.lightBorder
                          : isCompleted
                              ? AppColors.success
                              : AppColors.success.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Drill Categories Overview
class DrillCategoriesScreen extends StatelessWidget {
  const DrillCategoriesScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'center_focus_strong':
        return Icons.center_focus_strong;
      case 'circle':
        return Icons.circle_outlined;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'shield':
        return Icons.shield;
      case 'flash_on':
        return Icons.flash_on;
      case 'star':
        return Icons.star;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getColor(int index) {
    final colors = [
      AppColors.accent,
      AppColors.warning,
      const Color(0xFF8B5CF6),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Drill Library'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: DrillLibrary.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = DrillLibrary.categories[index];
          final color = _getColor(index);

          return InkWell(
            onTap: () => context.push('/training/drills/${category.id}'),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      _getIcon(category.icon),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.nameVi,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${category.drills.length} drills',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms);
        },
      ),
    );
  }
}
