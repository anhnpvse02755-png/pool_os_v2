# PoolOS Black Box Recorder — Design Document

**Date:** 2026-08-07
**Type:** Product + Engineering Design (Final)
**Scope:** Sprint 7.Beta — Complete AI State Snapshot

---

## Concept

**This is NOT a bug report.**

This is a **Snapshot of an AI Player.**

When opened, it should feel like opening a project.

Claude reads the ZIP and understands everything about this user without needing access to the original device.

---

## Workflow

```
PoolOS Beta 0.9

↓

Tester cài APK

↓

Tập luyện bình thường

↓

Coach hoạt động

↓

Nếu có gì bất thường

↓

Settings → Export Coach Package

↓

Share qua Zalo

↓

Nhận file ZIP

↓

Claude đọc toàn bộ

↓

Claude viết Engineering Report

↓

Claude sửa bug

↓

Build Beta 0.9.1
```

---

## Design Principles (P0 - Non-Negotiable)

### Principle 1: Event Schema Compatibility Policy

**Event names are immutable.**

| Rule | Description |
|------|-------------|
| CAN DO | Add new event types |
| CAN DO | Add new optional fields to existing events |
| CANNOT DO | Rename existing events |
| CANNOT DO | Change meaning of existing events |
| CANNOT DO | Remove event types |
| CANNOT DO | Change required fields |

**Versioning Example:**

```
v2.0 (Baseline)
├── start_drill
├── drill_completed
├── coach_chat_open
└── coach_chat_close

v2.1 (Future)
├── start_drill
├── drill_completed
├── coach_chat_open
├── coach_chat_close
├── match_export              ← NEW
└── video_analysis_completed   ← NEW

INVALID (DO NOT DO)
├── start_drill               ← OK
├── drill_started             ← INVALID! Was "start_drill"
└── drill_completed           ← OK
```

**Why?** Claude must support all versions simultaneously. Changing event names breaks backward compatibility and makes analysis impossible.

---

### Principle 2: 100% Replayability Principle

**Never export state without exporting the cause chain.**

> "Every state in the Black Box must be traceable to the events and decisions that created it."

**Example - CORRECT:**
```
State: "priority = Stop Ball"

Must also export:
1. Position Play score = 58% (observation)
2. Mistake frequency = 45 (observation)
3. Priority Engine calculation (reasoning)
4. Recommendation output (decision)
5. Player accepted (action)
6. Drill completed (result)
7. New Position Play score = 63% (new state)
```

**Example - INCORRECT (Prohibited):**
```json
// WRONG: Only state, no cause
{
  "current_priority": {
    "drill": "stop_ball"
  }
}
```

**Why?** Without the cause chain, Claude cannot understand WHY the Coach made decisions. The Black Box must be a complete audit trail.

---

## North Star

> "One ZIP = One complete understanding of a player's journey."

**8 Questions Every ZIP Must Answer:**

1. **Who is this player?** — Identity, level, goals, history
2. **What did they do?** — Every action logged
3. **What did Coach recommend?** — All recommendations
4. **Why did Coach recommend it?** — Full reasoning chain
5. **Did the player follow it?** — Accept/Ignore/Modified
6. **What was the result?** — Before/After comparison
7. **Bugs encountered?** — Crashes, errors, warnings
8. **What did they think?** — Full feedback

---

## Package Naming

```
PoolOS_Coach_v2.0_<TesterID>_<yyyyMMdd_HHmm>.zip

Examples:
PoolOS_Coach_v2.0_A01_20260807_2115.zip
PoolOS_Coach_v2.0_B02_20260808_1430.zip
```

---

## Package Structure

```
PoolOS_Coach_v2.0_A01_20260807_2115.zip
├── manifest.json              # Package metadata + versions
├── player/
│   ├── identity.json         # Who is this player
│   ├── skill_profile.json    # Current skills
│   ├── knowledge.json        # Knowledge progress
│   ├── progress.json         # Trend engine state
│   └── mental.json           # Confidence, motivation
├── coach/
│   ├── current_state.json    # Coach Brain current state
│   ├── recommendations/      # All recommendations
│   │   ├── rec_001.json
│   │   ├── rec_002.json
│   │   └── ...
│   ├── conversations/       # All chat logs
│   │   ├── conv_001.json
│   │   ├── conv_002.json
│   │   └── ...
│   └── memory.json           # Coach Memory
├── session/
│   ├── current.json          # Current session state
│   ├── interrupted.json      # Unfinished session
│   └── history.json          # Session history
├── replay.json               # FLIGHT RECORDER - Sequential timeline
├── timeline/
│   └── events.json          # Detailed event log
├── feedback/
│   └── responses.json        # Full feedback survey
└── system/
    ├── device.json           # Environment
    ├── errors.json           # Crashes, warnings
    └── versions.json         # Build info
```

