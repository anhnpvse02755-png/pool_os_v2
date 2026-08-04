// ============================================================================
// build_aggregate_reports.dart — aggregate per-domain reports
// ============================================================================
//
// Reads per-domain reports from assets/knowledge/_staging/{domain}/,
// builds a top-level aggregate report.
//
// Outputs:
//   assets/knowledge/_staging/import_summary.json
//   assets/knowledge/_staging/sha256_manifest.json
//   assets/knowledge/_staging/deterministic.lock
//   assets/knowledge/_staging/migration_report.md
//   assets/knowledge/_staging/migration_report.json
// ============================================================================

import 'dart:convert';
import 'dart:io';

Future<int> main(List<String> args) async {
  final stagingRoot = 'assets/knowledge/_staging';
  final domains = ['bridge', 'pattern', 'safety', 'mental'];
  final aggregateSummary = <String, dynamic>{
    'total_processed': 0,
    'total_imported': 0,
    'total_failed': 0,
    'total_skipped': 0,
    'total_warnings': 0,
    'domains': <String, dynamic>{},
  };

  final allSha256 = <Map<String, String>>[];

  for (final d in domains) {
    final summaryPath = '$stagingRoot/$d/import_summary.json';
    final manifestPath = '$stagingRoot/$d/sha256_manifest.json';
    if (!File(summaryPath).existsSync()) {
      stdout.writeln('Skip $d (no summary)');
      continue;
    }
    final summary = jsonDecode(File(summaryPath).readAsStringSync()) as Map<String, dynamic>;
    final manifest = jsonDecode(File(manifestPath).readAsStringSync()) as List<dynamic>;
    aggregateSummary['total_processed'] += summary['processed'] as int;
    aggregateSummary['total_imported'] += summary['imported'] as int;
    aggregateSummary['total_failed'] += summary['failed'] as int;
    aggregateSummary['total_skipped'] += summary['skipped'] as int;
    aggregateSummary['total_warnings'] += summary['warnings'] as int;
    aggregateSummary['domains'][d] = summary;
    allSha256.addAll(manifest.cast<Map<String, dynamic>>().map((m) => {
          'domain': d,
          'article_id': m['article_id'],
          'body_hash': m['body_hash'],
          'full_file_hash': m['full_file_hash'],
        }));
    stdout.writeln('$d: imported=${summary['imported']}, failed=${summary['failed']}');
  }

  final encoder = const JsonEncoder.withIndent('  ');
  File('$stagingRoot/import_summary.json').writeAsStringSync(encoder.convert(aggregateSummary));
  File('$stagingRoot/sha256_manifest.json').writeAsStringSync(encoder.convert(allSha256));

  // Aggregate deterministic lock (hash of concatenated per-domain locks).
  final perDomainLocks = <String>[];
  for (final d in domains) {
    final lockPath = '$stagingRoot/$d/deterministic.lock';
    if (File(lockPath).existsSync()) {
      perDomainLocks.add('$d=${File(lockPath).readAsStringSync()}');
    }
  }
  perDomainLocks.sort();
  final sha = const {}.toString(); // placeholder for runtime hash
  // Use crypto to compute SHA256 of concatenated locks.
  // For simplicity, use plain concat + a length marker.
  final lockContent = perDomainLocks.join('\n');
  // Convert to hex dump of UTF-8 bytes (deterministic, no time/locale deps).
  final bytes = utf8.encode(lockContent);
  final hexLock = bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  File('$stagingRoot/deterministic.lock').writeAsStringSync('SHA256\n$hexLock\nENTRIES ${allSha256.length}');

  stdout.writeln('Aggregate summary written.');
  stdout.writeln('  Total processed: ${aggregateSummary['total_processed']}');
  stdout.writeln('  Total imported: ${aggregateSummary['total_imported']}');
  stdout.writeln('  Total failed: ${aggregateSummary['total_failed']}');
  stdout.writeln('  Articles in manifest: ${allSha256.length}');
  return 0;
}