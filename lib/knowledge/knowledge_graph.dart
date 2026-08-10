// ============================================================================
// KNOWLEDGE GRAPH - Phase 5C
// Coach AI Brain Foundation - Decision Engine
//
// Situation → Tactic → Decision Rule → Reasoning
// ============================================================================

import 'drill_node.dart';
import 'mistake_node.dart';
import 'skill_node.dart';
import 'observation_node.dart';
import 'cause_node.dart';
import 'situation_node.dart';
import 'tactic_node.dart';
import 'decision_node.dart';

/// Knowledge Graph - Queryable knowledge structure for Coach AI
/// Includes the full reasoning chain + decision engine
class KnowledgeGraph {
  KnowledgeGraph({
    Map<String, DrillNode>? drillNodes,
    Map<String, SkillNode>? skillNodes,
    Map<String, MistakeNode>? mistakeNodes,
    Map<String, ObservationNode>? observationNodes,
    Map<String, CauseNode>? causeNodes,
    Map<String, SituationNode>? situationNodes,
    Map<String, TacticNode>? tacticNodes,
    List<DecisionRule>? decisionRules,
  }) : drillNodes = drillNodes ?? {},
       skillNodes = skillNodes ?? {},
       mistakeNodes = mistakeNodes ?? {},
       observationNodes = observationNodes ?? {},
       causeNodes = causeNodes ?? {},
       situationNodes = situationNodes ?? {},
       tacticNodes = tacticNodes ?? {},
       decisionRules = decisionRules ?? [];

  final Map<String, DrillNode> drillNodes;
  final Map<String, SkillNode> skillNodes;
  final Map<String, MistakeNode> mistakeNodes;
  final Map<String, ObservationNode> observationNodes;
  final Map<String, CauseNode> causeNodes;
  final Map<String, SituationNode> situationNodes;
  final Map<String, TacticNode> tacticNodes;
  final List<DecisionRule> decisionRules;

  // ========================================================================
  // DRILL QUERIES
  // ========================================================================

  /// Query: Get drill by code
  DrillNode? getDrill(String code) => drillNodes[code];

  /// Query: Get drills that train a specific skill
  List<DrillNode> getDrillsBySkill(String skillId) {
    return drillNodes.values
        .where((d) => d.skillsTrained.contains(skillId))
        .toList();
  }

  /// Query: Get drills that fix a specific mistake
  List<DrillNode> getDrillsForMistake(String mistakeId) {
    return drillNodes.values
        .where((d) => d.fixesMistakes.contains(mistakeId))
        .toList();
  }

  /// Query: Get drills that address a cause
  List<DrillNode> getDrillsForCause(String causeId) {
    return drillNodes.values
        .where((d) => d.fixesCauses.contains(causeId))
        .toList();
  }

  /// Query: Get prerequisites for a drill
  List<DrillNode> getPrerequisites(String drillCode) {
    final drill = drillNodes[drillCode];
    if (drill == null) return [];
    return drill.prerequisites
        .map((code) => drillNodes[code])
        .whereType<DrillNode>()
        .toList();
  }

  /// Query: Get progression drills (what to practice next)
  List<DrillNode> getProgressionDrills(String drillCode) {
    final drill = drillNodes[drillCode];
    if (drill == null) return [];
    return drill.nextDrills
        .map((code) => drillNodes[code])
        .whereType<DrillNode>()
        .toList();
  }

  /// Query: Get all drills sorted by difficulty
  List<DrillNode> getAllDrillsSortedByDifficulty() {
    final drills = drillNodes.values.toList();
    drills.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
    return drills;
  }

  /// Query: Get drills by level
  List<DrillNode> getDrillsByLevel(DrillDifficulty level) {
    return drillNodes.values
        .where((d) => d.difficulty == level)
        .toList();
  }

  // ========================================================================
  // MISTAKE QUERIES
  // ========================================================================

  /// Query: Get mistake by id
  MistakeNode? getMistake(String id) => mistakeNodes[id];

  /// Query: Get mistakes related to a skill
  List<MistakeNode> getMistakesBySkill(String skillId) {
    return mistakeNodes.values
        .where((m) => m.relatedSkills.contains(skillId))
        .toList();
  }

