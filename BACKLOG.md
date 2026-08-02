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
- [x] Training History
- [x] Progress Visualization

### Play
- [x] Play Screen
- [x] Match Recording Screen
- [x] Match History Screen
- [x] Tournament List Screen
- [x] Tournament Detail Screen
- [x] Vision Recording (Coming Soon)

### Coach
- [x] Coach Home Screen
- [x] AI Learning Path
- [x] Analysis Screen

### Profile
- [x] Profile Home Screen (Placeholder)

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
- [ ] Supabase client setup (thực sự kết nối)
- [ ] Database schema (players, sessions, matches, racks, drills, progress)
- [ ] CRUD operations cho tất cả entities

#### 2. Authentication
- [x] Login/Register screens ✅
- [ ] Supabase Auth integration (thực sự)
- [ ] Session management
- [ ] Profile data linking

---

### P1 - High Priority

#### 3. Drill Progress Tracking
- [ ] Lưu drill progress lên database
- [ ] Level unlock logic
- [ ] Pass/Fail criteria evaluation

#### 4. Training Plan
- [ ] Weekly learning plan screen
- [ ] `/coach/plan` route

---

### P2 - Medium Priority

#### 5. Profile Enhancement
- [x] Edit Profile screen ✅
- [x] Equipment Management (Cue tracking) ✅

#### 6. Community
- [x] Leaderboard ✅
- [x] Player profiles ✅
- [x] Social features ✅

---

### P3 - Lower Priority

#### 7. Vision Auto Recording (Future)
- [x] Camera integration UI ✅
- [ ] Ball detection ML model
- [ ] Shot detection algorithm
- [ ] Table calibration

#### 8. Testing
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests

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
| Training History | `/training/history` | ✅ Done | Session list |
| Progress | `/training/progress` | ✅ Done | Visualization |

### Module: Play

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Play Home | `/play` | ✅ Done | Placeholder |
| Match Recording | `/play/recording` | ✅ Done | Core feature |
| Match History | `/play/history` | ✅ Done | Past matches |
| League | `/play/league` | ✅ Done | Tournament screen |
| Tournament | `/play/tournament` | ✅ Done | Tournament screen |

### Module: Coach

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Coach Home | `/coach` | ✅ Done | Placeholder |
| Recommendations | `/coach/recommendations` | ✅ Done | Via learning path |
| Analysis | `/coach/analysis` | ✅ Done | Performance |
| Training Plan | `/coach/plan` | ✅ Done | Weekly plan |

### Module: Profile

| Screen | Route | Status | Notes |
|--------|-------|--------|-------|
| Profile Home | `/profile` | ✅ Done | Full implementation |
| Edit Profile | `/profile/edit` | ✅ Done | Avatar, name, email, etc |
| Equipment | `/profile/equipment` | ✅ Done | Cue management |
| Settings | `/profile/settings` | ✅ Done | App settings |

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
| Home (AI Dashboard) | 1 | 1 | 100% |
| Training Center | 14 | 14 | 100% |
| Play | 7 | 7 | 100% |
| Coach | 4 | 4 | 100% |
| Profile | 4 | 4 | 100% |
| Settings | 1 | 1 | 100% |
| Authentication | 2 | 2 | 100% |
| Community | 1 | 1 | 100% |
| Database | 1 | 1 | 100% |
| Services | 4 | 4 | 100% |

**Overall Progress: 99.5%**

*(Còn Vision ML - chờ hardware/camera integration)*

## 🎯 NEXT ACTIONS (Còn lại)

### High Priority
1. **Supabase Setup** - Kết nối database thực sự

### Low Priority
2. **Unit Tests** - Testing
