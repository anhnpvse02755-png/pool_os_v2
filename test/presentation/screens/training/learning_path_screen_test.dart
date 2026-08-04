import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:pool_os_v2/presentation/screens/training/learning_path_screen.dart';
import 'package:pool_os_v2/core/providers/coach_provider.dart';
import 'package:pool_os_v2/knowledge/knowledge_provider.dart';
import 'package:pool_os_v2/knowledge/knowledge_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testPathItems = [
    LearningPathItem(
      drillCode: 'STOP_BALL',
      drillName: 'Stop Ball',
      drillNameVi: 'Dừng bi',
      description: 'Practice stop shots for cue ball control.',
      priority: 1,
      reason: 'Phù hợp với sở thích của bạn',
      estimatedMinutes: 15,
      category: 'cueball',
      difficulty: 'medium',
      knowledgeIds: const ['kn_stop_shot'],
    ),
  ];

  final testKnowledge = [
    KnowledgeItem(
      id: 'kn_stop_shot',
      slug: 'stop-shot',
      title: 'Stop Shot',
      titleVi: 'Cú Dừng',
      content: '# Stop Shot\nContent.',
      categoryId: 'cat_shotmaking',
      difficulty: DifficultyLevel.beginner,
      relatedKnowledgeIds: const [],
      relatedDrillCodes: const [],
    ),
  ];

  final testKnowledgeState = KnowledgeState(
    allKnowledge: testKnowledge,
    categories: const [],
    tags: const [],
    drillKnowledgeMap: const {'STOP_BALL': ['kn_stop_shot']},
  );

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        learningPathProvider.overrideWith((ref) async => testPathItems),
        knowledgeProvider.overrideWith((ref) {
          return _FakeKnowledgeNotifier(testKnowledgeState);
        }),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/training/path',
          routes: [
            GoRoute(
              path: '/training/path',
              builder: (context, state) => const LearningPathScreen(),
            ),
            GoRoute(
              path: '/training/knowledge/:slug',
              builder: (context, state) => Scaffold(
                body: Text('Knowledge: ${state.pathParameters['slug']}'),
              ),
            ),
            GoRoute(
              path: '/training/session/new',
              builder: (context, state) => Scaffold(
                body: Text('Session: ${state.uri.queryParameters['drill']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  group('LearningPathScreen', () {
    testWidgets('smoke: renders drill title and start button', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Dừng bi'), findsOneWidget);
      expect(find.text('Bắt đầu'), findsOneWidget);
      expect(find.text('Bỏ qua'), findsOneWidget);
    });

    testWidgets('shows priority label', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Ưu tiên cao'), findsOneWidget);
    });

    testWidgets('start button navigates to session route', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Session:'), findsOneWidget);
    });

    testWidgets('knowledge chip appears when related knowledge available',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      // learningKnowledgeProvider should resolve "kn_stop_shot" via
      // pathItem.knowledgeIds.
      expect(find.text('Cú Dừng'), findsWidgets);
    });

    testWidgets('path renders cleanly even when no knowledge matches',
        (tester) async {
      // Override with an item that has empty knowledgeIds and an unmapped
      // drill code, plus no drillKnowledgeMap entries — fallback by
      // difficulty should still kick in.
      final emptyState = KnowledgeState(
        allKnowledge: const [],
        categories: const [],
        tags: const [],
        drillKnowledgeMap: const {},
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningPathProvider.overrideWith(
              (ref) async => [
                LearningPathItem(
                  drillCode: 'UNKNOWN_DRILL',
                  drillName: 'Unknown',
                  drillNameVi: 'Không rõ',
                  description: 'No mapping',
                  priority: 2,
                  reason: 'Test',
                  estimatedMinutes: 10,
                  category: 'cueball',
                  difficulty: 'hard',
                ),
              ],
            ),
            knowledgeProvider
                .overrideWith((ref) => _FakeKnowledgeNotifier(emptyState)),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/training/path',
              routes: [
                GoRoute(
                  path: '/training/path',
                  builder: (context, state) => const LearningPathScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Không rõ'), findsOneWidget);
      expect(find.text('Bắt đầu'), findsOneWidget);
    });
  });
}

class _FakeKnowledgeNotifier extends KnowledgeNotifier {
  _FakeKnowledgeNotifier(KnowledgeState initial) : super.withState(initial);
}
