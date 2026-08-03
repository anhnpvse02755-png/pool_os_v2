// ============================================================================
// migration_pipeline.dart — orchestrates the migration stages
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// The pipeline composes:
//   - reader     (V1)        — Commit 4
//   - mapper     (V1 → V2)   — Commit 2
//   - validators (12 rules)  — Commit 3
//   - writer     (V2)        — Commit 4
//   - reporter               — Commit 3
//
// Today: scaffolding + DI hooks. Real work in later commits.
// ============================================================================

import 'cli_options.dart';
import 'migration_dto.dart';
import 'io.dart';

class MigrationPipeline {
  MigrationPipeline({
    required this.fs,
  });

  final FileSystemAdapter fs;

  Future<PipelineResult> run(CliOptions options) async {
    // Skeleton: do nothing, return empty success.
    // Commits 2-4 will plug real logic here.
    final report = MigrationReport(
      domain: options.domain ?? '<unset>',
      articlesTotal: 0,
      articlesImported: 0,
      articlesFailed: 0,
      brokenDrillRefs: 0,
      brokenKnowledgeRefs: 0,
      warnings: const ['Skeleton run — no migration performed.'],
    );

    return PipelineResult.success(report: report);
  }
}

class PipelineResult {
  PipelineResult._({required this.exitCode, required this.report});

  factory PipelineResult.success({required MigrationReport report}) =>
      PipelineResult._(exitCode: 0, report: report);

  factory PipelineResult.failure({required MigrationReport report}) =>
      PipelineResult._(exitCode: 1, report: report);

  final int exitCode;
  final MigrationReport report;

  @override
  String toString() =>
      'PipelineResult(exitCode: $exitCode, isClean: ${report.isClean})';
}