---
name: sprint-7a-status
description: Sprint 7A (Conversation Engine) closed. Coach Brain now accessible via conversation.
metadata:
  type: project
---

**Sprint 7A** = Conversation Engine

**North Star:** "Người chơi cảm thấy đang được một HLV thật sự đồng hành."

**Closed:** 2026-08-07.

**Shipped:**

### Phase 7A — Coach Conversation Interface

**Coach supports 4 main situations:**

1. **Before Practice**
   - What to practice today
   - Plan session
   - Prepare for match
   - Limited time

2. **During Practice**
   - Feedback
   - Encouragement
   - Take break

3. **After Practice**
   - Summarize session
   - Progress review
   - Next steps

4. **After Match**
   - Match analysis
   - What went wrong
   - Strengths analysis

**Conversation Engine Features:**

1. **Intent Parser**
   - Parses user message to CoachIntent
   - Handles free-form questions
   - Supports follow-up questions

2. **Context Builder**
   - Builds context from Player Intelligence
   - Includes coaching plan
   - Tracks session history

3. **Coach Service**
   - Orchestrates Coach Brain
   - Generates reasoning based on intent
   - Formats response in natural language

4. **Session Memory**
   - Tracks conversation turns
   - Remembers discussed topics
   - Maintains context

**Pipeline:**
```
Conversation → Intent → Context → Coach Brain → Reasoning → Response
```

**Safety Principle:**
- If data is insufficient → "Tôi chưa có đủ dữ liệu"
- Coach never fabricates

**Example Conversations:**

```
User: "Hôm nay tôi nên tập gì?"
Coach: "Hôm nay tôi khuyên bạn tập: Stop Ball
       Lý do: Lỗi cue ball overrun xuất hiện 8 lần
       Bằng chứng: Accuracy giảm 10%

       🚫 HÔM NAY KHÔNG NÊN:
       • Tập drill khó: Bạn đang trong giai đoạn sa sút"

User: "Vậy tôi nên tập gì?"
Coach: "Ưu tiên Stop Shot trước.
       Drill này ngắn nhưng hiệu quả."
```

**Design Principles Applied:**
- LLM chỉ diễn đạt, không bịa
- Reasoning đến từ Coach Brain
- Safety: Coach nói "Tôi chưa có đủ dữ liệu" khi cần

**Engineering gate:** All routes analyze clean.

**Product validation:** Deferred to Phase 7 Milestone.

**Next:** Phase 7B — Coach Preview UI

Related: [[phase-3-vertical-slice-roadmap]], [[sprint-6b-product-facts]].
