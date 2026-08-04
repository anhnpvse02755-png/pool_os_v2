import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../../knowledge/knowledge_models.dart';

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  String? _selectedCategoryId;
  DifficultyLevel? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final knowledgeState = ref.watch(knowledgeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiến thức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          _buildCategoryTabs(knowledgeState.categories),

          // Difficulty filter
          _buildDifficultyFilter(),

          // Content
          Expanded(
            child: _buildContent(knowledgeState),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(List<KnowledgeCategory> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'Tất cả',
              isSelected: _selectedCategoryId == null,
              onTap: () => setState(() => _selectedCategoryId = null),
            );
          }

          final category = categories[index - 1];
          return _CategoryChip(
            label: category.nameVi ?? category.name,
            isSelected: _selectedCategoryId == category.id,
            onTap: () => setState(() => _selectedCategoryId = category.id),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DifficultyLevel.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'Tất cả',
              isSelected: _selectedDifficulty == null,
              onTap: () => setState(() => _selectedDifficulty = null),
            );
          }

          final diff = DifficultyLevel.values[index - 1];
          return _CategoryChip(
            label: diff.label,
            isSelected: _selectedDifficulty == diff,
            onTap: () => setState(() => _selectedDifficulty = diff),
          );
        },
      ),
    );
  }

  Widget _buildContent(KnowledgeState state) {
    // Filter knowledge
    var knowledge = state.allKnowledge;

    if (_selectedCategoryId != null) {
      knowledge = knowledge
          .where((k) => k.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_selectedDifficulty != null) {
      knowledge = knowledge
          .where((k) => k.difficulty == _selectedDifficulty)
          .toList();
    }

    if (knowledge.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Không có bài viết',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: knowledge.length,
      itemBuilder: (context, index) {
        final item = knowledge[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _KnowledgeCard(
            knowledge: item,
            onTap: () => context.push('/training/knowledge/${item.slug}'),
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _KnowledgeSearchDelegate(ref),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final KnowledgeItem knowledge;
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.knowledge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              knowledge.titleVi ?? knowledge.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Preview
            Text(
              _getPreview(knowledge.content),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Tags
            Row(
              children: [
                _DifficultyBadge(difficulty: knowledge.difficulty),
                const Spacer(),
                if (knowledge.relatedDrillCodes.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.fitness_center, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${knowledge.relatedDrillCodes.length} drills',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPreview(String content) {
    // Remove markdown headers
    return content
        .replaceAll(RegExp(r'#{1,3}\s'), '')
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .replaceAll('\n', ' ')
        .trim();
  }
}

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty) {
      case DifficultyLevel.beginner:
        color = Colors.green;
        break;
      case DifficultyLevel.intermediate:
        color = Colors.blue;
        break;
      case DifficultyLevel.advanced:
        color = Colors.orange;
        break;
      case DifficultyLevel.expert:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KnowledgeSearchDelegate extends SearchDelegate<KnowledgeItem?> {
  final WidgetRef ref;
  Timer? _debounce;
  String _lastQueried = '';

  _KnowledgeSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _debounce?.cancel();
          _lastQueried = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _debounce?.cancel();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Debounce: schedule a refresh 300ms after the last keystroke.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query != _lastQueried) {
        _lastQueried = query;
        // Triggers a rebuild with the new query applied.
        (context as Element).markNeedsBuild();
      }
    });
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Nhập từ khóa để tìm kiếm',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    // Wait until debounce has settled and `_lastQueried` matches current query.
    if (query != _lastQueried) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final results = ref.watch(knowledgeSearchProvider(query));

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _KnowledgeCard(
            knowledge: item,
            onTap: () {
              _debounce?.cancel();
              close(context, item);
              context.push('/training/knowledge/${item.slug}');
            },
          ),
        );
      },
    );
  }

  @override
  void close(BuildContext context, KnowledgeItem? result) {
    _debounce?.cancel();
    super.close(context, result);
  }
}
