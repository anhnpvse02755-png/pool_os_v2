import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Chín luật vệ sinh token mà MỌI lô quét đều phải đạt.
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

  test('$batchName không dùng token hậu tố Light/Dark', () {
    // HỌ token hậu tố, không phải một token lẻ. Luật 1 đòi `light` làm TIỀN
    // TỐ, luật 3 đòi có đoạn `Subtle`, luật 7 chỉ phủ thân `accent` — nên
    // `shadowLight`, `successLight`, `warningDark`, `errorLight`, `goldLight`,
    // `streakLight`, `pastelLight/Dark` đều lọt lưới. Đây là lần vá thứ ba cho
    // cùng một hình dạng tên; vá nốt cả họ để năm lô sau không phải vá tiếp.
    //
    // Lookahead loại tiền tố `light`/`dark` (đã có luật 1 và 2 lo).
    //
    // CỐ Ý KHÔNG MIỄN TRỪ token thang độ (`successLight` = xanh nhạt hơn, chứ
    // không phải xanh chế-độ-sáng). Luật bắt chúng theo hình dạng tên, nhưng
    // bắt vậy vẫn ĐÚNG về bản chất: chúng là hằng hex cứng, không phản ứng với
    // Brightness, nên màn dùng chúng sẽ hiện y hệt nhau ở cả hai chế độ — đúng
    // cái lỗi mà cả bộ luật này sinh ra để chặn. Chúng cũng không có accessor
    // theo brightness, nên với tới chúng là với QUA lớp semantic. Lô nào thật
    // sự cần một sắc nhạt hơn thì việc đúng là thêm accessor, và luật này ép
    // đúng điều đó. Miễn trừ thì lại đẻ ra danh sách ngoại lệ từng-token mà
    // luật này vừa dọn.
    //
    // Token KHÔNG hậu tố (`AppColors.success/warning/error/gold/streak`) vẫn
    // hợp lệ: chúng bất biến theo chế độ một cách có chủ đích.
    final offenders = offendersFor(
        RegExp(r'AppColors\.(?!light|dark)[a-z]\w*(Light|Dark)\b'));
    expect(offenders, isEmpty,
        reason: 'Dùng accessor theo brightness (AppColors.foo(brightness), '
            'AppShadows.soft(brightness), AppColors.pastelFor(i, brightness)):\n'
            '$offenders');
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
