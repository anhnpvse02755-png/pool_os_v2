# Phase C.5 — Black Box Gate Review

**Date:** 2026-08-07
**Status:** Pending
**Phase:** Beta Pre-Release Verification

---

## Overview

Before releasing Beta APK, all 6 gates must pass. Each gate validates a critical aspect of the Black Box system.

---

## Gate 1 — Export Reliability ✅

### Criteria

| Test | Target | Status |
|------|--------|--------|
| Consecutive exports | 20/20 succeed | ⏳ |
| Empty state export | No crash | ⏳ |
| Interrupted session | No crash | ⏳ |
| 1000+ events | No crash | ⏳ |
| 100+ conversations | No crash | ⏳ |
| ZIP size | < 5 MB | ⏳ |

### Test Cases

```bash
# Test 1: Fresh install, no data
adb shell am start -n com.poolos.app/.MainActivity
# Navigate: Settings → Black Box → Export
# Expected: Success, ~500 KB ZIP

# Test 2: With interrupted session
# Start drill, force close app
adb shell am force-stop com.poolos.app
# Reopen, Settings → Black Box → Export
# Expected: Success, includes interrupted state

# Test 3: Heavy usage
# Simulate 1000 events
# Export
# Expected: Success, < 5 MB

# Test 4: 20 consecutive exports
for i in {1..20}; do
  adb shell am start -n com.poolos.app/.MainActivity
  # Export
done
# Expected: 20/20 success
```

---

## Gate 2 — Replay Integrity ⭐

### Criteria

Every user action must be traceable in `replay.json`.

### Test Scenario

```
Timeline:
19:00 - Open app
19:02 - Coach Home
19:03 - Recommendation shown (Stop Ball)
19:05 - Accept recommendation
19:05 - Start drill
19:18 - Complete drill (score: 72)
19:20 - Coach Chat opened
19:21 - Ask "How am I doing?"
19:22 - Coach response
19:30 - Match started
20:10 - Match completed (win 3-1)
20:15 - Close app
20:15 - Export
```

### Validation

Open `replay.json` and verify:

```json
{
  "replay": [
    {"event": "app_open", "elapsed": 0},
    {"event": "coach_home_loaded", "elapsed": 2},
    {"event": "coach_recommendation_shown", "elapsed": 3},
    {"event": "start_drill", "elapsed": 5},
    {"event": "drill_completed", "elapsed": 18},
    {"event": "coach_chat_open", "elapsed": 20},
    {"event": "coach_message_sent", "elapsed": 21},
    {"event": "coach_response_received", "elapsed": 22},
    {"event": "match_started", "elapsed": 30},
    {"event": "match_completed", "elapsed": 70},
    {"event": "app_close", "elapsed": 75}
  ]
}
```

### Requirements

- [ ] All 11 events present
- [ ] Elapsed times match ±2 seconds
- [ ] State changes have `stateBefore` and `stateAfter`
- [ ] Cause chains are complete

### Pass Criteria

**100% match** — If any event is missing, FAIL.

---

## Gate 3 — Snapshot Completeness

### Validation Checklist

Open ZIP and verify all folders exist with valid content:

```
PoolOS_Coach_v2.0_A01_20260807.zip
├── manifest.json              ✅ Not empty
├── replay.json               ✅ Not empty, valid JSON
├── player/
│   ├── identity.json         ✅ Has player data
│   ├── skill_profile.json    ✅ Has skills array
│   ├── progress.json         ✅ Has trend data
│   └── mental.json           ✅ Has indicators
├── coach/
│   ├── current_state.json    ✅ Has priority
│   ├── recommendations/     ✅ At least 1 file
│   └── conversations/        ✅ At least 1 file
├── session/
│   └── current.json          ✅ Present
├── timeline/                 ✅ Present
├── feedback/
│   └── responses.json        ✅ Present or null
└── system/
    ├── device.json           ✅ Present
    └── versions.json         ✅ Present
```

### Anti-Patterns Check

❌ NOT allowed:
```json
// Empty object
{}

// Empty array (when data expected)
{"skills": []}

// Null values (when data should exist)
{"player": null}
```

✅ Allowed:
```json
// Optional sections
{"feedback": null}

// Empty arrays (for optional data)
{"recommendations": []}
```

---

## Gate 4 — Claude Replay Test ⭐⭐⭐

### The Ultimate Test

**This is the most important gate.**

### Steps

1. Install Beta APK on device
2. Use app for 30 minutes (mix of coaching, drills, matches)
3. Export ZIP
4. Open new Claude conversation
5. Upload only the ZIP file
6. Ask questions

### Questions to Ask Claude

