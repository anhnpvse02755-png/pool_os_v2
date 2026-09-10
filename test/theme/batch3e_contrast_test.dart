import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';

/// Tương phản của hai chỗ lô 3e phải TÍNH chứ không đoán:
///
///  1. đuôi dải loang của thẻ tổng quan màn Tiến độ, và
///  2. nền bão hoà của thẻ trạng thái màn Xu hướng.
///
/// SÀN LÀ 4.5:1, KHÔNG PHẢI 3:1. Chữ trên cả hai thẻ là 12–18px, đều dưới
/// ngưỡng 18.66px (hoặc 24px không đậm) của "chữ lớn" theo WCAG. Trong theme
/// này `titleLarge` là 16px w600 chứ không phải 22px của Material, nên không
/// có đường tắt "đây là chữ lớn nên 3:1 là đủ".
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Màu bán trong suốt kết tủa lên nền thật của nó.
///
/// `computeLuminance()` BỎ QUA alpha, nên đo thẳng một màu có alpha sẽ ra con
/// số của màu đặc — đúng cái sai đã từng cho ra "0.80 vẫn đạt".
Color _over(Color tone, double alpha, Color ground) =>
    Color.alphaBlend(tone.withValues(alpha: alpha), ground);

const _brightnesses = [Brightness.light, Brightness.dark];

void main() {
  group('lô 3e — đuôi dải loang thẻ tổng quan (progress_screen)', () {
    test('đuôi 0.86 đạt sàn 4.5:1 ở cả hai chế độ', () {
      for (final b in _brightnesses) {
        final tail = _over(
            AppColors.primary(b), 0.86, AppColors.background(b));
        expect(_contrast(tail, AppColors.onPrimary(b)), greaterThanOrEqualTo(4.5),
            reason: 'Đuôi loang $b tại alpha 0.86 phải đọc được với onPrimary');
      }
    });

    test('stop đầu (primary đặc) đạt sàn ở cả hai chế độ', () {
      for (final b in _brightnesses) {
        expect(_contrast(AppColors.primary(b), AppColors.onPrimary(b)),
            greaterThanOrEqualTo(4.5));
      }
    });

    test('0.80 KHÔNG đạt ở chế độ tối — đây là lý do sàn là 0.86', () {
      final tail = _over(AppColors.primary(Brightness.dark), 0.80,
          AppColors.background(Brightness.dark));
      expect(_contrast(tail, AppColors.onPrimary(Brightness.dark)), lessThan(4.5),
          reason: 'Nếu 0.80 bỗng đạt thì token đã đổi — xem lại mốc 0.86');
    });
  });

  group('lô 3e — nền bão hoà thẻ trạng thái (trend_dashboard_screen)', () {
    // Hai tông của thẻ: `isGood` → success, ngược lại → warning.
    const tones = {'success': AppColors.success, 'warning': AppColors.warning};

    test('nền loang 0.18→0.10 đọc được với textPrimary ở cả hai chế độ', () {
      for (final entry in tones.entries) {
        for (final b in _brightnesses) {
          for (final alpha in [0.18, 0.10]) {
            final ground = _over(entry.value, alpha, AppColors.background(b));
            expect(_contrast(ground, AppColors.textPrimary(b)),
                greaterThanOrEqualTo(4.5),
                reason: '${entry.key} @ $alpha trên nền $b');
          }
        }
      }
    });

    test('bản cũ — mực sáng trên nền đặc — hỏng, nên mới phải loang', () {
      final white = AppColors.onPrimary(Brightness.light);
      for (final entry in tones.entries) {
        expect(_contrast(entry.value, white), lessThan(3.0),
            reason: 'Chữ trắng trên ${entry.key} đặc: đây là thứ đã bỏ');
      }
    });
  });

  group('lô 3e — nút chính (training_history_screen)', () {
    test('onPrimary trên nền primary đạt sàn ở cả hai chế độ', () {
      for (final b in _brightnesses) {
        expect(_contrast(AppColors.primary(b), AppColors.onPrimary(b)),
            greaterThanOrEqualTo(4.5));
      }
    });
  });
}
