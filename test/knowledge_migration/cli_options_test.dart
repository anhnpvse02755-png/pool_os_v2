// ============================================================================
// cli_options_test.dart — Sprint 1 Commit 1 skeleton tests
// ============================================================================
//
// Verifies:
//  - CLI parses --help / --version / --check / --promote.
//  - CLI parses --domain.
//  - CLI rejects empty --domain.
//  - CLI rejects unknown flags.
//  - MigrationPipeline runs (skeleton returns success).
//  - MigrationReport is well-formed.
//
// Tests import tool files via relative paths (tools/ lives outside
// lib/ so the package: import alias is not available).
// ============================================================================

import 'package:flutter_test/flutter_test.dart';

import '../../tools/knowledge_migration/src/cli_options.dart';
import '../../tools/knowledge_migration/src/migration_dto.dart';
import '../../tools/knowledge_migration/src/migration_pipeline.dart';
import '../../tools/knowledge_migration/src/io.dart';

void main() {
  group('CliOptions', () {
    test('parses --help', () {
      final opts = CliOptions.parse(['--help']);
      expect(opts.help, isTrue);
    });

    test('parses --domain', () {
      final opts = CliOptions.parse(['--domain', 'bridge/']);
      expect(opts.domain, equals('bridge/'));
    });

    test('parses positional domain', () {
      final opts = CliOptions.parse(['bridge/']);
      expect(opts.domain, equals('bridge/'));
    });

    test('rejects empty --domain', () {
      expect(
        () => CliOptions.parse(['--domain', '']),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unknown flag', () {
      expect(
        () => CliOptions.parse(['--bogus']),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses --check + --promote', () {
      final opts = CliOptions.parse(['--check', '--promote', 'pattern/']);
      expect(opts.check, isTrue);
      expect(opts.promote, isTrue);
      expect(opts.domain, equals('pattern/'));
    });

    test('uses default input/output when not specified', () {
      final opts = CliOptions.parse([]);
      expect(opts.input, isNotEmpty);
      expect(opts.output, equals('assets/knowledge/_staging'));
    });
  });

  group('MigrationReport', () {
    test('clean when no failures', () {
      final report = MigrationReport(
        domain: 'bridge/',
        articlesTotal: 30,
        articlesImported: 30,
        articlesFailed: 0,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: const [],
      );
      expect(report.isClean, isTrue);
    });

    test('dirty when broken drill refs > 0', () {
      final report = MigrationReport(
        domain: 'bridge/',
        articlesTotal: 30,
        articlesImported: 30,
        articlesFailed: 0,
        brokenDrillRefs: 1,
        brokenKnowledgeRefs: 0,
        warnings: const [],
      );
      expect(report.isClean, isFalse);
    });
  });

  group('MigrationPipeline (skeleton)', () {
    test('returns success with skeleton warning', () async {
      final pipeline = MigrationPipeline(fs: FileSystemAdapter());
      final options = CliOptions(
        help: false,
        version: false,
        check: true,
        promote: false,
        input: '/tmp/v1',
        output: '/tmp/staging',
        domain: 'bridge/',
      );
      final result = await pipeline.run(options);
      expect(result.exitCode, equals(0));
      expect(result.report.warnings, isNotEmpty);
      expect(
        result.report.warnings.any((w) => w.contains('Skeleton run')),
        isTrue,
      );
    });
  });
}