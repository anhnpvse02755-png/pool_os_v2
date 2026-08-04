/// Knowledge Repository Interface
/// Abstracts data access for knowledge articles
abstract class KnowledgeRepository {
  /// Get all knowledge articles
  Future<List<KnowledgeArticle>> getAllArticles();

  /// Get articles by category
  Future<List<KnowledgeArticle>> getArticlesByCategory(String category);

  /// Get article by slug
  Future<KnowledgeArticle?> getArticleBySlug(String slug);

  /// Get article by ID
  Future<KnowledgeArticle?> getArticleById(String id);

  /// Get all categories
  Future<List<KnowledgeCategory>> getCategories();

  /// Search articles
  Future<List<KnowledgeArticle>> searchArticles(String query);

  /// Get user's reading progress
  Future<Map<String, ReadingProgress>> getReadingProgress();

  /// Mark article as read
  Future<void> markAsRead(String articleId);

  /// Get recently read articles
  Future<List<KnowledgeArticle>> getRecentlyRead({int limit = 5});

  /// Get unread articles count
  Future<int> getUnreadCount();
}

/// Knowledge Article Model
class KnowledgeArticle {
  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String category;
  final String content;
  final String? imageUrl;
  final int readTimeMinutes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeArticle({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.content,
    this.imageUrl,
    required this.readTimeMinutes,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Knowledge Category Model
class KnowledgeCategory {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final int articleCount;

  KnowledgeCategory({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.articleCount,
  });
}

/// Reading Progress Model
class ReadingProgress {
  final String articleId;
  final bool isRead;
  final DateTime? readAt;
  final double progressPercent;
  final int timeSpentSeconds;

  ReadingProgress({
    required this.articleId,
    required this.isRead,
    this.readAt,
    required this.progressPercent,
    required this.timeSpentSeconds,
  });
}
