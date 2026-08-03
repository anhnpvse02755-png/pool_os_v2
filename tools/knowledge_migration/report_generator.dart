// ============================================================================
// report_generator.dart — Markdown + JSON migration reports
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
// ============================================================================

import 'src/migration_dto.dart';

class ReportGenerator {
  String toMarkdown(MigrationReport report) {
    final buf = StringBuffer();
    buf.writeln('# Migration Report — ${report.domain}');
    buf.writeln();
    buf.writeln('| Metric | Value |');
    buf.writeln('|--------|------:|');
    buf.writeln('| Articles total | ${report.articlesTotal} |');
    buf.writeln('| Articles imported | ${report.articlesImported} |');
    buf.writeln('| Articles failed | ${report.articlesFailed} |');
    buf.writeln('| Broken drill refs | ${report.brokenDrillRefs} |');
    buf.writeln('| Broken knowledge refs | ${report.brokenKnowledgeRefs} |');
    buf.writeln('| Clean | ${report.isClean} |');
    if (report.warnings.isNotEmpty) {
      buf.writeln();
      buf.writeln('## Warnings');
      for (final w in report.warnings) {
        buf.writeln('- $w');
      }
    }
    return buf.toString();
  }

  Map<String, dynamic> toJson(MigrationReport report) => <String, dynamic>{
        'domain': report.domain,
        'articles_total': report.articlesTotal,
        'articles_imported': report.articlesImported,
        'articles_failed': report.articlesFailed,
        'broken_drill_refs': report.brokenDrillRefs,
        'broken_knowledge_refs': report.brokenKnowledgeRefs,
        'is_clean': report.isClean,
        'warnings': report.warnings,
      };
}