import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/widgets/icon_tile.dart';
import 'package:pool_os_v2/presentation/widgets/logo/pool_cue_mark.dart';

/// Dấu hiệu bi-a của app: một bi đặc và cây cơ chéo chạm vào nó.
///
/// Trước đây tám chỗ dùng `Icons.pool` — biểu tượng BỂ BƠI, hình người đang
/// bơi. PoolOS là app bi-a. Material không có glyph bi-a nào nên mark này phải
/// tự vẽ.
Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: Center(child: child)),
    );

PoolCueMarkPainter _painterOf(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(PoolCueMark),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as PoolCueMarkPainter;
}

void main() {
  group('PoolCueMark', () {
    testWidgets('chế độ sáng: mặc định lấy AppColors.lightPrimary',
        (tester) async {
      await tester.pumpWidget(_wrap(const PoolCueMark(), Brightness.light));
      expect(_painterOf(tester).color, AppColors.lightPrimary);
    });

    testWidgets('chế độ tối: mặc định lấy AppColors.darkPrimary',
        (tester) async {
      await tester.pumpWidget(_wrap(const PoolCueMark(), Brightness.dark));
      expect(_painterOf(tester).color, AppColors.darkPrimary);
    });

    testWidgets('màu truyền vào thì thắng màu mặc định', (tester) async {
      await tester.pumpWidget(
          _wrap(const PoolCueMark(color: AppColors.gold), Brightness.light));
      expect(_painterOf(tester).color, AppColors.gold);
    });

    testWidgets('chiếm đúng ô vuông bằng size', (tester) async {
      await tester.pumpWidget(_wrap(const PoolCueMark(size: 42), Brightness.light));
      expect(tester.getSize(find.byType(PoolCueMark)), const Size(42, 42));
    });

    // Một painter vẽ rỗng vẫn dựng được và vẫn qua mọi assertion ở trên. Chỉ
    // có đọc pixel mới chứng minh nó thật sự vẽ ra hình.
    testWidgets('vẽ ra pixel thật, không phải ô trống', (tester) async {
      await tester.pumpWidget(_wrap(
        RepaintBoundary(
          key: const Key('mark-boundary'),
          child: const PoolCueMark(size: 64, color: Color(0xFF000000)),
        ),
        Brightness.light,
      ));
      await tester.pumpAndSettle();

      final bytes = await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('mark-boundary')));
        final image = await boundary.toImage();
        return image.toByteData(format: ui.ImageByteFormat.rawRgba);
      });

      final data = bytes!.buffer.asUint8List();
      var soPixelDaVe = 0;
      for (var i = 3; i < data.length; i += 4) {
        if (data[i] > 0) soPixelDaVe++;
      }
      final tong = data.length ~/ 4;
      expect(soPixelDaVe, greaterThan(tong ~/ 20),
          reason: 'Mark chỉ phủ ${soPixelDaVe * 100 ~/ tong}% ô — gần như trống');
      expect(soPixelDaVe, lessThan(tong),
          reason: 'Mark phủ kín cả ô — nhiều khả năng đang vẽ một khối đặc');
    });
  });

  group('IconTile.mark', () {
    testWidgets('dựng mark bi-a chứ không dựng Icon', (tester) async {
      await tester.pumpWidget(_wrap(
          const IconTile.mark(toneIndex: 0, size: 80), Brightness.light));

      expect(find.byType(PoolCueMark), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('mark lấy màu primary và cỡ theo tỉ lệ của ô như Icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
          const IconTile.mark(toneIndex: 0, size: 80), Brightness.dark));

      final mark = tester.widget<PoolCueMark>(find.byType(PoolCueMark));
      expect(mark.color, AppColors.darkPrimary);
      expect(mark.size, 80 * 0.46);
    });

    testWidgets('vẫn giữ nền pastel theo toneIndex', (tester) async {
      await tester.pumpWidget(_wrap(
          const IconTile.mark(toneIndex: 2), Brightness.light));

      final container = tester.widget<Container>(
          find.byKey(const Key('icon-tile-container')));
      expect((container.decoration as BoxDecoration).color,
          AppColors.pastelFor(2, Brightness.light));
    });
  });

  // Luật chặn tái phát, cùng khuôn với vệ sinh token: đọc mã nguồn.
  test('không tệp nào trong lib/ còn dùng Icons.pool (biểu tượng bể bơi)', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final match in RegExp(r'Icons\.pool\b').allMatches(source)) {
        final dong = '\n'.allMatches(source.substring(0, match.start)).length + 1;
        offenders.add('${entity.path}:$dong');
      }
    }

    expect(offenders, isEmpty,
        reason: 'Icons.pool là biểu tượng BỂ BƠI (người đang bơi). PoolOS là '
            'app bi-a — dùng PoolCueMark hoặc IconTile.mark:\n'
            '${offenders.join('\n')}');
  });
}
