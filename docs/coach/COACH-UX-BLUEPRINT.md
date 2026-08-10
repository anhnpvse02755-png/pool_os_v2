---
name: coach-ux-blueprint
description: Coach AI UX Blueprint v2 - Approved by Product Owner
metadata:
  type: project
---

# Coach AI UX Blueprint v2

**Purpose:** Design complete Coach AI experience before implementation.
**Phase:** 7B Discovery (Step 0)
**Status:** ✅ APPROVED v2.1 with 7 principles

> **Product Owner Review:** Blueprint đủ tốt để bắt đầu implementation.

## 8 Nguyên tắc đã được áp dụng

1. ✅ **Coach Home = App Home** — Không phải feature, mà là Dashboard chính
2. ✅ **ONE Priority Only** — Chỉ một hành động ưu tiên duy nhất
3. ✅ **Recommendation = Actionable** — Luôn có "Start Now" button
4. ✅ **Explain = Global Capability** — Không chỉ component, mà là hành vi xuyên suốt
5. ✅ **Interrupted Journey** — Coach nhớ và hỏi "Tiếp tục không?"
6. ✅ **Coach Voice Guideline** — Nói như HLV thật, không phải AI
7. ✅ **Coach chỉ nói khi có giá trị** — Không sinh nội dung để lấp chỗ trống
8. ✅ **Coach Leads, Never Asks** — Coach chủ động, không đặt câu hỏi khi đã có dữ liệu
9. ✅ **Expected Outcome** — Mọi recommendation phải có kết quả mong đợi
10. ✅ **Consistency** — Coach phải nhất quán với những gì đã nói

---

## Design Principles v2.1

1. **Coach Home = App Home** — User mở app vì Coach, không phải vì menu
2. **ONE Priority Only** — Chỉ một hành động ưu tiên duy nhất. Mọi thứ khác là thông tin hỗ trợ.
3. **Actionable by default** — Mọi Recommendation đều dẫn tới hành động với 1 tap
4. **5-second value** — User biết việc quan trọng nhất trong 5 giây
5. **Explain is everywhere** — "Tại sao?" có thể hỏi ở bất kỳ đâu
6. **Coach nhớ** — Interrupted Journey là core feature, không phải bonus
7. **Silence when no data** — Coach không nói khi không có gì để nói
8. **Coach Voice** — Nói như HLV thật, không phải AI. Chi tiết bên dưới.

---

## Coach Voice Guideline

### Nguyên tắc cốt lõi

Coach nói như một HLV thật, không phải AI.

| ❌ KHÔNG | ✅ NÊN |
|----------|--------|
| "Dựa trên dữ liệu của bạn..." | "Ba buổi gần đây..." |
| "Theo phân tích của hệ thống..." | "Mình thấy..." |
| "AI đề xuất..." | "Mình khuyên..." |
| "Accuracy giảm 8%" | "Bóng cái hay đi quá xa" |
| "Tỷ lệ thành công thấp" | "Có vẻ khó vào lắm nhỉ" |
| "Bạn nên tập..." | "Hôm nay mình quay lại..." |
| "Bạn muốn làm gì?" | "Hôm nay mình tập X nhé." |

### Giọng Coach

1. **Ngắn** — Tối đa 2-3 câu cho một đề xuất
2. **Tự nhiên** — Như đang nói chuyện với đồng đội
3. **Tích cực** — Luôn hướng tới hành động
4. **Cụ thể** — Nói về tình huống thật, không phải số liệu trừu tượng
5. **Chủ động** — Nói như HLV dẫn dắt, không hỏi người chơi
6. **Nhất quán** — Giữ lời đã hứa

### Rule 6: Coach Leads, Never Asks

Coach chủ động. Không đặt câu hỏi khi đã có dữ liệu.

| ❌ Chatbot-style (Ask) | ✅ Coach-style (Lead) |
|------------------------|----------------------|
| "Bạn muốn làm gì hôm nay?" | "Hôm nay mình quay lại Stop Ball nhé." |
| "Bạn muốn tập gì?" | "Hôm nay nghỉ các bài khó. Mình sửa cue ball trước." |
| "Hôm nay bạn muốn cải thiện kỹ năng nào?" | "Chỉ cần 10 phút thôi. Tập Stop Ball đi." |

