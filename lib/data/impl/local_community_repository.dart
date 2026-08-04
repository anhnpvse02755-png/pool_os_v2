import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/community_repository.dart';

/// Local Community Repository Implementation
class LocalCommunityRepository implements CommunityRepository {
  @override
  Future<List<CommunityPost>> getAllPosts({int? limit, int offset = 0}) async {
    final data = await LocalStorageDataSource.getCommunityPosts();
    var posts = data.map((json) => _postFromJson(json)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (offset > 0) {
      posts = posts.skip(offset).toList();
    }
    if (limit != null && posts.length > limit) {
      posts = posts.take(limit).toList();
    }
    return posts;
  }

  @override
  Future<CommunityPost?> getPostById(String postId) async {
    final posts = await getAllPosts();
    try {
      return posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CommunityPost>> getPostsByUser(String userId) async {
    final posts = await getAllPosts();
    return posts.where((p) => p.userId == userId).toList();
  }

  @override
  Future<CommunityPost> createPost(CommunityPost post) async {
    final posts = await LocalStorageDataSource.getCommunityPosts();
    posts.insert(0, _postToJson(post));
    await LocalStorageDataSource.saveCommunityPosts(posts);
    return post;
  }

  @override
  Future<CommunityPost> updatePost(CommunityPost post) async {
    final posts = await LocalStorageDataSource.getCommunityPosts();
    final index = posts.indexWhere((p) => p['id'] == post.id);
    if (index != -1) {
      posts[index] = _postToJson(post);
      await LocalStorageDataSource.saveCommunityPosts(posts);
    }
    return post;
  }

  @override
  Future<void> deletePost(String postId) async {
    final posts = await LocalStorageDataSource.getCommunityPosts();
    posts.removeWhere((p) => p['id'] == postId);
    await LocalStorageDataSource.saveCommunityPosts(posts);
  }

  @override
  Future<void> likePost(String postId) async {
    final posts = await LocalStorageDataSource.getCommunityPosts();
    final index = posts.indexWhere((p) => p['id'] == postId);
    if (index != -1) {
      posts[index]['likes'] = (posts[index]['likes'] ?? 0) + 1;
      posts[index]['likedByUsers'] = [...(posts[index]['likedByUsers'] ?? []), 'demo_user_001'];
      await LocalStorageDataSource.saveCommunityPosts(posts);
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    final posts = await LocalStorageDataSource.getCommunityPosts();
    final index = posts.indexWhere((p) => p['id'] == postId);
    if (index != -1) {
      final currentLikes = (posts[index]['likes'] ?? 1) as int;
      posts[index]['likes'] = currentLikes > 0 ? currentLikes - 1 : 0;
      await LocalStorageDataSource.saveCommunityPosts(posts);
    }
  }

  @override
  Future<Comment> addComment(String postId, Comment comment) async {
    // For demo, just return the comment
    return comment;
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    // For demo, return empty list
    return [];
  }

  CommunityPost _postFromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      content: json['content'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      likedByUsers: List<String>.from(json['likedByUsers'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> _postToJson(CommunityPost post) {
    return {
      'id': post.id,
      'userId': post.userId,
      'userName': post.userName,
      'userAvatar': post.userAvatar,
      'content': post.content,
      'images': post.images,
      'likes': post.likes,
      'comments': post.comments,
      'likedByUsers': post.likedByUsers,
      'createdAt': post.createdAt.toIso8601String(),
      'updatedAt': post.updatedAt?.toIso8601String(),
    };
  }

}
