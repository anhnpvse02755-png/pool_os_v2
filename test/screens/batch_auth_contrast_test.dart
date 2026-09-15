import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/theme/colors.dart';

import 'token_hygiene.dart';

/// Lô auth/welcome — 6 màn đầu của đợt quét, cộng một luật tương phản.
///
/// Mười luật vệ sinh token đọc TÊN token. Chúng không thấy được lỗi kiểu
/// "token đúng nhưng đặt cạnh nhau thì không đọc được" — đúng lỗi mà lô này
/// tìm ra: nút tắt vẽ chữ TRẮNG trên `textTertiary`, tỉ lệ 2.59 ở bản sáng.
/// `textTertiary` là token CHỮ; dùng nó làm NỀN là chiều thứ hai mà CLAUDE.md
/// cảnh báo phải kiểm.
const _batchPaths = [
  'lib/presentation/screens/auth/login_screen.dart',
  'lib/presentation/screens/auth/register_screen.dart',
  'lib/presentation/screens/auth/reset_password_screen.dart',
  'lib/presentation/screens/onboarding/welcome_screen.dart',
  'lib/presentation/screens/onboarding/onboarding_screen.dart',
  'lib/presentation/screens/onboarding/interest_selection_screen.dart',
];

/// Tỉ lệ tương phản WCAG 2.1 giữa hai màu đục.
double contrastRatio(Color a, Color b) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  double lum(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  final la = lum(a);
  final lb = lum(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('lô auth — vệ sinh token', () {
    expectTokenHygiene('lô auth', _batchPaths);
  });

  group('lô auth — tương phản cặp màu thật', () {
    for (final brightness in Brightness.values) {
      final ten = brightness == Brightness.light ? 'sáng' : 'tối';

      test('nhãn nút TẮT đọc được ở bản $ten', () {
        // Nền nút tắt và chữ trên nó là một CẶP, không phải hai quyết định
        // rời nhau.
        expect(
          contrastRatio(
            AppColors.textSecondary(brightness),
            AppColors.surfaceRecessed(brightness),
          ),
          greaterThanOrEqualTo(4.5),
          reason: 'nhãn nút tắt phải đọc được — trước đây là 2.59',
        );
      });

      test('nhãn nút BẬT đọc được ở bản $ten', () {
        expect(
          contrastRatio(
            AppColors.onPrimary(brightness),
            AppColors.primary(brightness),
          ),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('chữ chính và chữ phụ đọc được trên nền ở bản $ten', () {
        for (final pair in [
          [AppColors.textPrimary(brightness), AppColors.background(brightness)],
          [AppColors.textPrimary(brightness), AppColors.surface(brightness)],
          [
            AppColors.textSecondary(brightness),
            AppColors.background(brightness)
          ],
          [AppColors.textSecondary(brightness), AppColors.surface(brightness)],
        ]) {
          expect(contrastRatio(pair[0], pair[1]),
              greaterThanOrEqualTo(4.5));
        }
      });
    }

    test('không màn nào trong lô dùng textTertiary làm NỀN', () {
      final offenders = <String>[];
      for (final path in _batchPaths) {
        final src = File(path).readAsStringSync();
        // `color:` bên trong BoxDecoration là NỀN. `textTertiary` ở đó nghĩa
        // là một token chữ đang bị dùng làm nền.
        final pattern = RegExp(
          r'decoration: BoxDecoration\((?:[^()]|\([^()]*\))*?'
          r'AppColors\.textTertiary\(',
        );
        if (pattern.hasMatch(src)) offenders.add(path);
      }
      expect(offenders, isEmpty,
          reason: 'token CHỮ dùng làm NỀN — phải kiểm cả hai chiều:\n'
              '${offenders.join("\n")}');
    });
  });
}
