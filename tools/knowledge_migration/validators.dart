// ============================================================================
// validators.dart — 12-rule validation engine for V2 articles
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// The actual rule implementations land in Commit 3. Today: the
// interface only.
// ============================================================================

import 'src/migration_dto.dart';

abstract class ArticleValidator {
  /// Short id (e.g. "id-unique", "title-non-empty").
  String get ruleId;

  /// Human-readable description for the migration report.
  String get description;

  /// Returns PASS if the article satisfies the rule.
  ValidationOutcome validate(Map<String, dynamic> article);
}

class ValidatorRegistry {
  ValidatorRegistry(this.validators);

  final List<ArticleValidator> validators;

  ValidationOutcome validateAll(String articleId, Map<String, dynamic> article) {
    final errors = <String>[];
    final warnings = <String>[];

    for (final v in validators) {
      final out = v.validate(article);
      if (!out.passed) {
        if (out.errors.isNotEmpty) errors.addAll(out.errors);
        if (out.warnings.isNotEmpty) warnings.addAll(out.warnings);
      }
    }

    return ValidationOutcome(
      articleId: articleId,
      passed: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}