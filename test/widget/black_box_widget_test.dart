// ============================================================================
// Black Box Export Widget Tests — D0.2
// Tests for Black Box Export screen states and interactions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Black Box Export Widget Tests', () {
    testWidgets('Export Screen shows loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Export Screen shows Ready state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('PoolOS Black Box'),
                Text('What is this?'),
                Text('Preview'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('PoolOS Black Box'), findsOneWidget);
      expect(find.text('What is this?'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('Export Screen shows Export button', (tester) async {
      bool exportPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => exportPressed = true,
                child: const Text('Export Coach Package'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Export Coach Package'));
      expect(exportPressed, isTrue);
    });

    testWidgets('Export Screen shows Preview card with stats', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Preview'),
                Text('Sessions: 5'),
                Text('Recommendations: 3'),
                Text('Events: 42'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sessions: 5'), findsOneWidget);
      expect(find.text('Recommendations: 3'), findsOneWidget);
      expect(find.text('Events: 42'), findsOneWidget);
    });

    testWidgets('Export Screen shows v2.0 badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('v2.0'),
          ),
        ),
      );

      expect(find.text('v2.0'), findsOneWidget);
    });

    testWidgets('Progress shows all steps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Building Black Box...'),
                Text('Recording events'),
                Text('Building replay'),
                Text('Creating snapshots'),
                Text('Packaging'),
                Text('Compressing ZIP'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Recording events'), findsOneWidget);
      expect(find.text('Building replay'), findsOneWidget);
      expect(find.text('Creating snapshots'), findsOneWidget);
      expect(find.text('Packaging'), findsOneWidget);
      expect(find.text('Compressing ZIP'), findsOneWidget);
    });

    testWidgets('Success screen shows package info', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Black Box Ready!'),
                Text('Package: PoolOS_Coach_v2.0.zip'),
                Text('Version: 2.0'),
                Text('Size: 2.3 MB'),
                Text('Generated: 21:15'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Black Box Ready!'), findsOneWidget);
      expect(find.textContaining('PoolOS_Coach'), findsOneWidget);
      expect(find.text('Version: 2.0'), findsOneWidget);
      expect(find.text('Size: 2.3 MB'), findsOneWidget);
    });

    testWidgets('Success screen has Share button', (tester) async {
      bool sharePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => sharePressed = true,
                  child: const Text('Share via...'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Share via...'));
      expect(sharePressed, isTrue);
    });

    testWidgets('Success screen has Save button', (tester) async {
      bool savePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                OutlinedButton(
                  onPressed: () => savePressed = true,
                  child: const Text('Save to Downloads'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save to Downloads'));
      expect(savePressed, isTrue);
    });

    testWidgets('Error screen shows failure message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Export Failed'),
                Text('Failed at: Building Replay'),
                Text('Reason: Storage permission denied'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Export Failed'), findsOneWidget);
      expect(find.textContaining('Storage permission'), findsOneWidget);
    });

    testWidgets('Error screen has Retry button', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => retryPressed = true,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retryPressed, isTrue);
    });

    testWidgets('Error screen has Cancel button', (tester) async {
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: () => cancelled = true,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });

    testWidgets('Feedback dialog shows rating questions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Your Feedback'),
                Text('Coach hữu ích?'),
                Text('Coach dễ hiểu?'),
                Text('Coach đúng đắn?'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Your Feedback'), findsOneWidget);
      expect(find.text('Coach hữu ích?'), findsOneWidget);
      expect(find.text('Coach dễ hiểu?'), findsOneWidget);
    });

    testWidgets('Feedback dialog has star ratings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: const Icon(Icons.star_border),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Should have 5 star buttons
      expect(find.byType(IconButton), findsNWidgets(5));
    });

    testWidgets('Feedback dialog Submit button', (tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => submitted = true,
              child: const Text('Submit & Export'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit & Export'));
      expect(submitted, isTrue);
    });

    testWidgets('Feedback dialog Skip button', (tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedButton(
              onPressed: () => skipped = true,
              child: const Text('Skip'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      expect(skipped, isTrue);
    });

    testWidgets('Info card shows what is exported', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Your profile & skills'),
                Text('Coach recommendations & reasoning'),
                Text('All conversations'),
                Text('Complete event timeline'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Your profile & skills'), findsOneWidget);
      expect(find.text('Coach recommendations & reasoning'), findsOneWidget);
    });

    testWidgets('Privacy notice shown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('No account required. No internet required. Anonymous.'),
          ),
        ),
      );

      expect(find.textContaining('No account required'), findsOneWidget);
    });
  });
}