---

## replay.json — Flight Recorder

**The most important file for quick analysis.**

Sequential timeline with **100% Replayability**. Every state change includes the complete cause chain.

```json
{
  "schemaVersion": "2.0",
  "packageId": "pkg_abc123",
  "testerId": "A01",
  "sessionStart": "2026-08-07T19:00:00+07:00",
  "sessionEnd": "2026-08-07T21:15:00+07:00",
  "totalDuration": 7950,
  "totalEvents": 24,
  
  "replay": [
    {
      "time": "2026-08-07T19:00:00+07:00",
      "elapsed": 0,
      "event": "app_open",
      "cause": null,
      "stateBefore": null,
      "stateAfter": null
    },
    {
      "time": "2026-08-07T19:00:02+07:00",
      "elapsed": 2,
      "event": "coach_home_loaded",
      "cause": null,
      "stateBefore": null,
      "stateAfter": {
        "screen": "coach_home",
        "recommendation": null
      }
    },
    {
      "time": "2026-08-07T19:00:30+07:00",
      "elapsed": 30,
      "event": "recommendation_generated",
      "cause": {
        "type": "priority_engine",
        "observations": [
          "Position Play score = 58%",
          "Mistake frequency = 45",
          "Practice consistency = 75%"
        ],
        "reasoning": "Score (0.4) + Frequency (0.3) + Trend (0.2) = 94"
      },
      "stateBefore": {
        "current_priority": null
      },
      "stateAfter": {
        "current_priority": {
          "drill": "stop_ball",
          "score": 94,
          "recommendationId": "rec_124"
        }
      }
    },
    {
      "time": "2026-08-07T19:02:34+07:00",
      "elapsed": 154,
      "event": "start_drill",
      "cause": {
        "type": "user_action",
        "trigger": "recommendation_accepted",
        "recommendationId": "rec_124"
      },
      "stateBefore": {
        "session_active": false,
        "recommendation_status": "shown"
      },
      "stateAfter": {
        "session_active": true,
        "current_drill": "stop_ball",
        "recommendation_status": "accepted",
        "recommendationId": "rec_124"
      }
    },
    {
      "time": "2026-08-07T19:18:01+07:00",
      "elapsed": 1081,
      "event": "drill_completed",
      "cause": {
        "type": "drill_result",
        "recommendationId": "rec_124"
      },
      "stateBefore": {
        "session_active": true,
        "drill_score": null,
        "position_play_score": 58
      },
      "stateAfter": {
        "session_active": false,
        "drill_score": 72,
        "position_play_score": 63,
        "improvement": "+5%",
        "recommendationId": "rec_124",
        "recommendation_status": "completed"
      }
    },
    {
      "time": "2026-08-07T19:19:00+07:00",
      "elapsed": 1140,
      "event": "coach_chat_open",
      "cause": null,
      "stateBefore": null,
      "stateAfter": {
        "screen": "coach_chat",
        "conversationId": "conv_012"
      }
    },
    {
      "time": "2026-08-07T19:19:31+07:00",
      "elapsed": 1171,
      "event": "coach_response_received",
      "cause": {
        "type": "coach_service",
        "intent": "howAmIDoing",
        "reasoning": "Position improved 5%, continuing trend"
      },
      "stateBefore": null,
      "stateAfter": {
        "conversationId": "conv_012",
        "messages_count": 2
      }
    },
    {
      "time": "2026-08-07T19:22:00+07:00",
      "elapsed": 1320,
      "event": "coach_chat_close",
      "cause": {
        "type": "user_action"
      },
      "stateBefore": {
        "screen": "coach_chat"
      },
      "stateAfter": {
        "screen": "coach_home"
      }
    },
    {
      "time": "2026-08-07T19:25:00+07:00",
      "elapsed": 1500,
      "event": "match_started",
      "cause": null,
      "stateBefore": null,
      "stateAfter": {
        "match_active": true,
        "matchId": "match_008"
      }
    },
    {
      "time": "2026-08-07T20:10:00+07:00",
      "elapsed": 4200,
      "event": "match_completed",
      "cause": null,
      "stateBefore": {
        "match_active": true
      },
      "stateAfter": {
        "match_active": false,
        "match_result": "win",
        "player_score": 3,
        "opponent_score": 1
      }
    },
    {
      "time": "2026-08-07T20:15:00+07:00",
      "elapsed": 4500,
      "event": "app_close",
      "cause": null,
      "stateBefore": null,
      "stateAfter": {
        "session_duration": 4500
      }
    },
    {
      "time": "2026-08-07T21:15:00+07:00",
      "elapsed": 8100,
      "event": "export_initiated",
      "cause": null,
      "stateBefore": null,
      "stateAfter": null
    },
    {
      "time": "2026-08-07T21:15:30+07:00",
      "elapsed": 8130,
      "event": "export_completed",
      "cause": null,
      "stateBefore": null,
      "stateAfter": {
        "packageName": "PoolOS_Coach_v2.0_A01_20260807_2115.zip",
        "size": "2.3 MB"
      }
    }
  ]
}
```

