import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pool_os_v2/core/providers/repository_providers.dart';
import 'package:pool_os_v2/core/providers/training_provider.dart';
import 'package:pool_os_v2/data/models/training_session.dart' as model;
import 'package:pool_os_v2/data/datasources/local/local_storage_datasource.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageDataSource.init();
  });

  test('buoi tap luu qua notifier phai hien ra o repository', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(trainingNotifierProvider.notifier);
    final repo = container.read(drillRepositoryProvider);

    await notifier.addSession(model.TrainingSession(
      id: 's1',
      drillCode: 'BT01',
      drillName: 'Bai 1',
      level: 1,
      score: 70,
      shotsMade: 7,
      shotsMissed: 3,
      duration: 10,
      completedAt: DateTime(2026, 9, 17),
    ));

    final history = await repo.getTrainingHistory();

    expect(history.map((s) => s.id), contains('s1'),
        reason: 'hai ban ghi tach roi: notifier ghi vao drill_sessions, '
            'repository doc tu training_history');
  });

  test('buoi tap luu qua repository phai hien ra o notifier sau refresh', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repo = container.read(drillRepositoryProvider);
    await repo.saveTrainingSession(model.TrainingSession(
      id: 's2',
      drillCode: 'BT02',
      drillName: 'Bai 2',
      level: 1,
      score: 80,
      shotsMade: 8,
      shotsMissed: 2,
      duration: 12,
      completedAt: DateTime(2026, 9, 17),
    ));

    final notifier = container.read(trainingNotifierProvider.notifier);
    await notifier.refresh();

    expect(
      container.read(trainingNotifierProvider).sessions.map((s) => s.id),
      contains('s2'),
    );
  });
}
