// ============================================================================
// WARMUP MODELS - Dac-Ta-Che-Do-Khoi-Dong.md
// Mục 1 + 2: 3 giai đoạn khởi động 5 phút + WarmupLog
// ============================================================================

/// Một giai đoạn khởi động (không dùng tier/hệ thống điểm)
class WarmupPhase {
  final int phase; // 1, 2, 3
  final String name;
  final String nameVi;
  final String instruction;
  final String instructionVi;
  final int suggestedMinutes; // phút khuyến nghị
  final List<String> relatedKnowledgeSlugs; // tham chiếu từ điển

  const WarmupPhase({
    required this.phase,
    required this.name,
    required this.nameVi,
    required this.instruction,
    required this.instructionVi,
    required this.suggestedMinutes,
    this.relatedKnowledgeSlugs = const [],
  });
}

/// Log ghi nhận một lần warmup — lưu riêng, KHÔNG dùng cho Timeline/Progress
class WarmupLog {
  final DateTime date;
  final bool didWarmup;
  final double durationActualMinutes;
  final String ledTo; // 'buoi_tap' | 'tran_dau' | 'tu_do'
  final List<int> phasesCompleted; // [1, 2] nếu bỏ qua giai đoạn 3

  WarmupLog({
    required this.date,
    required this.didWarmup,
    required this.durationActualMinutes,
    required this.ledTo,
    this.phasesCompleted = const [],
  });

  factory WarmupLog.fromJson(Map<String, dynamic> json) {
    return WarmupLog(
      date: DateTime.parse(json['date'] as String),
      didWarmup: json['didWarmup'] as bool,
      durationActualMinutes:
          (json['durationActualMinutes'] as num).toDouble(),
      ledTo: json['ledTo'] as String,
      phasesCompleted: (json['phasesCompleted'] as List<dynamic>?)
              ?.cast<int>() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'didWarmup': didWarmup,
        'durationActualMinutes': durationActualMinutes,
        'ledTo': ledTo,
        'phasesCompleted': phasesCompleted,
      };

  WarmupLog copyWith({
    DateTime? date,
    bool? didWarmup,
    double? durationActualMinutes,
    String? ledTo,
    List<int>? phasesCompleted,
  }) =>
      WarmupLog(
        date: date ?? this.date,
        didWarmup: didWarmup ?? this.didWarmup,
        durationActualMinutes:
            durationActualMinutes ?? this.durationActualMinutes,
        ledTo: ledTo ?? this.ledTo,
        phasesCompleted: phasesCompleted ?? this.phasesCompleted,
      );
}

/// Định nghĩa 3 giai đoạn warmup
class WarmupPhases {
  WarmupPhases._();

  static const List<WarmupPhase> all = [
    WarmupPhase(
      phase: 1,
      name: 'Awaken the Senses',
      nameVi: 'Đánh thức cảm giác',
      instruction:
          'Place the cue ball and one object ball in a straight line, short distance (~30-40cm). '
          'Hit a few shots with light-to-medium force, slow stroke. '
          "Don't count shots, don't need 100% pot rate — just feel the smooth stroke building up.",
      instructionVi:
          'Đặt bi cái và 1 bi mục tiêu thẳng hàng, cự ly ngắn (~30-40cm). '
          'Đánh vài cú với lực nhẹ-vừa, tốc độ đẩy cơ chậm rãi. '
          'Không đếm cú, không cần vào lỗ 100% — chỉ cần cảm thấy cú đẩy cơ mượt dần lên.',
      suggestedMinutes: 2,
      relatedKnowledgeSlugs: ['stroke', 'stop-shot'],
    ),
    WarmupPhase(
      phase: 2,
      name: 'Adapt to Table Speed',
      nameVi: 'Thích nghi tốc độ bàn',
      instruction:
          'Try a few light stop/follow/draw shots at short-to-medium distance, medium force. '
          "Notice how this table plays — does the ball bounce/roll faster or slower than your practice table?",
      instructionVi:
          'Thử vài cú stop/follow/draw nhẹ ở cự ly ngắn-trung bình, lực trung bình. '
          'Chú ý xem bàn này nảy/lăn nhanh hay chậm hơn bàn bạn quen luyện tập.',
      suggestedMinutes: 2,
      relatedKnowledgeSlugs: ['stop-shot', 'follow-shot', 'draw-shot', 'speed-control'],
    ),
    WarmupPhase(
      phase: 3,
      name: 'Restore Cut Feel',
      nameVi: 'Khôi phục cảm giác góc cắt',
      instruction:
          'Hit a few medium-angle cut shots (30-45°) at various positions on the table. '
          'The goal is to get your eye re-accustomed to angle judgement before the main session.',
      instructionVi:
          'Đánh vài cú cắt góc trung bình (30-45°) ở nhiều vị trí khác nhau trên bàn. '
          'Mục tiêu là để mắt quen lại với việc phán đoán góc trước khi bắt đầu.',
      suggestedMinutes: 2,
      relatedKnowledgeSlugs: ['aiming', 'aiming-fractional'],
    ),
  ];
}
