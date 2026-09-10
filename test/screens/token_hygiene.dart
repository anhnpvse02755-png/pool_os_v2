import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Tám luật vệ sinh token mà MỌI lô quét đều phải đạt.
///
/// Đọc mã nguồn chứ không render: mục tiêu là chặn token khoá-sáng quay lại,
/// và việc đó rẻ hơn nhiều so với dựng đủ provider để pump từng màn.
///
/// [batchName] chỉ dùng để đặt tên test cho dễ đọc khi đỏ.
void expectTokenHygiene(String batchName, List<String> paths) {
  String readSource(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      fail('Lô "$batchName" khai báo đường dẫn không tồn tại: $path\n'
          '(kiểm tra lại danh sách paths — đường dẫn tính từ gốc package)');
    }
    return file.readAsStringSync();
  }

  String offendersFor(RegExp pattern) {
    final offenders = <String>[];
    for (final path in paths) {
      final matches = pattern
          .allMatches(readSource(path))
          .map((m) => m.group(0)!)
          .toSet();
      if (matches.isNotEmpty) {
        offenders.add('$path: ${matches.join(', ')}');
      }
    }
    return offenders.join('\n');
  }

  test('$batchName không hardcode AppColors.light*', () {
    final offenders = offendersFor(RegExp(r'AppColors\.light[A-Z]\w*'));
    expect(offenders, isEmpty,
        reason: 'Phải dùng AppColors.foo(brightness):\n$offenders');
  });

  test('$batchName không hardcode AppColors.dark*', () {
    final offenders = offendersFor(RegExp(r'AppColors\.dark[A-Z]\w*'));
    expect(offenders, isEmpty,
        reason: 'Token tối cứng cũng sai như token sáng cứng:\n$offenders');
  });

  test('$batchName không hardcode nền dịu bản sáng/tối', () {
    // `AppColors.errorSubtleLight` KHÔNG khớp regex `light[A-Z]` ở trên vì
    // chữ light nằm cuối tên — cần luật riêng, nếu không nó lọt lưới.
    final offenders =
        offendersFor(RegExp(r'AppColors\.\w*Subtle(Light|Dark)\b'));
    expect(offenders, isEmpty,
        reason: 'Dùng AppColors.errorSubtle(brightness) và anh em:\n$offenders');
  });

  test('$batchName không dùng emoji làm icon', () {
    final offenders = offendersFor(
        RegExp(r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{27BF}]', unicode: true));
    expect(offenders, isEmpty,
        reason: 'Quyết định thiết kế: Material icon trong ô pastel.\n'
            '$offenders');
  });

  test('$batchName không dùng Colors.* của Material', () {
    // Lookbehind loại `AppColors.` — nếu không, mọi token của app đều bị bắt
    // nhầm vì chuỗi "AppColors.x" có chứa "Colors.x".
    final offenders =
        offendersFor(RegExp(r'(?<!App)\bColors\.(?!transparent)\w+'));
    expect(offenders, isEmpty,
        reason: 'Dùng AppColors.foo(brightness):\n$offenders');
  });

  test('$batchName không dùng token accent xanh điện', () {
    // Cả đợt redesign tồn tại để rời khỏi accentColor/accentSubtle. Không có
    // luật này thì một lô sau có thể giữ nguyên toàn bộ chúng mà vẫn xanh.
    // `accentLabel` là token hợp lệ và KHÔNG bị bắt: `\b` không khớp được
    // giữa `t` và `L` nên nhánh rỗng của nhóm không kết thúc ở đó.
    final offenders =
        offendersFor(RegExp(r'AppColors\.accent(Color|Subtle|Light|Dark)?\b'));
    expect(offenders, isEmpty,
        reason: 'Dùng token moss (primary/primaryDeep/accentLabel):\n'
            '$offenders');
  });

  test('$batchName không còn hằng màu thô', () {
    // Màu thô không đổi theo Brightness, và không ai tìm ra nó khi sửa token.
    final offenders = offendersFor(RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)'));
    expect(offenders, isEmpty,
        reason: 'Dùng AppColors/AppShadows theo brightness:\n$offenders');
  });

  test('$batchName không dùng hằng shadow khoá chế độ', () {
    // `shadowLight` là Color(0x0D000000) — 5% đen. Trên nền than #121715 nó
    // không đóng góp gì, nên thẻ mất hẳn tín hiệu độ cao ở chế độ tối.
    // Luật `light[A-Z]` không bắt được vì ở đây "Light" là HẬU TỐ — đúng kẽ
    // hở mà luật `*Subtle(Light|Dark)` đã phải viết riêng cho họ token kia.
    final offenders = offendersFor(RegExp(r'AppColors\.shadow(Light|Dark)\b'));
    expect(offenders, isEmpty,
        reason: 'Dùng AppShadows.soft(brightness):\n$offenders');
  });

  test('$batchName mọi màn đọc Brightness', () {
    final offenders = <String>[];
    for (final path in paths) {
      final source = readSource(path);
      // Widget con nhận Brightness qua tham số cũng hợp lệ — cái sai là file
      // không hề biết tới Brightness ở bất kỳ dạng nào.
      if (!source.contains('Theme.of(context).brightness') &&
          !source.contains('Brightness brightness')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty,
        reason: 'Màn không đọc Brightness thì không đổi màu theo chế độ:\n'
            '${offenders.join("\n")}');
  });
}
