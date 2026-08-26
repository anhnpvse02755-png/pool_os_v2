# PoolOS v2 — UI/UX Redesign Design Spec

**Date:** 2026-08-26
**Status:** Draft — Pending User Approval
**Version:** 1.0

---

## 1. Overview

### 1.1 Project Summary

Complete UI/UX redesign of PoolOS v2 — a sports training and competition app for billiards (pool) players of all levels.

### 1.2 Design Philosophy

**Minimalist Luxury** — Flat design, sophisticated, professional sports tech.

> "Less, but better." — Dieter Rams

- **Flat design** — No card borders, no harsh shadows, content-first
- **Premium feel** — Inspired by Linear, Vercel, Apple Fitness, Notion
- **Professional** — Appeals to coaches, serious amateurs, and beginners alike
- **Functional minimalism** — Every element serves a purpose

### 1.3 Target Audience

| Segment | Needs |
|---------|-------|
| **Beginners** | Clear guidance, easy onboarding, simple flows |
| **Amateurs** | Progress tracking, challenges, motivation |
| **Coaches** | Detailed analytics, session history, exportable data |

---

## 2. Design System

### 2.1 Color Palette

#### Light Mode

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#FAFAFA` | Page background |
| `surface` | `#FFFFFF` | Cards, modals, inputs |
| `text-primary` | `#0A0A0A` | Headlines, important text |
| `text-secondary` | `#6B7280` | Descriptions, labels |
| `text-tertiary` | `#9CA3AF` | Hints, placeholders |
| `border` | `#E5E7EB` | Dividers, input borders |
| `border-subtle` | `#F3F4F6` | Hover states, subtle separation |

#### Dark Mode

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0F0F0F` | Page background |
| `surface` | `#18181B` | Cards, modals, inputs |
| `surface-elevated` | `#27272A` | Hover states, elevated cards |
| `text-primary` | `#FAFAFA` | Headlines, important text |
| `text-secondary` | `#A1A1AA` | Descriptions, labels |
| `text-tertiary` | `#71717A` | Hints, placeholders |
| `border` | `#27272A` | Dividers, input borders |
| `border-subtle` | `#3F3F46` | Hover states, subtle separation |

#### Accent Colors (Both Modes)

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `accent` | `#3B82F6` | `#60A5FA` | Primary actions, links |
| `accent-hover` | `#2563EB` | `#93C5FD` | Hover state |
| `accent-subtle` | `#EFF6FF` | `#1E3A5F` | Backgrounds |

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#10B981` | Completed, positive |
| `success-subtle` | `#ECFDF5` / `#064E3B` | Success backgrounds |
| `warning` | `#F59E0B` | Caution, in-progress |
| `warning-subtle` | `#FFFBEB` / `#78350F` | Warning backgrounds |
| `error` | `#EF4444` | Errors, destructive |
| `error-subtle` | `#FEF2F2` / `#7F1D1D` | Error backgrounds |

#### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `gold` | `#F59E0B` | Achievements, premium, streaks |
| `streak` | `#F97316` | Day streaks, fire motif |

### 2.2 Typography

**Font Family:** Plus Jakarta Sans (Google Fonts)

```
Font Stack: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif
```

**Weight Scale:**

| Name | Weight | Usage |
|------|--------|-------|
| Regular | 400 | Body text, descriptions |
| Medium | 500 | Labels, subtitles, button text |
| SemiBold | 600 | Headings, section titles |
| Bold | 700 | Display numbers, hero text |

**Type Scale:**

| Token | Size | Height | Weight | Usage |
|-------|------|--------|--------|-------|
| `display` | 32px | 1.2 | 700 | Hero numbers, big stats |
| `h1` | 24px | 1.3 | 600 | Page titles |
| `h2` | 20px | 1.4 | 600 | Section titles |
| `h3` | 16px | 1.4 | 600 | Card titles |
| `body-lg` | 16px | 1.5 | 400 | Important body text |
| `body` | 14px | 1.5 | 400 | Default body text |
| `caption` | 12px | 1.4 | 400 | Timestamps, metadata |
| `label` | 11px | 1.2 | 500 | Category labels, tabs (uppercase, letter-spacing: 0.5px) |

### 2.3 Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Icon padding, micro spacing |
| `space-2` | 8px | Element internal padding |
| `space-3` | 12px | List item padding |
| `space-4` | 16px | Section padding, standard gap |
| `space-5` | 20px | Comfortable padding |
| `space-6` | 24px | Section margins |
| `space-8` | 32px | Large section gaps |
| `space-12` | 48px | Hero margins, page padding |
| `space-16` | 64px | Empty states, major separations |

