/// Knowledge Articles — Vietnamese instructional content for fundamentals.
///
/// Bài viết kiến thức nền tảng, có thể đọc độc lập.
/// Dựa trên Dr. Dave Alciatore + BCA/APA standards.
library;

class KnowledgeArticle {
  final String id;
  final String title;
  final String category;
  final String level; // beginner | intermediate | advanced
  final String summary;
  final String content;
  final List<String> keyTakeaways;
  final List<String> relatedDrills;
  final List<String> tags;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.summary,
    required this.content,
    this.keyTakeaways = const [],
    this.relatedDrills = const [],
    this.tags = const [],
  });
}

/// Knowledge articles tiếng Việt
const knowledgeArticlesVi = <KnowledgeArticle>[
  // ============================================================================
  // CẦU TAY (BRIDGE) — Nền tảng quan trọng nhất
  // ============================================================================
  KnowledgeArticle(
    id: 'bridge-fundamentals',
    title: 'Cầu tay — Nền tảng của mọi cú đánh',
    category: 'fundamentals',
    level: 'beginner',
    summary: 'Cầu tay (bridge) là cách tay trước đặt trên bàn để giữ cơ. Đây là yếu tố quan trọng nhất quyết định độ chính xác của cú đánh.',
    content: '''
**Cầu tay là gì?**
Cầu tay là cách tay trước của bạn (tay gần bi trắng) đặt trên bàn để giữ cơ ổn định khi đánh. Nó hoạt động như một "giá đỡ" cho cơ, giúp cơ đi thẳng và chính xác.

**Hai loại cầu tay chính:**

1. **Cầu tay mở (Open Bridge)** — Dễ học, linh hoạt
   - Các ngón tay xếp thành hình chữ V trên bàn
   - Cơ nằm trong rãnh V
   - Ngón cái giữ chặt cơ từ trên xuống
   - Phù hợp với hầu hết các tình huống

2. **Cầu tay đóng (Closed Bridge)** — Chắc chắn hơn
   - Ngón trỏ vòng qua, tạo thành vòng khép kín
   - Ngón giữa và ngón áp úp giữ cơ
   - Chắc chắn hơn nhưng khó học hơn
   - Dùng khi cần lực mạnh

**Các biến thể:**

- **Cầu tay thấp (Low bridge)**: Bàn tay áp sát bàn — dùng cho cú đánh thường
- **Cầu tay cao (Elevated bridge)**: Tay nâng cao — dùng khi có bi cản
- **Cầu tay cơ học (Mechanical bridge)**: Dụng cụ rời — dùng khi bi ở xa tầm tay

**Lỗi thường gặp:**
- Tay không đặt trên bàn — cơ bị rung
- Ngón tay siết quá chặt — cơ không di chuyển mượt
- Cầu tay cao quá — khó kiểm soát
- Cầu tay xa bi quá — mất kiểm soát

**Lời khuyên:**
- Tập cầu tay 5-10 phút mỗi ngày
- Thử cả 2 loại và chọn loại thoải mái
- Khi đánh mạnh, dùng cầu tay đóng cho chắc
''',
    keyTakeaways: [
      'Cầu tay quyết định 80% độ chính xác',
      'Cầu tay mở phù hợp người mới',
      'Cầu tay đóng chắc chắn hơn nhưng khó hơn',
      'Tập cầu tay mỗi ngày',
    ],
    relatedDrills: ['BRIDGE_FORM', 'STRAIGHT_NEAR', 'STROKE_STRAIGHT'],
    tags: ['fundamentals', 'bridge', 'tag_bridge'],
  ),

  // ============================================================================
  // VÀO BỘ (STANCE) — Tư thế đứng
  // ============================================================================
  KnowledgeArticle(
    id: 'stance-fundamentals',
    title: 'Vào bộ — Tư thế đứng đúng cách',
    category: 'fundamentals',
    level: 'beginner',
    summary: 'Stance (tư thế đứng) là nền tảng cho mọi cú đánh. Tư thế sai sẽ ảnh hưởng đến toàn bộ cú đánh.',
    content: '''
**Stance là gì?**
Stance là tư thế đứng của cơ thể trước khi đánh. Stance đúng = cú đánh dễ chính xác. Stance sai = cú đánh khó thành công dù kỹ thuật tốt.

**5 yếu tố của stance chuẩn:**

1. **Chân**: Rộng bằng vai, chân trước (chân trái với người thuận phải) chỉ thẳng về phía bi mục tiêu
2. **Đầu gối**: Hơi cong, đàn hồi — không khóa
3. **Hông**: Thẳng và vuông góc với đường đánh
4. **Thân người**: Thẳng, hơi nghiêng về phía trước
5. **Cằm**: Chạm hoặc gần cơ, giữ đầu ổn định

**Trọng lượng:**
- Dồn đều 2 chân (50/50)
- Khi đánh mạnh, có thể dồn 60% về chân sau
- Sau khi đánh, giữ trọng lượng không xê dịch

**Lỗi thường gặp:**
- Chân quá hẹp — mất cân bằng
- Chân quá rộng — khó xoay
- Thân xoay quá — mất lực đánh
- Đầu cúi quá thấp — khó theo dõi đường bi

**Bài tập:**
- Đứng stance chuẩn 30 giây - 1 phút mỗi lần
- Tập ở nhiều góc đánh khác nhau
- Chụp ảnh stance để tự kiểm tra
''',
    keyTakeaways: [
      'Chân rộng bằng vai',
      'Chân trước chỉ thẳng mục tiêu',
      'Thân thẳng, đầu gối hơi cong',
      'Cằm chạm cơ',
    ],
    relatedDrills: ['STANCE_FORM', 'STRAIGHT_NEAR'],
    tags: ['fundamentals', 'stance', 'tag_technique'],
  ),

  // ============================================================================
  // RA CƠ (STROKE) — Kỹ thuật vung cơ
  // ============================================================================
  KnowledgeArticle(
    id: 'stroke-fundamentals',
    title: 'Ra cơ — Kỹ thuật vung cơ đúng cách',
    category: 'fundamentals',
    level: 'beginner',
    summary: 'Stroke (ra cơ) là cách bạn vung cơ để đánh bi. Stroke đúng = bi đi đúng hướng, lực chính xác.',
    content: '''
**Stroke là gì?**
Stroke là toàn bộ chuyển động của cơ từ lúc kéo về đến khi follow through (vung hết). Stroke đúng giúp bạn kiểm soát cả hướng và lực.

**4 giai đoạn của stroke:**

1. **Setup (chuẩn bị)**: Đặt cơ vào vị trí, kiểm tra mọi thứ
2. **Backstroke (kéo về)**: Kéo cơ ra sau — đều và chậm
3. **Forward stroke (đẩy tới)**: Đẩy cơ tới bi — nhanh và mượt
4. **Follow through (vung hết)**: Tiếp tục đẩy cơ sau khi chạm bi — dài gấp 3-4 lần kéo về

**Nguyên tắc vàng:**
- Chỉ khuỷu tay di chuyển — vai cố định
- Tốc độ đều (không giật)
- Follow through dài = cú đánh chính xác
- Tay cầm cơ (tay sau) buông thõng, không siết

**Lực đánh:**
- Nhẹ = bi đi ngắn
- Vừa = bi đi trung bình
- Mạnh = bi đi xa
- Cường độ từ tốc độ cơ, không phải từ siết tay

**Lỗi thường gặp:**
- Tay lắc sang trái/phải khi đánh
- Cổ tay cong khi đánh
- Khuỷu tay di chuyển không cố định
- Follow through không đều

**Bài tập:**
- Đánh bi trắng đi thẳng vào thành bàn nhiều lần
- Tập với tốc độ tăng dần
- Tập 10-15 phút mỗi ngày
''',
    keyTakeaways: [
      'Chỉ khuỷu tay di chuyển',
      'Follow through dài gấp 3-4 lần kéo về',
      'Tốc độ đều, không giật',
      'Tập mỗi ngày để cơ thể nhớ',
    ],
    relatedDrills: ['STROKE_STRAIGHT', 'STRAIGHT_NEAR'],
    tags: ['fundamentals', 'stroke', 'tag_technique'],
  ),

  // ============================================================================
  // NGẮM (AIMING) — Hệ thống ngắm
  // ============================================================================
  KnowledgeArticle(
    id: 'aiming-fundamentals',
    title: 'Ngắm — Hệ thống ngắm cơ bản',
    category: 'aiming',
    level: 'beginner',
    summary: 'Aiming (ngắm) là xác định hướng cơ đi để bi trắng chạm bi mục tiêu đúng điểm. Ngắm đúng = đánh trúng lỗ.',
    content: '''
**Hệ thống ngắm cơ bản:**

Đường ngắm là đường thẳng từ bi trắng đi qua bi mục tiêu đến điểm chuẩn trên viền lỗ. Cơ phải đi theo đường này.

**Các bước ngắm:**

1. **Nhìn bi mục tiêu**: Xác định bi nào cần đánh
2. **Xác định lỗ**: Bi sẽ vào lỗ nào
3. **Tìm điểm chuẩn**: Điểm trên viền lỗ mà bi mục tiêu sẽ chạm
4. **Nhìn qua bi mục tiêu ra điểm chuẩn**: Đường ngắm
5. **Đánh vào điểm tiếp xúc**: Trên bi trắng sao cho cơ đi qua đường ngắm

**Hệ thống Ghost Ball (Bi ma):**
- Hình dung 1 bi ảo ở vị trí sẽ chạm bi mục tiêu
- Đánh bi trắng vào vị trí bi ảo
- Hệ thống này giúp ngắm chính xác cho cú cắt

**Hệ thống nửa bi (½ ball system):**
- Khi đánh vào nửa bi trắng (½ ball), bi mục tiêu đi vuông góc với đường đánh
- Dùng khi cần bi mục tiêu đi theo góc cụ thể

**Lỗi thường gặp:**
- Nhìn bi trắng thay vì bi mục tiêu
- Đường ngắm không qua tâm bi mục tiêu
- Điểm chuẩn sai

**Bài tập:**
- Tập ngắm trước khi đánh — nhìn 3-5 giây rồi mới đánh
- Tập ghost ball với các góc cắt khác nhau
- Hỏi người xem xác nhận đường ngắm
''',
    keyTakeaways: [
      'Đường ngắm = bi trắng → bi mục tiêu → điểm chuẩn',
      'Ghost ball giúp ngắm cú cắt',
      '½ ball = bi mục tiêu vuông góc',
      'Tập ngắm trước khi đánh',
    ],
    relatedDrills: ['STRAIGHT_NEAR', 'THIN_CUT_30', 'HALF_BALL_LEFT'],
    tags: ['aiming', 'tag_aiming'],
  ),

  // ============================================================================
  // TOPSPIN / FOLLOW — Xoáy tiến
  // ============================================================================
  KnowledgeArticle(
    id: 'topspin-follow',
    title: 'Topspin (Follow) — Xoáy tiến',
    category: 'cueball',
    level: 'intermediate',
    summary: 'Topspin (còn gọi là follow) là xoáy tiến trên bi trắng. Sau khi chạm bi mục tiêu, bi trắng tiếp tục cuộn về phía trước.',
    content: '''
**Topspin là gì?**
Khi bạn đánh vào phần trên bi trắng (cao hơn tâm), bi sẽ có xoáy tiến (top spin). Sau khi chạm bi mục tiêu, bi trắng tiếp tục cuộn về phía trước.

**Cách đánh:**
- Đánh vào phần trên bi trắng (khoảng 1-3mm trên tâm)
- Follow through DÀI để truyền xoáy
- Cơ đi từ dưới lên trên qua bi

**Công dụng:**
- Position play: Đẩy bi trắng về vị trí thuận lợi cho cú tiếp theo
- Tạo đà khi cần đi xa

**Lưu ý:**
- Đánh càng mạnh = bi trắng càng xa
- Đánh quá nhẹ = không có xoáy
- Đánh quá cao trên bi = miscue (cơ trượt)

**Bài tập:**
- Đánh bi mục tiêu vào lỗ gần, bi trắng sẽ cuộn về phía trước
- Tăng dần lực để cảm nhận khoảng cách bi trắng đi
''',
    keyTakeaways: [
      'Đánh phần trên bi trắng = top spin',
      'Follow through dài = xoáy tốt',
      'Bi trắng tiếp tục đi sau khi chạm bi mục tiêu',
      'Dùng để position play',
    ],
    relatedDrills: ['FOLLOW_SHOT', 'TOP_SPIN_CONTROL', 'FOLLOW_FAR'],
    tags: ['cueball', 'tag_topspin'],
  ),

  // ============================================================================
  // BACKSPIN / DRAW — Xoáy lùi
  // ============================================================================
  KnowledgeArticle(
    id: 'backspin-draw',
    title: 'Backspin (Draw) — Xoáy lùi',
    category: 'cueball',
    level: 'intermediate',
    summary: 'Backspin (còn gọi là draw) là xoáy lùi trên bi trắng. Sau khi chạm bi mục tiêu, bi trắng quay lùi.',
    content: '''
**Backspin là gì?**
Khi đánh vào phần dưới bi trắng (thấp hơn tâm), bi có xoáy lùi (backspin). Sau khi chạm bi mục tiêu, bi trắng quay lùi về phía sau.

**Cách đánh:**
- Đánh vào phần dưới bi trắng (2-5mm dưới tâm)
- Đánh MẠNH với follow through DÀI
- Cơ đi từ trên xuống dưới qua bi

**Công dụng:**
- Position play: Bi trắng lùi về vị trí thuận lợi
- Tránh bi cản sau khi đánh

**Lưu ý:**
- Cần lực lớn hơn follow shot
- Đánh càng thấp trên bi = càng nhiều backspin
- Miscue (cơ trượt) là rủi ro lớn

**Miscue là gì?**
Miscue = cơ trượt khỏi bi vì đánh quá lệch tâm hoặc đầu cơ không đủ phấn. Miscue sẽ làm hỏng cú đánh và có thể làm hỏng đầu cơ.

**Cách tránh miscue:**
- Phấn kỹ đầu cơ trước mỗi cú
- Đánh vào vùng an toàn trên bi (2-3mm lệch tâm)
- Không đánh quá gần rìa bi

**Bài tập:**
- Đánh bi mục tiêu vào lỗ, bi trắng quay lùi về phía bạn
- Tăng dần khoảng cách và lực
''',
    keyTakeaways: [
      'Đánh phần dưới bi trắng = back spin',
      'Cần lực MẠNH + follow through DÀI',
      'Bi trắng quay lùi sau khi chạm bi mục tiêu',
      'Cẩn thận miscue',
    ],
    relatedDrills: ['DRAW_SHOT', 'BACK_SPIN_CONTROL', 'DRAW_BACK_FAR'],
    tags: ['cueball', 'tag_backspin'],
  ),

  // ============================================================================
  // ENGLISH / SIDE SPIN — Xoáy bên
  // ============================================================================
  KnowledgeArticle(
    id: 'english-side-spin',
    title: 'English (Side spin) — Xoáy bên',
    category: 'cueball',
    level: 'intermediate',
    summary: 'English (side spin) là xoáy bên trên bi trắng. Bi trắng sẽ cuộn theo đường cong khi chạm thành.',
    content: '''
**English là gì?**
English (còn gọi là side spin) là xoáy bên trên bi trắng. Khi bi trắng chạm thành bàn (cushion), nó sẽ đi theo đường cong thay vì đường thẳng.

**Cách đánh:**
- Đánh vào phần trái hoặc phải bi trắng (3-5mm lệch tâm)
- Cơ phải đi THẲNG, không lệch
- Phấn kỹ đầu cơ

**Hai loại:**
- **Left english** = xoáy trái = bi xoáy ngược chiều kim đồng hồ
- **Right english** = xoáy phải = bi xoáy theo chiều kim đồng hồ

**Ảnh hưởng:**

1. **Khi chạm cushion**: Bi đổi hướng theo góc cong, không theo góc phản xạ
2. **Khi chạm bi mục tiêu**: Bi mục tiêu có thể đi lệch so với dự kiến (do ma sát xoáy)
3. **Bi trắng sau va chạm**: Đi lệch sang trái hoặc phải so với đường full ball

**Công dụng:**
- Position play chính xác
- Điều khiển bi trắng về vị trí thuận lợi
- Tránh bi cản sau khi đánh

**Lỗi thường gặp:**
- Đánh lệch cơ — không tạo xoáy mà còn làm bi đi lệch
- Đánh quá gần rìa bi — miscue
- Đánh quá nhẹ — xoáy không đủ

**Bài tập:**
- Đánh bi trắng vào thành đối diện, quan sát đường đi của bi
- Thử left và right english, cảm nhận sự khác biệt
''',
    keyTakeaways: [
      'English = xoáy bên',
      'Cơ phải đi thẳng để tạo xoáy',
      'Bi trắng cong khi chạm cushion',
      'Dùng cho position play chính xác',
    ],
    relatedDrills: ['LEFT_ENGLISH_NEAR', 'RIGHT_ENGLISH_NEAR', 'INSIDE_ENGLISH'],
    tags: ['cueball', 'tag_english', 'tag_technique'],
  ),

  // ============================================================================
  // KIỂM SOÁT LỰC
  // ============================================================================
  KnowledgeArticle(
    id: 'power-control',
    title: 'Kiểm soát lực — Chìa khóa thành công',
    category: 'fundamentals',
    level: 'beginner',
    summary: 'Lực đánh quyết định khoảng cách và tốc độ bi. Kiểm soát lực tốt = kiểm soát được bi.',
    content: '''
**Lực đánh từ đâu đến?**

Lực đánh không đến từ việc siết tay mạnh. Lực đến từ:
- Tốc độ khuỷu tay di chuyển
- Khoảng cách kéo cơ về
- Follow through dài

**3 mức lực cơ bản:**

1. **Nhẹ (Soft)**: Bi đi chậm, dừng nhanh. Dùng cho cú cần kiểm soát.
2. **Vừa (Medium)**: Bi đi trung bình. Dùng cho hầu hết cú thường.
3. **Mạnh (Hard)**: Bi đi nhanh và xa. Dùng cho cú cần lực.

**Tỉ lệ lực với khoảng cách:**

Bi đi xa gấp đôi = cần lực gấp đôi (không phải gấp 4).

**Cách tập kiểm soát lực:**
- Đặt bi ở khoảng cách cố định
- Đánh với lực vừa đủ để bi đến đích
- Lặp lại nhiều lần để cảm nhận

**Lỗi thường gặp:**
- Đánh không đều — cú mạnh cú nhẹ
- Đánh quá mạnh vì sợ không tới
- Đánh không đủ mạnh vì sợ trượt
''',
    keyTakeaways: [
      'Lực từ tốc độ khuỷu tay, không từ siết tay',
      '3 mức: nhẹ, vừa, mạnh',
      'Bi đi xa gấp đôi = lực gấp đôi',
      'Tập đánh với lực chính xác nhiều lần',
    ],
    relatedDrills: ['STRAIGHT_MID', 'STRAIGHT_FAR', 'BREAK_CONTROL'],
    tags: ['fundamentals', 'tag_speed', 'tag_power_control'],
  ),

  // ============================================================================
  // PHÒNG THỦ (SAFETY)
  // ============================================================================
  KnowledgeArticle(
    id: 'safety-basics',
    title: 'Phòng thủ (Safety) — Chiến thuật quan trọng',
    category: 'strategy',
    level: 'intermediate',
    summary: 'Safety là đánh để đối thủ không dễ — không phải để mình vào lỗ. Trong 8-ball/9-ball, safety chiếm 40-50% thời gian.',
    content: '''
**Safety là gì?**
Safety là đánh bi sao cho đối thủ không có cú đánh dễ. Đây là chiến thuật quan trọng trong mọi game billiards.

**Khi nào nên safety?**

- Bạn không có cú trực tiếp tốt
- Đối thủ đang chạy tốt — bạn cần ngắt nhịp
- Bạn muốn chơi phòng thủ trước khi tấn công

**Các kiểu safety:**

1. **Hide the cue ball (giấu bi trắng)**: Đẩy bi trắng về vị trí khó (sau bi khác, dính thành bàn)
2. **Defensive safety**: Đẩy bi mục tiêu vào vị trí khó cho đối thủ
3. **Force safety**: Bi trắng chạm thành nhiều lần trước khi dừng
4. **Push out**: Đặt bi trắng ở vị trí thuận lợi (chỉ trong 9-ball và một số game)

**Lợi ích của safety:**
- Buộc đối thủ phải đánh khó hoặc cũng safety
- Chờ đối thủ mắc sai lầm
- Giành lợi thế về vị trí

**Lỗi thường gặp:**
- Cố đánh trúng khi không nên
- Để bi trắng ở giữa bàn cho đối thủ
- Safety không rõ ràng — đối thủ vẫn dễ
''',
    keyTakeaways: [
      'Safety = đánh để đối thủ không dễ',
      '40-50% thời gian game là safety',
      'Ẩn bi trắng hoặc đẩy bi mục tiêu vào vị trí khó',
      'Chờ đối thủ mắc sai lầm',
    ],
    relatedDrills: ['SAFETY_BASIC', 'SAFETY_FORCE', 'POSITION_BASIC'],
    tags: ['strategy', 'tag_strategy', 'tag_defense'],
  ),

  // ============================================================================
  // BANK SHOT — Cú băng
  // ============================================================================
  KnowledgeArticle(
    id: 'bank-shot-basics',
    title: 'Bank shot — Cú băng cơ bản',
    category: 'shotmaking',
    level: 'advanced',
    summary: 'Bank shot là cú đánh bi mục tiêu chạm 1 cushion trước khi vào lỗ. Đây là kỹ thuật nâng cao.',
    content: '''
**Bank shot là gì?**
Bank shot là cú đánh bi mục tiêu vào 1 cushion trước khi vào lỗ. Đây là kỹ thuật nâng cao, dùng khi không có đường đánh trực tiếp.

**Khi nào dùng bank shot:**
- Bi mục tiêu không ngắm trực tiếp được
- Cần đa dạng hóa chiến thuật
- Đối thủ không kỳ vọng

**2 hệ thống ngắm bank shot:**

1. **Phantom ball (Bi ma)**: Hình dung bi ảo ở vị trí sau khi chạm cushion. Đánh vào bi ảo như đánh trực tiếp.

2. **Parallel lines (Đường song song)**: Vẽ đường từ bi mục tiêu đến lỗ. Vẽ đường song song từ bi trắng. Điểm giao là nơi đánh.

**Lưu ý:**
- Bank shot khó và rủi ro cao
- Khoảng cách từ bi mục tiêu đến cushion = khoảng cách từ cushion đến lỗ (tỉ lệ 1:1 gần đúng)
- Thực tế cần điều chỉnh vì ma sát

**Bài tập:**
- Bắt đầu với bi mục tiêu gần cushion
- Tăng dần khoảng cách
- Tập 2 cushion bank (bank 2 lần)
''',
    keyTakeaways: [
      'Bank = bi mục tiêu chạm cushion trước khi vào lỗ',
      'Phantom ball hoặc parallel lines',
      'Khó và rủi ro cao',
      'Chỉ dùng khi không có lựa chọn trực tiếp',
    ],
    relatedDrills: ['BANK_SHOT', 'PATTERN_MULTI_RAIL'],
    tags: ['shotmaking', 'tag_bank', 'tag_technique'],
  ),

  // ============================================================================
  // POSITION PLAY
  // ============================================================================
  KnowledgeArticle(
    id: 'position-play',
    title: 'Position play — Kiểm soát bi trắng',
    category: 'positioning',
    level: 'intermediate',
    summary: 'Position play là kiểm soát vị trí bi trắng sau khi đánh. Đây là kỹ năng quan trọng nhất sau khi thành thạo ngắm.',
    content: '''
**Position play là gì?**
Position play là kiểm soát vị trí bi trắng sau khi đánh. Mục tiêu: bi trắng dừng ở vị trí thuận lợi cho cú đánh tiếp theo.

**3 yếu tố quyết định:**

1. **Điểm tiếp xúc trên bi trắng**:
   - Tâm = stun shot (bi trắng vuông góc)
   - Trên = follow (bi trắng tiếp tục)
   - Dưới = draw (bi trắng lùi lại)

2. **Lực đánh**:
   - Nhẹ = position gần
   - Mạnh = position xa

3. **Góc đánh**:
   - Cắt mỏng = bi trắng đi gần thẳng
   - Cắt dày = bi trắng đi xa hơn

**Tư duy position:**

Trước khi đánh, luôn hỏi:
- Bi mục tiêu sẽ đi đâu?
- Bi trắng sẽ đi đâu sau khi chạm bi mục tiêu?
- Có thuận lợi cho cú tiếp theo không?

**Cấp độ tư duy:**
- Cấp 1: Chỉ nghĩ về cú hiện tại
- Cấp 2: Nghĩ trước 1 cú
- Cấp 3: Nghĩ trước 2-3 cú (pattern play)
- Cấp 4: Toàn bộ game

**Bài tập:**
- Đặt bi trắng và bi mục tiêu. Đánh sao cho bi trắng dừng ở vị trí Y (chỉ định).
- Tăng dần khoảng cách và góc.
''',
    keyTakeaways: [
      'Position play = kiểm soát bi trắng',
      '3 yếu tố: điểm tiếp xúc, lực, góc',
      'Nghĩ trước ít nhất 1 cú',
      'Tập với bài tập có mục tiêu cụ thể',
    ],
    relatedDrills: ['POSITION_BASIC', 'POSITION_3BALL', 'PATTERN_3_BALLS'],
    tags: ['positioning', 'tag_positioning'],
  ),

  // ============================================================================
  // BREAK — Đánh vỡ rack
  // ============================================================================
  KnowledgeArticle(
    id: 'break-fundamentals',
    title: 'Break — Đánh vỡ rack',
    category: 'strategy',
    level: 'intermediate',
    summary: 'Break là cú đánh đầu tiên để vỡ rack (15 bi xếp hình tam giác). Break tốt = bắt đầu thuận lợi.',
    content: '''
**Break là gì?**
Break là cú đánh đầu tiên trong game 8-ball, 9-ball, 10-ball. Mục tiêu: vỡ rack và phân tán bi đều trên bàn.

**Hai kiểu break:**

1. **Power break**: Đánh mạnh nhất có thể để bi chạy xa
2. **Control break**: Đánh vừa đủ để rack vỡ và bi trắng ở giữa bàn

**Trong 8-ball:**
- Power break phổ biến hơn
- Mục tiêu: rack vỡ + 1 bi vào lỗ + bi trắng ở giữa

**Trong 9-ball:**
- Control break quan trọng hơn vì cần bi trắng ở vị trí tốt cho bi số 1
- Đánh vào bi số 1 (1 bi lệch lên trên)

**Kỹ thuật:**
- Đứng xa rack (1-1.5m)
- Dùng cơ break (đầu cơ phenolic hoặc cứng)
- Đánh mạnh, follow through dài
- Cầu tay chắc chắn

**Lỗi thường gặp:**
- Đánh full vào tâm — dễ scratch
- Đánh quá cao — bi nhảy khỏi bàn
- Đánh quá nhẹ — rack không vỡ đủ
- Dùng cơ thường — nhanh hỏng đầu cơ

**Bài tập:**
- Break dry 10-20 lần mỗi buổi tập
- Ghi chép điểm đánh nào cho kết quả tốt
''',
    keyTakeaways: [
      'Break = đánh vỡ rack đầu tiên',
      '8-ball: power break, 9-ball: control break',
      'Cần cơ break chuyên dụng',
      'Tập break dry nhiều lần',
    ],
    relatedDrills: ['BREAK_POWER', 'BREAK_CONTROL', 'BREAK_DRY'],
    tags: ['strategy', 'tag_break'],
  ),

  // ============================================================================
  // JUMP SHOT
  // ============================================================================
  KnowledgeArticle(
    id: 'jump-shot',
    title: 'Jump shot — Cú nhảy',
    category: 'shotmaking',
    level: 'expert',
    summary: 'Jump shot là cú đánh bi trắng vượt qua bi cản. Đây là kỹ thuật nâng cao, bị cấm trong một số giải.',
    content: '''
**Jump shot là gì?**
Jump shot là cú đánh bi trắng vượt qua bi cản. Bi trắng sẽ nảy lên khỏi bàn, bay qua bi cản, rồi rơi xuống đánh bi mục tiêu.

**Kỹ thuật:**
- Đứng ở góc 30-45 độ với bi trắng
- Cơ gần như thẳng đứng
- Đánh mạnh và dứt khoát xuống dưới
- Bi trắng sẽ nảy lên nhờ lực đánh

**Dụng cụ:**
- Cơ jump chuyên dụng (đầu cơ cứng hoặc skin mỏng)
- Hoặc cơ thường nhưng kỹ thuật phải tốt

**Luật:**
- BỊ CẤM trong nhiều giải đấu (BCA, APA, v.v.)
- Một số giải cho phép
- LUÔN kiểm tra luật giải trước khi dùng

**Lỗi thường gặp:**
- Đánh quá nhẹ — bi không nảy đủ
- Đánh quá mạnh — bi văng khỏi bàn
- Không có cơ jump — cơ miscues
- Bị cấm mà không biết

**Lời khuyên:**
- Chỉ dùng khi rất cần và hợp pháp
- Luyện nhiều vì cú này đòi hỏi cảm giác tốt
''',
    keyTakeaways: [
      'Jump shot = bi trắng vượt bi cản',
      'Cần cơ jump chuyên dụng',
      'Bị cấm trong nhiều giải — kiểm tra luật',
      'Kỹ thuật pro',
    ],
    relatedDrills: ['JUMP_SHOT'],
    tags: ['shotmaking', 'tag_jump', 'tag_advanced'],
  ),

  // ============================================================================
  // MASSE — Cú xoáy
  // ============================================================================
  KnowledgeArticle(
    id: 'masse-shot',
    title: 'Masse — Cú xoáy cong',
    category: 'shotmaking',
    level: 'expert',
    summary: 'Masse là cú đánh bi trắng đi đường cong. Kỹ thuật cực kỳ khó, chỉ pro mới dùng thành thạo.',
    content: '''
**Masse là gì?**
Masse là cú đánh bi trắng đi theo đường cong thay vì đường thẳng. Bi trắng sẽ cuộn vòng cung quanh chướng ngại vật.

**Kỹ thuật:**
- Đứng ở góc 45-90 độ với bi trắng
- Cơ gần như thẳng đứng
- Đánh mạnh vào phần rất lệch tâm bi (1/4 hoặc 3/4 bi)
- Bi trắng sẽ cuộn cong

**Dụng cụ:**
- Cơ masse chuyên dụng (đầu cơ dày)
- Hoặc cơ jump

**Công dụng:**
- Đi vòng qua bi cản
- Tránh thành bàn
- Trong game thật, rất hiếm khi dùng

**Lưu ý:**
- CỰC KỲ KHÓ — kỹ thuật pro
- Cần lực chính xác và cảm giác tốt
- Miscue là rủi ro lớn

**Lời khuyên:**
- Người mới KHÔNG nên thử
- Chỉ pro mới dùng thành thạo
- Trong game, thường có lựa chọn an toàn hơn
''',
    keyTakeaways: [
      'Masse = bi trắng đi đường cong',
      'CỰC KỲ khó — kỹ thuật pro',
      'Cần cơ masse chuyên dụng',
      'Người mới không nên thử',
    ],
    relatedDrills: ['MASSE'],
    tags: ['shotmaking', 'tag_masse', 'tag_advanced'],
  ),

  // ============================================================================
  // PATTERN PLAY
  // ============================================================================
  KnowledgeArticle(
    id: 'pattern-play',
    title: 'Pattern play — Tư duy nhiều cú trước',
    category: 'positioning',
    level: 'advanced',
    summary: 'Pattern play là tư duy nhiều cú trước khi đánh. Đây là kỹ năng pro, phân biệt pro với người chơi trung bình.',
    content: '''
**Pattern play là gì?**
Pattern play là tư duy toàn bộ chuỗi cú đánh từ đầu đến cuối. Mỗi cú đánh được lên kế hoạch trước dựa trên kết quả của các cú trước.

**Tại sao quan trọng?**

- Người chơi trung bình: nghĩ 1 cú
- Người chơi giỏi: nghĩ 2-3 cú
- Pro: nghĩ toàn bộ game

**Cách tập pattern play:**

1. Trước khi đánh, dừng lại 5-10 giây
2. Quan sát toàn bộ bàn
3. Hỏi: "Nếu đánh trúng, bi trắng sẽ ở đâu? Cú tiếp theo là gì?"
4. Hỏi tiếp: "Sau cú tiếp theo thì sao?"
5. Lên kế hoạch 2-3 cú rồi đánh

**Lợi ích:**
- Tránh đánh những cú "chết" (đánh xong không có cú tiếp)
- Tiết kiệm thời gian
- Tăng tỉ lệ thành công

**Lỗi thường gặp:**
- Chỉ nghĩ 1 cú
- Đánh xong mới tính — đã muộn
- Đánh cú khó vì "thấy vui" thay vì đánh cú dễ

**Bài tập:**
- Đặt 3-5 bi trên bàn. Tập đánh hết với kế hoạch trước.
- Ghi chép lại cú nào sai và tại sao.
''',
    keyTakeaways: [
      'Pattern play = nghĩ trước 2-3 cú',
      'Phân biệt pro với người thường',
      'Trước khi đánh, dừng 5-10 giây suy nghĩ',
      'Tránh đánh cú "chết"',
    ],
    relatedDrills: ['PATTERN_3_BALLS', 'PATTERN_5_BALLS', 'POSITION_3BALL'],
    tags: ['positioning', 'tag_pattern', 'tag_positioning'],
  ),

  // ============================================================================
  // MENTAL GAME — Tâm lý thi đấu
  // ============================================================================
  KnowledgeArticle(
    id: 'mental-game',
    title: 'Mental game — Tâm lý trong thi đấu billiards',
    category: 'mental',
    level: 'intermediate',
    summary: 'Mental game là yếu tố tâm lý quyết định 50% kết quả trận đấu. Kiểm soát cảm xúc, tập trung vào quá trình, không kết quả.',
    content: '''
**Tại sao mental game quan trọng?**

Trong billiards, kỹ thuật chỉ quyết định 50% kết quả. 50% còn lại là tâm lý.

**Các yếu tố tâm lý chính:**

1. **Confidence (Tự tin)**
   - Tự tin đến từ việc luyện tập đúng cách
   - Không tự tin = đánh run, sai cú dễ
   - Cách tăng: tập những cú đã thành thạo mỗi ngày

2. **Focus (Tập trung)**
   - Tập trung vào cú đánh hiện tại, không nghĩ về cú trước
   - Không nghĩ về điểm số
   - Tip: hít thở sâu trước mỗi cú

3. **Tilt control (Kiểm soát cảm xúc)**
   - Tilt = mất kiểm soát cảm xúc sau khi thua
   - Dấu hiệu tilt: thở nhanh, tay run, quyết định vội vàng
   - Cách kiểm soát: dừng 30 giây, hít thở, uống nước

4. **Pressure (Áp lực)**
   - Áp lực từ điểm số, đối thủ, khán giả
   - Áp lực giúp một số người chơi tốt hơn
   - Áp lực làm một số người chơi kém hơn
   - Biết mình thuộc loại nào

**Cách rèn luyện mental game:**

1. Tưởng tượng (visualization) trước khi ngủ
2. Tự nói chuyện với bản thân (self-talk) tích cực
3. Ghi lại trận đấu, xem lại để học từ sai lầm
4. Tập thở và thiền 5-10 phút mỗi ngày
5. Tập trong điều kiện có áp lực (đặt cược nhỏ với bạn bè)

**Lời khuyên:**
- Không bao giờ tỏ ra "chắc thắng" — đối thủ có thể hồi phục
- Không bao giờ tỏ ra "chắc thua" — có thể đối thủ đang căng thẳng
- Luôn tập trung vào quá trình, không phải kết quả
''',
    keyTakeaways: [
      'Mental game = 50% kết quả trận đấu',
      'Tự tin đến từ luyện tập',
      'Tập trung vào cú hiện tại',
      'Kiểm soát tilt bằng cách dừng 30 giây',
      'Áp lực có thể là bạn hoặc kẻ thù',
    ],
    relatedDrills: ['BREAK_POWER', 'STRAIGHT_NEAR'],
    tags: ['mental', 'tag_psychology', 'tag_tilt'],
  ),

  KnowledgeArticle(
    id: 'pressure-play',
    title: 'Chơi dưới áp lực — Khi điểm số quan trọng',
    category: 'mental',
    level: 'advanced',
    summary: 'Cách chơi hiệu quả khi điểm số quan trọng, đối thủ thắng thế, hoặc thi đấu quan trọng.',
    content: '''
**Áp lực trong billiards:**

Áp lực xuất hiện khi:
- Đang thắng và muốn giữ
- Đang thua và cần gỡ
- Trận đấu quan trọng
- Đối thủ mạnh hơn
- Thi đấu trước khán giả

**Triệu chứng áp lực:**

1. **Thể chất:**
   - Tim đập nhanh
   - Tay run hoặc cứng
   - Thở nông, không đều
   - Ra mồ hôi nhiều hơn bình thường

2. **Tinh thần:**
   - Nghĩ quá nhiều về kết quả
   - Phân tán chú ý
   - Đưa ra quyết định vội vàng
   - Mất tự tin đột ngột

**Cách xử lý áp lực:**

1. **Thở:** Hít sâu 4 giây, giữ 4 giây, thở ra 4 giây. Lặp 3 lần.

2. **Ritual trước cú:** Tạo thói quen trước mỗi cú đánh (đặt cơ xuống, nhìn, hít thở, đánh)

3. **Một cú một lần:** Không nghĩ về cú trước hay cú tiếp theo. Chỉ nghĩ về cú hiện tại.

4. **Visualization:** Trước khi đánh, tưởng tượng cú đánh thành công trong đầu.

5. **Điểm số không quan trọng:** Tập trung vào quá trình đánh tốt, điểm số sẽ tự cải thiện.

**Luyện tập dưới áp lực:**

- Tập với "stakes" nhỏ: thua thì phạt (10 cái chạm, chống đẩy)
- Tập với đối thủ giỏi hơn
- Tập thi đấu mô phỏng (đặt thời gian, điểm số giả)
- Tập trước khán giả

**Tư duy đúng:**
- "Dưới áp lực, tôi chơi tốt hơn" → self-fulfilling prophecy
- "Áp lực là cơ hội để tỏa sáng" → growth mindset
- "Thắng thua không quan trọng bằng việc đánh tốt" → process focus
''',
    keyTakeaways: [
      'Áp lực gây run tay, phân tán chú ý',
      'Thở sâu 4-4-4 giúp bình tĩnh',
      'Một cú một lần, không nghĩ về điểm số',
      'Tưởng tượng cú thành công trước khi đánh',
      'Luyện tập với stakes nhỏ để quen áp lực',
    ],
    relatedDrills: ['STRAIGHT_NEAR', 'STRAIGHT_MID'],
    tags: ['mental', 'tag_pressure', 'tag_advanced'],
  ),

  // ============================================================================
  // BREAK — Khai cuộc
  // ============================================================================
  KnowledgeArticle(
    id: 'break-technique',
    title: 'Kỹ thuật break — Nền tảng của mọi trận đấu',
    category: 'break',
    level: 'intermediate',
    summary: 'Break là cú đánh đầu tiên trong mỗi rack. Một break tốt tạo cơ hội ghi điểm ngay, break không tốt có thể mất lợi thế.',
    content: '''
**Break là gì?**

Break là cú đánh mở đầu mỗi rack, đánh bi 1 vào tổ hợp bi để phát tán chúng.

**Mục tiêu của break:**

1. **Phát tán bi:** Làm bi tách ra khắp bàn
2. **Ghi điểm:** Đánh được ít nhất 1 bi vào lỗ (break and run)
3. **Kiểm soát:** Không để đối thủ dễ đánh

**Các loại break phổ biến:**

1. **Power Break:**
   - Đánh mạnh để phát tán mạnh
   - Ưu điểm: nhiều bi bay ra
   - Nhược điểm: mất kiểm soát bi cái

2. **Control Break:**
   - Đánh vừa phải, nhắm vào vị trí
   - Ưu điểm: kiểm soát tốt hơn
   - Nhược điểm: ít bi phát tán hơn

3. **Cut Break:**
   - Đánh lệch để tạo góc
   - Ưu điểm: tạo cơ hội cho mình
   - Nhược điểm: khó kiểm soát

**Kỹ thuật đánh break:**

1. **Điểm đánh trên bi:**
   - 1/4 dưới tâm: ít xoáy, phát tán mạnh
   - 1/2 dưới tâm: xoáy forward, bi cái đi theo bi đánh
   - Dưới đáy: xoáy back, bi cái quay về

2. **Vị trí đứng:**
   - Chân trước hơi xa bàn
   - Thân nghiêng về phía trước
   - Tay sau nắm cuối cơ (power grip)

3. **Lực đánh:**
   - Đánh mạnh và nhanh
   - Follow through đầy đủ
   - Không "chặn" cơ khi tiếp xúc

4. **Follow through:**
   - Vung cơ qua bi, không dừng
   - Tay cao theo sau cú đánh
   - Độ dài follow through = độ mạnh cú đánh

**Lỗi thường gặp:**

1. Đánh không đủ lực → bi không phát tán
2. Điểm đánh sai → bi đi lệch hướng
3. Follow through ngắn → mất lực
4. Tay run → miscues

**Cách luyện tập:**

1. Bắt đầu với power break để cảm nhận lực
2. Tập kiểm soát điểm đánh trên bi
3. Tập break vào lỗ cụ thể
4. Quay video để phân tích kỹ thuật
''',
    keyTakeaways: [
      'Break = cú đánh mở đầu mỗi rack',
      'Điểm đánh 1/4 dưới tâm để phát tán',
      'Follow through đầy đủ = lực đánh tốt',
      'Power break vs control break tùy tình huống',
      'Quay video để phân tích kỹ thuật',
    ],
    relatedDrills: ['BREAK_POWER', 'BREAK_CONTROL', 'BREAK_ACCURACY'],
    tags: ['break', 'tag_technique', 'tag_power'],
  ),

  // ============================================================================
  // SAFETY PLAY
  // ============================================================================
  KnowledgeArticle(
    id: 'safety-fundamentals',
    title: 'Safety play — Khi không thể đánh trúng',
    category: 'safety',
    level: 'intermediate',
    summary: 'Safety là cú đánh không nhắm ghi điểm mà tạo thế khó cho đối thủ. Đây là kỹ năng chiến thuật quan trọng.',
    content: '''
**Safety là gì?**

Safety là cú đánh mục đích không phải ghi điểm mà tạo thế khó cho đối thủ.

**Khi nào nên đánh safety:**

1. Không có cú đánh trúng chắc chắn
2. Đang thắng điểm, muốn giữ lợi thế
3. Đối thủ đang có momentum
4. Hết giờ (trong thi đấu có thời gian)

**Các loại safety:**

1. **Hit and Stay:**
   - Đánh bi cái chạm bi đối thủ
   - Bi đối thủ dừng gần vị trí cũ
   - Đối thủ khó đánh trúng

2. **Hit and Run:**
   - Đánh bi cái chạm bi đối thủ
   - Bi cái đi ra xa
   - Tạo khoảng cách bất lợi cho đối thủ

3. **Legal Ball:**
   - Đánh đúng bi đầu tiên
   - Không phạm lỗi (foul)
   - Tạo thế khó cho đối thủ

4. **Plant:**
   - Bi đối thủ gần lỗ nhưng đánh trực tiếp khó
   - Đánh bi đối thủ để nó đi vào lỗ
   - "Ăn gian" một cú điểm

**Nguyên tắc safety tốt:**

1. **Đánh đúng bi đầu tiên** — không phạm lỗi
2. **Tạo khoảng cách** — đối thủ phải đánh xa
3. **Khó cho đối thủ** — ít lỗ mở, bi đối thủ xa lỗ
4. **An toàn cho mình** — không tạo cơ hội cho đối thủ

**Cách luyện safety:**

1. Đặt bi đối thủ ở các vị trí khác nhau
2. Tập đánh safety từ xa
3. Tập kick safety (đá bi khi không đánh thẳng được)
4. Tập 2-ball safety (2 bi cách nhau)

**Trong thi đấu:**

- Safety là quyền lựa chọn, không phải lựa chọn cuối cùng
- Đọc thế bàn trước khi quyết định safety hay đánh
- Safety tốt có thể khiến đối thủ phạm sai lầm
''',
    keyTakeaways: [
      'Safety = tạo thế khó cho đối thủ',
      'Đánh đúng bi đầu tiên, không phạm lỗi',
      'Hit and Run tạo khoảng cách bất lợi',
      'Safety là quyền lựa chọn chiến thuật',
      'Luyện kick safety để đa dạng',
    ],
    relatedDrills: ['SAFETY_BASIC', 'SAFETY_FORCE', 'SAFETY_KICK'],
    tags: ['safety', 'tag_strategy', 'tag_defensive'],
  ),

  // ============================================================================
  // AIMING — Bổ sung
  // ============================================================================
  KnowledgeArticle(
    id: 'cut-shot-geometry',
    title: 'Hình học của cú cắt — Hiểu để đánh chính xác',
    category: 'aiming',
    level: 'advanced',
    summary: 'Cú cắt (cut shot) là cú đánh mà bi cái và bi mục tiêu không thẳng hàng với lỗ. Hiểu hình học giúp đánh chính xác hơn.',
    content: '''
**Cú cắt là gì?**

Cú cắt (cut shot) là cú đánh mà:
- Bi cái không đi thẳng đến bi mục tiêu
- Góc cắt = góc giữa đường bi cái-bi mục tiêu và đường bi mục tiêu-lỗ

**Các loại cú cắt:**

1. **Thin Cut (Cắt mỏng):**
   - Góc cắt > 45 độ
   - Bi mục tiêu ở xa lỗ
   - Khó đánh, dễ miss

2. **Half Ball (Nửa bi):**
   - Góc cắt = 30 độ
   - Điểm ngắm = mép bi mục tiêu
   - Cú cắt phổ biến nhất

3. **Thick Cut (Cắt dày):**
   - Góc cắt < 30 độ
   - Bi mục tiêu gần lỗ
   - Dễ đánh hơn

**Cách xác định góc cắt:**

1. **Bằng mắt:**
   - Ước lượng góc
   - Tập với nhiều tình huống
   - Kinh nghiệm là chìa khóa

2. **Bằng hình học:**
   - Điểm ngắm = tâm bi mục tiêu + offset
   - Offset = khoảng cách từ tâm đến điểm cắt
   - Công thức: Offset = R × sin(góc cắt)

3. **Ghost ball method:**
   - Tưởng tượng bi trắng "đi qua" bi mục tiêu
   - Điểm cắt = điểm tiếp xúc ảo
   - Đánh vào điểm đó

**Tip đánh cú cắt:**

1. **Ngắm điểm rìa bi mục tiêu** — điểm gần nhất với hướng lỗ

2. **Điều khiển lực theo góc** — góc cắt lớn → lực nhẹ hơn

3. **Follow through đầy đủ** — không "chặn" cơ

4. **Giữ mắt trên đường ngắm** — không nhìn bi cái khi ra cơ

**Luyện tập:**

1. Bắt đầu với half ball (30 độ)
2. Tập thin cut từ dễ đến khó
3. Tập đánh vào lỗ khác nhau
4. Tập với khoảng cách khác nhau
''',
    keyTakeaways: [
      'Cú cắt = bi cái không thẳng với bi mục tiêu-lỗ',
      'Half ball = góc 30 độ, điểm ngắm = mép bi',
      'Thin cut (>45 độ) khó hơn thick cut (<30 đô)',
      'Ghost ball method giúp xác định điểm ngắm',
      'Góc cắt lớn → lực nhẹ hơn',
    ],
    relatedDrills: ['THIN_CUT_30', 'HALF_BALL_LEFT', 'HALF_BALL_RIGHT'],
    tags: ['aiming', 'tag_cut', 'tag_geometry'],
  ),
];