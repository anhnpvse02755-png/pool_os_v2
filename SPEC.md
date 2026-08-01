# PoolOS_v2 — AI Pool Training Platform

**Version:** 2.0.0  
**Status:** MVP Specification  
**Last Updated:** 2026-08-01
**Repository:** https://github.com/anhnpvse02755-png/pool_os_v2

---

## 1. Product Vision

PoolOS_v2 là **AI Pool Training Platform** — không phải app ghi điểm, không phải dashboard thống kê, không phải chatbot.

**Core Philosophy:**
- Pool OS giúp người chơi hiểu: Tôi đang ở trình độ nào? Tôi đang yếu ở đâu? Vì sao tôi yếu? Tôi cần làm gì tiếp theo?
- Coach không chỉ phân tích — Coach còn dẫn người dùng đến đúng chức năng
- Không fake data — hiển thị "Chưa đủ dữ liệu" khi không đủ evidence

**Product Loop:**
```
Collect → Analyze → Understand → Recommend → Train → Improve → repeat...
```

**Tầm nhìn cuối cùng:**
> Pool OS không phải ứng dụng ghi điểm.
> Pool OS là một hệ thống có khả năng học cách bạn chơi bi-a, hiểu điểm mạnh, điểm yếu, thể trạng, tâm lý, thiết bị và quá trình tiến bộ của bạn để trở thành một huấn luyện viên cá nhân, giúp bạn nâng cao trình độ theo thời gian bằng dữ liệu thực tế của chính bạn.

---

## 2. Platform Target

- **Primary Platform:** Mobile (iOS & Android)
- **Framework:** Flutter 3.44.6 with Dart 3.12
- **Architecture:** Modular Monolith with Clean Architecture (Presentation → Domain → Data)
- **State Management:** Riverpod 2.x
- **Navigation:** GoRouter
- **Backend:** Supabase (Auth, Database, Edge Functions)

---

## 3. Domain Architecture

### 3.1 Five Domains (from v1 Constitution)

```
┌─────────────────────────────────────────────────────────────────┐
│                         EXPERIENCE                               │
│   (UI Layer: Screens, Components, Navigation)                │
│   Coach is the CENTER of the application                      │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│      KNOWLEDGE          │     │       EVIDENCE          │
│                         │     │                         │
│ - Techniques            │     │ - Sessions             │
│ - Drills               │     │ - Matches             │
│ - Skills               │     │ - Racks               │
│ - Learning Paths       │     │ - Shots               │
│ - Mistake Graph        │     │ - Events              │
│ - Video Mapping        │     │ - Readiness           │
└─────────────────────────┘     └─────────────────────────┘
              │                               │
              └───────────────┬───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      INTELLIGENCE                               │
│   (Coach Engine, Statistics, Recommendations)                   │
│   - Coach ONLY reads data, never writes                        │
│   - Every insight has: Evidence + Reason + Action             │
│   - Coach acts as Navigation Engine                           │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Domain Ownership

| Domain | Responsibility |
|--------|----------------|
| **Knowledge** | What is teachable (techniques, drills, mistakes, videos) |
| **Evidence** | What was observed (sessions, matches, shots, events) |
| **Intelligence** | What can be inferred (patterns, recommendations) |
| **Experience** | How users interact (screens, coaching flow) |

---

## 4. Player Journey (H1 Design)

### 4.1 Onboarding Flow (6 Screens)

```
Screen 1: WELCOME
"Chào mừng đến với PoolOS"
"Trước khi bắt đầu, hãy để PoolOS hiểu bạn."
[Mất khoảng 2-3 phút]

Screen 2: WHAT WILL I GET?
✓ Xác định trình độ hiện tại của bạn
✓ Tạo giáo trình học riêng phù hợp với bạn
✓ AI phân tích lối chơi và đưa ra gợi ý cải thiện
✓ Theo dõi tiến bộ qua từng trận đấu
✓ Đề xuất video và bài tập phù hợp trình độ
✓ Luyện tập mỗi ngày với kế hoạch rõ ràng

Screen 3: HOW DOES RANKING WORK?
Beginner → K → I → H → G → F
(Mỗi level có mô tả tiếng Việt)