### 2.4 Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 6px | Buttons, inputs |
| `radius-md` | 8px | Cards, modals |
| `radius-lg` | 12px | Large cards, sheets |
| `radius-full` | 9999px | Pills, avatars |

### 2.5 Elevation (Shadows)

**Light Mode:**

```css
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.07);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.08);
```

**Dark Mode:**

```css
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.4);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.5);
```

### 2.6 Motion & Animation

**Philosophy:** Motion is functional, not decorative. It provides feedback and context, not entertainment.

**Duration Scale:**

| Token | Duration | Usage |
|-------|----------|-------|
| `duration-instant` | 0ms | State-only changes |
| `duration-fast` | 100ms | Button press, toggle |
| `duration-normal` | 200ms | Standard transitions |
| `duration-slow` | 300ms | Page transitions, modals |

**Easing:**

```css
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);      /* Smooth deceleration */
--ease-in: cubic-bezier(0.7, 0, 0.84, 0);       /* Smooth acceleration */
--ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);  /* Balanced */
--ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1); /* Success feedback */
```

**Micro-interactions at Key Touch Points:**

1. **Button Press**
   - Scale down to 0.97 on press
   - Duration: 100ms
   - Easing: ease-out

2. **Success Feedback**
   - Green pulse animation on completion
   - Duration: 300ms
   - Easing: ease-bounce

3. **Page Transition**
   - Fade + slight slide (8px)
   - Duration: 200ms
   - Direction: forward (slide left), back (slide right)

4. **List Item Appearance**
   - Stagger fade-in (50ms delay between items)
   - Duration: 200ms per item
   - Easing: ease-out

5. **Progress Bar Fill**
   - Smooth width transition
   - Duration: 300ms
   - Easing: ease-out

**Reduced Motion:**
Respect `prefers-reduced-motion`. When enabled, disable all animations except essential state feedback (button press scale).

### 2.7 Icons

**Style:** Outlined, 24px default, 1.5px stroke weight

**Icon Set:** Lucide Icons (or similar open-source icon library)

**Principles:**
- Consistent 24px size for navigation
- 20px for inline/list icons
- 16px for small indicators
- Use `Icons` class from Material for built-in icons
- Custom SVG for logo only

---

## 3. Logo & Branding

### 3.1 Logo Concept

**Name:** PoolOS (or new name TBD)

**Concept:** Minimal mark representing pool/billiards
- Abstract representation of cue ball trajectory
- Clean, geometric, memorable
- Works in single color (monochrome)

**Design Direction:**

```
Option A: Abstract trajectory line
┌─────────────────────────────┐
│                             │
│      ●──────────────        │  ← Cue ball path
│              ↘             │
│                             │
└─────────────────────────────┘

Option B: Minimalist table corner
┌─────────────────────────────┐
│  ╲                         │
│    ╲  ○                    │  ← Corner pocket + ball
│      ╲                     │
│                             │
└─────────────────────────────┘

Option C: Typography-focused
┌─────────────────────────────┐
│                             │
│       POOL                   │
│         OS                   │
│                             │
└─────────────────────────────┘
```

**Final Selection:** TBD based on user feedback

### 3.2 Logo Usage

| Context | Size | Treatment |
|---------|------|-----------|
| App header | 120px width | Full logo |
| Splash screen | 80px width | Full logo |
| Favicon | 32px | Mark only |
| Empty state illustrations | 48px | Mark only |
| Bottom sheet drag handle | 40px | Mark only |

---

## 4. Layout & Structure

### 4.1 Page Architecture

**Shell:**
```
┌─────────────────────────────────────────────────────┐
│  [App Bar - contextual, minimal]                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│                                                     │
│  [Content Area - full bleed]                       │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
├─────────────────────────────────────────────────────┤
│  [Bottom Navigation - 4 tabs]                      │
└─────────────────────────────────────────────────────┘
```

**Content Area:**
- Full-bleed background (no card borders)
- Content contained by page padding (16px horizontal)
- Sections separated by space, not lines

### 4.2 Bottom Navigation

**4 Tabs (Current 5 → 4):**

| Tab | Icon | Label | Route |
|-----|------|-------|-------|
| Home | `home` | Home | `/home` |
| Train | `target` | Train | `/training` |
| Progress | `chart` | Progress | `/progress` |
| Profile | `user` | Profile | `/profile` |

