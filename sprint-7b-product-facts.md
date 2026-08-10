---
name: sprint-7b-product-facts
description: Sprint 7B (Coach Preview UI) - Experience Layer Only
metadata:
  type: project
---

**Sprint 7B** = Coach Preview UI

**North Star:** "Người chơi thực sự sử dụng Coach AI trong quá trình tập luyện."

**Closed:** 2026-08-07.

**Principles:**
- Product First
- No Brain expansion
- Experience Layer only
- Coach Brain = Feature Complete

---

## Phase 7B — Coach Preview UI

### Coach Home Screen

**One screen answering:** "Hôm nay tôi nên làm gì?"

**Components:**
- Daily Briefing card
- Today's Recommendation
- Things to Avoid
- Quick Actions

### Daily Briefing Card

**Coach summarizes:**
- Tiến độ (Progress summary)
- Xu hướng (Trend: improving/stable/declining)
- Trọng tâm hôm nay (Today's focus)
- Điều nên tránh (Things to avoid)

**Format:**
> "Xin chào Minh!
>
> 📊 Tiến độ: Ổn định
> 📈 Xu hướng: Đang tiến bộ
>
> 📌 HÔM NAY: Stop Shot
>
> 🚫 KHÔNG NÊN: Tập Break"

### Coach Chat Screen

**User asks naturally:**
- "Hôm nay nên tập gì?"
- "Tại sao tôi đánh kém?"
- "Tôi nên sửa lỗi nào trước?"

**Coach responds with:**
- Recommendation
- Reasoning
- Evidence
- Suggestions

### Recommendation Card

**Each recommendation includes:**
- Priority badge (1, 2, 3...)
- Drill name
- Reason (why this drill)
- Evidence (data supporting this)
- Expected outcome
- Time horizon

**Example:**
```
┌─────────────────────────────────────┐
│  #1 ƯU TIÊN CAO                    │
├─────────────────────────────────────┤
│  🎯 Stop Shot                       │
│                                     │
│  Lý do:                             │
│  Lỗi cue ball overrun xuất hiện    │
│  8 lần trong 5 buổi gần nhất       │
│                                     │
│  Bằng chứng:                       │
│  • Accuracy giảm 10%                │
│  • Position recovery tăng 15%      │
│                                     │
│  Kết quả mong đợi:                  │
│  • Cue ball control ổn định hơn   │
│  • Accuracy > 80%                   │
│                                     │
│  Thời gian: 2 tuần                 │
│                                     │
│  [Tại sao?] [Bắt đầu tập]          │
└─────────────────────────────────────┘
```

### Explain Button ("Tại sao?")

**User taps "Tại sao?"**
→ Coach explains with data:

> "Tôi khuyên Stop Shot vì:
>
> 1. **Dữ liệu:** Trong 5 buổi gần nhất, accuracy của bạn giảm 10%
>
> 2. **Lỗi recurring:** Cue ball overrun xuất hiện 8 lần
>
> 3. **Nguyên nhân:** Speed control không ổn định
>
> 4. **Prerequisite:** Bạn đã thành thạo Straight Pot
>
> 5. **Expected:** Stop Shot sẽ giúp bạn kiểm soát tốt hơn"

### Coach Timeline

**Shows:**
- Coach advised: "Tập Stop Shot"
- Player did: "Completed Stop Shot - 75%"
- Result: "Accuracy +5%"

**Format:**
```
┌─────────────────────────────────────┐
│  📅 LỊCH SỬ COACH                 │
├─────────────────────────────────────┤
│  Hôm nay                           │
│  ├─ 🏃 Coach: "Tập Stop Shot"     │
│  └─ ✅ Bạn: "Đã tập 75%"          │
│                                     │
│  Hôm qua                          │
│  ├─ 🏃 Coach: "Tập Straight Pot" │
│  └─ ✅ Bạn: "Đã tập 80%"          │
│                                     │
│  3 ngày trước                     │
│  ├─ 🏃 Coach: "Xem lại stance"   │
│  └─ ✅ Bạn: "Đã cải thiện"         │
└─────────────────────────────────────┘
```

---

## Definition of Done

**A new player can:**
- [ ] Mở app
- [ ] Tập luyện (Drill Loop)
- [ ] Ghi trận (Match Recording)
- [ ] Xem lịch sử (History)
- [ ] Hỏi Coach (Chat)
- [ ] Nhận recommendation
- [ ] Hiểu vì sao (Explain)
- [ ] Quay lại sử dụng

**Without any explanation from others.**

---

## After Phase 7B

**Close the vertical slice.**

**Move to Preview/Beta phase:**
1. Test thật
2. Thu thập conversation quality
3. Thu thập recommendation quality
4. Thu thập retention
5. Thu thập feedback

**Chỉ sau khi có dữ liệu thực tế mới quyết định Phase tiếp theo.**

**Principle:** Không tiếp tục mở rộng AI cho đến khi hoàn thành Beta đầu tiên.

---

## Engineering Notes

**UI Components to build:**
- `CoachHomeScreen`
- `DailyBriefingCard`
- `CoachChatScreen`
- `RecommendationCard`
- `ExplainBottomSheet`
- `CoachTimelineScreen`

**Data used (no new Brain):**
- `PlayerIntelligence` (Phase 6A)
- `PriorityEngine` (Phase 6B)
- `CoachService` (Phase 7A)

**No new knowledge nodes.**
**No new reasoning logic.**
**Only UI wrapping existing Brain.**

---

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-7a-product-facts]], [[sprint-6b-product-facts]].
