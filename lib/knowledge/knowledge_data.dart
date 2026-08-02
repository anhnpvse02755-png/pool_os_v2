// ============================================================================
// KNOWLEDGE DATA - Static data for V2
// ============================================================================

import 'knowledge_models.dart';

// ============================================================================
// CATEGORIES
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
// TAGS
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
  KnowledgeTag(id: 'tag_stance', name: 'Stance', nameVi: 'Tư thế', color: '#CDDC39'),
  KnowledgeTag(id: 'tag_technique', name: 'Technique', nameVi: 'Kỹ thuật', color: '#FFC107'),
  KnowledgeTag(id: 'tag_accuracy', name: 'Accuracy', nameVi: 'Độ chính xác', color: '#8BC34A'),
  KnowledgeTag(id: 'tag_defense', name: 'Defense', nameVi: 'Phòng thủ', color: '#FF5722'),
  KnowledgeTag(id: 'tag_rail', name: 'Rail', nameVi: 'Đệm', color: '#9E9E9E'),
  KnowledgeTag(id: 'tag_backspin', name: 'Backspin', nameVi: 'Quay lùi', color: '#00BCD4'),
  KnowledgeTag(id: 'tag_topspin', name: 'Topspin', nameVi: 'Quay tới', color: '#03A9F4'),
];

// ============================================================================
// KNOWLEDGE ITEMS
// ============================================================================

