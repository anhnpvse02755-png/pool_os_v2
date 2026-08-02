# PoolOS v2 - Backlog Chức năng

**Updated:** 2026-08-02
**Status:** In Progress

---

## ✅ ĐÃ HOÀN THÀNH

### Onboarding
- [x] Welcome Screen
- [x] Onboarding Screen
- [x] Interest Selection Screen

### Navigation
- [x] Main Shell với Bottom Navigation
- [x] Router với GoRouter

### Home
- [x] Home Screen với Quick Actions

### Training Center
- [x] Training Center Home Screen
- [x] Drill Categories List
- [x] Drill List (tabs: Recommended/All, filters, search)
- [x] Drill Detail Screen (levels, setup, steps, knowledge link)
- [x] Drill Session Screen (manual recording)
- [x] Drill Result Screen
- [x] Drill Library với 6 categories, 15+ drills, 5 levels each
- [x] AI Learning Path (Coach Service + Screen)
- [x] Knowledge Library (5 categories, 10+ articles)
- [x] Skill Certification (5 certifications)

### Play
- [x] Play Screen (placeholder)
- [x] Match Recording Screen

### Authentication
- [x] Login Screen
- [x] Register Screen

### Database & Services
- [x] Database Schema (Supabase migrations)
- [x] Auth Service
- [x] Player Service
- [x] Training Service
- [x] Coach Service
- [x] Riverpod Providers

---

## 📋 CHƯA LÀM - Theo thứ tự ưu tiên

### P0 - Critical (Cần làm ngay)

#### 1. Database & Supabase Integration
- [ ] Supabase client setup
- [ ] Database schema (players, sessions, matches, racks, drills, progress)
- [ ] CRUD operations cho tất cả entities

#### 2. Authentication
- [ ] Login/Register screens
- [ ] Supabase Auth integration
- [ ] Session management
- [ ] Profile data linking

#### 3. Drill Progress Tracking
- [ ] Lưu drill progress lên database
- [ ] Level unlock logic (hoàn thành Lv1 → mở Lv2)
- [ ] Pass/Fail criteria evaluation
- [ ] Progress visualization

#### 4. Drill Session Recording
- [ ] Save drill sessions to database
- [ ] Track attempts, successes, failures
- [ ] Calculate pass/fail dựa trên criteria
- [ ] Session history

---

### P1 - High Priority

#### 5. AI Learning Path
- [ ] Generate recommendations based on:
  - User's interest (từ onboarding)
  - Performance data (weaknesses)
  - Rank/level
- [ ] Weekly learning path display
- [ ] Follow AI / Skip AI actions

#### 6. Knowledge Library
- [ ] Knowledge List Screen
- [ ] Knowledge Detail Screen
- [ ] Knowledge-Drill linking
- [ ] Categories: Aiming, Draw, Follow, Bank, Kick, Jump, Masse, Safety, Bridge, Psychology, Strategy, Equipment

#### 7. Skill Certification
- [ ] Certification List Screen
- [ ] Certification Test Screen
- [ ] Results tracking
- [ ] Certificate display

#### 8. Match Recording (Play Module)
- [ ] Quick Match setup
- [ ] Match Recording Screen
- [ ] Rack recording (Win/Lose, balls potted, errors)
- [ ] Match Summary (auto-generated)
- [ ] Match history

---

### P2 - Medium Priority

#### 9. Coach AI
- [ ] Coach Screen
- [ ] Performance analysis
- [ ] Recommendations generation
- [ ] Weakness identification
- [ ] Improvement suggestions

#### 10. Statistics Engine
- [ ] Training statistics (drill success rates)
- [ ] Match statistics (win rate, largest run)
- [ ] Combined statistics (real accuracy)
- [ ] Trend analysis
- [ ] Charts & visualizations

#### 11. Profile Screen
- [ ] User profile display
- [ ] Edit profile
- [ ] Equipment management
- [ ] Settings

#### 12. Progress Tracking
- [ ] Overall progress visualization
- [ ] Drill completion status
- [ ] Achievement badges
- [ ] Streak tracking

---

### P3 - Lower Priority

#### 13. Play Module Expansion
- [ ] Friendly Match (2 players)
- [ ] League management
- [ ] Tournament bracket
- [ ] Challenge system

#### 14. Community (Future)
- [ ] Player profiles
- [ ] Social features
- [ ] Leaderboards

#### 15. Knowledge Expansion
- [ ] Video content
- [ ] Interactive tutorials
- [ ] Expert tips

#### 16. Vision Auto Recording (Future)
- [ ] Camera integration
- [ ] Ball detection ML model
- [ ] Shot detection algorithm
- [ ] Table calibration

