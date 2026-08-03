// ============================================================================
// migration_dto.dart — data transfer objects for the migration pipeline
// ============================================================================

/// V1 article input.
class V1Article {
  V1Article({
    required this.id,
    required this.rawJsonPath,
  });

  final String id;
  final String rawJsonPath;
}

/// V2 article output (metadata only — actual JSON lives in staging dir).
class V2Article {
  V2Article({
    required this.id,
    required this.slug,
    required this.destinationPath,
  });

  final String id;
  final String slug;
  final String destinationPath;
}

/// Outcome of a single article validation.
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

/// Per-rule stats across a validation run.
class RuleStats {
  RuleStats({required this.ruleId});
  final String ruleId;
  int passed = 0;
  int warned = 0;
  int failed = 0;
}

/// Aggregated validation run result.
class ValidationRunResult {
  ValidationRunResult({
    required this.outcomes,
    required this.ruleStats,
    required this.articleIds,
  });

  final List<ValidationOutcome> outcomes;
  final List<RuleStats> ruleStats;
  final List<String> articleIds;

  int get totalArticles => outcomes.length;
  int get passedArticles => outcomes.where((o) => o.passed).length;
  int get failedArticles => outcomes.where((o) => !o.passed).length;
  int get warningCount =>
      outcomes.fold<int>(0, (s, o) => s + o.warnings.length);
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

  ValidationRunResult? validation;

  bool get isClean =>
      articlesFailed == 0 && brokenDrillRefs == 0 && brokenKnowledgeRefs == 0;
}