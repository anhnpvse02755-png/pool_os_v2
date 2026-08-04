// ============================================================================
// v1_seed_data.dart — V1 verified article metadata
// ============================================================================
//
// Sprint 1, Commit 4 — DEV tool only.
//
// 92 verified articles from V1 domain validation reports:
//   - bridge/.      (30 articles)
//   - pattern/      (28 articles)
//   - safety/       (23 articles)
//   - mental/       (21 articles)
//
// Each article has metadata-level content (no body prose). Body
// follows V1 schema template. The mapper synthesizes V2 markdown.
//
// This file is INTERNAL to Commit 4. It generates the input for the
// migration tool. It will be removed at end of Sprint 1.
// ============================================================================

final Map<String, List<Map<String, dynamic>>> v1Domains = {
  'bridge': [
    _a('bridge.fundamentals', 'Bridge Fundamentals', 'Nền Tảng Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.open_bridge', 'Open Bridge', 'Tay Chống Mở', 'fundamentals', 'beginner'),
    _a('bridge.closed_bridge', 'Closed Bridge', 'Tay Chống Kín', 'fundamentals', 'beginner'),
    _a('bridge.rail_bridge', 'Rail Bridge', 'Tay Chống Băng', 'fundamentals', 'intermediate'),
    _a('bridge.mechanical_bridge', 'Mechanical Bridge', 'Gậy Chống Cơ Học', 'fundamentals', 'intermediate'),
    _a('bridge.spider_bridge', 'Spider Bridge', 'Đầu Nhện', 'fundamentals', 'intermediate'),
    _a('bridge.stability', 'Bridge Stability', 'Độ Ổn Định Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.length', 'Bridge Length', 'Chiều Dài Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.distance', 'Bridge Distance', 'Khoảng Cách Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.pressure', 'Bridge Pressure', 'Áp Lực Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.hand_position', 'Hand Position', 'Vị Trí Tay', 'fundamentals', 'beginner'),
    _a('bridge.thumb_channel', 'Thumb Channel', 'Rãnh Ngón Cái', 'fundamentals', 'intermediate'),
    _a('bridge.finger_placement', 'Finger Placement', 'Vị Trí Ngón Tay', 'fundamentals', 'beginner'),
    _a('bridge.high', 'High Bridge', 'Tay Chống Cao', 'fundamentals', 'intermediate'),
    _a('bridge.low', 'Low Bridge', 'Tay Chống Thấp', 'fundamentals', 'intermediate'),
    _a('bridge.elevated', 'Elevated Bridge', 'Tay Chống Nâng Cao', 'fundamentals', 'advanced'),
    _a('bridge.jump_bridge', 'Jump Bridge', 'Kỹ Thuật Tay Chống Nhảy', 'fundamentals', 'advanced'),
    _a('bridge.index_finger_hook', 'Index Finger Hook', 'Móc Ngón Trỏ', 'fundamentals', 'advanced'),
    _a('bridge.finger_spread', 'Finger Spread', 'Kỹ Thuật Xòe Ngón', 'fundamentals', 'intermediate'),
    _a('bridge.wrist_position', 'Wrist Position', 'Vị Trí Cổ Tay', 'fundamentals', 'beginner'),
    _a('bridge.level_check', 'Level Check', 'Kiểm Tra Độ Ngang Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.adjustment', 'Bridge Adjustment', 'Điều Chỉnh Tay Chống', 'fundamentals', 'intermediate'),
    _a('bridge.transition', 'Bridge Transition', 'Chuyển Đổi Tay Chống', 'fundamentals', 'intermediate'),
    _a('bridge.comfort_check', 'Comfort Check', 'Kiểm Tra Thoải Mái Tay Chống', 'fundamentals', 'beginner'),
    _a('bridge.dominant_eye', 'Dominant Eye Alignment', 'Căn Chỉnh Mắt Thuận', 'fundamentals', 'intermediate'),
    _a('bridge.tension_release', 'Tension Release', 'Giải Phóng Căng Thẳng Tay Chống', 'fundamentals', 'intermediate'),
    _a('bridge.consistency', 'Bridge Consistency', 'Tính Nhất Quán Tay Chống', 'fundamentals', 'intermediate'),
    _a('bridge.fatigue_management', 'Fatigue Management', 'Quản Lý Mỏi Tay Chống', 'fundamentals', 'advanced'),
    _a('bridge.mastery_checklist', 'Mastery Checklist', 'Danh Sách Kiểm Tra Thành Thạo', 'fundamentals', 'expert'),
    _a('bridge.adaptive_bridge', 'Adaptive Bridge', 'Kỹ Thuật Tay Chống Thích Ứng', 'fundamentals', 'advanced'),
  ],
  'pattern': [
    _a('pattern.fundamentals', 'Pattern Fundamentals', 'Nền Tảng Mẫu Đánh', 'strategy', 'beginner'),
    _a('pattern.table_reading', 'Table Reading', 'Đọc Bàn', 'strategy', 'beginner'),
    _a('pattern.cluster_identification', 'Cluster Identification', 'Nhận Biết Cụm Bóng', 'strategy', 'intermediate'),
    _a('pattern.ball_distribution', 'Ball Distribution', 'Phân Bố Bóng', 'strategy', 'intermediate'),
    _a('pattern.pocket_assignment', 'Pocket Assignment', 'Phân Bổ Túi', 'strategy', 'intermediate'),
    _a('pattern.position_planning', 'Position Planning', 'Kế Hoạch Vị Trí', 'strategy', 'intermediate'),
    _a('pattern.speed_control', 'Speed Control', 'Kiểm Soát Lực', 'strategy', 'intermediate'),
    _a('pattern.spin_application', 'Spin Application', 'Áp Dụng Xoáy', 'strategy', 'advanced'),
    _a('pattern.run_out', 'Run Out', 'Chạy Bàn', 'strategy', 'advanced'),
    _a('pattern.safety_alternatives', 'Safety Alternatives', 'Phương Án An Toàn', 'strategy', 'advanced'),
    _a('pattern.multiple_position', 'Multiple Position', 'Đa Vị Trí', 'strategy', 'advanced'),
    _a('pattern.adaptive_planning', 'Adaptive Planning', 'Kế Hoạch Thích Ứng', 'strategy', 'advanced'),
    _a('pattern.decision_making', 'Decision Making', 'Ra Quyết Định', 'strategy', 'intermediate'),
    _a('pattern.risk_assessment', 'Risk Assessment', 'Đánh Giá Rủi Ro', 'strategy', 'advanced'),
    _a('pattern.percentage_play', 'Percentage Play', 'Đánh Tỷ Lệ', 'strategy', 'advanced'),
    _a('pattern.long_term_planning', 'Long Term Planning', 'Kế Hoạch Dài Hạn', 'strategy', 'expert'),
    _a('pattern.game_sense', 'Game Sense', 'Cảm Nhận Trận Đấu', 'strategy', 'expert'),
    _a('pattern.visualization', 'Visualization', 'Hình Dung', 'strategy', 'intermediate'),
    _a('pattern.plan_execution', 'Plan Execution', 'Thực Thi Kế Hoạch', 'strategy', 'intermediate'),
    _a('pattern.focus', 'Pattern Focus', 'Tập Trung Mẫu', 'strategy', 'beginner'),
    _a('pattern.consistency', 'Pattern Consistency', 'Tính Nhất Quán Mẫu', 'strategy', 'intermediate'),
    _a('pattern.improvement', 'Pattern Improvement', 'Cải Thiện Mẫu', 'strategy', 'advanced'),
    _a('pattern.shape_recognition', 'Shape Recognition', 'Nhận Biết Hình Dạng', 'strategy', 'intermediate'),
    _a('pattern.key_ball', 'Key Ball', 'Bóng Chìa Khoá', 'strategy', 'advanced'),
    _a('pattern.break_layout', 'Break Layout', 'Bố Cục Sau Phá', 'strategy', 'expert'),
    _a('pattern.transition_zones', 'Transition Zones', 'Vùng Chuyển Tiếp', 'strategy', 'advanced'),
    _a('pattern.pattern_repeat', 'Pattern Repeat', 'Lặp Lại Mẫu', 'strategy', 'expert'),
    _a('pattern.pattern_transfer', 'Pattern Transfer', 'Chuyển Giao Mẫu', 'strategy', 'expert'),
  ],
  'safety': [
    _a('safety.fundamentals', 'Safety Fundamentals', 'Nền Tảng An Toàn', 'safety', 'beginner'),
    _a('safety.snooker', 'Snooker Safety', 'An Toàn Cản Trở', 'safety', 'intermediate'),
    _a('safety.hide', 'Hide the Cue Ball', 'Giấu Bi Cái', 'safety', 'intermediate'),
    _a('safety.hook', 'Hook the Cue Ball', 'Móc Bi Cái', 'safety', 'intermediate'),
    _a('safety.jail', 'Jail Escape', 'Thoát Khỏi Tù', 'safety', 'advanced'),
    _a('safety.leave_options', 'Leave Options', 'Để Lại Lựa Chọn', 'safety', 'intermediate'),
    _a('safety.defense_basics', 'Defensive Basics', 'Cơ Bản Phòng Thủ', 'safety', 'beginner'),
    _a('safety.long_safety', 'Long Safety', 'An Toàn Xa', 'safety', 'intermediate'),
    _a('safety.short_safety', 'Short Safety', 'An Toàn Gần', 'safety', 'beginner'),
    _a('safety.rail_safety', 'Rail Safety', 'An Toàn Băng', 'safety', 'advanced'),
    _a('safety.bank_safety', 'Bank Safety', 'An Toàn Băng Tường', 'safety', 'advanced'),
    _a('safety.kick_safety', 'Kick Safety', 'An Toàn Đá', 'safety', 'advanced'),
    _a('safety.ball_in_hand', 'Ball in Hand', 'Bóng Trên Tay', 'safety', 'intermediate'),
    _a('safety.cue_ball_position', 'Cue Ball Position', 'Vị Trí Bi Cái', 'safety', 'intermediate'),
    _a('safety.object_ball_distance', 'Object Ball Distance', 'Khoảng Cách Bi Đích', 'safety', 'beginner'),
    _a('safety.contact_point', 'Contact Point', 'Điểm Tiếp Xúc', 'safety', 'beginner'),
    _a('safety.three_rail', 'Three Rail Safety', 'An Toàn Ba Băng', 'safety', 'expert'),
    _a('safety.break_safe', 'Break Safe', 'Phá An Toàn', 'safety', 'advanced'),
    _a('safety.return_safe', 'Return Safe', 'Trả An Toàn', 'safety', 'intermediate'),
    _a('safety.tactical_safe', 'Tactical Safety', 'An Toàn Chiến Thuật', 'safety', 'advanced'),
    _a('safety.safety_response', 'Safety Response', 'Phản Ứng An Toàn', 'safety', 'intermediate'),
    _a('safety.defensive_roll', 'Defensive Roll', 'Lăn Phòng Thủ', 'safety', 'advanced'),
    _a('safety.escape_sequence', 'Escape Sequence', 'Trình Tự Thoát', 'safety', 'expert'),
  ],
  'mental': [
    _a('mental.fundamentals', 'Mental Fundamentals', 'Nền Tảng Tâm Lý', 'mental', 'beginner'),
    _a('mental.concentration', 'Concentration', 'Tập Trung', 'mental', 'beginner'),
    _a('mental.routine', 'Pre-shot Routine', 'Thói Quen Trước Cú', 'mental', 'beginner'),
    _a('mental.breathing', 'Breathing', 'Hô Hấp', 'mental', 'beginner'),
    _a('mental.composure', 'Composure', 'Bình Tĩnh', 'mental', 'intermediate'),
    _a('mental.confidence', 'Confidence', 'Tự Tin', 'mental', 'intermediate'),
    _a('mental.pressure', 'Playing Under Pressure', 'Thi Đấu Dưới Áp Lực', 'mental', 'advanced'),
    _a('mental.focus_recovery', 'Focus Recovery', 'Phục Hồi Tập Trung', 'mental', 'intermediate'),
    _a('mental.frustration', 'Frustration Management', 'Quản Lý Bực Bội', 'mental', 'intermediate'),
    _a('mental.visualization', 'Mental Visualization', 'Hình Dung Tâm Lý', 'mental', 'intermediate'),
    _a('mental.positive_self_talk', 'Positive Self-Talk', 'Tự Nói Chuyện Tích Cực', 'mental', 'beginner'),
    _a('mental.goal_setting', 'Goal Setting', 'Đặt Mục Tiêu', 'mental', 'beginner'),
    _a('mental.pre_match_routine', 'Pre-Match Routine', 'Thói Quen Trước Trận', 'mental', 'intermediate'),
    _a('mental.match_rhythm', 'Match Rhythm', 'Nhịp Trận Đấu', 'mental', 'intermediate'),
    _a('mental.errors_recovery', 'Error Recovery', 'Phục Hồi Sau Lỗi', 'mental', 'intermediate'),
    _a('mental.arousal_control', 'Arousal Control', 'Kiểm Soát Hưng Phấn', 'mental', 'advanced'),
    _a('mental.attention_control', 'Attention Control', 'Kiểm Soát Chú Ý', 'mental', 'advanced'),
    _a('mental.competitive_mental', 'Competitive Mental', 'Tâm Lý Thi Đấu', 'mental', 'advanced'),
    _a('mental.bounce_back', 'Bounce Back', 'Phục Hồi Sau Thất Bại', 'mental', 'expert'),
    _a('mental.sport_psychology', 'Sport Psychology', 'Tâm Lý Thể Thao', 'mental', 'expert'),
    _a('mental.mental_assets', 'Mental Assets', 'Tài Sản Tâm Lý', 'mental', 'expert'),
  ],
};

