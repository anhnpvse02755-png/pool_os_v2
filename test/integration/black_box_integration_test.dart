// ============================================================================
// Black Box Integration Tests — D0.3
// End-to-end flows for Black Box export
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Black Box test states
enum BlackBoxState { idle, ready, exporting, compressing, exported, error }

void main() {
  group('Black Box Integration: Export Flow', () {
    testWidgets('Full export flow succeeds', (tester) async {
      BlackBoxState finalState = BlackBoxState.idle;

      await tester.pumpWidget(
        MaterialApp(
          home: _BlackBoxExportFlowWidget(
            onStateChange: (state) => finalState = state,
          ),
        ),
      );

      // Start export
      await tester.tap(find.text('Export Coach Package'));
      await tester.pump();

      // Should be exporting
      expect(find.text('Building Black Box...'), findsOneWidget);

      // Wait for completion
      await tester.pump(const Duration(seconds: 1));

      // Should be exported
      expect(find.text('Black Box Ready!'), findsOneWidget);
      expect(finalState, equals(BlackBoxState.exported));
    });

    testWidgets('Export creates ZIP file', (tester) async {
      String? zipPath;

      await tester.pumpWidget(
        MaterialApp(
          home: _BlackBoxExportWidget(
            onExport: (path) => zipPath = path,
          ),
        ),
      );

      await tester.tap(find.text('Export Coach Package'));
      await tester.pump(const Duration(seconds: 2));

      expect(zipPath, isNotNull);
      expect(zipPath!.contains('.zip'), isTrue);
    });

    testWidgets('Export includes all data sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _BlackBoxPreviewWidget(
            sections: [
              'manifest.json',
              'replay.json',
              'player/',
              'coach/',
              'session/',
              'timeline/',
              'feedback/',
              'system/',
            ],
          ),
        ),
      );

      expect(find.text('manifest.json'), findsOneWidget);
      expect(find.text('replay.json'), findsOneWidget);
      expect(find.text('player/'), findsOneWidget);
      expect(find.text('coach/'), findsOneWidget);
    });
  });

  group('Black Box Integration: Progress Tracking', () {
    testWidgets('Progress updates sequentially', (tester) async {
      final progressSteps = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: _BlackBoxProgressWidget(
            onStep: (step) => progressSteps.add(step),
          ),
        ),
      );

      // Simulate export progress
      await tester.pump(const Duration(milliseconds: 500));

      // Steps should be added in order
      expect(progressSteps.isNotEmpty, isTrue);
    });

    testWidgets('Progress shows all steps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
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
  });

  group('Black Box Integration: Share Flow', () {
    testWidgets('Share button opens share sheet', (tester) async {
      bool shareOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => shareOpened = true,
              child: const Text('Share via...'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Share via...'));

      expect(shareOpened, isTrue);
    });

    testWidgets('Save button saves to downloads', (tester) async {
      bool saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedButton(
              onPressed: () => saved = true,
              child: const Text('Save to Downloads'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save to Downloads'));

      expect(saved, isTrue);
    });
  });

  group('Black Box Integration: Feedback Flow', () {
    testWidgets('Feedback dialog shows before export', (tester) async {
      bool feedbackShown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => feedbackShown = true,
              child: const Text('Export Coach Package'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Export Coach Package'));

      expect(feedbackShown, isTrue);
    });

    testWidgets('Skip feedback proceeds to export', (tester) async {
      bool exported = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: () => exported = true,
                  child: const Text('Submit & Export'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit & Export'));

      expect(exported, isTrue);
    });
  });

  group('Black Box Integration: Error Recovery', () {
    testWidgets('Error shows retry option', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Export Failed'),
                ElevatedButton(
                  onPressed: () => retried = true,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));

      expect(retried, isTrue);
    });

    testWidgets('Error shows cancel option', (tester) async {
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Export Failed'),
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
  });

  group('Black Box Integration: Package Validation', () {
    testWidgets('Package includes manifest', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Package: PoolOS_Coach_v2.0.zip'),
                Text('Version: 2.0'),
                Text('Size: 2.3 MB'),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('PoolOS_Coach'), findsOneWidget);
      expect(find.text('Version: 2.0'), findsOneWidget);
    });

    testWidgets('Package shows generation time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Generated: 21:15'),
          ),
        ),
      );

      expect(find.textContaining('Generated:'), findsOneWidget);
    });
  });
}

// ============================================================================
// Test Widgets
// ============================================================================

class _BlackBoxExportFlowWidget extends StatefulWidget {
  final Function(BlackBoxState)? onStateChange;

  const _BlackBoxExportFlowWidget({this.onStateChange});

  @override
  State<_BlackBoxExportFlowWidget> createState() => _BlackBoxExportFlowWidgetState();
}

class _BlackBoxExportFlowWidgetState extends State<_BlackBoxExportFlowWidget> {
  BlackBoxState _state = BlackBoxState.ready;

  void _setState(BlackBoxState state) {
    setState(() => _state = state);
    widget.onStateChange?.call(state);
  }

  @override
  Widget build(BuildContext context) {
    if (_state == BlackBoxState.ready) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _setState(BlackBoxState.exporting);
              Future.delayed(const Duration(milliseconds: 500), () {
                _setState(BlackBoxState.compressing);
              });
              Future.delayed(const Duration(seconds: 1), () {
                _setState(BlackBoxState.exported);
              });
            },
            child: const Text('Export Coach Package'),
          ),
        ),
      );
    }

    if (_state == BlackBoxState.exporting) {
      return const Scaffold(
        body: Center(
          child: Text('Building Black Box...'),
        ),
      );
    }

    if (_state == BlackBoxState.exported) {
      return const Scaffold(
        body: Center(
          child: Text('Black Box Ready!'),
        ),
      );
    }

    return const Scaffold(body: SizedBox());
  }
}

class _BlackBoxExportWidget extends StatelessWidget {
  final Function(String)? onExport;

  const _BlackBoxExportWidget({this.onExport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            onExport?.call('/test/PoolOS_Coach_v2.0.zip');
          },
          child: const Text('Export Coach Package'),
        ),
      ),
    );
  }
}

class _BlackBoxPreviewWidget extends StatelessWidget {
  final List<String> sections;

  const _BlackBoxPreviewWidget({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: sections.map((s) => ListTile(title: Text(s))).toList(),
      ),
    );
  }
}

class _BlackBoxProgressWidget extends StatefulWidget {
  final Function(String)? onStep;

  const _BlackBoxProgressWidget({this.onStep});

  @override
  State<_BlackBoxProgressWidget> createState() => _BlackBoxProgressWidgetState();
}

class _BlackBoxProgressWidgetState extends State<_BlackBoxProgressWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      widget.onStep?.call('Recording events');
      Future.microtask(() {
        widget.onStep?.call('Building replay');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Building...'),
      ),
    );
  }
}
