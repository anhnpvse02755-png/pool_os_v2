// ============================================================================
// chip_layout_test.dart
//
// Chip KHONG duoc nam trong vung cuon NGANG.
//
// Phat hien 11/9/2026 bang cach dung app that va NHIN: moi chip loc o man Kien
// thuc deu cut ky tu cuoi — "Kiem Soat Vi Tri" thanh "Kiem Soat Vi Tr",
// "Chuyen gia" thanh "Chuyen gi". Loi co o CA HAI che do sang/toi.
//
// Nguyen nhan: trong `ListView(scrollDirection: horizontal)` hoac
// `SingleChildScrollView(scrollDirection: horizontal)`, con duoc cap be rong VO
// HAN. Material Chip do be rong nhan trong hoan canh do bi hut, roi cat phan
// thua. Dat trong `Wrap` (be rong co han) thi ve dung.
//
// Khong bai test nao truoc day bat duoc: hygiene token chi doc ten mau, con
// test widget khong kiem tra be rong chu ve ra.
// ============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('khong dat Chip trong vung cuon ngang', () {
    final viPham = <String>[];

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final src = file.readAsStringSync();

      // Quet tung khoi mo dau mot vung cuon, nhin xuong 1500 ky tu ke tiep.
      final moKhoi = RegExp(r'(ListView[.\w]*\(|SingleChildScrollView\()');
      for (final m in moKhoi.allMatches(src)) {
        final khoi = src.substring(
            m.start, (m.start + 1500).clamp(0, src.length));

        // Chi quan tam vung cuon NGANG.
        final dauKhoi = khoi.length < 400 ? khoi : khoi.substring(0, 400);
        if (!dauKhoi.contains('Axis.horizontal')) continue;

        final coChip = RegExp(r'\b(FilterChip|ChoiceChip|ActionChip|InputChip|Chip)\(')
                .hasMatch(khoi) ||
            RegExp(r'\b_\w*Chip\(').hasMatch(khoi);
        if (!coChip) continue;

        final dong = '\n'.allMatches(src.substring(0, m.start)).length + 1;
        viPham.add('${file.path.replaceAll(r'\', '/')}:$dong');
      }
    }

    expect(
      viPham,
      isEmpty,
      reason: 'Chip trong vung cuon ngang se bi cat ky tu cuoi cua nhan.\n'
          'Dung Wrap (be rong co han) thay vi cuon ngang:\n'
          '${viPham.join('\n')}',
    );
  });
}
