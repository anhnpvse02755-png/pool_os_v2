// ============================================================================
// cli_options.dart — parsed CLI options for the migration tool
// ============================================================================
//
// Sprint 1, Commit 1 — SKELETON ONLY.
//
// Hand-rolled parser (no `args` package) — flags are simple enough.
// ============================================================================

class CliOptions {
  CliOptions({
    required this.help,
    required this.version,
    required this.check,
    required this.promote,
    required this.input,
    required this.output,
    required this.domain,
  });

  final bool help;
  final bool version;
  final bool check;
  final bool promote;
  final String input;
  final String output;
  final String? domain;

  static CliOptions parse(List<String> argv) {
    var help = false;
    var version = false;
    var check = false;
    var promote = false;
    var input = defaultInput;
    var output = defaultOutput;
    String? domain;

    for (var i = 0; i < argv.length; i++) {
      final arg = argv[i];
      switch (arg) {
        case '-h':
        case '--help':
          help = true;
          break;
        case '-V':
        case '--version':
          version = true;
          break;
        case '--check':
          check = true;
          break;
        case '--promote':
          promote = true;
          break;
        case '-i':
        case '--input':
          if (i + 1 >= argv.length) {
            throw const FormatException('--input requires a value.');
          }
          input = argv[++i];
          break;
        case '-o':
        case '--output':
          if (i + 1 >= argv.length) {
            throw const FormatException('--output requires a value.');
          }
          output = argv[++i];
          break;
        case '--domain':
          if (i + 1 >= argv.length) {
            throw const FormatException('--domain requires a value.');
          }
          domain = argv[++i];
          if (domain.isEmpty) {
            throw const FormatException('--domain must be non-empty.');
          }
          break;
        default:
          if (arg.startsWith('-')) {
            throw FormatException('Unknown flag: $arg');
          }
          // Positional argument → domain.
          if (domain == null) {
            domain = arg;
          } else {
            throw FormatException('Multiple positional args: $arg');
          }
      }
    }

    return CliOptions(
      help: help,
      version: version,
      check: check,
      promote: promote,
      input: input,
      output: output,
      domain: domain,
    );
  }

  static const String defaultInput =
      'C:/Users/anhnpv/OneDrive - Thanh Cong Group/Desktop/code/Pool OS/Knowledge';
  static const String defaultOutput = 'assets/knowledge/_staging';

  static String usage() => '''
migrate_v1_to_v2 — V1 → V2 Knowledge migration tool (Sprint 1 skeleton)

Usage:
  dart run tools/knowledge_migration/migrate_v1_to_v2.dart [options] [<domain>]

Options:
  -h, --help              Show this usage.
  -V, --version           Show version.
  --check                 Dry-run. Validate but do not write output.
  --promote               Promote staging to assets/knowledge/ (after clean report).
  -i, --input <dir>       V1 input directory (default: ${defaultInput}).
  -o, --output <dir>      Staging output directory (default: ${defaultOutput}).
  --domain <name>         V1 domain (bridge/, pattern/, safety/, mental/).
''';
}