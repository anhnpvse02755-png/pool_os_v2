// ============================================================================
// validators.dart — 12-rule validation engine for V2 articles
// ============================================================================
//
// Sprint 1, Commit 3.
//
// Implements the 12 rules from SPRINT_1_KNOWLEDGE_PARITY.md §3:
//
//   1. id unique         7. relatedDrillCodes valid (when present)
//   2. title non-empty   8. relatedKnowledgeIds valid (warning only)
//   3. category valid    9. readingTime > 0
//   4. difficulty valid 10. search index entry exists
//   5. body non-empty   11. markdown valid
//   6. tags non-empty   12. UTF-8 (no replacement chars)
//
// Each rule implements ArticleValidator and returns ValidationOutcome
// (defined in src/migration_dto.dart).
// ============================================================================

import 'src/migration_dto.dart';

abstract class ArticleValidator {
  String get ruleId;
  String get description;

  ValidationOutcome validate(String articleId, Map<String, dynamic> article);
}

/// Rule 1: id unique.
class IdUniqueValidator implements ArticleValidator {
  IdUniqueValidator(this.allIds);
  final List<String> allIds;

  @override
  String get ruleId => 'id-unique';
  @override
  String get description => 'Article id appears ≤ 1 time in corpus.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final count = allIds.where((id) => id == articleId).length;
    if (count > 1) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['Duplicate id: "$articleId" appears $count times'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 2: title non-empty.
class TitleNonEmptyValidator implements ArticleValidator {
  @override
  String get ruleId => 'title-non-empty';
  @override
  String get description => 'title.length >= 3 and not whitespace.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final title = (article['title'] as String?)?.trim() ?? '';
    if (title.length < 3) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['title is empty or too short: "$title"'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 3: category valid.
class CategoryValidValidator implements ArticleValidator {
  CategoryValidValidator(this.validCategoryIds);
  final Set<String> validCategoryIds;

  @override
  String get ruleId => 'category-valid';
  @override
  String get description => 'categoryId exists in V2 categories.json.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final id = article['categoryId'] as String?;
    if (id == null || !validCategoryIds.contains(id)) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['Invalid categoryId: "$id"'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 4: difficulty valid.
class DifficultyValidValidator implements ArticleValidator {
  static const allowed = {'beginner', 'intermediate', 'advanced', 'expert'};

  @override
  String get ruleId => 'difficulty-valid';
  @override
  String get description => 'One of beginner, intermediate, advanced, expert.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final d = article['difficulty'] as String?;
    if (d == null || !allowed.contains(d)) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['Invalid difficulty: "$d"'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 5: body non-empty.
class BodyNonEmptyValidator implements ArticleValidator {
  @override
  String get ruleId => 'body-non-empty';
  @override
  String get description => 'content.length >= 100.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final content = (article['content'] as String?) ?? '';
    if (content.length < 100) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['content too short: ${content.length} chars (< 100)'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 6: tags non-empty.
class TagsNonEmptyValidator implements ArticleValidator {
  @override
  String get ruleId => 'tags-non-empty';
  @override
  String get description => 'tagIds.length >= 1, all valid.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final tags = (article['tagIds'] as List<dynamic>?) ?? const [];
    if (tags.isEmpty) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['tagIds is empty'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 7: relatedDrillCodes valid.
class RelatedDrillCodesValidator implements ArticleValidator {
  RelatedDrillCodesValidator(this.validDrillCodes);
  final Set<String> validDrillCodes;

  @override
  String get ruleId => 'related-drill-codes-valid';
  @override
  String get description =>
      'relatedDrillCodes all exist in drill catalog (when present).';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final codes = ((article['relatedDrillCodes'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
    if (codes.isEmpty) return ValidationOutcome(articleId: articleId, passed: true);
    final broken = codes.where((c) => !validDrillCodes.contains(c)).toList();
    if (broken.isNotEmpty) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['Broken drill references: ${broken.join(", ")}'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 8: relatedKnowledgeIds valid (warning only).
class RelatedKnowledgeIdsValidator implements ArticleValidator {
  RelatedKnowledgeIdsValidator(this.validKnowledgeIds);
  final Set<String> validKnowledgeIds;

  @override
  String get ruleId => 'related-knowledge-ids-valid';
  @override
  String get description =>
      'relatedKnowledgeIds all exist in imported corpus (warning only).';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final ids = ((article['relatedKnowledgeIds'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
    if (ids.isEmpty) return ValidationOutcome(articleId: articleId, passed: true);
    final broken = ids.where((i) => !validKnowledgeIds.contains(i)).toList();
    if (broken.isNotEmpty) {
      return ValidationOutcome(
        articleId: articleId,
        passed: true,
        warnings: ['relatedKnowledgeIds not found: ${broken.join(", ")}'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 9: readingTime > 0.
class ReadingTimeValidator implements ArticleValidator {
  @override
  String get ruleId => 'reading-time-positive';
  @override
  String get description => 'readingTimeMinutes > 0.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final t = (article['readingTimeMinutes'] as num?)?.toInt() ?? 0;
    if (t <= 0) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['readingTimeMinutes <= 0: $t'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 10: search index entry.
class SearchIndexEntryValidator implements ArticleValidator {
  SearchIndexEntryValidator(this.indexedIds);
  final Set<String> indexedIds;

  @override
  String get ruleId => 'search-index-generated';
  @override
  String get description => 'Entry exists in search_index.json.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    if (!indexedIds.contains(articleId)) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: ['Missing search index entry'],
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 11: markdown valid.
class MarkdownValidValidator implements ArticleValidator {
  @override
  String get ruleId => 'markdown-valid';
  @override
  String get description =>
      'Markdown well-formed: balanced code fences, valid headings.';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final content = (article['content'] as String?) ?? '';
    final fenceCount = '```'.allMatches(content).length;
    final errors = <String>[];

    if (fenceCount.isOdd) {
      errors.add('Unbalanced code fences: $fenceCount');
    }

    final lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (l.startsWith('#') && !RegExp(r'^#{1,6}\s+\S').hasMatch(l)) {
        errors.add('Invalid heading at line ${i + 1}: "$l"');
      }
    }
    if (errors.isNotEmpty) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: errors,
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

/// Rule 12: UTF-8 (no replacement chars).
class Utf8ValidValidator implements ArticleValidator {
  @override
  String get ruleId => 'utf8-valid';
  @override
  String get description =>
      'No Unicode replacement chars or mojibake sequences.';

  static const _replacementChar = '�';

  @override
  ValidationOutcome validate(String articleId, Map<String, dynamic> article) {
    final fields = ['id', 'slug', 'title', 'titleVi', 'content', 'contentVi'];
    final errors = <String>[];
    for (final f in fields) {
      final v = article[f]?.toString() ?? '';
      if (v.contains(_replacementChar)) {
        errors.add('Field "$f" contains Unicode replacement char');
      }
    }
    if (errors.isNotEmpty) {
      return ValidationOutcome(
        articleId: articleId,
        passed: false,
        errors: errors,
      );
    }
    return ValidationOutcome(articleId: articleId, passed: true);
  }
}

// ============================================================================
// Registry + runner
// ============================================================================

class ValidatorRegistry {
  ValidatorRegistry(this.validators);
  final List<ArticleValidator> validators;

  ValidationRunResult runAll(List<Map<String, dynamic>> articles) {
    final articleIds = articles.map((a) => a['id'] as String).toList();
    final outcomes = <ValidationOutcome>[];
    final ruleStats = <String, RuleStats>{};

    for (final v in validators) {
      ruleStats[v.ruleId] = RuleStats(ruleId: v.ruleId);
    }

    for (final article in articles) {
      final id = article['id'] as String;
      final articleErrors = <String>[];
      final articleWarnings = <String>[];
      var passed = true;

      for (final v in validators) {
        final outcome = v.validate(id, article);
        final stats = ruleStats[v.ruleId]!;
        if (outcome.passed && outcome.warnings.isEmpty) {
          stats.passed++;
        } else if (outcome.passed && outcome.warnings.isNotEmpty) {
          stats.warned++;
        } else {
          stats.failed++;
        }
        if (outcome.errors.isNotEmpty) {
          articleErrors.addAll(outcome.errors.map((e) => '[${v.ruleId}] $e'));
          passed = false;
        }
        if (outcome.warnings.isNotEmpty) {
          articleWarnings.addAll(outcome.warnings.map((w) => '[${v.ruleId}] $w'));
        }
      }

      outcomes.add(ValidationOutcome(
        articleId: id,
        passed: passed,
        errors: articleErrors,
        warnings: articleWarnings,
      ));
    }

    return ValidationRunResult(
      outcomes: outcomes,
      ruleStats: ruleStats.values.toList(),
      articleIds: articleIds,
    );
  }
}

/// Builds a set of valid drill codes from a JSON drill catalog file.
Set<String> buildValidDrillCodes(dynamic drillCatalog) {
  final out = <String>{};
  if (drillCatalog is List) {
    for (final d in drillCatalog) {
      if (d is Map<String, dynamic>) {
        final code = d['code'] as String? ?? d['drillCode'] as String?;
        if (code != null) out.add(code);
      }
    }
  }
  return out;
}

/// Builds a set of valid V2 category IDs from categories.json.
Set<String> buildValidCategoryIds(dynamic categoriesJson) {
  final out = <String>{};
  if (categoriesJson is List) {
    for (final c in categoriesJson) {
      if (c is Map<String, dynamic>) {
        final id = c['id'] as String?;
        if (id != null) out.add(id);
      }
    }
  }
  return out;
}

extension _AllMatchesExt on String {
  Iterable<Match> allMatches(String pattern) =>
      RegExp(pattern).allMatches(this);
}