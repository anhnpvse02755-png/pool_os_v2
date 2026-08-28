// ============================================================================
// create_session_screen_test.dart
// ----------------------------------------------------------------------------
// Sprint 2E AC-2 widget smoke. Three assertions per Constitution Article 8:
//   (1) screen mounts without crash,
//   (2) the start session CTA renders with its label,
//   (3) tapping a session-type card does not throw.
//
// Widget under test is CreateSessionScreen
// (lib/presentation/screens/session/create_session_screen.dart).
//
// No service calls, no Riverpod injection, no GoRouter needed for this
// smoke. The screen is a plain StatefulWidget that holds session-type
// and readiness-slider state locally. Tapping the start CTA calls
// `context.go('/sessions')` (go_router) which would require a full
// router setup, so we tap the type card instead — it exercises the
// setState + animation path without leaving the screen.
//
// Implementation note: this test renders the screen and asserts visible
// widgets. Avoid pumpAndSettle — flutter_animate uses indefinite
// tweens. The drill_session_screen_test pattern from Sprint 2D uses
// the same approach: pump-and-assert, with optional tap.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/presentation/screens/session/create_session_screen.dart';

void main() {
  testWidgets(
      'CreateSessionScreen mounts, start CTA renders, type-card tap safe',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CreateSessionScreen(),
      ),
    );

    // Allow async flutter_animate tweens to settle. Avoid pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Assertion 1: screen is reachable.
    expect(find.byType(CreateSessionScreen), findsOneWidget);

    // Assertion 2: the start-session CTA renders with its label. This
    // proves the widget renders the call-to-action without any
    // state-driven error path.
    expect(find.text('Bắt đầu buổi chơi'),
        findsOneWidget,
        reason: 'start CTA should be visible on initial render');

    // Assertion 3: tapping a type card does not throw. Toggling
    // session-type triggers setState + animation, both of which are
    // safe paths (unlike the start button, which calls context.go).
    await tester.tap(find.text('Luyện tập'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull,
        reason: 'type-card tap should be a no-op for navigation');
  });
}