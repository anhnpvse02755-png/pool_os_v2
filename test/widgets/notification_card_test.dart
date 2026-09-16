import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/providers/notification_provider.dart';
import 'package:pool_os_v2/core/services/notification_service.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/screens/home/notification_screen.dart';
import 'package:pool_os_v2/presentation/widgets/icon_tile.dart';

/// Thẻ thông báo là widget duy nhất của lô 2 chưa có test.
///
/// Nó là widget RIÊNG TƯ nên không import thẳng được; test pump cả màn với
/// `notificationProvider` đã bơm sẵn dữ liệu — cách này còn đúng hơn, vì nó
/// kiểm luôn đường dây từ provider tới thẻ.
PoolNotification _thongBao({
  String id = 'n1',
  String type = 'level_up',
  String title = 'Lên cấp',
  String body = 'Bạn vừa mở khoá cấp 3',
  String? actionLabel,
  bool isRead = false,
}) =>
    PoolNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      actionLabel: actionLabel,
      createdAt: DateTime(2026, 9, 16),
      isRead: isRead,
    );

Future<void> _pump(
  WidgetTester tester,
  List<PoolNotification> data, {
  Brightness brightness = Brightness.light,
}) async {
  final notifier = NotificationNotifier();
  for (final n in data.reversed) {
    notifier.addNotification(n);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [notificationProvider.overrideWith((ref) => notifier)],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const NotificationScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Chấm tròn 8x8 báo chưa đọc.
Finder _chamChuaDoc() => find.byWidgetPredicate((w) =>
    w is Container &&
    w.constraints?.maxWidth == 8 &&
    w.decoration is BoxDecoration &&
    (w.decoration as BoxDecoration).shape == BoxShape.circle);

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  testWidgets('hiện tiêu đề và nội dung của thông báo', (tester) async {
    await _pump(tester, [_thongBao()]);

    expect(find.text('Lên cấp'), findsOneWidget);
    expect(find.text('Bạn vừa mở khoá cấp 3'), findsOneWidget);
  });

  testWidgets('chưa đọc: có chấm báo và tiêu đề in đậm', (tester) async {
    await _pump(tester, [_thongBao(isRead: false)]);

    expect(_chamChuaDoc(), findsOneWidget);
    expect(tester.widget<Text>(find.text('Lên cấp')).style!.fontWeight,
        FontWeight.bold);
  });

  testWidgets('đã đọc: mất chấm báo và tiêu đề nhẹ đi', (tester) async {
    await _pump(tester, [_thongBao(isRead: true)]);

    expect(_chamChuaDoc(), findsNothing);
    expect(tester.widget<Text>(find.text('Lên cấp')).style!.fontWeight,
        FontWeight.w500);
  });

  // Ô pastel và icon gán CỐ ĐỊNH theo loại — người dùng học được màu, nên đây
  // là hợp đồng chứ không phải chi tiết trang trí.
  //
  // Mỗi loại một test riêng: pump lần hai trong cùng một test thì Flutter tái
  // dùng cây cũ và thẻ không đổi theo dữ liệu mới, nên test xanh/đỏ nhầm chỗ.
  const tongTheoLoai = {
    'level_up': 0,
    'test_available': 1,
    'streak_warning': 2,
    'match_analysis': 3,
    'streak_milestone': 4,
    'loai-la': 0,
  };
  const iconTheoLoai = {
    'streak_warning': Icons.local_fire_department,
    'level_up': Icons.trending_up,
    'test_available': Icons.quiz,
    'match_analysis': Icons.analytics,
    'streak_milestone': Icons.emoji_events,
    'loai-la': Icons.notifications,
  };

  for (final e in tongTheoLoai.entries) {
    testWidgets('loại "${e.key}" luôn dùng tông pastel ${e.value}',
        (tester) async {
      await _pump(tester, [_thongBao(type: e.key)]);
      expect(tester.widget<IconTile>(find.byType(IconTile)).toneIndex, e.value);
    });
  }

  for (final e in iconTheoLoai.entries) {
    testWidgets('loại "${e.key}" luôn dùng đúng icon của nó', (tester) async {
      await _pump(tester, [_thongBao(type: e.key)]);
      expect(tester.widget<IconTile>(find.byType(IconTile)).icon, e.value);
    });
  }

  testWidgets('có nhãn hành động thì hiện nhãn', (tester) async {
    await _pump(tester, [_thongBao(actionLabel: 'Xem ngay')]);
    expect(find.text('Xem ngay'), findsOneWidget);
  });

  testWidgets('không có nhãn hành động thì không hiện gì thêm',
      (tester) async {
    await _pump(tester, [_thongBao()]);
    expect(find.text('Xem ngay'), findsNothing);
  });

  testWidgets('vuốt sang trái thì xoá thông báo khỏi danh sách',
      (tester) async {
    await _pump(tester, [_thongBao(id: 'a', title: 'Một'),
        _thongBao(id: 'b', title: 'Hai')]);
    expect(find.text('Một'), findsOneWidget);

    await tester.drag(find.text('Một'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Một'), findsNothing);
    expect(find.text('Hai'), findsOneWidget);
  });

  // Chấm báo là ĐỐI TƯỢNG ĐỒ HOẠ mang nghĩa (nó là thứ duy nhất phân biệt đã
  // đọc với chưa đọc), nên sàn WCAG của nó là 3:1 với mặt thẻ.
  for (final b in [Brightness.light, Brightness.dark]) {
    for (final type in [
      'streak_warning',
      'level_up',
      'streak_milestone',
      'loai-la',
    ]) {
      testWidgets('$b: chấm chưa đọc của "$type" đạt 3:1 trên mặt thẻ',
          (tester) async {
        await _pump(tester, [_thongBao(type: type)], brightness: b);
        final cham = tester.widget<Container>(_chamChuaDoc());
        final mau = (cham.decoration as BoxDecoration).color!;

        expect(_contrast(mau, AppColors.surface(b)), greaterThanOrEqualTo(3.0),
            reason: 'Chấm chưa đọc chìm vào mặt thẻ');
      });
    }
  }
}

