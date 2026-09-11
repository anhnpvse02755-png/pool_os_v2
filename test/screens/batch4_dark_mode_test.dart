import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 4 — community', const [
    'lib/presentation/screens/community/community_screen.dart',
  ]);

  expectTokenHygiene('lô 4 — session', const [
    'lib/presentation/screens/session/create_session_screen.dart',
    'lib/presentation/screens/session/session_list_screen.dart',
  ]);

  expectTokenHygiene('lô 4 — reports', const [
    'lib/presentation/screens/reports/weekly_report_screen.dart',
    'lib/presentation/screens/reports/monthly_report_screen.dart',
  ]);

  expectTokenHygiene('lô 4 — match', const [
    'lib/presentation/screens/match/match_analytics_screen.dart',
    'lib/presentation/screens/match/match_replay_screen.dart',
  ]);

  expectTokenHygiene('lô 4 — knowledge', const [
    'lib/presentation/screens/knowledge/ai_explain_screen.dart',
    'lib/presentation/screens/knowledge/flashcard_screen.dart',
    'lib/presentation/screens/knowledge/knowledge_graph_screen.dart',
    'lib/presentation/screens/knowledge/quiz_screen.dart',
  ]);
}
