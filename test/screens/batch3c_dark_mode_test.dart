import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3c', const [
    'lib/presentation/screens/training/training_center_screen.dart',
    'lib/presentation/screens/training/learning_path_screen.dart',
    'lib/presentation/screens/training/recommended_screen.dart',
    'lib/presentation/screens/training/assessment_screen.dart',
  ]);
}
