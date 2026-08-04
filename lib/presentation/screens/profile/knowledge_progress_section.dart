import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Knowledge progress section — embedded widget used by Profile / Home.
///
/// Day 2A: read via `cacheRepositoryProvider` instead of LocalStorageService directly.
class KnowledgeProgressSection extends StatefulWidget {
  const KnowledgeProgressSection({super.key});

  @override
  State<KnowledgeProgressSection> createState() =>
      _KnowledgeProgressSectionState();
}

class _KnowledgeProgressSectionState extends State<KnowledgeProgressSection> {
  Map<String, dynamic> _progress = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cache = ProviderScope.containerOf(context, listen: false)
        .read(cacheRepositoryProvider);
    _progress = await cache.getKnowledgeProgress();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    final readIds = _progress.entries
        .where((e) => (e.value as Map)['read'] == true)
        .map((e) => e.key)
        .toList();
    final readCount = readIds.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text('Knowledge Progress',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('$readCount articles read',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            if (readIds.isEmpty)
              const Text('Bạn chưa đọc bài viết nào. Hãy khám phá Knowledge!')
            else
              ...readIds.take(5).map((id) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(id),
                    subtitle: Text(
                      'Read at ${_format((_progress[id] as Map)['readAt'])}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _format(dynamic v) => v == null ? '—' : v.toString().substring(0, 10);
}
