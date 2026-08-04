import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/presentation/screens/training/knowledge_screen.dart';
import 'package:pool_os_v2/knowledge/knowledge_provider.dart';
import 'package:pool_os_v2/knowledge/knowledge_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testItems = [
    KnowledgeItem(
      id: 'kn_stop_shot',
      slug: 'stop-shot',
      title: 'Stop Shot',
      titleVi: 'Cú Dừng',
      content: '# Stop Shot\nContent here.',
      categoryId: 'cat_shotmaking',
      difficulty: DifficultyLevel.beginner,
      relatedKnowledgeIds: const [],
      relatedDrillCodes: const [],
    ),
    KnowledgeItem(
      id: 'kn_draw_shot',
      slug: 'draw-shot',
      title: 'Draw Shot',
      titleVi: 'Cú Lùi',
      content: '# Draw Shot\nContent here.',
      categoryId: 'cat_shotmaking',
      difficulty: DifficultyLevel.intermediate,
      relatedKnowledgeIds: const [],
      relatedDrillCodes: const [],
    ),
    KnowledgeItem(
      id: 'kn_bridge',
      slug: 'bridge',
      title: 'Bridge',
      titleVi: 'Tay Chống',
      content: '# Bridge\nContent here.',
      categoryId: 'cat_fundamentals',
      difficulty: DifficultyLevel.beginner,
      relatedKnowledgeIds: const [],
      relatedDrillCodes: const [],
    ),
  ];

  final testCategories = [
    const KnowledgeCategory(
      id: 'cat_shotmaking',
      slug: 'shot-making',
      name: 'Shot Making',
      nameVi: 'Kỹ Thuật Đánh',
      order: 2,
    ),
    const KnowledgeCategory(
      id: 'cat_fundamentals',
      slug: 'fundamentals',
      name: 'Fundamentals',
      nameVi: 'Nền Tảng',
      order: 1,
    ),
  ];

  KnowledgeState makeState() => KnowledgeState(
        allKnowledge: testItems,
        categories: testCategories,
        tags: const [],
        drillKnowledgeMap: const {},
      );

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        knowledgeProvider.overrideWith((ref) {
          return _FakeKnowledgeNotifier(makeState());
        }),
      ],
      child: const MaterialApp(home: KnowledgeScreen()),
    );
  }

  group('KnowledgeScreen', () {
    testWidgets('smoke: renders article titles', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Cú Dừng'), findsOneWidget);
      expect(find.text('Cú Lùi'), findsOneWidget);
      expect(find.text('Tay Chống'), findsOneWidget);
    });

    testWidgets('smoke: shows category chips including "Tất cả"',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      // "Tất cả" appears twice (categories + difficulty filter rows).
      expect(find.widgetWithText(FilterChip, 'Tất cả'), findsNWidgets(2));
      expect(find.widgetWithText(FilterChip, 'Kỹ Thuật Đánh'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Nền Tảng'), findsOneWidget);
    });

    testWidgets('smoke: shows difficulty chips (Cơ bản, Trung bình, ...)',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      // Difficulty chip labels match the label property of DifficultyLevel.
      // They appear inside the FilterChip widgets in the difficulty row.
      expect(find.widgetWithText(FilterChip, 'Cơ bản'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Trung bình'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Nâng cao'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Chuyên gia'), findsOneWidget);
    });

    testWidgets('difficulty filter: Cơ bản shows only beginner articles',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Cơ bản'));
      await tester.pumpAndSettle();
      expect(find.text('Cú Dừng'), findsOneWidget); // beginner
      expect(find.text('Cú Lùi'), findsNothing); // intermediate
      expect(find.text('Tay Chống'), findsOneWidget); // beginner
    });

    testWidgets('difficulty filter: Trung bình shows only intermediate',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Trung bình'));
      await tester.pumpAndSettle();
      expect(find.text('Cú Lùi'), findsOneWidget);
      expect(find.text('Cú Dừng'), findsNothing);
      expect(find.text('Tay Chống'), findsNothing);
    });

    testWidgets('category filter: Kỹ Thuật Đánh narrows to shotmaking only',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Kỹ Thuật Đánh'));
      await tester.pumpAndSettle();
      expect(find.text('Cú Dừng'), findsOneWidget);
      expect(find.text('Cú Lùi'), findsOneWidget);
      expect(find.text('Tay Chống'), findsNothing);
    });

    testWidgets('search icon opens search delegate', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      // SearchDelegate renders a TextField at the top of the search route.
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}

/// Fake notifier that bypasses rootBundle loading entirely. Tests pass a
/// pre-built KnowledgeState through the constructor.
class _FakeKnowledgeNotifier extends KnowledgeNotifier {
  _FakeKnowledgeNotifier(KnowledgeState initial)
      : super.withState(initial);
}
