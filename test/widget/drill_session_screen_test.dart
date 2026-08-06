// ============================================================================
// drill_session_screen_test.dart
// ----------------------------------------------------------------------------
// Sprint 2D AC-2 widget smoke. Three assertions per Constitution Article 8:
//   (1) screen mounts without crash,
//   (2) instructions view renders the drill header,
//   (3) start FAB is present, signaling the pre-active state machine.
//
// Widget under test is DrillSessionScreen
// (lib/presentation/screens/training/drill_session_screen.dart).
//
// No score assertions, no timer simulation, no manual tap-through.
// Manual QA on a real device covers the rest.
//
// DrillSessionScreen is a plain StatefulWidget — no Riverpod injection
// needed. State (currentRep / successCount / isSessionActive) is local
// to the screen; no fake repositories required for this smoke.
//
// Implementation note: this test renders the screen in its initial
// (pre-active) state and asserts visible widgets only. Driving the
// start/stop transitions would require `tester.tap(...)` on widgets
// that drive flutter_animate tweens, which leave pending Timer
// instances that fail the binding's post-test invariant check
// (`!timersPending`). The match_summary_flow_test pattern from
// Sprint 2B uses the same approach: pump-and-assert, no tap.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/presentation/screens/training/drill_session_screen.dart';

void main() {
  testWidgets('Drill session screen mounts and shows instructions view',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DrillSessionScreen(drillCode: 'STRAIGHT_POT'),
      ),
    );

    // Allow async flutter_animate tweens to settle. Avoid pumpAndSettle
    // (flutter_animate has indefinite animations).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Assertion 1: screen is reachable.
    expect(find.byType(DrillSessionScreen), findsOneWidget);

    // Assertion 2: instructions view shows the drill header.
    // Note: the same drill name appears in AppBar title AND in the
    // header card, so we expect at least one match.
    expect(find.text('Đánh thẳng'), findsAtLeastNWidgets(1),
        reason: 'drill header should be visible from instructions view');

    // Assertion 3: start FAB is present, signaling the pre-active state
    // machine. This proves the widget renders the call-to-action without
    // any state-driven error path.
    expect(find.widgetWithText(FloatingActionButton, 'Bắt đầu'),
        findsOneWidget,
        reason: 'start FAB should be visible before session starts');
  });
}