### Event Types for replay.json

| Event | Description |
|-------|-------------|
| `app_open` | App started |
| `app_close` | App closed |
| `coach_home_loaded` | Coach Home screen loaded |
| `coach_recommendation_shown` | Recommendation displayed |
| `recommendation_accepted` | User tapped Start |
| `recommendation_ignored` | User dismissed |
| `start_drill` | User started drill |
| `drill_completed` | Drill finished successfully |
| `drill_abandoned` | Drill abandoned |
| `drill_paused` | Drill paused |
| `drill_resumed` | Drill resumed |
| `coach_chat_open` | Chat opened |
| `coach_message_sent` | User sent message |
| `coach_response_received` | Coach responded |
| `coach_chat_close` | Chat closed |
| `coach_explain_shown` | Explain sheet shown |
| `match_started` | Match started |
| `match_completed` | Match finished |
| `settings_open` | Settings opened |
| `settings_changed` | Setting changed |
| `export_initiated` | Export started |
| `export_completed` | Export finished |
| `error_occurred` | Error/warning occurred |

---

## manifest.json

```json
{
  "schemaVersion": "2.0",
  "packageCreated": "2026-08-07T21:15:00+07:00",
  "testerId": "A01",
  
  "versions": {
    "app": {
      "name": "PoolOS",
      "version": "1.0.0",
      "build": "42",
      "channel": "beta"
    },
    "schema": "2.0",
    "knowledgeGraph": {
      "version": "18",
      "totalNodes": 156
    },
    "coachBrain": {
      "priorityEngine": "7",
      "coachService": "7",
      "conversationEngine": "7"
    }
  },
  
  "stats": {
    "sessionsTotal": 15,
    "sessionsCompleted": 12,
    "sessionsInterrupted": 3,
    "matchesTotal": 8,
    "recommendationsTotal": 15,
    "conversationsTotal": 12,
    "eventsTotal": 156,
    "packageSize": "2.3 MB"
  }
}
```

---

## player/identity.json

```json
{
  "schemaVersion": "2.0",
  
  "player": {
    "id": "player_abc123",
    "displayName": "Minh",
    "createdAt": "2026-06-01T10:00:00+07:00",
    "daysActive": 37,
    "testerId": "A01"
  },
  
  "level": {
    "current": "intermediate",
    "score": 72,
    "classification": "Người chơi trung cấp"
  },
  
  "goals": {
    "primary": "Cải thiện position play",
    "secondary": ["Giảm lỗi Draw Shot", "Tăng consistency"]
  },
  
  "history": {
    "firstSession": "2026-06-01",
    "lastSession": "2026-08-07",
    "longestStreak": 12,
    "currentStreak": 5,
    "totalPracticeMinutes": 1800
  }
}
```

---

## player/skill_profile.json

```json
{
  "schemaVersion": "2.0",
  "snapshotAt": "2026-08-07T21:15:00+07:00",
  
  "overall": {
    "score": 72,
    "trend": "improving",
    "confidence": 78
  },
  
  "skills": [
    {
      "id": "aiming",
      "name": "Aiming",
      "nameVi": "Ngắm bia",
      "score": 85,
      "trend": "stable",
      "attempts": 450,
      "accuracy": 0.85,
      "mastery": "high"
    },
    {
      "id": "position_play",
      "name": "Position Play",
      "nameVi": "Vị trí",
      "score": 58,
      "trend": "improving",
      "attempts": 320,
      "accuracy": 0.58,
      "mastery": "low",
      "priority": 1
    },
    {
      "id": "speed_control",
      "name": "Speed Control",
      "nameVi": "Kiểm soát tốc độ",
      "score": 65,
      "trend": "declining",
      "attempts": 280,
      "accuracy": 0.65,
      "mastery": "medium"
    },
    {
      "id": "spin_control",
      "name": "Spin Control",
      "nameVi": "Kiểm soát xoá",
      "score": 70,
      "trend": "stable",
      "attempts": 200,
      "accuracy": 0.70,
      "mastery": "medium"
    }
  ],
  
  "weakestSkills": ["position_play", "speed_control"],
  "strongestSkills": ["aiming"]
}
```

