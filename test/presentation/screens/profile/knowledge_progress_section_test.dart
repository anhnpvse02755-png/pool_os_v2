import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';
import 'package:pool_os_v2/presentation/screens/profile/knowledge_progress_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();
  });

  Widget dungMan() => const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: KnowledgeProgressSection()),
          ),
        ),
      );

  group('KnowledgeProgressSection', () {
    testWidgets('chưa đọc bài nào thì hiện lời mời khám phá', (tester) async {
      await tester.pumpWidget(dungMan());
      await tester.pumpAndSettle();

      expect(find.textContaining('Bạn chưa đọc bài viết nào'), findsOneWidget);
    });

    testWidgets('hiện TIÊU ĐỀ bài đã đọc, không phải id thô', (tester) async {
      await LocalStorageDataSource.markKnowledgeAsRead(
        'kn_stop_shot',
        title: 'Cú Dừng',
      );

      await tester.pumpWidget(dungMan());
      await tester.pumpAndSettle();

      expect(find.text('Cú Dừng'), findsOneWidget);
      expect(find.text('kn_stop_shot'), findsNothing);
    });

    testWidgets('bản ghi cũ không có title thì rơi về id, không vỡ',
        (tester) async {
      // Du lieu ghi truoc khi them truong `title` van phai hien duoc.
      await LocalStorageDataSource.markKnowledgeAsRead('kn_cu_khong_title');

      await tester.pumpWidget(dungMan());
      await tester.pumpAndSettle();

      expect(find.text('kn_cu_khong_title'), findsOneWidget);
    });

    testWidgets('đếm số bài bằng tiếng Việt', (tester) async {
      await LocalStorageDataSource.markKnowledgeAsRead('kn_a', title: 'A');
      await LocalStorageDataSource.markKnowledgeAsRead('kn_b', title: 'B');

      await tester.pumpWidget(dungMan());
      await tester.pumpAndSettle();

      expect(find.text('2 bài viết'), findsOneWidget);
    });
  });
}
