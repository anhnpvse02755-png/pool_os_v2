import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/utils/drills_library.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3a', const [
    'lib/presentation/screens/training/drill_list_screen.dart',
    'lib/presentation/screens/training/drill_detail_screen.dart',
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
  });

  test('_toneFor liệt kê ĐỦ mọi danh mục có thật, không rơi vào default', () {
    // Chỉ kiểm `case 'aiming'` thì một nhãn case gõ sai vẫn xanh, mà mười
    // danh mục còn lại lặng lẽ dồn hết về `default` -> cùng một tông.
    // Duyệt danh sách THẬT nên thêm danh mục mới mà quên gán tông là đỏ ngay.
    final source =
        File('lib/presentation/screens/training/drill_list_screen.dart')
            .readAsStringSync();

    final missing = <String>[];
    for (final category in DrillLibrary.categories) {
      if (!source.contains("case '${category.id}'")) {
        missing.add(category.id);
      }
    }

    expect(missing, isEmpty,
        reason: '_toneFor thiếu case cho danh mục: ${missing.join(", ")}\n'
            '(rơi vào default nghĩa là chúng dùng chung tông 0)');
  });

  test('không tông nào suy ra từ vị trí trong danh sách', () {
    // Ràng buộc thật sự của task: `_toneFor(category.id)` chứ không phải
    // `_toneFor(index)`, và không có phép chia dư trên index ở bất kỳ đâu.
    // `hashCode % 5` cũng bị chặn — nó ổn định giữa các lần chạy nhưng không
    // đọc được, và không ai kiểm soát được nhóm nào ra tông nào.
    final source =
        File('lib/presentation/screens/training/drill_list_screen.dart')
            .readAsStringSync();

    expect(source, contains('_toneFor(category.id)'),
        reason: 'Tông phải gán theo id, không theo index');
    expect(source, isNot(contains('index %')),
        reason: 'Chia dư trên index là gán theo vị trí');
    expect(source, isNot(contains('hashCode')),
        reason: 'Băm id ra tông thì không kiểm soát được nhóm nào màu gì');
  });
}
