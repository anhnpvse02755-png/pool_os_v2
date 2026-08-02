// ============================================================================
// KNOWLEDGE DATA MODELS - V2
// ============================================================================
// Chuẩn hóa từ V1, sẵn sàng cho Flutter integration

/// Knowledge Item - Đơn vị kiến thức nhỏ nhất
class KnowledgeItem {
  final String id;
  final String slug;
  final String title;
  final String? titleVi; // Tiếng Việt
  final String content;
  final String? contentVi; // Tiếng Việt
  final String categoryId;
  final List<String> tagIds;
  final List<String> aliases;
  final List<String> keywords;
  final DifficultyLevel difficulty;
  final String? imageUrl;
  final List<String> relatedKnowledgeIds;
  final List<String> relatedDrillCodes;
  final String? sourceUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeItem({
    required this.id,
    required this.slug,
    required this.title,
    this.titleVi,
    required this.content,
    this.contentVi,
    required this.categoryId,
    this.tagIds = const [],
    this.aliases = const [],
    this.keywords = const [],
    this.difficulty = DifficultyLevel.beginner,
    this.imageUrl,
    this.relatedKnowledgeIds = const [],
    this.relatedDrillCodes = const [],
    this.sourceUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Knowledge Category
class KnowledgeCategory {
  final String id;
  final String slug;
  final String name;
  final String? nameVi;
  final String? description;
  final String? icon;
  final int order;
  final List<String> knowledgeIds;

  const KnowledgeCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.nameVi,
    this.description,
    this.icon,
    this.order = 0,
    this.knowledgeIds = const [],
  });
}

/// Knowledge Tag
class KnowledgeTag {
  final String id;
  final String name;
  final String? nameVi;
  final String? color;

  const KnowledgeTag({
    required this.id,
    required this.name,
    this.nameVi,
    this.color,
  });
}

/// Difficulty Level
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Glossary Term
class GlossaryTerm {
  final String id;
  final String term;
  final String? termVi;
  final String definition;
  final String? definitionVi;
  final String? category;
  final List<String> relatedTermIds;

  const GlossaryTerm({
    required this.id,
    required this.term,
    this.termVi,
    required this.definition,
    this.definitionVi,
    this.category,
    this.relatedTermIds = const [],
  });
}

/// Drill - Knowledge Mapping (nhiều-nhiều)
class DrillKnowledgeMapping {
  final String drillCode;
  final int drillLevel;
  final List<String> knowledgeIds;
  final List<String> commonMistakes;
  final String? tips;

  const DrillKnowledgeMapping({
    required this.drillCode,
    required this.drillLevel,
    required this.knowledgeIds,
    this.commonMistakes = const [],
    this.tips,
  });
}

// ============================================================================
// VÍ DỤ DATA
// ============================================================================

/// Ví dụ: Stop Shot Knowledge
const stopShotKnowledge = KnowledgeItem(
  id: 'kn_stopshot_001',
  slug: 'stop-shot',
  title: 'Stop Shot',
  titleVi: 'Cú Dừng Bóng',
  content: '''
A stop shot is a shot where the cue ball stops immediately after contact with the object ball.

Key Points:
- Strike the cue ball at center
- Follow through straight
- Use moderate speed

Common Mistakes:
- Hitting too hard
- Not following through
- Incorrect cue elevation
''',
  contentVi: '''
Stop shot là cú đánh mà bi trắng dừng lại ngay sau khi chạm bi đích.

Điểm quan trọng:
- Đánh bi trắng ở tâm
- Theo qua thẳng
- Dùng lực vừa phải

Lỗi thường gặp:
- Đánh quá mạnh
- Không theo qua
- Nâng cue không đúng
''',
  categoryId: 'cat_shotmaking',
  tagIds: ['tag_basic', 'tag_shotmaking', 'tag_cueball'],
  aliases: ['stop', 'dung', 'stop ball', 'halt shot'],
  keywords: ['stop shot', 'cue ball control', 'center ball', 'follow through'],
  difficulty: DifficultyLevel.beginner,
  relatedKnowledgeIds: ['kn_follow_001', 'kn_draw_001', 'kn_bridge_001'],
  relatedDrillCodes: ['STOP_LV1', 'STOP_LV2', 'STOP_LV3'],
  createdAt: null,
  updatedAt: null,
);

/// Ví dụ: Drill - Knowledge Mapping
const stopShotL2Mapping = DrillKnowledgeMapping(
  drillCode: 'STOP',
  drillLevel: 2,
  knowledgeIds: [
    'kn_stopshot_001',
    'kn_bridgelocked_001',
    'kn_followthrough_001',
    'kn_speedcontrol_001',
  ],
  commonMistakes: [
    'Pulling the cue back too far',
    'Jerky follow through',
    'Eyes not on contact point',
  ],
  tips: 'Focus on a smooth, pendulum-like motion.',
);

/// Ví dụ: Category
const shotmakingCategory = KnowledgeCategory(
  id: 'cat_shotmaking',
  slug: 'shot-making',
  name: 'Shot Making',
  nameVi: 'Kỹ Thuật Đánh',
  description: 'Fundamental shot-making techniques',
  icon: 'target',
  order: 1,
  knowledgeIds: ['kn_stopshot_001', 'kn_follow_001', 'kn_draw_001'],
);