**Khi nào Coach được hỏi:**
- Khi thiếu dữ liệu (người dùng mới)
- Khi cần người dùng quyết định (2 lựa chọn ngang nhau)

### Rule 7: Every Recommendation Has an Outcome

Mọi recommendation phải nói rõ **"Nếu làm theo thì được gì"**.

```
┌─────────────────────────────────────────┐
│  STOP BALL                              │
│                                         │
│  Ba buổi gần đây bóng cái hay đi     │
│  quá xa nhỉ.                           │
│                                         │
│  Nếu hoàn thành hôm nay:             │
│  ✓ Accuracy dự kiến tăng 5-10%       │
│  ✓ Giảm overrun                       │
│  ✓ Chuẩn bị cho Position Play          │
│                                         │
│         BẮT ĐẦU                        │
└─────────────────────────────────────────┘
```

| ❌ Không có outcome | ✅ Có outcome |
|---------------------|----------------|
| "Nên tập Stop Ball" | "Nếu hoàn thành: Accuracy tăng 5-10%" |

### Rule 8: Coach Must Be Consistent

Coach phải nhất quán với những gì đã nói.

| ❌ Inconsistent | ✅ Consistent |
|-----------------|--------------|
| Sáng: "Tập Stop Ball" | Sáng: "Tập Stop Ball" |
| Chiều: "Bây giờ hãy tập Draw" | Chiều: "Tiếp tục Stop Ball đi" |
| (không có bằng chứng mới) | (vì chưa hoàn thành Stop Ball) |

**Nguyên tắc:**
- Nếu đã recommend A, phải recommend A cho đến khi có kết quả
- Chỉ đổi khi: có bằng chứng mới HOẶC user hoàn thành A
- User phải cảm giác "Coach nhớ mình vừa nói gì"

### Ví dụ

**❌ Bot-style:**
```
"Dựa trên dữ liệu của bạn trong 5 buổi gần nhất,
tỷ lệ accuracy đã giảm 8%. Hệ thống khuyến
nghị bạn nên tập trung vào bài tập Stop Ball
để cải thiện cue ball control."
```

**✅ Coach-style:**
```
"Ba buổi gần đây bóng cái hay đi quá xa nhỉ.
Mình quay lại Stop Ball hôm nay nhé."
```

**❌ Bot-style:**
```
"Phân tích cho thấy bạn đang trong giai đoạn
sa sút. Không nên tập Break Shot vào lúc này."
```

**✅ Coach-style:**
```
"Nghe có vẻ mệt rồi. Hôm nay nghỉ Break
đi, mình để dành sức cho tuần sau."
```

### Khi nào Coach nói

| Tình huống | Coach nói |
|------------|-----------|
| Có recommendation | "Hôm nay mình tập X nhé" |
| Không có dữ liệu | "Mình chưa biết nhiều về bạn. Bắt đầu tập X đi!" |
| Đang tiến bộ | "Tốt lắm! +5% đó!" |
| Đang sa sút | "Có vẻ mệt rồi. Nghỉ 1 ngày không?" |
| Cần explain | "Nghe mình giải thích nhé..." |

### Khi nào Coach im lặng

| Tình huống | Coach im lặng |
|------------|---------------|
| Không có recommendation | Không sinh nội dung giả |
| Không có dữ liệu | Không đoán |

---