```markdown
1. "Who is this player?"
   Expected: Name, level, goals, experience

2. "What is the player weak at?"
   Expected: Skill analysis, specific weakness

3. "What did Coach recommend?"
   Expected: List of recommendations with reasoning

4. "Did the player follow Coach's advice?"
   Expected: Acceptance rate, completion rate

5. "Are there any UX issues?"
   Expected: Analysis of user behavior patterns

6. "What should Coach improve?"
   Expected: Specific recommendations

7. "Can you replay the session?"
   Expected: Accurate recreation from replay.json
```

### Pass Criteria

Claude must answer **without asking follow-up questions**.

If Claude asks "What was the player's name?" → FAIL
If Claude asks "What drill did they start?" → FAIL

The Black Box must be **complete enough for Claude to understand everything**.

---

## Gate 5 — Performance

### Benchmarks

| Operation | Target | Measure |
|-----------|--------|---------|
| Build package | < 2s | From tap to ready |
| ZIP compression | < 3s | Including all files |
| Share sheet | < 1s | To native share |
| UI responsiveness | 60 FPS | No jank during export |
| Memory usage | < 100 MB | During export |

### Measurement

```dart
// In code, measure:
final stopwatch = Stopwatch()..start();
await packageBuilder.buildPackage(...);
stopwatch.stop();
final duration = stopwatch.elapsedMilliseconds;
// Log: 'Package built in ${duration}ms'
```

### Pass Criteria

All operations within targets on mid-range device (Snapdragon 665+).

---

## Gate 6 — Privacy

### Whitelist

**ALLOWED in export:**
- [ ] Player display name (e.g., "Minh")
- [ ] Skill scores and trends
- [ ] Coach recommendations and reasoning
- [ ] Session timestamps (relative)
- [ ] Device model (e.g., "Pixel 7")
- [ ] App version and build number
- [ ] Practice metrics

### Blacklist

**NEVER export:**
- [ ] Passwords or auth tokens
- [ ] Supabase keys
- [ ] Email addresses
- [ ] Phone numbers
- [ ] GPS coordinates
- [ ] IP addresses
- [ ] Contact list
- [ ] Photos or media
- [ ] Cookies or session tokens
- [ ] Payment information

### Verification

```bash
# Extract ZIP and search for sensitive data
unzip -o PoolOS_Coach_v2.0_*.zip -d /tmp/poolos_check

grep -r "password" /tmp/poolos_check/
grep -r "@" /tmp/poolos_check/          # Emails
grep -r "token" /tmp/poolos_check/
grep -r "secret" /tmp/poolos_check/
grep -r "key" /tmp/poolos_check/

# Expected: No matches
```

---

## Gate Results Summary

| Gate | Name | Status | Notes |
|------|------|--------|-------|
| 1 | Export Reliability | ⏳ | |
| 2 | Replay Integrity | ⏳ | |
| 3 | Snapshot Completeness | ⏳ | |
| 4 | Claude Replay Test | ⏳ | |
| 5 | Performance | ⏳ | |
| 6 | Privacy | ⏳ | |

---

## packageHealth Manifest Field

Each exported ZIP includes `manifest.json`:

```json
{
  "schemaVersion": "2.0",
  "packageCreated": "2026-08-07T21:15:00+07:00",
  "testerId": "A01",
  "versions": {...},
  "stats": {...},
  "packageHealth": {
    "exportSucceeded": true,
    "missingFiles": [],
    "validationIssues": [],
    "validationPassed": true,
    "checksum": "sha256:abc123...",
    "exportDurationMs": 2340,
    "validatedAt": "2026-08-07T21:15:02+07:00",
    "zipSizeBytes": 2457600
  }
}
```

### How to Use

Claude can read `manifest.json` first to determine package health:

```
✓ If validationPassed = true → Package is complete
✓ If validationPassed = false → Check missingFiles and validationIssues
✓ If checksum present → Verify integrity
✓ If exportSucceeded = false → Export was interrupted
```

---

## Sign-Off

| Gate | Tester | Date | Result |
|------|--------|------|--------|
| 1 | | | ⏳ |
| 2 | | | ⏳ |
| 3 | | | ⏳ |
| 4 | | | ⏳ |
| 5 | | | ⏳ |
| 6 | | | ⏳ |

**All gates must pass before Phase D: Internal Beta**

---

## Next Steps

After all gates pass:

```
Phase D: Internal Beta
├── Build Beta 0.9 APK
├── Prepare Tester Guide
├── Recruit 5-10 testers
├── Distribute APK
└── Collect Black Box ZIPs

Phase E: Analysis
├── Claude reviews each ZIP
├── Generate Engineering Reports
├── Identify patterns
└── Plan fixes for Beta 0.9.1
```
