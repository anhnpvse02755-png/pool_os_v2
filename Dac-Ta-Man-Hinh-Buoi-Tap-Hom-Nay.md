# ĐẶC TẢ: MÀN HÌNH "BUỔI TẬP HÔM NAY"
### Gộp Mục 3 (Retest định kỳ) + Mục 4 (Trình tạo buổi tập theo thời gian rảnh)
### Dùng cùng: Lo-Trinh-Hoc-Theo-Trinh-Do.md, Dac-Ta-Timeline-Dong.md, Dac-Ta-Chi-Tiet-Cac-Tinh-Nang-Bo-Sung.md

---

## 1. MỤC TIÊU MÀN HÌNH

Đây là màn hình **mặc định khi mở app** (thay thế/đứng trước màn hình danh sách 24 bài tập tra cứu). Trả lời đúng 1 câu hỏi của người dùng: *"Hôm nay tôi nên tập gì?"* — không bắt họ tự lục qua Cấp độ / Mục kiến thức / Nhật ký lỗi để tự quyết định.

---

## 2. LUỒNG MÀN HÌNH (UI FLOW)

```
[Mở app]
   │
   ▼
[Màn hình "Buổi tập hôm nay"]
   │
   ├── Header: "Chào [tên]! Cấp [X] — [Y]% hoàn thành. Dự kiến lên cấp: ~[Z] tuần nữa."
   │
   ├── Nếu có mục "cần retest" khẩn cấp (xem 3.1) → Banner nhẹ ở trên cùng:
   │      "2 kỹ năng lâu rồi bạn chưa ôn — [Xem ngay]"  (không bắt buộc bấm)
   │
   ├── Câu hỏi chính: "Hôm nay bạn có bao nhiêu thời gian?"
   │      [ 15 phút ]  [ 30 phút ]  [ 60 phút ]  [ Tùy chỉnh ]
   │
   ▼ (người dùng chọn 1 mốc)
   │
[Màn hình "Buổi tập được đề xuất"]
   │
   ├── Danh sách bài tập dạng checklist, đã sắp theo thứ tự ưu tiên (xem thuật toán mục 3):
   │      ☐ BT07 — Ôn lại (không luyện 18 ngày)         ~7 phút
   │      ☐ BT03 — Điểm yếu: góc 45°                     ~6 phút
   │      ☐ BT09 — Tiếp theo trong lộ trình               ~5 phút
   │                                          Tổng: ~18/20 phút
   │
   ├── Mỗi dòng có thể: [Bỏ qua] (thay bằng bài kế tiếp trong hàng đợi ưu tiên)
   │                     [Xem lý do] (mở giải thích ngắn — xem mục 5)
   │
   ├── Nút chính: [ Bắt đầu buổi tập ]
   └── Nút phụ:   [ Tự chọn bài khác ] → mở danh sách đầy đủ 24 BT (lối thoát cho người muốn tự chủ)
   │
   ▼ (bấm Bắt đầu)
[Luyện lần lượt từng bài đã có UI sẵn — không đổi]
   │
   ▼ (hoàn thành buổi)
[Màn hình tổng kết buổi tập]
   ├── Kết quả từng bài (tier cũ → tier mới nếu có thay đổi)
   ├── Cập nhật Timeline nếu lệch đủ lớn (theo logic đã có ở Dac-Ta-Timeline-Dong.md mục 4.5)
   └── [ Xong ]
```

---

## 3. THUẬT TOÁN CHỌN BÀI TẬP (chạy khi người dùng chọn mốc thời gian)

### 3.1. Bước 1 — Tập hợp ứng viên theo 3 nguồn, gắn nhãn ưu tiên

```
candidates = []

// Nguồn A: Cần retest (ưu tiên cao nhất)
for bt in user.progress:
    if bt.current_tier >= 2:
        days_since = today - bt.last_practiced_date
        threshold = { 2: 14, 3: 21, 4: 30 }[bt.current_tier]
        if days_since >= threshold:
            candidates.append({ bt_id: bt.id, priority: "A_retest",
                                 urgency_score: days_since - threshold })

// Nguồn B: Điểm yếu nổi bật (theo condition, xem file mục 1)
for weak_point in compute_weak_points(user):  // trả về list các (bt_id, condition)
    candidates.append({ bt_id: weak_point.bt_id, priority: "B_weakness",
                         urgency_score: weak_point.gap_percent })

// Nguồn C: Tiếp theo trong lộ trình chính (chưa đạt tier mục tiêu ở cấp hiện tại)
next_in_path = get_next_uncompleted_bt(user.current_cap, user.progress)
candidates.append({ bt_id: next_in_path, priority: "C_lo_trinh", urgency_score: 0 })
```

### 3.2. Bước 2 — Sắp xếp và loại trùng

```
1. Loại bỏ candidate trùng bt_id (giữ candidate có priority cao hơn: A > B > C).
2. Sắp xếp trong từng nhóm theo urgency_score giảm dần.
3. Ghép thành 1 danh sách theo thứ tự: [tất cả nhóm A] → [tất cả nhóm B] → [nhóm C].
4. Giới hạn tối đa 2 candidate từ nhóm A trong 1 buổi (tránh 1 buổi toàn bài ôn cũ,
   mất động lực vì không thấy tiến độ mới).
```