Map<String, dynamic> _a(
  String id,
  String titleEn,
  String titleVi,
  String category,
  String difficulty,
) {
  return {
    'id': id,
    'title': titleEn,
    'titleVi': titleVi,
    'category': category,
    'difficulty': difficulty,
    'summary': '${titleEn} explained.',
    'summaryVi': 'Giải thích về ${titleVi}.',
    'purpose': 'A core ${category} concept for billiards players.',
    'purposeVi': 'Khái niệm ${category} cốt lõi cho người chơi billiards.',
    'setup': <String>[
      'Establish a stable baseline.',
      'Position cue and body for the technique.',
    ],
    'execution': <String>[
      'Apply the technique step by step.',
      'Verify alignment before contact.',
    ],
    'successCriteria': <String>[
      'Smooth execution.',
      'Predictable result.',
    ],
    'failureCriteria': <String>[
      'Jerky motion.',
      'Inconsistent result.',
    ],
    'commonMistakes': <Map<String, dynamic>>[
      {
        'mistake': 'Rushing the technique.',
        'mistakeVi': 'Vội vàng khi thực hiện.',
        'correction': 'Slow down and focus on form.',
        'correctionVi': 'Chậm lại và tập trung vào tư thế.',
      },
    ],
    'tags': <String>[category, difficulty],
    'keywords': <String>[id, titleEn.toLowerCase()],
    'sources': <String>['Pool OS V1 Verified'],
    'estLearningMinutes': 10,
    'relatedKnowledge': <Map<String, dynamic>>[],
  };
}