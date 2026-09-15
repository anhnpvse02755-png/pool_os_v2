# ĐẶC TẢ CHI TIẾT: CÁC TÍNH NĂNG BỔ SUNG CHO APP LUYỆN TẬP
### Dùng cùng Lo-Trinh-Hoc-Theo-Trinh-Do.md và Dac-Ta-Timeline-Dong.md

Tài liệu này đặc tả chi tiết (mô hình dữ liệu, logic, pseudocode, UI) cho 9 ý tưởng đã đề xuất, để đối chiếu/nâng cấp phiên bản hiện có trong app hoặc đưa thẳng cho Claude CLI triển khai.

---

## 1. BẢN ĐỒ ĐIỂM YẾU THEO GÓC / KỸ THUẬT

### Mục tiêu
Thay vì hiển thị 1 con số % chung cho cả bài tập, tách nhỏ theo biến số đã có sẵn trong dữ liệu (góc cắt, cự ly, loại xoáy) để chỉ đúng điểm yếu cụ thể.

### Dữ liệu cần lưu (mở rộng từ `session_log` đã có)
```json
{
  "bt_id": "BT03",
  "date": "2026-09-10",
  "attempts_detail": [
    { "condition": "0deg", "attempts": 5, "success": 5 },
    { "condition": "30deg", "attempts": 5, "success": 4 },
    { "condition": "45deg", "attempts": 5, "success": 2 },
    { "condition": "60deg", "attempts": 5, "success": 1 }
  ]
}
```
Áp dụng tương tự cho các BT có nhiều điều kiện con: BT05 (sát băng vs giữa bàn), BT07 (follow/draw/stun riêng), BT08 (xoáy trái/phải), BT17 (mức lực 2/4/6/8/10).

### Logic tính "điểm yếu nổi bật"
```
Với mỗi (bt_id, condition):
    tỉ_lệ_gần_đây = success / attempts, tính trên N lần log gần nhất (N=5)

so_sánh tỉ_lệ_gần_đây giữa các condition trong CÙNG một bt_id
    → condition có tỉ lệ thấp nhất VÀ thấp hơn trung bình các condition khác >= 20 điểm %
    → gắn cờ "điểm yếu nổi bật"
```
Ngưỡng 20 điểm % để tránh báo động giả khi chênh lệch chỉ do may rủi số lượng nhỏ (5 cú/lần).

### UI gợi ý
- Biểu đồ dạng "radar chart" hoặc thanh ngang cho mỗi BT có nhiều condition, tô màu đỏ nhạt condition yếu nhất.
- Nhấn vào điểm yếu → dẫn thẳng tới đúng bài tập luyện lại condition đó (không phải luyện lại cả bài).

---

## 2. NHẬT KÝ LỖI TỔNG HỢP THEO THỜI GIAN

### Mục tiêu
Gộp các lỗi cụ thể (đã liệt kê sẵn trong từ điển — ví dụ 5 hiện tượng lỗi ở Mục 9 "Đứng bi") thành một nhật ký có thể tra cứu, phát hiện lỗi lặp lại xuyên suốt nhiều buổi/nhiều bài tập.

### Dữ liệu cần lưu
```json
{
  "date": "2026-09-10",
  "bt_id": "BT07",
  "tagged_errors": ["stun_re_hut_lui", "stun_re_trai_phai"]
}
```
Mỗi lỗi trong từ điển kiến thức nên có một `error_id` chuẩn hóa (slug), dùng chung giữa các Mục/BT liên quan — ví dụ lỗi "đầu cơ lệch ngang" xuất hiện ở cả Mục 9 (stun) và Mục 7 (follow) thì dùng chung 1 `error_id: "dau_co_lech_ngang"`.

### Logic phát hiện lỗi gốc rễ lặp lại
```
Đếm tần suất mỗi error_id trong 30 ngày gần nhất, xuyên suốt MỌI bt_id (không chỉ 1 bài).

Nếu error_id xuất hiện >= 3 lần VÀ ở >= 2 bt_id khác nhau:
    → tra bảng ánh xạ error_id → mục_gốc_rễ (cấu hình sẵn, ví dụ:
        "dau_co_lech_ngang" → gợi ý ôn lại Mục 3 - Cầu tay, Mục 4 - Cú đẩy cơ)
    → hiển thị gợi ý: "Lỗi [X] đang lặp lại ở nhiều bài tập khác nhau — 
       có thể gốc rễ nằm ở [Mục Y], bạn có muốn ôn lại không?"
```
Đây là bảng ánh xạ tĩnh (`error_id → mục_gốc_rễ`), không cần machine learning, chỉ cần bạn liệt kê thủ công vì bạn đã biết rõ mối liên hệ giữa các lỗi (giống cách mình phân tích lỗi "rẽ trái/phải" ở Mục 9 vốn thực ra là lỗi cầu tay từ Mục 3).

