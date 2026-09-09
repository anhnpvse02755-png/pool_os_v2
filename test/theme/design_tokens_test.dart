import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';
import 'package:pool_os_v2/core/theme/shadows.dart';
import 'package:pool_os_v2/core/theme/spacing.dart';
import 'package:pool_os_v2/core/theme/typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      final m = RegExp('static TextStyle get ' + name + r' =>(.*?);',
              dotAll: true)
          .firstMatch(source);
      expect(m, isNotNull, reason: 'khong tim thay style ' + name);
      return m!.group(1)!;
    }

    int sizeOf(String body) =>
        int.parse(RegExp(r'fontSize: (\d+)').firstMatch(body)!.group(1)!);

    test('van dung Plus Jakarta Sans', () {
      expect(source, contains('plusJakartaSans'));
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
}
