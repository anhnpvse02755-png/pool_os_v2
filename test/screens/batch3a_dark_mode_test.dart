import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3a', const [
    'lib/presentation/screens/training/drill_list_screen.dart',
  ]);

  test('lô 3a giữ nhãn E2E của thẻ nhóm bài', () {
    // Playwright định vị thẻ nhóm bài bằng getByRole('button', name: /\d+ drills/i).
    // Đổi chuỗi này là gãy test điều hướng sang danh sách bài.
    final source =
        File('lib/presentation/screens/training/drill_list_screen.dart')
            .readAsStringSync();

    expect(source, contains(r"${category.drills.length} drills"),
        reason: 'E2E bám vào chuỗi "<n> drills"');
  });

  test('màu nhóm bài gán theo id, không theo vị trí trong danh sách', () {
    // Spec: cùng một danh mục phải LUÔN cùng tông, để người dùng học được màu.
    // Gán theo index nghĩa là thêm/bớt một nhóm sẽ đổi màu mọi nhóm sau nó.
    final source =
        File('lib/presentation/screens/training/drill_list_screen.dart')
            .readAsStringSync();

    expect(source, isNot(contains('_getColor(')),
        reason: 'Hàm gán màu theo index phải bị bỏ');
    expect(source, contains('_toneFor('),
        reason: 'Phải có hàm gán tông theo id danh mục');
    expect(source, contains("case 'aiming'"),
        reason: '_toneFor phải switch trên id danh mục');
  });
}
