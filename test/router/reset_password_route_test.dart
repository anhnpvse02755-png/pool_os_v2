// ============================================================================
// Điểm vào từ link đặt lại mật khẩu trong email.
//
// App dùng hash routing, nên GoRouter KHÔNG tự thấy `/reset-password` ở phần
// path. Hàm này phải tự bóc token ra, nếu không người dùng bấm link trong
// email sẽ rơi về màn Welcome và luồng quên mật khẩu đứt ở bước cuối.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/router/app_router.dart';

void main() {
  group('initialLocationFromUrl', () {
    test('link thật từ email đưa thẳng vào màn đặt lại kèm token', () {
      final url = Uri.parse(
          'https://poolos.kjdybl.easypanel.host/reset-password?token=abc123');

      expect(initialLocationFromUrl(url), '/reset-password?token=abc123');
    });

    test('không có token thì về Welcome, không mở màn đặt lại rỗng', () {
      final url =
          Uri.parse('https://poolos.kjdybl.easypanel.host/reset-password');

      expect(initialLocationFromUrl(url), '/welcome');
    });

    test('token rỗng cũng về Welcome', () {
      final url = Uri.parse(
          'https://poolos.kjdybl.easypanel.host/reset-password?token=');

      expect(initialLocationFromUrl(url), '/welcome');
    });

    test('có token nhưng không phải link đặt lại thì bỏ qua', () {
      final url =
          Uri.parse('https://poolos.kjdybl.easypanel.host/?token=abc123');

      expect(initialLocationFromUrl(url), '/welcome');
    });

    test('mở app bình thường thì vào Welcome', () {
      expect(initialLocationFromUrl(Uri.parse('https://poolos.example/')),
          '/welcome');
    });

    test('nhận cả trường hợp reset-password nằm trong fragment', () {
      final url = Uri.parse(
          'https://poolos.example/#/reset-password?token=xyz');

      expect(initialLocationFromUrl(url), contains('/reset-password'));
    });
  });
}
