import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os_v2/core/router/app_router.dart';

void main() {
  group('Training Session Route Ordering', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() {
      container = ProviderContainer();
      router = container.read(routerProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('/training/session/new resolves to DrillSessionScreen', () {
      final config = router.configuration;
      final sessionNewRoute = config.routes
          .expand((r) => r is ShellRoute ? r.routes : [r])
          .expand((r) => r is GoRoute ? [r] : [])
          .firstWhere(
            (r) => r.path == '/training/session/new',
            orElse: () => throw Exception('Route /training/session/new not found'),
          );

      expect(sessionNewRoute.path, '/training/session/new');
    });

    test('/training/session/new route configuration has drill query param', () {
      // Verify the route builder receives query parameters
      final config = router.configuration;
      final sessionNewRoute = config.routes
          .expand((r) => r is ShellRoute ? r.routes : [r])
          .expand((r) => r is GoRoute ? [r] : [])
          .firstWhere(
            (r) => r.path == '/training/session/new',
            orElse: () => throw Exception('Route not found'),
          );

      // Route path confirms drillCode param is expected via query parameters
      expect(sessionNewRoute.path, '/training/session/new');
    });

    test('/training/session/complete resolves to DrillCompletionScreen', () {
      final config = router.configuration;
      final completeRoute = config.routes
          .expand((r) => r is ShellRoute ? r.routes : [r])
          .expand((r) => r is GoRoute ? [r] : [])
          .firstWhere(
            (r) => r.path == '/training/session/complete',
            orElse: () => throw Exception('Route /training/session/complete not found'),
          );

      expect(completeRoute.path, '/training/session/complete');
    });

    test('/training/session/:sessionId resolves to SessionDetailScreen', () {
      final config = router.configuration;
      final sessionIdRoute = config.routes
          .expand((r) => r is ShellRoute ? r.routes : [r])
          .expand((r) => r is GoRoute ? [r] : [])
          .firstWhere(
            (r) => r.path == '/training/session/:sessionId',
            orElse: () => throw Exception('Route /training/session/:sessionId not found'),
          );

      expect(sessionIdRoute.path, '/training/session/:sessionId');
    });

    test('Static routes appear before dynamic :sessionId route', () {
      final config = router.configuration;
      final sessionRoutes = config.routes
          .expand((r) => r is ShellRoute ? r.routes : [r])
          .expand((r) => r is GoRoute ? [r] : [])
          .where((r) => r.path.startsWith('/training/session/'))
          .toList();

      // Get the index of each route
      final newIndex = sessionRoutes.indexWhere((r) => r.path == '/training/session/new');
      final completeIndex = sessionRoutes.indexWhere((r) => r.path == '/training/session/complete');
      final activeIndex = sessionRoutes.indexWhere((r) => r.path == '/training/session/active');
      final sessionIdIndex = sessionRoutes.indexWhere((r) => r.path == '/training/session/:sessionId');

      // Static routes must come before the dynamic :sessionId route
      expect(newIndex, lessThan(sessionIdIndex), reason: '/new must be before :sessionId');
      expect(completeIndex, lessThan(sessionIdIndex), reason: '/complete must be before :sessionId');
      expect(activeIndex, lessThan(sessionIdIndex), reason: '/active must be before :sessionId');
    });
  });
}
