# D0.5 — Black Box Self Validation

**Purpose:** Validate that Black Box exports are complete, correct, and forward-compatible.

---

## Level 1: ZIP Structure Validation

### Validation Checklist

```bash
# Extract ZIP
unzip PoolOS_Coach_v2.0_*.zip -d /tmp/blackbox_check

# Verify structure
ls -la /tmp/blackbox_check/
```

### Required Files

| File/Directory | Required | Validation |
|----------------|----------|------------|
| `manifest.json` | Yes | Valid JSON, has schemaVersion |
| `replay.json` | Yes | Valid JSON, has events array |
| `player/` | Yes | Directory exists, has files |
| `coach/` | Yes | Directory exists, has files |
| `session/` | Yes | Directory exists |
| `timeline/` | Yes | Directory exists |
| `feedback/` | Yes | Directory exists |
| `system/` | Yes | Directory exists |

### Pass Criteria

- [ ] All required directories exist
- [ ] All required files exist and are non-empty
- [ ] `manifest.json` has valid schema version
- [ ] `packageHealth` field is present and valid

---

## Level 2: Replay Integrity Validation

### Validation Steps

```dart
// Pseudocode
final replay = loadJson('replay.json');
final events = replay['events'] as List;

assert(events.isNotEmpty, 'No events recorded');
assert(events.first['type'] == 'session_start', 'First event should be session_start');
assert(events.last['type'] == 'session_end', 'Last event should be session_end');

// Verify timeline integrity
var previousTimestamp = 0;
for (final event in events) {
  final timestamp = event['timestamp'] as int;
  assert(timestamp >= previousTimestamp, 'Events not in order');
  previousTimestamp = timestamp;
}
```

### Pass Criteria

- [ ] `replay.json` has events array
- [ ] Events are in chronological order
- [ ] First event is `session_start`
- [ ] Last event is `session_end`
- [ ] All events have required fields (`type`, `timestamp`)
- [ ] No duplicate event IDs

---

## Level 3: Recommendation Validation

### Validation Steps

```dart
// 1. Load recommendation
final rec = loadJson('coach/current_state.json');
final priority = rec['currentPriority'];

// 2. Load drill progress
final progress = loadJson('player/skill_profile.json');

// 3. Verify recommendation matches PriorityEngine output
final expected = PriorityEngine.calculate(
  drillProgress: progress,
  playerLevel: rec['playerLevel'],
  interests: rec['interests'],
);

assert(
  priority['drillCode'] == expected.drillCode,
  'Priority mismatch!',
);
assert(
  priority['reason'] == expected.reason,
  'Reason mismatch!',
);
```

### Pass Criteria

- [ ] `coach/current_state.json` exists
- [ ] Priority engine output matches stored recommendation
- [ ] Reason text is coherent (not empty, not generic)
- [ ] Priority is 1-3 range

---

## Level 4: Conversation Validation

### Validation Steps

```dart
// Load conversation log
final conversations = loadJson('coach/conversations/conversation_001.json');

// Verify conversation structure
for (final msg in conversations['messages']) {
  assert(msg['sender'] == 'user' || msg['sender'] == 'coach');
  assert(msg['text'] != null && msg['text'].isNotEmpty);
  assert(msg['timestamp'] != null);
}

// Verify Coach Voice compliance
for (final msg in conversations['messages']) {
  if (msg['sender'] == 'coach') {
    assert(!msg['text'].contains('Bạn muốn'));
    assert(!msg['text'].contains('Theo phân tích'));
    assert(!msg['text'].contains('Dựa trên dữ liệu'));
    assert(msg['text'].length < 200, 'Coach messages should be short');
  }
}
```

### Pass Criteria

- [ ] Conversation history exists (if any conversations)
- [ ] All messages have sender, text, timestamp
- [ ] No Coach Voice violations
- [ ] Messages are in chronological order

---

## Level 5: Claude Blind Test ⭐

### Purpose

Verify that Claude can understand the Black Box package without any additional context.

