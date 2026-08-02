// ============================================================================
// COMMUNITY PROVIDER
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityState {
  final List<Post> posts;
  final List<CommunityUser> users;
  final bool isLoading;
  final String? error;

  const CommunityState({
    this.posts = const [],
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<Post>? posts,
    List<CommunityUser>? users,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String type; // 'tip', 'question', 'achievement', 'general'

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.type = 'general',
  });
}

class CommunityUser {
  final String id;
  final String name;
  final String? avatar;
  final String rank;
  final int level;
  final int postsCount;
  final int followersCount;

  const CommunityUser({
    required this.id,
    required this.name,
    this.avatar,
    required this.rank,
    this.level = 1,
    this.postsCount = 0,
    this.followersCount = 0,
  });
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier() : super(const CommunityState()) {
    _loadDemoData();
  }

  void _loadDemoData() {
    // Demo posts
    final posts = [
      Post(
        id: '1',
        authorId: 'u1',
        authorName: 'Nguyễn Văn A',
        content: 'Mẹo hay: Khi tập Draw Shot, hãy bắt đầu với khoảng cách ngắn trước. Điểm đánh dưới tâm khoảng 1/4 là đủ để bắt đầu!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 45,
        comments: 12,
        type: 'tip',
      ),
      Post(
        id: '2',
        authorId: 'u2',
        authorName: 'Trần Văn B',
        content: 'Câu hỏi: Có bạn nào tập Position Play hiệu quả không? Mình đang gặp khó khăn với việc kiểm soát bi cái sau khi đánh.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 23,
        comments: 8,
        type: 'question',
      ),
      Post(
        id: '3',
        authorId: 'u3',
        authorName: 'Lê Văn C',
        content: '🎉 Đạt được Achievement: "Practice Makes Perfect" - Tập 100 bài tập Stop Shot!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 89,
        comments: 15,
        type: 'achievement',
      ),
      Post(
        id: '4',
        authorId: 'u4',
        authorName: 'Phạm Văn D',
        content: 'Review: Bàn billiards của CLB Minh Hoàng - Chất lượng tốt, băng nhanh. Phù hợp cho người mới tập chơi.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 34,
        comments: 5,
        type: 'general',
      ),
    ];

    final users = [
      const CommunityUser(
        id: 'u1',
        name: 'Nguyễn Văn A',
        rank: 'Chuyên gia',
        level: 45,
        postsCount: 156,
        followersCount: 234,
      ),
      const CommunityUser(
        id: 'u2',
        name: 'Trần Văn B',
        rank: 'Nâng cao',
        level: 28,
        postsCount: 89,
        followersCount: 112,
      ),
    ];

    state = state.copyWith(posts: posts, users: users);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    _loadDemoData();
    state = state.copyWith(isLoading: false);
  }

  void likePost(String postId) {
    final posts = state.posts.map((p) {
      if (p.id == postId) {
        return Post(
          id: p.id,
          authorId: p.authorId,
          authorName: p.authorName,
          authorAvatar: p.authorAvatar,
          content: p.content,
          imageUrl: p.imageUrl,
          createdAt: p.createdAt,
          likes: p.likes + 1,
          comments: p.comments,
          type: p.type,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(posts: posts);
  }

  List<Post> getPostsByType(String type) {
    if (type == 'all') return state.posts;
    return state.posts.where((p) => p.type == type).toList();
  }

  List<Post> searchPosts(String query) {
    final lowerQuery = query.toLowerCase();
    return state.posts.where((p) {
      return p.content.toLowerCase().contains(lowerQuery) ||
          p.authorName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier();
});

// Filter provider
final communityFilterProvider = StateProvider<String>((ref) => 'all');

// Filtered posts provider
final filteredPostsProvider = Provider<List<Post>>((ref) {
  final filter = ref.watch(communityFilterProvider);
  ref.watch(communityProvider); // Subscribe to changes
  final notifier = ref.read(communityProvider.notifier);
  return notifier.getPostsByType(filter);
});
