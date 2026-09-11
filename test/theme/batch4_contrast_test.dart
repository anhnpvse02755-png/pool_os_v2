import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';

/// Tương phản của lô 4 phải TÍNH chứ không đoán.
///
/// Bài học lô 3a: thêm một token màu mà chỉ kiểm MỘT chiều là đủ để nó lọt
/// qua ba vòng review. `difficultyExpert` từng được kiểm như màu chữ nhưng
/// không ai kiểm nó như màu nền, và nút back tụt 3,16 → 2,03:1 ở chế độ SÁNG.
/// Vì vậy mọi token thêm ở đây đều bị kiểm CẢ HAI chiều.
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
  group('lô 4 — bộ ba huy chương, kiểm hai chiều', () {
    // CHIỀU 1: huy chương làm NỀN, chữ số hạng đè lên.
    //
    // Số hạng ở bục là 24px bold, vượt ngưỡng "chữ lớn" 18.66px bold của WCAG
    // nên sàn ở đây là 3:1 chứ không phải 4.5:1. Ghi rõ lý do để lô sau không
    // tưởng đây là chỗ sàn bị nới tuỳ tiện.
    test('làm nền: chữ onPrimary đọc được trên cả ba huy chương', () {
      for (final b in _brightnesses) {
        final medals = <String, Color>{
          'vàng': AppColors.gold,
          'bạc': AppColors.silver,
          'đồng': AppColors.bronze,
        };
        for (final e in medals.entries) {
          expect(_contrast(e.value, AppColors.onPrimary(b)),
              greaterThanOrEqualTo(3.0),
              reason: 'Số hạng trên bục ${e.key} ($b) phải đạt 3:1');
        }
      }
    });

    // CHIỀU 2: huy chương làm CHỮ trên nền dịu của chính nó.
    // Đây đúng là chiều mà lô 3a bỏ sót. Chữ thường 12-16px → sàn 4.5:1.
    test('làm chữ: bản OnTint đọc được trên nền 10% của chính nó', () {
      for (final b in _brightnesses) {
        final pairs = <String, List<Color>>{
          'vàng': [AppColors.gold, AppColors.goldOnTint(b)],
          'bạc': [AppColors.silver, AppColors.silverOnTint(b)],
          'đồng': [AppColors.bronze, AppColors.bronzeOnTint(b)],
        };
        for (final e in pairs.entries) {
          final ground = _over(e.value[0], 0.10, AppColors.background(b));
          expect(_contrast(ground, e.value[1]), greaterThanOrEqualTo(4.5),
              reason: 'Chữ ${e.key} trên nền dịu của nó ($b) phải đạt 4.5:1');
        }
      }
    });

    // Ba huy chương phải phân biệt được VỚI NHAU, không chỉ với nền — bục
    // vinh danh đặt chúng cạnh nhau nên đó mới là phép so người dùng thấy.
    //
    // Đo bằng HUE chứ không bằng tỉ lệ tương phản. Bản đầu của test này dùng
    // `_contrast` và đòi 1.3 — sai thứ cần đo: tương phản là phép đo ĐỘ SÁNG,
    // mà ba kim loại vốn cùng dải sáng nên chúng trượt (gold/silver 1.27,
    // silver/bronze 1.21) dù mắt phân biệt thừa sức. Thứ tách chúng ra là sắc,
    // và hệ này đã có sẵn sàn 20° dùng cho bốn bậc độ khó ở `assessment_screen`.
    test('ba huy chương tách bạch nhau về sắc, sàn 20°', () {
      final pairs = <String, List<Color>>{
        'vàng/bạc': [AppColors.gold, AppColors.silver],
        'bạc/đồng': [AppColors.silver, AppColors.bronze],
        'vàng/đồng': [AppColors.gold, AppColors.bronze],
      };
      for (final e in pairs.entries) {
        final d = (HSLColor.fromColor(e.value[0]).hue -
                HSLColor.fromColor(e.value[1]).hue)
            .abs();
        final gap = d > 180 ? 360 - d : d;
        expect(gap, greaterThanOrEqualTo(20.0),
            reason: 'Cặp ${e.key} chỉ cách nhau ${gap.toStringAsFixed(0)}° — '
                'dưới sàn 20° thì hai huy chương đọc ra như một');
      }
    });
  });

  // Bục vinh danh chồng ba lớp: thẻ (primary 10% trên surface) → vòng tròn
  // (huy chương 30% trên thẻ) → chữ/nét. Luật vệ sinh token KHÔNG với tới đây
  // vì nó đọc mã nguồn chứ không đo tương phản — đúng khoảng mù đã để lọt lỗi
  // của lô 3a.
  group('lô 4 — bục vinh danh, ba lớp chồng nhau', () {
    Color _card(Brightness b) =>
        _over(AppColors.primary(b), 0.10, AppColors.surface(b));

    final medals = <String, Color Function(Brightness)>{
      'vàng': (b) => AppColors.gold,
      'bạc': (b) => AppColors.silver,
      'đồng': (b) => AppColors.bronze,
    };
    final onTints = <String, Color Function(Brightness)>{
      'vàng': AppColors.goldOnTint,
      'bạc': AppColors.silverOnTint,
      'đồng': AppColors.bronzeOnTint,
    };

    // Chữ avatar là 20px bold → vượt 18.66px nên sàn 3:1.
    // Dùng chính màu huy chương ở đây cho 2.11-2.84 — trượt cả sáu tổ hợp.
    test('chữ avatar đọc được trên nền 30% của huy chương', () {
      for (final b in _brightnesses) {
        for (final key in medals.keys) {
          final ring = _over(medals[key]!(b), 0.30, _card(b));
          expect(_contrast(ring, onTints[key]!(b)), greaterThanOrEqualTo(3.0),
              reason: 'Chữ avatar $key ($b) phải đạt 3:1');
        }
      }
    });

    // Viền 3px và icon cúp là thành phần UI phi văn bản → sàn 3:1.
    // Màu huy chương đặc ở đây tụt 2.87 (bạc) và 2.96 (đồng) ở chế độ TỐI.
    test('viền và icon huy chương nổi trên nền thẻ', () {
      for (final b in _brightnesses) {
        for (final key in medals.keys) {
          expect(_contrast(_card(b), onTints[key]!(b)),
              greaterThanOrEqualTo(3.0),
              reason: 'Viền/icon $key ($b) phải đạt 3:1 trên nền thẻ');
        }
      }
    });
  });

  group('lô 4 — bốn bậc trình độ community', () {
    // Badge bậc: nền là màu bậc ở alpha 0.1, chữ đặc đè lên.
    // Chữ badge 12-14px bold, dưới ngưỡng 18.66px nên sàn là 4.5:1.
    //
    // Màu NỀN và màu CHỮ không phải lúc nào cũng là một. Đo thật cho thấy
    // `warning` làm chữ trên nền 10% của chính nó chỉ được 1.82 ở chế độ sáng,
    // và `error` được 3.01 sáng / 4.39 tối — cả hai đều trượt. Hệ đã có sẵn
    // `warningOnTint`/`errorOnTint` đúng cho chiều này. `difficultyExpert` và
    // `primary` thì tự đạt nên dùng thẳng, không cần bản OnTint.
    Map<String, Color> levelTint(Brightness b) => <String, Color>{
          'Pro': AppColors.difficultyExpert(b),
          'Expert': AppColors.primary(b),
          'Advanced': AppColors.warning,
          'Beginner': AppColors.error,
        };

    Map<String, Color> levelOnTint(Brightness b) => <String, Color>{
          'Pro': AppColors.difficultyExpert(b),
          'Expert': AppColors.primary(b),
          'Advanced': AppColors.warningOnTint(b),
          'Beginner': AppColors.errorOnTint(b),
        };

    test('chữ bậc đọc được trên nền 10% của bậc đó', () {
      for (final b in _brightnesses) {
        final tint = levelTint(b);
        final onTint = levelOnTint(b);
        for (final key in tint.keys) {
          final ground = _over(tint[key]!, 0.10, AppColors.background(b));
          expect(_contrast(ground, onTint[key]!), greaterThanOrEqualTo(4.5),
              reason: 'Badge bậc $key ($b) phải đạt 4.5:1');
        }
      }
    });

    // Bốn bậc đứng cạnh nhau trong bảng xếp hạng nên phải tách bạch về sắc,
    // cùng sàn 20° mà `assessment_screen` đã đặt cho bốn bậc độ khó.
    test('bốn bậc tách bạch nhau về sắc, sàn 20°', () {
      for (final b in _brightnesses) {
        final l = levelTint(b);
        final keys = l.keys.toList();
        for (var i = 0; i < keys.length; i++) {
          for (var j = i + 1; j < keys.length; j++) {
            final d = (HSLColor.fromColor(l[keys[i]]!).hue -
                    HSLColor.fromColor(l[keys[j]]!).hue)
                .abs();
            final gap = d > 180 ? 360 - d : d;
            expect(gap, greaterThanOrEqualTo(20.0),
                reason: 'Bậc ${keys[i]} và ${keys[j]} ($b) chỉ cách '
                    '${gap.toStringAsFixed(0)}°');
          }
        }
      }
    });
  });
}