Screen 4-5: 12 ASSESSMENT QUESTIONS (Beginner-friendly)
- Không dùng jargon
- Câu trả lời có điểm số + knowledge mapping
- Confidence calibration để phát hiện over-estimation

Screen 6: YOUR LEVEL + PERSONALIZED LEARNING PATH
- Level với confidence %
- Điểm mạnh / Điểm yếu đã xác định
- Knowledge Graph-based path (không phải list tuyến tính)
- Ước tính giờ để lên level tiếp theo
```

### 4.2 Player Levels

| Level | Vietnamese | Description |
|-------|------------|-------------|
| Beginner | Chưa từng chơi | New to pool |
| K | K | Played but no fundamentals |
| I | I | Basic technique, 2-3 ball runs |
| H | H | Club player, has tactics |
| G | G | Good club player, wins small tournaments |
| F | F | Strong player, competitive |

---

## 5. Core Data Models

### 5.1 Session (Complete)
```typescript
interface Session {
  id: string;
  playerId: string;
  date: Date;
  type: 'practice' | 'tournament' | 'casual';
  
  // Before Match Context
  arrivalTime?: Date;
  warmupDuration?: number;
  warmupDrills?: string[];
  warmupScore?: number;
  
  // Readiness
  readiness: Readiness;
  
  // Matches
  matches: Match[];
  
  // After Match Context
  fatigueLevel: 'none' | 'light' | 'moderate' | 'heavy';
  fatigueLocation?: ('hand' | 'shoulder' | 'wrist' | 'back' | 'eyes')[];
  mentalState: 'very_confident' | 'confident' | 'normal' | 'uncertain' | 'pressured';
  selfRating: 1-5;
  keyFactor?: string;
  
  // Notes
  notes?: string;
  
  // Coach Review (AI-generated from data)
  coachReview?: CoachReview;
}
```

### 5.2 Match
```typescript
interface Match {
  id: string;
  sessionId: string;
  opponent?: string;
  raceTo: number;
  result: 'win' | 'lose' | 'draw';
  racks: Rack[];
  startTime: Date;
  endTime: Date;
  
  // Competition context
  matchType: 'practice' | 'friendly' | 'tournament' | 'league';
  opponentLevel?: 'weaker' | 'equal' | 'stronger';
  
  // Table context
  tableCondition?: 'familiar' | 'unfamiliar';
  environment?: 'home' | 'club' | 'tournament';
  lighting?: 'good' | 'normal' | 'poor';
}
```

### 5.3 Rack
```typescript
interface Rack {
  id: string;
  matchId: string;
  rackNumber: number;
  result: 'win' | 'lose';
  
  // Break
  breakShot: boolean;
  breakSuccess: boolean;
  ballsPottedOnBreak: number;
  
  // Performance
  longestRun: number;
  totalBallsPotted: number;
  safetyPlays: number;
  fouls: number;
  
  // Analysis
  howWon: 'break_run' | 'run_out' | 'opponent_error' | 'safety_win' | 'other';
  biggestMistake?: ShotEvent;
  biggestStrength?: string;
  
  // Confidence at rack end
  confidence: 1-5;
  
  // Notes
  note?: string;
  
  // Shots
  shots: Shot[];
}
```

### 5.4 Shot
```typescript
interface Shot {
  id: string;
  rackId: string;
  
  // What player tried to do
  shotType: ShotType;
  difficulty: 'easy' | 'medium' | 'hard';
  
  // Spin
  spinUsed: SpinType[];
  
  // Result
  result: 'made' | 'missed';
  
  // Events (what went wrong, if any)
  events: ShotEvent[];
  
  // Confidence before shot
  confidence: 1-10;
  
  // Challenge/Goal (Practice mode)
  challenge?: string;
}

type ShotType = 
  | 'pot' | 'safety' | 'break' | 'jump' | 'kick' 
  | 'bank' | 'combo' | 'push_out' | 'masse';

type SpinType = 'top' | 'back' | 'left' | 'right' | 'follow' | 'draw';

type ShotEvent = 
  | 'scratch' | 'foul' | 'double_kiss' | 'jumped_cue'
  | 'easy_miss' | 'wrong_angle' | 'wrong_speed' | 'wrong_spin'
  | 'bridge_unstable' | 'aim_error' | 'deceleration' | 'kick' | 'bad_roll';