---

## 🗂️ CHI TIẾT THEO MODULE

### Module: Training Center

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Training Center Home | `/training` | ✅ Done | |
| AI Learning Path | `/training/path` | ✅ Done | AI recommendations |
| Drill Categories | `/training/drills` | ✅ Done | |
| Drill List | `/training/drills/:id` | ✅ Done | Tabs, filters, search |
| Drill Detail | `/training/drill/:code` | ✅ Done | Levels, setup, steps |
| Drill Session | `/training/session/new` | ✅ Done | Manual recording UI |
| Drill Result | `/training/session/result` | ✅ Done | |
| Knowledge | `/training/knowledge` | ✅ Done | Library screen |
| Knowledge Detail | `/training/knowledge/:id` | ✅ Done | Article view |
| Skill Certification | `/training/certification` | ✅ Done | List screen |
| Skill Test | `/training/certification/:id` | ✅ Done | Test detail |
| Training History | `/training/history` | 📋 TODO | Session list |
| Progress | `/training/progress` | 📋 TODO | Visualization |

### Module: Play

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Play Home | `/play` | ✅ Done | Placeholder |
| Match Recording | `/play/recording` | ✅ Done | Core feature |
| Match History | `/play/history` | 📋 TODO | Past matches |
| League | `/play/league` | 📋 TODO | Future |
| Tournament | `/play/tournament` | 📋 TODO | Future |

### Module: Coach

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Coach Home | `/coach` | ✅ Done | Placeholder |
| Recommendations | `/coach/recommendations` | ✅ Done | Via learning path |
| Analysis | `/coach/analysis` | 📋 TODO | Performance |
| Training Plan | `/coach/plan` | 📋 TODO | Weekly plan |

### Module: Profile

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Profile Home | `/profile` | ✅ Done | Placeholder |
| Edit Profile | `/profile/edit` | 📋 TODO | |
| Equipment | `/profile/equipment` | 📋 TODO | Cue management |
| Settings | `/profile/settings` | 📋 TODO | App settings |

### Module: Authentication

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Welcome | `/welcome` | ✅ Done | |
| Onboarding | `/onboarding` | ✅ Done | |
| Interest Selection | `/onboarding/interests` | ✅ Done | |
| Login | `/auth/login` | ✅ Done | |
| Register | `/auth/register` | ✅ Done | |

---

## 🔧 TECHNICAL TASKS

### Database Schema
- [ ] `players` table
- [ ] `training_sessions` table
- [ ] `training_progress` table
- [ ] `drill_attempts` table
- [ ] `matches` table
- [ ] `racks` table
- [ ] `knowledge` table
- [ ] `certifications` table
- [ ] `equipment` table

### State Management
- [ ] Auth state provider
- [ ] User profile provider
- [ ] Training progress provider
- [ ] Session state provider
- [ ] Coach recommendations provider

### API Services
- [ ] Auth service
- [ ] Player service
- [ ] Training service
- [ ] Match service
- [ ] Coach service
- [ ] Knowledge service

### Testing
- [ ] Unit tests cho business logic
- [ ] Widget tests cho UI components
- [ ] Integration tests cho flows

---

## 📊 PROGRESS SUMMARY

| Module | Completed | Total | Percentage |
|--------|-----------|-------|------------|
| Onboarding | 3 | 3 | 100% |
| Navigation | 2 | 2 | 100% |
| Home | 1 | 1 | 100% |
| Training Center | 12 | 13 | 92% |
| Play | 2 | 5 | 40% |
| Coach | 1 | 4 | 25% |
| Profile | 1 | 4 | 25% |
| Authentication | 2 | 2 | 100% |
| Database | 1 | 1 | 100% |
| Services | 4 | 4 | 100% |

**Overall Progress: ~75%**

## 🎯 NEXT ACTIONS

### P2 - Medium Priority
1. **Training History** - Xem lịch sử luyện tập
2. **Progress Visualization** - Biểu đồ tiến bộ
3. **Match History** - Lịch sử trận đấu
4. **Coach Analysis** - Phân tích chi tiết
5. **Profile Enhancement** - Profile screen đầy đủ

### P3 - Lower Priority
1. **League System** - Hệ thống giải đấu
2. **Tournament** - Giải đấu
3. **Vision Auto Recording** - Camera integration
4. **Community** - Social features

---

## 🎯 NEXT ACTIONS

1. **Supabase Setup** - Database schema + client
2. **Auth Integration** - Login/Register flows
3. **Training Persistence** - Save drill progress
4. **AI Learning Path** - Recommendation engine
5. **Match Recording** - Core Play feature
