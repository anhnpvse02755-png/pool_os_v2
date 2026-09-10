import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3b', const [
    'lib/presentation/screens/training/drill_recording_preparation_screen.dart',
    'lib/presentation/screens/training/drill_result_screen.dart',
    'lib/presentation/screens/training/drill_completion_screen.dart',
    'lib/presentation/screens/training/session_detail_screen.dart',
  ]);
}
