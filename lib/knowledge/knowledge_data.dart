// ============================================================================
// KNOWLEDGE DATA - Imported from V1
// ============================================================================

import 'knowledge_models.dart';

// ============================================================================
// TAGS - Imported from V1
// ============================================================================

const knowledgeTags = [
  KnowledgeTag(id: 'tag_basic', name: 'Basic', nameVi: 'Cơ bản', color: '#4CAF50'),
  KnowledgeTag(id: 'tag_intermediate', name: 'Intermediate', nameVi: 'Trung bình', color: '#2196F3'),
  KnowledgeTag(id: 'tag_advanced', name: 'Advanced', nameVi: 'Nâng cao', color: '#FF9800'),
  KnowledgeTag(id: 'tag_expert', name: 'Expert', nameVi: 'Chuyên gia', color: '#F44336'),
  KnowledgeTag(id: 'tag_shotmaking', name: 'Shot Making', nameVi: 'Kỹ thuật đánh', color: '#9C27B0'),
  KnowledgeTag(id: 'tag_positioning', name: 'Positioning', nameVi: 'Vị trí', color: '#00BCD4'),
  KnowledgeTag(id: 'tag_aiming', name: 'Aiming', nameVi: 'Ngắm bắn', color: '#E91E63'),
  KnowledgeTag(id: 'tag_strategy', name: 'Strategy', nameVi: 'Chiến lược', color: '#673AB7'),
  KnowledgeTag(id: 'tag_speed', name: 'Speed Control', nameVi: 'Kiểm soát lực', color: '#795548'),
  KnowledgeTag(id: 'tag_cueball', name: 'Cue Ball', nameVi: 'Bi trắng', color: '#607D8B'),
  KnowledgeTag(id: 'tag_bank', name: 'Bank Shot', nameVi: 'Cú băng', color: '#009688'),
  KnowledgeTag(id: 'tag_bridge', name: 'Bridge', nameVi: 'Tay gác', color: '#3F51B5'),
  KnowledgeTag(id: 'tag_technique', name: 'Technique', nameVi: 'Kỹ thuật', color: '#FFC107'),
  KnowledgeTag(id: 'tag_defense', name: 'Defense', nameVi: 'Phòng thủ', color: '#FF5722'),
  KnowledgeTag(id: 'tag_backspin', name: 'Backspin', nameVi: 'Quay lùi', color: '#00BCD4'),
  KnowledgeTag(id: 'tag_topspin', name: 'Topspin', nameVi: 'Quay tới', color: '#03A9F4'),
];

// ============================================================================
// CATEGORIES - Imported from V1
// ============================================================================

const knowledgeCategories = [
  KnowledgeCategory(
    id: 'cat_fundamentals',
    slug: 'fundamentals',
    name: 'Fundamentals',
    nameVi: 'Nền Tảng',
    description: 'Basic techniques and posture',
    icon: 'school',
    order: 1,
  ),
  KnowledgeCategory(
    id: 'cat_shotmaking',
    slug: 'shot-making',
    name: 'Shot Making',
    nameVi: 'Kỹ Thuật Đánh',
    description: 'Core shot techniques',
    icon: 'sports_cricket',
    order: 2,
  ),
  KnowledgeCategory(
    id: 'cat_aiming',
    slug: 'aiming',
    name: 'Aiming',
    nameVi: 'Ngắm Bắn',
    description: 'Aiming techniques and alignment',
    icon: 'gps_fixed',
    order: 3,
  ),
  KnowledgeCategory(
    id: 'cat_positioning',
    slug: 'positioning',
    name: 'Positioning',
    nameVi: 'Kiểm Soát Vị Trí',
    description: 'Cue ball control and position play',
    icon: 'timeline',
    order: 4,
  ),
  KnowledgeCategory(
    id: 'cat_strategy',
    slug: 'strategy',
    name: 'Strategy',
    nameVi: 'Chiến Lược',
    description: 'Game strategy and tactics',
    icon: 'psychology',
    order: 5,
  ),
  KnowledgeCategory(
    id: 'cat_equipment',
    slug: 'equipment',
    name: 'Equipment',
    nameVi: 'Dụng Cụ',
    description: 'Cues, tips, and table equipment',
    icon: 'build',
    order: 6,
  ),
  KnowledgeCategory(
    id: 'cat_psychology',
    slug: 'psychology',
    name: 'Psychology',
    nameVi: 'Tâm Lý',
    description: 'Mental game and focus',
    icon: 'self_improvement',
    order: 7,
  ),
  KnowledgeCategory(
    id: 'cat_rules',
    slug: 'rules',
    name: 'Rules',
    nameVi: 'Luật Chơi',
    description: 'Game rules and regulations',
    icon: 'rule',
    order: 8,
  ),
];

