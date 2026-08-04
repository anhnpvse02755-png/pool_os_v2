// ============================================================================
// KNOWLEDGE PROVIDER - Riverpod Integration
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/coach_provider.dart';
import 'knowledge_models.dart';
import 'knowledge_data.dart';

/// Knowledge state
class KnowledgeState {
  final List<KnowledgeItem> allKnowledge;
  final List<KnowledgeCategory> categories;
  final List<KnowledgeTag> tags;
  final Map<String, List<String>> drillKnowledgeMap; // drillCode → knowledgeIds
  final bool isLoading;
  final String? error;
  final bool fromAssets;

  const KnowledgeState({
    this.allKnowledge = const [],
    this.categories = const [],
    this.tags = const [],
    this.drillKnowledgeMap = const {},
    this.isLoading = false,
    this.error,
    this.fromAssets = false,
  });

  KnowledgeState copyWith({
    List<KnowledgeItem>? allKnowledge,
    List<KnowledgeCategory>? categories,
    List<KnowledgeTag>? tags,
    Map<String, List<String>>? drillKnowledgeMap,
    bool? isLoading,
    String? error,
    bool? fromAssets,
  }) {
    return KnowledgeState(
      allKnowledge: allKnowledge ?? this.allKnowledge,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      drillKnowledgeMap: drillKnowledgeMap ?? this.drillKnowledgeMap,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      fromAssets: fromAssets ?? this.fromAssets,
    );
  }
}

/// Knowledge Notifier
class KnowledgeNotifier extends StateNotifier<KnowledgeState> {
  KnowledgeNotifier() : super(const KnowledgeState()) {
    _loadData();
  }

  /// Test-only constructor: allows injecting a pre-built state without
  /// triggering asset loading. Used by widget tests via ProviderScope overrides.
  @visibleForTesting
  KnowledgeNotifier.withState(super.initial);

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);

    try {
      final jsonString =
          await rootBundle.loadString('assets/knowledge/knowledge.json');
      final List<dynamic> items = json.decode(jsonString) as List<dynamic>;
      if (items.isNotEmpty) {
        final parsed = items
            .map((e) => KnowledgeItem.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          allKnowledge: parsed,
          categories: knowledgeCategories,
          tags: knowledgeTags,
          drillKnowledgeMap: drillKnowledgeMapping,
          isLoading: false,
          fromAssets: true,
        );
        return;
      }
    } catch (_) {
      // Fall through to fallback below.
    }

    _loadFallback();
  }

  void _loadFallback() {
    state = state.copyWith(
      allKnowledge: knowledgeItems,
      categories: knowledgeCategories,
      tags: knowledgeTags,
      drillKnowledgeMap: drillKnowledgeMapping,
      isLoading: false,
      fromAssets: false,
    );
  }

  /// Get knowledge by ID
  KnowledgeItem? getById(String id) {
    try {
      return state.allKnowledge.firstWhere((k) => k.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get knowledge by slug
  KnowledgeItem? getBySlug(String slug) {
    try {
      return state.allKnowledge.firstWhere((k) => k.slug == slug);
    } catch (_) {
      return null;
    }
  }

  /// Get knowledge by category
  List<KnowledgeItem> getByCategory(String categoryId) {
    return state.allKnowledge
        .where((k) => k.categoryId == categoryId)
        .toList();
  }

  /// Get knowledge for a drill
  List<KnowledgeItem> getKnowledgeForDrill(String drillCode) {
    final knowledgeIds = state.drillKnowledgeMap[drillCode] ?? [];
    return knowledgeIds
        .map((id) => getById(id))
        .where((k) => k != null)
        .cast<KnowledgeItem>()
        .toList();
  }

  /// Search knowledge
  List<KnowledgeItem> search(String query) {
    final lowerQuery = query.toLowerCase();
    return state.allKnowledge.where((k) {
      return k.title.toLowerCase().contains(lowerQuery) ||
          k.content.toLowerCase().contains(lowerQuery) ||
          k.aliases.any((a) => a.toLowerCase().contains(lowerQuery)) ||
          k.keywords.any((kw) => kw.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get category by ID
  KnowledgeCategory? getCategoryById(String id) {
    try {
      return state.categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get tag by ID
  KnowledgeTag? getTagById(String id) {
    try {
      return state.tags.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Provider
final knowledgeProvider =
    StateNotifierProvider<KnowledgeNotifier, KnowledgeState>((ref) {
  return KnowledgeNotifier();
});

/// Current knowledge item provider
final currentKnowledgeProvider = StateProvider<KnowledgeItem?>((ref) => null);

/// Knowledge search provider
final knowledgeSearchProvider = Provider.family<List<KnowledgeItem>, String>((ref, query) {
  ref.watch(knowledgeProvider);
  if (query.isEmpty) return [];

  final notifier = ref.read(knowledgeProvider.notifier);
  return notifier.search(query);
});

/// Knowledge by category provider
final knowledgeByCategoryProvider =
    Provider.family<List<KnowledgeItem>, String>((ref, categoryId) {
  ref.watch(knowledgeProvider);
  final notifier = ref.read(knowledgeProvider.notifier);
  return notifier.getByCategory(categoryId);
});

/// Drill knowledge provider
final drillKnowledgeProvider =
    Provider.family<List<KnowledgeItem>, String>((ref, drillCode) {
  final notifier = ref.read(knowledgeProvider.notifier);
  return notifier.getKnowledgeForDrill(drillCode);
});

/// Knowledge articles recommended for a given LearningPathItem.
///
/// Strategy:
///   1. If the path item declares `knowledgeIds`, resolve them via `getById`.
///   2. Else, look up via the V1/V2 drill-code map with `getKnowledgeForDrill`.
///   3. Else, fall back to articles matching the path item's difficulty string.
///
/// Always caps the result at 2 articles.
final learningKnowledgeProvider =
    Provider.family<List<KnowledgeItem>, LearningPathItem>((ref, pathItem) {
  final notifier = ref.read(knowledgeProvider.notifier);

  // Method 1: explicit knowledgeIds on the path item.
  if (pathItem.knowledgeIds.isNotEmpty) {
    final byId = pathItem.knowledgeIds
        .map(notifier.getById)
        .whereType<KnowledgeItem>()
        .toList();
    if (byId.isNotEmpty) return byId.take(2).toList();
  }

  // Method 2: drillCode → knowledgeIds (V1 and V2 codes both work).
  final byDrill = notifier.getKnowledgeForDrill(pathItem.drillCode);
  if (byDrill.isNotEmpty) return byDrill.take(2).toList();

  // Method 3: fallback by difficulty string.
  final all = ref.watch(knowledgeProvider).allKnowledge;
  final byDifficulty = all
      .where((k) => k.difficulty.name == pathItem.difficulty)
      .take(2)
      .toList();
  return byDifficulty;
});
