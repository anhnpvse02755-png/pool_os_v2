// ============================================================================
// schema_mapper.dart — V1 article → V2 article (real mapping)
// ============================================================================
//
// Sprint 1, Commit 2.
//
// Maps V1 article JSON into the V2 article shape used by
// assets/knowledge/knowledge.json. The V2 schema is documented in
// SPRINT_1_KNOWLEDGE_PARITY.md §1.2.
//
// Pipeline:
//   1. parse V1 JSON.
//   2. derive V2 id + slug via IdMapper.
//   3. derive V2 categoryId via CategoryMapper (skip if unmapped).
//   4. derive V2 tagIds via TagMapper (drop unmapped tags).
//   5. synthesize V2 content markdown from V1 fields (verbatim).
//   6. assemble deterministic ordered map.
//
// Determinism (Section 7):
//   - Map keys are written in canonical order.
//   - Lists are deduped + sorted (where order doesn't matter).
//   - No DateTime.now(). updatedAt from V1 if present, else empty.
// ============================================================================

import 'dart:convert';

import 'category_mapper.dart';
import 'id_mapper.dart';
import 'tag_mapper.dart';
import 'src/migration_dto.dart';

class SchemaMapper {
  /// Maps a parsed V1 article JSON into the V2 article shape.
  ///
  /// Returns null when the V1 article cannot be mapped (no V2
  /// category mapping for its category).
  ///
  /// Throws [SchemaMapperException] for malformed V1 input.
  static Map<String, dynamic>? map(V1Article v1, Map<String, dynamic> v1Json) {
    final id = v1.id;
    if (!IdMapper.isValidV1Id(id)) {
      throw SchemaMapperException(
        'Invalid V1 id: "$id" (must contain dot, lowercase only)',
      );
    }

    final v1Category = (v1Json['category'] as String?)?.toLowerCase().trim() ?? '';
    final v2CategoryId = CategoryMapper.map(v1Category);
    if (v2CategoryId == null) {
      return null; // Skip: no V2 mapping for category.
    }

    final slug = IdMapper.deriveSlug(id);

    final v1Tags = (v1Json['tags'] as List<dynamic>?)?.cast<String>() ?? const [];
    final tagResult = TagMapper.mapAll(v1Tags);

    final contentEn = _synthesizeContent(
      title: (v1Json['title'] as String?) ?? '',
      summary: (v1Json['summary'] as String?) ?? '',
      purpose: (v1Json['purpose'] as String?) ?? '',
      setup: ((v1Json['setup'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      execution: ((v1Json['execution'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      successCriteria:
          ((v1Json['successCriteria'] as List<dynamic>?) ?? const [])
              .map((e) => e.toString())
              .toList(),
      failureCriteria:
          ((v1Json['failureCriteria'] as List<dynamic>?) ?? const [])
              .map((e) => e.toString())
              .toList(),
      commonMistakes: v1Json['commonMistakes'] as List<dynamic>? ?? const [],
      sources: ((v1Json['sources'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      language: 'en',
    );

    final contentVi = _synthesizeContent(
      title: (v1Json['titleVi'] as String?) ?? '',
      summary: (v1Json['summaryVi'] as String?) ?? '',
      purpose: (v1Json['purposeVi'] as String?) ?? '',
      setup: const [],
      execution: const [],
      successCriteria: const [],
      failureCriteria: const [],
      commonMistakes: const [],
      sources: const [],
      language: 'vi',
    );

    final aliases = <String>{
      ...((v1Json['keywords'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString().toLowerCase()),
      ..._collectAliasesFromLocalization(v1Json),
    }.toList()
      ..sort();

    final relatedKnowledgeIds = ((v1Json['relatedKnowledge'] as List<dynamic>?)
                ?? const [])
        .map((e) => (e as Map<String, dynamic>)['id'] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    final estLearningMinutes =
        (v1Json['estLearningMinutes'] as num?)?.toInt() ?? 5;

    final difficulty = (v1Json['difficulty'] as String?) ?? 'beginner';

    final keywords = ((v1Json['keywords'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList()
      ..sort();

    final sources = ((v1Json['sources'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList()
      ..sort();

    // Deterministic key order (canonical).
    final out = <String, dynamic>{
      'id': id,
      'slug': slug,
      'title': (v1Json['title'] as String?) ?? '',
      'titleVi': (v1Json['titleVi'] as String?) ?? '',
      'content': contentEn,
      'contentVi': contentVi,
      'categoryId': v2CategoryId,
      'tagIds': tagResult.ids,
      'difficulty': difficulty,
      'aliases': aliases,
      'keywords': keywords,
      'relatedKnowledgeIds': relatedKnowledgeIds,
      'relatedDrillCodes': <String>[],
      'readingTimeMinutes': estLearningMinutes,
      'media': v1Json['media'] ?? const {},
      'sources': sources,
    };

    // Sanity: ensure JSON-encodable.
    jsonEncode(out);
    return out;
  }

  static String _synthesizeContent({
    required String title,
    required String summary,
    required String purpose,
    required List<String> setup,
    required List<String> execution,
    required List<String> successCriteria,
    required List<String> failureCriteria,
    required List<dynamic> commonMistakes,
    required List<String> sources,
    required String language,
  }) {
    final buf = StringBuffer();
    if (title.isNotEmpty) {
      buf.writeln('# $title');
      buf.writeln();
    }
    if (summary.isNotEmpty) {
      buf.writeln(summary);
      buf.writeln();
    }
    if (purpose.isNotEmpty) {
      buf.writeln('## Purpose');
      buf.writeln();
      buf.writeln(purpose);
      buf.writeln();
    }
    if (setup.isNotEmpty) {
      buf.writeln('## Setup');
      buf.writeln();
      for (var i = 0; i < setup.length; i++) {
        buf.writeln('${i + 1}. ${setup[i]}');
      }
      buf.writeln();
    }
    if (execution.isNotEmpty) {
      buf.writeln('## Execution');
      buf.writeln();
      for (var i = 0; i < execution.length; i++) {
        buf.writeln('${i + 1}. ${execution[i]}');
      }
      buf.writeln();
    }
    if (successCriteria.isNotEmpty) {
      buf.writeln('## Success Criteria');
      buf.writeln();
      for (final c in successCriteria) {
        buf.writeln('- [ ] $c');
      }
      buf.writeln();
    }
    if (failureCriteria.isNotEmpty) {
      buf.writeln('## Failure Criteria');
      buf.writeln();
      for (final c in failureCriteria) {
        buf.writeln('- $c');
      }
      buf.writeln();
    }
    if (commonMistakes.isNotEmpty) {
      buf.writeln('## Common Mistakes');
      buf.writeln();
      for (final m in commonMistakes) {
        if (m is Map<String, dynamic>) {
          final mistake = language == 'vi'
              ? (m['mistakeVi'] as String? ?? m['mistake'] as String? ?? '')
              : (m['mistake'] as String? ?? '');
          final correction = language == 'vi'
              ? (m['correctionVi'] as String? ??
                  m['correction'] as String? ??
                  '')
              : (m['correction'] as String? ?? '');
          if (mistake.isNotEmpty) buf.writeln('- **$mistake**');
          if (correction.isNotEmpty) buf.writeln('  - Fix: $correction');
        }
      }
      buf.writeln();
    }
    if (sources.isNotEmpty) {
      buf.writeln('## Sources');
      buf.writeln();
      for (final s in sources) {
        buf.writeln('- $s');
      }
      buf.writeln();
    }
    return buf.toString().trimRight();
  }

  static List<String> _collectAliasesFromLocalization(
      Map<String, dynamic> v1Json) {
    final out = <String>[];
    final loc = v1Json['localization'];
    if (loc is Map<String, dynamic>) {
      final club = loc['club_names'];
      if (club is List) {
        out.addAll(club.map((e) => e.toString().toLowerCase()));
      }
      final coach = loc['coach_names'];
      if (coach is List) {
        out.addAll(coach.map((e) => e.toString().toLowerCase()));
      }
      final slang = loc['slang'];
      if (slang is List) {
        out.addAll(slang.map((e) => e.toString().toLowerCase()));
      }
    }
    final sa = v1Json['searchAliases'];
    if (sa is Map<String, dynamic>) {
      final vi = sa['vi'];
      if (vi is List) {
        out.addAll(vi.map((e) => e.toString().toLowerCase()));
      }
    }
    return out;
  }
}

class SchemaMapperException implements Exception {
  SchemaMapperException(this.message);
  final String message;
  @override
  String toString() => 'SchemaMapperException: $message';
}