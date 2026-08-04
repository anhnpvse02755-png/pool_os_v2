// ============================================================================
// cli_options.dart — parsed CLI options for the migration tool
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

  static const String defaultInput =
      'C:/Users/anhnpv/OneDrive - Thanh Cong Group/Desktop/code/Pool OS/Knowledge';
  static const String defaultOutput = 'assets/knowledge/_staging';

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
          {
            final r = _readInlineOrNext(arg, argv, i, '--input');
            input = r.value;
            if (r.consumeNext) i++;
          }
          break;
        case '-o':
        case '--output':
          {
            final r = _readInlineOrNext(arg, argv, i, '--output');
            output = r.value;
            if (r.consumeNext) i++;
          }
          break;
        case '--domain':
          {
            final r = _readInlineOrNext(arg, argv, i, '--domain');
            domain = r.value;
            if (r.consumeNext) i++;
            if (domain.isEmpty) {
              throw const FormatException('--domain must be non-empty.');
            }
          }
          break;
        default:
          if (arg.startsWith('-')) {
            throw FormatException('Unknown flag: $arg');
          }
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

  static _ValueRead _readInlineOrNext(
      String arg, List<String> argv, int i, String flagName) {
    final eq = arg.indexOf('=');
    if (eq >= 0) {
      return _ValueRead(arg.substring(eq + 1), false);
    }
    if (i + 1 >= argv.length) {
      throw FormatException('$flagName requires a value.');
    }
    return _ValueRead(argv[i + 1], true);
  }

  static String usage() => '''
migrate_v1_to_v2 — V1 → V2 Knowledge migration tool (Sprint 1)

Usage:
  dart run tools/knowledge_migration/migrate_v1_to_v2.dart [options] [<domain>]

Options:
  -h, --help              Show this usage.
  -V, --version           Show version.
  --check                 Dry-run. Validate but do not write output.
  --promote               Promote staging to assets/knowledge/ (after clean report).
  -i, --input <dir>       V1 input directory (default: $defaultInput).
  -o, --output <dir>      Staging output directory (default: $defaultOutput).
  --domain <name>         V1 domain (bridge, pattern, safety, mental).
''';
}

class _ValueRead {
  _ValueRead(this.value, this.consumeNext);
  final String value;
  final bool consumeNext;
}