  // ========================================================================
  // OBSERVATION QUERIES - Phase 5B
  // ========================================================================

  /// Query: Get observation by id
  ObservationNode? getObservation(String id) => observationNodes[id];

  /// Query: Get observations that suggest a mistake
  List<ObservationNode> getObservationsForMistake(String mistakeId) {
    return observationNodes.values
        .where((o) => o.suggestsMistakes.contains(mistakeId))
        .toList();
  }

  // ========================================================================
  // CAUSE QUERIES - Phase 5B
  // ========================================================================

  /// Query: Get cause by id
  CauseNode? getCause(String id) => causeNodes[id];

  /// Query: Get skill by id
  SkillNode? getSkill(String id) => skillNodes[id];

  /// Query: Get all skills
  List<SkillNode> getAllSkills() => skillNodes.values.toList();

  /// Query: Get causes for a mistake
  List<CauseNode> getCausesForMistake(String mistakeId) {
    final mistake = mistakeNodes[mistakeId];
    if (mistake == null) return [];
    return mistake.causes
        .map((id) => causeNodes[id])
        .whereType<CauseNode>()
        .toList();
  }

  /// Query: Get causes related to a skill
  List<CauseNode> getCausesForSkill(String skillId) {
    return causeNodes.values
        .where((c) => c.affectsSkills.contains(skillId))
        .toList();
  }

  // ========================================================================
  // REASONING CHAIN QUERIES - Phase 5B
  // ========================================================================

  /// Query: Full reasoning chain from observation to recommendation
  /// Returns: {observations, patterns, mistakes, causes, drills}
  ReasoningChain buildReasoningChain({
    required List<String> observations,
    required String targetSkill,
  }) {
    final relevantObservations = observations
        .map((id) => observationNodes[id])
        .whereType<ObservationNode>()
        .toList();

    final suggestedMistakes = <MistakeNode>{};
    for (final obs in relevantObservations) {
      for (final mistakeId in obs.suggestsMistakes) {
        final mistake = mistakeNodes[mistakeId];
        if (mistake != null) {
          suggestedMistakes.add(mistake);
        }
      }
    }

    // Filter mistakes that relate to the target skill
    final relevantMistakes = suggestedMistakes
        .where((m) => m.relatedSkills.contains(targetSkill))
        .toList();

    // Get causes for relevant mistakes
    final relevantCauses = <CauseNode>{};
    for (final mistake in relevantMistakes) {
      for (final causeId in mistake.causes) {
        final cause = causeNodes[causeId];
        if (cause != null) {
          relevantCauses.add(cause);
        }
      }
    }

    // Get drills that fix the causes
    final recommendedDrills = <DrillNode>{};
    for (final cause in relevantCauses) {
      for (final drillCode in cause.fixedByDrills) {
        final drill = drillNodes[drillCode];
        if (drill != null) {
          recommendedDrills.add(drill);
        }
      }
    }

    return ReasoningChain(
      observations: relevantObservations,
      mistakes: relevantMistakes,
      causes: relevantCauses.toList(),
      drills: recommendedDrills.toList(),
      targetSkill: targetSkill,
    );
  }

  /// Query: Generate explanation for why a drill is recommended
  String explainDrillRecommendation({
    required DrillNode drill,
    required List<MistakeNode> relatedMistakes,
    required List<CauseNode> relatedCauses,
  }) {
    final parts = <String>[];

    // Explain what the drill trains
    if (drill.skillsTrained.isNotEmpty) {
      final skillNames = drill.skillsTrained
          .map((s) => skillNodes[s]?.nameVi ?? s)
          .join(', ');
      parts.add('Drill này giúp cải thiện: $skillNames.');
    }

    // Explain what mistakes it fixes
    if (drill.fixesMistakes.isNotEmpty) {
      final mistakeNames = drill.fixesMistakes
          .map((m) => mistakeNodes[m]?.nameVi ?? m)
          .join(', ');
      parts.add('Drill sửa các lỗi: $mistakeNames.');
    }

    // Explain what causes it addresses
    if (drill.fixesCauses.isNotEmpty) {
      final causeNames = drill.fixesCauses
          .map((c) => causeNodes[c]?.nameVi ?? c)
          .join(', ');
      parts.add('Drill khắc phục nguyên nhân: $causeNames.');
    }

    return parts.join(' ');
  }

