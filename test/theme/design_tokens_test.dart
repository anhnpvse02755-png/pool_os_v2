import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/core/theme/shadows.dart';
import 'package:pool_os_v2/core/theme/spacing.dart';

void main() {
  group('Bảng màu sáng', () {
    test('nền là kem ấm, không phải trắng xám', () {
      expect(AppColors.lightBackground, const Color(0xFFF7F4EC));
    });

    test('màu chính là xanh rêu đậm', () {
      expect(AppColors.primary(Brightness.light), const Color(0xFF0F4032));
    });

    test('có bề mặt chìm cho thẻ chưa chọn', () {
      expect(AppColors.lightSurfaceRecessed, const Color(0xFFF1EFEA));
    });
  });

  group('Bảng màu tối', () {
    test('nền là than ám xanh, KHÔNG phải đen thuần', () {
      expect(AppColors.darkBackground, const Color(0xFF121715));
      expect(AppColors.darkBackground, isNot(const Color(0xFF000000)));
    });

    test('xanh chính sáng hơn bản sáng để đọc được trên nền tối', () {
      final light = AppColors.primary(Brightness.light);
      final dark = AppColors.primary(Brightness.dark);
      expect(dark, const Color(0xFF34A97C));
      expect(dark.computeLuminance(), greaterThan(light.computeLuminance()));
    });
  });

  group('Ô pastel', () {
    test('có đúng 5 tông cho mỗi chế độ', () {
      expect(AppColors.pastelLight, hasLength(5));
      expect(AppColors.pastelDark, hasLength(5));
    });

    test('pastelFor lặn vòng, không bao giờ vượt mảng', () {
      for (var i = 0; i < 12; i++) {
        expect(AppColors.pastelFor(i, Brightness.light), isA<Color>());
      }
      expect(AppColors.pastelFor(0, Brightness.light),
          AppColors.pastelFor(5, Brightness.light));
    });

    test('tông tối sẫm hơn tông sáng tương ứng', () {
      for (var i = 0; i < 5; i++) {
        expect(
          AppColors.pastelFor(i, Brightness.dark).computeLuminance(),
          lessThan(AppColors.pastelFor(i, Brightness.light).computeLuminance()),
        );
      }
    });
  });

  group('Tương phản chữ', () {
    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    test('chữ chính trên nền đạt tối thiểu 7:1 ở cả hai chế độ', () {
      expect(
        contrast(AppColors.lightTextPrimary, AppColors.lightBackground),
        greaterThanOrEqualTo(7.0),
      );
      expect(
        contrast(AppColors.darkTextPrimary, AppColors.darkBackground),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('chữ phụ trên nền đạt tối thiểu 4.5:1', () {
      expect(
        contrast(AppColors.lightTextSecondary, AppColors.lightBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(AppColors.darkTextSecondary, AppColors.darkBackground),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  group('Thang bo góc', () {
    test('mềm hơn hẳn thang cũ 6/8/12', () {
      expect(AppSpacing.radiusSm, 12.0);
      expect(AppSpacing.radiusMd, 20.0);
      expect(AppSpacing.radiusLg, 28.0);
    });

    test('tăng dần', () {
      expect(AppSpacing.radiusSm, lessThan(AppSpacing.radiusMd));
      expect(AppSpacing.radiusMd, lessThan(AppSpacing.radiusLg));
    });
  });

  group('Shadow', () {
    test('mềm và loang — blur lớn, opacity thấp', () {
      final s = AppShadows.soft(Brightness.light);
      expect(s, isNotEmpty);
      expect(s.first.blurRadius, greaterThanOrEqualTo(16));
      expect(s.first.color.a, lessThan(0.12));
    });

    test('bản tối có shadow riêng, đậm hơn', () {
      final light = AppShadows.soft(Brightness.light);
      final dark = AppShadows.soft(Brightness.dark);
      expect(dark.first.color.a, greaterThan(light.first.color.a));
    });
  });

  group('Typography', () {
    // Doc ma nguon thay vi goi AppTypography.displayLg: cac getter do goi
    // GoogleFonts.plusJakartaSans(), kich hoat mot luot tai font bat dong bo.
    // Trong moi truong test font khong co san, no nem loi SAU KHI test da ket
    // thuc ("This test failed after it had already completed") nen khong bat
    // duoc, va lam do mot test khac khong lien quan.
    //
    // Kiem tra o tang ma nguon giu dung y dinh — chan doi font, doi co, doi do
    // dam — ma khong dung toi may tai font.
    final source = File('lib/core/theme/typography.dart').readAsStringSync();

    String styleBody(String name) {
      final m = RegExp('static TextStyle get $name =>(.*?);', dotAll: true)
          .firstMatch(source);
      expect(m, isNotNull, reason: 'khong tim thay style $name');
      return m!.group(1)!;
    }

    int sizeOf(String body) =>
        int.parse(RegExp(r'fontSize: (\d+)').firstMatch(body)!.group(1)!);

    test('van dung Plus Jakarta Sans', () {
      // Khang dinh dung tren than cua _fontFamily, khong phai "co chuoi
      // plusJakartaSans o dau do trong file": doi ten bien roi gan font khac
      // van de test xanh neu chi tim chuoi tu do.
      final family = RegExp(r'get _fontFamily =>(.*?);', dotAll: true)
          .firstMatch(source);
      expect(family, isNotNull, reason: 'khong tim thay _fontFamily');
      expect(family!.group(1), contains('plusJakartaSans'));
    });

    test('tieu de trang to va rat dam', () {
      final body = styleBody('displayLg');
      expect(sizeOf(body), greaterThanOrEqualTo(28));
      expect(body, contains('FontWeight.w800'));
    });

    test('tieu de the to gan bang tieu de trang', () {
      final body = styleBody('cardTitle');
      expect(sizeOf(body), greaterThanOrEqualTo(22));
      expect(body, contains('FontWeight.w700'));
    });

    test('co style nhan hanh dong', () {
      expect(styleBody('actionLabel'), contains('FontWeight.w600'));
    });
  });

  group('Chu tren nen primary', () {
    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    // Bay that: che do toi primary la #34A97C (xanh sang). Chu trang len do
    // chi ~2.5:1 — khong doc duoc. Nen onPrimary PHAI dao chieu theo che do,
    // khong duoc la Colors.white cung.
    test('du tuong phan 4.5:1 tren nen primary o ca hai che do', () {
      for (final b in [Brightness.light, Brightness.dark]) {
        expect(
          contrast(AppColors.onPrimary(b), AppColors.primary(b)),
          greaterThanOrEqualTo(4.5),
          reason: 'onPrimary khong doc duoc tren primary o che do $b',
        );
      }
    });

    test('che do sang dung chu sang, che do toi dung chu sam', () {
      expect(
        AppColors.onPrimary(Brightness.dark).computeLuminance(),
        lessThan(AppColors.onPrimary(Brightness.light).computeLuminance()),
      );
    });
  });

  group('Tong do kho expert', () {
    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    // Bay that: gop expert vao `primary` thi che do toi expert = #34A97C,
    // lech dung 3 do hue so voi success #10B981 — bai de nhat va bai kho nhat
    // trong y het nhau. Tong rieng phai giu khoang cach hue.
    double hueOf(Color c) =>
        HSLColor.fromColor(c).hue;

    test('doi theo che do', () {
      expect(AppColors.difficultyExpert(Brightness.light),
          AppColors.lightDifficultyExpert);
      expect(AppColors.difficultyExpert(Brightness.dark),
          AppColors.darkDifficultyExpert);
    });

    test('dat toi thieu 3:1 tren nen cua chinh che do do', () {
      expect(
        contrast(AppColors.difficultyExpert(Brightness.light),
            AppColors.background(Brightness.light)),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        contrast(AppColors.difficultyExpert(Brightness.dark),
            AppColors.background(Brightness.dark)),
        greaterThanOrEqualTo(3.0),
      );
    });

    test('dat toi thieu 3:1 tren surface — no la chu tren mat the', () {
      expect(
        contrast(AppColors.difficultyExpert(Brightness.light),
            AppColors.surface(Brightness.light)),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        contrast(AppColors.difficultyExpert(Brightness.dark),
            AppColors.surface(Brightness.dark)),
        greaterThanOrEqualTo(3.0),
      );
    });

    test('khac hue ro rang voi ba tong do kho con lai', () {
      for (final b in [Brightness.light, Brightness.dark]) {
        final expert = hueOf(AppColors.difficultyExpert(b));
        for (final other in [
          AppColors.success,
          AppColors.warning,
          AppColors.error,
        ]) {
          var delta = (expert - hueOf(other)).abs();
          if (delta > 180) delta = 360 - delta;
          expect(delta, greaterThanOrEqualTo(60.0),
              reason: 'expert o che do $b qua gan hue cua $other');
        }
      }
    });

    // Bay that thu hai, va la loi cua nguoi CHON hex chu khong phai nguoi
    // dung no: #6D4AA6 duoc kiem tra nhu mot mau CHU (4.5:1 tren trang) roi
    // dem dung lam NEN header. Do sang 0.109 — tham hon han #8B5CF6 (0.198)
    // ma no thay — nen chrome (nut back / share / tieu de, ve bang
    // `textPrimary(brightness)`) tut xuong 2.03:1.
    //
    // KHONG the assert `difficultyExpert(light)` DAC dat 3:1 tren
    // `textPrimary(light)`: khong hue nao vua dat 4.5:1 lam chu badge tren
    // trang vua dat 3:1 duoi chrome gan-den — hai khung mau thuan nhau. Cach
    // sua la lam NHAT nen: header loang alpha 0.18 -> 0.10 tren `surface`.
    // Nen thu doc duoc phai la nen DA LOANG, va do la thu duoc khoa o day.
    const washStops = [0.18, 0.10];

    test('chrome doc duoc tren nen loang header o ca hai che do', () {
      for (final b in [Brightness.light, Brightness.dark]) {
        final tones = <String, Color>{
          'easy': AppColors.success,
          'medium': AppColors.warning,
          'hard': AppColors.error,
          'expert': AppColors.difficultyExpert(b),
        };
        for (final entry in tones.entries) {
          for (final stop in washStops) {
            final washed = Color.alphaBlend(
              entry.value.withValues(alpha: stop),
              AppColors.surface(b),
            );
            expect(
              contrast(AppColors.textPrimary(b), washed),
              greaterThanOrEqualTo(4.5),
              reason: 'chrome tren nen loang ${entry.key} @$stop o che do $b '
                  'khong doc duoc — dung to dac lai, hay ha alpha xuong.',
            );
          }
        }
      }
    });

    test('nen loang phai NHAT hon han ban to dac — do la ca noi dung ban sua',
        () {
      for (final b in [Brightness.light, Brightness.dark]) {
        final solid = AppColors.difficultyExpert(b);
        final washed = Color.alphaBlend(
          solid.withValues(alpha: washStops.first),
          AppColors.surface(b),
        );
        expect(
          contrast(AppColors.textPrimary(b), washed),
          greaterThan(contrast(AppColors.textPrimary(b), solid)),
        );
      }
    });

    test('KHONG duoc trung voi primary — do la loi da sua', () {
      for (final b in [Brightness.light, Brightness.dark]) {
        expect(AppColors.difficultyExpert(b), isNot(AppColors.primary(b)));
      }
    });
  });

  group('Nen semantic diu theo Brightness', () {
    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    // Man hinh dung nen diu cho hop loi / canh bao / thanh cong. Truoc day
    // chi co hang *SubtleLight va *SubtleDark, khong co accessor, nen moi man
    // deu hardcode ban sang -> dark mode hong.
    test('errorSubtle doi theo che do', () {
      expect(AppColors.errorSubtle(Brightness.light),
          AppColors.errorSubtleLight);
      expect(
          AppColors.errorSubtle(Brightness.dark), AppColors.errorSubtleDark);
    });

    test('warningSubtle doi theo che do', () {
      expect(AppColors.warningSubtle(Brightness.light),
          AppColors.warningSubtleLight);
      expect(AppColors.warningSubtle(Brightness.dark),
          AppColors.warningSubtleDark);
    });

    test('successSubtle doi theo che do', () {
      expect(AppColors.successSubtle(Brightness.light),
          AppColors.successSubtleLight);
      expect(AppColors.successSubtle(Brightness.dark),
          AppColors.successSubtleDark);
    });

    test('ban toi sam hon ban sang o ca ba', () {
      for (final pair in [
        [
          AppColors.errorSubtle(Brightness.dark),
          AppColors.errorSubtle(Brightness.light)
        ],
        [
          AppColors.warningSubtle(Brightness.dark),
          AppColors.warningSubtle(Brightness.light)
        ],
        [
          AppColors.successSubtle(Brightness.dark),
          AppColors.successSubtle(Brightness.light)
        ],
      ]) {
        expect(pair[0].computeLuminance(),
            lessThan(pair[1].computeLuminance()));
      }
    });

    // Mot o hong trong lop token thi MOI lo sau doi mot *SubtleLight deu dam
    // vao no. #7F1D1D cu cho `error` #EF4444 dung 2.66:1 — duoi san 3:1 cho
    // mot doi tuong do hoa mang nghia — trong khi hai o anh em da dat.
    // Khoa ca ba lai cung mot cho.
    test('chu/icon semantic dat toi thieu 3:1 tren nen diu ban toi', () {
      for (final pair in [
        [AppColors.error, AppColors.errorSubtle(Brightness.dark)],
        [AppColors.warning, AppColors.warningSubtle(Brightness.dark)],
        [AppColors.success, AppColors.successSubtle(Brightness.dark)],
      ]) {
        expect(
          contrast(pair[0], pair[1]),
          greaterThanOrEqualTo(3.0),
          reason: 'nen diu ban toi qua sang cho tong semantic cua chinh no — '
              'ha do sang cua nen, dung doi tong semantic.',
        );
      }
    });

    // CO CHU Y chi khoa ban TOI. Ban sang cung co van de cung loai
    // (`warning` tren #FFFBEB = 2.07:1, `success` tren #ECFDF5 = 2.41:1) nhung
    // do la no ton tu truoc va ngoai pham vi dot sua nay — khoa lai o day se
    // do ngay ma khong ai duoc giao sua. Da bao cao rieng.
  });
}