// ============================================================================
// KNOWLEDGE ITEMS - Imported from V1
// ============================================================================

const knowledgeItems = [
  // SHOT MAKING - Imported from V1
  KnowledgeItem(
    id: 'kn_stop-shot',
    slug: 'stop-shot',
    title: 'Stop Shot',
    titleVi: 'Dừng bi cái',
    content: '''# Stop Shot

## Mục tiêu
Bi cái dừng ngay tại điểm chạm với bi mục tiêu, không đi xa hơn.

## Kỹ thuật
1. **Điểm đánh**: Đánh vào tâm bi cái (hoặc hơi dưới tâm một chút)
2. **Lực đánh**: Vừa phải đến mạnh
3. **Follow through**: Đầy đủ, không dừng đột ngột

## Lưu ý
- Đánh mạnh hơn bình thường một chút để overcome friction
- Giữ cổ tay cố định
- Follow through phải dài để truyền đủ lực

## Sai lầm thường gặp
- Đánh quá nhẹ
- Điểm đánh quá cao (tạo follow)
- Follow through không đủ dài''',
    contentVi: '''# Dừng bi cái (Stop Shot)

## Mục tiêu
Bi cái dừng ngay tại điểm chạm với bi mục tiêu, không đi xa hơn.

## Kỹ thuật
1. **Điểm đánh**: Đánh vào tâm bi cái (hoặc hơi dưới tâm một chút)
2. **Lực đánh**: Vừa phải đến mạnh
3. **Follow through**: Đầy đủ, không dừng đột ngột

## Lưu ý
- Đánh mạnh hơn bình thường một chút để overcome friction
- Giữ cổ tay cố định
- Follow through phải dài để truyền đủ lực

## Sai lầm thường gặp
- Đánh quá nhẹ
- Điểm đánh quá cao (tạo follow)
- Follow through không đủ dài''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_basic', 'tag_shotmaking'],
    aliases: ['stop shot', 'dừng bi cái', 'stop', 'dung'],
    keywords: ['stop shot', 'dừng bi cái', 'cue ball control'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_draw-shot', 'kn_follow-shot'],
    relatedDrillCodes: ['STOP_LV1', 'STOP_LV2', 'STOP_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_draw-shot',
    slug: 'draw-shot',
    title: 'Draw Shot',
    titleVi: 'Draw',
    content: '''# Draw Shot

## Mục tiêu
Bi cái quay ngược lại sau khi chạm bi mục tiêu.

## Kỹ thuật
1. **Điểm đánh**: Dưới tâm bi cái (1/4 đến 1/2)
2. **Lực đánh**: Mạnh vừa phải
3. **Follow through**: Dài, hướng về phía bi mục tiêu

## Các cấp độ
- **Level 1**: Draw 20-30cm
- **Level 2**: Draw 40-50cm
- **Level 3**: Draw 60-80cm
- **Level 4**: Draw gần hết bàn
- **Level 5**: Full draw

## Lưu ý
- Điểm đánh càng thấp, draw càng nhiều
- Lực đánh ảnh hưởng đến khoảng cách quay lại
- Practice kiên nhẫn để cảm nhận

## Sai lầm thường gặp
- Điểm đánh không đủ thấp
- Đánh quá nhẹ
- "Scooping" - nâng đầu cơ khi đánh''',
    contentVi: '''# Draw Shot

## Mục tiêu
Bi cái quay ngược lại sau khi chạm bi mục tiêu.

## Kỹ thuật
1. **Điểm đánh**: Dưới tâm bi cái (1/4 đến 1/2)
2. **Lực đánh**: Mạnh vừa phải
3. **Follow through**: Dài, hướng về phía bi mục tiêu

## Các cấp độ
- **Level 1**: Draw 20-30cm
- **Level 2**: Draw 40-50cm
- **Level 3**: Draw 60-80cm
- **Level 4**: Draw gần hết bàn
- **Level 5**: Full draw

## Lưu ý
- Điểm đánh càng thấp, draw càng nhiều
- Lực đánh ảnh hưởng đến khoảng cách quay lại
- Practice kiên nhẫn để cảm nhận

## Sai lầm thường gặp
- Điểm đánh không đủ thấp
- Đánh quá nhẹ
- "Scooping" - nâng đầu cơ khi đánh''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_basic', 'tag_shotmaking', 'tag_backspin'],
    aliases: ['draw shot', 'draw', 'backspin', 'lui'],
    keywords: ['draw shot', 'backspin', 'pull back'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stop-shot', 'kn_follow-shot'],
    relatedDrillCodes: ['DRAW_LV1', 'DRAW_LV2', 'DRAW_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_follow-shot',
    slug: 'follow-shot',
    title: 'Follow Shot',
    titleVi: 'Follow',
    content: '''# Follow Shot

## Mục tiêu
Bi cái đi cùng hướng với bi mục tiêu sau khi chạm.

## Kỹ thuật
1. **Điểm đánh**: Trên tâm bi cái (1/4 đến 1/2)
2. **Lực đánh**: Mạnh hơn bình thường 20-30%
3. **Follow through**: Rất dài

## Các cấp độ
- **Level 1**: Follow 30cm
- **Level 2**: Follow 50cm
- **Level 3**: Follow 80cm
- **Level 4**: Follow 1m
- **Level 5**: Full follow

## Lưu ý
- Điểm đánh càng cao, follow càng nhiều
- Lực phải đủ mạnh để overcome backspin
- Follow through dài là chìa khóa

## Sai lầm thường gặp
- Điểm đánh không đủ cao
- Đánh quá nhẹ
- Follow through quá ngắn''',
    contentVi: '''# Follow Shot

## Mục tiêu
Bi cái đi cùng hướng với bi mục tiêu sau khi chạm.

## Kỹ thuật
1. **Điểm đánh**: Trên tâm bi cái (1/4 đến 1/2)
2. **Lực đánh**: Mạnh hơn bình thường 20-30%
3. **Follow through**: Rất dài

## Các cấp độ
- **Level 1**: Follow 30cm
- **Level 2**: Follow 50cm
- **Level 3**: Follow 80cm
- **Level 4**: Follow 1m
- **Level 5**: Full follow

## Lưu ý
- Điểm đánh càng cao, follow càng nhiều
- Lực phải đủ mạnh để overcome backspin
- Follow through dài là chìa khóa

## Sai lầm thường gặp
- Điểm đánh không đủ cao
- Đánh quá nhẹ
- Follow through quá ngắn''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_basic', 'tag_shotmaking', 'tag_topspin'],
    aliases: ['follow shot', 'follow', 'topspin', 'theo'],
    keywords: ['follow shot', 'topspin', 'forward roll'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stop-shot', 'kn_draw-shot'],
    relatedDrillCodes: ['FOLLOW_LV1', 'FOLLOW_LV2', 'FOLLOW_LV3'],
  ),

  // AIMING - Imported from V1
  KnowledgeItem(
    id: 'kn_ghost-ball',
    slug: 'ghost-ball',
    title: 'Ghost Ball Method',
    titleVi: 'Phương pháp Ghost Ball',
    content: '''# Phương pháp Ghost Ball

## Giới thiệu
Ghost Ball là phương pháp ngắm phổ biến nhất, giúp xác định điểm ngắm chính xác.

## Cách thực hiện
1. **Hình dung bi cái**: Tưởng tượng một bi cái "ma" (ghost ball) đặt ngay vị trí bi cái cần đến
2. **Xác định điểm tiếp xúc**: Điểm mà bi mục tiêu cần chạm bi cái
3. **Ngắm điểm**: Aim vào điểm đó

## Áp dụng cho các cú đánh
- **Cú thẳng**: Điểm ngắm là tâm lỗ
- **Cú cắt**: Điểm ngắm là điểm tiếp xúc
- **Cú bank**: Cần tính góc phản xạ

## Luyện tập
1. Đặt 2 bi thẳng hàng với lỗ
2. Ngắm bi "ma" bằng mắt
3. Thực hành nhiều lần''',
    contentVi: '''# Phương pháp Ghost Ball

## Giới thiệu
Ghost Ball là phương pháp ngắm phổ biến nhất, giúp xác định điểm ngắm chính xác.

## Cách thực hiện
1. **Hình dung bi cái**: Tưởng tượng một bi cái "ma" (ghost ball) đặt ngay vị trí bi cái cần đến
2. **Xác định điểm tiếp xúc**: Điểm mà bi mục tiêu cần chạm bi cái
3. **Ngắm điểm**: Aim vào điểm đó

## Áp dụng cho các cú đánh
- **Cú thẳng**: Điểm ngắm là tâm lỗ
- **Cú cắt**: Điểm ngắm là điểm tiếp xúc
- **Cú bank**: Cần tính góc phản xạ

## Luyện tập
1. Đặt 2 bi thẳng hàng với lỗ
2. Ngắm bi "ma" bằng mắt
3. Thực hành nhiều lần''',
    categoryId: 'cat_aiming',
    tagIds: ['tag_basic', 'tag_aiming'],
    aliases: ['ghost ball', 'bi ao', 'phuong phap bi ao'],
    keywords: ['ghost ball', 'aiming', 'contact point'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_cut-shots'],
    relatedDrillCodes: ['STRAIGHT_LV1', 'STRAIGHT_LV2'],
  ),
  KnowledgeItem(
    id: 'kn_cut-shots',
    slug: 'cut-shots',
    title: 'Cut Shots',
    titleVi: 'Cú cắt',
    content: '''# Cut Shots - Cú cắt

## Định nghĩa
Cú cắt là cú đánh mà bi cái không đi thẳng đến bi mục tiêu mà đi theo góc.

## Góc cắt
- **0°**: Cú thẳng (straight)
- **1-30°**: Cú cắt mỏng (thin cut)
- **30-60°**: Cú cắt trung bình (medium cut)
- **60-90°**: Cú cắt dày (thick cut)

## Kỹ thuật
1. **Xác định góc**: Ước lượng góc cắt
2. **Điểm ngắm**: Dịch chuyển điểm ngắm sang phía ngược lại với góc cắt
3. **Kiểm soát lực**: Lực ảnh hưởng đến độ chính xác

## Mẹo
- Góc cắt càng lớn, cần độ chính xác càng cao
- Giảm lực khi góc cắt lớn
- Practice các góc từ dễ đến khó''',
    contentVi: '''# Cut Shots - Cú cắt

## Định nghĩa
Cú cắt là cú đánh mà bi cái không đi thẳng đến bi mục tiêu mà đi theo góc.

## Góc cắt
- **0°**: Cú thẳng (straight)
- **1-30°**: Cú cắt mỏng (thin cut)
- **30-60°**: Cú cắt trung bình (medium cut)
- **60-90°**: Cú cắt dày (thick cut)

## Kỹ thuật
1. **Xác định góc**: Ước lượng góc cắt
2. **Điểm ngắm**: Dịch chuyển điểm ngắm sang phía ngược lại với góc cắt
3. **Kiểm soát lực**: Lực ảnh hưởng đến độ chính xác

## Mẹo
- Góc cắt càng lớn, cần độ chính xác càng cao
- Giảm lực khi góc cắt lớn
- Practice các góc từ dễ đến khó''',
    categoryId: 'cat_aiming',
    tagIds: ['tag_intermediate', 'tag_aiming'],
    aliases: ['cut shots', 'cu cat', 'cat'],
    keywords: ['cut shot', 'aiming', 'angle'],
    difficulty: DifficultyLevel.intermediate,
    relatedKnowledgeIds: ['kn_ghost-ball'],
    relatedDrillCodes: ['STRAIGHT_LV1', 'STRAIGHT_LV2'],
  ),

  // STRATEGY - Imported from V1
  KnowledgeItem(
    id: 'kn_basic-safety',
    slug: 'basic-safety',
    title: 'Basic Safety',
    titleVi: 'An toàn cơ bản',
    content: '''# An toàn cơ bản

## Mục tiêu
Đánh safety sao cho đối thủ khó ghi điểm.

## Nguyên tắc
1. **Để bi đối thủ xa lỗ**: Tạo khoảng cách
2. **Kiểm soát bi cái**: Không tạo cơ hội cho đối thủ
3. **Tạo thế khó**: Buộc đối thủ đánh cú khó

## Kỹ thuật
1. **Đọc bàn**: Quan sát vị trí các bi và lỗ
2. **Tính góc**: Xác định điểm đánh trên băng
3. **Kiểm soát lực**: Bi cái dừng ở vị trí mong muốn

## Các loại safety
- **Hook**: Để bi đối thủ bị kẹp
- **Side safety**: Để bi đối thủ ở bên
- **Long safety**: Đẩy bi đối thủ ra xa''',
    contentVi: '''# An toàn cơ bản

## Mục tiêu
Đánh safety sao cho đối thủ khó ghi điểm.

## Nguyên tắc
1. **Để bi đối thủ xa lỗ**: Tạo khoảng cách
2. **Kiểm soát bi cái**: Không tạo cơ hội cho đối thủ
3. **Tạo thế khó**: Buộc đối thủ đánh cú khó

## Kỹ thuật
1. **Đọc bàn**: Quan sát vị trí các bi và lỗ
2. **Tính góc**: Xác định điểm đánh trên băng
3. **Kiểm soát lực**: Bi cái dừng ở vị trí mong muốn

## Các loại safety
- **Hook**: Để bi đối thủ bị kẹp
- **Side safety**: Để bi đối thủ ở bên
- **Long safety**: Đẩy bi đối thủ ra xa''',
    categoryId: 'cat_strategy',
    tagIds: ['tag_advanced', 'tag_strategy', 'tag_defense'],
    aliases: ['safety', 'an toan', 'choi an toan'],
    keywords: ['safety', 'defensive', 'strategy'],
    difficulty: DifficultyLevel.advanced,
    relatedKnowledgeIds: ['kn_position-play'],
    relatedDrillCodes: ['SAFETY_LV1', 'SAFETY_LV2'],
  ),
  KnowledgeItem(
    id: 'kn_position-play',
    slug: 'position-play',
    title: 'Position Play',
    titleVi: 'Vị trí',
    content: '''# Vị trí (Position Play)

## Tầm quan trọng
Kiểm soát vị trí bi cái là kỹ năng phân biệt người chơi giỏi và xuất sắc.

## Nguyên tắc cơ bản
1. **Plan ahead**: Luôn nghĩ đến cú tiếp theo
2. **Leave options**: Để nhiều lựa chọn cho bản thân
3. **Control pace**: Kiểm soát tốc độ bi

## Kỹ thuật
- **Speed control**: Điều khiển lực
- **Spin application**: Sử dụng xoáy
- **Natural angles**: Tận dụng góc tự nhiên

## Practice
1. Đặt 3 bi, đánh lần lượt
2. Kết thúc ở vị trí thuận lợi cho cú tiếp
3. Tăng dần độ khó''',
    contentVi: '''# Vị trí (Position Play)

## Tầm quan trọng
Kiểm soát vị trí bi cái là kỹ năng phân biệt người chơi giỏi và xuất sắc.

## Nguyên tắc cơ bản
1. **Plan ahead**: Luôn nghĩ đến cú tiếp theo
2. **Leave options**: Để nhiều lựa chọn cho bản thân
3. **Control pace**: Kiểm soát tốc độ bi

## Kỹ thuật
- **Speed control**: Điều khiển lực
- **Spin application**: Sử dụng xoáy
- **Natural angles**: Tận dụng góc tự nhiên

## Practice
1. Đặt 3 bi, đánh lần lượt
2. Kết thúc ở vị trí thuận lợi cho cú tiếp
3. Tăng dần độ khó''',
    categoryId: 'cat_positioning',
    tagIds: ['tag_advanced', 'tag_positioning', 'tag_strategy'],
    aliases: ['position play', 'vi tri', 'kiem soat vi tri'],
    keywords: ['position play', 'cue ball control', 'speed'],
    difficulty: DifficultyLevel.advanced,
    relatedKnowledgeIds: ['kn_stop-shot', 'kn_draw-shot', 'kn_follow-shot'],
    relatedDrillCodes: ['POSITION_LV1', 'POSITION_LV2', 'POSITION_LV3'],
  ),

  // FUNDAMENTALS - Imported from V1
  KnowledgeItem(
    id: 'kn_open-bridge',
    slug: 'open-bridge',
    title: 'Open Bridge',
    titleVi: 'Gác cơ mở',
    content: '''# Gác cơ mở (Open Bridge)

## Mô tả
Đây là kiểu gác cơ phổ biến nhất, dễ thực hiện.

## Cách thực hiện
1. Đặt tay lên bàn, ngón cái hướng về phía trước
2. Ngón trỏ quấn xuống, tạo vòng
3. Các ngón còn lại đặt trên bàn
4. Khoảng trống giữa ngón cái và ngón trỏ là nơi cơ đi qua

## Lưu ý
- Tay phải chắc chắn, không rung
- Khoảng trống đủ rộng cho cơ
- Cánh tay tạo đường thẳng với cơ''',
    contentVi: '''# Gác cơ mở (Open Bridge)

## Mô tả
Đây là kiểu gác cơ phổ biến nhất, dễ thực hiện.

## Cách thực hiện
1. Đặt tay lên bàn, ngón cái hướng về phía trước
2. Ngón trỏ quấn xuống, tạo vòng
3. Các ngón còn lại đặt trên bàn
4. Khoảng trống giữa ngón cái và ngón trỏ là nơi cơ đi qua

## Lưu ý
- Tay phải chắc chắn, không rung
- Khoảng trống đủ rộng cho cơ
- Cánh tay tạo đường thẳng với cơ''',
    categoryId: 'cat_fundamentals',
    tagIds: ['tag_basic', 'tag_technique'],
    aliases: ['open bridge', 'gac co mo', 'bridge'],
    keywords: ['bridge', 'grip', 'stability'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_closed-bridge'],
    relatedDrillCodes: ['STRAIGHT_LV1'],
  ),
  KnowledgeItem(
    id: 'kn_closed-bridge',
    slug: 'closed-bridge',
    title: 'Closed Bridge',
    titleVi: 'Gác cơ kín',
    content: '''# Gác cơ kín (Closed Bridge)

## Mô tả
Dùng khi cần kiểm soát chặt chẽ hơn, đặc biệt cho cú đánh mềm.

## Cách thực hiện
1. Đặt tay như open bridge
2. Gập ngón trỏ xuống, chạm vào ngón cái
3. Tạo vòng kín bao quanh cơ
4. Có thể dùng ngón giữa hỗ trợ

## Ưu điểm
- Kiểm soát tốt hơn
- Ít bị run
- Tốt cho cú đánh mềm, chính xác

## Nhược điểm
- Khó thực hiện hơn
- Cần practice nhiều''',
    contentVi: '''# Gác cơ kín (Closed Bridge)

## Mô tả
Dùng khi cần kiểm soát chặt chẽ hơn, đặc biệt cho cú đánh mềm.

## Cách thực hiện
1. Đặt tay như open bridge
2. Gập ngón trỏ xuống, chạm vào ngón cái
3. Tạo vòng kín bao quanh cơ
4. Có thể dùng ngón giữa hỗ trợ

## Ưu điểm
- Kiểm soát tốt hơn
- Ít bị run
- Tốt cho cú đánh mềm, chính xác

## Nhược điểm
- Khó thực hiện hơn
- Cần practice nhiều''',
    categoryId: 'cat_fundamentals',
    tagIds: ['tag_intermediate', 'tag_technique'],
    aliases: ['closed bridge', 'gac co kin', 'bridge'],
    keywords: ['bridge', 'grip', 'control'],
    difficulty: DifficultyLevel.intermediate,
    relatedKnowledgeIds: ['kn_open-bridge'],
    relatedDrillCodes: ['STRAIGHT_LV1', 'STRAIGHT_LV2'],
  ),
];

// ============================================================================
// DRILL - KNOWLEDGE MAPPING - Imported from V1
// ============================================================================

const drillKnowledgeMapping = {
  'STOP_LV1': ['kn_stop-shot'],
  'STOP_LV2': ['kn_stop-shot'],
  'STOP_LV3': ['kn_stop-shot'],
  'DRAW_LV1': ['kn_draw-shot'],
  'DRAW_LV2': ['kn_draw-shot'],
  'DRAW_LV3': ['kn_draw-shot'],
  'FOLLOW_LV1': ['kn_follow-shot'],
  'FOLLOW_LV2': ['kn_follow-shot'],
  'FOLLOW_LV3': ['kn_follow-shot'],
  'STRAIGHT_LV1': ['kn_ghost-ball', 'kn_open-bridge'],
  'STRAIGHT_LV2': ['kn_ghost-ball', 'kn_cut-shots', 'kn_closed-bridge'],
  'SAFETY_LV1': ['kn_basic-safety'],
  'SAFETY_LV2': ['kn_basic-safety'],
  'POSITION_LV1': ['kn_position-play'],
  'POSITION_LV2': ['kn_position-play'],
  'POSITION_LV3': ['kn_position-play'],
};
