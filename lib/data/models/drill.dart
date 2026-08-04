/// Tier axis — derived from difficulty but exposed as a tier label for UI.
enum DrillTier { foundation, intermediate, advanced, master }

DrillTier tierFor(int difficulty) {
  if (difficulty <= 1) return DrillTier.foundation;
  if (difficulty <= 3) return DrillTier.intermediate;
  if (difficulty <= 4) return DrillTier.advanced;
  return DrillTier.master;
}

/// Shot-type axis — single tag per drill but can be multi.
class DrillAxes {
  final String code;
  final String name;
  final String nameVi;
  final String categoryId;
  final int difficulty;
  final String difficultyLevel;
  final int estimatedMinutes;
  final String description;
  final List<String> equipment;
  final String setupInstructions;
  final List<String> executionSteps;
  final String objective;
  final String successCriteria;
  final List<String> commonMistakes;
  final String coachingTips;
  final List<String> relatedKnowledge;
  // Phase B additions (optional, defaulted)
  final DrillTier tier;
  final List<String> tags;
  final int tableSize; // 7 | 8 | 9 (default 9)
  final String gameContext; // 8-ball | 9-ball | 10-ball | straight
  final List<String> relatedDrills;

  const DrillAxes({
    required this.code,
    required this.name,
    required this.nameVi,
    required this.categoryId,
    required this.difficulty,
    required this.difficultyLevel,
    required this.estimatedMinutes,
    required this.description,
    required this.equipment,
    required this.setupInstructions,
    required this.executionSteps,
    required this.objective,
    required this.successCriteria,
    required this.commonMistakes,
    required this.coachingTips,
    required this.relatedKnowledge,
    this.tier = DrillTier.foundation,
    this.tags = const [],
    this.tableSize = 9,
    this.gameContext = '8-ball',
    this.relatedDrills = const [],
  });

  factory DrillAxes.fromJson(Map<String, dynamic> j) {
    final difficulty = j['difficulty'] as int? ?? 1;
    final categoryId = j['categoryId'] as String? ?? 'fundamentals';
    return DrillAxes(
      code: j['code'] as String,
      name: j['nameEn'] as String? ?? j['name'] as String? ?? '',
      nameVi: j['nameVi'] as String? ?? '',
      categoryId: categoryId,
      difficulty: difficulty,
      difficultyLevel: j['difficultyLevel'] as String? ?? 'Beginner',
      estimatedMinutes: j['estimatedMinutes'] as int? ?? 15,
      description: j['description'] as String? ?? '',
      equipment: (j['equipment'] as List?)?.cast<String>() ?? const [],
      setupInstructions: j['setupInstructions'] as String? ?? '',
      executionSteps:
          (j['executionSteps'] as List?)?.cast<String>() ?? const [],
      objective: j['objective'] as String? ?? '',
      successCriteria: j['successCriteria'] as String? ?? '',
      commonMistakes:
          (j['commonMistakes'] as List?)?.cast<String>() ?? const [],
      coachingTips: j['coachingTips'] as String? ?? '',
      relatedKnowledge:
          (j['relatedKnowledge'] as List?)?.cast<String>() ?? const [],
      tier: j['tier'] is String
          ? DrillTier.values.firstWhere(
              (t) => t.name == j['tier'],
              orElse: () => tierFor(difficulty),
            )
          : tierFor(difficulty),
      tags: (j['tags'] as List?)?.cast<String>() ??
          _inferTags(categoryId, j),
      tableSize: j['tableSize'] as int? ?? 9,
      gameContext: j['gameContext'] as String? ?? '8-ball',
      relatedDrills:
          (j['relatedDrills'] as List?)?.cast<String>() ?? const [],
    );
  }

  static List<String> _inferTags(String categoryId, Map<String, dynamic> j) {
    final tags = <String>{};
    // category axis
    if (categoryId.isNotEmpty) tags.add(categoryId);
    // keyword-inference from objective / description
    final text =
        '${j['objective'] ?? ''} ${j['description'] ?? ''} ${j['nameVi'] ?? ''} ${j['nameEn'] ?? ''}'
            .toLowerCase();
    void addIf(String tag, String key) {
      if (text.contains(key)) tags.add(tag);
    }
    addIf('cut', 'cắt');
    addIf('bank', 'bank');
    addIf('kick', 'kick');
    addIf('combo', 'combo');
    addIf('jump', 'jump');
    addIf('carom', 'carom');
    addIf('safety', 'safety');
    addIf('pattern', 'pattern');
    addIf('position', 'position');
    addIf('cue_ball_control', 'cue ball');
    return tags.toList();
  }
}