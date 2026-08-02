import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/knowledge.dart';

class KnowledgeDetailScreen extends StatelessWidget {
  final String articleId;

  const KnowledgeDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final article = KnowledgeLibrary.getArticle(articleId);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy bài viết')),
      );
    }

    final color = _getCategoryColor(article.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.titleVi,
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(article.category),
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(article.category),
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryName(article.category),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 24),

                  // Content
                  _MarkdownContent(content: article.content),

                  const SizedBox(height: 32),

                  // Related Drills
                  if (article.relatedDrillCodes.isNotEmpty) ...[
                    _buildSectionTitle('Bài tập liên quan'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: article.relatedDrillCodes.map((code) {
                        return ActionChip(
                          avatar: const Icon(Icons.fitness_center, size: 16),
                          label: Text(_formatDrillCode(code)),
                          onPressed: () {
                            context.push('/training/drill/$code');
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Related Articles
                  if (article.relatedArticleIds.isNotEmpty) ...[
                    _buildSectionTitle('Bài viết liên quan'),
                    const SizedBox(height: 12),
                    ...article.relatedArticleIds.map((id) {
                      final related = KnowledgeLibrary.getArticle(id);
                      if (related == null) return const SizedBox();
                      return _RelatedArticleCard(
                        article: related,
                        onTap: () => context.push('/training/knowledge/$id'),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Note about drills
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.accentGold, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bạn có thể bắt đầu luyện tập ngay từ Drill Library. Kiến thức không bị khóa theo cấp độ.',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/training/drills'),
            icon: const Icon(Icons.fitness_center),
            label: const Text('Đi đến Drill Library'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
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

  Color _getCategoryColor(String category) {
    switch (category) {
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

  String _getCategoryName(String category) {
    switch (category) {
      case 'cueball':
        return 'Cue Ball Control';
      case 'aiming':
        return 'Aiming';
      case 'safety':
        return 'Safety';
      case 'bridge':
        return 'Bridge';
      case 'strategy':
        return 'Strategy';
      default:
        return category;
    }
  }

  String _formatDrillCode(String code) {
    return code.replaceAll('_', ' ');
  }
}

class _MarkdownContent extends StatelessWidget {
  final String content;

  const _MarkdownContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(2),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(3),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(child: _buildFormattedText(line.substring(2))),
            ],
          ),
        ));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line.replaceAll('**', ''),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ));
      } else if (line.trim().isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildFormattedText(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    ).animate().fadeIn();
  }

  Widget _buildFormattedText(String text) {
    // Simple bold handling
    final parts = <InlineSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    var lastEnd = 0;

    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      parts.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(TextSpan(text: text.substring(lastEnd)));
    }

    if (parts.isEmpty) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textPrimary,
          height: 1.6,
        ),
        children: parts,
      ),
    );
  }
}

class _RelatedArticleCard extends StatelessWidget {
  final KnowledgeArticle article;
  final VoidCallback onTap;

  const _RelatedArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.article, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    article.titleVi,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