**Design States:**

```
Active:
┌───────┐
│  🏠   │  ← Filled icon
│  Home │  ← Label visible, accent color
│  ───  │  ← Accent underline (2px)
└───────┘

Inactive:
┌───────┐
│  🎯   │  ← Outlined icon
│  Train │  ← Label visible, muted color
│       │  ← No underline
└───────┘
```

### 4.3 App Bar

**Standard:**
```
┌─────────────────────────────────────────────────────┐
│  ←  Page Title                        🔔  ⋮        │
└─────────────────────────────────────────────────────┘
```

- Back arrow: 24px, leads back or closes
- Title: `h2` style, left-aligned
- Actions: Icons only, 24px, right-aligned
- No elevation/shadow (flat)

### 4.4 Responsive Behavior

**Breakpoints:**
- Mobile: < 640px (default, single column)
- Tablet: 640px - 1024px (wider content, same layout)
- Desktop: > 1024px (max-width container, centered)

**Desktop Behavior:**
- Content max-width: 640px
- Centered horizontally
- Bottom navigation stays visible
- Side margins auto

---

## 5. Screen Designs

### 5.1 Home Screen

**Purpose:** Dashboard overview, daily motivation, quick access

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  PoolOS                               🔔            │  ← Minimal header
├─────────────────────────────────────────────────────┤
│                                                     │
│  Good morning, [Name] 👋                          │  ← Personal greeting
│  Ready to improve your game?                      │  ← Motivational subtitle
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │  TODAY'S TRAINING                           │  │  ← Section (label style)
│  │                                             │  │
│  │  Straight Shot                   5/10 reps  │  │  ← Drill name + progress
│  │  ████████████░░░░░░░░░░░░░░░  50%         │  │  ← Progress bar
│  │                                             │  │
│  │  Stop Ball                     8/10 reps    │  │
│  │  ████████████████████░░░░░░░  80%         │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │  QUICK ACTIONS                              │  │
│  │                                             │  │
│  │  ▶  Start Training Session →                │  │  ← Action items
│  │  ▶  Continue Last Drill →                   │  │
│  │  ▶  Daily Challenge →                      │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │  YOUR STATS                      View All → │  │
│  │                                             │  │
│  │     127        72%          8            │  │
│  │  Sessions   Accuracy     Day Streak        │  │  ← Big stat numbers
│  └─────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Components:**

1. **Greeting Section**
   - Dynamic greeting based on time of day
   - User name or "there" if no profile
   - Motivational subtitle

2. **Today's Training Card**
   - Section label (uppercase, muted)
   - List of today's recommended drills
   - Progress indicator per drill
   - Tappable → opens drill detail

3. **Quick Actions Card**
   - List of common actions
   - Arrow indicator for navigation
   - Flat button style

4. **Stats Card**
   - Key metrics with large numbers
   - "View All" link to progress page
   - Minimal labels

### 5.2 Training Screen

**Purpose:** Browse and access all training content

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  Train                                              │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [🔍 Search drills...]                            │  ← Minimal search
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  RECENT                                             │
│  Straight Shot (Basic)                  ▸          │  ← List item with arrow
│  Last practiced 2 days ago                          │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  AIMING                                             │
│  ┌─────────────────────────────────────────────┐  │
│  │  Straight Shot                               │  │  ← Expandable category
│  │  8 drills                                    │  │
│  │                                        ▼     │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │  Ball Control                               │  │
│  │  6 drills                                   │  │
│  │                                        ▶     │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  SAFETY PLAY                                        │
│  ...                                                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Components:**

1. **Search Bar**
   - Outlined style, subtle
   - Placeholder: "Search drills..."
   - Filter icon if needed

2. **Recent Section**
   - Last 3-5 practiced drills
   - Shows last practiced date

3. **Category Accordion**
   - Expandable/collapsible
   - Shows drill count
   - Tap header to expand
   - Tap → opens drill list

4. **Drill List Item**
   - Drill name
   - Level indicator (if applicable)
   - Right arrow for navigation

### 5.3 Drill Detail Screen

