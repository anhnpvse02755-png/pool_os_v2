import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lô 1 phải sạch token cứng thì dark mode mới đúng. Test này đọc mã nguồn
/// thay vì render, vì mục tiêu là chặn `AppColors.lightFoo` quay lại.
void main() {
  const batch1 = [
    'lib/presentation/screens/onboarding/welcome_screen.dart',
    'lib/presentation/screens/onboarding/onboarding_screen.dart',
    'lib/presentation/screens/onboarding/interest_selection_screen.dart',
    'lib/presentation/screens/auth/login_screen.dart',
    'lib/presentation/screens/auth/register_screen.dart',
    'lib/presentation/screens/auth/reset_password_screen.dart',
  ];

  test('lô 1 không còn màn nào hardcode AppColors.light*', () {
    final offenders = <String>[];

    for (final path in batch1) {
      final source = File(path).readAsStringSync();
      final matches =
          RegExp(r'AppColors\.light[A-Z]\w*').allMatches(source).toList();
      if (matches.isNotEmpty) {
        offenders
            .add('$path: ${matches.map((m) => m.group(0)).toSet().join(", ")}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Phải dùng AppColors.foo(brightness) thay vì token sáng cứng:\n'
          '${offenders.join("\n")}',
    );
  });

  test('lô 1 không hardcode AppColors.dark* nốt', () {
    final offenders = <String>[];

    for (final path in batch1) {
      final source = File(path).readAsStringSync();
      final matches =
          RegExp(r'AppColors\.dark[A-Z]\w*').allMatches(source).toList();
      if (matches.isNotEmpty) {
        offenders
            .add('$path: ${matches.map((m) => m.group(0)).toSet().join(", ")}');
      }
    }

    expect(offenders, isEmpty,
        reason: 'Token tối cứng cũng sai như token sáng cứng — màn sẽ không\n'
            'đổi theo Brightness:\n${offenders.join("\n")}');
  });

  test('lô 1 không hardcode nền dịu bản sáng/tối', () {
    // `AppColors.errorSubtleLight` không khớp regex `light[A-Z]` ở trên vì
    // chữ light nằm ở cuối tên — cần luật riêng, nếu không nó lọt lưới.
    final offenders = <String>[];

    for (final path in batch1) {
      final source = File(path).readAsStringSync();
      final matches = RegExp(r'AppColors\.\w*Subtle(Light|Dark)\b')
          .allMatches(source)
          .map((m) => m.group(0)!)
          .toSet();
      if (matches.isNotEmpty) offenders.add('$path: ${matches.join(", ")}');
    }

    expect(offenders, isEmpty,
        reason: 'Dùng AppColors.errorSubtle(brightness) và anh em của nó:\n'
            '${offenders.join("\n")}');
  });

  test('lô 1 không dùng emoji làm icon', () {
    // Dải emoji thường gặp; nhãn tiếng Việt có dấu KHÔNG nằm trong dải này.
    final emoji =
        RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}]', unicode: true);
    final offenders = <String>[];

    for (final path in batch1) {
      if (emoji.hasMatch(File(path).readAsStringSync())) offenders.add(path);
    }

    expect(offenders, isEmpty,
        reason: 'Quyết định thiết kế: dùng Material icon trong ô pastel.');
  });

  test('lô 1 không dùng Colors.* của Material làm màu giao diện', () {
    // Colors.transparent và Colors.white/black trong shadow là hợp lệ; thứ
    // cần chặn là màu đặc dùng làm nền/chữ, vì chúng không đổi theo Brightness.
    final offenders = <String>[];

    for (final path in batch1) {
      final source = File(path).readAsStringSync();
      // Lookbehind loại `AppColors.` — nếu không, mọi token của app đều bị
      // bắt nhầm vì chuỗi "AppColors.x" có chứa "Colors.x".
      final matches = RegExp(r'(?<!App)\bColors\.(?!transparent)\w+')
          .allMatches(source)
          .map((m) => m.group(0)!)
          .toSet();
      if (matches.isNotEmpty) offenders.add('$path: ${matches.join(", ")}');
    }

    expect(offenders, isEmpty,
        reason: 'Dùng AppColors.foo(brightness) để dark mode đúng:\n'
            '${offenders.join("\n")}');
  });

  test('mọi màn trong lô đọc Brightness từ Theme', () {
    final offenders = <String>[];

    for (final path in batch1) {
      final source = File(path).readAsStringSync();
      if (!source.contains('Theme.of(context).brightness')) offenders.add(path);
    }

    expect(offenders, isEmpty,
        reason: 'Màn không đọc Brightness thì không thể đổi màu theo chế độ:\n'
            '${offenders.join("\n")}');
  });

  test('lô 1 giữ nguyên các chuỗi E2E bám vào', () {
    // E2E Playwright định vị bằng nhãn hiển thị. Đổi chuỗi là gãy E2E, nên
    // khoá chúng lại ngay trong suite Flutter để biết sớm.
    const anchors = {
      'lib/presentation/screens/onboarding/welcome_screen.dart': [
        'Bắt đầu ngay',
        'Tôi đã có tài khoản',
      ],
      'lib/presentation/screens/onboarding/onboarding_screen.dart': [
        'Tiếp tục',
      ],
    };

    final missing = <String>[];

    anchors.forEach((path, labels) {
      final source = File(path).readAsStringSync();
      for (final label in labels) {
        if (!source.contains(label)) missing.add('$path: "$label"');
      }
    });

    expect(missing, isEmpty,
        reason: 'E2E bám vào các nhãn này, không được đổi:\n'
            '${missing.join("\n")}');
  });
}
