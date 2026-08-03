// ============================================================================
// migration_dto.dart — data transfer objects for the migration pipeline
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// DTOs are the contracts between pipeline stages. Concrete fields will
// be filled in as Commits 2-4 land. Today: shape only.
// ============================================================================

/// V1 article input (read from `Knowledge/<domain>/`).
class V1Article {
  V1Article({
    required this.id,
    required this.rawJsonPath,
  });

  /// V1 article id (e.g. "technique.stroke.fundamentals").
  final String id;

  /// Absolute path to the V1 source file (used for SHA256 byte-equality
  /// verification in Commit 4).
  final String rawJsonPath;
}

/// V2 article output (written to `assets/knowledge/_staging/<domain>/`).
class V2Article {
  V2Article({
    required this.id,
    required this.slug,
    required this.destinationPath,
  });

  final String id;
  final String slug;

  /// Path under staging output dir.
  final String destinationPath;
}

/// Validation outcome for a single article.
class ValidationOutcome {
  ValidationOutcome({
    required this.articleId,
    required this.passed,
    this.errors = const [],
    this.warnings = const [],
  });

  final String articleId;
  final bool passed;
  final List<String> errors;
  final List<String> warnings;
}

/// Aggregate migration report.
class MigrationReport {
  MigrationReport({
    required this.domain,
    required this.articlesTotal,
    required this.articlesImported,
    required this.articlesFailed,
    required this.brokenDrillRefs,
    required this.brokenKnowledgeRefs,
    required this.warnings,
  });

  final String domain;
  final int articlesTotal;
  final int articlesImported;
  final int articlesFailed;
  final int brokenDrillRefs;
  final int brokenKnowledgeRefs;
  final List<String> warnings;

  bool get isClean =>
      articlesFailed == 0 && brokenDrillRefs == 0 && brokenKnowledgeRefs == 0;
}