---

## coach/current_state.json

```json
{
  "schemaVersion": "2.0",
  "snapshotAt": "2026-08-07T21:15:00+07:00",
  
  "priorityEngine": {
    "version": "7",
    "currentPriority": {
      "drillCode": "position_play_basic",
      "drillName": "Position Play Cơ Bản",
      "priorityScore": 94,
      "reason": "Lowest score (58%) + High frequency (45%)",
      "setAt": "2026-08-07T09:00:00+07:00"
    },
    "priorityQueue": [
      { "rank": 1, "drill": "position_play_basic", "score": 94 },
      { "rank": 2, "drill": "speed_control", "score": 78 },
      { "rank": 3, "drill": "spin_basics", "score": 65 }
    ]
  },
  
  "coachingPlan": {
    "shortTerm": {
      "weeks": 2,
      "focus": ["Position Play", "Speed Control"],
      "targetDrills": ["position_play_basic", "speed_control"],
      "progress": 35
    },
    "longTerm": {
      "phases": [
        { "name": "Nền tảng", "weeks": 4, "focus": "Position Play", "status": "in_progress" },
        { "name": "Phát triển", "weeks": 6, "focus": "Advanced Positioning", "status": "pending" }
      ]
    }
  },
  
  "memory": {
    "sessionMemory": {
      "hasUnfinished": true,
      "drill": "stop_ball",
      "progress": 45,
      "lastUpdate": "2026-08-06T20:30:00+07:00"
    },
    "conversationMemory": {
      "totalConversations": 12,
      "lastConversation": "2026-08-07T09:20:00+07:00",
      "avgMessagesPerConversation": 4.2
    },
    "recommendationMemory": {
      "totalGiven": 15,
      "totalAccepted": 10,
      "totalCompleted": 9,
      "pending": 2
    }
  }
}
```

---

## coach/recommendations/rec_XXX.json

```json
{
  "schemaVersion": "2.0",
  "id": "rec_001",
  "createdAt": "2026-08-07T09:00:00+07:00",
  
  "drill": {
    "code": "stop_ball",
    "name": "Stop Ball",
    "difficulty": "beginner",
    "skills": ["position_play", "cue_ball_control"],
    "estimatedMinutes": 10
  },
  
  "priority": {
    "score": 94,
    "rank": 1,
    "type": "drill_recommendation",
    "urgency": "high"
  },
  
  "reasoning": {
    "primaryReason": "Gateway skill for position play",
    "evidence": [
      { "type": "low_score", "data": "Position Play score: 58%", "weight": 0.4 },
      { "type": "high_frequency", "data": "Lỗi position xuất hiện 45 lần", "weight": 0.3 },
      { "type": "trend", "data": "Xu hướng: improving", "weight": 0.2 },
      { "type": "prerequisite", "data": "Stop Ball prerequisite cho Position Play", "weight": 0.1 }
    ],
    "chain": [
      { "step": 1, "type": "observation", "input": "Player data", "output": "Position Play score = 58%" },
      { "step": 2, "type": "pattern_detection", "input": "Score history", "output": "Lỗi position sau Draw Shot xuất hiện 45 lần" },
      { "step": 3, "type": "prerequisite_analysis", "input": "Knowledge Graph", "output": "Stop Ball prerequisite cho Position Play" },
      { "step": 4, "type": "priority_calculation", "input": "Score + Frequency + Trend", "output": "Priority Score = 94" },
      { "step": 5, "type": "recommendation", "output": "Stop Ball drill" }
    ]
  },
  
  "expectedOutcome": {
    "shortTerm": "Cải thiện Stop Ball accuracy lên 70%",
    "longTerm": "Nền tảng cho Position Play nâng cao",
    "metrics": {
      "targetAccuracy": 70,
      "currentAccuracy": 58,
      "improvementExpected": "+12%"
    }
  },
  
  "knowledgeNodesUsed": [
    { "type": "skill", "id": "position_play", "name": "Position Play" },
    { "type": "skill", "id": "cue_ball_control", "name": "Kiểm soát cue ball" },
    { "type": "drill", "id": "stop_ball", "name": "Stop Ball" },
    { "type": "mistake", "id": "position_after_draw", "name": "Position after Draw" },
    { "type": "cause", "id": "follow_through", "name": "Follow through không đủ" }
  ],
  
  "playerState": {
    "skillScore": 58,
    "mistakeFrequency": 45,
    "practiceConsistency": 75,
    "confidenceLevel": "medium",
    "mentalState": "motivated"
  },
  
  "response": {
    "shown": true,
    "shownAt": "2026-08-07T09:00:01+07:00",
    "action": "accepted",
    "actionAt": "2026-08-07T09:03:00+07:00",
    "started": true,
    "startedAt": "2026-08-07T09:03:00+07:00",
    "completed": false,
    "abandoned": null
  },
  
  "result": {
    "measured": false,
    "newScore": null,
    "improvement": null,
    "notes": "Pending completion"
  }
}
```

