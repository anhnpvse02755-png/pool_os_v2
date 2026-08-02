// ============================================================================
// KNOWLEDGE SERVICE - Flutter Integration
// ============================================================================

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/knowledge_models.dart';

/// Service để load và query Knowledge data
class KnowledgeService {
  // Cache
  final Map<String, KnowledgeItem> _knowledgeCache = {};
  final Map<String, KnowledgeCategory> _categoryCache = {};
  final Map<String, KnowledgeTag> _tagCache = {};
  final Map<String, DrillKnowledgeMapping> _drillMappingCache = {};

  bool _initialized = false;

  /// Initialize - load tất cả data
  Future<void> initialize() async {
    if (_initialized) return;

    // Load knowledge items
    await _loadKnowledgeItems();

    // Load categories
    await _loadCategories();

    // Load tags
    await _loadTags();

    // Load drill mappings
    await _loadDrillMappings();

    _initialized = true;
  }

  Future<void> _loadKnowledgeItems() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/knowledge/knowledge.json');
      final List<dynamic> items = json.decode(jsonString);

      for (var item in items) {
        final knowledge = KnowledgeItem.fromJson(item);
        _knowledgeCache[knowledge.id] = knowledge;
      }
    } catch (e) {
      // Data chưa có, sẽ được thêm sau
    }
  }

  Future<void> _loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/knowledge/categories.json');
      final List<dynamic> items = json.decode(jsonString);

      for (var item in items) {
        final category = KnowledgeCategory.fromJson(item);
        _categoryCache[category.id] = category;
      }
    } catch (e) {
      // Data chưa có
    }
  }

  Future<void> _loadTags() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/knowledge/tags.json');
      final List<dynamic> items = json.decode(jsonString);

      for (var item in items) {
        final tag = KnowledgeTag.fromJson(item);
        _tagCache[tag.id] = tag;
      }
    } catch (e) {
      // Data chưa có
    }
  }

  Future<void> _loadDrillMappings() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/knowledge/drill_mapping.json');
      final Map<String, dynamic> mappings = json.decode(jsonString);

      mappings.forEach((key, value) {
        _drillMappingCache[key] = DrillKnowledgeMapping.fromJson(value);
      });
    } catch (e) {
      // Data chưa có
    }
  }

  // =========================================================================
  // QUERY METHODS
  // =========================================================================

  /// Get all knowledge items
  List<KnowledgeItem> getAllKnowledge() {
    return _knowledgeCache.values.toList();
  }

  /// Get knowledge by ID
  KnowledgeItem? getKnowledgeById(String id) {
    return _knowledgeCache[id];
  }

  /// Get knowledge by slug
  KnowledgeItem? getKnowledgeBySlug(String slug) {
    return _knowledgeCache.values.firstWhere(
      (k) => k.slug == slug,
      orElse: () => null as dynamic,
    );
  }

  /// Get knowledge by category
  List<KnowledgeItem> getKnowledgeByCategory(String categoryId) {
    return _knowledgeCache.values
        .where((k) => k.categoryId == categoryId)
        .toList();
  }

  /// Get knowledge by tag
  List<KnowledgeItem> getKnowledgeByTag(String tagId) {
    return _knowledgeCache.values
        .where((k) => k.tagIds.contains(tagId))
        .toList();
  }

  /// Search knowledge
  List<KnowledgeItem> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _knowledgeCache.values.where((k) {
      return k.title.toLowerCase().contains(lowerQuery) ||
          k.content.toLowerCase().contains(lowerQuery) ||
          k.aliases.any((a) => a.toLowerCase().contains(lowerQuery)) ||
          k.keywords.any((k) => k.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get all categories
  List<KnowledgeCategory> getAllCategories() {
    return _categoryCache.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Get category by ID
  KnowledgeCategory? getCategoryById(String id) {
    return _categoryCache[id];
  }

  /// Get all tags
  List<KnowledgeTag> getAllTags() {
    return _tagCache.values.toList();
  }

  /// Get drill → knowledge mapping
  DrillKnowledgeMapping? getDrillKnowledgeMapping(String drillCode, int level) {
    return _drillMappingCache['${drillCode}_LV$level'];
  }

  /// Get knowledge for a drill
  List<KnowledgeItem> getKnowledgeForDrill(String drillCode, int level) {
    final mapping = getDrillKnowledgeMapping(drillCode, level);
    if (mapping == null) return [];

    return mapping.knowledgeIds
        .map((id) => getKnowledgeById(id))
        .where((k) => k != null)
        .cast<KnowledgeItem>()
        .toList();
  }

  /// Get drills for a knowledge item
  List<String> getDrillsForKnowledge(String knowledgeId) {
    return _knowledgeCache[knowledgeId]?.relatedDrillCodes ?? [];
  }
}

// Singleton instance
final knowledgeService = KnowledgeService();