```

### 5.5 Coach Recommendation
```typescript
interface CoachRecommendation {
  id: string;
  playerId: string;
  
  // Insight components
  observation: string;      // What was detected
  evidence: EvidenceSummary; // Data backing
  reason: string;          // Why this matters
  dataConfidence: number;    // How reliable this insight is
  
  // Action
  recommendation: string;   // Specific action to take
  expectedResult?: string;   // What improvement to expect
  drillSuggestions: string[];
  
  // Navigation
  actionLabel: string;     // e.g., "Luyện Jump"
  actionRoute: string;       // Navigation target
  
  // Tracking
  priority: 'critical' | 'blocking' | 'improvement' | 'knowledge' | 'positive';
  status: 'active' | 'completed' | 'ignored' | 'expired';
  createdAt: Date;
  validUntil: Date;
}
```

---

## 6. Intelligence Systems

### 6.1 Coach Engine Principles

```
Coach NEVER:
- Stores data
- Modifies data
- Generates fake statistics
- Shows recommendations without evidence

Coach ALWAYS:
- Reads from Statistics Engine
- Provides Evidence + Reason + Action
- Acts as Navigation Engine
- Shows Data Confidence level
```

### 6.2 Intelligence Modules (from Phase 2)

| Module | What it learns |
|--------|----------------|
| **Warm-up Intelligence** | How many racks to peak, warm-up effectiveness |
| **First Rack Effect** | Rack 1-5 accuracy patterns |
| **Muscle Memory** | Time to stabilize performance |
| **Fatigue Model** | Performance degradation over time |
| **Endurance** | Match length optimization |
| **Mental Model** | Confidence, tilt, pressure handling |
| **Shot Learning** | Success/Failure/Reason per shot type |
| **Equipment Intelligence** | Cue impact on performance |
| **Performance Snapshot** | Aggregated player state |

### 6.3 Skill Tree

```
Stop Shot ──┬── Draw
            │
Follow ─────┤
            │
Bank ──────┤
            │
Kick ──────┤
            │
Jump ──────┤
            │
Safety ────┤
            │
Position ───┤
            │
Break ──────┤
            │
Mental ─────┴── Physical
                   │
                   └── Decision
                          │
                          └── Visualization
