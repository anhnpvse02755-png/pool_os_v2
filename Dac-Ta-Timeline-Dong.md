# ĐẶC TẢ: TIMELINE ĐỘNG (ADAPTIVE TIMELINE)
### Cho app luyện tập billiard — dùng cùng với Lo-Trinh-Hoc-Theo-Trinh-Do.md

Tài liệu này đặc tả **logic tính toán và cập nhật timeline** sau khi người dùng trả lời câu hỏi khởi đầu (onboarding), để đưa cho Claude CLI/coding assistant triển khai trực tiếp.

---

## 1. VẤN ĐỀ CẦN GIẢI QUYẾT

Hiện tại app đã có: (a) câu hỏi khởi đầu xác định trình độ, (b) hệ thống Cấp độ 1→5 với Mục kiến thức + Bài tập.

Còn thiếu:
- Sau khi trả lời câu hỏi khởi đầu → chưa hiển thị **timeline dự kiến** (ví dụ: "Dự kiến hoàn thành Cấp 2 trong 6 tuần").
- Timeline chưa **tự cập nhật** khi người dùng luyện tập nhanh/chậm hơn, bỏ buổi, hoặc luyện không đúng thứ tự.

---

## 2. MÔ HÌNH DỮ LIỆU (DATA MODEL)

### 2.1. Bảng cấu hình tĩnh: `effort_points` (điểm nỗ lực) cho mỗi Bài tập

Đây là số liệu **cấu hình sẵn trong app** (không đổi theo người dùng), ước tính số "đơn vị buổi tập" trung bình cần thiết để một người đi từ 0 đến đạt tiêu chí "Chuyên nghiệp" (~90-95%) ở bài tập đó, giả định 3 buổi/tuần. Dùng làm mẫu số chung để tính toán, không phải thời gian thật của từng người.

```json
{
  "cap_1": {
    "BT01": 2, "BT02": 2, "BT03": 4, "BT06": 2
  },
  "cap_2": {
    "BT04": 3, "BT05": 3, "BT07": 6, "BT08": 5, "BT09": 4
  },
  "cap_3": {
    "BT10": 4, "BT11": 4, "BT21": 3, "BT22": 4
  },
  "cap_4": {
    "BT12": 4, "BT13": 6, "BT14": 6, "BT15": 4, "BT16": 5,
    "BT17": 5, "BT18": 6, "BT19": 5, "BT20": 3, "BT23": 7
  },
  "cap_5": {
    "BT24": 6, "continuous_buffer": 12
  }
}
```

*(Tổng theo cấp: Cấp1=10, Cấp2=21, Cấp3=15, Cấp4=51, Cấp5=18 — khớp với bảng ước tính "3-9 tháng" đã thảo luận trước đó ở mức 3 buổi/tuần.)*

Mỗi bài tập còn có 3 "nấc chuyển" tương ứng 4 mức tỉ lệ thành công đã thiết kế (Mới tập → Cơ bản → Khá → Chuyên nghiệp). Chia đều effort_points cho 3 nấc, trừ khi muốn tinh chỉnh (nấc cao thường khó hơn nấc thấp — có thể dùng tỉ lệ 20%/30%/50% thay vì chia đều 33/33/33 nếu muốn phản ánh đúng thực tế "càng gần đỉnh càng khó lên").

### 2.2. Dữ liệu người dùng cần lưu

```json
{
  "user_id": "...",
  "onboarding": {
    "frequency_commitment": "light | medium | intensive",  // 2 / 3-4 / 5+ buổi/tuần
    "placement_test_result": { "cap_bat_dau": 1, "skipped_items": ["BT01","BT02"] }
  },
  "progress": {
    "BT01": { "current_tier": 2, "history": [ {"date": "...", "attempts": 10, "success": 7} ] },
    "BT07": { "current_tier": 1, "history": [ ... ] },
    "...": "..."
  },
  "session_log": [
    { "date": "2026-09-01", "exercises_practiced": ["BT01","BT03"], "duration_min": 40 },
    { "date": "2026-09-03", "exercises_practiced": ["BT01"], "duration_min": 25 }
  ]
}
```

---

## 3. TÍNH TIMELINE BAN ĐẦU (SAU ONBOARDING)

**Bước 1 — Xác định điểm nỗ lực còn lại (`remaining_effort`):**
```
remaining_effort = tổng effort_points của mọi BT từ cấp hiện tại (theo placement test)
                    đến hết Cấp 4 (Cấp 5 tính riêng vì không có điểm "hoàn thành")
```
Nếu placement test cho thấy người dùng đã đạt tier cao hơn ở một số BT cụ thể (ví dụ đã "Khá" ở BT01), chỉ tính phần effort_points còn lại của BT đó (1 nấc còn lại thay vì 3 nấc).

