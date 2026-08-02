import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/knowledge.dart';

class KnowledgeListScreen extends StatefulWidget {
  const KnowledgeListScreen({super.key});

  @override
  State<KnowledgeListScreen> createState() => _KnowledgeListScreenState();
}

class _KnowledgeListScreenState extends State<KnowledgeListScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'circle':
        return Icons.circle_outlined;
      case 'visibility':
        return Icons.visibility;
      case 'shield':
        return Icons.shield;
      case 'handyman':
        return Icons.handyman;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.article;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = KnowledgeLibrary.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiến thức'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm kiến thức...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // Category chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('Tất cả'),
                        selected: _selectedCategory == null,
                        onSelected: (_) => setState(() => _selectedCategory = null),
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat.nameVi),
                          selected: _selectedCategory == cat.id,
                          onSelected: (_) => setState(() => _selectedCategory = cat.id),
                          avatar: Icon(
                            _getIcon(cat.icon),
                            size: 16,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    List<KnowledgeArticle> articles;

    if (_searchQuery.isNotEmpty) {
      articles = KnowledgeLibrary.searchArticles(_searchQuery);
    } else if (_selectedCategory != null) {
      articles = KnowledgeLibrary.getArticlesByCategory(_selectedCategory!);
    } else {
      articles = KnowledgeLibrary.getAllArticles();
    }

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = articles[index];
        return _KnowledgeCard(
          article: article,
          onTap: () => context.push('/training/knowledge/${article.id}'),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final KnowledgeArticle article;
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.article,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (article.category) {
      case 'cueball':
        return Icons.circle_outlined;
      case 'aiming':
        return Icons.visibility;
      case 'safety':
        return Icons.shield;
      case 'bridge':
        return Icons.handyman;
      case 'strategy':
        return Icons.psychology;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor() {
    switch (article.category) {
      case 'cueball':
        return Colors.blue;
      case 'aiming':
        return Colors.orange;
      case 'safety':
        return Colors.green;
      case 'bridge':
        return Colors.purple;
      case 'strategy':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.titleVi,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPreview(article.content),
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
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _getPreview(String content) {
    // Remove markdown formatting and get first 100 chars
    final cleaned = content
        .replaceAll(RegExp(r'#+'), '')
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();
    if (cleaned.length > 100) {
      return '${cleaned.substring(0, 100)}...';
    }
    return cleaned;
  }
}
