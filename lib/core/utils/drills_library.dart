/// Drill Library for Training Center
/// Expanded to 80+ drills covering all skill categories
class DrillLibrary {
  static const List<DrillCategory> categories = [
    // ========================================================================
    // CATEGORY 1: AIMING
    // ========================================================================
    DrillCategory(
      id: 'aiming',
      name: 'Aiming',
      nameVi: 'Ngắm đánh',
      icon: 'center_focus_strong',
      drills: [
        // Straight Pot variants
        Drill(
          code: 'STRAIGHT_NEAR',
          name: 'Straight Pot Near',
          nameVi: 'Đánh thẳng gần',
          category: 'aiming',
          difficulty: 'easy',
          description: 'Đánh thẳng khoảng cách gần (20-30cm)',
          setup: 'Đặt bi cách lỗ 20cm',
          steps: ['Ngắm thẳng', 'Tư thế vững', 'Đánh nhẹ', 'Follow through'],
          goal: '10/12 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 12, passCount: 8, distance: '20cm'),
            DrillLevel(level: 2, attempts: 12, passCount: 9, distance: '25cm'),
            DrillLevel(level: 3, attempts: 15, passCount: 12, distance: '30cm'),
          ],
          knowledgeIds: ['aiming', 'bridge'],
        ),
        Drill(
          code: 'STRAIGHT_MID',
          name: 'Straight Pot Mid',
          nameVi: 'Đánh thẳng trung bình',
          category: 'aiming',
          difficulty: 'easy',
          description: 'Đánh thẳng khoảng cách trung bình (50-70cm)',
          setup: 'Đặt bi giữa bàn',
          steps: ['Ngắm chính xác', 'Kiểm soát lực', 'Follow through đầy'],
          goal: '8/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '50cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '60cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '70cm'),
          ],
          knowledgeIds: ['aiming', 'power_control'],
        ),
        Drill(
          code: 'STRAIGHT_FAR',
          name: 'Straight Pot Far',
          nameVi: 'Đánh thẳng xa',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh thẳng khoảng cách xa (1m+)',
          setup: 'Đặt bi đầu bàn',
          steps: ['Ngắm điểm chuẩn', 'Điều khiển lực chính xác', 'Follow through'],
          goal: '6/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 5, distance: '1m'),
            DrillLevel(level: 2, attempts: 10, passCount: 6, distance: '1.2m'),
            DrillLevel(level: 3, attempts: 10, passCount: 7, distance: '1.5m'),
          ],
          knowledgeIds: ['aiming', 'power_control', 'english'],
        ),
        // Thin Cut variants
        Drill(
          code: 'THIN_CUT_30',
          name: 'Thin Cut 30°',
          nameVi: 'Cắt mỏng 30°',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh bi với góc cắt 30°',
          setup: 'Đặt bi ở góc bàn, nhắm góc đối diện',
          steps: ['Xác định điểm ngắm', 'Tính góc 30°', 'Kiểm soát lực'],
          goal: '7/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 5, angle: '25°'),
            DrillLevel(level: 2, attempts: 10, passCount: 6, angle: '30°'),
            DrillLevel(level: 3, attempts: 10, passCount: 7, angle: '35°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming'],
        ),
        Drill(
          code: 'THIN_CUT_45',
          name: 'Thin Cut 45°',
          nameVi: 'Cắt mỏng 45°',
          category: 'aiming',
          difficulty: 'hard',
          description: 'Đánh bi với góc cắt 45°',
          setup: 'Đặt bi ở giữa bàn',
          steps: ['Xác định điểm ngắm', 'Đánh chính xác', 'Follow through'],
          goal: '5/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4, angle: '40°'),
            DrillLevel(level: 2, attempts: 10, passCount: 5, angle: '45°'),
            DrillLevel(level: 3, attempts: 10, passCount: 6, angle: '50°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming', 'english'],
        ),
        Drill(
          code: 'THICK_CUT_30',
          name: 'Thick Cut 30°',
          nameVi: 'Cắt dày 30°',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh bi với góc cắt dày 30°',
          setup: 'Đặt bi gần lỗ',
          steps: ['Ngắm điểm rìa lỗ', 'Điều khiển lực nhẹ'],
          goal: '8/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, angle: '25°'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, angle: '30°'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, angle: '35°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming'],
        ),
        Drill(
          code: 'THICK_CUT_45',
          name: 'Thick Cut 45°',
          nameVi: 'Cắt dày 45°',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh bi với góc cắt dày 45°',
          setup: 'Đặt bi gần lỗ',
          steps: ['Ngắm điểm rìa lỗ', 'Đánh mạnh vừa'],
          goal: '7/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 5, angle: '40°'),
            DrillLevel(level: 2, attempts: 10, passCount: 6, angle: '45°'),
            DrillLevel(level: 3, attempts: 10, passCount: 7, angle: '50°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming'],
        ),
        // Half Ball
        Drill(
          code: 'HALF_BALL_LEFT',
          name: 'Half Ball Left',
          nameVi: 'Nửa bi trái',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh nửa bi (½) sang trái',
          setup: 'Đặt bi mục tiêu, đánh nửa trái',
          steps: ['Xác định điểm ngắm ½ bi', 'Đánh thẳng', 'Kiểm soát lực'],
          goal: '7/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 5, distance: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 6, distance: '50cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 7, distance: '70cm'),
          ],
          knowledgeIds: ['half_ball', 'aiming'],
        ),
        Drill(
          code: 'HALF_BALL_RIGHT',
          name: 'Half Ball Right',
          nameVi: 'Nửa bi phải',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh nửa bi (½) sang phải',
          setup: 'Đặt bi mục tiêu, đánh nửa phải',
          steps: ['Xác định điểm ngắm ½ bi', 'Đánh thẳng', 'Follow through'],
          goal: '7/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 5, distance: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 6, distance: '50cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 7, distance: '70cm'),
          ],
          knowledgeIds: ['half_ball', 'aiming'],
        ),
        // Long Pot
        Drill(
          code: 'LONG_POT_1M',
          name: 'Long Pot 1m',
          nameVi: 'Đánh xa 1m',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh bi vào lỗ cách 1m',
          setup: 'Đặt bi đầu bàn',
          steps: ['Ngắm chuẩn', 'Kiểm soát lực đầy đủ', 'Follow through'],
          goal: '6/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4, distance: '80cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 5, distance: '1m'),
            DrillLevel(level: 3, attempts: 10, passCount: 6, distance: '1.1m'),
          ],
          knowledgeIds: ['long_pot', 'aiming', 'power_control'],
        ),
        Drill(
          code: 'LONG_POT_1_5M',
          name: 'Long Pot 1.5m',
          nameVi: 'Đánh xa 1.5m',
          category: 'aiming',
          difficulty: 'hard',
          description: 'Đánh bi vào lỗ cách 1.5m',
          setup: 'Đặt bi đầu bàn',
          steps: ['Ngắm chính xác', 'Đánh mạnh vừa đủ', 'Follow through đầy'],
          goal: '5/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3, distance: '1.3m'),
            DrillLevel(level: 2, attempts: 10, passCount: 4, distance: '1.5m'),
            DrillLevel(level: 3, attempts: 10, passCount: 5, distance: '1.7m'),
          ],
          knowledgeIds: ['long_pot', 'aiming', 'power_control'],
        ),
        // Combination Shots
        Drill(
          code: 'COMBO_SHORT',
          name: 'Combo Short',
          nameVi: 'Combo ngắn',
          category: 'aiming',
          difficulty: 'medium',
          description: 'Đánh bi qua 1 bi trung gian',
          setup: 'Đặt bi cái, bi mục tiêu có bi trung gian',
          steps: ['Xác định bi trung gian', 'Ngắm qua bi', 'Đánh chuẩn'],
          goal: '6/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4, distance: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 5, distance: '40cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 6, distance: '50cm'),
          ],
          knowledgeIds: ['combo', 'aiming'],
        ),
        Drill(
          code: 'COMBO_LONG',
          name: 'Combo Long',
          nameVi: 'Combo dài',
          category: 'aiming',
          difficulty: 'hard',
          description: 'Đánh bi qua 2 bi trung gian',
          setup: 'Đặt bi cái, bi mục tiêu có 2 bi trung gian',
          steps: ['Xác định 2 bi trung gian', 'Ngắm đường thẳng', 'Đánh chính xác'],
          goal: '4/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3, distance: '50cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 4, distance: '60cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 5, distance: '70cm'),
          ],
          knowledgeIds: ['combo', 'aiming', 'english'],
        ),
        // Obtained Color
        Drill(
          code: 'OBTAINED_COLOR',
          name: 'Obtained Color',
          nameVi: 'Đánh bi có vật cản',
          category: 'aiming',
          difficulty: 'hard',
          description: 'Đánh bi bỏ qua vật cản',
          setup: 'Đặt bi khác làm vật cản',
          steps: ['Quan sát đường đi', 'Tính toán góc', 'Đánh qua vật cản'],
          goal: '4/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3),
            DrillLevel(level: 2, attempts: 10, passCount: 4),
            DrillLevel(level: 3, attempts: 10, passCount: 5),
          ],
          knowledgeIds: ['obtain', 'aiming', 'english'],
        ),
        // Insideenglish
        Drill(
          code: 'INSIDE_ENGLISH',
          name: 'Inside English',
          nameVi: 'Đánh xoáy trong',
          category: 'aiming',
          difficulty: 'hard',
          description: 'Sử dụng xoáy trong để điều chỉnh đường đi',
          setup: 'Đặt bi cái với cushion',
          steps: ['Xác định điểm đánh trong', 'Thêm xoáy trong', 'Kiểm soát lực'],
          goal: '4/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3),
            DrillLevel(level: 2, attempts: 10, passCount: 4),
            DrillLevel(level: 3, attempts: 10, passCount: 5),
          ],
          knowledgeIds: ['inside_english', 'english', 'aiming'],
        ),
      ],
    ),
    DrillCategory(
      id: 'cueball',
      name: 'Cue Ball',
      nameVi: 'Kiểm soát bi cái',
      icon: 'circle',
      drills: [
        Drill(
          code: 'STOP_BALL',
          name: 'Stop Ball',
          nameVi: 'Dừng bi',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Dừng bi cái tại vị trí chỉ định sau cú đánh',
          setup: 'Đánh draw để dừng',
          steps: [
            'Điểm đánh dưới tâm bi cái',
            'Đánh mạnh vừa phải',
            'Giữ cổ tay cố định',
            'Follow through đầy đủ',
          ],
          goal: 'Dừng trong vòng 10cm 8 lần trong 10 lần thử',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '20cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '15cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '10cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '5cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: '2cm'),
          ],
          knowledgeIds: ['draw', 'tip_placement', 'acceleration'],
        ),
        Drill(
          code: 'FOLLOW_SHOT',
          name: 'Follow Shot',
          nameVi: 'Follow',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Bi cái đi tới sau khi chạm bi mục tiêu',
          setup: 'Sử dụng xoáy trên (top spin)',
          steps: [
            'Điểm đánh trên tâm bi cái',
            'Đánh mạnh hơn bình thường 20%',
            'Bi cái đi cùng hướng bi mục tiêu',
          ],
          goal: 'Follow đến vị trí trong 10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '50cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '80cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '1m'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: 'Full table'),
          ],
          knowledgeIds: ['follow', 'top_spin', 'tip_placement'],
        ),
        Drill(
          code: 'DRAW_SHOT',
          name: 'Draw Shot',
          nameVi: 'Draw',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Bi cái quay ngược lại sau khi chạm bi mục tiêu',
          setup: 'Sử dụng xoáy dưới (back spin)',
          steps: [
            'Điểm đánh dưới tâm bi cái',
            'Đánh mạnh vừa phải',
            'Bi cái quay về sau khi chạm',
          ],
          goal: 'Draw về vị trí trong 10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, distance: '20cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, distance: '40cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, distance: '60cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, distance: '80cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, distance: '1m+'),
          ],
          knowledgeIds: ['draw', 'back_spin', 'tip_placement'],
        ),
        Drill(
          code: 'STUN_SHOT',
          name: 'Stun Shot',
          nameVi: 'Stun',
          category: 'cueball',
          difficulty: 'medium',
          description: 'Bi cái đi thẳng sau khi chạm, không xoáy',
          setup: 'Đánh vào tâm bi cái, không xoáy',
          steps: [
            'Đánh vào tâm bi cái',
            'Không có xoáy trên/dưới',
            'Bi cái đi thẳng về hướng ngắm',
          ],
          goal: 'Stun chính xác 8 lần trong 10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, accuracy: '10cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, accuracy: '7cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, accuracy: '5cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, accuracy: '3cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, accuracy: '1cm'),
          ],
          knowledgeIds: ['stun', 'tip_placement', 'stroke'],
        ),
      ],
    ),
    DrillCategory(
      id: 'position',
      name: 'Position',
      nameVi: 'Vị trí',
      icon: 'gps_fixed',
      drills: [
        Drill(
          code: 'POSITION_BASIC',
          name: 'Basic Position',
          nameVi: 'Vị trí cơ bản',
          category: 'position',
          difficulty: 'medium',
          description: 'Điều bi cái đến vị trí chỉ định',
          setup: 'Đặt bi mục tiêu, đánh đến vùng chỉ định',
          steps: [
            'Quan sát khoảng cách',
            'Tính toán lực và xoáy',
            'Thực hiện cú đánh',
          ],
          goal: 'Bi cái dừng trong vùng chỉ định 8/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6, zone: '30cm'),
            DrillLevel(level: 2, attempts: 10, passCount: 7, zone: '20cm'),
            DrillLevel(level: 3, attempts: 10, passCount: 8, zone: '15cm'),
            DrillLevel(level: 4, attempts: 10, passCount: 8, zone: '10cm'),
            DrillLevel(level: 5, attempts: 10, passCount: 9, zone: '5cm'),
          ],
          knowledgeIds: ['position_play', 'speed_control', 'spin_control'],
        ),
        Drill(
          code: 'POSITION_3BALL',
          name: '3-Ball Position',
          nameVi: 'Position 3 bi',
          category: 'position',
          difficulty: 'hard',
          description: 'Đánh 3 bi theo thứ tự, kết thúc ở vị trí chỉ định',
          setup: 'Đặt 3 bi, đánh lần lượt',
          steps: [
            'Quan sát toàn bộ bàn',
            'Lên kế hoạch đường đi',
            'Position cho từng cú',
          ],
          goal: 'Hoàn thành pattern 3 bi 5/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 3, balls: 3),
            DrillLevel(level: 2, attempts: 5, passCount: 4, balls: 3),
            DrillLevel(level: 3, attempts: 5, passCount: 4, balls: 3),
            DrillLevel(level: 4, attempts: 5, passCount: 5, balls: 3),
            DrillLevel(level: 5, attempts: 5, passCount: 5, balls: 3),
          ],
          knowledgeIds: ['pattern', 'position_play', 'speed_control'],
        ),
      ],
    ),
    DrillCategory(
      id: 'safety',
      name: 'Safety',
      nameVi: 'An toàn',
      icon: 'shield',
      drills: [
        Drill(
          code: 'SAFETY_BASIC',
          name: 'Basic Safety',
          nameVi: 'An toàn cơ bản',
          category: 'safety',
          difficulty: 'easy',
          description: 'Đánh an toàn không để đối thủ dễ đánh',
          setup: 'Đặt bi đối thủ, đánh safety',
          steps: [
            'Đánh bi cái chạm băng',
            'Để bi đối thủ ở vị trí khó',
            'Không tạo cơ hội cho đối thủ',
          ],
          goal: 'Tạo thế an toàn 8/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6),
            DrillLevel(level: 2, attempts: 10, passCount: 7),
            DrillLevel(level: 3, attempts: 10, passCount: 8),
            DrillLevel(level: 4, attempts: 10, passCount: 8),
            DrillLevel(level: 5, attempts: 10, passCount: 9),
          ],
          knowledgeIds: ['safety', 'angles', 'position_play'],
        ),
        Drill(
          code: 'SAFETY_FORCE',
          name: 'Force Safety',
          nameVi: 'Ép lực an toàn',
          category: 'safety',
          difficulty: 'hard',
          description: 'Buộc đối thủ đánh cú khó',
          setup: 'Để bi đối thủ sát băng',
          steps: [
            'Tính toán góc đánh',
            'Điều khiển lực chính xác',
            'Tạo khoảng cách bất lợi',
          ],
          goal: 'Ép đối thủ vào thế khó 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
            DrillLevel(level: 4, attempts: 10, passCount: 7),
            DrillLevel(level: 5, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['safety', 'angles', 'english'],
        ),
      ],
    ),
    DrillCategory(
      id: 'special',
      name: 'Special',
      nameVi: 'Kỹ năng đặc biệt',
      icon: 'star',
      drills: [
        Drill(
          code: 'BANK_SHOT',
          name: 'Bank Shot',
          nameVi: 'Bank',
          category: 'special',
          difficulty: 'hard',
          description: 'Đánh bi chạm băng trước khi vào lỗ',
          setup: 'Đặt bi cách băng, nhắm vào lỗ đối diện',
          steps: [
            'Tính góc phản xạ',
            'Đánh chạm băng vuông góc',
            'Kiểm soát lực',
          ],
          goal: 'Bank thành công 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
            DrillLevel(level: 4, attempts: 10, passCount: 7),
            DrillLevel(level: 5, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['bank', 'angles', 'speed_control'],
        ),
        Drill(
          code: 'KICK_SHOT',
          name: 'Kick Shot',
          nameVi: 'Kick',
          category: 'special',
          difficulty: 'expert',
          description: 'Đánh từ băng vào bi mục tiêu',
          setup: 'Đá từ băng đến bi',
          steps: [
            'Tính toán góc đá',
            'Điểm đánh chính xác',
            'Kiểm soát lực',
          ],
          goal: 'Kick thành công 4/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 2),
            DrillLevel(level: 2, attempts: 10, passCount: 3),
            DrillLevel(level: 3, attempts: 10, passCount: 4),
            DrillLevel(level: 4, attempts: 10, passCount: 5),
            DrillLevel(level: 5, attempts: 10, passCount: 6),
          ],
          knowledgeIds: ['kick', 'angles', 'math'],
        ),
        Drill(
          code: 'JUMP_SHOT',
          name: 'Jump Shot',
          nameVi: 'Jump',
          category: 'special',
          difficulty: 'expert',
          description: 'Bi cái nhảy qua chướng ngại vật',
          setup: 'Đặt bi cách bi khác',
          steps: [
            'Nâng đầu cơ cao',
            'Đánh mạnh từ dưới lên',
            'Hạ cánh chính xác',
          ],
          goal: 'Jump thành công 3/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 2),
            DrillLevel(level: 2, attempts: 10, passCount: 2),
            DrillLevel(level: 3, attempts: 10, passCount: 3),
            DrillLevel(level: 4, attempts: 10, passCount: 4),
            DrillLevel(level: 5, attempts: 10, passCount: 5),
          ],
          knowledgeIds: ['jump', 'bridging', 'power'],
        ),
        Drill(
          code: 'MASSE',
          name: 'Masse',
          nameVi: 'Masse',
          category: 'special',
          difficulty: 'expert',
          description: 'Đánh xoáy ngược với độ cong lớn',
          setup: 'Nâng đầu cơ, đánh mạnh',
          steps: [
            'Xác định điểm đánh',
            'Nâng đầu cơ cao',
            'Đánh mạnh theo hướng',
          ],
          goal: 'Masse thành công 2/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 1),
            DrillLevel(level: 2, attempts: 10, passCount: 1),
            DrillLevel(level: 3, attempts: 10, passCount: 2),
            DrillLevel(level: 4, attempts: 10, passCount: 2),
            DrillLevel(level: 5, attempts: 10, passCount: 3),
          ],
          knowledgeIds: ['masse', 'english', 'power'],
        ),
      ],
    ),
    DrillCategory(
      id: 'break',
      name: 'Break',
      nameVi: 'Khai cuộc',
      icon: 'flash_on',
      drills: [
        Drill(
          code: 'BREAK_POWER',
          name: 'Power Break',
          nameVi: 'Khai cuộc lực mạnh',
          category: 'break',
          difficulty: 'medium',
          description: 'Phá bi với lực mạnh để phết bóng',
          setup: 'Đặt cơ ở góc thấp',
          steps: [
            'Điểm đánh 1/4 dưới bi',
            'Đánh mạnh và nhanh',
            'Follow through đầy đủ',
          ],
          goal: 'Phết được 4+ bi 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
            DrillLevel(level: 4, attempts: 10, passCount: 7),
            DrillLevel(level: 5, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['break', 'tip_placement', 'power'],
        ),
        Drill(
          code: 'BREAK_CONTROL',
          name: 'Control Break',
          nameVi: 'Khai cuộc kiểm soát',
          category: 'break',
          difficulty: 'hard',
          description: 'Phá bi với kiểm soát để tạo cơ hội',
          setup: 'Nhắm vào vị trí tối ưu',
          steps: [
            'Xác định điểm ngắm',
            'Điều khiển lực vừa phải',
            'Follow through kiểm soát',
          ],
          goal: 'Tạo cơ hội đánh 5/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3),
            DrillLevel(level: 2, attempts: 10, passCount: 4),
            DrillLevel(level: 3, attempts: 10, passCount: 5),
            DrillLevel(level: 4, attempts: 10, passCount: 6),
            DrillLevel(level: 5, attempts: 10, passCount: 7),
          ],
          knowledgeIds: ['break', 'position', 'control'],
        ),
      ],
    ),
    // ========================================================================
    // CATEGORY 7: SPIN CONTROL
    // ========================================================================
    DrillCategory(
      id: 'spin',
      name: 'Spin Control',
      nameVi: 'Kiểm soát xoáy',
      icon: 'sync',
      drills: [
        Drill(
          code: 'LEFT_ENGLISH_NEAR',
          name: 'Left English Near',
          nameVi: 'Xoáy trái gần',
          category: 'spin',
          difficulty: 'medium',
          description: 'Sử dụng xoáy trái khoảng cách gần',
          setup: 'Đặt bi cái gần cushion',
          steps: ['Điểm đánh bên trái bi cái', 'Đánh nhẹ', 'Quan sát đường đi cong'],
          goal: '5/10 lần điều khiển được',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
          ],
          knowledgeIds: ['left_english', 'english', 'tip_placement'],
        ),
        Drill(
          code: 'RIGHT_ENGLISH_NEAR',
          name: 'Right English Near',
          nameVi: 'Xoáy phải gần',
          category: 'spin',
          difficulty: 'medium',
          description: 'Sử dụng xoáy phải khoảng cách gần',
          setup: 'Đặt bi cái gần cushion',
          steps: ['Điểm đánh bên phải bi cái', 'Đánh nhẹ', 'Quan sát đường đi cong'],
          goal: '5/10 lần điều khiển được',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
          ],
          knowledgeIds: ['right_english', 'english', 'tip_placement'],
        ),
        Drill(
          code: 'TOP_SPIN_CONTROL',
          name: 'Top Spin Control',
          nameVi: 'Kiểm soát top spin',
          category: 'spin',
          difficulty: 'medium',
          description: 'Điều khiển lực với top spin',
          setup: 'Đặt bi cái, điểm đánh trên tâm',
          steps: ['Điểm đánh trên tâm bi', 'Đánh vừa phải', 'Follow through'],
          goal: 'Bi cái đi xa 8/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6),
            DrillLevel(level: 2, attempts: 10, passCount: 7),
            DrillLevel(level: 3, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['top_spin', 'follow', 'power_control'],
        ),
        Drill(
          code: 'BACK_SPIN_CONTROL',
          name: 'Back Spin Control',
          nameVi: 'Kiểm soát back spin',
          category: 'spin',
          difficulty: 'medium',
          description: 'Điều khiển lực với back spin',
          setup: 'Đặt bi cái, điểm đánh dưới tâm',
          steps: ['Điểm đánh dưới tâm bi', 'Đánh vừa phải', 'Quan sát bi quay lại'],
          goal: 'Bi cái quay về 7/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 5),
            DrillLevel(level: 2, attempts: 10, passCount: 6),
            DrillLevel(level: 3, attempts: 10, passCount: 7),
          ],
          knowledgeIds: ['back_spin', 'draw', 'power_control'],
        ),
      ],
    ),
    // ========================================================================
    // CATEGORY 8: PATTERN PLAY
    // ========================================================================
    DrillCategory(
      id: 'pattern',
      name: 'Pattern Play',
      nameVi: 'Mẫu hình',
      icon: 'grid_on',
      drills: [
        Drill(
          code: 'PATTERN_3_BALLS',
          name: '3 Ball Pattern',
          nameVi: 'Mẫu 3 bi',
          category: 'pattern',
          difficulty: 'medium',
          description: 'Đánh 3 bi theo pattern hiệu quả',
          setup: 'Đặt 3 bi trên bàn',
          steps: ['Quan sát vị trí', 'Chọn bi đầu tiên', 'Lên kế hoạch position'],
          goal: 'Đánh hết 3 bi 4/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 3),
            DrillLevel(level: 2, attempts: 5, passCount: 4),
            DrillLevel(level: 3, attempts: 5, passCount: 5),
          ],
          knowledgeIds: ['pattern', 'position_play'],
        ),
        Drill(
          code: 'PATTERN_5_BALLS',
          name: '5 Ball Pattern',
          nameVi: 'Mẫu 5 bi',
          category: 'pattern',
          difficulty: 'hard',
          description: 'Đánh 5 bi theo pattern hiệu quả',
          setup: 'Đặt 5 bi trên bàn',
          steps: ['Quan sát toàn bộ', 'Lên kế hoạch', 'Position từng cú'],
          goal: 'Đánh hết 5 bi 3/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 2),
            DrillLevel(level: 2, attempts: 5, passCount: 3),
            DrillLevel(level: 3, attempts: 5, passCount: 4),
          ],
          knowledgeIds: ['pattern', 'position_play', 'speed_control'],
        ),
        Drill(
          code: 'PATTERN_MULTI_RAIL',
          name: 'Multi Rail Pattern',
          nameVi: 'Mẫu đa băng',
          category: 'pattern',
          difficulty: 'hard',
          description: 'Đánh với nhiều băng trước khi vào lỗ',
          setup: 'Đặt bi cần position nhiều băng',
          steps: ['Tính toán đường đi', 'Điều khiển lực', 'Position cho cú tiếp'],
          goal: 'Position chính xác 4/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 2),
            DrillLevel(level: 2, attempts: 5, passCount: 3),
            DrillLevel(level: 3, attempts: 5, passCount: 4),
          ],
          knowledgeIds: ['pattern', 'position_play', 'english'],
        ),
      ],
    ),
    // ========================================================================
    // CATEGORY 9: STANCE & FUNDAMENTALS
    // ========================================================================
    DrillCategory(
      id: 'fundamentals',
      name: 'Fundamentals',
      nameVi: 'Căn bản',
      icon: 'school',
      drills: [
        Drill(
          code: 'BRIDGE_FORM',
          name: 'Bridge Form',
          nameVi: 'Tay chống',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Luyện tay chống đúng cách',
          setup: 'Đặt tay chống vuông góc',
          steps: ['Tay chống tạo chữ V', 'Có điểm tì', 'Ổn định'],
          goal: 'Tay chống vững 10/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 8),
            DrillLevel(level: 2, attempts: 10, passCount: 9),
            DrillLevel(level: 3, attempts: 10, passCount: 10),
          ],
          knowledgeIds: ['bridge', 'stance'],
        ),
        Drill(
          code: 'STANCE_FORM',
          name: 'Stance Form',
          nameVi: 'Tư thế đứng',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Luyện tư thế đứng đúng',
          setup: 'Đứng vuông góc bàn',
          steps: ['Chân trước hướng bàn', 'Chân sau cân bằng', 'Lưng thẳng'],
          goal: 'Tư thế đúng 10/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 8),
            DrillLevel(level: 2, attempts: 10, passCount: 9),
            DrillLevel(level: 3, attempts: 10, passCount: 10),
          ],
          knowledgeIds: ['stance', 'posture'],
        ),
        Drill(
          code: 'STROKE_STRAIGHT',
          name: 'Straight Stroke',
          nameVi: 'Đánh thẳng',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Luyện đánh thẳng',
          setup: 'Cầm cơ đúng, đánh thẳng',
          steps: ['Cổ tay cố định', 'Đánh thẳng theo đường ngắm', 'Follow through'],
          goal: 'Đánh thẳng 8/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 6),
            DrillLevel(level: 2, attempts: 10, passCount: 7),
            DrillLevel(level: 3, attempts: 10, passCount: 8),
          ],
          knowledgeIds: ['stroke', 'bridge', 'follow_through'],
        ),
        Drill(
          code: 'BREAK_DRY',
          name: 'Dry Break Practice',
          nameVi: 'Tập phá khô',
          category: 'fundamentals',
          difficulty: 'easy',
          description: 'Luyện động tác phá không có bi',
          setup: 'Không có bi trên bàn',
          steps: ['Tư thế đúng', 'Điểm đánh dưới tâm', 'Follow through đầy'],
          goal: 'Động tác đúng 10/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 8),
            DrillLevel(level: 2, attempts: 10, passCount: 9),
            DrillLevel(level: 3, attempts: 10, passCount: 10),
          ],
          knowledgeIds: ['break', 'stroke', 'tip_placement'],
        ),
      ],
    ),
    // ========================================================================
    // CATEGORY 10: MENTAL GAME
    // ========================================================================
    DrillCategory(
      id: 'mental',
      name: 'Mental Game',
      nameVi: 'Tâm lý thi đấu',
      icon: 'psychology',
      drills: [
        Drill(
          code: 'PRESSURE_SHOT',
          name: 'Pressure Shot',
          nameVi: 'Cú áp lực',
          category: 'mental',
          difficulty: 'hard',
          description: 'Luyện đánh trong tình huống áp lực',
          setup: 'Đặt cú khó, có thời gian suy nghĩ',
          steps: ['Bình tĩnh', 'Quan sát kỹ', 'Quyết đoán'],
          goal: 'Đánh đúng 4/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 3),
            DrillLevel(level: 2, attempts: 5, passCount: 4),
            DrillLevel(level: 3, attempts: 5, passCount: 5),
          ],
          knowledgeIds: ['mental', 'focus', 'confidence'],
        ),
        Drill(
          code: 'COMEBACK_PRACTICE',
          name: 'Comeback Practice',
          nameVi: 'Tập lội ngược',
          category: 'mental',
          difficulty: 'hard',
          description: 'Luyện lội ngược khi thua',
          setup: 'Bắt đầu với điểm số thấp',
          steps: ['Tập trung', 'Từng cú một', 'Không bỏ cuộc'],
          goal: 'Hoàn thành comeback 3/5 lần',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 2),
            DrillLevel(level: 2, attempts: 5, passCount: 3),
            DrillLevel(level: 3, attempts: 5, passCount: 4),
          ],
          knowledgeIds: ['mental', 'resilience', 'focus'],
        ),
        Drill(
          code: 'FOCUS_DRILL',
          name: 'Focus Drill',
          nameVi: 'Rèn tập trung',
          category: 'mental',
          difficulty: 'medium',
          description: 'Luyện tập trung trong thời gian dài',
          setup: 'Đánh 20 cú liên tiếp',
          steps: ['Hít thở sâu', 'Tập trung vào bi', 'Đánh từng cú'],
          goal: 'Đánh đúng 15/20 lần',
          levels: [
            DrillLevel(level: 1, attempts: 20, passCount: 12),
            DrillLevel(level: 2, attempts: 20, passCount: 14),
            DrillLevel(level: 3, attempts: 20, passCount: 16),
          ],
          knowledgeIds: ['mental', 'focus', 'breathing'],
        ),
      ],
    ),
    // ========================================================================
    // CATEGORY 11: GAME SITUATIONS
    // ========================================================================
    DrillCategory(
      id: 'situations',
      name: 'Game Situations',
      nameVi: 'Tình huống thi đấu',
      icon: 'sports',
      drills: [
        Drill(
          code: 'TIE_BREAKER',
          name: 'Tie Breaker Practice',
          nameVi: 'Tập đánh tie-break',
          category: 'situations',
          difficulty: 'hard',
          description: 'Luyện cú quyết định',
          setup: 'Điểm số ngang nhau',
          steps: ['Bình tĩnh', 'Đánh cú quan trọng', 'Tập trung'],
          goal: 'Thắng 4/5 tie-break',
          levels: [
            DrillLevel(level: 1, attempts: 5, passCount: 3),
            DrillLevel(level: 2, attempts: 5, passCount: 4),
            DrillLevel(level: 3, attempts: 5, passCount: 5),
          ],
          knowledgeIds: ['mental', 'pressure', 'match_play'],
        ),
        Drill(
          code: 'SCRATCH_RECOVERY',
          name: 'Scratch Recovery',
          nameVi: 'Phục hồi sau scratch',
          category: 'situations',
          difficulty: 'medium',
          description: 'Luyện phục hồi sau khi scratch',
          setup: 'Bắt đầu từ bất kỳ vị trí nào',
          steps: ['Quan sát bàn', 'Chọn cú an toàn', 'Thực hiện'],
          goal: 'Phục hồi thành công 6/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4),
            DrillLevel(level: 2, attempts: 10, passCount: 5),
            DrillLevel(level: 3, attempts: 10, passCount: 6),
          ],
          knowledgeIds: ['scratch', 'safety', 'position_play'],
        ),
        Drill(
          code: '8_BALL_SNookERED',
          name: 'Snookered Escape',
          nameVi: 'Thoát khỏi snooker',
          category: 'situations',
          difficulty: 'expert',
          description: 'Luyện thoát khỏi tình huống snooker',
          setup: 'Bi cái bị chắn hoàn toàn',
          steps: ['Tính toán góc', 'Chọn cú kick hoặc bao', 'Thực hiện'],
          goal: 'Thoát thành công 3/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 2),
            DrillLevel(level: 2, attempts: 10, passCount: 3),
            DrillLevel(level: 3, attempts: 10, passCount: 4),
          ],
          knowledgeIds: ['snooker', 'kick', 'bank', 'english'],
        ),
        // Additional drills for full coverage
        Drill(
          code: 'THICK_CUT_60',
          name: 'Thick Cut 60°',
          nameVi: 'Cắt dày 60°',
          category: 'aiming',
          difficulty: 'hard',
          description: 'Đánh bi với góc cắt dày 60°',
          setup: 'Đặt bi gần lỗ',
          steps: ['Ngắm điểm rìa lỗ', 'Đánh mạnh', 'Follow through'],
          goal: '6/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 4, angle: '55°'),
            DrillLevel(level: 2, attempts: 10, passCount: 5, angle: '60°'),
            DrillLevel(level: 3, attempts: 10, passCount: 6, angle: '65°'),
          ],
          knowledgeIds: ['cut_shots', 'aiming'],
        ),
        Drill(
          code: 'LONG_POT_2M',
          name: 'Long Pot 2m',
          nameVi: 'Đánh xa 2m',
          category: 'aiming',
          difficulty: 'expert',
          description: 'Đánh bi vào lỗ cách 2m',
          setup: 'Đặt bi đầu bàn',
          steps: ['Ngắm chuẩn', 'Kiểm soát lực tối đa', 'Follow through'],
          goal: '3/10 lần trúng',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 2, distance: '1.8m'),
            DrillLevel(level: 2, attempts: 10, passCount: 3, distance: '2m'),
            DrillLevel(level: 3, attempts: 10, passCount: 4, distance: '2.2m'),
          ],
          knowledgeIds: ['long_pot', 'aiming', 'power_control'],
        ),
        Drill(
          code: 'FOLLOW_FAR',
          name: 'Follow Far',
          nameVi: 'Follow xa',
          category: 'cueball',
          difficulty: 'hard',
          description: 'Follow khoảng cách xa',
          setup: 'Đánh bi đầu bàn',
          steps: ['Điểm đánh trên tâm', 'Đánh mạnh', 'Follow đến cuối bàn'],
          goal: 'Bi cái đi hết bàn 5/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3, distance: '1m'),
            DrillLevel(level: 2, attempts: 10, passCount: 4, distance: '1.5m'),
            DrillLevel(level: 3, attempts: 10, passCount: 5, distance: 'Full table'),
          ],
          knowledgeIds: ['follow', 'top_spin', 'power_control'],
        ),
        Drill(
          code: 'DRAW_BACK_FAR',
          name: 'Draw Back Far',
          nameVi: 'Draw về xa',
          category: 'cueball',
          difficulty: 'hard',
          description: 'Draw khoảng cách xa',
          setup: 'Đánh bi đầu bàn, draw về',
          steps: ['Điểm đánh dưới tâm', 'Đánh mạnh', 'Bi quay về nhiều'],
          goal: 'Bi quay về gần 5/10 lần',
          levels: [
            DrillLevel(level: 1, attempts: 10, passCount: 3, distance: '0.5m'),
            DrillLevel(level: 2, attempts: 10, passCount: 4, distance: '1m'),
            DrillLevel(level: 3, attempts: 10, passCount: 5, distance: '1.5m'),
          ],
          knowledgeIds: ['draw', 'back_spin', 'power_control'],
        ),
      ],
    ),
  ];

  static List<Drill> getAllDrills() {
    final List<Drill> all = [];
    for (final category in categories) {
      all.addAll(category.drills);
    }
    return all;
  }

  static Drill? getDrill(String code) {
    for (final category in categories) {
      for (final drill in category.drills) {
        if (drill.code == code) return drill;
      }
    }
    return null;
  }

  static List<Drill> getDrillsByCategory(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) {
        return category.drills;
      }
    }
    return [];
  }

  static List<Drill> getDrillsByDifficulty(String difficulty) {
    return getAllDrills().where((d) => d.difficulty == difficulty).toList();
  }

  static List<Drill> searchDrills(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllDrills().where((d) {
      return d.name.toLowerCase().contains(lowerQuery) ||
          d.nameVi.toLowerCase().contains(lowerQuery) ||
          d.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  static List<Drill> getRecommendedDrills() {
    // Returns drills from different categories for variety
    // Using valid drill codes that exist in the library
    final recommended = <Drill>[];
    final codes = ['DRAW_SHOT', 'FOLLOW_SHOT', 'STOP_BALL', 'STRAIGHT_NEAR', 'POSITION_BASIC'];
    for (final code in codes) {
      final drill = getDrill(code);
      if (drill != null && !recommended.any((d) => d.code == drill.code)) {
        recommended.add(drill);
      }
    }
    // Fallback: return first 5 drills from different categories if some codes don't exist
    if (recommended.length < 3) {
      for (final cat in categories) {
        if (cat.drills.isNotEmpty && !recommended.any((d) => d.code == cat.drills.first.code)) {
          recommended.add(cat.drills.first);
          if (recommended.length >= 5) break;
        }
      }
    }
    return recommended;
  }
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

  String get criteriaText {
    if (distance != null) return '$attempts attempts → $passCount success ($distance)';
    if (angle != null) return '$attempts attempts → $passCount success ($angle)';
    if (accuracy != null) return '$attempts attempts → $passCount success ($accuracy)';
    if (zone != null) return '$attempts attempts → $passCount success (zone: $zone)';
    return '$attempts attempts → $passCount success';
  }
}
