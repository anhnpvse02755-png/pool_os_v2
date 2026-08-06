// ============================================================================
// drill_attempt_repository_test.dart
// ----------------------------------------------------------------------------
// Sprint 2D AC-1 — DrillAttempt critical-suite coverage (Tier 1).
//
// Per docs/SPRINT_2D_KICKOFF.md AC-1, 6 cases locked:
//   1. CRUD round-trip
//   2. Multi-attempt ordering + monotonic attemptNumber
//   3. Session isolation
//   4. Empty-session case
//   5. JSON round-trip
//   6. Counter monotonic + duplicate-id behavior
//
// Uses test/helpers/fake_drill_session_repository.dart (in-memory
// IDrillSessionRepository) to keep tests deterministic. The Local
// SharedPreferences implementation is exercised by
// drill_session_recovery_test.dart (Sprint 1 baseline).
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os_v2/data/models/drill_attempt.dart';

import 'helpers/fake_drill_session_repository.dart';

DrillAttempt _attempt({
  required String id,
  required String sessionId,
  required int attemptNumber,
  bool made = true,
  int? timeMs,
  String? notes,
  String drillCode = 'drill-A',
  DateTime? createdAt,
}) =>
    DrillAttempt(
      id: id,
      sessionId: sessionId,
      drillCode: drillCode,
      attemptNumber: attemptNumber,
      made: made,
      timeMs: timeMs,
      notes: notes,
      createdAt: createdAt ?? DateTime(2026, 8, 6, 10, attemptNumber),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -----------------------------------------------------------------
  // Case 1 — CRUD round-trip
  //
  // addAttempt writes a DrillAttempt; the fake's attemptsFor() returns
  // the same value with all fields intact.
  // -----------------------------------------------------------------
  test('case 1: CRUD round-trip preserves all fields', () async {
    final repo = FakeDrillSessionRepository();
    final a = _attempt(
      id: 'a1',
      sessionId: 's1',
      attemptNumber: 1,
      made: true,
      timeMs: 2500,
      notes: 'clean cut',
    );

    await repo.addAttempt(a);
    final list = repo.attemptsFor('s1');

    expect(list.length, 1);
    final r = list.single;
    expect(r.id, 'a1');
    expect(r.sessionId, 's1');
    expect(r.drillCode, 'drill-A');
    expect(r.attemptNumber, 1);
    expect(r.made, true);
    expect(r.timeMs, 2500);
    expect(r.notes, 'clean cut');
    expect(r.createdAt, a.createdAt);
  });

  // -----------------------------------------------------------------
  // Case 2 — Multi-attempt ordering + monotonic attemptNumber
  // -----------------------------------------------------------------
  test('case 2: 5 attempts in order with monotonic attemptNumber', () async {
    final repo = FakeDrillSessionRepository();
    for (var i = 1; i <= 5; i++) {
      await repo.addAttempt(_attempt(
        id: 'a$i',
        sessionId: 's1',
        attemptNumber: i,
        made: i.isOdd,
      ));
    }

    final list = repo.attemptsFor('s1');
    expect(list.length, 5);
    expect(list.map((a) => a.attemptNumber).toList(), [1, 2, 3, 4, 5]);
    expect(list.map((a) => a.id).toList(), ['a1', 'a2', 'a3', 'a4', 'a5']);
    expect(list.map((a) => a.made).toList(), [true, false, true, false, true]);
  });

  // -----------------------------------------------------------------
  // Case 3 — Session isolation
  //
  // Attempts for session A are not returned for session B.
  // -----------------------------------------------------------------
  test('case 3: attempts for session A do not leak into session B', () async {
    final repo = FakeDrillSessionRepository();
    await repo.addAttempt(_attempt(id: 'a1', sessionId: 'sA', attemptNumber: 1));
    await repo.addAttempt(_attempt(id: 'a2', sessionId: 'sA', attemptNumber: 2));
    await repo.addAttempt(_attempt(id: 'b1', sessionId: 'sB', attemptNumber: 1));

    final listA = repo.attemptsFor('sA');
    final listB = repo.attemptsFor('sB');

    expect(listA.length, 2);
    expect(listA.every((a) => a.sessionId == 'sA'), true);
    expect(listB.length, 1);
    expect(listB.single.id, 'b1');
    expect(listB.every((a) => a.sessionId == 'sB'), true);
  });

  // -----------------------------------------------------------------
  // Case 4 — Empty-session case
  //
  // Attempts for a session id with no attempts returns empty list.
  // -----------------------------------------------------------------
  test('case 4: empty-session case returns empty list', () async {
    final repo = FakeDrillSessionRepository();
    expect(repo.attemptsFor('never-saved'), isEmpty);
  });

  // -----------------------------------------------------------------
  // Case 5 — JSON round-trip
  //
  // toJson / fromJson preserve all fields including nullable timeMs
  // and notes. Both null and present cases.
  // -----------------------------------------------------------------
  test('case 5: JSON round-trip preserves fields incl. nullable', () async {
    final a = _attempt(
      id: 'a-json',
      sessionId: 's1',
      attemptNumber: 3,
      made: false,
      // timeMs and notes left null
    );

    final json = a.toJson();
    final restored = DrillAttempt.fromJson(json);

    expect(restored.id, 'a-json');
    expect(restored.sessionId, 's1');
    expect(restored.attemptNumber, 3);
    expect(restored.made, false);
    expect(restored.timeMs, isNull);
    expect(restored.notes, isNull);
    expect(restored.createdAt, a.createdAt);

    // Round-trip with non-null nullable fields.
    final b = _attempt(
      id: 'a-json2',
      sessionId: 's1',
      attemptNumber: 4,
      made: true,
      timeMs: 1200,
      notes: 'follow shot',
    );
    final restoredB = DrillAttempt.fromJson(b.toJson());
    expect(restoredB.timeMs, 1200);
    expect(restoredB.notes, 'follow shot');
  });

  // -----------------------------------------------------------------
  // Case 6 — Counter monotonic + duplicate-id behavior
  //
  // LocalDrillSessionRepository semantics: addAttempt is append-only.
  // Re-adding with same id duplicates the entry (no dedup at repo
  // layer). Caller's responsibility to avoid.
  //
  // This test pins the current behavior so any future change is
  // caught by the Critical Suite and reviewed intentionally.
  // -----------------------------------------------------------------
  test('case 6: append-only; duplicate id is appended (no dedup at repo)', () async {
    final repo = FakeDrillSessionRepository();
    await repo.addAttempt(_attempt(id: 'a1', sessionId: 's1', attemptNumber: 1));
    await repo.addAttempt(_attempt(id: 'a1', sessionId: 's1', attemptNumber: 2));

    final list = repo.attemptsFor('s1');
    // Current behavior: 2 entries, identical id, different attemptNumber.
    expect(list.length, 2);
    expect(list[0].attemptNumber, 1);
    expect(list[1].attemptNumber, 2);
  });
}