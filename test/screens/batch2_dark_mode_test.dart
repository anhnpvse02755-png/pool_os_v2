import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 2', const [
    'lib/presentation/screens/shell/main_shell.dart',
    'lib/presentation/screens/home/notification_screen.dart',
    'lib/presentation/screens/home/home_screen.dart',
  ]);

  test('lô 2 giữ nguyên 4 nhãn thanh điều hướng', () {
    // E2E so khớp `exact: true` với đúng bốn chuỗi này. Đổi bất kỳ chuỗi nào
    // là gãy 4 test điều hướng cùng lúc.
    final source =
        File('lib/presentation/screens/shell/main_shell.dart')
            .readAsStringSync();

    for (final label in const ['Home', 'Train', 'Progress', 'Profile']) {
      expect(source, contains("'$label'"), reason: 'thiếu nhãn "$label"');
    }
  });

  test('main_shell không còn hằng màu thô', () {
    // Shadow của thanh dưới từng viết thẳng Color(0x0D000000)/Color(0x26000000).
    // Màu thô không đổi theo Brightness, và không ai tìm ra nó khi sửa token.
    final source =
        File('lib/presentation/screens/shell/main_shell.dart')
            .readAsStringSync();

    expect(RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)').allMatches(source), isEmpty,
        reason: 'Dùng AppShadows.soft(brightness) thay cho hằng màu thô.');
  });

  test('home giữ nguyên các nhãn E2E bám vào', () {
    final source = File('lib/presentation/screens/home/home_screen.dart')
        .readAsStringSync();

    for (final label in const [
      'Start Training',
      'Start Training Session',
      'View Training History',
      'Read knowledge article',
    ]) {
      expect(source, contains(label), reason: 'thiếu nhãn E2E "$label"');
    }
  });

  test('home chỉ còn đúng một khối gradient', () {
    // Ba mảng màu bão hoà cạnh nhau thì không mảng nào là điểm nhấn. Ngôn ngữ
    // tham chiếu là nền kem tĩnh, đúng một khối màu đậm dẫn mắt.
    final source = File('lib/presentation/screens/home/home_screen.dart')
        .readAsStringSync();

    expect(RegExp(r'LinearGradient\(').allMatches(source), hasLength(1),
        reason: 'Chỉ banner CTA chính được giữ gradient.');
  });
}
