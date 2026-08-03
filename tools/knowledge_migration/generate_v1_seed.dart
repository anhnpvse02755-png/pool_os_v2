// ============================================================================
// generate_v1_seed.dart — generates V1 seed article data from V1 validation
// ============================================================================
//
// Sprint 1, Commit 4 — DEV tool only.
//
// Reads V1 *_domain_validation.md files + example schema, generates
// V1 article JSON files in assets/knowledge/_v1_input/{domain}/.
//
// Body content is NOT in V1 source. The seed generates a structured
// placeholder template (Title, Purpose, Setup, Execution, Sources)
// that V1 schema mapper can consume. Real body content will be
// expanded in Sprint 2 (Phase 2).
//
// This tool is INTERNAL to Commit 4. It is removed at end of Sprint 1.
// ============================================================================

import 'dart:convert';
import 'dart:io';

import 'v1_seed_data.dart';

Future<int> main(List<String> args) async {
  final outDir = 'assets/knowledge/_v1_input';
  var total = 0;

  for (final entry in v1Domains.entries) {
    final domain = entry.key;
    final articles = entry.value;
    final dir = Directory('$outDir/$domain');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    for (final article in articles) {
      final file = File('${dir.path}/${article['id']}.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(article),
      );
      total++;
    }
    stdout.writeln('Wrote ${articles.length} articles to $domain/');
  }
  stdout.writeln('Total: $total V1 article seed files.');
  return 0;
}