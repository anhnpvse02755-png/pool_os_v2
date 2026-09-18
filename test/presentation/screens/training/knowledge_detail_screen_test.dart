import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:pool_os_v2/presentation/screens/training/knowledge_detail_screen.dart';
import 'package:pool_os_v2/knowledge/knowledge_provider.dart';
import 'package:pool_os_v2/knowledge/knowledge_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testItem = KnowledgeItem(
    id: 'kn_stop_shot',
    slug: 'stop-shot',
    title: 'Stop Shot',
    titleVi: 'Cú Dừng',
    content: '# Stop Shot\nNội dung chi tiết về cú dừng.',
    contentVi: 'Nội dung chi tiết về cú dừng.',
    categoryId: 'cat_shotmaking',
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: const ['kn_draw_shot'],
    relatedDrillCodes: const ['BT07'],
  );

  final relatedItem = KnowledgeItem(
    id: 'kn_draw_shot',
    slug: 'draw-shot',
    title: 'Draw Shot',
    titleVi: 'Cú Lùi',
    content: '# Draw Shot\nContent.',
    categoryId: 'cat_shotmaking',
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: const [],
    relatedDrillCodes: const [],
  );

  final testState = KnowledgeState(
    allKnowledge: [testItem, relatedItem],
    categories: const [
      KnowledgeCategory(
        id: 'cat_shotmaking',
        slug: 'shot-making',
        name: 'Shot Making',
        nameVi: 'Kỹ Thuật Đánh',
        order: 2,
      ),
    ],
    tags: const [],
    drillKnowledgeMap: const {'BT07': ['kn_stop_shot']},
  );

  Widget buildScreen(String slug) {
    return ProviderScope(
      overrides: [
        knowledgeProvider.overrideWith((ref) {
          return _FakeKnowledgeNotifier(testState);
        }),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/training/knowledge/$slug',
          routes: [
            GoRoute(
              path: '/training/knowledge/:slug',
              builder: (context, state) => KnowledgeDetailScreen(
                slug: state.pathParameters['slug']!,
              ),
            ),
            GoRoute(
              path: '/training/session/new',
              builder: (context, state) => Scaffold(
                body: Text(
                    'Session: ${state.uri.queryParameters['drill'] ?? 'none'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  group('KnowledgeDetailScreen', () {
    testWidgets('smoke: renders article title and content', (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();
      expect(find.text('Cú Dừng'), findsWidgets);
      expect(find.textContaining('Nội dung'), findsWidgets);
    });

    testWidgets('shows related knowledge section', (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();
      expect(find.text('Bài viết liên quan'), findsOneWidget);
    });

    testWidgets('shows practice button', (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();
      expect(find.text('Luyện tập'), findsOneWidget);
    });

    testWidgets('practice button navigates with bridged V2 drill code',
        (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Luyện tập'));
      await tester.pumpAndSettle();
      // V1 BT07 should bridge to V2 BT07.
      expect(find.text('Session: BT07'), findsOneWidget);
    });

    testWidgets('unknown slug shows not-found view', (tester) async {
      await tester.pumpWidget(buildScreen('does-not-exist'));
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy bài viết'), findsOneWidget);
    });
  });

  // ── Ghi tiến độ đọc ──────────────────────────────────────────────────────
  //
  // Cổng thật của bug "mục Tiến độ kiến thức ở Profile luôn rỗng". Bug KHÔNG
  // nằm ở hàm ghi sai, mà ở chỗ KHÔNG AI GỌI hàm ghi. Nên mọi test ở group
  // này phải đi qua MÀN HÌNH — test gọi thẳng `markKnowledgeAsRead` sẽ xanh
  // trong khi Profile vẫn rỗng, đúng cái bẫy ở memory mục 9.
  group('KnowledgeDetailScreen ghi tiến độ đọc', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorageDataSource.init();
    });

    testWidgets('mở một bài thì bài đó được đánh dấu đã đọc', (tester) async {
      expect(await LocalStorageDataSource.getKnowledgeProgress(), isEmpty);

      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();

      final progress = await LocalStorageDataSource.getKnowledgeProgress();
      expect(progress.containsKey('kn_stop_shot'), isTrue);
      expect((progress['kn_stop_shot'] as Map)['read'], isTrue);
    });

    testWidgets('bản ghi mang tiêu đề tiếng Việt để Profile khỏi hiện id thô',
        (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();

      final progress = await LocalStorageDataSource.getKnowledgeProgress();
      expect((progress['kn_stop_shot'] as Map)['title'], 'Cú Dừng');
    });

    testWidgets('slug không tồn tại thì không ghi gì', (tester) async {
      await tester.pumpWidget(buildScreen('does-not-exist'));
      await tester.pumpAndSettle();

      expect(await LocalStorageDataSource.getKnowledgeProgress(), isEmpty);
    });

    testWidgets('đọc lại một bài giữ nguyên readAt của lần đọc đầu',
        (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();
      final lanDau = (await LocalStorageDataSource.getKnowledgeProgress())
          ['kn_stop_shot'] as Map;
      final readAtDau = lanDau['readAt'] as String;

      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();

      final lanSau = (await LocalStorageDataSource.getKnowledgeProgress())
          ['kn_stop_shot'] as Map;
      expect(lanSau['readAt'], readAtDau);
    });

    testWidgets('đọc bài thứ hai không xoá bản ghi của bài thứ nhất',
        (tester) async {
      await tester.pumpWidget(buildScreen('stop-shot'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildScreen('draw-shot'));
      await tester.pumpAndSettle();

      final progress = await LocalStorageDataSource.getKnowledgeProgress();
      expect(progress.keys, containsAll(['kn_stop_shot', 'kn_draw_shot']));
    });
  });
}

class _FakeKnowledgeNotifier extends KnowledgeNotifier {
  _FakeKnowledgeNotifier(super.initial) : super.withState();
}
