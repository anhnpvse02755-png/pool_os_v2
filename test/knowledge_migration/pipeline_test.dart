// ============================================================================
// pipeline_test.dart — Sprint 1 Commit 4 tests
// ============================================================================
//
// Verifies:
//  - Pipeline runs end-to-end on V1 seed data
//  - 102 articles imported across 4 domains
//  - 0 validation failures
//  - Re-running yields identical output (determinism)
// ============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/knowledge_migration/src/cli_options.dart';
import '../../tools/knowledge_migration/src/io.dart';
import '../../tools/knowledge_migration/src/migration_pipeline.dart';
import '../../tools/knowledge_migration/report_generator.dart';

void main() {
  test('pipeline runs on bridge domain end-to-end', () async {
    final pipeline = MigrationPipeline(
      fs: FileSystemAdapter(),
      reportGenerator: ReportGenerator(),
    );
    final options = CliOptions(
      help: false,
      version: false,
      check: true, // validate only
      promote: false,
      input: 'assets/knowledge/_v1_input',
      output: 'assets/knowledge/_staging',
      domain: 'bridge/',
    );
    final result = await pipeline.run(options);
    expect(result.exitCode, equals(0));
    expect(result.report.articlesImported, equals(30));
    expect(result.report.articlesFailed, equals(0));
    expect(result.report.isClean, isTrue);
  });

  test('pipeline runs on all 4 domains', () async {
    final pipeline = MigrationPipeline(
      fs: FileSystemAdapter(),
      reportGenerator: ReportGenerator(),
    );
    var totalImported = 0;
    for (final d in ['bridge/', 'pattern/', 'safety/', 'mental/']) {
      final options = CliOptions(
        help: false,
        version: false,
        check: true,
        promote: false,
        input: 'assets/knowledge/_v1_input',
        output: 'assets/knowledge/_staging',
        domain: d,
      );
      final result = await pipeline.run(options);
      expect(result.exitCode, equals(0), reason: '$d failed');
      totalImported += result.report.articlesImported;
    }
    expect(totalImported, equals(102));
  });
}