```

---

## 7. UX Principles

### 7.1 Core Rules

1. **Người dùng không cảm thấy "đang nhập dữ liệu"**
   - Mà cảm thấy "đang ghi lại trận đấu"

2. **Coach là Navigation Engine**
   - Sau mỗi insight luôn có action button
   - Bấm button → đi đến đúng màn hình

3. **Không có dead-end screens**
   - Mỗi màn hình đều hướng đến hành động tiếp theo

4. **Input tối thiểu, AI suy luận tối đa**
   - Ưu tiên: 1 screen → 1 action
   - Không hỏi những gì AI có thể infer

### 7.2 Empty States

| Scenario | Message |
|----------|---------|
| No sessions | "Bắt đầu buổi chơi đầu tiên để AI học về lối chơi của bạn" |
| No data for insight | "Cần thêm dữ liệu để đưa ra khuyến nghị" |
| Insufficient for Coach | "Tôi cần thêm dữ liệu để đánh giá chính xác hơn" |
| First coach insight | "AI đã phân tích xong. Xem khuyến nghị của Coach" |

### 7.3 Coach Communication Style

- **Specific, not generic**: "Trong 30 cú Stop Shot gần nhất, 19 cú đánh quá dày"
- **Evidence-backed**: "Dựa trên 45 cú đánh của bạn..."
- **Actionable**: "Hãy thử..." with [Bắt đầu] button
- **Shows confidence**: "Kỹ thuật Stop Shot rất tốt trong luyện tập. Hiệu quả giảm khi thi đấu."

---

## 8. Feature Roadmap (Tasks 05-15)

### Phase 1 Foundation (MVP)
| Task | Feature | Priority |
|------|---------|----------|
| TBD | Project Setup + Auth | P0 |
| TBD | Database Schema | P0 |
| TBD | Core Recording (Match/Rack/Shot) | P0 |
| TBD | Basic Statistics | P1 |

### Phase 2 Intelligence (Tasks 05-15 from v1)

| Task | Feature | Core Business Value |
|------|---------|---------------------|
| Task 05 | Player Profile | Complete player identity (rank, style, goals, achievements) |
| Task 06 | Match Context | Pre/Post match data collection |
| Task 07 | Warm-up Intelligence | Learning warm-up effectiveness |
| Task 08 | Endurance Intelligence | Match length optimization |
| Task 09 | Training Center | Drill library + progress tracking |
| Task 10 | Goal & Progress | Goal setting + achievement system |
| Task 11 | Player Timeline | Career history + milestones |
| Task 12 | Data Center | Backup/Restore/Export |
| Task 13 | Tournament Management | Tournament + brackets |
| Task 14 | Club & Community | Club management + leaderboards |
| Task 15 | Coach Intelligence V2 | Central coaching engine |

### Phase 3 Learning System (Post-Task 15)

| Component | Description |
|-----------|-------------|
| **Knowledge Graph** | DAG of techniques → drills → statistics |
| **Video Mapping** | Video → Chapter → Timestamp → Knowledge |
| **Mistake Graph** | Mistake → Root Cause → Drill → Video |
| **Learning Path** | Personalized based on level + gaps |
| **Mastery System** | When is a skill considered "mastered" |

---

## 9. Technical Decisions

### 9.1 Stack
- **Frontend:** Flutter 3.44.6 + Dart 3.12
- **Backend:** Supabase
- **State:** Riverpod 2.x (flutter_riverpod)
- **Navigation:** GoRouter
- **UI Components:** Material Design 3 + Custom components
- **Local Storage:** SharedPreferences + Hive (for offline caching)
- **HTTP Client:** Dio

### 9.2 Database Schema (Supabase)

```sql
-- Players (Extended from v1)
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  avatar_url TEXT,
  dominant_hand TEXT CHECK (dominant_hand IN ('left', 'right')),
  current_level TEXT DEFAULT 'beginner',
  target_level TEXT,
  playing_style TEXT[],
  years_playing INTEGER,
  hours_per_week DECIMAL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Player Timeline (NEW)
CREATE TABLE player_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  event_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sessions (Complete)
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  type TEXT CHECK (type IN ('practice', 'tournament', 'casual')),
  
  -- Pre-Match Context
  arrival_time TIMESTAMPTZ,
  warmup_duration INTEGER,
  match_purpose TEXT,
  opponent_type TEXT,
  table_condition TEXT,
  
  -- Readiness
  energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5),
  focus_level INTEGER CHECK (focus_level BETWEEN 1 AND 5),
  confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5),
  
  -- Post-Match Context
  fatigue_level TEXT,
  fatigue_locations TEXT[],
  mental_state TEXT,
  self_rating INTEGER CHECK (self_rating BETWEEN 1 AND 5),
  key_factor TEXT,
  
  -- Meta
  duration_minutes INTEGER,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Matches
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  opponent TEXT,
  race_to INTEGER NOT NULL,
  result TEXT CHECK (result IN ('win', 'lose', 'draw')),
  match_type TEXT DEFAULT 'friendly',
  opponent_level TEXT,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ
);

-- Racks (Enhanced)
CREATE TABLE racks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  rack_number INTEGER NOT NULL,
  result TEXT CHECK (result IN ('win', 'lose')),
  break_shot BOOLEAN DEFAULT FALSE,
  break_success BOOLEAN,
  balls_potted_on_break INTEGER DEFAULT 0,
  longest_run INTEGER DEFAULT 0,
  total_balls_potted INTEGER DEFAULT 0,
  safety_plays INTEGER DEFAULT 0,
  fouls INTEGER DEFAULT 0,
  how_won TEXT,
  biggest_mistake TEXT,
  biggest_strength TEXT,
  confidence INTEGER CHECK (confidence BETWEEN 1 AND 5),
  note TEXT
);

-- Shots (Complete with Events)
CREATE TABLE shots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rack_id UUID REFERENCES racks(id) ON DELETE CASCADE,
  shot_type TEXT NOT NULL,
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  result TEXT CHECK (result IN ('made', 'missed')),
  spin_used TEXT[],
  events TEXT[],
  confidence INTEGER CHECK (confidence BETWEEN 1 AND 5),
  challenge TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Coach Recommendations
