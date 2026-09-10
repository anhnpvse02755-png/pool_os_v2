import 'package:flutter_test/flutter_test.dart';

import 'token_hygiene.dart';

void main() {
  expectTokenHygiene('lô 3d', const [
    'lib/presentation/screens/training/knowledge_screen.dart',
    'lib/presentation/screens/training/knowledge_detail_screen.dart',
    'lib/presentation/screens/training/certification_list_screen.dart',
    'lib/presentation/screens/training/certification_detail_screen.dart',
  ]);
}
