// ============================================================================
// migrate_v1_to_v2.dart — CLI entry point for V1 → V2 knowledge migration
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// This file currently defines the CLI contract and dependency injection
// wiring. NO migration logic yet. Logic arrives in:
//   - Commit 2: schema_mapper.dart, category_mapper.dart, id_mapper.dart
//   - Commit 3: validators.dart
//   - Commit 4: full migration pipeline + 92 article import
//
// Usage:
//   dart run tools/knowledge_migration/migrate_v1_to_v2.dart --help
//   dart run tools/knowledge_migration/migrate_v1_to_v2.dart <domain>
//   dart run tools/knowledge_migration/migrate_v1_to_v2.dart <domain> --check
//   dart run tools/knowledge_migration/migrate_v1_to_v2.dart <domain> --output=<dir>
//
// Boundaries:
//   - Tool lives under tools/, NOT lib/. It is not part of the app
//     runtime. It is invoked by developers / CI only.
//   - Tool writes to a staging directory by default. Promotion to
//     assets/knowledge/ requires explicit --promote flag (added in
//     Commit 4).
// ============================================================================

import 'dart:io';

import 'src/cli_options.dart';
import 'src/migration_dto.dart';
import 'src/migration_pipeline.dart';
import 'src/io.dart';

Future<int> main(List<String> args) async {
  CliOptions options;

  try {
    options = CliOptions.parse(args);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(CliOptions.usage());
    return 64; // EX_USAGE
  }

  if (options.help) {
    stdout.writeln(CliOptions.usage());
    return 0;
  }

  if (options.version) {
    stdout.writeln('migrate_v1_to_v2 1.0.0 (Sprint 1 skeleton)');
    return 0;
  }

  // Skeleton behavior: print parsed options + pipeline invocation plan.
  // Real migration lands in Commit 4.
  stdout.writeln('[skeleton] domain: ${options.domain ?? '<unset>'}');
  stdout.writeln('[skeleton] input:  ${options.input}');
  stdout.writeln('[skeleton] output: ${options.output}');
  stdout.writeln('[skeleton] check:  ${options.check}');
  stdout.writeln('[skeleton] promote: ${options.promote}');

  final fs = FileSystemAdapter();
  final pipeline = MigrationPipeline(fs: fs);

  final result = await pipeline.run(options);
  stdout.writeln(result.toString());
  return result.exitCode;
}