---

## coach/conversations/conv_XXX.json

```json
{
  "schemaVersion": "2.0",
  "id": "conv_001",
  "startedAt": "2026-08-07T09:00:00+07:00",
  "endedAt": "2026-08-07T09:02:30+07:00",
  "duration": 150,
  
  "messages": [
    {
      "index": 0,
      "role": "user",
      "content": "Nên tập gì hôm nay?",
      "timestamp": "2026-08-07T09:00:00+07:00",
      "intent": { "detected": "whatToPractice", "confidence": 0.95 }
    },
    {
      "index": 1,
      "role": "coach",
      "content": "Hôm nay mình khuyên bạn tập Stop Ball.\nVì accuracy của bạn ở bài này thấp nhất (62%).",
      "timestamp": "2026-08-07T09:00:01+07:00",
      "intent": { "detected": "whatToPractice", "confidence": 0.95 },
      "recommendationId": "rec_001"
    },
    {
      "index": 2,
      "role": "user",
      "content": "Tại sao?",
      "timestamp": "2026-08-07T09:01:30+07:00",
      "intent": { "detected": "whyRecommendation", "confidence": 0.92 }
    },
    {
      "index": 3,
      "role": "coach",
      "content": "Mình nhận thấy position play là điểm yếu chính của bạn.\nStop Ball là bài tập nền tảng giúp bạn kiểm soát cue ball.",
      "timestamp": "2026-08-07T09:01:31+07:00",
      "intent": { "detected": "whyRecommendation", "confidence": 0.92 }
    },
    {
      "index": 4,
      "role": "user",
      "content": "OK bắt đầu thôi",
      "timestamp": "2026-08-07T09:02:00+07:00",
      "intent": { "detected": "affirmative", "confidence": 0.98 }
    }
  ],
  
  "outcome": {
    "recommendationId": "rec_001",
    "accepted": true,
    "drillStarted": true,
    "drillCompleted": null
  }
}
```

---

## feedback/responses.json

```json
{
  "schemaVersion": "2.0",
  "collectedAt": "2026-08-07T21:15:00+07:00",
  
  "rating": {
    "overall": 4,
    "coachHelpful": 4,
    "coachUnderstandable": 4,
    "coachAccurate": 4,
    "coachRemembering": 3,
    "coachNatural": 4,
    "wouldUseAgain": true,
    "wouldRecommend": true
  },
  
  "qualitative": {
    "mostUseful": "Recommendation cá nhân hóa",
    "leastUseful": "Coach Chat hơi chậm",
    "mostConfusing": "Coach Timeline",
    "missingFeatures": "Video phân tích cú đánh"
  },
  
  "detailedFeedback": {
    "whatWorkedWell": "Coach khuyên đúng drill. Tiến bộ rõ rệt sau 1 tuần.",
    "whatCouldBeBetter": "Coach trả lời hơi dài dòng.",
    "frustrations": "Session bị mất khi tập giữa chừng.",
    "bugsEncountered": "Animation hơi lag ở Coach Timeline."
  }
}
```

---

## Export UX Flow

