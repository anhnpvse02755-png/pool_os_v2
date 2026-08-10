// ============================================================================
// KNOWLEDGE GRAPH SERVICE - Phase 5B
// Coach AI Brain Foundation - Reasoning Chain
//
// Provides structured knowledge queries for Coach AI.
// Graph-based, not document-based.
// ============================================================================

import 'knowledge_graph.dart';
import 'drill_node.dart';
import 'skill_node.dart';
import 'observation_node.dart';
import 'cause_node.dart';
import 'mistake_node.dart';
import 'situation_node.dart';
import 'tactic_node.dart';
import 'decision_node.dart';

/// Service for querying the knowledge graph
class KnowledgeGraphService {
  KnowledgeGraphService._(this._graph);
  static KnowledgeGraphService? _instance;
  static KnowledgeGraphService get instance => _instance ??= _create();

  final KnowledgeGraph _graph;

  static KnowledgeGraphService _create() {
    final graph = KnowledgeGraph(
      drillNodes: _seedDrillNodes(),
      skillNodes: _seedSkillNodes(),
      mistakeNodes: _seedMistakeNodes(),
      observationNodes: _seedObservationNodes(),
      causeNodes: _seedCauseNodes(),
      situationNodes: _seedSituationNodes(),
      tacticNodes: _seedTacticNodes(),
      decisionRules: _seedDecisionRules(),
    );
    return KnowledgeGraphService._(graph);
  }

  // ========================================================================
  // QUERY INTERFACE
  // ========================================================================

  /// Query: Get drill knowledge by code
  DrillNode? getDrill(String code) => _graph.getDrill(code);

  /// Query: Get drills that train a specific skill
  List<DrillNode> getDrillsBySkill(String skillId) => _graph.getDrillsBySkill(skillId);

  /// Query: Get drills that fix a specific mistake
  List<DrillNode> getDrillsForMistake(String mistakeId) => _graph.getDrillsForMistake(mistakeId);

  /// Query: Get prerequisites for a drill
  List<DrillNode> getPrerequisites(String drillCode) => _graph.getPrerequisites(drillCode);

  /// Query: Get progression drills
  List<DrillNode> getProgressionDrills(String drillCode) => _graph.getProgressionDrills(drillCode);

  /// Query: Get all drills
  List<DrillNode> getAllDrills() => _graph.drillNodes.values.toList();

  /// Query: Get all skills
  List<SkillNode> getAllSkills() => _graph.skillNodes.values.toList();

  /// Query: Get all mistakes
  List<MistakeNode> getAllMistakes() => _graph.mistakeNodes.values.toList();

  /// Query: Get skill by ID
  SkillNode? getSkill(String skillId) => _graph.getSkill(skillId);

  /// Query: Get mistake by ID
  MistakeNode? getMistake(String mistakeId) => _graph.getMistake(mistakeId);

  /// Query: Get drill by difficulty
  List<DrillNode> getDrillsByLevel(DrillDifficulty level) =>
      _graph.drillNodes.values.where((d) => d.difficulty == level).toList();

  /// Query: Get recommended drills for a skill (sorted by difficulty)
  List<DrillNode> getRecommendedDrillsForSkill(String skillId) {
    final drills = getDrillsBySkill(skillId);
    drills.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
    return drills;
  }

  /// Query: Coach AI reasoning - Why should I practice this drill?
  String explainDrillPurpose(String drillCode) {
    final drill = getDrill(drillCode);
    if (drill == null) return 'Unknown drill';

    final skills = drill.skillsTrained
        .map((s) => _graph.getSkill(s)?.nameVi ?? s)
        .join(', ');

    return 'Drill này giúp cải thiện: $skills.';
  }

  /// Query: Coach AI reasoning - What drills should fix this mistake?
  List<DrillNode> getDrillFixFor(String mistakeId) => getDrillsForMistake(mistakeId);

  /// Query: Coach AI reasoning - What drills fix a cause?
  List<DrillNode> getDrillsForCause(String causeId) => _graph.getDrillsForCause(causeId);

  /// Query: Coach AI reasoning - Get causes for a mistake
  List<CauseNode> getCausesForMistake(String mistakeId) => _graph.getCausesForMistake(mistakeId);

  /// Query: Coach AI reasoning - Get observations that suggest a mistake
  List<ObservationNode> getObservationsForMistake(String mistakeId) =>
      _graph.getObservationsForMistake(mistakeId);

  /// Query: Coach AI reasoning - Build full reasoning chain
  ReasoningChain buildReasoningChain({
    required List<String> observations,
    required String targetSkill,
  }) {
    return _graph.buildReasoningChain(
      observations: observations,
      targetSkill: targetSkill,
    );
  }

  /// Get the underlying graph for advanced queries
  KnowledgeGraph get graph => _graph;
}

// ========================================================================
// SEED DATA - Drill Nodes
// ========================================================================

