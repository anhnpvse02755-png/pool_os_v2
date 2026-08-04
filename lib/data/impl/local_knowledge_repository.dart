import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/knowledge_repository.dart';

/// Local Knowledge Repository Implementation
class LocalKnowledgeRepository implements KnowledgeRepository {
  @override
  Future<List<KnowledgeArticle>> getAllArticles() async {
    final data = await LocalStorageDataSource.getKnowledgeArticles();
    return data.map((json) => _articleFromJson(json)).toList();
  }

  @override
  Future<List<KnowledgeArticle>> getArticlesByCategory(String category) async {
    final articles = await getAllArticles();
    return articles.where((a) => a.category == category).toList();
  }

  @override
  Future<KnowledgeArticle?> getArticleBySlug(String slug) async {
    final articles = await getAllArticles();
    try {
      return articles.firstWhere((a) => a.slug == slug);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<KnowledgeArticle?> getArticleById(String id) async {
    final articles = await getAllArticles();
    try {
      return articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<KnowledgeCategory>> getCategories() async {
    final articles = await getAllArticles();
    final categoryMap = <String, int>{};
    for (final article in articles) {
      categoryMap[article.category] = (categoryMap[article.category] ?? 0) + 1;
    }
    return categoryMap.entries.map((e) => KnowledgeCategory(
      id: e.key,
      name: e.key,
      nameVi: _getCategoryNameVi(e.key),
      icon: _getCategoryIcon(e.key),
      articleCount: e.value,
    )).toList();
  }

  String _getCategoryNameVi(String category) {
    const names = {
      'basics': 'Căn bản',
      'position': 'Vị trí',
      'spin': 'Xoáy',
      'safety': 'Safety',
      'bank': 'Bank Shot',
      'advanced': 'Nâng cao',
    };
    return names[category] ?? category;
  }

  String _getCategoryIcon(String category) {
    const icons = {
      'basics': 'school',
      'position': 'gps_fixed',
      'spin': 'sync',
      'safety': 'shield',
      'bank': 'change_history',
      'advanced': 'flash_on',
    };
    return icons[category] ?? 'article';
  }

  @override
  Future<List<KnowledgeArticle>> searchArticles(String query) async {
    final articles = await getAllArticles();
    final lowerQuery = query.toLowerCase();
    return articles.where((a) =>
      a.title.toLowerCase().contains(lowerQuery) ||
      a.content.toLowerCase().contains(lowerQuery) ||
      a.tags.any((t) => t.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  @override
  Future<Map<String, ReadingProgress>> getReadingProgress() async {
    final data = await LocalStorageDataSource.getKnowledgeProgress();
    final progress = <String, ReadingProgress>{};
    data.forEach((key, value) {
      progress[key] = ReadingProgress(
        articleId: key,
        isRead: value['isRead'] ?? false,
        readAt: value['readAt'] != null ? DateTime.parse(value['readAt']) : null,
        progressPercent: (value['progressPercent'] ?? 0).toDouble(),
        timeSpentSeconds: value['timeSpentSeconds'] ?? 0,
      );
    });
    return progress;
  }

  @override
  Future<void> markAsRead(String articleId) async {
    final progress = await LocalStorageDataSource.getKnowledgeProgress();
    progress[articleId] = {
      'isRead': true,
      'readAt': DateTime.now().toIso8601String(),
      'progressPercent': 100,
      'timeSpentSeconds': 0,
    };
    await LocalStorageDataSource.saveKnowledgeProgress(progress);
  }

  @override
  Future<List<KnowledgeArticle>> getRecentlyRead({int limit = 5}) async {
    final progress = await getReadingProgress();
    final readArticles = progress.entries
        .where((e) => e.value.isRead && e.value.readAt != null)
        .toList()
      ..sort((a, b) => b.value.readAt!.compareTo(a.value.readAt!));

    final articles = <KnowledgeArticle>[];
    for (final entry in readArticles.take(limit)) {
      final article = await getArticleById(entry.key);
      if (article != null) articles.add(article);
    }
    return articles;
  }

  @override
  Future<int> getUnreadCount() async {
    final articles = await getAllArticles();
    final progress = await getReadingProgress();
    return articles.where((a) => !(progress[a.id]?.isRead ?? false)).length;
  }

  KnowledgeArticle _articleFromJson(Map<String, dynamic> json) {
    return KnowledgeArticle(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      subtitle: json['subtitle'],
      category: json['category'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      readTimeMinutes: json['readTimeMinutes'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