```
┌────────────────────────────────────────┐
│  Settings → PoolOS Black Box          │
│                                        │
│  [Export Black Box]                    │
└────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────┐
│  📝 Your Feedback (Optional)           │
│                                        │
│  Coach hữu ích?     ★ ★ ★ ★ ☆        │
│  Dễ hiểu?           ★ ★ ★ ★ ★        │
│  Đúng đắn?          ★ ★ ★ ★ ☆        │
│  Nhớ được?          ★ ★ ★ ☆ ☆        │
│  Tự nhiên?          ★ ★ ★ ★ ☆        │
│                                        │
│  [Skip]  [Submit & Export]            │
└────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────┐
│  ⏳ Building Black Box...              │
│                                        │
│  ████████████░░░░░░  67%              │
│                                        │
│  ✓ manifest.json                       │
│  ✓ replay.json         ← Flight Recorder│
│  ✓ player/identity.json                │
│  ✓ player/skill_profile.json          │
│  ▓ coach/current_state.json            │
│  ○ coach/recommendations/              │
│  ○ coach/conversations/               │
│  ...                                   │
└────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────┐
│  ✅ Black Box Ready!                   │
│                                        │
│  📦 PoolOS_Coach_v2.0_                │
│     A01_20260807_2115.zip             │
│     Size: 2.8 MB                      │
│                                        │
│  ┌────────────────────────────────┐    │
│  │     📤 Share via Zalo...      │    │
│  └────────────────────────────────┘    │
│                                        │
│  ┌────────────────────────────────┐    │
│  │     💾 Save to Downloads       │    │
│  └────────────────────────────────┘    │
└────────────────────────────────────────┘
```

---

## Implementation Steps (Post-Design)

### STEP 1: Freeze & Stabilize
```
- Freeze feature development
- Run full static analysis
- Run widget tests
- Run integration tests
- Fix every compile error and runtime issue
- Production stable before Beta
```

### STEP 2: Build Beta Release
```
- release mode
- minify enabled
- obfuscation enabled
- split debug symbols
- versionCode +1
- versionName: Beta 0.9
```

### STEP 3: Beta Test Checklist
```
Coach Home
Coach Chat
Training
Match Recording
History
Recommendation
Explain
Continue Session
Export Coach Package
```

### STEP 4: Tester Guide
```
How to install
How to use Coach
How to export package
How to send package
How to report feedback
```

### STEP 5: Package Review
```
Can we replay every recommendation?
Can we understand every Coach decision?
Can we reproduce every bug?
Can we evaluate recommendation quality?
Can we improve Coach from this package alone?
```

---

## Complete Journey Traceability Example

Demonstrating 100% Replayability:

```
SESSION: 2026-08-07

┌─────────────────────────────────────────────────────────────┐
│ STATE: priority = null                                       │
│ CAUSE: [app just opened]                                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ EVENT: recommendation_generated                             │
│ CAUSE: Priority Engine ran                                  │
│   - Position Play score = 58% (observation)                │
│   - Mistake frequency = 45 (observation)                    │
│   - Priority Score = 94 (calculation)                      │
│ STATE: priority = "stop_ball" (rec_124)                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ EVENT: start_drill (user accepted)                          │
│ CAUSE: User tapped "Start Stop Ball"                        │
│ STATE: session_active = true, drill = "stop_ball"          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ EVENT: drill_completed                                      │
│ CAUSE: User finished drill                                  │
│ RESULT: score = 72, improvement = +5%                       │
│ STATE: position_play_score = 63% (updated)                 │
│         recommendation_status = "completed"                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ VERIFICATION:                                              │
│ Can replay entire journey from replay.json?     ✅ YES       │
│ Can understand WHY Coach recommended?        ✅ YES       │
│ Can see BEFORE/AFTER state change?           ✅ YES       │
│ Can trace to observations/decisions?         ✅ YES       │
└─────────────────────────────────────────────────────────────┘
```

---

## Definition of Done

### Core Functionality
- [ ] Black Box exports successfully
- [ ] replay.json present and valid
- [ ] All JSON files with schemaVersion
- [ ] ZIP naming correct
- [ ] Share sheet works
- [ ] Save to Downloads works

### Traceability
- [ ] replay.json shows complete journey
- [ ] All recommendations traceable
- [ ] All conversations logged
- [ ] Coach reasoning complete
- [ ] Player state restorable

### Quality
- [ ] ZIP < 5 MB (target 2-3 MB)
- [ ] JSON valid and human-readable
- [ ] Performance impact < 5%

### Privacy
- [ ] No sensitive data
- [ ] Anonymous by design

---

**Document Status:** Final
**Version:** 2.0
**Concept:** Black Box Flight Recorder
**Next:** Implementation
