import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Thư viện kiến thức: mọi mục phải là NỘI DUNG THẬT.
///
/// Bản trước của file này chỉ khoá SỐ LƯỢNG (`>= 110`). Con số đó từng đúng,
/// nhưng nó không phân biệt được bài viết thật với khuôn rỗng — và đúng chỗ đó
/// đã để lọt 102 mục sinh tự động theo mẫu:
///
///     # Hô Hấp
///     Giải thích về Hô Hấp.
///     ## Purpose
///     Khái niệm mental cốt lõi cho người chơi billiards.
///
/// Chúng dài 95–151 ký tự, không có `relatedDrillCodes`, và chiếm 74% thư viện
/// mà người dùng nhìn thấy. Vì vậy test này khoá CHẤT thay vì LƯỢNG.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<Map<String, dynamic>>> load() async {
    final raw = await rootBundle.loadString('assets/knowledge/knowledge.json');
    return (json.decode(raw) as List).cast<Map<String, dynamic>>();
  }

  test('mọi mục đều có nội dung thật, không phải khuôn rỗng', () async {
    final list = await load();
    expect(list, isNotEmpty);

    final stubs = <String>[];
    for (final m in list) {
      final body = (m['contentVi'] as String?) ?? (m['content'] as String? ?? '');
      // Khuôn rỗng dài nhất từng thấy là 151 ký tự; bài thật ngắn nhất 775.
      // Lấy 400 làm mốc — rộng rãi cho bài ngắn, vẫn chặn mọi khuôn.
      if (body.trim().length < 400) {
        stubs.add('${m['id']} (${body.trim().length} ký tự)');
      }
    }
    expect(stubs, isEmpty,
        reason: 'Những mục sau quá ngắn để là bài viết thật:\n'
            '${stubs.join('\n')}');
  });

  test('mọi liên kết relatedKnowledgeIds đều trỏ tới mục có thật', () async {
    final list = await load();
    final ids = list.map((m) => m['id'] as String).toSet();

    final dangling = <String>[];
    for (final m in list) {
      for (final r in (m['relatedKnowledgeIds'] as List? ?? const [])) {
        if (!ids.contains(r)) dangling.add('${m['id']} → $r');
      }
    }
    expect(dangling, isEmpty,
        reason: 'Liên kết gãy — trỏ tới mục không tồn tại:\n'
            '${dangling.join('\n')}');
  });

  test('mọi mục có đủ trường bắt buộc', () async {
    for (final m in await load()) {
      expect(m['id'], isNotNull, reason: 'thiếu id');
      expect(m['slug'], isNotNull, reason: 'thiếu slug');
      expect(m['title'], isNotNull, reason: 'thiếu title');
      expect(m['content'], isNotNull, reason: 'thiếu content');
      expect(m['categoryId'], isNotNull, reason: 'thiếu categoryId');
      expect(m['difficulty'], isNotNull, reason: 'thiếu difficulty');
      expect(m['relatedDrillCodes'], isA<List>(),
          reason: 'relatedDrillCodes phải là danh sách');
    }
  });

  test('mọi relatedDrillCodes trỏ tới bài tập có thật trong DrillLibrary',
      () async {
    final list = await load();

    // Mã bài tập là hằng Dart trong `DrillLibrary`, không phải asset — đọc
    // thẳng mã nguồn thay vì dựng cả cây widget, cùng lối với token_hygiene.
    final src = File('lib/core/utils/drills_library.dart').readAsStringSync();
    final codes = RegExp(r"code:\s*'([^']+)'")
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toSet();
    expect(codes, isNotEmpty, reason: 'Không đọc được mã nào từ DrillLibrary');

    final dangling = <String>[];
    for (final m in list) {
      for (final c in (m['relatedDrillCodes'] as List? ?? const [])) {
        if (!codes.contains(c)) dangling.add('${m['id']} → $c');
      }
    }
    expect(dangling, isEmpty,
        reason: 'Kiến thức trỏ tới bài tập không tồn tại:\n'
            '${dangling.join('\n')}');
  });
}
