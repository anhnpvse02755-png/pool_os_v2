import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/providers/coach_provider.dart';
import 'package:pool_os_v2/core/utils/drills_library.dart';
import 'package:pool_os_v2/knowledge/drill_code_bridge.dart';
import 'package:pool_os_v2/knowledge/knowledge_graph_service.dart';
import 'package:pool_os_v2/knowledge/player_intelligence.dart';
import 'package:pool_os_v2/presentation/providers/coach_survey_provider.dart';
import 'package:pool_os_v2/presentation/screens/coach/coach_screen.dart';
import 'package:pool_os_v2/presentation/widgets/coach/recommendation_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ba trạng thái của màn Coach: đang tải · có gợi ý · rỗng/lỗi.
///
/// Trước đây không test được: `CoachStateNotifier` gọi `_initialize()` bất
/// đồng bộ ngay trong constructor, nên trạng thái test vừa đặt đã bị ghi đè.
/// Khe `autoStart: false` + `initialState` mở đường cho bộ test này.
CoachState _trangThai({
  bool isLoading = false,
  String? error,
  CoachRecommendation? goiY,
}) =>
    CoachState(
      playerIntelligence: PlayerIntelligence.empty('test-user'),
      isLoading: isLoading,
      error: error,
      currentRecommendation: goiY,
    );

CoachRecommendation _goiY() => CoachRecommendation(
      drillCode: 'BT09',
      drillName: 'Cú bi quay lại (Draw)',
      reason: 'Bi cái của bạn hay lố vị trí',
      outcomes: ['Kiểm soát được quãng lùi'],
      estimatedMinutes: 20,
      confidence: 80,
      priority: 1,
    );

Future<void> _pump(WidgetTester tester, CoachState trangThai) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        coachStateProvider.overrideWith((ref) => CoachStateNotifier(
              ref,
              KnowledgeGraphService.instance,
              autoStart: false,
              initialState: trangThai,
            )),
        // Màn chuyển thẳng sang khảo sát nếu provider này trả true.
        needsCoachSurveyProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(home: CoachScreen()),
    ),
  );
  // `flutter_animate` hẹn giờ cho fadeIn/slideY. Không cho chúng chạy hết thì
  // test đỏ vì "A Timer is still pending" chứ không phải vì assertion. Không
  // dùng `pumpAndSettle` được: trạng thái đang tải có vòng quay quay mãi.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('ĐANG TẢI: hiện vòng quay, chưa hiện bài nào', (tester) async {
    await _pump(tester, _trangThai(isLoading: true));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Bắt đầu ngay'), findsNothing);
  });

  testWidgets('CÓ GỢI Ý: hiện tên bài, lý do và nút bắt đầu', (tester) async {
    await _pump(tester, _trangThai(goiY: _goiY()));

    expect(find.text('Cú bi quay lại (Draw)'), findsOneWidget);
    expect(find.text('Bi cái của bạn hay lố vị trí'), findsOneWidget);
    expect(find.text('Bắt đầu ngay'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('RỖNG: hiện bài dự phòng thay vì để trống', (tester) async {
    await _pump(tester, _trangThai());

    expect(find.text('Bắt đầu'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  // Nút của trạng thái rỗng điều hướng bằng một mã cứng. Mã đó phải MỞ ĐƯỢC
  // một bài có thật — nếu không, người dùng bấm vào là tới màn lỗi.
  //
  // Test này BẤM NÚT THẬT rồi đọc mã trong URL. Bản đầu của nó chỉ khẳng định
  // hằng `CoachScreen.fallbackDrillCode` giải được — và vẫn xanh khi nút bên
  // dưới còn dùng chuỗi cứng `'straight_shot'`. Một test không bao giờ đỏ được
  // thì không phải test.
  testWidgets('RỖNG: bấm "Bắt đầu" mở đúng một bài có thật', (tester) async {
    SharedPreferences.setMockInitialValues({});
    String? maDaMo;

    final router = GoRouter(
      initialLocation: '/coach',
      routes: [
        GoRoute(path: '/coach', builder: (_, _) => const CoachScreen()),
        GoRoute(
          path: '/training/session/new',
          builder: (_, state) {
            maDaMo = state.uri.queryParameters['drill'];
            return const Scaffold(body: Text('man tap'));
          },
        ),
        GoRoute(
          path: '/coach/survey',
          builder: (_, _) => const Scaffold(body: Text('khao sat')),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        coachStateProvider.overrideWith((ref) => CoachStateNotifier(
              ref,
              KnowledgeGraphService.instance,
              autoStart: false,
              initialState: _trangThai(),
            )),
        needsCoachSurveyProvider.overrideWithValue(false),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(maDaMo, isNotNull, reason: 'Bấm nút mà không điều hướng đi đâu');
    final resolved = resolveDrillCode(maDaMo!);
    expect(resolved, isNotNull,
        reason: 'Nút mở bài bằng mã "$maDaMo" — cầu nối không giải được');
    expect(DrillLibrary.getDrill(resolved!), isNotNull,
        reason: 'Mã "$maDaMo" giải ra "$resolved" nhưng bài đó không tồn tại');
  });

  // Lỗi mà không hiện gì thì người dùng thấy một gợi ý dự phòng và tưởng mọi
  // thứ bình thường — hỏng im lặng, tệ hơn báo lỗi.
  testWidgets('LỖI: nói rõ đã hỏng và cho thử lại', (tester) async {
    await _pump(tester, _trangThai(error: 'Không tải được dữ liệu'));

    expect(find.textContaining('Không tải được'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
  });
}