**Bước 2 — Xác định nhịp độ dự kiến (`planned_pace`):**
```
planned_pace (buổi/tuần) = 2   nếu frequency_commitment = "light"
                          = 3.5 nếu = "medium"
                          = 6   nếu = "intensive"
```

**Bước 3 — Tính ETA ban đầu:**
```
ETA_tuan = remaining_effort / planned_pace
```

**Hiển thị:** "Dự kiến hoàn thành Cấp 2 trong khoảng **X tuần** (luyện ~Y buổi/tuần). Đây là ước tính ban đầu, sẽ tự điều chỉnh theo tốc độ luyện tập thực tế của bạn."

→ Luôn hiển thị kèm câu "ước tính, sẽ điều chỉnh" để tránh người dùng hiểu nhầm là deadline cứng.

---

## 4. CẬP NHẬT TIMELINE ĐỘNG (KHI NGƯỜI DÙNG LUYỆN LỆCH KẾ HOẠCH)

### 4.1. Nguyên tắc chung
Timeline **không dựa vào lịch** (không tính "còn N ngày tới deadline"), mà dựa vào **tốc độ hoàn thành effort_points thực tế** — nên tự động đúng dù người dùng nghỉ 2 tuần rồi luyện dồn dập, hay luyện đều đặn.

### 4.2. Công thức tính nhịp độ thực tế (`actual_pace`)

Dùng **cửa sổ trượt (rolling window)** thay vì tính từ ngày đầu tiên (để phản ánh đúng thói quen *gần đây* thay vì trung bình cả quá trình — quan trọng vì thói quen luyện tập hay thay đổi):

```
window = 14 ngày gần nhất (có thể để người dùng chỉnh: 7 / 14 / 30 ngày)

so_buoi_thuc_te = đếm số session_log trong window
actual_pace (buổi/tuần) = so_buoi_thuc_te / (window_ngay / 7)
```

**Xử lý trường hợp mới cài app (chưa đủ dữ liệu window):**
```
Nếu so_buoi_thuc_te < 3 (chưa đủ tin cậy):
    dùng planned_pace (từ onboarding) thay vì actual_pace
Ngược lại:
    dùng trọng số kết hợp để tránh dao động quá mạnh chỉ vì 1-2 buổi bất thường:
    blended_pace = 0.7 * actual_pace + 0.3 * planned_pace
```

### 4.3. Cập nhật `remaining_effort` sau mỗi buổi tập

Sau mỗi lần người dùng nhập kết quả bài tập (số cú/tỉ lệ đạt):

```
Với mỗi BT vừa luyện:
    tier_cu = current_tier lưu trước đó
    tier_moi = tier tính được từ kết quả mới (dựa trên bảng % đã thiết kế)

    Nếu tier_moi > tier_cu:
        remaining_effort -= effort_points_per_tier(BT) * (tier_moi - tier_cu)
        current_tier = tier_moi

    Nếu tier_moi < tier_cu (bị tụt — xem mục 4.4):
        xử lý theo logic thoái lui
```

### 4.4. Xử lý "thoái lui" (regression) — người dùng làm tệ hơn lần trước

Đây là tình huống **quan trọng nhưng dễ bị bỏ sót**: người dùng đã từng đạt "Khá" ở BT07 nhưng 2 tuần không luyện, giờ test lại chỉ đạt "Cơ bản".

```
Nếu tier_moi < tier_cu:
    remaining_effort += effort_points_per_tier(BT) * (tier_cu - tier_moi) * 0.5
    // hệ số 0.5 vì "ôn lại" luôn nhanh hơn "học lần đầu"
    current_tier = tier_moi   // hạ tier hiển thị xuống mức thực tế
    hiển thị thông báo: "Có vẻ [Kỹ thuật X] cần ôn lại một chút — mình đã
                         điều chỉnh lại lộ trình, không sao cả, đây là chuyện bình thường."
```

*(Giọng điệu thông báo quan trọng: không nên tạo cảm giác "phạt" người dùng vì bỏ tập — dễ khiến họ bỏ app luôn.)*

### 4.5. Công thức ETA cập nhật (chạy lại sau mỗi buổi tập hoặc mỗi ngày)

```
ETA_tuan_moi = remaining_effort / blended_pace
```

Chỉ **hiển thị lại** cho người dùng khi độ lệch đủ lớn để có ý nghĩa (tránh làm phiền vì số nhảy liên tục từng chút một):
```
Nếu |ETA_moi - ETA_hien_thi_gan_nhat| >= 3 ngày:
    cập nhật số hiển thị + có thể kèm thông báo nhẹ ("Bạn đang luyện nhanh hơn dự kiến — 
    còn khoảng X tuần nữa thôi!" hoặc "Timeline đã điều chỉnh lại theo nhịp độ gần đây của bạn").
Ngược lại:
    giữ nguyên số cũ, chỉ cập nhật ngầm trong dữ liệu.
```

