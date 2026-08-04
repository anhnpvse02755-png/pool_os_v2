import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
    relatedDrillCodes: const ['STOP_LV1'],
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
    drillKnowledgeMap: const {'STOP_LV1': ['kn_stop_shot']},
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
      // V1 STOP_LV1 should bridge to V2 STOP_BALL.
      expect(find.text('Session: STOP_BALL'), findsOneWidget);
    });

    testWidgets('unknown slug shows not-found view', (tester) async {
      await tester.pumpWidget(buildScreen('does-not-exist'));
      await tester.pumpAndSettle();
      expect(find.text('Không tìm thấy bài viết'), findsOneWidget);
    });
  });
}

class _FakeKnowledgeNotifier extends KnowledgeNotifier {
  _FakeKnowledgeNotifier(KnowledgeState initial) : super.withState(initial);
}
