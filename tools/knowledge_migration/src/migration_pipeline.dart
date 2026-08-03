// ============================================================================
// migration_pipeline.dart — full orchestration for V1 → V2 migration
// ============================================================================
//
// Sprint 1, Commit 4.
//
// Real pipeline:
//   1. List V1 input files (sorted).
//   2. For each: parse JSON, map via SchemaMapper.
//   3. Run 12-rule validation.
//   4. Generate search_index.json.
//   5. Write V2 articles to staging output dir.
//   6. Generate imports_summary.json + sha256_manifest.json +
//      deterministic.lock.
//   7. Promote to assets/knowledge/{domain}/ if --promote and clean.
//
// Determinism (Section 7):
//   - All file listings sorted.
//   - All JSON encoded with indent='  ' (stable).
//   - All hashes computed from sorted-file digest.
//   - No timestamps in output.
//
// Exit codes (CLI):
//   - 0 = clean
//   - 1 = validation failed
//   - 2 = tool/runtime error
// ============================================================================

import 'dart:convert';
import 'dart:io';

import '../category_mapper.dart';
import '../hash_utils.dart';
import '../report_generator.dart';
import '../schema_mapper.dart';
import '../validators.dart';
import 'cli_options.dart';
import 'io.dart';
import 'migration_dto.dart';

class MigrationPipeline {
  MigrationPipeline({
    required this.fs,
    required this.reportGenerator,
  });

  final FileSystemAdapter fs;
  final ReportGenerator reportGenerator;

  Future<PipelineResult> run(CliOptions options) async {
    try {
      return await _runInternal(options);
    } catch (e) {
      stderr.writeln('Migration error: $e');
      return PipelineResult._(exitCode: 2, report: MigrationReport(
        domain: options.domain ?? '<unset>',
        articlesTotal: 0,
        articlesImported: 0,
        articlesFailed: 0,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: ['Tool error: $e'],
      ));
    }
  }