**Purpose:** View drill details and start practice

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  ←  Drill Detail                                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Straight Shot                                     │  ← Title
│  Aiming • Beginner                                 │  ← Meta info
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │                                             │  │
│  │         [Drill Illustration]               │  │  ← Visual (SVG/image)
│  │                                             │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  Description                                       │
│  ─────────────────────────────────────────────────  │
│  Master the fundamentals of aiming by pocketing    │
│  balls from a fixed position. This drill builds    │
│  hand-eye coordination and cue control.            │
│                                                     │
│  Levels                                            │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Level 1: 10 reps • Easy                          │
│  Level 2: 12 reps • Medium                        │
│  Level 3: 15 reps • Hard                          │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Tips                                              │
│  ─────────────────────────────────────────────────  │
│  • Keep your bridge hand stable                    │
│  • Follow through after each shot                 │
│  • Focus on the target spot, not the cue ball     │
│                                                     │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │           START TRAINING                    │  │  ← Primary CTA
│  └─────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Components:**

1. **Header Info**
   - Title + subtitle
   - Category breadcrumb

2. **Visual**
   - Drill illustration/diagram
   - Full-width, subtle border-radius

3. **Description**
   - Body text
   - Clear, concise

4. **Levels List**
   - Tappable rows
   - Shows reps + difficulty
   - Selected state for chosen level

5. **Tips**
   - Bulleted list
   - Muted text color

6. **CTA Button**
   - Full-width
   - Accent color
   - Fixed at bottom

### 5.4 Drill Session Screen (Recording)

**Purpose:** Practice a drill and record attempts