```
┌─────────────────────────────────────────────────────────────────┐
│                      APP OPEN                                     │
│                          │                                        │
│                          ▼                                        │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                    COACH HOME                            │  │
│   │                    (App Dashboard)                       │  │
│   │                                                          │  │
│   │   • Daily Briefing                                       │  │
│   │   • Today's Focus (with Start Now)                      │  │
│   │   • Continue Session? (if interrupted)                 │  │
│   │   • Quick Actions                                       │  │
│   │                                                          │  │
│   │   Everything else is secondary.                         │  │
│   └─────────────────────────────────────────────────────────┘  │
│                          │                                        │
│         ┌────────────────┼────────────────┐                    │
│         ▼                ▼                ▼                     │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│   │  DRILL   │    │  MATCH   │    │  COACH   │              │
│   │   Loop   │    │ Recording│    │   Chat   │              │
│   └──────────┘    └──────────┘    └──────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Principle 1: ONE Priority Only

### Coach Home chỉ có MỘT ưu tiên

Mọi thông tin khác (trend, avoid, timeline...) chỉ là **thông tin hỗ trợ**, không được cạnh tranh với CTA chính.

### ❌ Overwhelming Home (5 thông tin cùng lúc)
```
┌─────────────────────────────────────────┐
│  🏠 Xin chào Minh!
│
│  📈 Đang tiến bộ
│  📅 12 buổi tập
│
│  📌 HÔM NAY: Stop Ball
│  🚫 KHÔNG NÊN: Break
│  ⏰ Continue Session
│
│  ┌────────┐  ┌────────┐  ┌────────┐
│  │  Tập  │  │  Đấu  │  │  Hỏi  │
│  │  ngay  │  │  trận  │  │  Coach │
│  └────────┘  └────────┘  └────────┘
└─────────────────────────────────────────┘
```

### ✅ ONE Priority Home
```
┌─────────────────────────────────────────┐
│  Xin chào Minh!
│
│  ┌─────────────────────────────────┐
│  │                                 │
│  │    STOP BALL                   │
│  │                                 │
│  │    Ba buổi gần đây bóng cái   │
│  │    hay đi quá xa nhỉ.         │
│  │                                 │
│  │         BẮT ĐẦU              │
│  │                                 │
│  └─────────────────────────────────┘
│
│  ─── Hoặc ───
│
│  Tiếp tục Stop Ball? (45%) [Tiếp tục]
│
└─────────────────────────────────────────┘
```

---

## Principle 2: Coach Home = App Home

### Coach Home is NOT a feature
### Coach Home IS the app

```
┌─────────────────────────────────────────┐
│  🏠                                    │
│                                         │
│  Xin chào Minh!                         │
│  Hôm nay: Thứ 3, 25/7                 │
│                                         │
│  ════════════════════════════════════    │
│                                         │
│  📌 HÔM NAY                            │
│  ┌─────────────────────────────────┐    │
│  │ Stop Ball                       │    │
│  │                                 │    │
│  │ Accuracy giảm 8%               │    │
│  │ Tập 10 phút                    │    │
│  │                                 │    │
│  │        [ BẮT ĐẦU ]            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─── HOẶC ───                          │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Tiếp tục Stop Ball?            │    │
│  │ Bạn đang tập dở (45%)        │    │
│  │ [ TIẾP TỤC ] [ BẮT ĐẦU MỚI ]│    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─── HOẶC ───                          │
│                                         │
│  ┌────────┐  ┌────────┐  ┌────────┐   │
│  │  Đấu  │  │  Hỏi   │  │ Xem    │   │
│  │  trận │  │  Coach │  │ lịch sử│   │
│  └────────┘  └────────┘  └────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

**Tất cả đều dẫn tới hành động. Không có "xem thêm" không cần thiết.**

---

## Principle 2: Actionable Recommendation

### Every Recommendation = One Button + Outcome

```
┌─────────────────────────────────────────┐
│  📌 STOP BALL                          │
│                                         │
│  Ba buổi gần đây bóng cái hay đi     │
│  quá xa nhỉ.                          │
│                                         │
│  Nếu hoàn thành hôm nay:             │
│  ✓ Accuracy dự kiến tăng 5-10%       │
│  ✓ Giảm overrun                       │
│  ✓ Chuẩn bị cho Position Play          │
│                                         │
│  Thời gian: 10 phút                   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │         BẮT ĐẦU                │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Tại sao?                              │
└─────────────────────────────────────────┘
```

**Mọi recommendation phải có:**
1. Một hành động (Start Now)
2. Một lý do (Coach Voice)
3. Một Expected Outcome (được gì nếu làm)

---

## Principle 3: Explain = Global Capability

### "Tại sao?" có thể hỏi ở mọi nơi

