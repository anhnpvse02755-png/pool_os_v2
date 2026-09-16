import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/core/utils/drills_library.dart';
import 'package:pool_os_v2/knowledge/drill_code_bridge.dart';
import 'package:pool_os_v2/knowledge/knowledge_graph_service.dart';

/// Mã bài tập là KHOÁ CHÍNH của dữ liệu: `DrillLibrary`, knowledge graph,
/// `knowledge.json` và cầu nối giữa chúng đều trỏ vào nhau bằng mã này.
///
/// Trước test này, `knowledge_graph_service` khai khoá `'BT07'` BA LẦN trong
/// cùng một map literal. Dart lấy bản cuối, nên hai bài — Follow Shot và Draw
/// Shot — bị nuốt mất im lặng, và bản sống sót còn khai chính nó làm điều kiện
/// tiên quyết. Không test nào bắt được vì map vẫn dựng thành công.
void main() {
  group('DrillLibrary — mã là khoá chính', () {
    final drills = DrillLibrary.categories.expand((c) => c.drills).toList();

    test('không mã nào trùng', () {
      final seen = <String, int>{};
      for (final d in drills) {
        seen[d.code] = (seen[d.code] ?? 0) + 1;
      }
      final trung = seen.entries.where((e) => e.value > 1).toList();
      expect(trung, isEmpty,
          reason: 'Mã trùng: ${trung.map((e) => '${e.key} x${e.value}')}');
    });

    test('đánh số liên tục BT01..BT<n>, không thủng lỗ', () {
      final so = drills
          .map((d) => int.parse(d.code.substring(2)))
          .toList()
        ..sort();
      expect(so, List.generate(drills.length, (i) => i + 1),
          reason: 'Dãy mã thủng lỗ hoặc lệch: $so');
    });

    // Ba cú xoáy dọc là nền tảng của người mới chơi. Gộp chúng thành một bài
    // thì người mới không có đường đi từng bước, và hệ gợi ý không thể nói
    // "em hỏng ở draw" — nó chỉ nói được "em hỏng ở bài gộp".
    test('stop, follow, draw là BA bài riêng', () {
      for (final tu in ['stop', 'follow', 'draw']) {
        final khop = drills.where((d) =>
            d.name.toLowerCase().contains(tu) &&
            !d.name.toLowerCase().contains('-'));
        expect(khop.length, 1,
            reason: 'Phải có đúng một bài cho "$tu", đang có ${khop.length}');
      }
    });
  });

  group('knowledge graph — node trỏ đúng', () {
    final kg = KnowledgeGraphService.instance;
    final nodes = kg.getAllDrills();

    test('mỗi node mang đúng mã của nó, không node nào bị nuốt', () {
      // `getAllDrills()` đọc values của map: khoá trùng thì bản trước biến
      // mất. Đếm số node là cách duy nhất thấy được điều đó từ bên ngoài.
      final codes = nodes.map((n) => n.code).toSet();
      expect(codes.length, nodes.length,
          reason: 'Hai node dùng chung một mã');
    });

    test('không node nào tự trỏ vào chính nó', () {
      final loi = <String>[];
      for (final n in nodes) {
        for (final field in {
          'prerequisites': n.prerequisites,
          'nextDrills': n.nextDrills,
          'relatedDrills': n.relatedDrills,
        }.entries) {
          if (field.value.contains(n.code)) {
            loi.add('${n.code}.${field.key}');
          }
        }
      }
      expect(loi, isEmpty, reason: 'Node tự tham chiếu: $loi');
    });

    test('không danh sách liên kết nào lặp cùng một mã', () {
      final loi = <String>[];
      for (final n in nodes) {
        for (final field in {
          'prerequisites': n.prerequisites,
          'nextDrills': n.nextDrills,
          'relatedDrills': n.relatedDrills,
        }.entries) {
          if (field.value.toSet().length != field.value.length) {
            loi.add('${n.code}.${field.key} = ${field.value}');
          }
        }
      }
      expect(loi, isEmpty, reason: 'Mã lặp trong danh sách: $loi');
    });

    test('mọi mã được nhắc tới đều tồn tại', () {
      final biet = nodes.map((n) => n.code).toSet();
      final treo = <String>[];
      for (final n in nodes) {
        for (final ref in [
          ...n.prerequisites,
          ...n.nextDrills,
          ...n.relatedDrills,
        ]) {
          final coTrongGraph = biet.contains(ref);
          final coTrongThuVien = DrillLibrary.getDrill(ref) != null;
          if (!coTrongGraph && !coTrongThuVien) treo.add('${n.code} -> $ref');
        }
      }
      expect(treo, isEmpty, reason: 'Trỏ tới mã không tồn tại: $treo');
    });
  });

  test('mọi mã BT trong knowledge.json đều có bài thật', () {
    final raw = File('assets/knowledge/knowledge.json').readAsStringSync();
    final codes = RegExp(r'\bBT\d{2}\b')
        .allMatches(raw)
        .map((m) => m.group(0)!)
        .toSet();
    expect(codes, isNotEmpty, reason: 'Không tìm thấy mã nào — sai đường dẫn?');

    final treo = codes
        .where((c) => DrillLibrary.getDrill(resolveDrillCode(c) ?? '') == null)
        .toList()
      ..sort();
    expect(treo, isEmpty, reason: 'knowledge.json trỏ tới bài không tồn tại: $treo');
  });

  test('cầu nối đưa stop, follow, draw tới ba bài khác nhau', () {
    final dich = {
      for (final v1 in ['STOP', 'FOLLOW', 'DRAW']) v1: v1ToV2Code(v1),
    };
    expect(dich.values.whereType<String>().toSet().length, 3,
        reason: 'Ba kỹ thuật phải mở ra ba bài khác nhau, đang là $dich');
  });
}
