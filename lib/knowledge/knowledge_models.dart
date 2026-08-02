// ============================================================================
// KNOWLEDGE MODELS - Flutter Integration
// ============================================================================

/// Knowledge Item
class KnowledgeItem {
  final String id;
  final String slug;
  final String title;
  final String? titleVi;
  final String content;
  final String? contentVi;
  final String categoryId;
  final List<String> tagIds;
  final List<String> aliases;
  final List<String> keywords;
  final DifficultyLevel difficulty;
  final String? imageUrl;
  final List<String> relatedKnowledgeIds;
  final List<String> relatedDrillCodes;

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
  });

  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      titleVi: json['titleVi'],
      content: json['content'],
      contentVi: json['contentVi'],
      categoryId: json['categoryId'],
      tagIds: List<String>.from(json['tagIds'] ?? []),
      aliases: List<String>.from(json['aliases'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      imageUrl: json['imageUrl'],
      relatedKnowledgeIds: List<String>.from(json['relatedKnowledgeIds'] ?? []),
      relatedDrillCodes: List<String>.from(json['relatedDrillCodes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'title': title,
    'titleVi': titleVi,
    'content': content,
    'contentVi': contentVi,
    'categoryId': categoryId,
    'tagIds': tagIds,
    'aliases': aliases,
    'keywords': keywords,
    'difficulty': difficulty.name,
    'imageUrl': imageUrl,
    'relatedKnowledgeIds': relatedKnowledgeIds,
    'relatedDrillCodes': relatedDrillCodes,
  };
}

/// Difficulty Level
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get label {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Cơ bản';
      case DifficultyLevel.intermediate:
        return 'Trung bình';
      case DifficultyLevel.advanced:
        return 'Nâng cao';
      case DifficultyLevel.expert:
        return 'Chuyên gia';
    }
  }
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

  const KnowledgeCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.nameVi,
    this.description,
    this.icon,
    this.order = 0,
  });

  factory KnowledgeCategory.fromJson(Map<String, dynamic> json) {
    return KnowledgeCategory(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      nameVi: json['nameVi'],
      description: json['description'],
      icon: json['icon'],
      order: json['order'] ?? 0,
    );
  }
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

  factory KnowledgeTag.fromJson(Map<String, dynamic> json) {
    return KnowledgeTag(
      id: json['id'],
      name: json['name'],
      nameVi: json['nameVi'],
      color: json['color'],
    );
  }
}

/// Glossary Term
class GlossaryTerm {
  final String id;
  final String term;
  final String? termVi;
  final String definition;
  final String? definitionVi;
  final String? category;

  const GlossaryTerm({
    required this.id,
    required this.term,
    this.termVi,
    required this.definition,
    this.definitionVi,
    this.category,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) {
    return GlossaryTerm(
      id: json['id'],
      term: json['term'],
      termVi: json['termVi'],
      definition: json['definition'],
      definitionVi: json['definitionVi'],
      category: json['category'],
    );
  }
}

/// Drill - Knowledge Mapping
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

  factory DrillKnowledgeMapping.fromJson(Map<String, dynamic> json) {
    return DrillKnowledgeMapping(
      drillCode: json['drillCode'],
      drillLevel: json['drillLevel'],
      knowledgeIds: List<String>.from(json['knowledgeIds'] ?? []),
      commonMistakes: List<String>.from(json['commonMistakes'] ?? []),
      tips: json['tips'],
    );
  }
}
