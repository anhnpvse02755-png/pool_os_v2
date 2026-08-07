// ============================================================================
// DECISION RULE - Knowledge Graph Component
// Coach AI reasoning rules for tactical decisions
// ============================================================================

import 'situation_node.dart';
import 'tactic_node.dart';

/// Decision rule - When Coach recommends a tactic
class DecisionRule {
  final String id;
  final String situationId;
  final String tacticId;

  /// Why this tactic is recommended
  final String reason;

  /// Why NOT to use an alternative
  final String? alternativeReason;

  /// Confidence level
  final DecisionConfidence confidence;

  /// Priority (higher = more important)
  final int priority;

  /// Alternative tactic if this one fails
  final String? alternativeTacticId;

  const DecisionRule({
    required this.id,
    required this.situationId,
    required this.tacticId,
    required this.reason,
    this.alternativeReason,
    this.confidence = DecisionConfidence.medium,
    this.priority = 1,
    this.alternativeTacticId,
  });

  /// Generate explanation for why this tactic
  String explain({
    required String situationName,
    required String tacticName,
  }) {
    return '$reason: $situationName → $tacticName';
  }
}

/// Decision confidence level
enum DecisionConfidence {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case DecisionConfidence.low:
        return 'Ít tự tin';
      case DecisionConfidence.medium:
        return 'Tự tin';
      case DecisionConfidence.high:
        return 'Rất tự tin';
    }
  }
}

/// Decision result - Coach AI's tactical decision
class DecisionResult {
  final SituationNode situation;
  final TacticNode tactic;
  final DecisionRule rule;
  final List<TacticNode> alternatives;
  final String reasoning;

  DecisionResult({
    required this.situation,
    required this.tactic,
    required this.rule,
    this.alternatives = const [],
    required this.reasoning,
  });

  /// Generate full explanation
  String toExplanation() {
    final parts = <String>[];

    parts.add('Tình huống: ${situation.nameVi}.');
    parts.add('Quyết định: ${rule.reason}');
    parts.add('Chiến thuật: ${tactic.nameVi}.');
    parts.add('Rủi ro: ${tactic.riskProfile.riskLevel.label}.');

    if (alternatives.isNotEmpty) {
      final altNames = alternatives.map((t) => t.nameVi).join(', ');
      parts.add('Phương án khác: $altNames.');
    }

    return parts.join(' ');
  }

  /// Generate Coach-style explanation
  String toCoachExplanation() {
    return '''
Mình khuyên bạn nên ${tactic.nameVi} trong tình huống này vì:
${rule.reason}.

${tactic.tips.isNotEmpty ? 'Lưu ý: ${tactic.tips.first}' : ''}

${rule.alternativeTacticId != null && alternatives.isNotEmpty ? 'Nếu không thể, hãy thử ${alternatives.first.nameVi}.' : ''}
''';
  }
}
