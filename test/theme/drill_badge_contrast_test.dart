import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/presentation/screens/training/drill_list_screen.dart';

/// Huy hiệu độ khó trong thẻ bài tập: chữ đặt trên nền 10% của chính tông đó.
///
/// `colors.dart` đã ghi rõ thành ngữ này TRƯỢT ở bản sáng và phải dùng họ
/// `*OnTint`. `drill_list_screen` vẫn dùng một hàm duy nhất cho cả nền lẫn
/// chữ, nên `easy` xuống 2,31 · `medium` 1,99 · `hard` 3,29 — đều dưới sàn.
///
/// Test gọi ĐÚNG hai hàm ánh xạ của màn chứ không chép lại bảng màu; chép lại
/// thì test vẫn xanh trong khi màn dùng sai token.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// `computeLuminance()` bỏ qua alpha, nên nền 10% phải kết tủa lên nền thật
/// trước khi đo.
Color _over(Color tone, double alpha, Color ground) =>
    Color.alphaBlend(tone.withValues(alpha: alpha), ground);

const _brightnesses = [Brightness.light, Brightness.dark];

/// Năm nhánh của `switch` trong màn, kể cả nhánh mặc định.
const _doKho = ['easy', 'medium', 'hard', 'expert', 'khong-ro'];

void main() {
  group('huy hiệu độ khó — chữ trên nền 10% của chính tông', () {
    for (final b in _brightnesses) {
      for (final d in _doKho) {
        test('$b: "$d" đạt sàn 4,5:1', () {
          // Huy hiệu nằm trong thẻ, nên nền thật của nó là `surface`.
          final nen = _over(difficultyTint(d, b), 0.1, AppColors.surface(b));
          expect(_contrast(nen, difficultyOnTint(d, b)),
              greaterThanOrEqualTo(4.5),
              reason: 'Chữ "$d" 9–20px trên nền 10% của chính nó');
        });
      }
    }

    // Chiều còn lại của luật "kiểm CẢ HAI chiều": tông nền phải phân biệt
    // được với nhau, nếu không thì năm bậc độ khó nhìn như một.
    test('năm bậc không có hai bậc nào trùng tông nền', () {
      for (final b in _brightnesses) {
        final tones = _doKho.map((d) => difficultyTint(d, b)).toSet();
        expect(tones.length, _doKho.length,
            reason: 'Có hai bậc độ khó dùng chung một tông ở $b');
      }
    });
  });
}
