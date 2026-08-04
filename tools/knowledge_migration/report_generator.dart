// ============================================================================
// report_generator.dart — full Markdown + JSON migration reports
// ============================================================================
//
// Sprint 1, Commit 3.
//
// Reports are deterministic:
//   - Rule stats table sorted by ruleId.
//   - Failure list sorted by articleId then ruleId.
//   - Warning list sorted same way.
//
// JSON output uses lexicographic key order (Dart's default).
// ============================================================================

import 'dart:convert';

import 'src/migration_dto.dart';
import 'validators.dart';

class ReportGenerator {
  String toMarkdown(
    MigrationReport report,
    ValidationRunResult validation,
  ) {
    final buf = StringBuffer();
    buf.writeln('# Migration Report — ${report.domain}');
    buf.writeln();
    buf.writeln('## Summary');
    buf.writeln();
    buf.writeln('| Metric | Value |');
    buf.writeln('|--------|------:|');
    buf.writeln('| Articles total | ${report.articlesTotal} |');
    buf.writeln('| Articles imported | ${report.articlesImported} |');
    buf.writeln('| Articles failed | ${report.articlesFailed} |');
    buf.writeln('| Articles passed | ${validation.passedArticles} |');
    buf.writeln('| Warnings | ${validation.warningCount} |');
    buf.writeln('| Broken drill refs | ${report.brokenDrillRefs} |');
    buf.writeln('| Broken knowledge refs | ${report.brokenKnowledgeRefs} |');
    buf.writeln('| Clean | ${report.isClean} |');
    buf.writeln();

    // Rule breakdown (sorted by ruleId).
    buf.writeln('## Rule Breakdown');
    buf.writeln();
    buf.writeln('| Rule | Passed | Warned | Failed |');
    buf.writeln('|------|------:|------:|------:|');
    final sortedRules = [...validation.ruleStats]
      ..sort((a, b) => a.ruleId.compareTo(b.ruleId));
    for (final r in sortedRules) {
      buf.writeln('| ${r.ruleId} | ${r.passed} | ${r.warned} | ${r.failed} |');
    }
    buf.writeln();

    // Failure list (sorted by articleId).
    final failures = [...validation.outcomes]
      ..sort((a, b) => a.articleId.compareTo(b.articleId));
    final failedOnly = failures.where((o) => !o.passed).toList();
    if (failedOnly.isNotEmpty) {
      buf.writeln('## Failures');
      buf.writeln();
      for (final o in failedOnly) {
        buf.writeln('### ${o.articleId}');
        for (final e in o.errors) {
          buf.writeln('- $e');
        }
        buf.writeln();
      }
    }

    // Warning list (sorted; capped to 100).
    final warningOutcomes = failures
        .where((o) => o.warnings.isNotEmpty)
        .toList();
    if (warningOutcomes.isNotEmpty) {
      buf.writeln('## Warnings');
      buf.writeln();
      var count = 0;
      for (final o in warningOutcomes) {
        if (count >= 100) {
          buf.writeln('_(truncated — see JSON for full list)_');
          break;
        }
        buf.writeln('- **${o.articleId}**: ${o.warnings.join("; ")}');
        count++;
      }
      buf.writeln();
    }

    if (report.warnings.isNotEmpty) {
      buf.writeln('## Pipeline Warnings');
      buf.writeln();
      for (final w in report.warnings) {
        buf.writeln('- $w');
      }
    }

    return buf.toString();
  }

  String toJson(
    MigrationReport report,
    ValidationRunResult validation,
  ) {
    final sortedRules = [...validation.ruleStats]
      ..sort((a, b) => a.ruleId.compareTo(b.ruleId));
    final sortedOutcomes = [...validation.outcomes]
      ..sort((a, b) => a.articleId.compareTo(b.articleId));

    final map = <String, dynamic>{
      'domain': report.domain,
      'summary': {
        'articles_total': report.articlesTotal,
        'articles_imported': report.articlesImported,
        'articles_failed': report.articlesFailed,
        'articles_passed': validation.passedArticles,
        'warning_count': validation.warningCount,
        'broken_drill_refs': report.brokenDrillRefs,
        'broken_knowledge_refs': report.brokenKnowledgeRefs,
        'is_clean': report.isClean,
      },
      'rule_breakdown': {
        for (final r in sortedRules)
          r.ruleId: {
            'passed': r.passed,
            'warned': r.warned,
            'failed': r.failed,
          },
      },
      'failures': sortedOutcomes
          .where((o) => !o.passed)
          .map((o) => {
                'article_id': o.articleId,
                'errors': o.errors,
              })
          .toList(),
      'warnings': sortedOutcomes
          .where((o) => o.warnings.isNotEmpty)
          .map((o) => {
                'article_id': o.articleId,
                'warnings': o.warnings,
              })
          .toList(),
      'pipeline_warnings': report.warnings,
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
