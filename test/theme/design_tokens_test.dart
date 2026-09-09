import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';

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
}
