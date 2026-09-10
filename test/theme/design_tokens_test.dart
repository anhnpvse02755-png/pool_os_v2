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

  group('Nen loang cua the ti le (drill_result)', () {
    double contrast(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    // Cung mot cai bay, cung mot cach sua nhu nen header cua drill_detail.
    //
    // `ratingColor` tra ve bon bac. Khi the ti le con TO DAC, chu tren no la
    // `onPrimary` — trang o che do sang — va ba trong bon bac khong doc noi
    // ngay o che do DUY NHAT dang phat hanh: success 2.54:1, warning 2.15:1,
    // error 3.76:1. Doi hue khong cuu duoc vi loi nam o DO DAM cua nen.
    //
    // Gop hai bac cao nhat ve `success` cung khong cuu duoc: no lam che do
    // sang TE DI. Cach sua la lam nhat nen, y het drill_detail.
    const washStops = [0.18, 0.10];

    // Bon bac cua `ratingColor(b)`, viet lai o day CO CHU Y: neu ai doi mot
    // nhanh trong man hinh ma quen sua o day thi hai ben lech nhau, con neu
    // ho sua ca hai thi rang buoc tuong phan van duoc kiem tra tren tong moi.
    List<MapEntry<String, Color>> bands(Brightness b) => [
          MapEntry('>=90 Xuat sac', AppColors.success),
          MapEntry('>=70 Tot lam', AppColors.primary(b)),
          MapEntry('>=50 Can co gang', AppColors.warning),
          MapEntry('<50 Can luyen tap', AppColors.error),
        ];

    test('chu doc duoc tren nen loang cua ca bon bac, o ca hai che do', () {
      for (final b in [Brightness.light, Brightness.dark]) {
        for (final band in bands(b)) {
          for (final stop in washStops) {
            final washed = Color.alphaBlend(
              band.value.withValues(alpha: stop),
              AppColors.surface(b),
            );
            expect(
              contrast(AppColors.textPrimary(b), washed),
              greaterThanOrEqualTo(4.5),
              reason: 'chu chinh tren nen loang bac "${band.key}" @$stop o che '
                  'do $b khong doc duoc — ha alpha xuong, dung to dac lai.',
            );
          }
        }
      }
    });

    test('nhan phu KHONG duoc ha xuong textSecondary — da thu va da bo', () {
      // Cai bay tinh te: nhan phu 14px thi ai cung muon lam nhat di cho co thu
      // bac. Nhung bac ">= 70" dung `primary(light)` #0F4032 rat tham, nen
      // ngay o alpha 0.18 nen da du toi de `textSecondary` chi con 4.27:1.
      // Thu bac da do co chu 48 vs 14 lo. Khoa lai de lo sau khong "don dep".
      final washed = Color.alphaBlend(
        AppColors.primary(Brightness.light).withValues(alpha: washStops.first),
        AppColors.surface(Brightness.light),
      );
      expect(
        contrast(AppColors.textSecondary(Brightness.light), washed),
        lessThan(4.5),
        reason: 'neu textSecondary da du tuong phan thi chu thich trong '
            'drill_result_screen.dart da lac hau — doc lai roi sua.',
      );
    });

    test('phan da chay cua thanh tien do noi tren ca nen loang lan ranh', () {
      // Phan da chay MA HOA ti le nen no la doi tuong do hoa mang nghia:
      // san 3:1. Phai kiem CA HAI mep no cham vao — nen loang va ranh.
      for (final b in [Brightness.light, Brightness.dark]) {
        final fill = AppColors.textPrimary(b);
        for (final band in bands(b)) {
          for (final stop in washStops) {
            final washed = Color.alphaBlend(
              band.value.withValues(alpha: stop),
              AppColors.surface(b),
            );
            final groove = Color.alphaBlend(
              AppColors.textPrimary(b).withValues(alpha: 0.12),
              washed,
            );
            expect(contrast(fill, washed), greaterThanOrEqualTo(3.0),
                reason: 'phan da chay o bac "${band.key}" @$stop che do $b '
                    'chim vao nen loang.');
            expect(contrast(fill, groove), greaterThanOrEqualTo(3.0),
                reason: 'phan da chay o bac "${band.key}" @$stop che do $b '
                    'khong tach duoc khoi ranh.');
          }
        }
      }
    });

    test('phan da chay KHONG duoc lay `tone` hay `primary` — deu da thu', () {
      // Hai cach "hien nhien" deu hong, va hong o hai bac khac nhau nen thu
      // mot cai roi ket luan la sai. Khoa ca hai.
      //
      // `tone` dac tren nen loang cung hue: bac `warning` che do sang, 1.87:1.
      final washedWarn = Color.alphaBlend(
        AppColors.warning.withValues(alpha: washStops.first),
        AppColors.surface(Brightness.light),
      );
      expect(contrast(AppColors.warning, washedWarn), lessThan(3.0),
          reason: 'neu `tone` dac da du tuong phan thi chu thich trong '
              'drill_result_screen.dart da lac hau — doc lai roi sua.');

      // `primary` bang mau: bac `success` che do TOI, 2.89:1 voi ranh.
      final washedOk = Color.alphaBlend(
        AppColors.success.withValues(alpha: washStops.first),
        AppColors.surface(Brightness.dark),
      );
      final groove = Color.alphaBlend(
        AppColors.textPrimary(Brightness.dark).withValues(alpha: 0.12),
        washedOk,
      );
      expect(contrast(AppColors.primary(Brightness.dark), groove),
          lessThan(3.0),
          reason: 'neu `primary` da du tuong phan thi chu thich trong '
              'drill_result_screen.dart da lac hau — doc lai roi sua.');
    });

    test('nen loang phai nhat hon han ban to dac — do la ca noi dung ban sua',
        () {
      // Khoa chinh cai delta, khong chi ket qua: neu ai do quay lai to dac thi
      // test dau tien co the van xanh o mot bac may man nao do.
      for (final b in [Brightness.light, Brightness.dark]) {
        for (final band in bands(b)) {
          final washed = Color.alphaBlend(
            band.value.withValues(alpha: washStops.first),
            AppColors.surface(b),
          );
          expect(
            contrast(AppColors.textPrimary(b), washed),
            greaterThan(contrast(AppColors.textPrimary(b), band.value)),
            reason: 'bac "${band.key}" o che do $b: nen loang khong nhat hon '
                'ban to dac.',
          );
        }
      }
    });

    test('man hinh that su dung nen loang chu khong to dac', () {
      // Bon test tren chi kiem SO. Neu man hinh quay lai `colors: [tone, ...]`
      // thi chung van xanh het. Doc nguon de chac rang cach sua con nam do.
      final source =
          File('lib/presentation/screens/training/drill_result_screen.dart')
              .readAsStringSync();

      expect(source, contains('tone.withValues(alpha: 0.18)'),
          reason: 'the ti le phai dung nen loang 0.18 -> 0.10');
      expect(source, contains('tone.withValues(alpha: 0.10)'),
          reason: 'the ti le phai dung nen loang 0.18 -> 0.10');

      // Nen loang khong con bao hoa, nen chu tren THE TI LE khong duoc la
      // `onPrimary`. Token nay VAN hop le o cho khac trong file — nut bam dac
      // to bang `primary(brightness)` — nen chi cam trong pham vi the.
      final card = source.substring(
        source.indexOf('// Success rate'),
        source.indexOf("fadeIn(delay: 500.ms)"),
      );
      expect(card, isNot(contains('AppColors.onPrimary')),
          reason: 'the ti le het nen bao hoa thi khong duoc dung onPrimary — '
              'chu phai la textPrimary/textSecondary theo brightness');
      expect(card, contains('AppColors.textPrimary(brightness)'),
          reason: 'so 48px tren the ti le phai dung textPrimary');
      expect(card, isNot(contains('AppColors.textSecondary')),
          reason: 'nhan phu tren the ti le khong duoc ha xuong textSecondary');
    });
  });
}
