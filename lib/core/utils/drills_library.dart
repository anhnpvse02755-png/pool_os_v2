// ===========================================================================
// SINH TU DONG tu `new knowledge/Danh-Sach-Bai-Tap-Billiard.md`
// bang `tools/gen_drills.py`. Sua nguon roi chay lai, dung sua tay file nay.
// ===========================================================================

/// Thu vien bai tap thuc hanh.
///
/// `levels` la THANG TIEN BO: cap 1 dung dung nguong ghi trong nguon, cap tren
/// tang ca ti le lan co mau. Tran cua cap cao nhat phu thuoc ban chat cu danh —
/// ~91% (50/55) cho cu ti le cao, ~80% cho trung binh, ~60% cho cu von ti le
/// thap nhu bank/jump/kick. Co mau lon dan vi o 10 lan thu thi 9/10 va 7/10
/// gan nhu khong phan biet duoc.
///
/// Bai nao nguon KHONG neu nguong so thi `passCount` = 0 va `criteriaVi` giu
/// nguyen van tieu chi — UI phai uu tien hien `criteriaVi`.
class DrillLibrary {
  static const List<DrillCategory> categories = [
    DrillCategory(
      id: 'fundamentals',
      name: 'Fundamentals',
      nameVi: 'Nền tảng',
      icon: 'sports_martial_arts',
      drills: [
        Drill(
          code: 'BT01',
          name: 'Grip & Straight Stroke',
          nameVi: 'Luyện cầm cơ & đẩy cơ thẳng',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Tạo phản xạ nắm cơ đúng lực và đường đẩy cơ thẳng, không lệch trái/phải.',
          setup: 'Đặt bi cái ở đầu bàn, không có bi mục tiêu — chỉ tập đẩy cơ.',
          steps: [
            'Đặt bi cái ở đầu bàn, không có bi mục tiêu — chỉ tập đẩy cơ.',
            'Đẩy cơ 10 lần liên tiếp cho bi cái đi thẳng dọc theo một đường kẻ tưởng tượng (hoặc dùng dây/thước làm mốc), chạm băng cuối và quay lại.',
            'Quan sát bi có đi lệch khỏi đường thẳng hay không sau mỗi lần.',
          ],
          goal: 'Tạo phản xạ nắm cơ đúng lực và đường đẩy cơ thẳng, không lệch trái/phải.',
          criteriaVi: '8/10 lần bi cái đi thẳng, lệch không quá bề rộng 1 viên bi khi tới băng cuối.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_grip', 'kn_stroke'],
        ),
        Drill(
          code: 'BT02',
          name: 'Stance & Bridge Consistency',
          nameVi: 'Giữ tư thế và cầu tay cố định',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Rèn tính nhất quán của tư thế đứng và cầu tay ở mọi cú đánh.',
          setup: 'Vào tư thế đánh một bi thẳng đơn giản (bi cái – bi mục tiêu – lỗ thẳng hàng).',
          steps: [
            'Vào tư thế đánh một bi thẳng đơn giản (bi cái – bi mục tiêu – lỗ thẳng hàng).',
            'Thực hiện 3 lần đẩy cơ thử (practice stroke), giữ đầu và cầu tay hoàn toàn bất động.',
            'Đánh thật, sau đó tự đánh giá: đầu có nhấc lên trước khi bi chạm đích không?',
            'Lặp lại 15 cú, ghi nhận số lần giữ đầu cố định thành công.',
          ],
          goal: 'Rèn tính nhất quán của tư thế đứng và cầu tay ở mọi cú đánh.',
          criteriaVi: '12/15 lần giữ đầu bất động đến khi bi mục tiêu đã vào lỗ hoặc dừng hẳn.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_stance', 'kn_bridge'],
        ),
        Drill(
          code: 'BT06',
          name: 'Controlled Break Shot',
          nameVi: 'Break shot có kiểm soát',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Break đủ lực để tán bi tốt nhưng vẫn giữ bi cái ở lại giữa bàn.',
          setup: 'Xếp bi theo hình tam giác (8-ball) hoặc kim cương (9-ball) đúng luật.',
          steps: [
            'Xếp bi theo hình tam giác (8-ball) hoặc kim cương (9-ball) đúng luật.',
            'Break 10 lần, mỗi lần ghi lại: (a) số bi vào lỗ, (b) vị trí bi cái sau break (giữa bàn / dính băng / rơi khỏi bàn).',
            'Điều chỉnh lực và điểm ngắm nếu bi cái thường xuyên văng khỏi khu vực trung tâm.',
          ],
          goal: 'Break đủ lực để tán bi tốt nhưng vẫn giữ bi cái ở lại giữa bàn.',
          criteriaVi: 'Bi cái ở lại trong khu vực 1/2 bàn phía trên (không dính băng cuối) ít nhất 7/10 lần, không nhấc bi khỏi bàn lần nào.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_break_shot'],
        ),
      ],
    ),
    DrillCategory(
      id: 'aiming',
      name: 'Aiming',
      nameVi: 'Ngắm đánh',
      icon: 'center_focus_strong',
      drills: [
        Drill(
          code: 'BT03',
          name: 'Ghost Ball by Increasing Angle',
          nameVi: 'Ngắm bi ảo (Ghost Ball) theo góc tăng dần',
          category: 'aiming',
          difficulty: 'easy',
          description: 'Luyện mắt ước lượng vị trí ghost ball chính xác ở nhiều góc cắt.',
          setup: 'Đặt bi mục tiêu cách lỗ khoảng 30-40cm, ở các góc cắt lần lượt: 0° (thẳng) → 30° → 45° → 60°.',
          steps: [
            'Đặt bi mục tiêu cách lỗ khoảng 30-40cm, ở các góc cắt lần lượt: 0° (thẳng) → 30° → 45° → 60°.',
            'Ở mỗi góc, đánh 5 cú, ghi lại số lần vào lỗ.',
            'Tăng góc cắt chỉ khi đã đạt tiêu chí ở góc hiện tại.',
          ],
          goal: 'Luyện mắt ước lượng vị trí ghost ball chính xác ở nhiều góc cắt.',
          criteriaVi: 'Đạt tối thiểu 4/5 ở góc 0°-30°, 3/5 ở góc 45°, 2/5 ở góc 60° trước khi coi là thành thạo cơ bản.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_aiming'],
        ),
        Drill(
          code: 'BT04',
          name: 'Six Aiming Reference Methods',
          nameVi: 'Bài tập 6 mốc ngắm phối hợp (Mép bi – Điểm xa/gần – Đầu gậy/mép bi)',
          category: 'aiming',
          difficulty: 'easy',
          description: 'Làm quen và so sánh 3 phương pháp ngắm bổ trợ cho ghost ball.',
          setup: 'Đặt cùng một thế bi cố định (góc cắt ~45°).',
          steps: [
            'Đặt cùng một thế bi cố định (góc cắt ~45°).',
            'Ngắm và đánh 5 cú chỉ dùng phương pháp mép bi (tỷ lệ 1/2 bi).',
            'Ngắm và đánh 5 cú chỉ dùng phương pháp điểm xa nhất – gần nhất.',
            'Ngắm và đánh 5 cú dùng phương pháp đầu gậy – mép bi (có pivot).',
            'So sánh tỷ lệ vào bi giữa 3 phương pháp để biết mình hợp với cách ngắm nào hơn.',
          ],
          goal: 'Làm quen và so sánh 3 phương pháp ngắm bổ trợ cho ghost ball.',
          criteriaVi: 'Xác định được phương pháp cho tỷ lệ vào bi cao nhất với bản thân (không yêu cầu tỷ lệ cụ thể — đây là bài tập nhận diện phong cách ngắm).',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 0),
          ],
          knowledgeIds: ['kn_aiming_fractional', 'kn_aiming_contact_point', 'kn_aiming_tip_to_edge'],
        ),
        Drill(
          code: 'BT05',
          name: 'Rail & Mid-table Cut Aiming',
          nameVi: 'Ngắm bi sát băng & bi góc lệch giữa bàn',
          category: 'aiming',
          difficulty: 'easy',
          description: 'Luyện phản xạ đổi phương pháp ngắm tùy vị trí bi mục tiêu.',
          setup: 'Đặt 5 bi mục tiêu dọc theo băng dọc (gần/dính băng), đánh vào lỗ góc gần nhất — dùng phương pháp điểm tiếp xúc bi–băng.',
          steps: [
            'Đặt 5 bi mục tiêu dọc theo băng dọc (gần/dính băng), đánh vào lỗ góc gần nhất — dùng phương pháp điểm tiếp xúc bi–băng.',
            'Đặt 5 bi mục tiêu ở giữa bàn với góc cắt trung bình (không sát băng) — dùng phương pháp điểm tiếp xúc mặt nỉ kết hợp ghost ball để kiểm tra chéo.',
            'Ghi nhận tỷ lệ vào bi ở từng nhóm.',
          ],
          goal: 'Luyện phản xạ đổi phương pháp ngắm tùy vị trí bi mục tiêu.',
          criteriaVi: 'Tối thiểu 3/5 ở mỗi nhóm; nếu dưới mức này, quay lại BT03 luyện thêm ghost ball cơ bản.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_aiming_rail_ball', 'kn_aiming_cloth_contact'],
        ),
      ],
    ),
    DrillCategory(
      id: 'shotmaking',
      name: 'Shot Making',
      nameVi: 'Kỹ thuật cú đánh',
      icon: 'sports_baseball',
      drills: [
        Drill(
          code: 'BT07',
          name: 'Stop - Follow - Draw at Fixed Distance',
          nameVi: 'Bài tập Stop – Follow – Draw trên cùng cự ly',
          category: 'shotmaking',
          difficulty: 'medium',
          description: 'Cảm nhận rõ sự khác biệt giữa 3 loại xoáy dọc cơ bản với cùng một cự ly và lực đánh.',
          setup: 'Đặt bi cái và bi mục tiêu thẳng hàng với lỗ, cách nhau ~40cm.',
          steps: [
            'Đặt bi cái và bi mục tiêu thẳng hàng với lỗ, cách nhau ~40cm.',
            'Đánh 5 cú stun (ngắm giữa tâm) — quan sát bi cái dừng tại chỗ va chạm.',
            'Đánh 5 cú follow (ngắm 1/2-3/4 phía trên tâm) — quan sát bi cái lăn tiếp theo bi mục tiêu.',
            'Đánh 5 cú draw (ngắm 1/2 phía dưới tâm) — quan sát bi cái lùi lại.',
          ],
          goal: 'Cảm nhận rõ sự khác biệt giữa 3 loại xoáy dọc cơ bản với cùng một cự ly và lực đánh.',
          criteriaVi: 'Nhận biết và mô tả đúng bằng lời sự khác biệt về khoảng cách di chuyển của bi cái ở cả 3 loại; bi cái không trượt cơ (miscue) quá 1 lần trong 15 cú.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_follow_shot', 'kn_draw_shot', 'kn_stop_shot'],
        ),
        Drill(
          code: 'BT08',
          name: 'Basic English through One Rail',
          nameVi: 'Xoáy ngang cơ bản qua 1 băng (English Drill)',
          category: 'shotmaking',
          difficulty: 'medium',
          description: 'Cảm nhận độ lệch (squirt) và hiệu ứng xoáy khi bi cái chạm băng.',
          setup: 'Đặt bi cái cách băng dọc khoảng 50cm, không có bi mục tiêu.',
          steps: [
            'Đặt bi cái cách băng dọc khoảng 50cm, không có bi mục tiêu.',
            'Đánh bi cái chạm băng bằng xoáy phải (đầu gậy lệch phải khoảng 1 tip), quan sát và đánh dấu điểm bi cái dừng lại.',
            'Lặp lại với xoáy trái, ghi nhận sự khác biệt hướng đi so với không xoáy (đánh tâm).',
            'Thử điều chỉnh điểm ngắm ban đầu để bù squirt, sao cho bi cái đi đến đúng một điểm đích cho trước.',
          ],
          goal: 'Cảm nhận độ lệch (squirt) và hiệu ứng xoáy khi bi cái chạm băng.',
          criteriaVi: 'Sau 10 lần thử, đưa được bi cái đến trong phạm vi 15cm quanh điểm đích mong muốn ít nhất 6/10 lần.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_english'],
        ),
        Drill(
          code: 'BT12',
          name: 'Recognising & Compensating Throw',
          nameVi: 'Nhận diện và bù Throw Effect',
          category: 'shotmaking',
          difficulty: 'hard',
          description: 'Cảm nhận mức độ lệch bi mục tiêu do throw ở các mức lực khác nhau.',
          setup: 'Đặt bi mục tiêu ở góc cắt nhỏ (~15-20°), đánh với lực nhẹ và có xoáy ngang — quan sát mức lệch so với đường ngắm lý thuyết (ghost ball).',
          steps: [
            'Đặt bi mục tiêu ở góc cắt nhỏ (~15-20°), đánh với lực nhẹ và có xoáy ngang — quan sát mức lệch so với đường ngắm lý thuyết (ghost ball).',
            'Lặp lại với lực mạnh hơn ở cùng thế bi, so sánh độ lệch.',
            'Ghi nhận độ bù góc ngắm cần thiết ở từng mức lực để bi vẫn vào đúng lỗ.',
          ],
          goal: 'Cảm nhận mức độ lệch bi mục tiêu do throw ở các mức lực khác nhau.',
          criteriaVi: 'Xác định được (bằng cảm nhận cá nhân) mức bù góc phù hợp để đạt tỷ lệ vào bi từ 6/10 trở lên ở lực nhẹ có xoáy.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_throw_squirt_swerve'],
        ),
        Drill(
          code: 'BT13',
          name: 'One-Rail Kick Shot',
          nameVi: 'Luyện Kick Shot 1 băng (Diamond System cơ bản)',
          category: 'shotmaking',
          difficulty: 'hard',
          description: 'Làm quen hệ thống điểm kim cương để tính góc kick 1 băng.',
          setup: 'Đặt bi mục tiêu ở một vị trí cố định, bi cái ở vị trí "bị khóa" cần kick 1 băng để chạm bi mục tiêu.',
          steps: [
            'Đặt bi mục tiêu ở một vị trí cố định, bi cái ở vị trí "bị khóa" cần kick 1 băng để chạm bi mục tiêu.',
            'Dùng hệ thống diamond để tính điểm chạm băng dự kiến, đánh với tốc độ trung bình cố định.',
            'Lặp lại 10 lần ở cùng một thế bi để hiệu chỉnh độ lệch riêng của bàn.',
          ],
          goal: 'Làm quen hệ thống điểm kim cương để tính góc kick 1 băng.',
          criteriaVi: 'Bi cái chạm trúng bi mục tiêu (không cần vào lỗ) ít nhất 5/10 lần.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 30, passCount: 8),
            DrillLevel(level: 2, attempts: 30, passCount: 12),
            DrillLevel(level: 3, attempts: 30, passCount: 16),
          ],
          knowledgeIds: ['kn_kick_shot'],
        ),
        Drill(
          code: 'BT14',
          name: 'Bank Shot to Side Pocket',
          nameVi: 'Bank Shot cơ bản vào lỗ giữa',
          category: 'shotmaking',
          difficulty: 'hard',
          description: 'Luyện xác định "lỗ ảo" và điểm chạm băng để bank bi mục tiêu vào lỗ.',
          setup: 'Đặt bi mục tiêu ở giữa bàn, xác định lỗ ảo đối xứng qua băng dọc gần nhất.',
          steps: [
            'Đặt bi mục tiêu ở giữa bàn, xác định lỗ ảo đối xứng qua băng dọc gần nhất.',
            'Đánh 10 lần với lực cố định (trung bình), ghi nhận tỷ lệ vào lỗ.',
            'Thử nghiệm điều chỉnh nhẹ điểm ngắm nếu bi liên tục lệch cùng một hướng.',
          ],
          goal: 'Luyện xác định "lỗ ảo" và điểm chạm băng để bank bi mục tiêu vào lỗ.',
          criteriaVi: 'Đạt 3/10 trở lên (bank shot vốn có tỷ lệ thấp hơn cú đánh trực tiếp — đây là mức chấp nhận được cho người mới luyện).',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 30, passCount: 8),
            DrillLevel(level: 2, attempts: 30, passCount: 12),
            DrillLevel(level: 3, attempts: 30, passCount: 16),
          ],
          knowledgeIds: ['kn_bank_shot'],
        ),
        Drill(
          code: 'BT15',
          name: 'Basic Jump Shot',
          nameVi: 'Jump Shot cơ bản (trên bàn/nỉ tập)',
          category: 'shotmaking',
          difficulty: 'hard',
          description: 'Làm quen góc nâng cơ tối thiểu để bi nhảy qua vật cản.',
          setup: '**Chỉ luyện trên bàn/nỉ tập, không dùng bàn thi đấu chính.**',
          steps: [
            '**Chỉ luyện trên bàn/nỉ tập, không dùng bàn thi đấu chính.**',
            'Đặt một bi cản giữa bi cái và bi mục tiêu, khoảng cách ngắn.',
            'Bắt đầu với góc nâng cơ nhỏ, tăng dần cho đến khi bi cái nhảy qua được vật cản.',
            'Ghi nhận góc nâng tối thiểu hiệu quả với bản thân.',
          ],
          goal: 'Làm quen góc nâng cơ tối thiểu để bi nhảy qua vật cản.',
          criteriaVi: 'Bi cái nhảy qua vật cản thành công (không chạm bi cản) ít nhất 4/10 lần mà không làm hỏng mặt nỉ.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 30, passCount: 8),
            DrillLevel(level: 2, attempts: 30, passCount: 12),
            DrillLevel(level: 3, attempts: 30, passCount: 16),
          ],
          knowledgeIds: ['kn_jump_shot'],
        ),
        Drill(
          code: 'BT16',
          name: 'Basic Combination',
          nameVi: 'Combination cơ bản (2 bi thẳng hàng)',
          category: 'shotmaking',
          difficulty: 'hard',
          description: 'Luyện ngắm nối tiếp 2 điểm tiếp xúc trong cú đánh combination.',
          setup: 'Đặt bi trung gian và bi cuối gần như thẳng hàng với lỗ (độ khó thấp).',
          steps: [
            'Đặt bi trung gian và bi cuối gần như thẳng hàng với lỗ (độ khó thấp).',
            'Đánh 10 lần, tập trung ngắm điểm tiếp xúc bi cái–bi trung gian trước, không nhìn dồn vào lỗ.',
            'Giảm dần độ thẳng hàng (tăng độ khó) khi đã đạt tỷ lệ ổn định.',
          ],
          goal: 'Luyện ngắm nối tiếp 2 điểm tiếp xúc trong cú đánh combination.',
          criteriaVi: '5/10 ở mức thẳng hàng dễ trước khi thử độ khó cao hơn.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_combination_carom'],
        ),
      ],
    ),
    DrillCategory(
      id: 'positioning',
      name: 'Positioning',
      nameVi: 'Kiểm soát vị trí',
      icon: 'my_location',
      drills: [
        Drill(
          code: 'BT09',
          name: 'Three-Ball Position Drill',
          nameVi: 'Bài tập vị trí 3 bi liên tiếp (3-Ball Position Drill)',
          category: 'positioning',
          difficulty: 'medium',
          description: 'Luyện tư duy tính trước vị trí bi cái cho cú kế tiếp, không chỉ tập trung ăn bi hiện tại.',
          setup: 'Đặt 3 bi ở 3 vị trí khác nhau trên bàn (không quá khó), có thể đánh lần lượt vào các lỗ khác nhau.',
          steps: [
            'Đặt 3 bi ở 3 vị trí khác nhau trên bàn (không quá khó), có thể đánh lần lượt vào các lỗ khác nhau.',
            'Trước mỗi cú, xác định trước "vùng đích" muốn bi cái dừng lại để thuận lợi cho bi tiếp theo.',
            'Đánh liên tiếp cả 3 bi mà không dừng; ghi nhận có đạt vùng đích dự kiến hay không sau mỗi cú.',
          ],
          goal: 'Luyện tư duy tính trước vị trí bi cái cho cú kế tiếp, không chỉ tập trung ăn bi hiện tại.',
          criteriaVi: 'Hoàn thành trọn vẹn chuỗi 3 bi (không bỏ lỡ bi nào) và đạt đúng vùng đích dự kiến ít nhất 2/3 lần, lặp lại bài với 5 bố cục bi khác nhau.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_position_play'],
        ),
        Drill(
          code: 'BT17',
          name: 'Speed Control on a 1-10 Scale',
          nameVi: 'Kiểm soát tốc độ theo thang 1-10',
          category: 'positioning',
          difficulty: 'hard',
          description: 'Rèn khả năng đánh nhiều mức lực khác nhau một cách nhất quán.',
          setup: 'Đặt bi cái ở đầu bàn. Định nghĩa 5 mức lực (2, 4, 6, 8, 10 trên thang 10 của bản thân).',
          steps: [
            'Đặt bi cái ở đầu bàn. Định nghĩa 5 mức lực (2, 4, 6, 8, 10 trên thang 10 của bản thân).',
            'Ở mỗi mức, đánh 5 lần bi cái đi thẳng, đo khoảng cách bi cái dừng lại (có thể đặt các mốc/băng dính trên bàn).',
            'So sánh độ lệch chuẩn (dao động) giữa các lần đánh ở cùng một mức lực.',
          ],
          goal: 'Rèn khả năng đánh nhiều mức lực khác nhau một cách nhất quán.',
          criteriaVi: 'Độ dao động khoảng cách dừng giữa 5 lần cùng mức lực không vượt quá 15-20cm.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_speed_control'],
        ),
      ],
    ),
    DrillCategory(
      id: 'strategy',
      name: 'Strategy',
      nameVi: 'Chiến thuật',
      icon: 'psychology_alt',
      drills: [
        Drill(
          code: 'BT10',
          name: 'Basic Safety - Screening One Ball',
          nameVi: 'Bài tập Safety cơ bản (Che chắn 1 bi)',
          category: 'strategy',
          difficulty: 'medium',
          description: 'Luyện đưa bi cái vào vị trí an toàn, khó cho "đối thủ giả định".',
          setup: 'Đặt 1 bi cản giữa bi cái và bi mục tiêu tưởng tượng.',
          steps: [
            'Đặt 1 bi cản giữa bi cái và bi mục tiêu tưởng tượng.',
            'Thực hiện cú đánh nhẹ để bi cái dừng lại ở phía sau bi cản, không lộ đường đánh trực tiếp đến bi mục tiêu.',
            'Tự đánh giá (hoặc nhờ người khác đánh giá): nếu là đối thủ, cú đánh tiếp theo có khó không?',
          ],
          goal: 'Luyện đưa bi cái vào vị trí an toàn, khó cho "đối thủ giả định".',
          criteriaVi: '6/10 lần tạo được tình huống mà bi mục tiêu bị che hoàn toàn khỏi đường ngắm trực tiếp.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_safety_play'],
        ),
        Drill(
          code: 'BT11',
          name: 'Table Reading & Run-out Planning',
          nameVi: 'Bài tập đọc bàn & lên kế hoạch run-out',
          category: 'strategy',
          difficulty: 'medium',
          description: 'Rèn khả năng lên thứ tự đánh hợp lý cho một bố cục bi ngẫu nhiên.',
          setup: 'Xếp ngẫu nhiên 5-6 bi trên bàn (không theo luật cụ thể, chỉ để luyện tư duy).',
          steps: [
            'Xếp ngẫu nhiên 5-6 bi trên bàn (không theo luật cụ thể, chỉ để luyện tư duy).',
            'Trước khi đánh, viết ra giấy (hoặc nói to) thứ tự dự định đánh từng bi.',
            'Thực hiện đánh theo đúng kế hoạch đã lên; nếu bi cái đi sai vị trí dự kiến, dừng lại phân tích nguyên nhân trước khi tiếp tục.',
          ],
          goal: 'Rèn khả năng lên thứ tự đánh hợp lý cho một bố cục bi ngẫu nhiên.',
          criteriaVi: 'Hoàn thành run-out (vào hết bi đã xếp) theo đúng thứ tự đã lên kế hoạch ban đầu ít nhất 3/5 lần thử với các bố cục khác nhau.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 22),
            DrillLevel(level: 2, attempts: 50, passCount: 30),
            DrillLevel(level: 3, attempts: 50, passCount: 37),
          ],
          knowledgeIds: ['kn_table_layout'],
        ),
        Drill(
          code: 'BT18',
          name: 'Advanced Run-out Planning (7+ balls)',
          nameVi: 'Lập kế hoạch Run-out nâng cao (7+ bi)',
          category: 'strategy',
          difficulty: 'expert',
          description: 'Áp dụng tư duy "tính ngược từ bi cuối" cho bố cục phức tạp hơn.',
          setup: 'Xếp 7-8 bi ngẫu nhiên, xác định bi khó nhất và bi "chìa khóa" nối các cụm.',
          steps: [
            'Xếp 7-8 bi ngẫu nhiên, xác định bi khó nhất và bi "chìa khóa" nối các cụm.',
            'Lên kế hoạch bằng cách tính từ bi cuối cùng ngược về bi đầu tiên.',
            'Thực hiện run-out theo kế hoạch; nếu thất bại giữa chừng, dừng lại và điều chỉnh kế hoạch cho các bi còn lại thay vì bỏ cuộc.',
          ],
          goal: 'Áp dụng tư duy "tính ngược từ bi cuối" cho bố cục phức tạp hơn.',
          criteriaVi: 'Hoàn thành run-out trọn vẹn ít nhất 2/5 lần thử với các bố cục 7-8 bi khác nhau.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 30, passCount: 8),
            DrillLevel(level: 2, attempts: 30, passCount: 12),
            DrillLevel(level: 3, attempts: 30, passCount: 16),
          ],
          knowledgeIds: ['kn_run_out_planning'],
        ),
        Drill(
          code: 'BT19',
          name: 'Probabilistic Active Safety',
          nameVi: 'Safety chủ động có tính xác suất',
          category: 'strategy',
          difficulty: 'expert',
          description: 'Rèn thói quen đánh giá tỷ lệ trước khi chọn safety thay vì ăn bi liều.',
          setup: 'Với mỗi thế bi khó (tự đánh giá tỷ lệ ăn bi dưới 50%), thử cả 2 phương án: (a) đánh liều ăn bi, (b) chơi safety.',
          steps: [
            'Với mỗi thế bi khó (tự đánh giá tỷ lệ ăn bi dưới 50%), thử cả 2 phương án: (a) đánh liều ăn bi, (b) chơi safety.',
            'Ghi lại kết quả thực tế của cả 2 phương án qua nhiều lần lặp lại thế bi tương tự.',
            'So sánh: phương án nào cho kết quả tốt hơn về lâu dài (ăn bi thành công hay tạo thế bất lợi khi trượt)?',
          ],
          goal: 'Rèn thói quen đánh giá tỷ lệ trước khi chọn safety thay vì ăn bi liều.',
          criteriaVi: 'Tự rút ra được ngưỡng tỷ lệ cá nhân (ví dụ "dưới 40% thì nên safety") dựa trên dữ liệu tự ghi nhận sau tối thiểu 20 lần thử.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 30, passCount: 8),
            DrillLevel(level: 2, attempts: 30, passCount: 12),
            DrillLevel(level: 3, attempts: 30, passCount: 16),
          ],
          knowledgeIds: ['kn_safety_advanced'],
        ),
      ],
    ),
    DrillCategory(
      id: 'psychology',
      name: 'Mental',
      nameVi: 'Tâm lý',
      icon: 'self_improvement',
      drills: [
        Drill(
          code: 'BT20',
          name: 'Pre-shot Routine',
          nameVi: 'Routine trước cú đánh (Pre-shot Routine)',
          category: 'psychology',
          difficulty: 'medium',
          description: 'Xây dựng và tự động hóa một chuỗi hành động cố định trước mỗi cú đánh.',
          setup: 'Thiết kế một routine cá nhân cố định (ví dụ: nhìn bàn → cúi người → 2 lần đẩy thử → hít thở → đánh).',
          steps: [
            'Thiết kế một routine cá nhân cố định (ví dụ: nhìn bàn → cúi người → 2 lần đẩy thử → hít thở → đánh).',
            'Áp dụng đúng routine này cho MỌI cú đánh trong một buổi tập, kể cả cú rất dễ.',
            'Tự quan sát (hoặc quay video) xem có bỏ bước nào khi gặp cú khó/áp lực không.',
          ],
          goal: 'Xây dựng và tự động hóa một chuỗi hành động cố định trước mỗi cú đánh.',
          criteriaVi: 'Duy trì đúng trình tự routine ở ít nhất 9/10 cú đánh liên tiếp trong một buổi tập kéo dài.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_mental_game'],
        ),
      ],
    ),
    DrillCategory(
      id: 'rules',
      name: 'Rules',
      nameVi: 'Luật chơi',
      icon: 'gavel',
      drills: [
        Drill(
          code: 'BT21',
          name: '8-Ball Practice Game with Calls',
          nameVi: 'Ván tập 8-Ball có gọi bi/lỗ',
          category: 'rules',
          difficulty: 'medium',
          description: 'Làm quen luật "call shot" và quản lý nhóm bi của mình.',
          setup: 'Chơi thử một ván 8-ball hoàn chỉnh (một mình hoặc với bạn tập), bắt buộc gọi rõ bi và lỗ trước mỗi cú.',
          steps: [
            'Chơi thử một ván 8-ball hoàn chỉnh (một mình hoặc với bạn tập), bắt buộc gọi rõ bi và lỗ trước mỗi cú.',
            'Tự kiểm đếm số bi còn lại trong nhóm của mình trước khi cân nhắc đánh bi số 8.',
          ],
          goal: 'Làm quen luật "call shot" và quản lý nhóm bi của mình.',
          criteriaVi: 'Hoàn thành trọn vẹn 3 ván không phạm lỗi "đánh bi số 8 sai lượt" hoặc quên gọi bi/lỗ.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_rules_8ball'],
        ),
        Drill(
          code: 'BT22',
          name: '9-Ball / 10-Ball Lowest-Ball Contact',
          nameVi: 'Ván tập 9-Ball / 10-Ball chú trọng chạm đúng bi nhỏ nhất',
          category: 'rules',
          difficulty: 'medium',
          description: 'Rèn phản xạ luôn xác nhận bi số nhỏ nhất trước khi đánh.',
          setup: 'Chơi thử 5 ván 9-ball (hoặc 10-ball nếu muốn luyện call-shot bắt buộc), tự nhắc to số bi nhỏ nhất trước mỗi lượt.',
          steps: [
            'Chơi thử 5 ván 9-ball (hoặc 10-ball nếu muốn luyện call-shot bắt buộc), tự nhắc to số bi nhỏ nhất trước mỗi lượt.',
            'Với 10-ball, bắt buộc gọi lỗ cho MỌI bi kể cả bi số 10.',
          ],
          goal: 'Rèn phản xạ luôn xác nhận bi số nhỏ nhất trước khi đánh.',
          criteriaVi: 'Không phạm lỗi "chưa chạm bi nhỏ nhất trước" trong toàn bộ 5 ván.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_rules_9ball', 'kn_rules_10ball'],
        ),
        Drill(
          code: 'BT23',
          name: 'Short Straight Pool - Break Ball Awareness',
          nameVi: 'Ván tập Straight Pool ngắn (Break Ball Awareness)',
          category: 'rules',
          difficulty: 'hard',
          description: 'Luyện thói quen luôn để ý bi cuối cùng (break ball) khi chơi 14.1.',
          setup: 'Xếp 14 bi + break ball theo đúng luật straight pool.',
          steps: [
            'Xếp 14 bi + break ball theo đúng luật straight pool.',
            'Chơi hết rack, chú ý không đánh vào break ball cho đến khi chỉ còn nó + bi cái trên bàn.',
            'Thực hiện break rack mới từ break ball, tiếp tục đếm điểm.',
          ],
          goal: 'Luyện thói quen luôn để ý bi cuối cùng (break ball) khi chơi 14.1.',
          criteriaVi: 'Hoàn thành ít nhất 1 chu kỳ đầy đủ (hết rack → break rack mới) mà không phạm lỗi đánh nhầm break ball sớm.',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 50, passCount: 27),
            DrillLevel(level: 2, attempts: 50, passCount: 35),
            DrillLevel(level: 3, attempts: 50, passCount: 42),
          ],
          knowledgeIds: ['kn_rules_14_1'],
        ),
      ],
    ),
    DrillCategory(
      id: 'equipment',
      name: 'Equipment',
      nameVi: 'Thiết bị',
      icon: 'build',
      drills: [
        Drill(
          code: 'BT24',
          name: 'Periodic Cue Inspection & Maintenance',
          nameVi: 'Kiểm tra & bảo dưỡng cơ định kỳ',
          category: 'equipment',
          difficulty: 'easy',
          description: 'Hình thành thói quen kiểm tra cơ trước/sau khi chơi.',
          setup: 'Trước mỗi buổi tập: kiểm tra đầu da (độ cong, độ nhám), lau shaft.',
          steps: [
            'Trước mỗi buổi tập: kiểm tra đầu da (độ cong, độ nhám), lau shaft.',
            'Sau buổi tập: lau lại toàn bộ cơ, cất vào hộp/ống đúng cách.',
            'Định kỳ 1-2 tháng: kiểm tra độ thẳng của cơ bằng roll test trên mặt phẳng.',
          ],
          goal: 'Hình thành thói quen kiểm tra cơ trước/sau khi chơi.',
          criteriaVi: 'Duy trì thói quen này liên tục trong ít nhất 4 tuần tập luyện (tự đánh dấu vào lịch/nhật ký tập).',
          commonMistakes: [],
          levels: [
            DrillLevel(level: 1, attempts: 1, passCount: 0, zone: 'duy tri 4 tuan'),
          ],
          knowledgeIds: ['kn_cue_selection', 'kn_cue_maintenance'],
        ),
      ],
    ),
  ];

  static List<Drill> getAllDrills() =>
      categories.expand((c) => c.drills).toList();

  static List<Drill> getDrillsByCategory(String categoryId) => categories
      .where((c) => c.id == categoryId)
      .expand((c) => c.drills)
      .toList();

  static Drill? getDrill(String code) {
    for (final d in getAllDrills()) {
      if (d.code == code) return d;
    }
    return null;
  }

  /// Bi danh: giu ten cu de cho goi hien co khong gay.
  static Drill? getDrillByCode(String code) => getDrill(code);

  static List<Drill> getDrillsByDifficulty(String difficulty) =>
      getAllDrills().where((d) => d.difficulty == difficulty).toList();

  /// Nam bai dau theo thu tu Phan 1 -> Phan 6 cua nguon.
  static List<Drill> getRecommendedDrills() => getAllDrills().take(5).toList();
}
class DrillCategory {
  final String id;
  final String name;
  final String nameVi;
  final String icon;
  final List<Drill> drills;

