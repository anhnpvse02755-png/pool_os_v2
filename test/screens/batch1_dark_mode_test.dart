import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 1', const [
    'lib/presentation/screens/onboarding/welcome_screen.dart',
    'lib/presentation/screens/onboarding/onboarding_screen.dart',
    'lib/presentation/screens/onboarding/interest_selection_screen.dart',
    'lib/presentation/screens/auth/login_screen.dart',
    'lib/presentation/screens/auth/register_screen.dart',
    'lib/presentation/screens/auth/reset_password_screen.dart',
  ]);

  test('lô 1 giữ nguyên các chuỗi E2E bám vào', () {
    // E2E Playwright định vị bằng nhãn hiển thị. Đổi chuỗi là gãy E2E, nên
    // khoá chúng lại ngay trong suite Flutter để biết sớm.
    const anchors = {
      'lib/presentation/screens/onboarding/welcome_screen.dart': [
        'Bắt đầu ngay',
        'Tôi đã có tài khoản',
      ],
      'lib/presentation/screens/onboarding/onboarding_screen.dart': [
        'Tiếp tục',
      ],
    };

    final missing = <String>[];
    anchors.forEach((path, labels) {
      final source = File(path).readAsStringSync();
      for (final label in labels) {
        if (!source.contains(label)) missing.add('$path: "$label"');
      }
    });

    expect(missing, isEmpty,
        reason: 'E2E bám vào các nhãn này, không được đổi:\n'
            '${missing.join("\n")}');
  });
}