### Test Procedure

1. Export Black Box from app
2. Do NOT look at the code
3. Open Claude in new conversation
4. Upload only the ZIP file
5. Ask these questions:

### Questions Claude Must Answer

| # | Question | Claude Must Identify |
|---|----------|---------------------|
| 1 | "Who is this player?" | Name, level, goals |
| 2 | "What is the player's weakness?" | Specific skills/drills |
| 3 | "What did Coach recommend?" | Drill name + reason |
| 4 | "Was the recommendation followed?" | Accept/decline, completion |
| 5 | "Are there any UX issues?" | Behavioral patterns |
| 6 | "What should Coach improve?" | Specific recommendations |

### Pass Criteria

Claude answers **all 6 questions** without asking follow-up questions like:
- "What was the player's name?"
- "Which drill did they start?"
- "Did they complete the drill?"

---

## Gate 7: Forward Compatibility

### Purpose

Ensure Black Box packages remain readable across schema versions.

### Test Procedure

1. Create a test package with `schemaVersion: "2.1"`
2. Add a new event type: `app_theme_changed`
3. Parse with current reader (expecting v2.0)

### Expected Behavior

```dart
// Old reader should:
void readPackage(Map<String, dynamic> manifest) {
  // Read known fields
  final version = manifest['schemaVersion'];
  final health = manifest['packageHealth'];

  // Ignore unknown fields (forward compatibility)
  // No crash, no error
}

// New fields should be silently ignored
```

### Pass Criteria

- [ ] Reader handles unknown `schemaVersion` gracefully
- [ ] Reader ignores unknown event types
- [ ] Reader ignores unknown JSON fields
- [ ] No exceptions thrown on unknown data

---

## Validation Tool

### Usage

```bash
# Run validation
dart tools/validate_black_box.dart --input=./PoolOS_Coach_v2.0_A01.zip
```

### Output

```
╔══════════════════════════════════════════════════════════════╗
║           BLACK BOX VALIDATION REPORT                      ║
╠══════════════════════════════════════════════════════════════╣
║ File: PoolOS_Coach_v2.0_A01.zip                            ║
║ Date: 2026-08-07                                           ║
╠══════════════════════════════════════════════════════════════╣
║ LEVEL 1: ZIP Structure         [✓ PASS]                    ║
║   - manifest.json              [✓]                          ║
║   - replay.json                [✓]                          ║
║   - player/                    [✓]                          ║
║   - coach/                    [✓]                          ║
╠══════════════════════════════════════════════════════════════╣
║ LEVEL 2: Replay Integrity     [✓ PASS]                     ║
║   - Events in order           [✓]                          ║
║   - Start/end markers         [✓]                          ║
╠══════════════════════════════════════════════════════════════╣
║ LEVEL 3: Recommendation       [✓ PASS]                     ║
║   - Priority matches engine    [✓]                          ║
║   - Reason is coherent        [✓]                          ║
╠══════════════════════════════════════════════════════════════╣
║ LEVEL 4: Conversation         [✓ PASS]                     ║
║   - Coach Voice compliant     [✓]                          ║
║   - Structure valid           [✓]                          ║
╠══════════════════════════════════════════════════════════════╣
║ GATE 7: Forward Compat        [✓ PASS]                     ║
║   - Unknown fields ignored    [✓]                          ║
║   - Unknown events ignored    [✓]                          ║
╠══════════════════════════════════════════════════════════════╣
║                    [✓✓✓✓✓] ALL CHECKS PASSED                ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Sign-Off

| Checkpoint | Status | Date |
|------------|--------|------|
| Level 1: ZIP Structure | ☐ | |
| Level 2: Replay Integrity | ☐ | |
| Level 3: Recommendation | ☐ | |
| Level 4: Conversation | ☐ | |
| Level 5: Claude Blind Test | ☐ | |
| Gate 7: Forward Compatibility | ☐ | |

**Overall Result:** ☐ PASS ☐ FAIL

---