```
┌─────────────────────────────────────────┐
│  COACH HOME ────────► Explain           │
│       │                                   │
│       │ "Tại sao?"                       │
│       ▼                                   │
│  COACH CHAT ────────► Explain           │
│       │                                   │
│       │ "Tại sao?"                       │
│       ▼                                   │
│  COACH REVIEW ──────► Explain           │
│       │                                   │
│       │ "Tại sao?"                       │
│       ▼                                   │
│  TIMELINE ──────────► Explain            │
│       │                                   │
│       │ "Tại sao?"                       │
│       ▼                                   │
│  ANY COACH OUTPUT                       │
│       │                                   │
│       │ "Tại sao?"                       │
│       ▼                                   │
│  EXPLAIN BOTTOM SHEET                   │
└─────────────────────────────────────────┘
```

### Explain Bottom Sheet (Universal)

```
┌─────────────────────────────────────────┐
│                                    ─ ✕  │
│  📊 TẠI SAO?                          │
│                                         │
│  Tôi khuyên Stop Ball vì:              │
│                                         │
│  ════════════════════════════════════    │
│                                         │
│  1️⃣ DỮ LIỆU CỦA BẠN                   │
│     • Accuracy 5 buổi gần nhất:        │
│       78% → 75% → 72% → 70% → 68%     │
│     • Cue ball overrun: tăng 15%       │
│                                         │
│  2️⃣ NGUYÊN NHÂN                        │
│     • Speed control không ổn định       │
│     • Thường đánh mạnh hơn cần        │
│                                         │
│  3️⃣ ĐIỀU KIỆN ĐÃ ĐÁP ỨNG             │
│     ✅ Straight Shot: 85% (đạt)         │
│     ✅ Follow Shot: 75% (đạt)          │
│     ✅ Stop Shot: CHƯA (đang tập)       │
│                                         │
│  4️⃣ KẾT QUẢ MONG ĐỢI                  │
│     • Cue ball control ổn định         │
│     • Accuracy > 75%                    │
│     • Thời gian: 2 tuần               │
│                                         │
│  ════════════════════════════════════    │
│  Confidence: 85%                        │
│                                         │
│  [ BẮT ĐẦU STOP BALL ]                │
│                                         │
└─────────────────────────────────────────┘
```

**Explain không phải một màn hình. Explain là một action sheet xuất hiện từ bất kỳ đâu.**

---

## Principle 4: Coach nhớ - Interrupted Journey

### Khi user thoát giữa chừng

```
┌─────────────────────────────────────────┐
│  🏠                                    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 👋 CHÀO LẠI!                    │    │
│  │                                  │    │
│  │ Bạn đang tập dở Stop Ball.      │    │
│  │                                 │    │
│  │ Lần cuối: 45% (5 buổi trước)  │    │
│  │ Tiếp tục từ đây?              │    │
│  │                                 │    │
│  │      [ TIẾP TỤC ]              │    │
│  │      [ BẮT ĐẦU MỚI ]          │    │
│  │      [ VỀ HOME ]              │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### Khi user quay lại trong ngày

```
┌─────────────────────────────────────────┐
│  🏠                                    │
│                                         │
│  Hôm nay bạn đã:                       │
│  • Stop Ball: 2/3 buổi (66%)          │
│                                         │
│  Đang trong giai đoạn tốt.             │
│  Tiếp tục duy trì!                    │
│                                         │
│  ─────────────────────────────────     │
│                                         │
│  📌 HÔM NAY                            │
│  Stop Ball (tiếp tục)                  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │         BẮT ĐẦU                │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### Khi user quay lại sau nhiều ngày

```
┌─────────────────────────────────────────┐
│  🏠                                    │
│                                         │
│  👋 ĐÃ LÂU RỒI!                        │
│                                         │
│  3 ngày trước bạn đang tập            │
│  Stop Ball (58%).                       │
│                                         │
│  Tôi khuyên bạn nên:                   │
│  • Tiếp tục Stop Ball                  │
│  • Hoặc bắt đầu lại từ đầu           │
│                                         │
│  [ TIẾP TỤC STOP BALL ]               │
│  [ BẮT ĐẦU LẠI ]                     │
│                                         │
└─────────────────────────────────────────┘
```

**Coach nhớ:**
- Đang tập gì
- Đến đâu
- Bao lâu rồi không tập
- Kết quả gần nhất

---

## Principle 5: Silence when no data

### Khi không có dữ liệu

