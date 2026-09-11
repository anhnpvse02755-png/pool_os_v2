import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pool_os_v2/knowledge/knowledge_provider.dart';

/// Runtime-loading integration test for Commit 5 Gate 2.
///
/// Verifies that `KnowledgeNotifier._loadData()` reads from
/// `assets/knowledge/knowledge.json` (NOT the const fallback) when the
/// asset is bundled. This is the same code path the app uses on startup.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps the binding until the provider's async _loadData settles.
  Future<KnowledgeState> awaitLoad(ProviderContainer container) async {
    // Read triggers construction → _loadData runs in microtask.
    container.read(knowledgeProvider);
    for (var i = 0; i < 50; i++) {
      // Yield to microtask queue so rootBundle.loadString resolves.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final s = container.read(knowledgeProvider);
      if (!s.isLoading) return s;
    }
    return container.read(knowledgeProvider);
  }

  test(
      'KnowledgeNotifier loads all articles from bundled asset '
      '(not from 10-article const fallback)', () async {
    // Asset và notifier phải khớp nhau — nếu lệch thì notifier đã rơi về
    // fallback. Con số 36 là toàn bộ thư viện sau khi gỡ 102 khuôn rỗng
    // (xem knowledge_article_count_test.dart); trước đó nó là 138.
    final raw = await rootBundle.loadString('assets/knowledge/knowledge.json');
    final rawCount = (json.decode(raw) as List).length;
    expect(rawCount, 36, reason: 'Bundled asset must contain 36 articles.');

    // Now exercise the notifier — the production loading path.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = await awaitLoad(container);

    expect(state.allKnowledge.length, rawCount,
        reason: 'Notifier must resolve every article from asset. '
            'Got ${state.allKnowledge.length} — fallback was used.');
    expect(state.allKnowledge.length, greaterThan(10),
        reason: 'Phải nhiều hơn fallback hằng 10 mục.');
    expect(state.fromAssets, true,
        reason: 'fromAssets flag must be true after asset load.');
    expect(state.isLoading, false);
    expect(state.error, isNull);

    // Sanity check: một bài THẬT phải có mặt. Trước đây mốc là
    // `bridge.open_bridge` — một trong 102 khuôn rỗng, nay đã gỡ.
    final bridge =
        state.allKnowledge.where((a) => a.id == 'kn_bridge').toList();
    expect(bridge.length, 1);
    expect(bridge.first.titleVi, isNotNull);
    expect(bridge.first.content.length, greaterThan(400));
  });

  test('knowledgeSearchProvider returns matching articles from asset',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await awaitLoad(container);

    final results = container.read(knowledgeSearchProvider('open bridge'));
    expect(results, isNotEmpty,
        reason: 'Search for "open bridge" must return at least one article '
            'loaded from the bundled asset.');
    // `kn_bridge` khai keyword 'open bridge' nên vẫn khớp truy vấn này.
    expect(results.any((a) => a.id == 'kn_bridge'), true);
  });

  test('getBySlug returns live article loaded from asset', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await awaitLoad(container);

    final notifier = container.read(knowledgeProvider.notifier);
    final stopShot = notifier.getBySlug('stop-shot');
    expect(stopShot, isNotNull,
        reason: 'Live article kn_stop_shot must be present in asset.');
    expect(stopShot!.titleVi, 'Stun shot — Đánh dừng');
  });

  test('mọi bài đều có DifficultyLevel hợp lệ', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await awaitLoad(container);

    final items = container.read(knowledgeProvider).allKnowledge;
    for (final item in items) {
      // Each enum has a label getter that returns non-empty string.
      expect(item.difficulty.label, isNotEmpty,
          reason: 'Article ${item.id} has invalid difficulty.');
    }
  });

  test('categories and tags are loaded alongside articles', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await awaitLoad(container);

    final state = container.read(knowledgeProvider);
    expect(state.categories, isNotEmpty,
        reason: 'Categories must be populated after asset load.');
    expect(state.tags, isNotEmpty,
        reason: 'Tags must be populated after asset load.');
  });
}