Map<String, DrillNode> _seedDrillNodes() {
  return {
    // POTting drills
    'STRAIGHT_POT': const DrillNode(
      code: 'STRAIGHT_POT',
      name: 'Straight Shot',
      nameVi: 'Đánh thẳng',
      description: 'Nền tảng của mọi cú đánh. Đánh bi vào lỗ theo đường thẳng.',
      skillsTrained: [PoolSkills.aiming, PoolSkills.stroke],
      fixesMistakes: [CommonMistakes.misalign],
      prerequisites: [],
      nextDrills: ['STOP_BALL', 'FOLLOW_SHOT', 'DRAW_SHOT'],
      relatedDrills: ['STOP_BALL'],
      tips: [
        'Ngắm từ bi đến lỗ, chọn điểm ngắm',
        'Tư thế vững vàng, vai vuông góc với bàn',
        'Đánh thẳng, follow through đầy đủ',
      ],
      commonMistakes: [
        'Ngắm lệch',
        'Đánh không thẳng',
        'Ngắng bàn khi follow through',
      ],
      metrics: ['accuracy', 'success_rate'],
      difficulty: DrillDifficulty.beginner,
      estimatedMinutes: 15,
    ),

    'STOP_BALL': const DrillNode(
      code: 'STOP_BALL',
      name: 'Stop Ball',
      nameVi: 'Dừng bi',
      description: 'Kiểm soát bi cái dừng lại tại vị trí mong muốn sau cú đánh.',
      skillsTrained: [PoolSkills.cueBallControl, PoolSkills.stroke, PoolSkills.speedControl],
      fixesMistakes: [CommonMistakes.cueBallOverrun, CommonMistakes.overRun],
      prerequisites: ['STRAIGHT_POT'],
      nextDrills: ['FOLLOW_SHOT', 'DRAW_SHOT'],
      relatedDrills: ['STRAIGHT_POT', 'STUN_SHOT'],
      tips: [
        'Đánh vào tâm bi (center ball hit)',
        'Tốc độ vừa phải, không quá nhanh',
        'Follow through đầy đủ nhưng dừng tự nhiên',
      ],
      commonMistakes: [
        'Đánh quá nhanh',
        'Dùng quá nhiều english',
        'Dừng tay sớm',
      ],
      metrics: ['accuracy', 'position_accuracy'],
      difficulty: DrillDifficulty.beginner,
      estimatedMinutes: 15,
    ),

    'FOLLOW_SHOT': const DrillNode(
      code: 'FOLLOW_SHOT',
      name: 'Follow Shot',
      nameVi: 'Bi lăn theo',
      description: 'Bi cái lăn theo hướng bi đánh sau cú đánh.',
      skillsTrained: [PoolSkills.cueBallControl, PoolSkills.speedControl],
      fixesMistakes: [CommonMistakes.cueBallStop],
      prerequisites: ['STOP_BALL'],
      nextDrills: ['POSITION_CONTROL'],
      relatedDrills: ['STOP_BALL', 'DRAW_SHOT'],
      tips: [
        'Đánh trên tâm bi (top spin)',
        'Tốc độ mạnh, follow through dài',
      ],
      commonMistakes: [
        'Đánh không đủ mạnh',
        'Dùng english sai hướng',
      ],
      metrics: ['position_accuracy', 'distance_control'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 20,
    ),

    'DRAW_SHOT': const DrillNode(
      code: 'DRAW_SHOT',
      name: 'Draw Shot',
      nameVi: 'Bi quay lại',
      description: 'Bi cái quay ngược lại sau khi chạm bi mục tiêu.',
      skillsTrained: [PoolSkills.cueBallControl, PoolSkills.stroke],
      fixesMistakes: [CommonMistakes.underRun],
      prerequisites: ['STOP_BALL'],
      nextDrills: ['POSITION_CONTROL'],
      relatedDrills: ['STOP_BALL', 'FOLLOW_SHOT'],
      tips: [
        'Đánh dưới tâm bi (draw)',
        'Rút cue nhanh và mạnh',
        'Follow through dài về phía bi',
      ],
      commonMistakes: [
        'Đánh không đủ nhanh',
        'Chạm bi không đúng điểm',
        'Tư thế không ổn định',
      ],
      metrics: ['accuracy', 'backspin_control'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 20,
    ),

    'STUN_SHOT': const DrillNode(
      code: 'STUN_SHOT',
      name: 'Stun Shot',
      nameVi: 'Bi dừng tức',
      description: 'Bi cái dừng ngay sau khi chạm bi mục tiêu (không lăn thêm).',
      skillsTrained: [PoolSkills.cueBallControl, PoolSkills.speedControl],
      fixesMistakes: [CommonMistakes.overRun, CommonMistakes.underRun],
      prerequisites: ['STOP_BALL'],
      nextDrills: ['POSITION_CONTROL'],
      relatedDrills: ['STOP_BALL'],
      tips: [
        'Đánh center ball với lực vừa phải',
        'Kiểm soát tốc độ chính xác',
      ],
      commonMistakes: [
        'Tốc độ không đều',
        'Đánh hơi lệch tâm',
      ],
      metrics: ['accuracy', 'position_accuracy'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 15,
    ),

    'THIN_CUT': const DrillNode(
      code: 'THIN_CUT',
      name: 'Thin Cut',
      nameVi: 'Cắt mỏng',
      description: 'Cú đánh với góc cắt mỏng (< 30°).',
      skillsTrained: [PoolSkills.aiming, PoolSkills.cueBallControl],
      fixesMistakes: [CommonMistakes.thinHit],
      prerequisites: ['STRAIGHT_POT'],
      nextDrills: ['THICK_CUT', 'BANK_SHOT'],
      relatedDrills: ['THICK_CUT'],
      tips: [
        'Xác định điểm ngắm chính xác',
        'Tốc độ vừa phải',
        'Follow through thẳng',
      ],
      commonMistakes: [
        'Ngắm sai điểm',
        'Đánh quá nhanh',
      ],
      metrics: ['accuracy', 'cut_angle'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 20,
    ),

    'THICK_CUT': const DrillNode(
      code: 'THICK_CUT',
      name: 'Thick Cut',
      nameVi: 'Cắt dày',
      description: 'Cú đánh với góc cắt dày (> 45°).',
      skillsTrained: [PoolSkills.aiming],
      fixesMistakes: [CommonMistakes.thickHit],
      prerequisites: ['STRAIGHT_POT'],
      nextDrills: ['THIN_CUT', 'BANK_SHOT'],
      relatedDrills: ['THIN_CUT'],
      tips: [
        'Điểm ngắm gần với bi mục tiêu',
        'Tốc độ mạnh hơn với cú cắt dày',
      ],
      commonMistakes: [
        'Đánh không đủ mạnh',
        'Ngắm lệch',
      ],
      metrics: ['accuracy', 'cut_angle'],
      difficulty: DrillDifficulty.beginner,
      estimatedMinutes: 20,
    ),

    'BANK_SHOT': const DrillNode(
      code: 'BANK_SHOT',
      name: 'Bank Shot',
      nameVi: 'Đánh bi vào band',
      description: 'Đánh bi vào band trước khi vào lỗ.',
      skillsTrained: [PoolSkills.bankShot, PoolSkills.aiming, PoolSkills.speedControl],
      fixesMistakes: [CommonMistakes.angleMiss],
      prerequisites: ['THIN_CUT', 'THICK_CUT'],
      nextDrills: ['KICK_SHOT'],
      relatedDrills: ['KICK_SHOT'],
      tips: [
        'Tính góc phản xạ',
        'Tốc độ nhất quán',
        'Ngắm điểm trên band',
      ],
      commonMistakes: [
        'Tính sai góc',
        'Tốc độ không đều',
        'Đánh hơi lệch',
      ],
      metrics: ['accuracy', 'consistency'],
      difficulty: DrillDifficulty.advanced,
      estimatedMinutes: 25,
    ),

    'KICK_SHOT': const DrillNode(
      code: 'KICK_SHOT',
      name: 'Kick Shot',
      nameVi: 'Đá bi',
      description: 'Đánh bi vào band để đến bi mục tiêu bị che.',
      skillsTrained: [PoolSkills.kicking, PoolSkills.aiming],
      fixesMistakes: [CommonMistakes.angleMiss],
      prerequisites: ['BANK_SHOT'],
      nextDrills: ['SAFETY_PLAY'],
      relatedDrills: ['BANK_SHOT'],
      tips: [
        'Xác định điểm chạm band',
        'Ước lượng góc phản xạ',
        'Tốc độ vừa phải',
      ],
      commonMistakes: [
        'Tính sai góc',
        'Đánh quá nhanh hoặc quá chậm',
      ],
      metrics: ['accuracy', 'consistency'],
      difficulty: DrillDifficulty.advanced,
      estimatedMinutes: 25,
    ),

    'SAFETY_PLAY': const DrillNode(
      code: 'SAFETY_PLAY',
      name: 'Safety Play',
      nameVi: 'Chơi an toàn',
      description: 'Đánh an toàn khi không có cú đánh tốt.',
      skillsTrained: [PoolSkills.safetyPlay, PoolSkills.positionPlay],
      fixesMistakes: [CommonMistakes.rushShot],
      prerequisites: ['STOP_BALL', 'DRAW_SHOT'],
      nextDrills: ['BREAK_SHOT'],
      relatedDrills: ['ESCAPING'],
      tips: [
        'Ưu tiên để đối thủ khó đánh',
        'Kiểm soát bi cái tốt',
        'Có thể đánh bi vào band an toàn',
      ],
      commonMistakes: [
        'Đánh quá vội vàng',
        'Không quan tâm vị trí sau cú đánh',
      ],
      metrics: ['success_rate', 'defensive_position'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 20,
    ),

    'BREAK_SHOT': const DrillNode(
      code: 'BREAK_SHOT',
      name: 'Break Shot',
      nameVi: 'Khai cuộc',
      description: 'Cú đánh mở đầu ván đấu.',
      skillsTrained: [PoolSkills.breakShot, PoolSkills.stroke, PoolSkills.speedControl],
      fixesMistakes: [],
      prerequisites: ['DRAW_SHOT', 'FOLLOW_SHOT'],
      nextDrills: ['RUN_OUT'],
      relatedDrills: ['SPEED_CONTROL'],
      tips: [
        'Đánh mạnh và thẳng',
        'Chạm vào điểm 1/4 từ tâm bi',
        'Follow through dài',
      ],
      commonMistakes: [
        'Đánh không đủ mạnh',
        'Đánh lệch tâm',
        'Ngắm không thẳng',
      ],
      metrics: ['break_efficiency', 'balls_pocketed', 'scratch_rate'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 20,
    ),

    'POSITION_CONTROL': const DrillNode(
      code: 'POSITION_CONTROL',
      name: 'Position Control',
      nameVi: 'Kiểm soát vị trí',
      description: 'Kiểm soát bi cái đến vị trí mong muốn sau cú đánh.',
      skillsTrained: [PoolSkills.positionPlay, PoolSkills.cueBallControl, PoolSkills.speedControl],
      fixesMistakes: [CommonMistakes.overRun, CommonMistakes.underRun, CommonMistakes.positionMiss],
      prerequisites: ['STOP_BALL', 'FOLLOW_SHOT', 'DRAW_SHOT'],
      nextDrills: ['RUN_OUT'],
      relatedDrills: ['STOP_BALL', 'FOLLOW_SHOT', 'DRAW_SHOT', 'STUN_SHOT'],
      tips: [
        'Lên kế hoạch vị trí trước khi đánh',
        'Chọn điểm đến thực tế',
        'Kiểm soát tốc độ là quan trọng nhất',
      ],
      commonMistakes: [
        'Không lên kế hoạch',
        'Đánh quá nhanh',
        'Chọn vị trí không thực tế',
      ],
      metrics: ['position_accuracy', 'plan_follow_rate'],
      difficulty: DrillDifficulty.advanced,
      estimatedMinutes: 30,
    ),

    'RUN_OUT': const DrillNode(
      code: 'RUN_OUT',
      name: 'Run Out',
      nameVi: 'Đánh hết bi',
      description: 'Đánh hết tất cả bi vào lỗ trong một lượt.',
      skillsTrained: [PoolSkills.runOut, PoolSkills.positionPlay, PoolSkills.aiming],
      fixesMistakes: [CommonMistakes.rushShot],
      prerequisites: ['POSITION_CONTROL', 'BREAK_SHOT'],
      nextDrills: [],
      relatedDrills: ['POSITION_CONTROL'],
      tips: [
        'Ưu tiên bi dễ đánh trước',
        'Lên kế hoạch cho toàn bộ lượt',
        'Giữ bình tĩnh, không vội vàng',
      ],
      commonMistakes: [
        'Vội vàng',
        'Không lên kế hoạch',
        'Đánh bi khó trước bi dễ',
      ],
      metrics: ['run_out_rate', 'balls_pocketed', 'position_accuracy'],
      difficulty: DrillDifficulty.expert,
      estimatedMinutes: 30,
    ),

    'SPEED_CONTROL': const DrillNode(
      code: 'SPEED_CONTROL',
      name: 'Speed Control',
      nameVi: 'Kiểm soát tốc độ',
      description: 'Luyện kiểm soát tốc độ bi cái.',
      skillsTrained: [PoolSkills.speedControl, PoolSkills.cueBallControl],
      fixesMistakes: [CommonMistakes.overRun, CommonMistakes.underRun],
      prerequisites: ['STOP_BALL'],
      nextDrills: ['POSITION_CONTROL'],
      relatedDrills: ['STOP_BALL', 'STUN_SHOT'],
      tips: [
        'Bắt đầu với khoảng cách ngắn',
        'Tập trung vào cảm giác tốc độ',
        'Lặp lại nhiều lần',
      ],
      commonMistakes: [
        'Tốc độ không nhất quán',
        'Đánh quá nhanh',
      ],
      metrics: ['distance_accuracy', 'consistency'],
      difficulty: DrillDifficulty.intermediate,
      estimatedMinutes: 20,
    ),

    'ESCAPING': const DrillNode(
      code: 'ESCAPING',
      name: 'Escaping',
      nameVi: 'Thoát khỏi kẹt',
      description: 'Thoát khỏi tình huống kẹt bi.',
      skillsTrained: [PoolSkills.escaping, PoolSkills.kicking, PoolSkills.bankShot],
      fixesMistakes: [],
      prerequisites: ['KICK_SHOT', 'BANK_SHOT'],
      nextDrills: ['SAFETY_PLAY'],
      relatedDrills: ['KICK_SHOT', 'BANK_SHOT', 'SAFETY_PLAY'],
      tips: [
        'Ước lượng góc và khoảng cách',
        'Tốc độ an toàn trước',
        'Có thể cần nhiều band',
      ],
      commonMistakes: [
        'Tính sai góc',
        'Đánh quá nhanh',
      ],
      metrics: ['success_rate', 'safety_outcome'],
      difficulty: DrillDifficulty.advanced,
      estimatedMinutes: 25,
    ),
  };
}

// ========================================================================
// SEED DATA - Skill Nodes
// ========================================================================

Map<String, SkillNode> _seedSkillNodes() {
  return {
    PoolSkills.aiming: const SkillNode(
      id: PoolSkills.aiming,
      name: 'Aiming',
      nameVi: 'Ngắm',
      description: 'Xác định đường đi của bi và điểm ngắm.',
      category: SkillCategory.foundation,
      prerequisites: [],
      relatedMistakes: [CommonMistakes.misalign, CommonMistakes.thinHit, CommonMistakes.thickHit],
      relatedDrills: ['STRAIGHT_POT', 'THIN_CUT', 'THICK_CUT'],
    ),

    PoolSkills.stroke: const SkillNode(
      id: PoolSkills.stroke,
      name: 'Stroke',
      nameVi: 'Giá đánh',
      description: 'Kỹ thuật đánh - động tác cần nhất quán.',
      category: SkillCategory.foundation,
      prerequisites: [PoolSkills.stance],
      relatedMistakes: [CommonMistakes.jerkyStroke, CommonMistakes.shortStroke],
      relatedDrills: ['STRAIGHT_POT', 'STOP_BALL', 'BREAK_SHOT'],
    ),

    PoolSkills.cueBallControl: const SkillNode(
      id: PoolSkills.cueBallControl,
      name: 'Cue Ball Control',
      nameVi: 'Kiểm soát bi cái',
      description: 'Kiểm soát bi cái di chuyển đến vị trí mong muốn.',
      category: SkillCategory.offensive,
      prerequisites: [PoolSkills.stroke, PoolSkills.speedControl],
      relatedMistakes: [CommonMistakes.cueBallOverrun, CommonMistakes.cueBallStop],
      relatedDrills: ['STOP_BALL', 'FOLLOW_SHOT', 'DRAW_SHOT', 'STUN_SHOT', 'POSITION_CONTROL'],
    ),

    PoolSkills.speedControl: const SkillNode(
      id: PoolSkills.speedControl,
      name: 'Speed Control',
      nameVi: 'Kiểm soát tốc độ',
      description: 'Kiểm soát tốc độ bi cái.',
      category: SkillCategory.foundation,
      prerequisites: [PoolSkills.stroke],
      relatedMistakes: [CommonMistakes.overRun, CommonMistakes.underRun],
      relatedDrills: ['SPEED_CONTROL', 'STOP_BALL', 'STUN_SHOT', 'POSITION_CONTROL'],
    ),

    PoolSkills.positionPlay: const SkillNode(
      id: PoolSkills.positionPlay,
      name: 'Position Play',
      nameVi: 'Chơi vị trí',
      description: 'Lên kế hoạch và kiểm soát vị trí bi cái.',
      category: SkillCategory.offensive,
      prerequisites: [PoolSkills.cueBallControl, PoolSkills.speedControl],
      relatedMistakes: [CommonMistakes.positionMiss],
      relatedDrills: ['POSITION_CONTROL', 'RUN_OUT'],
    ),

    PoolSkills.bankShot: const SkillNode(
      id: PoolSkills.bankShot,
      name: 'Bank Shot',
      nameVi: 'Đánh band',
      description: 'Đánh bi vào band trước khi vào lỗ.',
      category: SkillCategory.offensive,
      prerequisites: [PoolSkills.aiming],
      relatedMistakes: [CommonMistakes.angleMiss],
      relatedDrills: ['BANK_SHOT', 'KICK_SHOT'],
    ),

    PoolSkills.kicking: const SkillNode(
      id: PoolSkills.kicking,
      name: 'Kicking',
      nameVi: 'Đá bi',
      description: 'Đánh bi vào band để đến bi mục tiêu bị che.',
      category: SkillCategory.defensive,
      prerequisites: [PoolSkills.bankShot],
      relatedMistakes: [CommonMistakes.angleMiss],
      relatedDrills: ['KICK_SHOT', 'ESCAPING'],
    ),

    PoolSkills.safetyPlay: const SkillNode(
      id: PoolSkills.safetyPlay,
      name: 'Safety Play',
      nameVi: 'Chơi an toàn',
      description: 'Đánh an toàn khi không có cú đánh tốt.',
      category: SkillCategory.defensive,
      prerequisites: [PoolSkills.positionPlay],
      relatedMistakes: [CommonMistakes.rushShot],
      relatedDrills: ['SAFETY_PLAY'],
    ),

    PoolSkills.breakShot: const SkillNode(
      id: PoolSkills.breakShot,
      name: 'Break Shot',
      nameVi: 'Khai cuộc',
      description: 'Cú đánh mở đầu ván đấu.',
      category: SkillCategory.offensive,
      prerequisites: [PoolSkills.stroke, PoolSkills.speedControl],
      relatedMistakes: [],
      relatedDrills: ['BREAK_SHOT'],
    ),

    PoolSkills.runOut: const SkillNode(
      id: PoolSkills.runOut,
      name: 'Run Out',
      nameVi: 'Đánh hết bi',
      description: 'Đánh hết tất cả bi vào lỗ trong một lượt.',
      category: SkillCategory.offensive,
      prerequisites: [PoolSkills.positionPlay, PoolSkills.aiming],
      relatedMistakes: [CommonMistakes.rushShot],
      relatedDrills: ['RUN_OUT'],
    ),

    PoolSkills.escaping: const SkillNode(
      id: PoolSkills.escaping,
      name: 'Escaping',
      nameVi: 'Thoát kẹt',
      description: 'Thoát khỏi tình huống kẹt bi.',
      category: SkillCategory.defensive,
      prerequisites: [PoolSkills.kicking, PoolSkills.bankShot],
      relatedMistakes: [],
      relatedDrills: ['ESCAPING'],
    ),

    PoolSkills.mentalGame: const SkillNode(
      id: PoolSkills.mentalGame,
      name: 'Mental Game',
      nameVi: 'Tâm lý',
      description: 'Kỹ năng tâm lý trong thi đấu.',
      category: SkillCategory.mental,
      prerequisites: [],
      relatedMistakes: [CommonMistakes.rushShot, CommonMistakes.giveUp],
      relatedDrills: [],
    ),

    PoolSkills.focus: const SkillNode(
      id: PoolSkills.focus,
      name: 'Focus',
      nameVi: 'Tập trung',
      description: 'Khả năng tập trung trong thi đấu.',
      category: SkillCategory.mental,
      prerequisites: [PoolSkills.mentalGame],
      relatedMistakes: [CommonMistakes.rushShot],
      relatedDrills: [],
    ),
  };
}

// ========================================================================
// SEED DATA - Mistake Nodes
// ========================================================================

Map<String, MistakeNode> _seedMistakeNodes() {
  return {
    CommonMistakes.cueBallOverrun: const MistakeNode(
      id: CommonMistakes.cueBallOverrun,
      name: 'Cue Ball Overrun',
      nameVi: 'Bi cái chạy quá xa',
      description: 'Bi cái di chuyển xa hơn vị trí mong muốn.',
      causes: [
        'Tốc độ quá mạnh',
        'Dùng quá nhiều follow',
        'Đánh trên tâm bi quá nhiều',
      ],
      symptoms: [
        'Bi cái chạy qua vị trí đến',
        'Không thể thực hiện cú đánh tiếp theo',
        'Phải điều chỉnh kế hoạch',
      ],
      consequences: [
        'Không kiểm soát được vị trí',
        'Có thể mất lượt đánh',
        'Khó thực hiện run out',
      ],
      relatedSkills: [PoolSkills.speedControl, PoolSkills.cueBallControl],
      fixesByDrills: ['STOP_BALL', 'SPEED_CONTROL', 'STUN_SHOT'],
      fixDifficulty: FixDifficulty.easy,
      category: MistakeCategory.position,
    ),

    CommonMistakes.overRun: const MistakeNode(
      id: CommonMistakes.overRun,
      name: 'Over Run',
      nameVi: 'Chạy quá',
      description: 'Bi cái chạy qua vị trí đánh bi tiếp theo.',
      causes: [
        'Tốc độ quá mạnh',
        'Follow quá nhiều',
        'Ngắm không chính xác',
      ],
      symptoms: [
        'Phải điều chỉnh kế hoạch',
        'Cú đánh khó hơn',
        'Có thể miss',
      ],
      consequences: [
        'Tăng độ khó cú đánh',
        'Có thể miss',
        'Mất kiểm soát trận đấu',
      ],
      relatedSkills: [PoolSkills.positionPlay, PoolSkills.speedControl],
      fixesByDrills: ['STOP_BALL', 'POSITION_CONTROL', 'SPEED_CONTROL'],
      fixDifficulty: FixDifficulty.medium,
      category: MistakeCategory.position,
    ),

    CommonMistakes.underRun: const MistakeNode(
      id: CommonMistakes.underRun,
      name: 'Under Run',
      nameVi: 'Chạy thiếu',
      description: 'Bi cái dừng trước vị trí mong muốn.',
      causes: [
        'Tốc độ yếu',
        'Dùng quá nhiều draw',
        'Ngắm xa hơn thực tế',
      ],
      symptoms: [
        'Không đến được vị trí',
        'Bi mục tiêu ra xa',
        'Cú đánh khó',
      ],
      consequences: [
        'Bỏ lỡ cơ hội',
        'Để đối thủ có lợi thế',
        'Có thể miss',
      ],
      relatedSkills: [PoolSkills.positionPlay, PoolSkills.speedControl, PoolSkills.cueBallControl],
      fixesByDrills: ['DRAW_SHOT', 'SPEED_CONTROL', 'POSITION_CONTROL'],
      fixDifficulty: FixDifficulty.medium,
      category: MistakeCategory.position,
    ),

    CommonMistakes.thinHit: const MistakeNode(
      id: CommonMistakes.thinHit,
      name: 'Thin Hit',
      nameVi: 'Đánh mỏng',
      description: 'Đánh vào bi mục tiêu quá mỏng.',
      causes: [
        'Ngắm sai điểm',
        'Đánh lệch hướng cue',
        'Không đủ tốc độ',
      ],
      symptoms: [
        'Bi mục tiêu đi sai hướng',
        'Có thể không vào lỗ',
        'Bi cái đi hướng khác',
      ],
      consequences: [
        'Miss',
        'Có thể để đối thủ ăn',
        'Mất lượt',
      ],
      relatedSkills: [PoolSkills.aiming],
      fixesByDrills: ['THIN_CUT', 'STRAIGHT_POT'],
      fixDifficulty: FixDifficulty.easy,
      category: MistakeCategory.execution,
    ),

    CommonMistakes.thickHit: const MistakeNode(
      id: CommonMistakes.thickHit,
      name: 'Thick Hit',
      nameVi: 'Đánh dày',
      description: 'Đánh vào bi mục tiêu quá dày.',
      causes: [
        'Ngắm sai điểm',
        'Tư thế lệch',
        'Đánh hướng khác',
      ],
      symptoms: [
        'Bi mục tiêu đi sai hướng',
        'Thường vào lỗ nhưng để lộ bi',
      ],
      consequences: [
        'Để đối thủ ăn',
        'Mất kiểm soát',
      ],
      relatedSkills: [PoolSkills.aiming],
      fixesByDrills: ['THICK_CUT', 'STRAIGHT_POT'],
      fixDifficulty: FixDifficulty.easy,
      category: MistakeCategory.execution,
    ),

    CommonMistakes.misalign: const MistakeNode(
      id: CommonMistakes.misalign,
      name: 'Misalignment',
      nameVi: 'Lệch ngắm',
      description: 'Ngắm không thẳng hàng.',
      causes: [
        'Mắt không đúng vị trí',
        'Tư thế không chuẩn',
        'Ngắm vội vàng',
      ],
      symptoms: [
        'Cú đánh đi sai hướng',
        'Thường lệch một hướng nhất quán',
      ],
      consequences: [
        'Miss thường xuyên',
        'Khó cải thiện',
      ],
      relatedSkills: [PoolSkills.aiming, PoolSkills.stance],
      fixesByDrills: ['STRAIGHT_POT'],
      fixDifficulty: FixDifficulty.medium,
      category: MistakeCategory.execution,
    ),

    CommonMistakes.jerkyStroke: const MistakeNode(
      id: CommonMistakes.jerkyStroke,
      name: 'Jerky Stroke',
      nameVi: 'Giá đánh giật',
      description: 'Động tác đánh không nhất quán, có giật.',
      causes: [
        'Thiếu luyện tập',
        'Căng thẳng',
        'Tư thế không ổn định',
      ],
      symptoms: [
        'Tốc độ không nhất quán',
        'Cú đánh đi sai hướng',
        'Thường đánh yếu',
      ],
      consequences: [
        'Không kiểm soát được tốc độ',
        'Miss',
      ],
      relatedSkills: [PoolSkills.stroke],
      fixesByDrills: ['STRAIGHT_POT', 'STOP_BALL'],
      fixDifficulty: FixDifficulty.medium,
      category: MistakeCategory.execution,
    ),

    CommonMistakes.shortStroke: const MistakeNode(
      id: CommonMistakes.shortStroke,
      name: 'Short Stroke',
      nameVi: 'Giá ngắn',
      description: 'Rút cue ngắn, không đủ follow through.',
      causes: [
        'Sợ đánh mạnh',
        'Thiếu tự tin',
        'Lo lắng',
      ],
      symptoms: [
        'Cú đánh yếu',
        'Bi cái không đi xa',
        'Thường thiếu lực',
      ],
      consequences: [
        'Không đủ lực',
        'Dễ miss',
        'Khó kiểm soát tốc độ',
      ],
      relatedSkills: [PoolSkills.stroke],
      fixesByDrills: ['STRAIGHT_POT', 'BREAK_SHOT'],
      fixDifficulty: FixDifficulty.easy,
      category: MistakeCategory.execution,
    ),

    CommonMistakes.rushShot: const MistakeNode(
      id: CommonMistakes.rushShot,
      name: 'Rush Shot',
      nameVi: 'Đánh vội',
      description: 'Đánh quá nhanh mà không suy nghĩ.',
      causes: [
        'Mất kiên nhẫn',
        'Căng thẳng',
        'Muốn kết thúc nhanh',
      ],
      symptoms: [
        'Đánh không kịp ngắm',
        'Quyết định vội vàng',
        'Không lên kế hoạch',
      ],
      consequences: [
        'Miss',
        'Để lộ bi',
        'Mất lượt',
      ],
      relatedSkills: [PoolSkills.mentalGame, PoolSkills.focus, PoolSkills.safetyPlay],
      fixesByDrills: ['SAFETY_PLAY'],
      fixDifficulty: FixDifficulty.hard,
      category: MistakeCategory.mental,
    ),

    CommonMistakes.positionMiss: const MistakeNode(
      id: CommonMistakes.positionMiss,
      name: 'Position Miss',
      nameVi: 'Sai vị trí',
      description: 'Bi cái không đến vị trí mong muốn.',
      causes: [
        'Tốc độ không đúng',
        'Ngắm sai',
        'Không lên kế hoạch',
      ],
      symptoms: [
        'Phải điều chỉnh kế hoạch',
        'Cú đánh khó hơn',
        'Có thể miss',
      ],
      consequences: [
        'Tăng độ khó',
        'Có thể mất lượt',
      ],
      relatedSkills: [PoolSkills.positionPlay, PoolSkills.speedControl],
      fixesByDrills: ['POSITION_CONTROL', 'SPEED_CONTROL'],
      fixDifficulty: FixDifficulty.medium,
      category: MistakeCategory.position,
    ),

    CommonMistakes.angleMiss: const MistakeNode(
      id: CommonMistakes.angleMiss,
      name: 'Angle Miss',
      nameVi: 'Sai góc',
      description: 'Tính sai góc trong cú đánh band.',
      causes: [
        'Không hiểu phản xạ',
        'Tốc độ không đúng',
        'Ngắm không chính xác',
      ],
      symptoms: [
        'Bi đi sai hướng',
        'Không vào lỗ',
        'Band không đúng',
      ],
      consequences: [
        'Miss',
        'Có thể để lộ bi',
      ],
      relatedSkills: [PoolSkills.bankShot, PoolSkills.kicking],
      fixesByDrills: ['BANK_SHOT', 'KICK_SHOT'],
      fixDifficulty: FixDifficulty.hard,
      category: MistakeCategory.execution,
    ),
  };
}

// ========================================================================
// SEED DATA - Observation Nodes (Phase 5B)
// ========================================================================

Map<String, ObservationNode> _seedObservationNodes() {
  return {
    // Performance observations
    TrainingObservations.accuracyDrop: const ObservationNode(
      id: TrainingObservations.accuracyDrop,
      name: 'Accuracy Drop',
      nameVi: 'Accuracy giảm',
      description: 'Tỷ lệ đánh trúng giảm so với trước đó.',
      dataSource: 'training_session',
      metrics: ['accuracy'],
      conditions: ['accuracy < previous_avg - 10%'],
      suggestsMistakes: [
        CommonMistakes.misalign,
        CommonMistakes.thinHit,
        CommonMistakes.thickHit,
      ],
      category: ObservationCategory.performance,
    ),

    TrainingObservations.highVariance: const ObservationNode(
      id: TrainingObservations.highVariance,
      name: 'High Variance',
      nameVi: 'Biến động cao',
      description: 'Kết quả tập luyện không nhất quán.',
      dataSource: 'training_session',
      metrics: ['variance', 'success_rate'],
      conditions: ['variance > 20%'],
      suggestsMistakes: [
        CommonMistakes.jerkyStroke,
        CommonMistakes.overRun,
        CommonMistakes.underRun,
      ],
      category: ObservationCategory.consistency,
    ),

    TrainingObservations.scorePlateau: const ObservationNode(
      id: TrainingObservations.scorePlateau,
      name: 'Score Plateau',
      nameVi: 'Điểm dậm chân',
      description: 'Điểm số không tăng sau nhiều buổi tập.',
      dataSource: 'training_session',
      metrics: ['score'],
      conditions: ['score_change < 5% over 5 sessions'],
      suggestsMistakes: [],
      category: ObservationCategory.performance,
    ),

    TrainingObservations.scoreDecline: const ObservationNode(
      id: TrainingObservations.scoreDecline,
      name: 'Score Decline',
      nameVi: 'Điểm giảm',
      description: 'Điểm số giảm liên tục.',
      dataSource: 'training_session',
      metrics: ['score'],
      conditions: ['score decreasing over 3 sessions'],
      suggestsMistakes: [
        CommonMistakes.jerkyStroke,
        CommonMistakes.overRun,
        CommonMistakes.underRun,
      ],
      category: ObservationCategory.performance,
    ),

    // Rack-level observations (from match play)
    RackObservations.cueBallOverrun: const ObservationNode(
      id: RackObservations.cueBallOverrun,
      name: 'Cue Ball Overrun',
      nameVi: 'Bi cái chạy quá',
      description: 'Bi cái di chuyển xa hơn vị trí mong muốn.',
      dataSource: 'rack',
      metrics: ['longest_run', 'position_accuracy'],
      suggestsMistakes: [CommonMistakes.cueBallOverrun, CommonMistakes.overRun],
      category: ObservationCategory.technique,
    ),

    RackObservations.cueBallUnderrun: const ObservationNode(
      id: RackObservations.cueBallUnderrun,
      name: 'Cue Ball Underrun',
      nameVi: 'Bi cái chạy thiếu',
      description: 'Bi cái dừng trước vị trí mong muốn.',
      dataSource: 'rack',
      metrics: ['position_accuracy'],
      suggestsMistakes: [CommonMistakes.underRun],
      category: ObservationCategory.technique,
    ),

    RackObservations.thinHit: const ObservationNode(
      id: RackObservations.thinHit,
      name: 'Thin Hit',
      nameVi: 'Đánh mỏng',
      description: 'Bi mục tiêu bị đánh mỏng.',
      dataSource: 'rack',
      metrics: ['cut_accuracy'],
      suggestsMistakes: [CommonMistakes.thinHit, CommonMistakes.misalign],
      category: ObservationCategory.technique,
    ),

    RackObservations.easyMiss: const ObservationNode(
      id: RackObservations.easyMiss,
      name: 'Easy Miss',
      nameVi: 'Miss dễ',
      description: 'Bỏ lỡ cú đánh dễ.',
      dataSource: 'rack',
      metrics: ['easy_shot_miss'],
      suggestsMistakes: [
        CommonMistakes.misalign,
        CommonMistakes.shortStroke,
        CommonMistakes.jerkyStroke,
      ],
      category: ObservationCategory.technique,
    ),

    // Match observations
    MatchObservations.positionMiss: const ObservationNode(
      id: MatchObservations.positionMiss,
      name: 'Position Miss',
      nameVi: 'Sai vị trí',
      description: 'Vị trí bi cáí không như kế hoạch.',
      dataSource: 'match',
      metrics: ['position_recovery'],
      suggestsMistakes: [
        CommonMistakes.positionMiss,
        CommonMistakes.overRun,
        CommonMistakes.underRun,
      ],
      category: ObservationCategory.technique,
    ),

    MatchObservations.safetyFailure: const ObservationNode(
      id: MatchObservations.safetyFailure,
      name: 'Safety Failure',
      nameVi: 'Safety thất bại',
      description: 'Safety không hiệu quả.',
      dataSource: 'match',
      metrics: ['safety_success_rate'],
      suggestsMistakes: [],
      category: ObservationCategory.behavior,
    ),
  };
}

// ========================================================================
// SEED DATA - Cause Nodes (Phase 5B)
// ========================================================================

Map<String, CauseNode> _seedCauseNodes() {
  return {
    // Technique causes
    CommonCauses.rollingCueBall: const CauseNode(
      id: CommonCauses.rollingCueBall,
      name: 'Rolling Cue Ball',
      nameVi: 'Bi cái lăn',
      description: 'Bi cái lăn thay vì dừng hoặc quay lại.',
      affectsSkills: [PoolSkills.speedControl, PoolSkills.cueBallControl],
      leadsToMistakes: [CommonMistakes.overRun, CommonMistakes.cueBallOverrun],
      fixedByDrills: ['STOP_BALL', 'STUN_SHOT', 'SPEED_CONTROL'],
      difficulty: FixDifficulty.easy,
      category: CauseCategory.technique,
      indicators: ['Bi cái không dừng tại điểm đến', 'Position không kiểm soát được'],
      diagnosticQuestions: [
        'Bạn có đang đánh center ball không?',
        'Tốc độ có đều không?',
      ],
    ),

    CommonCauses.overHit: const CauseNode(
      id: CommonCauses.overHit,
      name: 'Over Hit',
      nameVi: 'Đánh quá mạnh',
      description: 'Đánh mạnh hơn mức cần thiết.',
      affectsSkills: [PoolSkills.speedControl],
      leadsToMistakes: [CommonMistakes.overRun, CommonMistakes.cueBallOverrun],
      fixedByDrills: ['STOP_BALL', 'SPEED_CONTROL', 'STUN_SHOT'],
      difficulty: FixDifficulty.easy,
      category: CauseCategory.technique,
      indicators: ['Bi cái chạy qua vị trí', 'Khó kiểm soát tốc độ'],
      diagnosticQuestions: [
        'Bạn có thường đánh mạnh hơn cần thiết không?',
        'Có cảm giác gì khi đánh?',
      ],
    ),

    CommonCauses.underHit: const CauseNode(
      id: CommonCauses.underHit,
      name: 'Under Hit',
      nameVi: 'Đánh yếu',
      description: 'Đánh yếu hơn mức cần thiết.',
      affectsSkills: [PoolSkills.speedControl],
      leadsToMistakes: [CommonMistakes.underRun],
      fixedByDrills: ['SPEED_CONTROL', 'FOLLOW_SHOT'],
      difficulty: FixDifficulty.easy,
      category: CauseCategory.technique,
      indicators: ['Bi cái dừng trước vị trí', 'Cú đánh thiếu lực'],
      diagnosticQuestions: [
        'Bạn có sợ đánh mạnh không?',
        'Có cảm giác mất tự tin không?',
      ],
    ),

    CommonCauses.poorStun: const CauseNode(
      id: CommonCauses.poorStun,
      name: 'Poor Stun',
      nameVi: 'Stun kém',
      description: 'Không kiểm soát được bi cái khi stun.',
      affectsSkills: [PoolSkills.cueBallControl, PoolSkills.speedControl],
      leadsToMistakes: [CommonMistakes.overRun, CommonMistakes.underRun],
      fixedByDrills: ['STUN_SHOT', 'STOP_BALL', 'SPEED_CONTROL'],
      difficulty: FixDifficulty.medium,
      category: CauseCategory.technique,
      indicators: ['Position không nhất quán', 'Khó đến điểm đến'],
      diagnosticQuestions: [
        'Bạn có đánh center ball với lực vừa phải không?',
        'Có thể dừng bi cái tại điểm chính xác không?',
      ],
    ),

    CommonCauses.inconsistentSpeed: const CauseNode(
      id: CommonCauses.inconsistentSpeed,
      name: 'Inconsistent Speed',
      nameVi: 'Tốc độ không đều',
      description: 'Tốc độ đánh không nhất quán giữa các cú.',
      affectsSkills: [PoolSkills.speedControl, PoolSkills.cueBallControl],
      leadsToMistakes: [
        CommonMistakes.overRun,
        CommonMistakes.underRun,
        CommonMistakes.positionMiss,
      ],
      fixedByDrills: ['SPEED_CONTROL', 'STOP_BALL', 'STUN_SHOT'],
      difficulty: FixDifficulty.medium,
      category: CauseCategory.technique,
      indicators: ['Kết quả biến động', 'Position không đoán được'],
      diagnosticQuestions: [
        'Tốc độ có giống nhau mỗi cú không?',
        'Có thể điều chỉnh tốc độ không?',
      ],
    ),

    CommonCauses.shortStroke: const CauseNode(
      id: CommonCauses.shortStroke,
      name: 'Short Stroke',
      nameVi: 'Giá ngắn',
      description: 'Rút cue ngắn, không đủ follow through.',
      affectsSkills: [PoolSkills.stroke],
      leadsToMistakes: [CommonMistakes.shortStroke],
      fixedByDrills: ['STRAIGHT_POT', 'BREAK_SHOT'],
      difficulty: FixDifficulty.easy,
      category: CauseCategory.technique,
      indicators: ['Cú đánh yếu', 'Không đủ lực', 'Bi cái không đi xa'],
      diagnosticQuestions: [
        'Bạn có rút cue đủ xa không?',
        'Follow through có đầy đủ không?',
      ],
    ),

    CommonCauses.jerkyStroke: const CauseNode(
      id: CommonCauses.jerkyStroke,
      name: 'Jerky Stroke',
      nameVi: 'Giá giật',
      description: 'Động tác đánh có giật, không mượt.',
      affectsSkills: [PoolSkills.stroke],
      leadsToMistakes: [CommonMistakes.jerkyStroke],
      fixedByDrills: ['STRAIGHT_POT', 'STOP_BALL'],
      difficulty: FixDifficulty.medium,
      category: CauseCategory.technique,
      indicators: ['Động tác không mượt', 'Tốc độ biến đổi', 'Cú đánh không đều'],
      diagnosticQuestions: [
        'Động tác có mượt không?',
        'Có cảm thấy căng thẳng khi đánh không?',
      ],
    ),

    CommonCauses.misalignedAim: const CauseNode(
      id: CommonCauses.misalignedAim,
      name: 'Misaligned Aim',
      nameVi: 'Lệch ngắm',
      description: 'Ngắm không thẳng hàng với đường bi.',
      affectsSkills: [PoolSkills.aiming],
      leadsToMistakes: [CommonMistakes.misalign, CommonMistakes.thinHit, CommonMistakes.thickHit],
      fixedByDrills: ['STRAIGHT_POT', 'THIN_CUT', 'THICK_CUT'],
      difficulty: FixDifficulty.medium,
      category: CauseCategory.technique,
      indicators: ['Thường đánh lệch một hướng', 'Cú đánh đi sai'],
      diagnosticQuestions: [
        'Mắt có thẳng với đường ngắm không?',
        'Tư thế có thoải mái không?',
      ],
    ),

    // Mental causes
    CommonCauses.rushDecision: const CauseNode(
      id: CommonCauses.rushDecision,
      name: 'Rush Decision',
      nameVi: 'Quyết định vội',
      description: 'Đưa ra quyết định quá nhanh, không suy nghĩ.',
      affectsSkills: [PoolSkills.mentalGame, PoolSkills.focus],
      leadsToMistakes: [CommonMistakes.rushShot],
      fixedByDrills: ['SAFETY_PLAY'],
      difficulty: FixDifficulty.hard,
      category: CauseCategory.mental,
      indicators: ['Đánh không kịp ngắm', 'Quyết định vội vàng'],
      diagnosticQuestions: [
        'Bạn có thường đánh ngay sau khi đối thủ đánh không?',
        'Có đủ thời gian để ngắm không?',
      ],
    ),

    CommonCauses.lossOfFocus: const CauseNode(
      id: CommonCauses.lossOfFocus,
      name: 'Loss of Focus',
      nameVi: 'Mất tập trung',
      description: 'Không tập trung vào cú đánh.',
      affectsSkills: [PoolSkills.focus, PoolSkills.mentalGame],
      leadsToMistakes: [CommonMistakes.misalign, CommonMistakes.jerkyStroke],
      fixedByDrills: ['STRAIGHT_POT'],
      difficulty: FixDifficulty.hard,
      category: CauseCategory.mental,
      indicators: ['Đánh sai cú dễ', 'Tư thế không ổn định'],
      diagnosticQuestions: [
        'Có đang nghĩ về điều gì khác không?',
        'Có bị phân tâm không?',
      ],
    ),

    // Strategic causes
    CommonCauses.noPlanning: const CauseNode(
      id: CommonCauses.noPlanning,
      name: 'No Planning',
      nameVi: 'Không lên kế hoạch',
      description: 'Không lên kế hoạch cho cú đánh và vị trí tiếp theo.',
      affectsSkills: [PoolSkills.positionPlay],
      leadsToMistakes: [CommonMistakes.positionMiss, CommonMistakes.overRun, CommonMistakes.underRun],
      fixedByDrills: ['POSITION_CONTROL'],
      difficulty: FixDifficulty.medium,
      category: CauseCategory.strategic,
      indicators: ['Không có kế hoạch vị trí', 'Position không như mong đợi'],
      diagnosticQuestions: [
        'Bạn có nghĩ đến vị trí bi cái sau cú đánh không?',
        'Có lên kế hoạch cho 2-3 cú tiếp theo không?',
      ],
    ),
  };
}

// ========================================================================
// SEED DATA - Situation Nodes (Phase 5C)
// ========================================================================

Map<String, SituationNode> _seedSituationNodes() {
  return {
    CommonSituations.easyShot: const SituationNode(
      id: CommonSituations.easyShot,
      name: 'Easy Shot',
      nameVi: 'Cú đánh dễ',
      description: 'Cú đánh có góc rộng, gần lỗ.',
      descriptors: ['easy', 'routine', 'high success'],
      recommendedTactics: [CommonTactics.runOutAttempt],
      avoidTactics: [],
      priority: 1,
      category: SituationCategory.offensive,
    ),

    CommonSituations.difficultShot: const SituationNode(
      id: CommonSituations.difficultShot,
      name: 'Difficult Shot',
      nameVi: 'Cú đánh khó',
      description: 'Cú đánh có góc hẹp, xa lỗ, hoặc cần kỹ thuật cao.',
      descriptors: ['hard', 'technical', 'low success'],
      recommendedTactics: [CommonTactics.safetyPlay, CommonTactics.conservativePlay],
      avoidTactics: [CommonTactics.runOutAttempt],
      priority: 3,
      category: SituationCategory.offensive,
    ),

    CommonSituations.thinCut: const SituationNode(
      id: CommonSituations.thinCut,
      name: 'Thin Cut',
      nameVi: 'Cắt mỏng',
      description: 'Cú đánh với góc cắt mỏng (< 30°).',
      descriptors: ['thin', 'technical', 'moderate risk'],
      recommendedTactics: [CommonTactics.thinCutAttack, CommonTactics.bankShot],
      avoidTactics: [CommonTactics.runOutAttempt],
      priority: 2,
      category: SituationCategory.offensive,
    ),

    CommonSituations.noGoodShot: const SituationNode(
      id: CommonSituations.noGoodShot,
      name: 'No Good Shot',
      nameVi: 'Không có cú đánh tốt',
      description: 'Không có cú đánh trực tiếp vào bi mục tiêu.',
      descriptors: ['blocked', 'no line', 'tough position'],
      recommendedTactics: [CommonTactics.safetyPlay, CommonTactics.pushOut],
      avoidTactics: [CommonTactics.runOutAttempt, CommonTactics.thinCutAttack],
      priority: 3,
      category: SituationCategory.defensive,
    ),

    CommonSituations.hillHill: const SituationNode(
      id: CommonSituations.hillHill,
      name: 'Hill-Hill',
      nameVi: 'Đều đều',
      description: 'Trận đấu ngang nhau, ván quyết định.',
      descriptors: ['critical', 'pressure', 'tied'],
      recommendedTactics: [CommonTactics.conservativePlay, CommonTactics.slowDown],
      avoidTactics: [CommonTactics.runOutAttempt],
      priority: 3,
      category: SituationCategory.pressure,
    ),

    CommonSituations.bigLead: const SituationNode(
      id: CommonSituations.bigLead,
      name: 'Big Lead',
      nameVi: 'Dẫn trước nhiều',
      description: 'Đang dẫn trước với khoảng cách lớn.',
      descriptors: ['dominant', 'comfortable', 'advantage'],
      recommendedTactics: [CommonTactics.conservativePlay, CommonTactics.positionPlay],
      avoidTactics: [CommonTactics.riskyShot],
      priority: 1,
      category: SituationCategory.strategic,
    ),

    CommonSituations.bigDeficit: const SituationNode(
      id: CommonSituations.bigDeficit,
      name: 'Big Deficit',
      nameVi: 'Thua xa',
      description: 'Đang thua với khoảng cách lớn.',
      descriptors: ['behind', 'must-win', 'pressure'],
      recommendedTactics: [CommonTactics.aggressiveBreak, CommonTactics.runOutAttempt],
      avoidTactics: [CommonTactics.conservativePlay],
      priority: 3,
      category: SituationCategory.strategic,
    ),

    CommonSituations.cueBallTight: const SituationNode(
      id: CommonSituations.cueBallTight,
      name: 'Cue Ball Tight',
      nameVi: 'Bi cái kẹt',
      description: 'Bi cái gần band hoặc trong vùng khó.',
      descriptors: ['tight', 'restricted', 'constrained'],
      recommendedTactics: [CommonTactics.safetyPlay, CommonTactics.kickSafety],
      avoidTactics: [CommonTactics.runOutAttempt],
      priority: 3,
      category: SituationCategory.defensive,
    ),

    CommonSituations.breakAfterFoul: const SituationNode(
      id: CommonSituations.breakAfterFoul,
      name: 'Break After Foul',
      nameVi: 'Khai cuộc sau lỗi',
      description: 'Được quyền khai cuộc sau khi đối thủ phạm lỗi.',
      descriptors: ['free break', 'advantage', 'opportunity'],
      recommendedTactics: [CommonTactics.controlledBreak],
      avoidTactics: [CommonTactics.aggressiveBreak],
      priority: 2,
      category: SituationCategory.offensive,
    ),

    CommonSituations.matchBall: const SituationNode(
      id: CommonSituations.matchBall,
      name: 'Match Ball',
      nameVi: 'Điểm match',
      description: 'Cú đánh quyết định thắng thua trận đấu.',
      descriptors: ['critical', 'match point', 'high pressure'],
      recommendedTactics: [CommonTactics.conservativePlay, CommonTactics.slowDown],
      avoidTactics: [CommonTactics.runOutAttempt, CommonTactics.aggressiveBreak],
      priority: 3,
      category: SituationCategory.pressure,
    ),
  };
}

// ========================================================================
// SEED DATA - Tactic Nodes (Phase 5C)
// ========================================================================

Map<String, TacticNode> _seedTacticNodes() {
  return {
    CommonTactics.safetyPlay: const TacticNode(
      id: CommonTactics.safetyPlay,
      name: 'Safety Play',
      nameVi: 'Chơi an toàn',
      description: 'Đánh an toàn khi không có cú đánh tốt.',
      objective: 'Để đối thủ khó đánh hoặc miss.',
      whenToUse: [CommonSituations.noGoodShot, CommonSituations.difficultShot, CommonSituations.cueBallTight],
      whenToAvoid: [CommonSituations.easyShot, CommonSituations.bigDeficit],
      requiredSkills: [PoolSkills.safetyPlay, PoolSkills.positionPlay],
      improvesSkills: [PoolSkills.safetyPlay, PoolSkills.positionPlay],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.low,
        risks: [
          RiskItem(
            id: 'safety_fail',
            description: 'Safety không hiệu quả',
            consequence: 'Để đối thủ ăn',
            probability: 0.2,
          ),
        ],
        mitigations: ['Chọn vị trí leave tốt', 'Đánh đủ lực'],
      ),
      successConditions: ['Leave tốt', 'Đối thủ khó đánh'],
      failureConditions: ['Leave không tốt', 'Đối thủ có cú đánh dễ'],
      difficulty: TacticDifficulty.intermediate,
      category: TacticCategory.defensive,
      tips: [
        'Ưu tiên leave cho đối thủ khó',
        'Có thể đánh vào band an toàn',
        'Tốc độ phù hợp',
      ],
    ),

    CommonTactics.runOutAttempt: const TacticNode(
      id: CommonTactics.runOutAttempt,
      name: 'Run Out Attempt',
      nameVi: 'Thử đánh hết bi',
      description: 'Cố gắng đánh hết tất cả bi vào lỗ.',
      objective: 'Kết thúc ván ngay lập tức.',
      whenToUse: [CommonSituations.easyShot],
      whenToAvoid: [CommonSituations.difficultShot, CommonSituations.hillHill, CommonSituations.noGoodShot, CommonSituations.matchBall],
      requiredSkills: [PoolSkills.runOut, PoolSkills.positionPlay, PoolSkills.aiming],
      improvesSkills: [PoolSkills.runOut, PoolSkills.positionPlay],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.high,
        risks: [
          RiskItem(
            id: 'position_miss',
            description: 'Sai vị trí',
            consequence: 'Phải đánh cú khó hoặc safety',
            probability: 0.5,
          ),
          RiskItem(
            id: 'miss',
            description: 'Miss',
            consequence: 'Mất lượt, để đối thủ ăn',
            probability: 0.2,
          ),
        ],
        mitigations: ['Lên kế hoạch kỹ', 'Chọn vị trí thực tế'],
      ),
      successConditions: ['Đánh hết bi', 'Không miss'],
      failureConditions: ['Miss', 'Sai vị trí nghiêm trọng'],
      difficulty: TacticDifficulty.expert,
      category: TacticCategory.offensive,
      tips: [
        'Ưu tiên bi dễ trước',
        'Lên kế hoạch toàn bộ',
        'Giữ bình tĩnh',
      ],
    ),

    CommonTactics.conservativePlay: const TacticNode(
      id: CommonTactics.conservativePlay,
      name: 'Conservative Play',
      nameVi: 'Chơi an toàn chiến lược',
      description: 'Chơi chắc, giảm rủi ro.',
      objective: 'Không mắc sai lầm, chờ đợi cơ hội.',
      whenToUse: [CommonSituations.hillHill, CommonSituations.bigLead, CommonSituations.matchBall],
      whenToAvoid: [CommonSituations.bigDeficit],
      requiredSkills: [PoolSkills.positionPlay, PoolSkills.mentalGame],
      improvesSkills: [PoolSkills.mentalGame, PoolSkills.positionPlay],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.low,
        risks: [
          RiskItem(
            id: 'too_conservative',
            description: 'Quá conservative',
            consequence: 'Bỏ lỡ cơ hội',
            probability: 0.15,
          ),
        ],
        mitigations: ['Đánh khi có cơ hội tốt'],
      ),
      successConditions: ['Không miss', 'Giữ được lợi thế'],
      failureConditions: ['Để mất lợi thế'],
      difficulty: TacticDifficulty.easy,
      category: TacticCategory.mental,
      tips: [
        'Ưu tiên không miss',
        'Chờ đợi cơ hội tốt',
        'Kiên nhẫn',
      ],
    ),

    CommonTactics.thinCutAttack: const TacticNode(
      id: CommonTactics.thinCutAttack,
      name: 'Thin Cut Attack',
      nameVi: 'Tấn công cú cắt mỏng',
      description: 'Đánh cú cắt mỏng để vào bi.',
      objective: 'Tiếp tục lượt đánh.',
      whenToUse: [CommonSituations.thinCut],
      whenToAvoid: [CommonSituations.hillHill, CommonSituations.bigLead],
      requiredSkills: [PoolSkills.aiming, PoolSkills.cueBallControl],
      improvesSkills: [PoolSkills.aiming],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.medium,
        risks: [
          RiskItem(
            id: 'thin_miss',
            description: 'Đánh mỏng miss',
            consequence: 'Mất lượt',
            probability: 0.3,
          ),
        ],
        mitigations: ['Ngắm chính xác', 'Tốc độ vừa phải'],
      ),
      successConditions: ['Đánh trúng', 'Có position'],
      failureConditions: ['Miss', 'Để lộ bi'],
      difficulty: TacticDifficulty.advanced,
      category: TacticCategory.offensive,
      tips: [
        'Ngắm chính xác',
        'Tốc độ vừa phải',
        'Follow through đầy đủ',
      ],
    ),

    CommonTactics.controlledBreak: const TacticNode(
      id: CommonTactics.controlledBreak,
      name: 'Controlled Break',
      nameVi: 'Khai cuộc kiểm soát',
      description: 'Khai cuộc với lực vừa phải, kiểm soát bi.',
      objective: 'Phân tán bi, giữ vị trí kiểm soát.',
      whenToUse: [CommonSituations.breakAfterFoul],
      whenToAvoid: [CommonSituations.bigDeficit],
      requiredSkills: [PoolSkills.breakShot],
      improvesSkills: [PoolSkills.breakShot],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.low,
        risks: [
          RiskItem(
            id: 'scratch',
            description: 'Scratch',
            consequence: 'Đối thủ được khai cuộc',
            probability: 0.15,
          ),
        ],
        mitigations: ['Đánh đúng điểm', 'Không quá mạnh'],
      ),
      successConditions: ['Phân tán bi tốt', 'Không scratch'],
      failureConditions: ['Scratch', 'Bi tụ lại'],
      difficulty: TacticDifficulty.intermediate,
      category: TacticCategory.offensive,
      tips: [
        'Lực vừa phải',
        'Chạm điểm 1/4 từ tâm',
        'Follow through dài',
      ],
    ),

    CommonTactics.aggressiveBreak: const TacticNode(
      id: CommonTactics.aggressiveBreak,
      name: 'Aggressive Break',
      nameVi: 'Khai cuộc mạnh',
      description: 'Khai cuộc với lực mạnh nhất.',
      objective: 'Phá vỡ cục bi, có cơ hội ăn nhiều.',
      whenToUse: [CommonSituations.bigDeficit],
      whenToAvoid: [CommonSituations.breakAfterFoul, CommonSituations.hillHill],
      requiredSkills: [PoolSkills.breakShot],
      improvesSkills: [PoolSkills.breakShot],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.high,
        risks: [
          RiskItem(
            id: 'scratch',
            description: 'Scratch',
            consequence: 'Đối thủ được lợi',
            probability: 0.4,
          ),
        ],
        mitigations: ['Chỉ dùng khi cần thiết'],
      ),
      successConditions: ['Ăn nhiều', 'Phân tán tốt'],
      failureConditions: ['Scratch', 'Bi tụ lại'],
      difficulty: TacticDifficulty.intermediate,
      category: TacticCategory.offensive,
      tips: [
        'Đánh mạnh và thẳng',
        'Chạm bi đầu 1/4',
        'Chỉ dùng khi cần',
      ],
    ),

    CommonTactics.slowDown: const TacticNode(
      id: CommonTactics.slowDown,
      name: 'Slow Down',
      nameVi: 'Chậm lại',
      description: 'Giảm tốc độ quyết định trong tình huống áp lực.',
      objective: 'Tránh sai lầm do vội vàng.',
      whenToUse: [CommonSituations.hillHill, CommonSituations.matchBall],
      whenToAvoid: [CommonSituations.bigDeficit],
      requiredSkills: [PoolSkills.mentalGame],
      improvesSkills: [PoolSkills.mentalGame],
      riskProfile: RiskProfile.low,
      successConditions: ['Quyết định đúng', 'Không vội vàng'],
      failureConditions: ['Vẫn vội vàng'],
      difficulty: TacticDifficulty.easy,
      category: TacticCategory.mental,
      tips: [
        'Hít thở sâu',
        'Đếm đến 3 trước khi đánh',
        'Ngắm kỹ hơn bình thường',
      ],
    ),

    CommonTactics.kickSafety: const TacticNode(
      id: CommonTactics.kickSafety,
      name: 'Kick Safety',
      nameVi: 'Đá an toàn',
      description: 'Đánh band để thoát khỏi vùng kẹt và leave tốt.',
      objective: 'Thoát kẹt, tạo leave tốt.',
      whenToUse: [CommonSituations.cueBallTight],
      whenToAvoid: [CommonSituations.easyShot],
      requiredSkills: [PoolSkills.kicking, PoolSkills.safetyPlay],
      improvesSkills: [PoolSkills.kicking],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.medium,
        risks: [
          RiskItem(
            id: 'kick_miss',
            description: 'Đá miss',
            consequence: 'Mất lượt',
            probability: 0.35,
          ),
        ],
        mitigations: ['Ước lượng góc kỹ'],
      ),
      successConditions: ['Thoát được', 'Leave tốt'],
      failureConditions: ['Miss', 'Leave không tốt'],
      difficulty: TacticDifficulty.advanced,
      category: TacticCategory.defensive,
      tips: [
        'Xác định điểm chạm band',
        'Ước lượng góc phản xạ',
        'Tốc độ an toàn',
      ],
    ),

    CommonTactics.positionPlay: const TacticNode(
      id: CommonTactics.positionPlay,
      name: 'Position Play',
      nameVi: 'Chơi vị trí',
      description: 'Kiểm soát vị trí bi cái cho cú đánh tiếp theo.',
      objective: 'Tạo vị trí thuận lợi.',
      whenToUse: [CommonSituations.bigLead, CommonSituations.easyShot],
      whenToAvoid: [CommonSituations.cueBallTight],
      requiredSkills: [PoolSkills.positionPlay, PoolSkills.speedControl],
      improvesSkills: [PoolSkills.positionPlay],
      riskProfile: RiskProfile(
        riskLevel: RiskLevel.medium,
        risks: [
          RiskItem(
            id: 'position_miss',
            description: 'Sai vị trí',
            consequence: 'Cú đánh khó hơn',
            probability: 0.4,
          ),
        ],
        mitigations: ['Chọn vị trí thực tế'],
      ),
      successConditions: ['Đến vị trí mong muốn'],
      failureConditions: ['Sai vị trí'],
      difficulty: TacticDifficulty.advanced,
      category: TacticCategory.positional,
      tips: [
        'Lên kế hoạch trước',
        'Chọn vị trí thực tế',
        'Kiểm soát tốc độ',
      ],
    ),
  };
}

