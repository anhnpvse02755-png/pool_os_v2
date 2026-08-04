/// Community Repository Interface
/// Abstracts data access for community posts
abstract class CommunityRepository {
  /// Get all posts
  Future<List<CommunityPost>> getAllPosts({int? limit, int offset = 0});

  /// Get post by ID
  Future<CommunityPost?> getPostById(String postId);

  /// Get posts by user
  Future<List<CommunityPost>> getPostsByUser(String userId);

  /// Create new post
  Future<CommunityPost> createPost(CommunityPost post);

  /// Update post
  Future<CommunityPost> updatePost(CommunityPost post);

  /// Delete post
  Future<void> deletePost(String postId);

  /// Like post
  Future<void> likePost(String postId);

  /// Unlike post
  Future<void> unlikePost(String postId);

  /// Comment on post
  Future<Comment> addComment(String postId, Comment comment);

  /// Get comments for post
  Future<List<Comment>> getComments(String postId);
}

/// Community Post Model
class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String>? images;
  final int likes;
  final int comments;
  final List<String> likedByUsers;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.images,
    this.likes = 0,
    this.comments = 0,
    this.likedByUsers = const [],
    required this.createdAt,
    this.updatedAt,
  });
}

/// Comment Model
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });
}