### 3.3. Bước 3 — Lấp đầy theo thời gian

```
estimated_minutes(bt) = tra bảng cấu hình sẵn theo số cú (N) của bài:
    N <= 5   → 4 phút
    N = 10  → 7 phút
    N = 15  → 10 phút
    (cộng thêm 2 phút "khởi động" cho bài đầu tiên trong buổi)

remaining_time = available_minutes
selected = []
for c in candidates (theo thứ tự đã sắp):
    if estimated_minutes(c) <= remaining_time * 1.15:   // cho phép vượt nhẹ 15%
        selected.append(c)
        remaining_time -= estimated_minutes(c)
    if remaining_time <= 2:
        break

if selected rỗng (available_minutes quá ít, ví dụ < 4 phút):
    selected = [candidate đầu tiên trong hàng đợi]  // vẫn đề xuất tối thiểu 1 bài
```

### 3.4. Xử lý nút "Bỏ qua" 1 bài trong danh sách đề xuất
```
Khi người dùng bấm [Bỏ qua] ở 1 dòng:
    remaining_time += estimated_minutes(bt_bo_qua)
    lấy candidate tiếp theo trong hàng đợi (chưa được chọn) sao cho vừa remaining_time
    thay vào đúng vị trí đó trong danh sách hiển thị
```

---

## 4. XỬ LÝ CÁC TRƯỜNG HỢP ĐẶC BIỆT

| Tình huống | Xử lý |
|---|---|
| Người dùng mới hoàn toàn (chưa có progress nào) | Bỏ qua nhóm A và B, chỉ dùng nhóm C (bài đầu tiên của Cấp 1: BT01) |
| Đã hoàn thành hết Cấp 4, đang ở Cấp 5 | Nhóm C lấy từ BT24 hoặc gợi ý "luyện tự do" (chọn lại BT bất kỳ để duy trì phong độ), không còn "lộ trình bắt buộc" |
| Không có bài nào cần retest, không có điểm yếu rõ rệt (dữ liệu quá ít) | Chỉ hiển thị nhóm C, ẩn hẳn banner retest thay vì hiện "0 mục" |
| Người dùng liên tục bấm "Tự chọn bài khác" thay vì theo đề xuất (>= 5 lần liên tiếp) | Ngừng ưu tiên hiển thị màn hình đề xuất làm mặc định — chuyển màn hình chính về danh sách đầy đủ, vẫn giữ tính năng đề xuất ở dạng nút phụ. (Tôn trọng người dùng muốn tự chủ, tránh ép buộc một UX họ không thích.) |

---

## 5. NỘI DUNG "XEM LÝ DO" CHO MỖI DÒNG ĐỀ XUẤT

Hiển thị ngắn gọn (1 câu), lấy trực tiếp từ dữ liệu đã tính, không cần viết tay từng trường hợp:

```
priority A_retest:  "Bạn chưa luyện bài này {days_since} ngày — nên ôn lại để giữ phong độ."
priority B_weakness: "Tỉ lệ thành công ở {condition} đang thấp hơn hẳn phần còn lại của bài này."
priority C_lo_trinh: "Đây là bước tiếp theo trong lộ trình Cấp {X} của bạn."
```

---

## 6. ĐỊNH NGHĨA HÀM (INTERFACE) CHO CODING ASSISTANT

```
function get_today_session(user_id, available_minutes) -> List[SessionItem]
    // Trả về danh sách bài tập đề xuất đã tính đủ 3 bước ở Mục 3.

function skip_item(user_id, session_draft, bt_id_to_skip) -> List[SessionItem]
    // Trả về danh sách mới sau khi thay thế 1 mục bị bỏ qua.

function log_session_completion(user_id, results: List[BTResult]) -> SessionSummary
    // Ghi nhận kết quả, gọi lại on_session_logged() đã đặc tả trong Dac-Ta-Timeline-Dong.md,
    // đồng thời cập nhật last_practiced_date cho từng bt_id (phục vụ tính retest ở lần sau).

type SessionItem = { bt_id, priority, estimated_minutes, reason_text }
```

---

## 7. GHI CHÚ THIẾT KẾ QUAN TRỌNG

- **Đừng để màn hình này cảm giác như "AI quyết định thay bạn"** — luôn giữ nút [Tự chọn bài khác] rõ ràng, và cho phép bỏ qua từng mục dễ dàng. Mục tiêu là giảm ma sát ra quyết định, không phải tước quyền chọn.
- **`estimated_minutes` nên đo thực tế theo thời gian** (không chỉ ước tính tĩnh) sau khi có đủ dữ liệu — lưu lại thời gian thực tế người dùng hoàn thành mỗi BT, dùng trung bình động để tinh chỉnh bảng cấu hình theo từng người dùng (người đánh chậm hơn/nhanh hơn mức trung bình).
- Toàn bộ ngưỡng số trong đặc tả này (14/21/30 ngày, 20 điểm %, giới hạn 2 mục nhóm A...) là giá trị khởi tạo hợp lý — nên đặt trong config, không hard-code, vì sẽ cần tinh chỉnh sau khi có phản hồi người dùng thật.
