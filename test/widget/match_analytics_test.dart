// ============================================================================
// match_analytics_test.dart - Sprint-9C
// Widget tests for Match Analytics components
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/presentation/widgets/pocket_accuracy_widget.dart';
import 'package:pool_os_v2/data/models/match.dart';

void main() {
  group('PocketAccuracyWidget', () {
    testWidgets('shows empty state when no racks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PocketAccuracyWidget(racks: []),
            ),
          ),
        ),
      );

      expect(find.text('Chưa có dữ liệu'), findsOneWidget);
      expect(find.text('Cần ghi ít nhất 1 trận đấu để xem thống kê'), findsOneWidget);
    });

    testWidgets('shows empty state icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PocketAccuracyWidget(racks: []),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.gps_off), findsOneWidget);
    });

    testWidgets('shows summary header with stats when data available', (tester) async {
      // Create a rack with some shots
      final rack = Rack(
        id: 'rack1',
        rackNumber: 1,
        result: 'win',
        createdAt: DateTime.now(),
        totalBallsPotted: 5,
        easyMissCount: 1,
        hardMissCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PocketAccuracyWidget(racks: [rack]),
            ),
          ),
        ),
      );

      // Should show total balls stat
      expect(find.textContaining('Tổng bi'), findsOneWidget);
    });

    testWidgets('shows data note when data is estimated', (tester) async {
      final rack = Rack(
        id: 'rack1',
        rackNumber: 1,
        result: 'win',
        createdAt: DateTime.now(),
        totalBallsPotted: 3,
        easyMissCount: 1,
        hardMissCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PocketAccuracyWidget(racks: [rack]),
            ),
          ),
        ),
      );

      // Should show data note about estimation
      expect(find.textContaining('ước tính'), findsOneWidget);
    });

    testWidgets('shows 6 pocket cards in grid', (tester) async {
      final rack = Rack(
        id: 'rack1',
        rackNumber: 1,
        result: 'win',
        createdAt: DateTime.now(),
        totalBallsPotted: 6,
        easyMissCount: 2,
        hardMissCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PocketAccuracyWidget(racks: [rack]),
            ),
          ),
        ),
      );

      // Should show GPS fixed icons for pockets
      expect(find.byIcon(Icons.gps_fixed), findsWidgets);
    });

    testWidgets('pocket accuracy calculation works', (tester) async {
      final widget = PocketAccuracyWidget(racks: []);

      // Test with empty racks
      final accuracy = widget.calculateAccuracy();
      expect(accuracy, isEmpty);

      // Test with rack data
      final rack = Rack(
        id: 'rack1',
        rackNumber: 1,
        result: 'win',
        createdAt: DateTime.now(),
        totalBallsPotted: 8,
        easyMissCount: 2,
        hardMissCount: 0,
      );

      final widgetWithData = PocketAccuracyWidget(racks: [rack]);
      final accuracyWithData = widgetWithData.calculateAccuracy();

      // Should have 6 pockets
      expect(accuracyWithData.length, equals(6));

      // All pockets should have names
      expect(accuracyWithData.first.pocketName, isNotEmpty);
    });
  });

  group('PocketAccuracy data class', () {
    test('creates pocket accuracy with correct values', () {
      final accuracy = PocketAccuracy(
        pocketName: 'Corner 1',
        pocketPosition: 'Top-Left',
        attempts: 10,
        made: 8,
        accuracy: 80.0,
      );

      expect(accuracy.pocketName, equals('Corner 1'));
      expect(accuracy.pocketPosition, equals('Top-Left'));
      expect(accuracy.attempts, equals(10));
      expect(accuracy.made, equals(8));
      expect(accuracy.accuracy, equals(80.0));
    });
  });
}
