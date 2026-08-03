import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/knowledge_node.dart';
import '../../../domain/services/knowledge_graph_service.dart';

/// Knowledge graph visualization — simple 2D layered DAG.
///
/// Nodes are placed top-to-bottom by depth; edges are drawn as connectors.
/// Tapping a node surfaces its prerequisites + drills.
class KnowledgeGraphScreen extends StatefulWidget {
  const KnowledgeGraphScreen({super.key});

  @override
  State<KnowledgeGraphScreen> createState() => _KnowledgeGraphScreenState();
}

class _KnowledgeGraphScreenState extends State<KnowledgeGraphScreen> {
  List<KnowledgeNode> _nodes = [];
  List<List<String>> _edges = [];
  Map<int, List<KnowledgeNode>> _layers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = ProviderScope.containerOf(context, listen: false)
        .read(knowledgeGraphServiceProvider);
    final nodes = await svc.all();
    final edges = await svc.edges();
    final layers = _layerByPrereq(nodes, edges);
    if (!mounted) return;
    setState(() {
      _nodes = nodes;
      _edges = edges;
      _layers = layers;
      _loading = false;
    });
  }

  Map<int, List<KnowledgeNode>> _layerByPrereq(
      List<KnowledgeNode> nodes, List<List<String>> edges) {
    final indegree = {for (final n in nodes) n.slug: 0};
    for (final e in edges) {
      indegree[e[1]] = (indegree[e[1]] ?? 0) + 1;
    }
    final layer = {for (final n in nodes) n.slug: 0};
    bool changed = true;
    int safety = 0;
    while (changed && safety < 100) {
      changed = false;
      safety++;
      for (final e in edges) {
        final candidate = (layer[e[0]] ?? 0) + 1;
        if (candidate > (layer[e[1]] ?? 0)) {
          layer[e[1]] = candidate;
          changed = true;
        }
      }
    }
    final out = <int, List<KnowledgeNode>>{};
    for (final n in nodes) {
      out.putIfAbsent(layer[n.slug] ?? 0, () => []).add(n);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Graph')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Articles in prerequisite order (top = no prerequisites).',
                  ),
                  const SizedBox(height: 16),
                  ..._layers.entries.map((entry) => _layerView(entry.key, entry.value)),
                ],
              ),
            ),
    );
  }

  Widget _layerView(int depth, List<KnowledgeNode> nodes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('$depth',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nodes
                  .map((n) => _nodeChip(n))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeChip(KnowledgeNode n) {
    Color color;
    switch (n.difficulty) {
      case 'advanced':
        color = Colors.deepOrange;
        break;
      case 'master':
        color = Colors.red;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      default:
        color = AppTheme.primary;
    }
    return InkWell(
      onTap: () => _onTap(n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(n.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(n.category,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _onTap(KnowledgeNode n) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Category: ${n.category}'),
            Text('Difficulty: ${n.difficulty}'),
            if (n.prerequisites.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Prerequisites:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              ...n.prerequisites.map((p) => Text('  • $p')),
            ],
            if (n.relatedDrills.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Related drills:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              ...n.relatedDrills.map((d) => Text('  • $d')),
            ],
          ],
        ),
      ),
    );
  }
}