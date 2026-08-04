// ============================================================================
// validators_test.dart — Sprint 1 Commit 3 tests
// ============================================================================
//
// Verifies:
//  - Each of the 12 rules: PASS / WARNING / FAIL with explicit examples.
//  - ValidatorRegistry produces per-article + per-rule stats.
//  - ReportGenerator produces deterministic Markdown + JSON.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import '../../tools/knowledge_migration/validators.dart';
import '../../tools/knowledge_migration/report_generator.dart';
import '../../tools/knowledge_migration/src/migration_dto.dart';

void main() {
  /// Helper: a minimal-valid article (passes most rules).
  Map<String, dynamic> validArticle({String id = 'a.b.c'}) => {
        'id': id,
        'slug': id.replaceAll('.', '-'),
        'title': 'Sample Title',
        'titleVi': 'Mẫu Tiêu Đề',
        'content': 'A'.padRight(150, ' '),
        'contentVi': 'B'.padRight(150, ' '),
        'categoryId': 'cat_fundamentals',
        'tagIds': ['tag_basic'],
        'difficulty': 'beginner',
        'readingTimeMinutes': 5,
        'relatedDrillCodes': <String>[],
        'relatedKnowledgeIds': <String>[],
        'aliases': <String>[],
        'keywords': <String>[],
        'sources': <String>[],
      };

  group('Rule 1 — id unique', () {
    test('PASS when id appears once', () {
      final ids = ['a.b.c', 'a.b.d'];
      final v = IdUniqueValidator(ids);
      final out = v.validate('a.b.c', {'id': 'a.b.c'});
      expect(out.passed, isTrue);
    });

    test('FAIL when id appears twice', () {
      final ids = ['a.b.c', 'a.b.c', 'a.b.d'];
      final v = IdUniqueValidator(ids);
      final out = v.validate('a.b.c', {'id': 'a.b.c'});
      expect(out.passed, isFalse);
      expect(out.errors.first, contains('Duplicate'));
    });
  });

  group('Rule 2 — title non-empty', () {
    test('PASS when title >= 3 chars', () {
      final v = TitleNonEmptyValidator();
      expect(v.validate('a', {'title': 'OK Title'}).passed, isTrue);
    });
    test('FAIL when title empty', () {
      final v = TitleNonEmptyValidator();
      expect(v.validate('a', {'title': ''}).passed, isFalse);
    });
    test('FAIL when title is whitespace', () {
      final v = TitleNonEmptyValidator();
      expect(v.validate('a', {'title': '   '}).passed, isFalse);
    });
  });

  group('Rule 3 — category valid', () {
    test('PASS when categoryId in valid set', () {
      final v = CategoryValidValidator({'cat_fundamentals'});
      expect(v.validate('a', {'categoryId': 'cat_fundamentals'}).passed, isTrue);
    });
    test('FAIL when categoryId unknown', () {
      final v = CategoryValidValidator({'cat_fundamentals'});
      expect(v.validate('a', {'categoryId': 'cat_xxx'}).passed, isFalse);
    });
  });

  group('Rule 4 — difficulty valid', () {
    test('PASS for each allowed value', () {
      final v = DifficultyValidValidator();
      for (final d in ['beginner', 'intermediate', 'advanced', 'expert']) {
        expect(v.validate('a', {'difficulty': d}).passed, isTrue,
            reason: 'difficulty=$d should pass');
      }
    });
    test('FAIL for invalid value', () {
      final v = DifficultyValidValidator();
      expect(v.validate('a', {'difficulty': 'novice'}).passed, isFalse);
    });
  });

  group('Rule 5 — body non-empty', () {
    test('PASS when content >= 100 chars', () {
      final v = BodyNonEmptyValidator();
      expect(v.validate('a', {'content': 'X' * 100}).passed, isTrue);
    });
    test('FAIL when content < 100 chars', () {
      final v = BodyNonEmptyValidator();
      expect(v.validate('a', {'content': 'short'}).passed, isFalse);
    });
  });

  group('Rule 6 — tags non-empty', () {
    test('PASS when tagIds non-empty', () {
      final v = TagsNonEmptyValidator();
      expect(v.validate('a', {'tagIds': ['tag_basic']}).passed, isTrue);
    });
    test('FAIL when tagIds empty', () {
      final v = TagsNonEmptyValidator();
      expect(v.validate('a', {'tagIds': <String>[]}).passed, isFalse);
    });
  });

  group('Rule 7 — relatedDrillCodes valid', () {
    test('PASS when refs resolve', () {
      final v = RelatedDrillCodesValidator({'D1', 'D2'});
      expect(
        v.validate('a', {'relatedDrillCodes': ['D1', 'D2']}).passed,
        isTrue,
      );
    });
    test('PASS when no refs', () {
      final v = RelatedDrillCodesValidator({'D1'});
      expect(
        v.validate('a', {'relatedDrillCodes': <String>[]}).passed,
        isTrue,
      );
    });
    test('FAIL when ref unknown', () {
      final v = RelatedDrillCodesValidator({'D1'});
      final out = v.validate('a', {'relatedDrillCodes': ['DXX']});
      expect(out.passed, isFalse);
      expect(out.errors.first, contains('DXX'));
    });
  });

  group('Rule 8 — relatedKnowledgeIds valid (warning only)', () {
    test('PASS with warning when id unknown', () {
      final v = RelatedKnowledgeIdsValidator({'kn_known'});
      final out = v.validate('a', {'relatedKnowledgeIds': ['kn_xxx']});
      expect(out.passed, isTrue, reason: 'should be warning, not failure');
      expect(out.warnings, isNotEmpty);
    });
    test('PASS when no refs', () {
      final v = RelatedKnowledgeIdsValidator(<String>{});
      expect(v.validate('a', {'relatedKnowledgeIds': <String>[]}).passed, isTrue);
    });
  });

  group('Rule 9 — readingTime > 0', () {
    test('PASS when readingTime positive', () {
      final v = ReadingTimeValidator();
      expect(v.validate('a', {'readingTimeMinutes': 5}).passed, isTrue);
    });
    test('FAIL when readingTime 0', () {
      final v = ReadingTimeValidator();
      expect(v.validate('a', {'readingTimeMinutes': 0}).passed, isFalse);
    });
  });

  group('Rule 10 — search index entry', () {
    test('PASS when id in indexed set', () {
      final v = SearchIndexEntryValidator({'a.b.c'});
      expect(v.validate('a.b.c', {'id': 'a.b.c'}).passed, isTrue);
    });
    test('FAIL when id missing', () {
      final v = SearchIndexEntryValidator(<String>{});
      expect(v.validate('a.b.c', {'id': 'a.b.c'}).passed, isFalse);
    });
  });

  group('Rule 11 — markdown valid', () {
    test('PASS when content is well-formed', () {
      final v = MarkdownValidValidator();
      final out = v.validate('a', {'content': '# H1\n## H2\n\nBody text.'});
      expect(out.passed, isTrue);
    });
    test('FAIL when code fences unbalanced', () {
      final v = MarkdownValidValidator();
      final out = v.validate('a', {'content': '# H1\n```code'});
      expect(out.passed, isFalse);
      expect(out.errors.first, contains('fence'));
    });
    test('FAIL when heading malformed', () {
      final v = MarkdownValidValidator();
      final out = v.validate('a', {'content': '#broken'});
      expect(out.passed, isFalse);
    });
  });

  group('Rule 12 — UTF-8 valid', () {
    test('PASS when no replacement chars', () {
      final v = Utf8ValidValidator();
      final out = v.validate('a', {
        'id': 'a.b.c',
        'slug': 'a-b-c',
        'title': 'Cú bóng',
        'titleVi': 'Cú bóng',
        'content': 'Bài viết về Pool OS',
        'contentVi': 'Bài viết về Pool OS',
      });
      expect(out.passed, isTrue);
    });
    test('FAIL when replacement char present', () {
      final v = Utf8ValidValidator();
      final out = v.validate('a', {
        'id': 'a.b.c',
        'slug': 'a-b-c',
        'title': 'Cú bóng �',
        'titleVi': 'X',
        'content': 'X',
        'contentVi': 'X',
      });
      expect(out.passed, isFalse);
    });
  });

  group('ValidatorRegistry', () {
    test('aggregates per-rule + per-article outcomes', () {
      final articles = [
        validArticle(id: 'a.b.c'),
        validArticle(id: 'a.b.d'),
      ];
      final registry = ValidatorRegistry([
        IdUniqueValidator(articles.map((a) => a['id'] as String).toList()),
        TitleNonEmptyValidator(),
        CategoryValidValidator({'cat_fundamentals'}),
        DifficultyValidValidator(),
        BodyNonEmptyValidator(),
        TagsNonEmptyValidator(),
        RelatedDrillCodesValidator(<String>{}),
        RelatedKnowledgeIdsValidator(<String>{}),
        ReadingTimeValidator(),
        SearchIndexEntryValidator({'a.b.c', 'a.b.d'}),
        MarkdownValidValidator(),
        Utf8ValidValidator(),
      ]);
      final result = registry.runAll(articles);
      expect(result.totalArticles, equals(2));
      expect(result.passedArticles, equals(2));
      expect(result.failedArticles, equals(0));
      expect(result.ruleStats.length, equals(12));
      for (final r in result.ruleStats) {
        expect(r.failed, equals(0), reason: '${r.ruleId} should have 0 failures');
      }
    });

    test('fails when an article is invalid', () {
      final articles = [
        validArticle(id: 'a.b.c').cast<String, dynamic>(),
        // bad article
        {
          'id': 'a.b.d',
          'slug': 'a-b-d',
          'title': '',
          'content': 'short',
          'categoryId': 'cat_xxx',
          'tagIds': <String>[],
          'difficulty': 'novice',
          'readingTimeMinutes': 0,
          'relatedDrillCodes': <String>[],
          'relatedKnowledgeIds': <String>[],
          'titleVi': '',
          'contentVi': '',
          'aliases': <String>[],
          'keywords': <String>[],
          'sources': <String>[],
        },
      ];
      final registry = ValidatorRegistry([
        IdUniqueValidator(articles.map((a) => a['id'] as String).toList()),
        TitleNonEmptyValidator(),
        CategoryValidValidator({'cat_fundamentals'}),
        DifficultyValidValidator(),
        BodyNonEmptyValidator(),
        TagsNonEmptyValidator(),
        RelatedDrillCodesValidator(<String>{}),
        RelatedKnowledgeIdsValidator(<String>{}),
        ReadingTimeValidator(),
        SearchIndexEntryValidator({'a.b.c'}),
        MarkdownValidValidator(),
        Utf8ValidValidator(),
      ]);
      final result = registry.runAll(articles);
      expect(result.passedArticles, equals(1));
      expect(result.failedArticles, equals(1));
    });
  });

  group('ReportGenerator', () {
    test('produces deterministic Markdown across runs', () {
      final regen = ReportGenerator();
      final report = MigrationReport(
        domain: 'bridge/',
        articlesTotal: 2,
        articlesImported: 1,
        articlesFailed: 1,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: const [],
      );
      final stats = [
        RuleStats(ruleId: 'title-non-empty')
          ..passed = 1
          ..failed = 1,
        RuleStats(ruleId: 'id-unique')
          ..passed = 2,
      ];
      final outcomes = [
        ValidationOutcome(
          articleId: 'a.b.c',
          passed: true,
        ),
        ValidationOutcome(
          articleId: 'a.b.d',
          passed: false,
          errors: ['[title-non-empty] title empty'],
        ),
      ];
      final result = ValidationRunResult(
        outcomes: outcomes,
        ruleStats: stats,
        articleIds: const ['a.b.c', 'a.b.d'],
      );
      final a = regen.toMarkdown(report, result);
      final b = regen.toMarkdown(report, result);
      expect(a, equals(b));
      expect(a, contains('Migration Report — bridge/'));
      expect(a, contains('## Rule Breakdown'));
      expect(a, contains('title-non-empty'));
    });

    test('JSON includes summary + rule breakdown + failures', () {
      final regen = ReportGenerator();
      final report = MigrationReport(
        domain: 'pattern/',
        articlesTotal: 1,
        articlesImported: 0,
        articlesFailed: 1,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: const [],
      );
      final result = ValidationRunResult(
        outcomes: [
          ValidationOutcome(
            articleId: 'p.q.r',
            passed: false,
            errors: ['[title-non-empty] title empty'],
          ),
        ],
        ruleStats: [
          RuleStats(ruleId: 'title-non-empty')..failed = 1,
        ],
        articleIds: const ['p.q.r'],
      );
      final json = regen.toJson(report, result);
      expect(json, contains('"domain": "pattern/"'));
      expect(json, contains('"rule_breakdown"'));
      expect(json, contains('"failures"'));
    });
  });
}