### UI gợi ý
- Tab "Nhật ký lỗi" dạng timeline, mỗi lỗi là 1 thẻ nhỏ có ngày + bài tập liên quan.
- Bộ lọc theo error_id để xem toàn bộ lịch sử của riêng 1 lỗi.

---

## 3. RETEST ĐỊNH KỲ CHỦ ĐỘNG

### Mục tiêu
Chủ động nhắc test lại các BT đã đạt tier cao nhưng lâu chưa luyện, để bắt thoái lui sớm thay vì bị động.

### Logic
```
Với mỗi BT đã có current_tier >= 2 (Cơ bản trở lên):
    ngay_luyen_gan_nhat = ngày log gần nhất của BT đó
    neu (hom_nay - ngay_luyen_gan_nhat) >= nguong_ngay(current_tier):
        đưa vào danh sách "cần retest"

nguong_ngay gợi ý:
    tier "Cơ bản" (2): 14 ngày
    tier "Khá" (3): 21 ngày
    tier "Chuyên nghiệp" (4): 30 ngày
    (tier càng cao, kỹ năng càng "chắc", ngưỡng thời gian trước khi lo ngại thoái lui càng dài)
```
Danh sách "cần retest" được ưu tiên hiển thị khi tạo buổi tập mới (xem mục 4), không phải thông báo đẩy gây phiền.

### UI gợi ý
- Badge nhỏ "Nên retest" trên thẻ bài tập trong danh sách.
- Không dùng thông báo push dồn dập — gộp chung vào 1 gợi ý nhẹ mỗi khi mở app, kiểu "Có 2 kỹ năng lâu rồi bạn chưa ôn, muốn kiểm tra không?"

---

## 4. TRÌNH TẠO BUỔI TẬP THEO THỜI GIAN RẢNH

### Mục tiêu
Người dùng nhập số phút rảnh → app tự chọn tổ hợp bài tập phù hợp, không cần tự quyết định.

### Input
```json
{ "available_minutes": 20 }
```

### Logic chọn bài tập (thứ tự ưu tiên)
```
1. Lấy danh sách "cần retest" (mục 3) — ưu tiên cao nhất, tối đa 1-2 bài.
2. Lấy danh sách "điểm yếu nổi bật" (mục 1) — ưu tiên thứ 2.
3. Lấy bài tập tiếp theo theo đúng lộ trình (cấp hiện tại, thứ tự BT chưa đạt tier mục tiêu).
4. Cộng dồn ước tính thời gian mỗi bài (ví dụ: 10 cú ~ 5-7 phút bao gồm nhặt bi/ngắm)
   cho đến khi gần chạm available_minutes (chừa dư 10-15% thời gian).
```
Bảng ước tính phút/bài tập (cấu hình sẵn theo số cú của mỗi BT, ví dụ N=10 → ~7 phút, N=15 → ~10 phút).

### UI gợi ý
- Nút to "Tôi có bao nhiêu phút?" ngay màn hình chính, kèm 3 lựa chọn nhanh (15 / 30 / 60 phút) + tùy chỉnh.
- Kết quả hiển thị dạng checklist buổi tập hôm nay, có thể kéo-thả đổi thứ tự hoặc bỏ bớt nếu muốn.

---

## 5. ĐỘ KHÓ TỰ THÍCH ỨNG TRONG CÙNG 1 BÀI

### Mục tiêu
Tránh nhảy cấp độ khó theo bậc thang cứng (0°→30°→45°→60°), thay bằng điều chỉnh mượt hơn.

