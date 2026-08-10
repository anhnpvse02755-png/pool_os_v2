---
name: phase-3-vertical-slice-roadmap
description: LOCKED Coach AI Vertical Slice roadmap — Phase 3 to Phase 7.
metadata:
  type: project
---

# Coach AI Vertical Slice Roadmap — LOCKED

**Goal:** Complete Vertical Slice from Practice → Coach AI Preview
**Priority Lens:** "Does this help Coach AI work better?"
**Validation Gate:** Phase 7 (Coach AI Preview)
**Status:** LOCKED — do not deviate without explicit approval

---

## Phase 3 — Experience Foundation ✅

| Sprint | Output for Coach AI | Status |
|--------|---------------------|--------|
| **3A** | Drill sessions + reflection patterns | ✅ Done |
| **3B** | Match data + performance signals | ✅ Done |

---

## Phase 4 — History & Analytics Foundation ✅

| Sprint | Output for Coach AI | Status |
|--------|---------------------|--------|
| **4A** | Training history, session details, progress tracking | ✅ Done |
| **4B** | Match history, rack data (fouls/safety/run), aggregates | ✅ Done |
| **4C** | Timeline, trends, Coach AI data layer | ✅ Done |

---

## Phase 5 — Knowledge Engine ✅

**Goal:** Coach AI must have domain knowledge about Pool.

### Sprint 5A — Drill & Kỹ thuật ✅
**North Star:** "Coach hiểu từng drill."

| Output | Coach AI Value |
|--------|---------------|
| Knowledge Graph | AI queries structured knowledge |
| DrillNode | AI knows drill purpose, skills, prerequisites |
| SkillNode | AI knows pool skills taxonomy |
| MistakeNode | AI knows common mistakes |

### Sprint 5B — Reasoning Chain ✅
**North Star:** "Coach có thể explain."

| Output | Coach AI Value |
|--------|---------------|
| ObservationNode | AI reads data signals |
| CauseNode | AI identifies root causes |
| Reasoning Chain | AI explains WHY, not just WHAT |

### Sprint 5C — Chiến thuật (Tactics) ✅
**North Star:** "Coach hiểu chiến thuật."

| Output | Coach AI Value |
|--------|---------------|
| SituationNode | AI recognizes game situations |
| TacticNode | AI knows tactical options |
| DecisionRule | AI reasons about when to use tactic |

---

## Phase 6 — Coach Foundation ✅

**Goal:** Coach must be able to read player data and generate recommendations.

### Sprint 6A — Player Intelligence Model ✅
**North Star:** "Coach AI hiểu người chơi."

| Output | Coach AI Value |
|--------|---------------|
| PlayerIntelligence | AI knows player profile |
| SkillProfile | AI knows skill levels |
| Memory Layers | AI remembers context |

### Sprint 6B — Priority Engine ✅
**North Star:** "Coach biết ưu tiên điều gì trước."

| Output | Coach AI Value |
|--------|---------------|
| Priority scoring | AI knows what matters most |
| Avoid recommendations | AI knows what NOT to do |
| Long-term plan | AI plans ahead |

---

## Phase 7 — Coach Preview ✅

**Goal:** Coach AI can have conversations with the player.

### Sprint 7A — Conversation Engine ✅
**North Star:** "Người chơi cảm thấy đang được một HLV đồng hành."

| Output | Coach AI Value |
|--------|---------------|
| ConversationEngine | AI can chat with player |
| IntentParser | AI understands player intent |
| CoachService | AI generates reasoning |
| SessionMemory | AI remembers context |

---

## Phase 7B — Coach Preview UI 🔲

**Goal:** Player actually uses Coach AI in practice.

**Principles:**
- Product First
- No Brain expansion
- Experience Layer only

### Deliverables (UI only)
- Coach Home Screen
- Daily Briefing Card
- Coach Chat Screen
- Recommendation Card
- Explain Button
- Coach Timeline

### Definition of Done
**A new player can:**
- Mở app
- Tập luyện
- Ghi trận
- Xem lịch sử
- Hỏi Coach
- Nhận recommendation
- Hiểu vì sao
- Quay lại sử dụng

**Without any explanation from others.**

---

## 🎯 COACH AI VERTICAL SLICE

**Phase 3-7B:** Coach AI Preview ready for testing.

