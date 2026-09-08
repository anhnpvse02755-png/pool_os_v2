// ============================================================================
// knowledge_dictionary_coverage_test.dart
//
// Verifies that every entry of Tu-Dien-Kien-Thuc-Billiard-Pool.md is present
// in assets/knowledge/knowledge.json, and that the knowledge base stays
// internally consistent as content is added.
// ============================================================================

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dictionary section → knowledge id. 36 entries (30 sections + §5.1–5.6).
const dictionaryTopics = <String, String>{
  '§1 Cách cầm cơ': 'kn_grip',
  '§2 Tư thế đứng': 'kn_stance',
  '§3 Cầu tay': 'kn_bridge',
  '§4 Cú đẩy cơ': 'kn_stroke',
  '§5 Ghost ball': 'kn_aiming',
  '§5.1 Ngắm mép bi': 'kn_aiming_fractional',
  '§5.2 Điểm xa–gần': 'kn_aiming_contact_point',
  '§5.3 Đầu gậy–mép bi': 'kn_aiming_tip_to_edge',
  '§5.4 Bi sát băng': 'kn_aiming_rail_ball',
  '§5.5 Điểm tiếp xúc mặt nỉ': 'kn_aiming_cloth_contact',
  '§5.6 Chọn phương pháp ngắm': 'kn_aiming_method_selection',
  '§6 Break shot': 'kn_break_shot',
  '§7 Follow': 'kn_follow_shot',
  '§8 Draw': 'kn_draw_shot',
  '§9 Stun shot': 'kn_stop_shot',
  '§10 Side spin / English': 'kn_english',
  '§11 Kiểm soát vị trí': 'kn_position_play',
  '§12 Safety cơ bản': 'kn_safety_play',
  '§13 Đọc bàn': 'kn_table_layout',
  '§14 Throw / Squirt / Swerve': 'kn_throw_squirt_swerve',
  '§15 Kick shot': 'kn_kick_shot',
  '§16 Bank shot': 'kn_bank_shot',
  '§17 Jump shot': 'kn_jump_shot',
  '§18 Masse shot': 'kn_masse_shot',
  '§19 Combination & Carom': 'kn_combination_carom',
  '§20 Kiểm soát tốc độ / Lag': 'kn_speed_control',
  '§21 Lập kế hoạch run-out': 'kn_run_out_planning',
  '§22 Safety nâng cao': 'kn_safety_advanced',
  '§23 Tâm lý thi đấu': 'kn_mental_game',
  '§24 8-Ball': 'kn_rules_8ball',
  '§25 9-Ball': 'kn_rules_9ball',
  '§26 10-Ball': 'kn_rules_10ball',
  '§27 Straight Pool 14.1': 'kn_rules_14_1',
  '§28 One Pocket': 'kn_rules_one_pocket',
  '§29 Chọn cơ': 'kn_cue_selection',
  '§30 Bảo trì cơ': 'kn_cue_maintenance',
};

/// The five blocks every dictionary-sourced article must carry.
const requiredSections = <String>[
  '## Mô tả',
  '## Hướng dẫn thực hiện',
  '## Lưu ý',
  '## Lỗi thường gặp',
  '## Cách sửa',
];

const validCategoryIds = <String>{
  'cat_fundamentals',
  'cat_shotmaking',
  'cat_aiming',
  'cat_positioning',
  'cat_strategy',
  'cat_equipment',
  'cat_psychology',
  'cat_rules',
};

const validDifficulties = <String>{
  'beginner',
  'intermediate',
  'advanced',
  'expert',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Map<String, dynamic>> items;
  late Map<String, Map<String, dynamic>> byId;

  setUpAll(() async {
    final raw = await rootBundle.loadString('assets/knowledge/knowledge.json');
    items = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    byId = {for (final i in items) i['id'] as String: i};
  });

  group('Dictionary coverage', () {
    test('all 36 dictionary entries exist in knowledge.json', () {
      final missing = <String>[];
      dictionaryTopics.forEach((section, id) {
        if (!byId.containsKey(id)) missing.add('$section → $id');
      });

      expect(
        missing,
        isEmpty,
        reason: 'Missing ${missing.length} dictionary entries:\n'
            '${missing.join('\n')}',
      );
    });

    test('every dictionary article carries the five content blocks', () {
      final incomplete = <String>[];

      for (final id in dictionaryTopics.values) {
        final item = byId[id];
        if (item == null) continue; // reported by the test above
        final content = item['contentVi'] as String? ?? '';
        final absent =
            requiredSections.where((s) => !content.contains(s)).toList();
        if (absent.isNotEmpty) {
          incomplete.add('$id missing: ${absent.join(', ')}');
        }
      }

      expect(
        incomplete,
        isEmpty,
        reason: 'Articles missing required sections:\n'
            '${incomplete.join('\n')}',
      );
    });

    test('the previously empty categories now have content', () {
      for (final category in ['cat_rules', 'cat_equipment']) {
        final count =
            items.where((i) => i['categoryId'] == category).length;
        expect(count, greaterThan(0),
            reason: '$category still has no knowledge items');
      }
    });
  });

  group('Knowledge base integrity', () {
    test('ids are unique', () {
      final ids = items.map((i) => i['id'] as String).toList();
      final duplicates =
          ids.where((id) => ids.where((o) => o == id).length > 1).toSet();
      expect(duplicates, isEmpty, reason: 'Duplicate ids: $duplicates');
    });

    test('slugs are unique', () {
      final slugs = items.map((i) => i['slug'] as String).toList();
      final duplicates =
          slugs.where((s) => slugs.where((o) => o == s).length > 1).toSet();
      expect(duplicates, isEmpty, reason: 'Duplicate slugs: $duplicates');
    });

    test('every categoryId is valid', () {
      final bad = items
          .where((i) => !validCategoryIds.contains(i['categoryId']))
          .map((i) => '${i['id']} → ${i['categoryId']}')
          .toList();
      expect(bad, isEmpty, reason: 'Unknown categoryId:\n${bad.join('\n')}');
    });

    test('every difficulty is valid', () {
      final bad = items
          .where((i) => !validDifficulties.contains(i['difficulty']))
          .map((i) => '${i['id']} → ${i['difficulty']}')
          .toList();
      expect(bad, isEmpty, reason: 'Unknown difficulty:\n${bad.join('\n')}');
    });

    test('every relatedKnowledgeIds entry resolves to a real article', () {
      final dangling = <String>[];
      for (final item in items) {
        final related =
            (item['relatedKnowledgeIds'] as List?)?.cast<String>() ?? const [];
        for (final ref in related) {
          if (!byId.containsKey(ref)) {
            dangling.add('${item['id']} → $ref');
          }
        }
      }
      expect(dangling, isEmpty,
          reason: 'Dangling relatedKnowledgeIds:\n${dangling.join('\n')}');
    });

    test('no article lists itself as related', () {
      final selfRefs = items
          .where((i) =>
              ((i['relatedKnowledgeIds'] as List?)?.cast<String>() ?? const [])
                  .contains(i['id']))
          .map((i) => i['id'] as String)
          .toList();
      expect(selfRefs, isEmpty, reason: 'Self-referencing: $selfRefs');
    });
  });
}