// ========================================================================
// SEED DATA - Decision Rules (Phase 5C)
// ========================================================================

List<DecisionRule> _seedDecisionRules() {
  return [
    // No good shot → Safety
    const DecisionRule(
      id: 'rule_ngs_001',
      situationId: CommonSituations.noGoodShot,
      tacticId: CommonTactics.safetyPlay,
      reason: 'Không có cú đánh tốt, safety là lựa chọn an toàn nhất.',
      alternativeTacticId: CommonTactics.pushOut,
      confidence: DecisionConfidence.high,
      priority: 3,
    ),

    // Easy shot → Run out
    const DecisionRule(
      id: 'rule_es_001',
      situationId: CommonSituations.easyShot,
      tacticId: CommonTactics.runOutAttempt,
      reason: 'Cú đánh dễ, đây là cơ hội đánh hết bi.',
      confidence: DecisionConfidence.high,
      priority: 3,
    ),

    // Hill-hill → Conservative
    const DecisionRule(
      id: 'rule_hh_001',
      situationId: CommonSituations.hillHill,
      tacticId: CommonTactics.conservativePlay,
      reason: 'Trận đấu ngang nhau, tránh rủi ro không cần thiết.',
      alternativeTacticId: CommonTactics.positionPlay,
      confidence: DecisionConfidence.high,
      priority: 3,
    ),

    // Big deficit → Aggressive
    const DecisionRule(
      id: 'rule_bd_001',
      situationId: CommonSituations.bigDeficit,
      tacticId: CommonTactics.aggressiveBreak,
      reason: 'Cần tạo đột phá, break mạnh có thể phá vỡ cục diện.',
      confidence: DecisionConfidence.medium,
      priority: 2,
    ),

    // Difficult shot → Safety
    const DecisionRule(
      id: 'rule_ds_001',
      situationId: CommonSituations.difficultShot,
      tacticId: CommonTactics.safetyPlay,
      reason: 'Cú đánh khó, rủi ro miss cao. Safety để giữ lượt.',
      confidence: DecisionConfidence.high,
      priority: 3,
    ),

    // Match ball → Slow down
    const DecisionRule(
      id: 'rule_mb_001',
      situationId: CommonSituations.matchBall,
      tacticId: CommonTactics.slowDown,
      reason: 'Cú đánh quyết định. Chậm lại để tránh sai lầm.',
      confidence: DecisionConfidence.high,
      priority: 3,
    ),

    // Cue ball tight → Kick safety
    const DecisionRule(
      id: 'rule_cbt_001',
      situationId: CommonSituations.cueBallTight,
      tacticId: CommonTactics.kickSafety,
      reason: 'Bi cái kẹt, cần thoát bằng cách đá band.',
      alternativeTacticId: CommonTactics.safetyPlay,
      confidence: DecisionConfidence.medium,
      priority: 3,
    ),

    // Break after foul → Controlled break
    const DecisionRule(
      id: 'rule_baf_001',
      situationId: CommonSituations.breakAfterFoul,
      tacticId: CommonTactics.controlledBreak,
      reason: 'Được free break, kiểm soát để tránh scratch.',
      confidence: DecisionConfidence.high,
      priority: 2,
    ),

    // Thin cut → Thin cut attack
    const DecisionRule(
      id: 'rule_tc_001',
      situationId: CommonSituations.thinCut,
      tacticId: CommonTactics.thinCutAttack,
      reason: 'Cú cắt mỏng có thể thực hiện được với kỹ thuật tốt.',
      alternativeTacticId: CommonTactics.bankShot,
      confidence: DecisionConfidence.medium,
      priority: 2,
    ),

    // Big lead → Conservative
    const DecisionRule(
      id: 'rule_bl_001',
      situationId: CommonSituations.bigLead,
      tacticId: CommonTactics.conservativePlay,
      reason: 'Đang dẫn, giữ lợi thế bằng cách chơi chắc.',
      confidence: DecisionConfidence.high,
      priority: 2,
    ),
  ];
}