### Logic (áp dụng cho BT có biến liên tục như góc cắt, cự ly)
```
Bắt đầu ở difficulty_level hiện tại (ví dụ góc = 30°).
Sau mỗi set 5 cú:
    tỉ_lệ = success/5
    nếu tỉ_lệ >= 80%: difficulty_level += step (ví dụ +5-10°)
    nếu tỉ_lệ <= 40%: difficulty_level -= step (lùi lại, tránh nản)
    nếu 40% < tỉ_lệ < 80%: giữ nguyên difficulty_level, luyện thêm 1 set nữa
```
Đây là mô hình "cầu thang thích ứng" (staircase adaptive) — dùng phổ biến trong các app học ngôn ngữ/thính lực, đơn giản, không cần AI, chỉ cần lưu `difficulty_level` dạng số liên tục thay vì enum cố định (0/30/45/60).

### Lưu ý khi triển khai
- Vẫn giữ 4 mốc chính (0°/30°/45°/60°) làm "chuẩn hiển thị" cho tiêu chí đạt cấp — độ khó liên tục chỉ là cách *luyện tập giữa các mốc* mượt hơn, không thay đổi cách tính tiêu chí lên cấp đã thiết kế.

---

## 6. THƯ VIỆN CÔNG CỤ TÍNH TOÁN (DIAMOND SYSTEM)

### Mục tiêu
Công cụ thực dụng, tách biệt khỏi phần "học" — dùng được ngay cả khi đang chơi thật ngoài bàn.

### Input/Output đơn giản
```
Input: vị trí bi cái (tọa độ tương đối trên bàn, theo lưới kim cương 0-8 mỗi cạnh),
       vị trí bi mục tiêu hoặc điểm cần bi cái đi tới sau khi chạm băng.
Output: điểm ngắm trên băng (số kim cương), gợi ý minh họa bằng hình vẽ đường đi.
```

### Cách triển khai đơn giản nhất (không cần vật lý phức tạp)
Dùng công thức hệ thống kim cương cơ bản (ví dụ hệ thống "Corner 5" phổ biến cho kick 1 băng):
```
diamond_effective = diamond_cue_ball - diamond_target_point
diamond_aim = diamond_effective / 2   // với hệ số hiệu chỉnh theo hệ thống cụ thể đang dùng
```
*(Đây chỉ là khung — cần chọn đúng 1 hệ thống kim cương cụ thể (Corner 5, Plus system...) để cài công thức chính xác; có thể để mình đặc tả chi tiết hệ thống nào nếu bạn chọn.)*

### UI gợi ý
- Vẽ bàn billiard đơn giản (SVG/canvas), người dùng chạm để đặt bi cái + bi mục tiêu → app vẽ đường ngắm gợi ý ngay trên hình.
- Có nút "Bật khi đang chơi thật" — chế độ full-screen dễ nhìn nhanh giữa ván đấu.

---

## 7. CHẾ ĐỘ GHI NHẬN TRẬN ĐẤU THẬT

### Mục tiêu
Đo xem kỹ năng luyện trong app có chuyển hóa ra trận thật không — thước đo quan trọng nhất nhưng khác hẳn về bản chất với luyện tập có cấu trúc (drill).

### Dữ liệu cần lưu (nhập nhanh sau trận, tối giản để không gây ngại nhập liệu)
```json
{
  "date": "2026-09-10",
  "game_type": "8-ball | 9-ball | 10-ball | straight-pool | one-pocket",
  "result": "thang | thua",
  "self_rating": 1-5,             // cảm nhận chủ quan về phong độ hôm đó
  "notable_errors": ["pham_luat_goi_bi", "mat_vi_tri_lien_tuc"],  // chọn nhanh từ danh sách có sẵn, không gõ tay
  "safety_success_est": "nhieu | vua | it | khong_choi"
}
```
Giữ tối giản (chọn nút bấm, không cần gõ chữ) vì nhập liệu sau 1 trận đấu thật dễ bị lười — nếu form quá dài, tính năng này sẽ chết yểu.

### Logic đối chiếu với luyện tập
```
So sánh notable_errors của trận thật với error_id trong "Nhật ký lỗi" (mục 2):
    nếu trùng lỗi đã luyện nhiều nhưng vẫn xảy ra ở trận thật
    → hiển thị insight: "Lỗi [X] đã luyện tốt trong bài tập nhưng vẫn xuất hiện 
      khi chơi thật — có thể do áp lực tâm lý (xem Mục 23) hoặc thế bi thực tế
      phức tạp hơn bài tập mô phỏng."
```
Đây là insight có giá trị thật, phản ánh đúng khoảng cách kinh điển giữa "luyện" và "thi đấu".