**Layout (Active Session):**
```
┌─────────────────────────────────────────────────────┐
│  ←  Straight Shot                        ⏹️       │  ← Stop button
├─────────────────────────────────────────────────────┤
│                                                     │
│                                                     │
│                                                     │
│                    5 / 10                          │  ← Huge display number
│                    reps                             │
│                                                     │
│              ─────────────────────                  │
│                                                     │
│               72% accuracy                         │  ← Secondary stat
│               4 successful                        │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │              ✓  SUCCESS                     │  │  ← Green, full-width
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │              ✗  MISS                         │  │  ← Red, full-width
│  └─────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Components:**

1. **Header**
   - Drill name
   - Stop/end button (top right)

2. **Progress Display**
   - Large current/target format (5/10)
   - Circular or linear progress indicator
   - Accuracy percentage
   - Success count

3. **Recording Buttons**
   - Full-width, stacked
   - Success: Green background
   - Miss: Red background
   - Large touch targets (min 56px height)

4. **Feedback Animation**
   - Brief flash on button press
   - Color matches result

### 5.5 Progress Screen

**Purpose:** View training history and analytics

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  Progress                                           │
├─────────────────────────────────────────────────────┤
│                                                     │
│  THIS WEEK                              Today ▼     │  ← Time filter
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │                                             │  │
│  │        ▃▅▃▅▃▅▇▅▃▅▃                       │  │  ← Weekly bar chart
│  │        M   T   W   T   F   S   S           │  │
│  │                                             │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  Summary                                            │
│  ─────────────────────────────────────────────────  │
│                                                     │
│     12         78%         5.2h                  │  ← Big stats row
│  Sessions   Accuracy     Total Time                │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  ACHIEVEMENTS                              View All │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  🏆 First Session      ✅ 7-Day Streak            │  ← Achievement badges
│  🎯 100 Reps          🔥 30-Day Streak            │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  RECENT ACTIVITY                                    │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Today, 2:30 PM                                    │
│  Straight Shot — Level 1                10/10 reps │
│  90% accuracy                                     │
│                                                     │
│  Yesterday, 4:15 PM                                │
│  Stop Ball — Level 2                   8/12 reps  │
│  67% accuracy                                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Components:**

1. **Time Filter**
   - Dropdown or tabs (Week/Month/Year/All)
   - Default: This Week

2. **Activity Chart**
   - Bar chart showing daily sessions
   - Simple, no gridlines
   - Touch to see day details

3. **Summary Stats**
   - 3-4 key metrics
   - Large numbers + labels

4. **Achievements Section**
   - Grid of earned badges
   - Muted/greyscale for unearned

5. **Activity List**
   - Chronological
   - Shows drill, level, reps, accuracy
   - Relative timestamps

### 5.6 Profile Screen

**Purpose:** User settings and account management

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  Profile                                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │  ┌─────┐                                    │  │
│  │  │ 😊 │  Viet Anh                          │  │  ← Avatar + Name
│  │  └─────┘  Level 5 • Pool Player            │  │
│  │               Edit Profile →                 │  │
│  └─────────────────────────────────────────────┘  │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  EQUIPMENT                                         │
│  ─────────────────────────────────────────────────  │
│  Cue: Predator Sport       ───────────────    ▸   │
│  Tip: Kamui Soft          ───────────────    ▸   │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  SETTINGS                                          │
│  ─────────────────────────────────────────────────  │
│  Dark Mode                               [Toggle]   │
│  Notifications                          [Toggle]   │
│  Sound Effects                         [Toggle]   │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  SUPPORT                                           │
│  ─────────────────────────────────────────────────  │
│  Help & FAQ                              ▸         │
│  Contact Us                               ▸         │
│  Privacy Policy                          ▸         │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │              Sign Out                        │  │  ← Destructive action
│  └─────────────────────────────────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Components:**

1. **Profile Header**
   - Avatar (circular, 64px)
   - Name + level/title
   - Edit link

2. **Equipment Section**
   - Current gear list
   - Editable

3. **Settings Section**
   - Toggle switches for preferences
   - Standard list items for navigation

4. **Support Section**
   - Help links
   - Legal links

5. **Sign Out**
   - Bottom, destructive style
   - Confirmation dialog

---

## 6. Component Library

### 6.1 Buttons

**Primary Button:**
```
┌─────────────────────────────────────────────┐
│           START TRAINING                    │  ← White text on accent
└─────────────────────────────────────────────┘
Height: 52px
Background: accent
Text: white, medium weight
Radius: radius-sm (6px)
```

**Secondary Button:**
```
┌─────────────────────────────────────────────┐
│           View Details                      │
└─────────────────────────────────────────────┘
Height: 44px
Background: transparent
Border: 1px solid border color
Text: text-primary, medium weight
Radius: radius-sm (6px)
```

**Destructive Button:**
```
┌─────────────────────────────────────────────┐
│              Sign Out                       │
└─────────────────────────────────────────────┘
Height: 44px
Background: transparent
Text: error color, medium weight
```

**Button States:**
- Default: Base styles
- Hover: Slight background darken (5%)
- Press: Scale to 0.97, darken 10%
- Disabled: 50% opacity, no interaction

### 6.2 Cards

**Card (Light Mode):**
```
┌─────────────────────────────────────────────┐
│  Content here                              │
└─────────────────────────────────────────────┘
Background: surface (#FFFFFF)
Radius: radius-md (8px)
Shadow: shadow-sm
Padding: space-4 (16px)
```

**Card (Dark Mode):**
```
┌─────────────────────────────────────────────┐
│  Content here                              │
└─────────────────────────────────────────────┘
Background: surface (#18181B)
Radius: radius-md (8px)
Shadow: shadow-sm
Padding: space-4 (16px)
```

**Card States:**
- Default: As above
- Hover (if interactive): surface-elevated background
- Press: Scale to 0.99

### 6.3 Input Fields

**Text Input:**
```
┌─────────────────────────────────────────────┐
│  Label                                       │
│  ┌─────────────────────────────────────┐    │
│  │  Input text here...                  │    │
│  └─────────────────────────────────────┘    │
│  Helper text or error message               │
└─────────────────────────────────────────────┘
```

**States:**
- Default: border color
- Focus: accent border (2px)
- Error: error border, error message below
- Disabled: muted background, no interaction

### 6.4 List Items

**Standard List Item:**
```
┌─────────────────────────────────────────────┐
│  Icon  Item Title                     ▸    │
│        Subtitle or description              │
└─────────────────────────────────────────────┘
Height: auto (min 56px for touch)
Padding: space-3 (12px) vertical
Divider: border-subtle (bottom)
```

### 6.5 Progress Indicators

**Linear Progress Bar:**
```
████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
```
Height: 8px
Radius: radius-full
Background: border color
Fill: accent color
Animation: width transition 300ms

**Circular Progress:**
```
┌─────────┐
│    ╭─╮  │
│   │  │  │
│    ╰─╯  │
│   72%   │
└─────────┘
Stroke: 4px
Size: 80px default
Animation: stroke-dashoffset transition

```

### 6.6 Toggles

**Toggle Switch:**
```
┌─────────────────────────────────────────────┐
│  Label                              [═══●]  │
└─────────────────────────────────────────────┘
Size: 52x28px
Track off: border color
Track on: accent
Knob: white, 24px
Animation: 200ms ease

```

---

## 7. Dark Mode Implementation

### 7.1 Theme Switching

**User Preference:**
- Toggle in Profile settings
- Default: System preference
- Persist choice in local storage

**Implementation:**
- Use Flutter's `ThemeMode` (light/dark/system)
- All colors via theme tokens (no hardcoded)
- Transition: 200ms fade

### 7.2 Color Adjustments

All semantic colors adjust for dark mode:

| Element | Light | Dark |
|---------|-------|------|
| Background | #FAFAFA | #0F0F0F |
| Surface | #FFFFFF | #18181B |
| Text Primary | #0A0A0A | #FAFAFA |
| Text Secondary | #6B7280 | #A1A1AA |
| Borders | #E5E7EB | #27272A |
| Accent | #3B82F6 | #60A5FA |

---

## 8. Accessibility

### 8.1 Color Contrast

- All text meets WCAG AA (4.5:1 for body, 3:1 for large text)
- Accent color on background: 4.5:1 minimum
- Error color on white/dark: 4.5:1 minimum

### 8.2 Touch Targets

- Minimum 44x44px for all interactive elements
- Adequate spacing between touch targets (8px minimum)

### 8.3 Motion

- Respect `prefers-reduced-motion`
- Essential feedback only when reduced motion enabled

### 8.4 Screen Reader

- Semantic widget types
- Meaningful labels for icons
- Progress announcements for dynamic content

---

## 9. Animation Details

### 9.1 Page Transitions

```dart
// Forward navigation (push)
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOut,
  )),
  child: page,
)