  const DrillCategory({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.drills,
  });
}

class Drill {
  final String code;
  final String name;
  final String nameVi;
  final String category;
  final String difficulty;
  final String description;
  final String setup;
  final List<String> steps;
  final String goal;
  final List<DrillLevel> levels;
  final List<String> knowledgeIds;

  /// Nguyen van dong *Tieu chi dat* cua nguon.
  final String criteriaVi;

  /// Loi thuong gap. RONG cho toi khi nguon bo sung muc nay —
  /// UI phai an han muc thay vi hien danh sach chung bia ra.
  final List<String> commonMistakes;

  const Drill({
    required this.code,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.setup,
    required this.steps,
    required this.goal,
    required this.levels,
    required this.knowledgeIds,
    required this.criteriaVi,
    this.commonMistakes = const [],
  });

  int get currentLevel {
    // Placeholder - sẽ lấy từ user progress
    return 1;
  }

  bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    // Level unlocked if previous level passed
    // Placeholder logic
    return true;
  }

  DrillLevel? getLevel(int level) {
    return levels.firstWhere(
      (l) => l.level == level,
      orElse: () => levels.first,
    );
  }
}

class DrillLevel {
  final int level;
  final int attempts;
  final int passCount;
  // Optional difficulty parameters
  final String? distance;
  final String? angle;
  final String? accuracy;
  final String? zone;
  final int? balls;

  const DrillLevel({
    required this.level,
    required this.attempts,
    required this.passCount,
    this.distance,
    this.angle,
    this.accuracy,
    this.zone,
    this.balls,
  });

  /// Nguong dang so; rong neu nguon khong neu nguong.
  String get criteriaText {
    if (passCount == 0) return '';
    if (distance != null) return '$attempts attempts → $passCount success ($distance)';
    if (angle != null) return '$attempts attempts → $passCount success ($angle)';
    if (accuracy != null) return '$attempts attempts → $passCount success ($accuracy)';
    if (zone != null) return '$attempts attempts → $passCount success (zone: $zone)';
    return '$attempts attempts → $passCount success';
  }
}