```
┌─────────────────────────────────────────┐
│  🏠                                    │
│                                         │
│  👋 CHÀO BẠN MỚI!                      │
│                                         │
│  Tôi là Coach của Pool OS.              │
│  Tôi sẽ giúp bạn cải thiện.           │
│                                         │
│  Để bắt đầu, hãy tập một bài tập.     │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     BẮT ĐẦU STRAIGHT SHOT      │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Đây là bài tập cơ bản nhất.          │
│  Tôi sẽ học về bạn từ đây.          │
│                                         │
└─────────────────────────────────────────┘
```

**Không hiện "recommendation" giả. Coach nói khi có gì để nói.**

### Khi có dữ liệu nhưng không đủ

```
┌─────────────────────────────────────────┐
│  🏠                                    │
│                                         │
│  Xin chào Minh!                         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  Tôi chưa có đủ dữ liệu để             │
│  đưa ra kế hoạch cụ thể.              │
│                                         │
│  Hiện tại:                             │
│  • 2 buổi tập                         │
│  • 0 trận đấu                         │
│                                         │
│  💡 Gợi ý:                             │
│  Tiếp tục tập Straight Shot để         │
│  tôi hiểu mức độ của bạn.             │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     TIẾP TỤC STRAIGHT SHOT     │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Khi nào tôi có đủ dữ liệu,           │
│  tôi sẽ đưa ra kế hoạch chi tiết.    │
│                                         │
└─────────────────────────────────────────┘
```

---

## Journey 1: App Open → Coach Home

### Flow
```
App Open
    │
    ▼
┌─────────────────────────────────────────┐
│  CHECK: Interrupted Session?              │
│                                         │
│  ├── YES → Show "Continue Session?"     │
│  │            │                        │
│  │            └── User chooses          │
│  │                    │                 │
│  │         ┌─────────┼─────────┐        │
│  │         ▼         ▼         ▼        │
│  │      Continue   Start    Go Home     │
│  │        │        New       │          │
│  │         └────────┬────────┘        │
│  │                  ▼                  │
│  │            Drill Loop               │
│  │                                       │
│  └── NO → Show Coach Home               │
│               │                         │
│               ▼                         │
│    ┌─────────────────────┐            │
│    │ CHECK: Enough Data? │            │
│    │                     │            │
│    │ ├── YES → Full Home │            │
│    │ │   with Recommendation            │
│    │ │                        │         │
│    │ └── NO → Minimal Home │         │
│    │       with Suggestion │          │
│    └─────────────────────┘            │
└─────────────────────────────────────────┘
```

### Coach Home v2 (Full Data)
```
┌─────────────────────────────────────────┐
│  Xin chào Minh!                         │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │    STOP BALL                   │    │
│  │                                 │    │
│  │    Ba buổi gần đây bóng cái   │    │
│  │    hay đi quá xa nhỉ.        │    │
│  │                                 │    │
│  │         BẮT ĐẦU              │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─── Hoặc ───                          │
│                                         │
│  Tiếp tục Stop Ball? (45%)             │
│  [Tiếp tục]  [Bắt đầu mới]          │
│                                         │
└─────────────────────────────────────────┘
```

**Chỉ MỘT ưu tiên. Mọi thứ khác là thông tin hỗ trợ.**

### Coach Home v2 (No Data)
```
┌─────────────────────────────────────────┐
│  🏠 Xin chào Minh!                       │
│  Hôm nay: Thứ 3, 25/7                  │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  👋 TÔI CHƯA BIẾT NHIỀU VỀ BẠN        │
│                                         │
│  Tôi cần thêm dữ liệu để               │
│  đưa ra kế hoạch cụ thể.              │
│                                         │
│  💡 BẮT ĐẦU VỚI:                       │
│  Straight Shot - Bài tập cơ bản nhất   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     BẮT ĐẦU STRAIGHT SHOT     │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

---

## Journey 2: Finish Drill → Coach Intervention

### Flow
```
Drill Complete (DoD reached)
    │
    ▼
┌─────────────────────────────────────────┐
│  DRILL RESULT                           │
│                                         │
│  Stop Ball: 75% ✅                      │
│  (+5% vs 70%)                          │
│                                         │
│  [ TỔNG KẾT ] [ TIẾP TỤC ] [ VỀ HOME ]│
└─────────────────────────────────────────┘
    │
    ▼
