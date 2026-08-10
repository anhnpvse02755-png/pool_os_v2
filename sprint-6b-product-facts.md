---
name: sprint-6b-status
description: Sprint 6B (Priority Engine) closed. Coach knows what to prioritize.
metadata:
  type: project
---

**Sprint 6B** = Priority Engine

**North Star:** "Coach biết ưu tiên điều gì trước cho người chơi."

**Closed:** 2026-08-07.

**Shipped:**

### Phase 6B — Priority-First Coach Engine

**Pipeline:**
```
Player Intelligence → Knowledge Graph → Reasoning Engine → Priority Engine → Recommendation
```

**Priority Engine Features:**

1. **Focus Area Identification**
   - Mistake patterns
   - Skill weaknesses
   - Trend reversal needs
   - Consistency building

2. **Priority Scoring**
   - Urgency (40% weight)
   - Impact (30% weight)
   - Effort (20% penalty)
   - Player level (10% weight)

3. **Recommendation Types:**
   - Focus — Ưu tiên tập trung
   - Maintain — Duy trì
   - Delay — Tạm hoãn
   - Avoid — Không nên
   - Review — Xem lại

**Coach AI Can Now Answer:**

1. "Trong 10 vấn đề, vấn đề nào cần sửa đầu tiên?" → Priority Engine
2. "Vì sao?" → Reasoning + Evidence
3. "Nếu chỉ có 30 phút hôm nay, nên tập gì?" → Today Recommendation
4. "Nếu còn 4 tuần để lên hạng, ưu tiên điều gì?" → Long-term Plan
5. "Điều gì KHÔNG nên tập lúc này?" → Avoid Recommendations

**Output Structure:**

```dart
CoachingRecommendation {
  rank: 1,
  priority: high,
  confidence: 80%,
  type: today,
  drillCode: STOP_BALL,
  reason: "Lỗi này ảnh hưởng đến...",
  evidence: ["Xuất hiện 8 lần", "Đang có xu hướng giảm"],
  expectedImprovement: {...},
  timeHorizon: 2 weeks,
  successCriteria: ["Accuracy > 80%", "Consistency > 70%"]
}

AvoidRecommendation {
  item: "Drill khó",
  reason: "Bạn đang trong giai đoạn sa sút...",
  alternative: "Quay lại drill cơ bản..."
}
```

**Example Coach Statement:**
> "Xin chào Minh!
>
> 📌 HÔM NAY: Stop Ball
> Lý do: Lỗi cue ball overrun xuất hiện 8 lần trong 5 buổi gần nhất
> Bằng chứng: Accuracy giảm 10%
>
> 🚫 HÔM NAY KHÔNG NÊN:
> - Tập drill khó: Bạn đang trong giai đoạn sa sút
> - Tập quá sức: Tuần này đã tập 4 buổi
>
> 📅 KẾ HOẠCH:
> Giai đoạn 1 (2 tuần): Cải thiện cấp bách
>   Tập trung: Stop Ball, Speed Control"

**Design Principles Applied:**
- Recommendation chỉ là output
- Priority Engine quyết định điều gì quan trọng nhất
- Avoid Recommendations quan trọng không kém
- Coach tối ưu tiến trình học, không chỉ kỹ thuật

**Engineering gate:** All routes analyze clean.

**Product validation:** Deferred to Phase 7 Milestone.

**Next:** Phase 7 — Coach Preview (Conversation + AI Orchestration)

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-6a-product-facts]].