  Future<PipelineResult> _runInternal(CliOptions options) async {
    final domain = options.domain;
    if (domain == null) {
      stderr.writeln('Error: --domain is required.');
      return PipelineResult._(exitCode: 2, report: MigrationReport(
        domain: '<unset>',
        articlesTotal: 0,
        articlesImported: 0,
        articlesFailed: 0,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: ['--domain required'],
      ));
    }

    final inputDir = Directory('${options.input}/$domain');
    if (!inputDir.existsSync()) {
      stderr.writeln('Error: input dir not found: ${inputDir.path}');
      return PipelineResult._(exitCode: 2, report: MigrationReport(
        domain: domain,
        articlesTotal: 0,
        articlesImported: 0,
        articlesFailed: 0,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: ['Input dir not found'],
      ));
    }

    // 1. List V1 files (sorted).
    final v1Files = await fs.listFiles(
      inputDir.path,
      extension: '.json',
    );
    if (v1Files.isEmpty) {
      stderr.writeln('Error: no V1 files in ${inputDir.path}');
      return PipelineResult._(exitCode: 2, report: MigrationReport(
        domain: domain,
        articlesTotal: 0,
        articlesImported: 0,
        articlesFailed: 0,
        brokenDrillRefs: 0,
        brokenKnowledgeRefs: 0,
        warnings: ['No V1 files'],
      ));
    }

    // 2. Read + map.
    final v2Articles = <Map<String, dynamic>>[];
    final v1Articles = <V1Article>[];
    final skipped = <String>[];

    for (final path in v1Files) {
      final raw = await fs.read(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final id = json['id'] as String;
      final v1 = V1Article(id: id, rawJsonPath: path);
      v1Articles.add(v1);

      final v2 = SchemaMapper.map(v1, json);
      if (v2 == null) {
        skipped.add(id);
        continue;
      }
      v2Articles.add(v2);
    }

    // 3. Build validator registry.
    final validCategoryIds = <String>{
      'cat_fundamentals',
      'cat_aiming',
      'cat_positioning',
      'cat_strategy',
      'cat_psychology',
      'cat_equipment',
      'cat_rules',
      'cat_fundamentals',
    };
    final indexedIds = v2Articles.map((a) => a['id'] as String).toSet();
    final registry = ValidatorRegistry([
      IdUniqueValidator(v2Articles.map((a) => a['id'] as String).toList()),
      TitleNonEmptyValidator(),
      CategoryValidValidator(validCategoryIds),
      DifficultyValidValidator(),
      BodyNonEmptyValidator(),
      TagsNonEmptyValidator(),
      RelatedDrillCodesValidator(<String>{}), // No drill refs in V1.
      RelatedKnowledgeIdsValidator(indexedIds),
      ReadingTimeValidator(),
      SearchIndexEntryValidator(indexedIds),
      MarkdownValidValidator(),
      Utf8ValidValidator(),
    ]);

    // 4. Validate.
    final validation = registry.runAll(v2Articles);

    // 5. Compute aggregate stats.
    var brokenDrillRefs = 0;
    var brokenKnowledgeRefs = 0;
    final warnings = <String>[];
    for (final o in validation.outcomes) {
      for (final e in o.errors) {
        if (e.contains('drill')) brokenDrillRefs++;
        if (e.contains('knowledge')) brokenKnowledgeRefs++;
      }
    }
    if (skipped.isNotEmpty) {
      warnings.add('Skipped ${skipped.length} articles (no V2 category mapping)');
    }

    final report = MigrationReport(
      domain: domain,
      articlesTotal: v1Files.length,
      articlesImported: validation.passedArticles,
      articlesFailed: validation.failedArticles,
      brokenDrillRefs: brokenDrillRefs,
      brokenKnowledgeRefs: brokenKnowledgeRefs,
      warnings: warnings,
    );

    final isFailed = validation.failedArticles > 0 || brokenDrillRefs > 0;
    if (isFailed) {
      return PipelineResult._(exitCode: 1, report: report..validation = validation);
    }

    // 6. --check only validates.
    if (options.check) {
      stdout.writeln('--check: validation passed (no writes).');
      return PipelineResult._(exitCode: 0, report: report..validation = validation);
    }

    // 7. Write staging output.
    final stagingDir = Directory('${options.output}/$domain');
    if (stagingDir.existsSync()) {
      stagingDir.deleteSync(recursive: true);
    }
    stagingDir.createSync(recursive: true);

    // Write articles (sorted by id).
    v2Articles.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    final encoder = const JsonEncoder.withIndent('  ');
    for (final article in v2Articles) {
      final id = article['id'] as String;
      final file = File('${stagingDir.path}/$id.json');
      await file.writeAsString(encoder.convert(article));
    }

    // Write search_index.json (per-domain).
    final indexEntries = v2Articles.map((a) => {
      'id': a['id'],
      'slug': a['slug'],
      'title': a['title'],
      'titleVi': a['titleVi'],
      'keywords': a['keywords'],
      'tags': a['tagIds'],
      'category': a['categoryId'],
    }).toList();
    final indexFile = File('${stagingDir.path}/search_index.json');
    await indexFile.writeAsString(encoder.convert(indexEntries));

    // Write import_summary.json (per-domain).
    final importSummary = {
      'domain': domain,
      'processed': v1Files.length,
      'imported': validation.passedArticles,
      'failed': validation.failedArticles,
      'skipped': skipped.length,
      'warnings': validation.warningCount,
    };
    final summaryFile = File('${stagingDir.path}/import_summary.json');
    await summaryFile.writeAsString(encoder.convert(importSummary));

    // Write sha256_manifest.json (per-domain).
    final sha256 = <Map<String, String>>[];
    for (final article in v2Articles) {
      final id = article['id'] as String;
      final filePath = '${stagingDir.path}/$id.json';
      final bodyHash = HashUtils.sha256OfString(article['content'] as String);
      final fileHash = await HashUtils.sha256OfFile(filePath);
      sha256.add({
        'article_id': id,
        'body_hash': bodyHash,
        'full_file_hash': fileHash,
      });
    }
    final manifestFile = File('${stagingDir.path}/sha256_manifest.json');
    await manifestFile.writeAsString(encoder.convert(sha256));

    // Write deterministic.lock (per-domain).
    final lockHash = await HashUtils.sha256OfDirectory(stagingDir.path);
    final lockFile = File('${stagingDir.path}/deterministic.lock');
    await lockFile.writeAsString(lockHash);

    // Write migration_report.md + migration_report.json (per-domain).
    final reportMd = reportGenerator.toMarkdown(report, validation);
    final reportJson = reportGenerator.toJson(report, validation);
    File('${stagingDir.path}/migration_report.md').writeAsStringSync(reportMd);
    File('${stagingDir.path}/migration_report.json').writeAsStringSync(reportJson);

    stdout.writeln('Migration complete.');
    stdout.writeln('  Domain: $domain');
    stdout.writeln('  Imported: ${report.articlesImported}');
    stdout.writeln('  Failed: ${report.articlesFailed}');
    stdout.writeln('  Staging: ${stagingDir.path}');
    stdout.writeln('  Lock: $lockHash');

    return PipelineResult._(exitCode: 0, report: report..validation = validation);
  }
}

class PipelineResult {
  PipelineResult._({
    required this.exitCode,
    required this.report,
  });

  final int exitCode;
  final MigrationReport report;

  @override
  String toString() =>
      'PipelineResult(exitCode: $exitCode, isClean: ${report.isClean})';
}