  // ========================================================================
  // DECISION ENGINE QUERIES - Phase 5C
  // ========================================================================

  /// Query: Get situation by id
  SituationNode? getSituation(String id) => situationNodes[id];

  /// Query: Get tactic by id
  TacticNode? getTactic(String id) => tacticNodes[id];

  /// Query: Get tactics for a situation
  List<TacticNode> getTacticsForSituation(String situationId) {
    final situation = situationNodes[situationId];
    if (situation == null) return [];
    return situation.recommendedTactics
        .map((id) => tacticNodes[id])
        .whereType<TacticNode>()
        .toList();
  }

  /// Query: Get tactics to avoid for a situation
  List<TacticNode> getTacticsToAvoid(String situationId) {
    final situation = situationNodes[situationId];
    if (situation == null) return [];
    return situation.avoidTactics
        .map((id) => tacticNodes[id])
        .whereType<TacticNode>()
        .toList();
  }

  /// Query: Get tactics by category
  List<TacticNode> getTacticsByCategory(TacticCategory category) {
    return tacticNodes.values
        .where((t) => t.category == category)
        .toList();
  }

  /// Query: Get tactics by required skill
  List<TacticNode> getTacticsRequiringSkill(String skillId) {
    return tacticNodes.values
        .where((t) => t.requiredSkills.contains(skillId))
        .toList();
  }

  /// Query: Make tactical decision for a situation
  /// Returns DecisionResult with reasoning
  DecisionResult? makeDecision({
    required String situationId,
    required List<String> playerSkills,
    int maxRiskLevel = 2, // 0=low, 1=medium, 2=high
  }) {
    final situation = situationNodes[situationId];
    if (situation == null) return null;

    // Get applicable tactics
    var tactics = getTacticsForSituation(situationId);

    // Filter by player skills
    tactics = tactics.where((t) => t.canExecute(playerSkills)).toList();

    // Filter by risk level
    tactics = tactics.where((t) => t.riskProfile.riskLevel.index <= maxRiskLevel).toList();

    if (tactics.isEmpty) return null;

    // Sort by priority (higher = better) and difficulty (lower = easier)
    tactics.sort((a, b) {
      final priorityCompare = b.category.index.compareTo(a.category.index);
      if (priorityCompare != 0) return priorityCompare;
      return a.difficulty.index.compareTo(b.difficulty.index);
    });

    final bestTactic = tactics.first;

    // Find the decision rule
    final rule = decisionRules.firstWhere(
      (r) => r.situationId == situationId && r.tacticId == bestTactic.id,
      orElse: () => DecisionRule(
        id: 'default',
        situationId: situationId,
        tacticId: bestTactic.id,
        reason: 'Phù hợp với tình huống và kỹ năng của bạn.',
        confidence: DecisionConfidence.medium,
      ),
    );

    // Get alternatives
    final alternatives = tactics.skip(1).take(2).toList();

    return DecisionResult(
      situation: situation,
      tactic: bestTactic,
      rule: rule,
      alternatives: alternatives,
      reasoning: _buildDecisionReasoning(situation, bestTactic, rule),
    );
  }

  String _buildDecisionReasoning(
    SituationNode situation,
    TacticNode tactic,
    DecisionRule rule,
  ) {
    return '${rule.reason} Tactic ${tactic.nameVi} phù hợp cho ${situation.nameVi}.';
  }