CREATE TABLE coach_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  observation TEXT NOT NULL,
  evidence JSONB,
  reason TEXT,
  data_confidence INTEGER,
  recommendation TEXT NOT NULL,
  expected_result TEXT,
  drill_suggestions TEXT[],
  action_label TEXT,
  action_route TEXT,
  priority TEXT DEFAULT 'improvement',
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  valid_until TIMESTAMPTZ
);

-- Goals
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  goal_type TEXT,
  target_value DECIMAL,
  current_value DECIMAL DEFAULT 0,
  deadline DATE,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Achievements
CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  achievement_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  unlocked_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tournaments
CREATE TABLE tournaments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  tournament_type TEXT,
  start_date DATE,
  end_date DATE,
  venue TEXT,
  result TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Clubs
CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  logo_url TEXT,
  venue TEXT,
  description TEXT,
  admin_id UUID REFERENCES players(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Club Members
CREATE TABLE club_members (
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (club_id, player_id)
);

-- Equipment (Enhanced with roles)
CREATE TABLE equipment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT CHECK (type IN ('cue', 'shaft', 'tip', 'other')),
  brand TEXT,
  model TEXT,
  cue_type TEXT CHECK (cue_type IN ('breaking', 'jumping', 'regular')),
  notes TEXT,
  is_active BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Training Sessions
CREATE TABLE training_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  notes TEXT
);

-- Training Drills
CREATE TABLE drill_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES training_sessions(id) ON DELETE CASCADE,
  drill_code TEXT,
  drill_name TEXT NOT NULL,
  category TEXT,
  target_reps INTEGER,
  attempts INTEGER DEFAULT 0,
  successes INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Custom Drills
CREATE TABLE custom_drills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT,
  target_reps INTEGER,
  success_criteria TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Drill Favorites
CREATE TABLE drill_favorites (
  drill_key TEXT NOT NULL,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (drill_key, player_id)
);
```

### 9.3 Row Level Security
- All tables have RLS enabled
- Players can only access their own data
- Club admins can view club member stats

---

## 10. MVP Scope

### Included in MVP (v1.0)
- [ ] Player registration & login (Supabase Auth)
- [ ] Player Profile with timeline
- [ ] Session creation with full context
- [ ] Match recording with rack tracking
- [ ] Shot logging with events
- [ ] Basic statistics calculation
- [ ] Coach dashboard with recommendations
- [ ] Drill library (Knowledge domain)
- [ ] Equipment tracking with roles
- [ ] Goal setting & tracking
- [ ] Achievement system

### Post-MVP
- [ ] Tournament management (Task 13)
- [ ] Club & Community (Task 14)
- [ ] Coach Intelligence V2 (Task 15)
- [ ] Pattern detection engine
- [ ] Training plan generator
- [ ] Video integration
- [ ] Cloud sync & backup

---

## 11. Success Metrics

| Metric | Target |
|--------|--------|
| Session completion rate | >80% |
| Coach recommendation acceptance | >60% |
| Time to log a rack | <30 seconds |
| App retention (7-day) | >40% |
| Sessions per week (active users) | >2 |
| User says "Pool OS understands me" | >80% |

---

## 12. Key Business Principles

1. **Coach không lưu dữ liệu** — chỉ đọc từ Statistics Engine
2. **Không fake data** — hiển thị "Chưa đủ dữ liệu"
3. **Mọi insight phải có Evidence + Reason + Action**
4. **Coach là Navigation Engine** — luôn có next action
5. **Input tối thiểu, AI suy luận tối đa**
6. **Knowledge Graph-based** learning, không phải linear list
7. **Player Journey** quan trọng hơn feature list

---

## 13. References

- Pool OS v1 Architecture Constitution
- Pool OS v1 RFC-010 Coach Engine
- Pool OS v1 Phase 2 Feature Specification
- H1 Player Assessment Design
- Task 05-15 from Pool OS v1 development

---

*This specification is the source of truth for PoolOS_v2 development.*
*Business requirements may evolve — update this document as we learn.*
