// ============================================================================
// mappers_test.dart — Sprint 1 Commit 2 tests
// ============================================================================
//
// Verifies:
//  - IdMapper (slug derivation, validity)
//  - CategoryMapper (12 V1 categories → 8 V2 ids)
//  - TagMapper (mapped, unmapped, deduplication)
//  - SchemaMapper (full V1 → V2 mapping for a known article shape)
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import '../../tools/knowledge_migration/id_mapper.dart';
import '../../tools/knowledge_migration/category_mapper.dart';
import '../../tools/knowledge_migration/tag_mapper.dart';
import '../../tools/knowledge_migration/schema_mapper.dart';
import '../../tools/knowledge_migration/src/migration_dto.dart';

void main() {
  group('IdMapper', () {
    test('derives slug from dotted id', () {
      expect(
        IdMapper.deriveSlug('technique.stroke.fundamentals'),
        equals('technique-stroke-fundamentals'),
      );
    });

    test('accepts valid V1 ids', () {
      expect(IdMapper.isValidV1Id('bridge.open_bridge'), isTrue);
      expect(IdMapper.isValidV1Id('mental.concentration'), isTrue);
    });

    test('rejects empty id', () {
      expect(IdMapper.isValidV1Id(''), isFalse);
    });

    test('rejects id without dot', () {
      expect(IdMapper.isValidV1Id('bridge'), isFalse);
    });

    test('rejects uppercase id', () {
      expect(IdMapper.isValidV1Id('Bridge.Open'), isFalse);
    });
  });

  group('CategoryMapper', () {
    test('maps stroke → cat_fundamentals', () {
      expect(CategoryMapper.map('stroke'), equals('cat_fundamentals'));
    });

    test('maps aiming → cat_aiming', () {
      expect(CategoryMapper.map('aiming'), equals('cat_aiming'));
    });

    test('maps cueball → cat_positioning', () {
      expect(CategoryMapper.map('cueball'), equals('cat_positioning'));
    });

    test('maps strategy + safety → cat_strategy', () {
      expect(CategoryMapper.map('strategy'), equals('cat_strategy'));
      expect(CategoryMapper.map('safety'), equals('cat_strategy'));
    });

    test('maps mental → cat_psychology', () {
      expect(CategoryMapper.map('mental'), equals('cat_psychology'));
    });

    test('returns null for unmapped category', () {
      expect(CategoryMapper.map('oblivion'), isNull);
    });

    test('handles whitespace + case', () {
      expect(CategoryMapper.map('  Stance  '), equals('cat_fundamentals'));
    });
  });

  group('TagMapper', () {
    test('maps beginner → tag_basic', () {
      expect(TagMapper.map('beginner'), equals('tag_basic'));
    });

    test('maps intermediate/advanced/expert to their own', () {
      expect(TagMapper.map('intermediate'), equals('tag_intermediate'));
      expect(TagMapper.map('advanced'), equals('tag_advanced'));
      expect(TagMapper.map('expert'), equals('tag_expert'));
    });

    test('returns null for unmapped tag', () {
      expect(TagMapper.map('foo'), isNull);
    });

    test('mapAll dedupes + reports unmapped', () {
      final result = TagMapper.mapAll(
        ['beginner', 'stroke', 'foo', 'beginner'],
      );
      expect(result.ids, containsAll(['tag_basic', 'tag_technique']));
      expect(result.ids.length, equals(2));
      expect(result.unmapped, equals(['foo']));
    });
  });

  group('SchemaMapper (real mapping)', () {
    test('maps a complete V1 article', () {
      final v1Json = {
        'id': 'technique.stroke.fundamentals',
        'title': 'Stroke Fundamentals',
        'titleVi': 'Nhát Đánh Cơ Bản',
        'category': 'stroke',
        'difficulty': 'beginner',
        'summary': 'Master the basic stroke.',
        'summaryVi': 'Làm chủ nhát đánh cơ bản.',
        'purpose': 'A consistent stroke is the foundation.',
        'purposeVi': 'Nhát đánh nhất quán là nền tảng.',
        'setup': ['Stance at 30-45 degrees.', 'Plant front foot.'],
        'execution': ['Start cue smoothly.', 'Accelerate through ball.'],
        'successCriteria': ['Consistent power', 'Smooth motion'],
        'failureCriteria': ['Jerky motion'],
        'commonMistakes': [
          {
            'mistake': 'Squeezing grip',
            'mistakeVi': 'Bóp cơ quá chặt',
            'correction': 'Relax fingers',
            'correctionVi': 'Thư giãn ngón tay',
          },
        ],
        'tags': ['fundamentals', 'stroke', 'beginner'],
        'keywords': ['stroke', 'fundamentals'],
        'sources': ['Dr. Dave'],
        'estLearningMinutes': 20,
        'relatedKnowledge': [
          {'id': 'technique.breathing', 'weight': 0.9},
        ],
      };
      final v1 = V1Article(
        id: 'technique.stroke.fundamentals',
        rawJsonPath: '/tmp/v1/technique.stroke.fundamentals.json',
      );
      final v2 = SchemaMapper.map(v1, v1Json)!;

      expect(v2['id'], equals('technique.stroke.fundamentals'));
      expect(v2['slug'], equals('technique-stroke-fundamentals'));
      expect(v2['categoryId'], equals('cat_fundamentals'));
      expect(v2['tagIds'], containsAll(['tag_basic', 'tag_technique']));
      expect(v2['relatedKnowledgeIds'], equals(['technique.breathing']));
      expect(v2['readingTimeMinutes'], equals(20));
      expect(v2['content'], contains('# Stroke Fundamentals'));
      expect(v2['contentVi'], contains('# Nhát Đánh Cơ Bản'));
      expect(v2['aliases'], contains('stroke'));
      expect(v2['keywords'], equals(['fundamentals', 'stroke']));
    });

    test('returns null for unmapped category', () {
      final v1Json = {
        'id': 'foo.bar.baz',
        'title': 'X',
        'category': 'oblivion',
      };
      final v1 = V1Article(id: 'foo.bar.baz', rawJsonPath: '/tmp/x');
      expect(SchemaMapper.map(v1, v1Json), isNull);
    });

    test('throws on invalid V1 id', () {
      final v1Json = {'id': 'noDotHere', 'category': 'stroke'};
      final v1 = V1Article(id: 'noDotHere', rawJsonPath: '/tmp/x');
      expect(
        () => SchemaMapper.map(v1, v1Json),
        throwsA(isA<SchemaMapperException>()),
      );
    });

    test('uses default reading time when V1 has none', () {
      final v1Json = {
        'id': 'technique.stroke.basic',
        'title': 'X',
        'category': 'stroke',
        'tags': const [],
        'estLearningMinutes': null,
      };
      final v1 = V1Article(
          id: 'technique.stroke.basic', rawJsonPath: '/tmp/x');
      final v2 = SchemaMapper.map(v1, v1Json)!;
      expect(v2['readingTimeMinutes'], equals(5));
    });

    test('produces deterministic output across runs', () {
      final v1Json = {
        'id': 'mental.concentration',
        'title': 'Concentration',
        'titleVi': 'Tập Trung',
        'category': 'mental',
        'difficulty': 'intermediate',
        'tags': ['mental', 'concentration'],
        'keywords': ['focus'],
      };
      final v1 = V1Article(
          id: 'mental.concentration', rawJsonPath: '/tmp/x');
      final a = SchemaMapper.map(v1, v1Json)!;
      final b = SchemaMapper.map(v1, v1Json)!;
      expect(a.toString(), equals(b.toString()));
    });
  });
}