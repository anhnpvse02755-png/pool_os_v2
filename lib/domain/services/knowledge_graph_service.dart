import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../data/repositories/cache_repository.dart';
import '../../data/models/knowledge_node.dart';

/// Knowledge graph service — models the article prerequisite DAG and
/// powers navigation + visualization.
///
/// Day 2A: depends on [ICacheRepository]. Does NOT import LocalStorageService.
class KnowledgeGraphService {
  KnowledgeGraphService(this._cache);
  final ICacheRepository _cache;
  static const _kCacheKey = 'poolos_v2.knowledge_graph_cache';

  Future<void> load() async {
    final cached = _cache.getString(_kCacheKey);
    if (cached != null && cached.isNotEmpty) return;
    try {
      final raw = await rootBundle.loadString('assets/knowledge/knowledge.json');
      await _cache.setString(_kCacheKey, raw);
    } catch (_) {}
  }

  Future<List<KnowledgeNode>> all() async {
    await load();
    final raw = _cache.getString(_kCacheKey);
    if (raw == null || raw.isEmpty) return [];
    final json = jsonDecode(raw);
    final list = (json is List)
        ? json
        : (json is Map<String, dynamic>
            ? (json['articles'] as List? ?? const [])
            : const []);
    return list
        .cast<Map<String, dynamic>>()
        .map(KnowledgeNode.fromJson)
        .toList();
  }

  /// Articles that the player has not yet finished prerequisites for.
  Future<List<KnowledgeNode>> nextReadable(Set<String> readSlugs) async {
    final all = await this.all();
    return all
        .where((n) => !readSlugs.contains(n.slug))
        .where((n) => n.prerequisites.every(readSlugs.contains))
        .toList();
  }

  /// All prerequisites of a slug in topological order (depth first).
  Future<List<KnowledgeNode>> prerequisiteChain(String slug) async {
    final all = await this.all();
    final map = {for (final n in all) n.slug: n};
    final result = <KnowledgeNode>[];
    void dfs(String s, Set<String> seen) {
      if (seen.contains(s)) return;
      seen.add(s);
      final node = map[s];
      if (node == null) return;
      for (final p in node.prerequisites) {
        dfs(p, seen);
      }
      result.add(node);
    }
    dfs(slug, {});
    return result;
  }

  /// Returns a list of edges (from, to) — read prerequisite to enable dependent.
  Future<List<List<String>>> edges() async {
    final all = await this.all();
    final edges = <List<String>>[];
    for (final n in all) {
      for (final p in n.prerequisites) {
        edges.add([p, n.slug]);
      }
    }
    return edges;
  }
}