---

## 5. XỬ LÝ LUYỆN "KHÔNG ĐÚNG THỨ TỰ" (VD: LÀM BT12 KHI CHƯA XONG CẤP 2)

Nên **cho phép** (không khóa cứng), nhưng xử lý như sau:

```
Nếu người dùng luyện 1 BT thuộc cấp cao hơn cấp hiện tại đang "active":
    - Vẫn ghi nhận kết quả bình thường vào progress của BT đó.
    - KHÔNG trừ vào remaining_effort của cấp hiện tại (vì không phải nội dung đang học).
    - Hiển thị nhẹ nhàng: "Đây là nội dung của Cấp [X] — bạn có thể luyện thử,
      nhưng lộ trình chính vẫn đang ở Cấp [Y]."
    - Nếu người dùng đạt tier cao (>= Khá) ở BT vượt cấp NHIỀU LẦN liên tiếp
      cho nhiều BT của cấp đó → gợi ý chạy lại placement test để xem có nên
      chính thức nhảy cấp không (không tự động nhảy — luôn cần xác nhận từ người dùng).
```

---

## 6. HIỂN THỊ UI GỢI Ý

- **Thanh tiến độ theo cấp** (không phải theo % tổng toàn bộ hành trình — dễ gây nản vì Cấp 4 rất nặng): hiển thị riêng "Cấp hiện tại: 60% hoàn thành" + "Cấp tiếp theo dự kiến: ~4 tuần nữa".
- **Không hiển thị ngày cụ thể** kiểu "Hoàn thành vào 15/11/2026" — vì con người dễ coi đó là deadline cứng và thất vọng khi trễ. Chỉ nên hiện dạng tương đối: "~4 tuần nữa" hoặc "~1 tháng nữa".
- **Biểu đồ nhỏ nhịp độ luyện tập** (buổi/tuần trong 4-8 tuần gần nhất) giúp người dùng tự thấy vì sao timeline thay đổi — tăng tính minh bạch, giảm cảm giác "app tự đoán mò".
- Khi có **thoái lui**: dùng tông màu trung tính (không đỏ/cảnh báo) — ví dụ vàng nhạt kèm icon nhẹ nhàng, tránh gamification kiểu "mất streak" gây áp lực tiêu cực.

---

## 7. TÓM TẮT PSEUDOCODE TỔNG THỂ

```
function on_session_logged(user, session_results):
    for (bt, result) in session_results:
        tier_cu = user.progress[bt].current_tier
        tier_moi = compute_tier(result)  // dựa vào % thành công đạt được

        if tier_moi > tier_cu:
            user.remaining_effort -= effort_points(bt, tier_cu, tier_moi)
        elif tier_moi < tier_cu:
            user.remaining_effort += effort_points(bt, tier_moi, tier_cu) * 0.5
            notify_gentle_regression(bt)

        user.progress[bt].current_tier = tier_moi
        user.progress[bt].history.append(result)

    user.session_log.append(today_session)

    actual_pace = compute_actual_pace(user.session_log, window=14)
    blended_pace = blend(actual_pace, user.onboarding.planned_pace)
    new_eta = user.remaining_effort / blended_pace

    if abs(new_eta - user.displayed_eta) >= 3/7 (tuần):
        update_displayed_eta(new_eta)
        maybe_notify_user(new_eta, user.displayed_eta)

    user.displayed_eta = new_eta
```

---

## 8. GHI CHÚ KHI TRIỂN KHAI

- Toàn bộ số liệu `effort_points` ở Mục 2.1 là **giá trị khởi tạo hợp lý**, không phải số đo khoa học — nên để dễ chỉnh sửa qua file cấu hình (JSON/DB) thay vì hard-code, vì bạn (hoặc dữ liệu người dùng thật sau này) có thể cần tinh chỉnh lại theo phản hồi thực tế.
- Khi có đủ dữ liệu từ nhiều người dùng (sau vài tháng vận hành), có thể thay `effort_points` cố định bằng **trung bình thực tế đo được** từ chính người dùng app — lúc đó độ chính xác của timeline sẽ tăng đáng kể mà không cần thay đổi kiến trúc, chỉ cần thay nguồn số liệu đầu vào.
- Cân nhắc thêm cờ `paused` cho người dùng chủ động tạm dừng (đi công tác, nghỉ ốm...) để không tính window nghỉ đó vào "thoái lui" — tránh app hiểu nhầm nghỉ có chủ đích thành mất phong độ.