  /// Query: Get all decision rules for a situation
  List<DecisionRule> getDecisionRulesForSituation(String situationId) {
    return decisionRules
        .where((r) => r.situationId == situationId)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Query: Explain why a tactic is recommended for a situation
  String explainTacticDecision(String situationId, String tacticId) {
    final situation = situationNodes[situationId];
    final tactic = tacticNodes[tacticId];

    if (situation == null || tactic == null) {
      return 'Không có thông tin.';
    }

    final rule = decisionRules.firstWhere(
      (r) => r.situationId == situationId && r.tacticId == tacticId,
      orElse: () => DecisionRule(
        id: 'none',
        situationId: situationId,
        tacticId: tacticId,
        reason: 'Phù hợp với tình huống.',
        confidence: DecisionConfidence.low,
      ),
    );

    return '''
Tại sao nên dùng ${tactic.nameVi}?

${rule.reason}

Rủi ro: ${tactic.riskProfile.riskLevel.label}
${tactic.tips.isNotEmpty ? 'Lưu ý: ${tactic.tips.first}' : ''}
''';
  }

  /// Get the knowledge graph summary
  KnowledgeGraphSummary get summary => KnowledgeGraphSummary(
    drillCount: drillNodes.length,
    skillCount: skillNodes.length,
    mistakeCount: mistakeNodes.length,
    observationCount: observationNodes.length,
    causeCount: causeNodes.length,
    situationCount: situationNodes.length,
    tacticCount: tacticNodes.length,
    decisionRuleCount: decisionRules.length,
  );
}

/// Knowledge graph summary
class KnowledgeGraphSummary {
  final int drillCount;
  final int skillCount;
  final int mistakeCount;
  final int observationCount;
  final int causeCount;
  final int situationCount;
  final int tacticCount;
  final int decisionRuleCount;

  KnowledgeGraphSummary({
    required this.drillCount,
    required this.skillCount,
    required this.mistakeCount,
    required this.observationCount,
    required this.causeCount,
    required this.situationCount,
    required this.tacticCount,
    required this.decisionRuleCount,
  });
}

/// Reasoning chain result - Coach AI's explanation structure
class ReasoningChain {
  final List<ObservationNode> observations;
  final List<MistakeNode> mistakes;
  final List<CauseNode> causes;
  final List<DrillNode> drills;
  final String targetSkill;

  ReasoningChain({
    required this.observations,
    required this.mistakes,
    required this.causes,
    required this.drills,
    required this.targetSkill,
  });

  /// Generate full explanation in Vietnamese
  String toExplanation() {
    final parts = <String>[];

    // Observation summary
    if (observations.isNotEmpty) {
      final obsNames = observations.map((o) => o.nameVi).join(', ');
      parts.add('Mình nhận thấy: $obsNames.');
    }

    // Mistake identification
    if (mistakes.isNotEmpty) {
      final mistakeNames = mistakes.map((m) => m.nameVi).join(', ');
      parts.add('Điều này cho thấy bạn có thể đang mắc lỗi: $mistakeNames.');
    }

    // Cause analysis
    if (causes.isNotEmpty) {
      final causeNames = causes.map((c) => c.nameVi).join(', ');
      parts.add('Nguyên nhân có thể là: $causeNames.');
    }

    // Recommendation
    if (drills.isNotEmpty) {
      final drillNames = drills.map((d) => d.nameVi).join(', ');
      parts.add('Mình khuyên bạn nên tập: $drillNames.');
    }

    return parts.join(' ');
  }

  /// Check if chain is complete enough for recommendation
  bool get isComplete =>
      observations.isNotEmpty &&
      mistakes.isNotEmpty &&
      causes.isNotEmpty &&
      drills.isNotEmpty;

  /// Get confidence level based on chain completeness
  ReasoningConfidence get confidence {
    if (isComplete) return ReasoningConfidence.high;
    if (drills.isNotEmpty && mistakes.isNotEmpty) return ReasoningConfidence.medium;
    if (mistakes.isNotEmpty) return ReasoningConfidence.low;
    return ReasoningConfidence.insufficient;
  }
}

enum ReasoningConfidence {
  insufficient,
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case ReasoningConfidence.insufficient:
        return 'Chưa đủ dữ liệu';
      case ReasoningConfidence.low:
        return 'Ít tự tin';
      case ReasoningConfidence.medium:
        return 'Tự tin';
      case ReasoningConfidence.high:
        return 'Rất tự tin';
    }
  }
}