| Phase | Focus | Status |
|-------|-------|--------|
| 3 | Experience Foundation | ✅ |
| 4 | History & Analytics | ✅ |
| 5 | Knowledge Graph | ✅ |
| 6 | Player Intelligence | ✅ |
| 7A | Conversation Engine | ✅ |
| **7B** | **Coach Preview UI** | **🔲** |

**After 7B:** Close slice, move to Preview/Beta testing phase.
|--------|---------------|
| Learning sequence | AI recommends drill order |
| Prerequisite chains | AI knows skill dependencies |
| Progression rules | AI tracks level advancement |

---

## Phase 6 — Coach Foundation

**Goal:** Coach must be able to read player data and generate recommendations.

### Sprint 6A — Player Profile + Memory
**North Star:** "Coach hiểu người chơi."

| Output | Coach AI Value |
|--------|---------------|
| Player profile | AI knows who the player is |
| Skill profile | AI knows player strengths/weaknesses |
| Memory layer | AI remembers player history |

### Sprint 6B — Insight Engine
**North Star:** "Coach phân tích điểm mạnh/yếu."

| Output | Coach AI Value |
|--------|---------------|
| Strength analysis | AI identifies what player does well |
| Weakness analysis | AI identifies improvement areas |
| Pattern detection | AI finds recurring issues |

### Sprint 6C — Recommendation Engine
**North Star:** "Coach đề xuất hành động."

| Output | Coach AI Value |
|--------|---------------|
| Recommendation rules | AI generates drill suggestions |
| Priority scoring | AI prioritizes by impact |
| Context-aware rules | AI adapts to recent performance |

---

## Phase 7 — Coach AI Preview

**Goal:** Complete Vertical Slice.

### Sprint 7A — Coach AI Core
**North Star:** "AI phân tích buổi tập & trận đấu."

| Capability | Coach AI Value |
|------------|---------------|
| Read drill history | ✅ From Phase 3-4 |
| Read match history | ✅ From Phase 3-4 |
| Read knowledge | ✅ From Phase 5 |
| Read player profile | ✅ From Phase 6A |
| Analyze strengths/weaknesses | 🔲 Sprint 7A |
| Explain causes | 🔲 Sprint 7A |
| Recommend next drill | 🔲 Sprint 7A |

### Sprint 7B — Integrated Preview
**North Star:** "Người chơi cảm thấy như đang có một HLV thật."

| Deliverable | Coach AI Value |
|-------------|---------------|
| Coach conversation | AI responds to player questions |
| Session analysis | AI reviews completed sessions |
| Match review | AI analyzes recent matches |
| Training plan | AI suggests practice schedule |

### Sprint 7C — Preview Build
**Goal:** Build APK Preview for real user testing.

| Deliverable | Status |
|-------------|--------|
| APK Preview | 🔲 Sprint 7C |
| Integration test | 🔲 Sprint 7C |
| Coach AI E2E test | 🔲 Sprint 7C |

---

## Vertical Slice Complete → Product Validation Gate

After Phase 7:
- ✅ Practice Loop (3A)
- ✅ Match Experience (3B)
- ✅ History & Analytics (4A-B)
- ✅ Knowledge Engine (5A-C)
- ✅ Coach Foundation (6A-C)
- ✅ Coach AI Preview (7A-C)

**→ Build APK Preview**
**→ Real User Validation**
**→ Branch A/B/C Decision**

---

## Locked Execution Rules

1. **Sprint 4C SKIPPED** — Analytics Dashboard has low Coach AI value. Data infrastructure complete from 4A-B.

2. **No deviation from roadmap** without explicit approval.

3. **Each sprint must answer:** "Coach AI sẽ tận dụng dữ liệu/workflow này như thế nào?"

4. **If a feature doesn't help Coach AI → lower priority.**

5. **Do not expand scope** beyond what's listed.

6. **Stop only if:** blocker kỹ thuật nghiêm trọng OR explicit approval to change roadmap.

---

## Dependency Map

```
Phase 3 (Practice + Match) → Session/Match data
         ↓
Phase 4 (History + Analytics) → Aggregated data + trends
         ↓
Phase 5 (Knowledge) → Domain knowledge for AI
         ↓
Phase 6 (Coach Foundation) → Player profile + recommendations
         ↓
Phase 7 (Coach AI) → Complete vertical slice
         ↓
Product Validation Gate
```

**Rule:** Each phase builds what the next phase needs. Coach AI is the consumer of all prior phases.

Related: [[phase-3-constitution]], [[phase-3-rule-4a]], [[phase-3-rule-4b]].
