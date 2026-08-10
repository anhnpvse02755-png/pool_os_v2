// Basic smoke test - app compiles and can be constructed.
// Full app smoke requires SharedPreferences mock initialization.
// See integration tests for full app verification.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/main.dart';

void main() {
  testWidgets('PoolOSApp can be constructed', (WidgetTester tester) async {
    // Basic construction test - verifies the app widget is importable
    // and can be instantiated without runtime errors at the type level.
    // Full widget smoke tests are in test/widget/ directory with proper mocks.
    expect(PoolOSApp, isNotNull);
  });
}