// Duration: 200ms
```

### 9.2 Button Press

```dart
// Scale down on press
Transform.scale(
  scale: isPressed ? 0.97 : 1.0,
  child: button,
)
// Duration: 100ms
// Curve: easeOut
```

### 9.3 List Item Stagger

```dart
// Staggered fade-in
FadeTransition(
  opacity: animation,
  child: SlideTransition(
    position: Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(animation),
    child: item,
  ),
)
// Delay: index * 50ms
// Duration: 200ms
```

### 9.4 Success Feedback

```dart
// Brief green flash on success
Container(
  color: Colors.green.withOpacity(flashValue),
)
// Duration: 300ms
// Curve: easeBounce
```

---

## 10. File Structure

### 10.1 New/Modified Files

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart          # Main theme definition
│   │   ├── colors.dart             # Color tokens
│   │   ├── typography.dart         # Text styles
│   │   ├── spacing.dart            # Spacing constants
│   │   └── shadows.dart            # Elevation definitions
│   └── router/
│       └── app_router.dart         # Navigation routes
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart    # Redesigned home
│   │   ├── training/
│   │   │   ├── training_center_screen.dart
│   │   │   ├── drill_list_screen.dart
│   │   │   ├── drill_detail_screen.dart
│   │   │   └── drill_session_screen.dart
│   │   ├── progress/
│   │   │   └── progress_screen.dart # NEW - was analysis
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── shell/
│   │       └── main_shell.dart     # Redesigned navigation
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── destructive_button.dart
│   │   ├── cards/
│   │   │   └── app_card.dart
│   │   ├── inputs/
│   │   │   └── app_text_field.dart
│   │   ├── progress/
│   │   │   ├── linear_progress.dart
│   │   │   └── circular_progress.dart
│   │   └── navigation/
│   │       └── bottom_nav.dart
│   └── assets/
│       ├── logo.svg                # NEW logo
│       └── icons/                  # Custom icons if needed
```

### 10.2 Implementation Order

1. **Design System** (Foundation)
   - Colors, typography, spacing tokens
   - Theme configuration
   - Button components
   - Card components

2. **Navigation Shell**
   - Bottom navigation redesign
   - App bar standardization

3. **Home Screen**
   - Complete redesign
   - All sections

4. **Training Screens**
   - Training center
   - Drill list
   - Drill detail
   - Drill session

5. **Progress Screen**
   - New screen (from analysis)
   - Charts, stats

6. **Profile Screen**
   - Redesign existing
   - Settings

7. **Polish**
   - Dark mode toggle
   - Animations
   - Accessibility pass

---

## 11. Open Questions (Pending User Input)

1. **Logo Selection:** Which logo concept do you prefer? (A, B, C, or other)

2. **Color Palette:** Is the accent blue (#3B82F6) acceptable? Or do you prefer another color direction?

3. **Feature Additions:** Any new features to add during redesign? Or focus only on visual?

4. **Content:** Any existing content/copy to preserve vs. rewrite?

---

## 12. Approval Checklist

Before implementation, confirm:

- [ ] Logo concept approved
- [ ] Color palette approved
- [ ] Layout structure approved
- [ ] Component designs approved
- [ ] Animation approach approved
- [ ] Dark mode direction approved
- [ ] No missing screens or features

---

*Document Status: Draft — Awaiting User Review*
