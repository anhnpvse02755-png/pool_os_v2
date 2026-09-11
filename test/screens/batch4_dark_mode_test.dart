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
}
