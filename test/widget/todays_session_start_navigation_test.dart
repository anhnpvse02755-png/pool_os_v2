import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/core/models/session_item.dart';
import 'package:pool_os_v2/core/providers/active_session_provider.dart';
import 'package:pool_os_v2/core/providers/coach_provider.dart';
import 'package:pool_os_v2/core/providers/warmup_provider.dart';
import 'package:pool_os_v2/presentation/screens/training/todays_session_screen.dart';

/// Lỗi gốc: nút "Bắt đầu buổi tập" và nút "Tự chọn bài khác" đều đi tới
/// `/training/drills`. Nút bắt đầu phải vào THẲNG bài đề xuất đầu tiên.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const proposed = ProposedSession(
    items: [
      SessionItem(
        drillCode: 'POSITION_CONTROL', // mã knowledge graph, phải dịch ra BT11
        drillName: 'Kiểm soát vị trí',
        priority: SessionPriority.path,
        estimatedMinutes: 10,
        reason: 'test',
      ),
      SessionItem(
        drillCode: 'BANK_SHOT',
        drillName: 'Đánh bi vào băng',
        priority: SessionPriority.path,
        estimatedMinutes: 10,
        reason: 'test',
      ),
    ],
    totalMinutes: 20,
    retestCount: 0,
    weaknessCount: 0,
    pathCount: 2,
  );

  /// Dựng màn Buổi tập hôm nay trong một router ghi lại đường đã đi.
  Future<List<String>> pumpAndTap(WidgetTester tester, String buttonText) async {
    SharedPreferences.setMockInitialValues({});
    final visited = <String>[];

    final router = GoRouter(
      initialLocation: '/training/session/today',
      routes: [
        GoRoute(
          path: '/training/session/today',
          builder: (_, _) => const TodaysSessionScreen(),
        ),
        GoRoute(
          path: '/training/session/new',
          builder: (context, state) {
            visited.add('/training/session/new?drill='
                '${state.uri.queryParameters['drill']}');
            return const Scaffold(body: Text('MAN TAP'));
          },
        ),
        GoRoute(
          path: '/training/drills',
          builder: (_, _) {
            visited.add('/training/drills');
            return const Scaffold(body: Text('DANH SACH BAI'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proposedSessionProvider.overrideWithValue(proposed),
          warmupDoneTodayProvider.overrideWith((ref) async => true),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Nút nằm cuối màn cuộn: không ensureVisible thì tap() bắn vào toạ độ
    // ngoài viewport và im lặng không làm gì.
    final button = find.textContaining(buttonText);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    return visited;
  }

  group('Buổi tập hôm nay — nút bắt đầu', () {
    testWidgets('"Bắt đầu buổi tập" vào thẳng bài đề xuất đầu tiên',
        (tester) async {
      final visited = await pumpAndTap(tester, 'Bắt đầu buổi tập');

      expect(visited, ['/training/session/new?drill=BT11'],
          reason: 'phải mở bài đầu tiên (POSITION_CONTROL -> BT11), '
              'không phải danh sách bài tập');
    });

    testWidgets('"Tự chọn bài khác" mới là nút đi tới danh sách bài tập',
        (tester) async {
      final visited = await pumpAndTap(tester, 'Tự chọn bài khác');

      expect(visited, ['/training/drills']);
    });

    testWidgets('bấm bắt đầu thì buổi tập được nạp đủ cả chuỗi bài',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          proposedSessionProvider.overrideWithValue(proposed),
          warmupDoneTodayProvider.overrideWith((ref) async => true),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/training/session/today',
        routes: [
          GoRoute(
            path: '/training/session/today',
            builder: (_, _) => const TodaysSessionScreen(),
          ),
          GoRoute(
            path: '/training/session/new',
            builder: (_, _) => const Scaffold(body: Text('MAN TAP')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.textContaining('Bắt đầu buổi tập');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      final active = container.read(activeSessionProvider);
      expect(active.isActive, isTrue);
      expect(active.total, 2, reason: 'cả hai bài phải nằm trong buổi tập');
      expect(active.position, 1);
      expect(active.items.map((i) => i.drillCode), ['BT11', 'BT16'],
          reason: 'mã knowledge graph phải được dịch sang mã bài tập thật');
    });
  });
}
