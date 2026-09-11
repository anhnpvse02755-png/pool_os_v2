import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 4 — community', const [
    'lib/presentation/screens/community/community_screen.dart',
  ]);
}
