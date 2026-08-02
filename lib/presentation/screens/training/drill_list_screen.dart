import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: Text(_getCategoryName()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Tabs
              TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                tabs: const [
                  Tab(text: '⭐ Recommended'),
                  Tab(text: 'All Drill'),
                ],
              ),
              // Filters Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search drills...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Difficulty Filter
                    PopupMenuButton<String?>(
                      initialValue: _selectedDifficulty,
                      onSelected: (value) =>
                          setState(() => _selectedDifficulty = value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All'),
                        ),
                        const PopupMenuItem(
                          value: 'easy',
                          child: Text('Easy'),
                        ),
                        const PopupMenuItem(
                          value: 'medium',
                          child: Text('Medium'),
                        ),
                        const PopupMenuItem(
                          value: 'hard',
                          child: Text('Hard'),
                        ),
                        const PopupMenuItem(
                          value: 'expert',
                          child: Text('Expert'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 18,
                              color: _selectedDifficulty != null
                                  ? AppTheme.primaryGreen
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedDifficulty != null
                                  ? _selectedDifficulty!.toUpperCase()
                                  : 'Filter',
                              style: TextStyle(
                                color: _selectedDifficulty != null
                                    ? AppTheme.primaryGreen
                                    : Colors.grey,
                                fontSize: 12,
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
            DrillLibrary.getRecommendedDrills(),
            showReason: true,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No drills found'),
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
      padding: const EdgeInsets.all(16),
      itemCount: filteredDrills.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
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
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _getLevelProgress(),
                          style: TextStyle(
                            color: _getDifficultyColor(),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getDifficultyLabel(),
                              style: TextStyle(
                                color: _getDifficultyColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        drill.description,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showReason) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Phù hợp với sở thích của bạn',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Level progress
            Row(
              children: List.generate(drill.levels.length, (index) {
                final level = index + 1;
                final isUnlocked = drill.isLevelUnlocked(level);
                final isCompleted = level <= drill.currentLevel - 1;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < drill.levels.length - 1 ? 4 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: !isUnlocked
                          ? Colors.grey.shade300
                          : isCompleted
                              ? AppTheme.primaryGreen
                              : AppTheme.primaryGreen.withValues(alpha: 0.3),
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
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drill Library'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: DrillLibrary.categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = DrillLibrary.categories[index];
          final color = _getColor(index);

          return InkWell(
            onTap: () => context.push('/training/drills/${category.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(category.icon),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        Text(
                          '${category.drills.length} drills • ${category.drills.length * 5} levels',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms);
        },
      ),
    );
  }
}