const knowledgeItems = [
  // FUNDAMENTALS
  KnowledgeItem(
    id: 'kn_stance',
    slug: 'stance',
    title: 'Stance',
    titleVi: 'Tư Thế',
    content: '''A proper stance provides balance and stability for a smooth, accurate stroke.

## Basic Stance
1. **Feet Position** - Feet shoulder-width apart
2. **Body Angle** - Leaning slightly over the table
3. **Weight Distribution** - Weight on front foot

## Common Issues
- Standing too upright
- Feet too close together
- Leaning backward

## Practice Tips
- Stand naturally, then adjust
- Your bridge hand should be comfortable
- Keep your head still during the shot''',
    contentVi: '''Tư thế đúng tạo sự cân bằng và ổn định cho nhát đánh mượt mà, chính xác.

## Tư Thế Cơ Bản
1. **Vị trí Chân** - Hai chân rộng bằng vai
2. **Góc Người** - Hơi nghiêng người qua bàn
3. **Phân Bổ Trọng Lượng** - Trọng lượng lên chân trước

## Vấn đề thường gặp
- Đứng quá thẳng
- Hai chân quá sát nhau
- Nghiêng người ra sau

## Mẹo luyện tập
- Đứng tự nhiên, sau đó điều chỉnh
- Tay gác nên thoải mái
- Giữ đầu đứng yên trong cú đánh''',
    categoryId: 'cat_fundamentals',
    tagIds: ['tag_basic', 'tag_stance'],
    aliases: ['stance', 'posture', 'position', 'stand'],
    keywords: ['stance', 'posture', 'balance', 'foot position'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_bridge', 'kn_aiming'],
    relatedDrillCodes: ['STRAIGHT_LV1'],
  ),
  KnowledgeItem(
    id: 'kn_bridge',
    slug: 'bridge',
    title: 'Bridge Hand',
    titleVi: 'Tay Gác',
    content: '''The bridge hand provides stability and guidance for your shot.

## Basic Bridge
1. **Flat Surface** - Keep your hand flat on the table
2. **Firm Grip** - Create a V-shape for the cue
3. **Stable** - Keep your bridge steady throughout the shot

## Variations
- **Rail Bridge** - When balls block normal bridge
- **Elevated Bridge** - For shots over obstacles
- **Spot Shot Bridge** - For elevated shots''',
    contentVi: '''Tay gác tạo sự ổn định và hướng dẫn cho cú đánh.

## Tay Gác Cơ Bản
1. **Bàn Phẳng** - Giữ tay phẳng trên bàn
2. **Nắm Chắc** - Tạo hình V cho cue
3. **Ổn Định** - Giữ tay gác vững trong cú đánh

## Biến thể
- **Gác Đường Ray** - Khi bi cản tay gác thường
- **Gác Nâng** - Cho cú đánh qua vật cản
- **Gác Spot** - Cho cú đánh nâng''',
    categoryId: 'cat_fundamentals',
    tagIds: ['tag_basic', 'tag_bridge'],
    aliases: ['bridge', 'bridge hand', 'grip'],
    keywords: ['bridge', 'grip', 'stability'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stance', 'kn_aiming'],
    relatedDrillCodes: ['STRAIGHT_LV1'],
  ),
  KnowledgeItem(
    id: 'kn_grip',
    slug: 'grip',
    title: 'Cue Grip',
    titleVi: 'Cách Nắm Cue',
    content: '''A proper grip controls cue power and accuracy.

## Grip Principles
1. **Relaxed** - Grip should be firm but relaxed
2. **Wrist Free** - Wrist should be loose for smooth stroke
3. **Base of Fingers** - Grip from the base of your fingers

## Common Mistakes
- Gripping too tight
- Using wrist only
- Inconsistent grip pressure''',
    contentVi: '''Cách nắm đúng kiểm soát lực và độ chính xác của cue.

## Nguyên tắc Nắm
1. **Thư Giãn** - Nắm chắc nhưng thư giãn
2. **Cổ Tay Tự Do** - Cổ tay nên lỏng cho nhát đánh mượt
3. **Gốc Ngón Tay** - Nắm từ gốc ngón tay

## Lỗi thường gặp
- Nắm quá chặt
- Chỉ dùng cổ tay
- Lực nắm không nhất quán''',
    categoryId: 'cat_fundamentals',
    tagIds: ['tag_basic', 'tag_technique'],
    aliases: ['grip', 'cue grip', 'hand'],
    keywords: ['grip', 'hold', 'hand'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stance', 'kn_bridge'],
    relatedDrillCodes: ['STRAIGHT_LV1'],
  ),

  // SHOT MAKING
  KnowledgeItem(
    id: 'kn_stop_shot',
    slug: 'stop-shot',
    title: 'Stop Shot',
    titleVi: 'Cú Dừng Bóng',
    content: '''A stop shot is where the cue ball stops immediately after contact.

## Key Points
1. **Center Ball** - Hit the cue ball at dead center
2. **Straight Follow Through** - Keep your cue level
3. **Controlled Speed** - Use moderate force

## Common Mistakes
- Hitting too hard causes the cue ball to roll forward
- Not following through results in miscues
- Looking up too early breaks concentration

## Practice Tips
- Start close to the object ball
- Focus on smooth, pendulum-like motion
- Gradually increase distance as you improve''',
    contentVi: '''Stop shot là cú đánh mà bi trắng dừng lại ngay tại chỗ sau khi chạm bi đích.

## Điểm quan trọng
1. **Tâm Bi** - Đánh vào tâm bi trắng
2. **Theo Qua Thẳng** - Giữ cue ngang
3. **Lực Vừa** - Dùng lực vừa phải

## Lỗi thường gặp
- Đánh quá mạnh khiến bi trắng lăn tiếp
- Không theo qua dẫn đến đánh trượt
- Nhìn lên quá sớm làm mất tập trung

## Mẹo luyện tập
- Bắt đầu ở khoảng cách gần
- Tập trung động tác như con lắc
- Tăng dần khoảng cách khi cải thiện''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_basic', 'tag_shotmaking', 'tag_cueball'],
    aliases: ['stop', 'stop ball', 'halt'],
    keywords: ['stop shot', 'cue ball control', 'center ball'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_draw_shot', 'kn_follow_shot', 'kn_bridge'],
    relatedDrillCodes: ['STOP_LV1', 'STOP_LV2', 'STOP_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_draw_shot',
    slug: 'draw-shot',
    title: 'Draw Shot',
    titleVi: 'Cú Lùi',
    content: '''A draw shot (backspin) causes the cue ball to reverse direction after contact.

## Key Points
1. **Below Center** - Hit below the center of the cue ball
2. **Bridging** - Extend your bridge for more power
3. **Follow Through** - Follow through in the direction you want

## Tips for Success
- Chalk your tip before every shot
- Keep your cue level to avoid miscues
- Use smooth, accelerating stroke''',
    contentVi: '''Draw shot (backspin) khiến bi trắng quay ngược lại sau khi chạm bi đích.

## Điểm quan trọng
1. **Dưới Tâm** - Đánh vào phía dưới tâm bi trắng
2. **Gác Tay** - Duỗi tay gác để có thêm lực
3. **Theo Qua** - Theo qua theo hướng bạn muốn

## Mẹo thành công
- Tẩy đầu cue trước mỗi cú đánh
- Giữ cue ngang để tránh đánh trượt
- Dùng động tác mượt mà, tăng tốc đều''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_basic', 'tag_shotmaking', 'tag_backspin'],
    aliases: ['draw', 'backspin', 'pull'],
    keywords: ['draw shot', 'backspin', 'pull back'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stop_shot', 'kn_follow_shot', 'kn_speed_control'],
    relatedDrillCodes: ['DRAW_LV1', 'DRAW_LV2', 'DRAW_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_follow_shot',
    slug: 'follow-shot',
    title: 'Follow Shot',
    titleVi: 'Cú Theo',
    content: '''A follow shot (topspin) causes the cue ball to continue rolling forward.

## Key Points
1. **Above Center** - Hit above center of the cue ball
2. **Full Stroke** - Use full, confident stroke
3. **Elevate Slightly** - Slight elevation adds topspin effect

## When to Use
- When you need cue ball to continue to another ball
- For position play after pocketing
- In combination shots''',
    contentVi: '''Follow shot (topspin) khiến bi trắng tiếp tục lăn về phía trước.

## Điểm quan trọng
1. **Trên Tâm** - Đánh vào phía trên tâm bi trắng
2. **Động tác đầy đủ** - Dùng nhát đánh đầy đủ, tự tin
3. **Hơi Nâng** - Nâng nhẹ cue để tăng topspin

## Khi nào sử dụng
- Khi cần bi trắng tiếp tục đến bi khác
- Cho position play sau khi đánh bi vào
- Trong các cú combination''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_basic', 'tag_shotmaking', 'tag_topspin'],
    aliases: ['follow', 'topspin', 'run'],
    keywords: ['follow shot', 'topspin', 'forward roll'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stop_shot', 'kn_draw_shot', 'kn_position_play'],
    relatedDrillCodes: ['FOLLOW_LV1', 'FOLLOW_LV2', 'FOLLOW_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_bank_shot',
    slug: 'bank-shot',
    title: 'Bank Shot',
    titleVi: 'Cú Đánh Băng',
    content: '''A bank shot uses the rail to change direction to reach the target.

## Basic Principles
1. **Angle of Incidence** - Ball bounces at equal angle
2. **Speed** - Speed affects rebound angle slightly
3. **Practice** - Learn natural bank angles on your table

## Tips
- Find the kissing point where balls meet
- Use ghost ball method for aim
- Practice with simple one-rail banks first''',
    contentVi: '''Cú bank shot sử dụng đệm để thay đổi hướng bi trắng đến đích.

## Nguyên tắc cơ bản
1. **Góc Tới** - Bi nảy với góc bằng nhau
2. **Tốc Độ** - Tốc độ ảnh hưởng nhẹ đến góc nảy
3. **Luyện Tập** - Học góc bank tự nhiên trên bàn của bạn

## Mẹo
- Tìm điểm kiss nơi hai bi gặp nhau
- Dùng phương pháp bi ảo để ngắm
- Luyện bank một đệm đơn giản trước''',
    categoryId: 'cat_shotmaking',
    tagIds: ['tag_intermediate', 'tag_bank', 'tag_rail'],
    aliases: ['bank', 'bank shot', 'bounce'],
    keywords: ['bank shot', 'rail', 'bounce'],
    difficulty: DifficultyLevel.intermediate,
    relatedKnowledgeIds: ['kn_aiming', 'kn_speed_control'],
    relatedDrillCodes: ['BANK_LV1', 'BANK_LV2', 'BANK_LV3'],
  ),

  // AIMING
  KnowledgeItem(
    id: 'kn_aiming',
    slug: 'aiming',
    title: 'Aiming',
    titleVi: 'Ngắm Bắn',
    content: '''Aiming is the foundation of every shot.

## Ghost Ball Method
1. **Visualize** - See where cue ball needs to contact object ball
2. **Ghost Ball** - Imagine a ghost ball at contact point
3. **Aim at Ghost** - Align cue to hit the ghost ball

## Tips
- Trust your alignment once you've aimed
- Keep your head still during stroke
- Practice with center ball shots first''',
    contentVi: '''Ngắm bắn là nền tảng của mọi cú đánh.

## Phương pháp Bi Ảo
1. **Hình dung** - Thấy nơi bi trắng cần chạm bi đích
2. **Bi Ảo** - Tưởng tượng bi ảo tại điểm tiếp xúc
3. **Ngắm Bi Ảo** - Căn cue để đánh vào bi ảo

## Mẹo
- Tin tưởng đường ngắm sau khi đã căn
- Giữ đầu đứng yên trong nhát đánh
- Luyện với cú đánh tâm trước''',
    categoryId: 'cat_aiming',
    tagIds: ['tag_basic', 'tag_aiming', 'tag_accuracy'],
    aliases: ['aim', 'aiming', 'alignment'],
    keywords: ['aiming', 'ghost ball', 'contact point'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_stance', 'kn_bridge'],
    relatedDrillCodes: ['STRAIGHT_LV1', 'STRAIGHT_LV2', 'STRAIGHT_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_ghost_ball',
    slug: 'ghost-ball',
    title: 'Ghost Ball Method',
    titleVi: 'Phương Pháp Bi Ảo',
    content: '''The ghost ball method is a systematic aiming technique.

## Steps
1. Identify target pocket
2. Visualize the line from object ball to pocket
3. Place imaginary ghost ball where object ball needs to be
4. Aim cue to contact the ghost ball

## Benefits
- Consistent aiming system
- Works for all shots
- Develops ball awareness''',
    contentVi: '''Phương pháp bi ảo là kỹ thuật ngắm có hệ thống.

## Các bước
1. Xác định lỗ đích
2. Hình dung đường từ bi đích đến lỗ
3. Đặt bi ảo tưởng tượng nơi bi đích cần đến
4. Ngắm cue để chạm bi ảo

## Lợi ích
- Hệ thống ngắm nhất quán
- Áp dụng cho mọi cú đánh
- Phát triển nhận thức về bi''',
    categoryId: 'cat_aiming',
    tagIds: ['tag_basic', 'tag_aiming'],
    aliases: ['ghost ball', 'aiming method'],
    keywords: ['ghost ball', 'aiming', 'technique'],
    difficulty: DifficultyLevel.beginner,
    relatedKnowledgeIds: ['kn_aiming'],
    relatedDrillCodes: ['STRAIGHT_LV1'],
  ),

  // POSITIONING
  KnowledgeItem(
    id: 'kn_position_play',
    slug: 'position-play',
    title: 'Position Play',
    titleVi: 'Kiểm Soát Vị Trí',
    content: '''Position play is the art of controlling where the cue ball ends up.

## Fundamentals
1. **Speed Control** - Most important factor
2. **Natural Angle** - Use natural angles when possible
3. **Plan Ahead** - Think 2-3 shots ahead

## Techniques
- **Natural Position** - Where cue ball naturally goes
- **Cheat the Pocket** - Adjust for difficult positions
- **Safety First** - When impossible, play safe''',
    contentVi: '''Position play là nghệ thuật kiểm soát vị trí bi trắng sau cú đánh.

## Nguyên tắc cơ bản
1. **Kiểm Soát Lực** - Yếu tố quan trọng nhất
2. **Góc Tự Nhiên** - Sử dụng góc tự nhiên khi có thể
3. **Lên Kế Hoạch** - Nghĩ trước 2-3 cú đánh

## Kỹ thuật
- **Vị trí tự nhiên** - Nơi bi trắng đến một cách tự nhiên
- **Cheat Pocket** - Điều chỉnh cho vị trí khó
- **An Toàn Trước** - Khi không thể, chơi an toàn''',
    categoryId: 'cat_positioning',
    tagIds: ['tag_advanced', 'tag_positioning', 'tag_strategy'],
    aliases: ['position', 'positioning', 'control'],
    keywords: ['position play', 'cue ball control', 'speed'],
    difficulty: DifficultyLevel.intermediate,
    relatedKnowledgeIds: ['kn_stop_shot', 'kn_draw_shot', 'kn_follow_shot'],
    relatedDrillCodes: ['POSITION_LV1', 'POSITION_LV2', 'POSITION_LV3'],
  ),
  KnowledgeItem(
    id: 'kn_speed_control',
    slug: 'speed-control',
    title: 'Speed Control',
    titleVi: 'Kiểm Soát Lực',
    content: '''Speed control is the most important skill in billiards.

## Understanding Speed
1. **Soft** - For delicate position work
2. **Medium** - Most common, versatile
3. **Hard** - For power shots and long distances

## Practice Drills
- Stop ball at specific distances
- Position cue ball on specific spots
- Use speed to control rebound''',
    contentVi: '''Kiểm soát lực có lẽ là kỹ năng quan trọng nhất trong billiards.

## Hiểu về Lực
1. **Nhẹ** - Cho position tinh tế
2. **Vừa** - Phổ biến nhất, linh hoạt
3. **Mạnh** - Cho cú mạnh và khoảng cách xa

## Bài tập luyện
- Dừng bi ở khoảng cách cụ thể
- Đặt bi trắng ở vị trí cụ thể
- Dùng lực để kiểm soát nảy''',
    categoryId: 'cat_positioning',
    tagIds: ['tag_intermediate', 'tag_speed', 'tag_cueball'],
    aliases: ['speed', 'power', 'force', 'control'],
    keywords: ['speed', 'control', 'power'],
    difficulty: DifficultyLevel.intermediate,
    relatedKnowledgeIds: ['kn_position_play', 'kn_stop_shot'],
    relatedDrillCodes: ['STOP_LV2', 'POSITION_LV2'],
  ),

  // STRATEGY
  KnowledgeItem(
    id: 'kn_safety_play',
    slug: 'safety-play',
    title: 'Safety Play',
    titleVi: 'Chơi An Toàn',
    content: '''Safety play is defensive strategy when you cannot make a winning shot.

## When to Play Safe
1. No clear shot to pocket
2. Difficult position required
3. Opponent is strong in position play

## Objectives
- Leave opponent with difficult shot
- Create opportunities for yourself
- Avoid giving easy shots to opponent''',
    contentVi: '''Safety play là chiến lược phòng thủ khi không thể đánh thắng.

## Khi nào Chơi An Toàn
1. Không có cú rõ ràng để đánh bi vào
2. Vị trí khó đạt được
3. Đối thủ mạnh về position play

## Mục tiêu
- Để đối thủ ở vị trí khó đánh
- Tạo cơ hội cho bản thân
- Tránh để đối thủ có cú dễ''',
    categoryId: 'cat_strategy',
    tagIds: ['tag_advanced', 'tag_strategy', 'tag_defense'],
    aliases: ['safety', 'safe play', 'defensive'],
    keywords: ['safety', 'defensive', 'strategy'],
    difficulty: DifficultyLevel.advanced,
    relatedKnowledgeIds: ['kn_position_play', 'kn_aiming'],
    relatedDrillCodes: ['SAFETY_LV1', 'SAFETY_LV2', 'SAFETY_LV3'],
  ),

  // PSYCHOLOGY
  KnowledgeItem(
    id: 'kn_mental_game',
    slug: 'mental-game',
    title: 'Mental Game',
    titleVi: 'Tâm Lý Thi Đấu',
    content: '''The mental game is as important as technical skill.

## Key Elements
1. **Focus** - Stay present on current shot
2. **Confidence** - Trust your practice
3. **Patience** - Wait for the right opportunity

## Managing Tilt
- Take a deep breath
- Walk around the table
- Reset your routine''',
    contentVi: '''Tâm lý thi đấu quan trọng ngang với kỹ năng kỹ thuật.

## Yếu tố quan trọng
1. **Tập trung** - Ở hiện tại với cú đánh hiện tại
2. **Tự tin** - Tin tưởng vào quá trình luyện tập
3. **Kiên nhẫn** - Chờ cơ hội đúng

## Quản lý Tilt
- Hít thở sâu
- Đi quanh bàn
- Reset thói quen của bạn''',
    categoryId: 'cat_psychology',
    tagIds: ['tag_advanced', 'tag_strategy'],
    aliases: ['mental', 'psychology', 'focus', 'tilt'],
    keywords: ['mental', 'psychology', 'focus', 'confidence'],
    difficulty: DifficultyLevel.advanced,
    relatedKnowledgeIds: ['kn_safety_play'],
    relatedDrillCodes: [],
  ),
];

// ============================================================================
// DRILL - KNOWLEDGE MAPPING
// ============================================================================

const drillKnowledgeMapping = {
  // Stop Shot Drills
  'STOP_LV1': ['kn_stop_shot', 'kn_bridge', 'kn_aiming'],
  'STOP_LV2': ['kn_stop_shot', 'kn_speed_control', 'kn_aiming'],
  'STOP_LV3': ['kn_stop_shot', 'kn_position_play', 'kn_speed_control'],

  // Draw Shot Drills
  'DRAW_LV1': ['kn_draw_shot', 'kn_bridge', 'kn_aiming'],
  'DRAW_LV2': ['kn_draw_shot', 'kn_speed_control', 'kn_position_play'],
  'DRAW_LV3': ['kn_draw_shot', 'kn_position_play', 'kn_speed_control'],

  // Follow Shot Drills
  'FOLLOW_LV1': ['kn_follow_shot', 'kn_bridge', 'kn_aiming'],
  'FOLLOW_LV2': ['kn_follow_shot', 'kn_speed_control', 'kn_position_play'],
  'FOLLOW_LV3': ['kn_follow_shot', 'kn_position_play', 'kn_speed_control'],

  // Position Drills
  'POSITION_LV1': ['kn_position_play', 'kn_speed_control', 'kn_stop_shot'],
  'POSITION_LV2': ['kn_position_play', 'kn_speed_control', 'kn_draw_shot'],
  'POSITION_LV3': ['kn_position_play', 'kn_speed_control', 'kn_follow_shot'],

  // Straight Drills
  'STRAIGHT_LV1': ['kn_aiming', 'kn_stance', 'kn_bridge'],
  'STRAIGHT_LV2': ['kn_aiming', 'kn_ghost_ball', 'kn_stance'],
  'STRAIGHT_LV3': ['kn_aiming', 'kn_position_play', 'kn_speed_control'],

  // Bank Drills
  'BANK_LV1': ['kn_bank_shot', 'kn_aiming', 'kn_speed_control'],
  'BANK_LV2': ['kn_bank_shot', 'kn_position_play', 'kn_speed_control'],
  'BANK_LV3': ['kn_bank_shot', 'kn_position_play', 'kn_aiming'],

  // Safety Drills
  'SAFETY_LV1': ['kn_safety_play', 'kn_aiming', 'kn_position_play'],
  'SAFETY_LV2': ['kn_safety_play', 'kn_position_play', 'kn_speed_control'],
  'SAFETY_LV3': ['kn_safety_play', 'kn_mental_game', 'kn_position_play'],
};
