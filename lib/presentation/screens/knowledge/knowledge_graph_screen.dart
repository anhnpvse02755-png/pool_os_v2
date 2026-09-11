import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../data/models/knowledge_node.dart';
import '../../../domain/services/knowledge_graph_service.dart';

/// Knowledge graph visualization - Redesigned with Minimalist Luxury
/// Nodes are placed top-to-bottom by depth; edges are drawn as connectors.
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
  late Brightness _brightness;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightness = Theme.of(context).brightness;
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
      backgroundColor: AppColors.background(_brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(_brightness),
        elevation: 0,
        title: Text(
          'Knowledge Graph',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(_brightness),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary(_brightness)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Articles in prerequisite order',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(_brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ..._layers.entries.map((entry) => _layerView(entry.key, entry.value)),
                ],
              ),
            ),
    );
  }

  Widget _layerView(int depth, List<KnowledgeNode> nodes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary(_brightness).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: Text(
                '$depth',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(_brightness),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: nodes.map((n) => _nodeChip(n)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeChip(KnowledgeNode n) {
    // Bốn bậc độ khó theo THỨ HẠNG, dùng đúng bộ bốn hue tách bạch của hệ —
    // `difficultyExpert` 262° / họ xanh rêu 157-163° / `warning` 38° /
    // `error` 0° — giống `assessment_screen` và `community_screen`.
    // Màu NỀN (dùng ở 10%) tách khỏi màu NÉT. Đo thật: viền `warning` đặc chỉ
    // được 1,95:1 trên nền kem ở bản sáng — dưới sàn 3:1 của thành phần UI.
    // Bản `OnTint` đưa nó lên 4,99. Cùng khuôn đã dùng ở `community_screen`.
    Color fill;
    Color stroke;
    switch (n.difficulty) {
      case 'master':
        fill = AppColors.difficultyExpert(_brightness);
        stroke = fill;
        break;
      case 'advanced':
        fill = AppColors.primary(_brightness);
        stroke = fill;
        break;
      case 'intermediate':
        fill = AppColors.warning;
        stroke = AppColors.warningOnTint(_brightness);
        break;
      default:
        fill = AppColors.error;
        stroke = AppColors.errorOnTint(_brightness);
    }

    return InkWell(
      onTap: () => _onTap(n),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: fill.withValues(alpha: 0.1),
          border: Border.all(color: stroke),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              n.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(_brightness),
              ),
            ),
            Text(
              n.category,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(_brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(KnowledgeNode n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(_brightness),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              n.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(_brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(label: 'Category', value: n.category),
            _DetailRow(label: 'Difficulty', value: n.difficulty),
            if (n.prerequisites.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Prerequisites:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(_brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...n.prerequisites.map((p) => Text('  • $p', style: TextStyle(color: AppColors.textSecondary(_brightness)))),
            ],
            if (n.relatedDrills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Related drills:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(_brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ...n.relatedDrills.map((d) => Text('  • $d', style: TextStyle(color: AppColors.textSecondary(_brightness)))),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: AppColors.textSecondary(brightness)),
          ),
        ],
      ),
    );
  }
}
