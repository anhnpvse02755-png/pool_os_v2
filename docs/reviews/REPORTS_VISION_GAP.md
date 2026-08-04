# Reports — Vision Gap Analysis

**Source of truth:** vision.

---

## 1. Question

> What would a coach-grade reports suite look like in the world's best
> billiards training app?

Every report should answer one specific question the player / coach asks.

---

## 2. Report taxonomy `[C]`

| Report | Audience | Question answered | Status |
|--------|----------|-------------------|--------|
| Match report | Player / Coach | What happened in this match? | ✅ |
| Weekly report | Player | How am I trending this week? | ❌ |
| Monthly report | Player | What's my month-over-month delta? | ❌ |
| Season report | Player / Coach | Quarter or year? | ❌ |
| Tournament report | Tournament org | How did each player fare? | ❌ |
| Coach report | Coach | What should I tell my student? | ❌ |
| Equipment report | Player | Is my gear helping or hurting? | ❌ |
| Health report | Player | How does my body affect my game? | ❌ |
| AI review report | Player | What does AI think of my game? | ❌ |

---

## 3. Common report engine

```
IReportService
  + generate(ReportType, ReportContext) → Report

Each ReportType implements:
  - buildSections()
  - composeNarrative()
  - renderAsPdf()
  - shareAsText()
```

Sections are reusable:
- KPI block
- Trend chart
- Wins / losses
- Skill radar
- AI commentary
- Drill recommendations
- Knowledge next-steps

---

## 4. Sharing

- OS share sheet (`share_plus`).
- PDF export (`printing` package + `pdf`).
- Public link (requires Supabase).

---

## 5. Definition of Done

`A`: weekly report (deferred to A because of parity backlog).

`C`:
- [ ] Weekly / Monthly / Season reports
- [ ] Tournament / Coach / Equipment / Health / AI reports
- [ ] PDF export
- [ ] Share sheet integration
- [ ] Public link (Phase D)
