import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3e', const [
    'lib/presentation/screens/training/progress_screen.dart',
    'lib/presentation/screens/training/training_history_screen.dart',
    'lib/presentation/screens/training/trend_dashboard_screen.dart',
    'lib/presentation/screens/training/unified_timeline_screen.dart',
  ]);
}