Coach Intervention (auto or on tap)
    │
    ▼
┌─────────────────────────────────────────┐
│  🏃 COACH                               │
│                                         │
│  "Tuyệt vời! +5% so với lần trước!"   │
│                                         │
│  Dựa trên buổi tập này, tôi khuyên:  │
│                                         │
│  📌 TIẾP TỤC VỚI                        │
│  ┌─────────────────────────────────┐    │
│  │         DRAW SHOT               │    │
│  │                                 │    │
│  │  Điều kiện đã đạt:            │    │
│  │  • Stop Shot: 75% ✅           │    │
│  │  • Follow Shot: 70% ✅         │    │
│  │                                 │    │
│  │        BẮT ĐẦU                │    │
│  │                                 │    │
│  │  Tại sao?                      │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [ VỀ HOME ]                           │
└─────────────────────────────────────────┘
```

**Coach luôn recommend drill tiếp theo. Không để user "không biết tập gì".**

---

## Journey 3: Coach Chat (Global Explain)

### Chat với Explain ở mọi nơi
```
┌─────────────────────────────────────────┐
│  💬 COACH                               │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ Xin chào! Tôi có thể giúp gì? │    │
│  │                                 │    │
│  │ Gợi ý:                         │    │
│  │ • "Hôm nay nên tập gì?"       │    │
│  │ • "Tại sao tôi đánh kém?"     │    │
│  │ • "Sao tôi thua?"             │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Tại sao tôi nên tập Stop Shot? │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🏃 Coach                       │    │
│  │                                 │    │
│  │ Tôi khuyên Stop Shot vì:     │    │
│  │ • Accuracy giảm 8%            │    │
│  │ • Cue ball overrun tăng        │    │
│  │                                 │    │
│  │ [ Tại sao? ]                  │    │
│  │ [ Bắt đầu tập ]              │    │
│  └─────────────────────────────────┘    │
│                                         │
│  User taps "Tại sao?"                   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🏃 Coach                       │    │
│  │                                 │    │
│  │ Chi tiết:                      │    │
│  │ 1️⃣ Dữ liệu: Accuracy 5 buổi  │    │
│  │    giảm: 78→75→72→70→68%     │    │
│  │                                 │    │
│  │ 2️⃣ Nguyên nhân: Speed control │    │
│  │    không ổn định              │    │
│  │                                 │    │
│  │ 3️⃣ Điều kiện: ✅ Stop Shot    │    │
│  │    CHƯA (đang tập)            │    │
│  │                                 │    │
│  │ [ Thu nhỏ ] [ Bắt đầu tập ]  │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  [ Type message...            ] [Send] ││
└─────────────────────────────────────────┘
```

---

## Journey 4: Coach Timeline

### Timeline với Coach Memory
```
┌─────────────────────────────────────────┐
│  📅 LỊCH SỬ                             │
├─────────────────────────────────────────┤
│                                         │
│  HÔM NAY                                │
│  ┌─────────────────────────────────┐    │
│  │ 🏃 Stop Ball: 75%             │    │
│  │ ✅ Đã hoàn thành              │    │
│  │ 📈 +5% vs lần trước          │    │
│  │                                 │    │
│  │ Coach khuyên tiếp Draw Shot   │    │
│  │ [ Bắt đầu? ] [ Tại sao? ]    │    │
│  └─────────────────────────────────┘    │
│                                         │
│  HÔM QUA                                │
│  ┌─────────────────────────────────┐    │
│  │ 🏃 Draw Shot: 60%             │    │
│  │ ✅ Đã tập (lần đầu tiên)     │    │
│  │                                 │    │
│  │ Coach khuyên tiếp Position    │    │
│  │ [ Xem chi tiết ]              │    │
│  └─────────────────────────────────┘    │
│                                         │
│  3 NGÀY TRƯỚC                          │
│  ┌─────────────────────────────────┐    │
│  │ 🏃 Stop Ball: 70%             │    │
│  │ ⚠️ Tạm dừng (nghỉ 1 ngày)   │    │
│  │                                 │    │
│  │ Coach khuyên: "Nghỉ 1 ngày"  │    │
│  │ ✅ Bạn đã nghỉ                │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

---

## Journey 5: Coach Review (Match)