### UI gợi ý
- Nút nổi "+ Ghi nhận trận đấu" luôn có sẵn, không cần vào sâu trong app.
- Biểu đồ tỉ lệ thắng/thua theo thời gian, chồng lên timeline cấp độ để xem có tương quan không.

---

## 8. XUẤT BÁO CÁO TIẾN ĐỘ ĐỊNH KỲ

### Mục tiêu
Tổng hợp định kỳ (hàng tháng) để người dùng tự nhìn lại, không cần họ tự lục dữ liệu.

### Nội dung báo cáo (tự động tổng hợp từ dữ liệu đã có)
1. Cấp độ hiện tại + % hoàn thành cấp đó.
2. Timeline hiện tại vs timeline lúc đầu tháng (đang nhanh hơn hay chậm hơn dự kiến).
3. Top 3 lỗi lặp lại nhiều nhất trong tháng (từ Nhật ký lỗi).
4. Biểu đồ nhịp luyện tập (số buổi/tuần qua từng tuần trong tháng).
5. Kết quả trận đấu thật (nếu có dùng mục 7): tỉ lệ thắng/thua.
6. 1 câu gợi ý trọng tâm cho tháng tới (dựa trên lỗi phổ biến nhất).

### Triển khai
- Chạy 1 job định kỳ (đầu mỗi tháng) tổng hợp dữ liệu tháng trước → render thành file (HTML → xuất PDF, hoặc ảnh dùng canvas) → lưu vào lịch sử báo cáo trong app.
- Không cần real-time, chạy batch 1 lần/tháng là đủ.

### UI gợi ý
- Trang "Báo cáo" dạng danh sách các tháng, bấm vào xem lại/tải về.
- Nút chia sẻ ảnh (dạng card đẹp, không phải PDF khô khan) để dễ đăng mạng xã hội nếu người dùng muốn khoe.

---

## 9. KỶ LỤC CÁ NHÂN & THỬ THÁCH HÀNG TUẦN

### 9.1. Kỷ lục cá nhân (Personal Best)
```json
{
  "bt_id": "BT07",
  "record_type": "longest_streak | highest_rate_in_session | fastest_tier_up",
  "value": 14,
  "date_achieved": "2026-09-10"
}
```
Logic: sau mỗi buổi, so sánh với `record_type` đã lưu, nếu vượt → cập nhật + hiệu ứng nhỏ ăn mừng trong UI (không cần âm thanh/rung quá đà, tránh cảm giác "trẻ con" với người chơi nghiêm túc).

**Quan trọng:** Không hiển thị kỷ lục dạng so sánh với người khác (leaderboard) trừ khi người dùng chủ động bật chế độ cộng đồng — mục tiêu là động lực nội tại (so với chính mình), tránh áp lực so sánh xã hội.

### 9.2. Thử thách hàng tuần (không bắt buộc)
```
Đầu mỗi tuần, random 1 BT thuộc đúng cấp hiện tại của người dùng
(ưu tiên BT có current_tier thấp nhất trong cấp, để vừa là thử thách vừa là ôn điểm yếu)
→ hiển thị dạng "Thử thách tuần này: BT08 — thử đạt 8/10!"
```
Không có hình phạt nếu bỏ qua — chỉ là gợi ý đổi gió, biến mất sau 7 ngày, không dồn lại gây áp lực nợ nần thử thách.

---

## GHI CHÚ CHUNG CHO TOÀN BỘ TÍNH NĂNG

- Tất cả các bảng ánh xạ tĩnh (`effort_points`, `error_id → mục_gốc_rễ`, thời gian ước tính mỗi BT...) nên đặt trong 1 file cấu hình chung (JSON/DB config), không hard-code rải rác — vì bạn sẽ còn tinh chỉnh nhiều lần dựa trên phản hồi thực tế.
- Ưu tiên triển khai theo thứ tự: (3) Retest chủ động và (4) Trình tạo buổi tập trước — vì chúng dùng chung hạ tầng dữ liệu với Timeline Động đã có, chi phí thêm thấp nhất, giá trị sử dụng hàng ngày cao nhất. (6) Diamond system và (7) Ghi nhận trận đấu thật có thể làm sau vì là module tương đối độc lập.
