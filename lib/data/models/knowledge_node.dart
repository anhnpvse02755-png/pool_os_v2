/// A single article in the knowledge graph with prerequisite links.
class KnowledgeNode {
  final String slug;
  final String title;
  final String category;
  final String difficulty; // 'beginner' | 'intermediate' | 'advanced' | 'master'
  final List<String> prerequisites;
  final List<String> relatedDrills;
  final List<String> tags;

  const KnowledgeNode({
    required this.slug,
    required this.title,
    required this.category,
    required this.difficulty,
    this.prerequisites = const [],
    this.relatedDrills = const [],
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'category': category,
        'difficulty': difficulty,
        'prerequisites': prerequisites,
        'relatedDrills': relatedDrills,
        'tags': tags,
      };

  factory KnowledgeNode.fromJson(Map<String, dynamic> j) => KnowledgeNode(
        slug: j['slug'] as String,
        title: j['title'] as String? ?? '',
        category: j['category'] as String? ?? 'general',
        difficulty: j['difficulty'] as String? ?? 'beginner',
        prerequisites:
            (j['prerequisites'] as List?)?.cast<String>() ?? const [],
        relatedDrills:
            (j['relatedDrills'] as List?)?.cast<String>() ?? const [],
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
      );
}