### Match Review với Explain
```
┌─────────────────────────────────────────┐
│  🏃 COACH REVIEW                       │
│                                         │
│  Thắng 3-2! 💪                         │
│                                         │
│  ════════════════════════════════════    │
│                                         │
│  ✅ ĐIỂM MẠNH                          │
│  • Safety play: 2/4 (tốt)             │
│  • Giữ bình tĩnh điểm quyết định     │
│                                         │
│  ⚠️ CẦN CẢI THIỆN                      │
│  • Position play sau Draw Shot         │
│  • Break efficiency (1 scratch)        │
│                                         │
│  🔍 QUYẾT ĐỊNH QUAN TRỌNG NHẤT       │
│  Shot 7 - Draw position miss           │
│  → Thua safety → Mất lượt             │
│                                         │
│  [ Tại sao? ] [ Chi tiết ] [ Lưu ]   │
│                                         │
└─────────────────────────────────────────┘
```

---

## Journey 6: Interrupted Journey (NEW)

### Entry: User returns after interruption
```
App Opens
    │
    ▼
┌─────────────────────────────────────────┐
│  CHECK: Interrupted Session?            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 👋 CHÀO LẠI!                   │    │
│  │                                 │    │
│  │ Bạn đang tập dở:               │    │
│  │ Stop Ball (45%)                 │    │
│  │                                 │    │
│  │ Lần cuối: 2 tiếng trước       │    │
│  │                                 │    │
│  │      [ TIẾP TỤC ]             │    │
│  │      [ BẮT ĐẦU MỚI ]          │    │
│  │      [ VỀ HOME ]              │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### Context-aware continuation
```
┌─────────────────────────────────────────┐
│  💬 COACH                               │
│                                         │
│  "Tôi nhớ bạn đang tập Stop Ball.    │
│   Bạn đạt 45% và đang tiến bộ.        │
│   Tiếp tục nhé?"                       │
│                                         │
│  [ TIẾP TỤC STOP BALL ]                │
│  [ CHỌN DRILL KHÁC ]                   │
│  [ VỀ HOME ]                           │
└─────────────────────────────────────────┘
```

### Coach nhớ:
- Đang tập gì
- Đến đâu (% hoàn thành)
- Bao lâu rồi
- Kết quả gần nhất
- Ngày mai nên làm gì

---

## Sprint Breakdown v2.1

### Sprint 7B.1 — Coach Home

**North Star:** Trong 5 giây sau khi mở app, người chơi biết ngay việc quan trọng nhất cần làm hôm nay và có thể bắt đầu bằng đúng 1 lần chạm.

**Scope (strict):**
| Deliverable | Description |
|-------------|-------------|
| Coach Home | ONE Priority only |
| Daily Briefing | 2-3 lines max |
| Primary Recommendation | Chỉ 1 recommendation |
| Start Now | 1-tap to drill |
| Continue Session | Nếu có buổi tập dở |
| Empty State | Chưa có dữ liệu |
| Loading State | Coach đang nghĩ |
| Error State | Coach không available |

**NOT in scope:** Chat, Timeline, Explain (Sprint 7B.2+)

**Metrics:**
- User mở app → thấy 1 recommendation trong 5 giây
- User bắt đầu drill bằng 1 tap

**DoD:**
- [ ] Mở app → thấy 1 ưu tiên rõ ràng
- [ ] Có thể bắt đầu drill bằng 1 tap
- [ ] Nếu có session dở → được mời tiếp tục
- [ ] Nếu không có dữ liệu → Coach nói rõ

---

### Sprint 7B.2 — Explain + Chat

**North Star:** Người dùng hiểu vì sao Coach nói như vậy.

**Scope:**
| Deliverable | Description |
|-------------|-------------|
| Explain Bottom Sheet | Global capability |
| Coach Chat | Natural language |
| Evidence Display | Coach Voice |
| Reasoning Display | Pattern + Cause |
| Chat History | Memory |

**NOT in scope:** Timeline, Onboarding (Sprint 7B.3+)

---

### Sprint 7B.3 — Timeline + Memory

**North Star:** Người dùng cảm thấy Coach nhớ mình.

**Scope:**
| Deliverable | Description |
|-------------|-------------|
| Coach Timeline | History of recommendations |
| Interrupted Journey | Continue after exit |
| Session Memory | ≥ 7 days recall |
| Coach Voice | Applied everywhere |

---

### Sprint 7B.4 — Polish + Onboarding

**North Star:** Một người chưa từng dùng Pool OS vẫn tự dùng được Coach.

**Scope:**
| Deliverable | Description |
|-------------|-------------|
| Coach Onboarding | 3 screens |
| UX Polish | Transitions |
| Error States | Graceful degradation |
| Offline Mode | When no network |

---

## Coach Voice Checklist

Mọi Coach response phải pass:

- [ ] **Ngắn** — ≤ 3 câu cho recommendation
- [ ] **Tự nhiên** — Không có "dựa trên", "hệ thống", "AI"
- [ ] **Tích cực** — Hướng tới hành động
- [ ] **Cụ thể** — Nói về tình huống, không phải số

**Ví dụ pass:**
```
"Hôm nay mình quay lại Stop Ball nhé.
Ba buổi gần đây bóng cái hay đi quá xa."
```

**Ví dụ fail:**
```
"Dựa trên dữ liệu của bạn trong 5 buổi gần nhất,
tỷ lệ accuracy đã giảm 8%. Hệ thống khuyến
nghị bạn nên tập trung vào bài tập Stop Ball."
```

---

## Definition of Done v2

**A new player can without explanation:**
- [ ] Mở app → thấy Coach Home (5 giây)
- [ ] Biết hôm nay nên tập gì
- [ ] Bắt đầu drill bằng 1 tap
- [ ] Hoàn thành drill → thấy Coach summary
- [ ] Hiểu vì sao nên tập drill tiếp theo ("Tại sao?")
- [ ] Hỏi Coach bằng tiếng Việt tự nhiên
- [ ] Thoát giữa chừng → quay lại → tiếp tục được
- [ ] Xem được Coach Timeline
- [ ] Quay lại sử dụng ngày hôm sau
- [ ] **Không có "Tôi không biết làm gì"**

---

## Not In Scope

- Vision AI
- Video Analysis
- Voice Coach
- Tournament AI
- Advanced Analytics
- Social features

---

## Sprint 7B.1 Plan

**Status:** ✅ APPROVED
**North Star:** Trong 5 giây sau khi mở app, người chơi biết ngay việc quan trọng nhất cần làm hôm nay và có thể bắt đầu bằng đúng 1 lần chạm.

### Implementation Scope

**Phase 1: Core UI**
- CoachHomeScreen (ONE priority layout)
- CoachRecommendationCard (with Start Now)
- CoachContinueSession (if interrupted)
- CoachEmptyState (no data)

**Phase 2: Data Integration**
- CoachService integration
- PriorityEngine integration
- PlayerIntelligence integration
- Session memory (continue)

**Phase 3: Coach Voice**
- CoachVoiceService (Coach-style responses)
- Loading states
- Error states

### Coach Voice Implementation

```dart
// Coach Voice Service
class CoachVoiceService {
  // ❌ Bot-style
  String botResponse = "Dựa trên dữ liệu của bạn...";

  // ✅ Coach-style
  String coachResponse = "Ba buổi gần đây bóng cái hay đi quá xa nhỉ.";
}
```

### Definition of Done

- [ ] Mở app → thấy 1 ưu tiên rõ ràng trong 5 giây
- [ ] Có thể bắt đầu drill bằng 1 tap
- [ ] Nếu có session dở → được mời tiếp tục
- [ ] Nếu không có dữ liệu → Coach nói rõ
- [ ] Coach response pass Coach Voice checklist

---

## Product Quality Gates

Trước khi chuyển sang Beta:

1. **Coach Home:** 100% flows work
2. **Explain:** Mọi recommendation đều có "Tại sao?"
3. **Interrupted Journey:** Session memory hoạt động ≥ 7 ngày
4. **No-Data State:** New user có thể bắt đầu không cần guidance
5. **Chat:** Intent parser cover ≥ 80% common questions

---

**Status:** ✅ APPROVED by Product Owner
**Version:** v2
**Date:** 2026-08-07

---

Related: [[sprint-7b-product-facts]], [[phase-3-vertical-slice-roadmap]].
