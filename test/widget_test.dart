import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_os_v2/main.dart';

void main() {
  testWidgets('PoolOS app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PoolOSApp()));
    await tester.pumpAndSettle();

    // Verify that the app loads
    expect(find.text('PoolOS'), findsAny);
  });
}
